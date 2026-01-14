#!/bin/bash
# =====================================
# PostLite — Linux Post Exploitation v4
# Lightweight | Signal-Focused
# =====================================

RED="\e[31m"; YEL="\e[33m"; GRN="\e[32m"; BLU="\e[34m"; NC="\e[0m"

info() { echo -e "[INFO] $1"; }
high() { echo -e "${YEL}[HIGH] $1${NC}"; }
crit() { echo -e "${RED}[CRITICAL] $1${NC}"; }

clear
echo "╔══════════════════════════════════════╗"
echo "║ PostLite — Linux Post Exploitation   ║"
echo "║ Lightweight • Signal‑Focused         ║"
echo "╚══════════════════════════════════════╝"

USER=$(whoami)
HOST=$(hostname)
KERNEL=$(uname -r)

info "User: $USER"
info "Host: $HOST"
info "Kernel: $KERNEL"

echo
echo "──────────────"
echo "[ PHASE 1 — Context ]"
echo "──────────────"

# Container / LXD
if groups | grep -q lxd; then
  crit "User is in lxd group (container root possible)"
fi

# Kernel intelligence
KV_MAJOR=$(echo "$KERNEL" | cut -d. -f1)
KV_MINOR=$(echo "$KERNEL" | cut -d. -f2)

if [ "$KV_MAJOR" -lt 5 ]; then
  high "Old kernel — kernel exploits likely"
fi

echo
echo "──────────────"
echo "[ PHASE 2 — Privilege Escalation Signals ]"
echo "──────────────"

# SUID / SGID (filtered)
for b in pkexec sudo passwd chsh newgrp; do
  if [ -u "$(command -v $b 2>/dev/null)" ]; then
    high "Interesting SUID binary: $(command -v $b)"
  fi
done

# Capabilities
if command -v getcap >/dev/null 2>&1; then
  CAPS=$(getcap -r / 2>/dev/null | grep -E "cap_setuid|cap_sys_admin|cap_dac_read_search")
  if [ -n "$CAPS" ]; then
    crit "Dangerous Linux capabilities detected"
  fi
fi

# Sudo misconfig
if sudo -n -l >/dev/null 2>&1; then
  high "Passwordless sudo possible"
  sudo -n -l 2>/dev/null | grep -E "(NOPASSWD|vim|less|find|tar|awk|perl)" >/dev/null && \
  crit "Dangerous sudo rule detected"
fi

# Cron jobs
for c in /etc/crontab /etc/cron.d/*; do
  [ -w "$c" ] && crit "Writable cron file: $c"
done

# File permissions
for f in /etc/passwd /etc/shadow; do
  [ -w "$f" ] && crit "Writable critical file: $f"
done

# Env / PATH abuse
echo "$PATH" | tr ':' '\n' | while read d; do
  [ -w "$d" ] && high "Writable PATH directory: $d"
done

# NFS
mount | grep nfs | grep -q no_root_squash && \
crit "NFS mount with no_root_squash detected"

# SSH keys / creds (presence only)
[ -d "$HOME/.ssh" ] && high "User SSH directory present"
[ -f "$HOME/.bash_history" ] && high "Shell history present"

echo
echo "──────────────"
echo "[ SUMMARY ]"
echo "──────────────"

echo -e "${GRN}PostLite analysis complete — manual exploitation paths identified where applicable.${NC}"
