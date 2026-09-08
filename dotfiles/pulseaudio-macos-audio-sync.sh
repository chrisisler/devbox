#!/bin/sh
# ponytail: system_profiler is a heavy CoreAudio probe; a ~2s loop caused
# periodic host-audio dropout (rhythmic stutter on every container stream).
# 10s cadence keeps output switching responsive enough without routine glitches;
# upgrade path = native kAudioHardwarePropertyDefaultOutputDevice notification.

while :; do
	selected="$(
		system_profiler SPAudioDataType 2>/dev/null |
		awk '
			/^        [^[:space:]].*:[[:space:]]*$/ {
				device = $0
				sub(/^        /, "", device)
				sub(/:[[:space:]]*$/, "", device)
			}
			/^[[:space:]]+Default (System )?Output Device:[[:space:]]+Yes$/ {
				print device
				exit
			}
		'
	)"

	if test -n "$selected"; then
		sink="$(
			pactl list sinks 2>/dev/null |
			awk -v target="$selected" '
				/^Sink #[0-9]+/ { name = "" }
				/^[[:space:]]+Name:/ { name = $2 }
				/^[[:space:]]+Description:/ {
					description = $0
					sub(/^[[:space:]]*Description:[[:space:]]*/, "", description)
					if (description == target) {
						print name
						exit
					}
				}
			'
		)"

		if test -n "$sink"; then
			current="$(pactl get-default-sink 2>/dev/null || true)"
			test "$current" = "$sink" || pactl set-default-sink "$sink"
		fi
	fi

	sleep 10
done
