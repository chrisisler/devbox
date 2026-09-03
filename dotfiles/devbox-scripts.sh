#!/usr/bin/env bash

set -eu

devbox_mounts() {
  local cache="$(git rev-parse --show-toplevel)/.devbox-mounts"
  local hostPath target existingTarget
  local -a hostPaths=()
  local -a targets=()

  if [[ -s "$cache" ]]; then
    while IFS= read -r hostPath; do
      [[ -n "$hostPath" ]] || continue
      [[ -d "$hostPath" ]] || {
        printf 'Cached mount directory does not exist: %s\nDelete %s to choose again\n' "$hostPath" "$cache" >&2
        return 1
      }
      hostPath="$(realpath -- "$hostPath")"
      hostPaths+=("$hostPath")
    done < "$cache"
  else
    printf 'Choose directories to mount (blank entry ends selection)\n'
    while :; do
      read -r -e -p "Directory $(( ${#hostPaths[@]} + 1 )): " hostPath
      [[ -n "$hostPath" ]] || break
      [[ -d "$hostPath" ]] || {
        printf 'Not a directory: %s\n' "$hostPath" >&2
        continue
      }
      hostPaths+=("$(realpath -- "$hostPath")")
    done
    ((${#hostPaths[@]} > 0)) || {
      printf 'Choose at least one directory\n' >&2
      return 1
    }
  fi

  for hostPath in "${hostPaths[@]}"; do
    target="/home/devuser/$(basename -- "$hostPath")"
    for existingTarget in "${targets[@]}"; do
      [[ "$existingTarget" != "$target" ]] || {
        printf 'Mount target collision: %s\nChoose directories with unique names\n' "$target" >&2
        return 1
      }
    done
    targets+=("$target")
    mountArgs+=(--volume "$hostPath:$target")
  done
  [[ -s "$cache" ]] || {
    printf '%s\n' "${hostPaths[@]}" > "$cache"
    chmod 600 "$cache"
  }
}

devbox() {
  local repo="$1"
  local branchName="$(git rev-parse --abbrev-ref HEAD)"
  local containerName="devbox-${branchName//[^a-zA-Z0-9_.-]/-}-$$"
  local -a mountArgs=()
  local dockerArgs=(
    run
    --interactive
    --tty
    --rm
    --init
    --cap-drop=ALL
    --security-opt=no-new-privileges
    --memory=12g
    --cpus=6
    -e "GH_TOKEN=$(gh auth token)"
  )

  if docker ps --filter name=devbox- --format '{{.Names}}' | grep --quiet .; then
    printf 'Existing devbox detected; leaving host ports with existing container\n'
  else
    dockerArgs+=(
      -p 127.0.0.1:3000:3000
      -p 127.0.0.1:5173:5173
      -p 127.0.0.1:8082:8082
    )
  fi

  devbox_mounts

  # --volume "$HOME/.fcc:/home/devuser/.fcc" \
  # -e MODEL="openai/gpt-5.6-luna" \
  docker "${dockerArgs[@]}" \
    "${mountArgs[@]}" \
    --volume "$HOME/.ssh/devbox:/home/devuser/.ssh" \
    --volume "$HOME/.codex:/home/devuser/.codex" \
    --volume "$HOME/.copilot:/home/devuser/.copilot" \
    --volume "$HOME/.local/share/opencode:/home/devuser/.local/share/opencode" \
    --name "$containerName" \
    "${repo:?}" /bin/bash
}
