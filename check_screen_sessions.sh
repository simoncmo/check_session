#!/bin/bash

# Cluster node list
hosts=(
  katmai
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

# Safe ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${YELLOW}Updated at: $(date)${RESET}"
echo "---------------------------------------------"

check_screen_on_host() {
  host=$1

  # Run screen -ls remotely and capture output
  output=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" 'screen -ls 2>&1')

  # Check for SSH failure
  if echo "$output" | grep -qE "Permission denied|Could not resolve|Connection refused|Connection timed out|ssh:"; then
    echo -e "$host: ${RED}SSH Failed or Timeout${RESET}"

  # No screens running
  elif echo "$output" | grep -qi "No Sockets found"; then
    echo -e "$host: ${GREEN}No screen sessions${RESET}"

  # Found screen sessions
  else
    echo "$output" | grep -Eo '[0-9]+\..+?\s+\(.*\)' | while IFS= read -r line; do
      echo -e "$host: ${YELLOW}$line${RESET}"
    done
  fi
}

export -f check_screen_on_host
export GREEN YELLOW RED RESET

# Run checks in parallel
parallel -j 6 check_screen_on_host ::: "${hosts[@]}"
