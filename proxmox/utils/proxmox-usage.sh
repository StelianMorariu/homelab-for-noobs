#!/bin/bash
# proxmox-usage.sh — robust: uses /cluster/resources JSON
set -euo pipefail

have_jq=0
command -v jq >/dev/null 2>&1 && have_jq=1

# Pull both LXC and QEMU in one go
LXC_JSON="$(pvesh get /cluster/resources --type lxc --output-format json 2>/dev/null || echo '[]')"
QEMU_JSON="$(pvesh get /cluster/resources --type qemu --output-format json 2>/dev/null || echo '[]')"

printf "%-6s %-4s %-16s %-16s %-8s\n" "ID" "Type" "Alloc_RAM(MB)" "Used_RAM(MB)" "CPU%"
echo "--------------------------------------------------------------------"

if [ $have_jq -eq 1 ]; then
  # With jq
  printf "%s\n" "$LXC_JSON" | jq -r '.[] | "\(.vmid)\tLXC\t\(.maxmem/1048576|floor)\t\(.mem/1048576|floor)\t\(.cpu*100)"' |
    awk -F'\t' '{printf "%-6s %-4s %-16.0f %-16.0f %-8.1f\n",$1,$2,$3,$4,$5}'

  printf "%s\n" "$QEMU_JSON" | jq -r '.[] | "\(.vmid)\tVM\t\(.maxmem/1048576|floor)\t\(.mem/1048576|floor)\t\(.cpu*100)"' |
    awk -F'\t' '{printf "%-6s %-4s %-16.0f %-16.0f %-8.1f\n",$1,$2,$3,$4,$5}'

else
  # Fallback to python3 (available on Proxmox nodes)
  python3 - "$LXC_JSON" "$QEMU_JSON" <<'PY'
import json, sys
def rows(items, typ):
    for it in items:
        vmid = it.get("vmid", "?")
        maxmem = int(it.get("maxmem", 0))//1048576
        mem    = int(it.get("mem", 0))//1048576
        cpu    = float(it.get("cpu", 0.0))*100.0
        print(f"{vmid:6} {typ:4} {maxmem:16d} {mem:16d} {cpu:8.1f}")
lxc  = json.loads(sys.argv[1])
qemu = json.loads(sys.argv[2])
rows(lxc,  "LXC")
rows(qemu, "VM")
PY
fi
