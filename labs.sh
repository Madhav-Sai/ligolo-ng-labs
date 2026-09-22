#!/usr/bin/env bash
# One entry point for every Docker-based lab in this repo.
#
# Why this exists: each lab level already has its own setup.sh/verify.sh/reset.sh,
# but that means remembering which folder to cd into and which script to run for
# which module of the course. This just wraps that in a menu so "start the lab for
# Module 5" doesn't require knowing any of that first.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

check_requirements() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker isn't installed (or isn't on your PATH)."
    echo "Install it from https://docs.docker.com/get-docker/ and run this again."
    exit 1
  fi
  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker is installed, but the 'docker compose' plugin isn't available."
    echo "See https://docs.docker.com/compose/install/ and run this again."
    exit 1
  fi
  if ! docker info >/dev/null 2>&1; then
    echo "Docker is installed but doesn't seem to be running."
    echo "Start Docker Desktop (or the docker daemon) and run this again."
    exit 1
  fi
}

declare -A LAB_DIR=(
  [1]="docker/level-01-single-hop"
  [2]="docker/level-02-double-hop"
  [3]="docker/level-03-multi-hop"
  [4]="docker/level-04-enterprise"
)
declare -A LAB_LABEL=(
  [1]="Level 01 — Single-Hop Pivot"
  [2]="Level 02 — Double-Hop Pivot"
  [3]="Level 03 — Multi-Hop Pivot"
  [4]="Level 04 — Enterprise-Style Pivot"
)

print_menu() {
  echo
  echo -e "${BOLD}Ligolo-ng Labs${RESET}"
  echo "Which lab do you want to start?"
  echo
  for k in 1 2 3 4; do
    echo "  $k) ${LAB_LABEL[$k]}"
  done
  echo -e "  5) ${DIM}Manual lab instructions (Linux/Windows VMs, not Docker)${RESET}"
  echo -e "  6) ${DIM}Troubleshooting labs (run these manually — see docker/troubleshooting/README.md)${RESET}"
  echo "  r) Reset a lab that's already running"
  echo "  q) Quit"
  echo
}

start_lab() {
  local dir="${LAB_DIR[$1]}"
  echo
  echo "[*] Starting ${LAB_LABEL[$1]}..."
  (cd "$dir" && ./setup.sh)
  echo
  read -r -p "Run the verify script now to confirm the lab came up correctly? [Y/n] " ans
  if [[ "${ans:-Y}" =~ ^[Yy]$ ]]; then
    (cd "$dir" && ./verify.sh) || true
  fi
  echo
  echo -e "${DIM}When you're done, come back here and choose 'r' to reset this lab.${RESET}"
}

reset_lab() {
  echo
  for k in 1 2 3 4; do
    echo "  $k) ${LAB_LABEL[$k]}"
  done
  read -r -p "Which lab do you want to reset? " choice
  local dir="${LAB_DIR[$choice]:-}"
  if [ -z "$dir" ]; then
    echo "Not a valid choice."
    return
  fi
  (cd "$dir" && ./reset.sh)
}

check_requirements

while true; do
  print_menu
  read -r -p "> " choice
  case "$choice" in
    1|2|3|4) start_lab "$choice" ;;
    5)
      echo
      echo "Manual labs build real VMs instead of containers — there's nothing to run"
      echo "from this script. Open manual/linux/README.md or manual/windows/README.md"
      echo "and follow the steps there."
      ;;
    6)
      echo
      echo "Troubleshooting labs are meant to be run by hand, one command at a time —"
      echo "part of the exercise is reading Docker's own output as you go, which this"
      echo "menu would only get in the way of. Open docker/troubleshooting/README.md"
      echo "and follow it from there."
      ;;
    r|R) reset_lab ;;
    q|Q) exit 0 ;;
    *) echo "Not a valid choice." ;;
  esac
done
