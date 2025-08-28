#!/bin/bash
# proxmox-usage.sh (pvesh-based, robust)
set -euo pipefail

NODE="$(hostname)"

printf "%-6s %-4s %-16s %-16s %-8s\n" "ID" "Type" "Alloc_RAM(MB)" "Used_RAM(MB)" "CPU%"
echo "--------------------------------------------------------------------"

# ---- LXCs ----
if command -v pct >/dev/null 2>&1; then
  pct list | awk 'NR>1 {print $1}' | while read -r ID; do
    # Query status/current for accurate, live numbers
    JSON="$(pvesh get /nodes/$NODE/lxc/$ID/status/current 2>/dev/null || true)"
    if [ -n "$JSON" ]; then
      MAXMEM=$(echo "$JSON" | awk -F'[:,}]' '/"maxmem":/ {gsub(/[^0-9]/,"",$2); print $2; exit}')
      MEM=$(echo "$JSON"    | awk -F'[:,}]' '/"mem":/    {gsub(/[^0-9]/,"",$2); print $2; exit}')
      CPUF=$(echo "$JSON"   | awk -F'[:,}]' '/"cpu":/    {gsub(/[^0-9.]/,"",$2); print $2; exit}')  # fraction (0..1)

      # Fallbacks if stopped
      [ -z "$MAXMEM" ] && MAXMEM=0
      [ -z "$MEM" ] && MEM=0
      [ -z "$CPUF" ] && CPUF=0

      ALLOC_MB=$(awk -v b="$MAXMEM" 'BEGIN{printf "%.0f", b/1024/1024}')
      USED_MB=$(awk -v b="$MEM"    'BEGIN{printf "%.0f", b/1024/1024}')
      CPU_PCT=$(awk -v f="$CPUF"   'BEGIN{printf "%.1f", f*100}')

      printf "%-6s %-4s %-16s %-16s %-8s\n" "$ID" "LXC" "$ALLOC_MB" "$USED_MB" "$CPU_PCT"
    else
      # Could be deleted or inaccessible
      printf "%-6s %-4s %-16s %-16s %-8s\n" "$ID" "LXC" "?" "?" "?"
    fi
  done
fi

# ---- QEMU VMs ----
if command -v qm >/dev/null 2>&1; then
  qm list | awk 'NR>1 {print $1}' | while read -r ID; do
    JSON="$(pvesh get /nodes/$NODE/qemu/$ID/status/current 2>/dev/null || true)"
    if [ -n "$JSON" ]; then
      MAXMEM=$(echo "$JSON" | awk -F'[:,}]' '/"maxmem":/ {gsub(/[^0-9]/,"",$2); print $2; exit}')
      MEM=$(echo "$JSON"    | awk -F'[:,}]' '/"mem":/    {gsub(/[^0-9]/,"",$2); print $2; exit}')
      CPUF=$(echo "$JSON"   | awk -F'[:,}]' '/"cpu":/    {gsub(/[^0-9.]/,"",$2); print $2; exit}')  # fraction (0..1)

      [ -z "$MAXMEM" ] && MAXMEM=0
      [ -z "$MEM" ] && MEM=0
      [ -z "$CPUF" ] && CPUF=0

      ALLOC_MB=$(awk -v b="$MAXMEM" 'BEGIN{printf "%.0f", b/1024/1024}')
      USED_MB=$(awk -v b="$MEM"    'BEGIN{printf "%.0f", b/1024/1024}')
      CPU_PCT=$(awk -v f="$CPUF"   'BEGIN{printf "%.1f", f*100}')

      printf "%-6s %-4s %-16s %-16s %-8s\n" "$ID" "VM" "$ALLOC_MB" "$USED_MB" "$CPU_PCT"
    else
      printf "%-6s %-4s %-16s %-16s %-8s\n" "$ID" "VM" "?" "?" "?"
    fi
  done
fi
