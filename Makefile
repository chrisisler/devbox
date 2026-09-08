REPOSITORY := chrisisler/devbox
BASE_SYS_REPOSITORY := $(REPOSITORY)-base-sys

all: cached

run:
	@source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY)

everything: base tdf termpdf imagemagick lilypond syncthing mpv cmus pianobar

tdf:
	@docker build --tag chrisisler/tdf --file base/tdf base

termpdf:
	@docker build --tag chrisisler/termpdf --file base/termpdf base

imagemagick:
	@docker build --tag chrisisler/imagemagick --file base/imagemagick base

lilypond:
	@docker build --tag chrisisler/lilypond --file base/lilypond base

syncthing:
	@docker build --tag chrisisler/syncthing --file base/syncthing base

# Shared macOS audio bridge: host PulseAudio + TCP module + auto-switch to
# newly connected outputs and output-port changes. Modules persist via ~/.config/pulse/default.pa
# (created with .include so system defaults still load) and load live.
# Auto-detects: skipped on non-Darwin hosts, which use native host audio.
pulseaudio:
	@test "$$(uname -s)" = Darwin || { echo "audio: host bridge skipped (not macOS)"; exit 0; }
	@command -v brew >/dev/null || { echo "audio: install Homebrew first" >&2; exit 1; }
	@command -v pulseaudio >/dev/null || brew install pulseaudio
	@command -v pactl >/dev/null || { echo "audio: PulseAudio tools unavailable" >&2; exit 1; }
	@mkdir -p ~/.config/pulse
	@module_dir="$(HOME)/.config/pulse/modules"; \
		brew_modules="$$(brew --prefix pulseaudio)/lib/pulseaudio/modules"; \
		mkdir -p "$$module_dir"; \
		for module in "$$brew_modules"/*.dylib; do \
			name="$$(basename "$$module" .dylib)"; \
			ln -sf "$$module" "$$module_dir/$$name.so"; \
			ln -sf "$$module" "$$module_dir/$$name.dylib"; \
		done
	@test -f ~/.config/pulse/default.pa || printf '.include %s/etc/pulse/default.pa\n' "$$(brew --prefix)" > ~/.config/pulse/default.pa
	@sed -i '' "s#^\.include .*#\.include $$(brew --prefix pulseaudio)/etc/pulse/default.pa#" ~/.config/pulse/default.pa
	@sed -i '' '/load-module module-switch-on-port-available/d' ~/.config/pulse/default.pa
	@grep -qs 'module-native-protocol-tcp' ~/.config/pulse/default.pa || echo 'load-module module-native-protocol-tcp port=4713 auth-anonymous=1' >> ~/.config/pulse/default.pa
	@grep -qs 'module-switch-on-connect' ~/.config/pulse/default.pa || echo 'load-module module-switch-on-connect' >> ~/.config/pulse/default.pa
	@pactl info >/dev/null 2>&1 || pulseaudio --daemonize=yes --exit-idle-time=-1 --dl-search-path="$(HOME)/.config/pulse/modules:$$(brew --prefix pulseaudio)/lib/pulseaudio/modules"
	@pactl list modules short | grep -q 'module-native-protocol-tcp' || \
		pactl load-module module-native-protocol-tcp port=4713 auth-anonymous=1 >/dev/null
	@pactl list modules short | grep -q 'module-switch-on-connect' || \
		pactl load-module module-switch-on-connect >/dev/null
	@pid_file="$(HOME)/.config/pulse/devbox-macos-audio-sync.pid"; \
		pid="$$(cat "$$pid_file" 2>/dev/null || true)"; \
		if test -z "$$pid" || ! kill -0 "$$pid" 2>/dev/null || \
			! ps -p "$$pid" -o command= | grep -q 'pulseaudio-macos-audio-sync.sh'; then \
			nohup "$(CURDIR)/dotfiles/pulseaudio-macos-audio-sync.sh" >/dev/null 2>&1 </dev/null & \
			printf '%s\n' "$$!" > "$$pid_file"; \
		fi
	@echo "audio host setup complete"

pulseaudio-stop:
	@test "$$(uname -s)" = Darwin || { echo "audio: sync daemon stop skipped (not macOS)"; exit 0; }
	@pid_file="$(HOME)/.config/pulse/devbox-macos-audio-sync.pid"; \
		pid="$$(cat "$$pid_file" 2>/dev/null || true)"; \
		if test -n "$$pid" && kill -0 "$$pid" 2>/dev/null && \
			ps -p "$$pid" -o command= | grep -q 'pulseaudio-macos-audio-sync.sh'; then \
			kill "$$pid"; \
			echo "audio: stopped sync daemon ($$pid)"; \
		else \
			echo "audio: sync daemon not running"; \
		fi

mpv-host: pulseaudio
	@test "$$(uname -s)" = Darwin || { echo "mpv: host setup requires macOS" >&2; exit 1; }
	@command -v brew >/dev/null || { echo "mpv: install Homebrew first" >&2; exit 1; }
	@test -d /Applications/XQuartz.app || test -d /Applications/Utilities/XQuartz.app || brew install --cask xquartz
	@defaults write org.xquartz.X11 nolisten_tcp -bool false
	@open -gj -a XQuartz
	@sleep 2
	@xhost="$$(command -v xhost || printf '%s' /opt/X11/bin/xhost)"; \
		test -x "$$xhost" || { echo "mpv: xhost unavailable" >&2; exit 1; }; \
		DISPLAY=:0 "$$xhost" +localhost
	@echo "mpv host setup complete; restart XQuartz once if it was already running"

mpv: mpv-host
	@docker build --tag chrisisler/mpv --file base/mpv base
	@bash -ceu 'if ! bash -ic "declare -F mpv >/dev/null" >/dev/null 2>&1; then \
		repo_dir="$$(pwd -P)"; \
		source_line="$$(printf "source %q" "$$repo_dir/.dockerfunc")"; \
		if ! grep -Fqx "$$source_line" "$$HOME/.bashrc" 2>/dev/null; then \
			printf "\n%s\n" "$$source_line" >> "$$HOME/.bashrc"; \
			echo "mpv: added $$source_line to $$HOME/.bashrc"; \
		fi; \
	fi'

# Wrong output device? Check placement, flip default (persists), move live stream:
#   pactl info | grep -i 'default sink'
#   pactl list sink-inputs | grep -E 'Sink Input|Sink:'
#   pactl set-default-sink <SINK>
#   pactl move-sink-input <INPUT#> <SINK>
# Find <SINK> via `pactl list sinks short`, e.g. Channel_1__Channel_2.3 (WH-1000XM3).
cmus: pulseaudio
	@docker build --tag chrisisler/cmus --file base/cmus base

pianobar-proxy:
	@if docker container inspect devbox-pianobar-proxy >/dev/null 2>&1; then \
		test "$$(docker inspect --format '{{.State.Running}}' devbox-pianobar-proxy)" = true || docker start devbox-pianobar-proxy >/dev/null; \
	else \
		docker run --detach --name devbox-pianobar-proxy \
			--restart unless-stopped \
			--mount type=volume,src=devbox-mitmproxy,dst=/home/mitmproxy/.mitmproxy \
			--publish 127.0.0.1:8080:8080 \
			--publish 127.0.0.1:8081:8081 \
			mitmproxy/mitmproxy mitmweb \
			--listen-host 0.0.0.0 \
			--listen-port 8080 \
			--web-host 0.0.0.0 \
			--web-port 8081 >/dev/null; \
	fi
	@test -s "$(HOME)/repos/devbox/mitmproxy-ca.pem" || \
		curl --fail --silent --show-error --proxy http://127.0.0.1:8080 \
		http://mitm.it/cert/pem --output "$(HOME)/repos/devbox/mitmproxy-ca.pem"

pianobar: pulseaudio pianobar-proxy
	@docker build --tag chrisisler/pianobar --file base/pianobar base

clean-base:
	@docker rmi --force $(BASE_SYS_REPOSITORY)

clean:
	@docker rmi --force $(REPOSITORY)

base:
	@docker build --tag $(BASE_SYS_REPOSITORY) --file base/Dockerfile.sys base

dotfiles: base
	@docker build --no-cache --tag $(REPOSITORY) .

cached: base
	@docker build --tag $(REPOSITORY) .

update:
	@./dotfiles/update-dotfiles.sh

.PHONY: all base dotfiles everything clean cached tdf termpdf \
	imagemagick lilypond syncthing pulseaudio pulseaudio-stop mpv cmus pianobar \
	pianobar-proxy
