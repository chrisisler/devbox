REPOSITORY := chrisisler/devbox
BASE_SYS_REPOSITORY := $(REPOSITORY)-base-sys
TDF_REPOSITORY := chrisisler/tdf
TERMPDF_REPOSITORY := chrisisler/termpdf
IMAGEMAGICK_REPOSITORY := chrisisler/imagemagick
LILYPOND_REPOSITORY := chrisisler/lilypond
SYNCTHING_REPOSITORY := chrisisler/syncthing
MPV_REPOSITORY := chrisisler/mpv
PULSEAUDIO_REPOSITORY := chrisisler/pulseaudio
XQUARTZ_VERSION := 2.8.6

all: cached

run:
	@source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY)

everything: base tdf termpdf cimagemagick clilypond csyncthing cpulseaudio mpv

tdf:
	@docker build --tag $(TDF_REPOSITORY) --file base/tdf base

termpdf:
	@docker build --tag $(TERMPDF_REPOSITORY) --file base/termpdf base

cimagemagick:
	@docker build --tag $(IMAGEMAGICK_REPOSITORY) --file base/imagemagick base

clilypond:
	@docker build --tag $(LILYPOND_REPOSITORY) --file base/lilypond base

csyncthing:
	@docker build --tag $(SYNCTHING_REPOSITORY) --file base/syncthing base

mpv-host:
	@test "$$(uname -s)" = Darwin || { echo "mpv: host setup requires macOS" >&2; exit 1; }
	@command -v brew >/dev/null || { echo "mpv: install Homebrew first" >&2; exit 1; }
	@test -d /Applications/XQuartz.app || test -d /Applications/Utilities/XQuartz.app || brew install --cask xquartz
	@xquartz_app="$$(mdfind 'kMDItemCFBundleIdentifier == "org.xquartz.X11"' | head -n1)"; \
		xquartz_app="$${xquartz_app:-/Applications/Utilities/XQuartz.app}"; \
		xquartz_version="$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$$xquartz_app/Contents/Info.plist" 2>/dev/null)"; \
		test "$$xquartz_version" = "$(XQUARTZ_VERSION)" || \
		{ echo "mpv: XQuartz $(XQUARTZ_VERSION) required (found: $${xquartz_version:-unknown})" >&2; exit 1; }
	@command -v pulseaudio >/dev/null || brew install pulseaudio
	@command -v pactl >/dev/null || { echo "mpv: PulseAudio tools unavailable" >&2; exit 1; }
	@defaults write org.xquartz.X11 nolisten_tcp -bool false
	@open -gj -a XQuartz
	@sleep 2
	@xhost="$$(command -v xhost || printf '%s' /opt/X11/bin/xhost)"; \
		test -x "$$xhost" || { echo "mpv: XQuartz xhost unavailable" >&2; exit 1; }; \
		DISPLAY=:0 "$$xhost" +localhost
	@pactl info >/dev/null 2>&1 || pulseaudio --exit-idle-time=-1
	@pactl list modules short | grep -q 'module-native-protocol-tcp' || \
		pactl load-module module-native-protocol-tcp port=4713 auth-anonymous=1 >/dev/null
	@echo "mpv host setup complete; restart XQuartz once if it was already running"

mpv: mpv-host
	@docker build --tag $(MPV_REPOSITORY) --file base/mpv base

cmpv: mpv

cpulseaudio:
	@docker build --tag $(PULSEAUDIO_REPOSITORY) --file base/pulseaudio base

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
	cimagemagick clilypond csyncthing cpulseaudio mpv-host mpv cmpv
