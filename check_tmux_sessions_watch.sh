#!/bin/bash

hosts=(
  kobuk
  arches
  yosemite
  saguaro
  kenai
  acadia
  zion
  guadalupe
  congaree
  tortugas
  shenandoah
  sequoia
)

## ANSI colors
#GREEN=$(tput setaf 2)
#YELLOW=$(tput setaf 3)
#RED=$(tput setaf 1)
#RESET=$(tput sgr0)

# ANSI color codes (watch-safe)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${YELLOW}Updated at: $(date)${RESET}"
echo "---------------------------------------------"

check_tmux_on_host() {
  host=$1

  # Run tmux ls remotely and capture output
  output=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" 'tmux ls 2>&1')

  # Check for SSH error (e.g., unreachable, auth failure)
  if echo "$output" | grep -qE "Permission denied|Could not resolve|Connection refused|Connection timed out|ssh:"; then
    echo -e "$host: ${RED}SSH Failed or Timeout${RESET}"

  # Check for no tmux sessions (common "no server" message)
  elif echo "$output" | grep -qE "no server running on|error connecting to .*/default"; then
    echo -e "$host: ${GREEN}No tmux sessions${RESET}"

  # If anything else, assume tmux session(s) exist
  else
    echo "$output" | while IFS= read -r line; do
      echo -e "$host: ${YELLOW}$line${RESET}"
    done
  fi
}

export -f check_tmux_on_host
export GREEN YELLOW RED RESET

# Run in parallel for speed
parallel -j 6 check_tmux_on_host ::: "${hosts[@]}"

