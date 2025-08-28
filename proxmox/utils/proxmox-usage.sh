#!/bin/bash
printf "%-6s %-4s %-15s %-15s %-8s\n" "ID" "Type" "Allocated_RAM(MB)" "Used_RAM(MB)" "CPU%"
echo "-------------------------------------------------------------------------------"

# LXCs
pct list | awk 'NR>1 {print $1}' | while read id; do
  alloc=$(pct config $id | awk '/memory/ {print $2}')
  used=$(pct status $id | awk -F'[:,]' '/memory/ {printf "%d", $2/1024/1024}')
  cpu=$(pct status $id | awk -F'[:,]' '/cpu/ {printf "%.1f", $2*100}')
  printf "%-6s %-4s %-15s %-15s %-8s\n" "$id" "LXC" "$alloc" "$used" "$cpu"
done

# QEMU VMs
qm list | awk 'NR>1 {print $1}' | while read id; do
  alloc=$(qm config $id | awk '/memory:/ {print $2}')
  used=$(qm monitor $id info balloon 2>/dev/null | awk '/actual/ {print $2/1024}')
  cpu=$(qm status $id | awk -F'[:,]' '/cpu/ {printf "%.1f", $2*100}')
  printf "%-6s %-4s %-15s %-15s %-8s\n" "$id" "VM" "$alloc" "${used:-?}" "$cpu"
done
