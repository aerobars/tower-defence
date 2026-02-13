#!/bin/sh
printf '\033c\033]0;%s\a' Tower Defence
base_path="$(dirname "$(realpath "$0")")"
"$base_path/happiness_comes_in_waves.x86_64" "$@"
