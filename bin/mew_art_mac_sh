#!/usr/bin/env zsh

mew_art() {
  local art
  art=$(cat <<'EOF'
             ▓▒░░▓
           ▒▒░░░▓
         ▓▒▒▒▒▒ ▓▓▓░░░▓
       ▓▒▒▒░░▒░░░░░░░▒▒
     ▓▒▒▒▒▒░░░░░░░░▒▒░░▒
    ▓▒▓    ░░░░░░░░▒▓▒░▒
   ▓▓     ▒░▒▒▓░░░░░▒░▒  █▓▓▓▓▓▓▓▓▓▒▒▓
  ▓▓       ▒░░▒░░░░▒▒▓▓▓▓▓          ▓▓
  ▓▓        ▓▓▓▒▒▒▒▒▒▒░▒░░░▒       ▓▓▓
  ▓▓▓▓▓▓▓▓▓▓  ▒░░▒▒░░░░░▒        ▓▓▓
              ▒▒  ▒░░░░░░░▒    ▓▓▓
                  ▒░░░░░░░░░▓▓▓▓
                  ▒░░░░▒░░░░░█
                  ▒▒░░░░▒▒▒▒▒▓
                  ▒▒▓▓▒▒▓▓ ▓▒▒█
                  ▓▒▒▒      ▒░▒▓
                  ▒▒░▒▓     ░░░▒
                   ▒░░▒     ▓░░░▒
                    ▓▓       ░░░░▓
                             ▒▒░▒▓
EOF
)

  # Muted Mew palette
  local reset=$'\e[0m'
  local accent=$'\e[38;2;185;155;170m'
  local text=$'\e[38;2;205;205;210m'
  local dim=$'\e[38;2;140;140;150m'

  # System information
  local os="$(sw_vers -productVersion)"
  local host="$(hostname -s)"
  local model="$(sysctl -n hw.model 2>/dev/null)"
  local kernel="$(uname -r)"
  local arch="$(uname -m)"
  local terminal="${TERM_PROGRAM:-Unknown}"
  local shell_name="zsh ${ZSH_VERSION}"

  # Memory
  local memory_bytes="$(sysctl -n hw.memsize)"
  local memory_gb="$(( memory_bytes / 1073741824 ))"

  # Uptime
  local boot_time="$(sysctl -n kern.boottime | sed -E 's/.*sec = ([0-9]+).*/\1/')"
  local uptime_sec="$(( $(date +%s) - boot_time ))"
  local days="$(( uptime_sec / 86400 ))"
  local hours="$(( (uptime_sec % 86400) / 3600 ))"
  local uptime="${days}d ${hours}h"

  # Info lines
  local -a info
  info=(
    "${accent}${USER}@${host}${reset}"
    "${dim}──────────────────────────${reset}"
    "${accent}OS        ${text}macOS ${os}${reset}"
    "${accent}Host      ${text}${model}${reset}"
    "${accent}Kernel    ${text}${kernel}${reset}"
    "${accent}Arch      ${text}${arch}${reset}"
    "${accent}Uptime    ${text}${uptime}${reset}"
    "${accent}Memory    ${text}${memory_gb} GiB${reset}"
    "${accent}Shell     ${text}${shell_name}${reset}"
    "${accent}Terminal  ${text}${terminal}${reset}"
    ""
    $'\e[48;2;145;120;130m  \e[48;2;165;150;155m  \e[48;2;180;170;175m  \e[48;2;195;190;192m  \e[0m'
    ""
    "${dim}──────────────────────────${reset}"
    "${accent}#151 ${text}— MEW${reset}"
    "${dim}PSYCHIC · NEW SPECIES POKÉMON${reset}"
    "${text}The ancestor of all Pokémon.${reset}"
  )

  # Split ASCII art into lines
  local -a lines
  lines=("${(@f)art}")

  # Calculate artwork width
  local width=0
  local line
  for line in "${lines[@]}"; do
    (( ${#line} > width )) && width=${#line}
  done

  # Display art and info side by side
  local count=${#lines}
  (( ${#info} > count )) && count=${#info}

  local i colored padding
  print ""

  for (( i=1; i<=count; i++ )); do
    line="${lines[i]:-}"
    colored="$line"

    colored=${colored//█/$'\e[38;2;165;120;140m'█$reset}
    colored=${colored//▓/$'\e[38;2;185;155;170m'▓$reset}
    colored=${colored//▒/$'\e[38;2;195;175;185m'▒$reset}
    colored=${colored//░/$'\e[38;2;205;195;200m'░$reset}

    padding=$(( width - ${#line} + 4 ))

    printf "%s%*s%s\n" \
      "$colored" \
      "$padding" "" \
      "${info[i]:-}"
  done

  print ""
}


mew_art
