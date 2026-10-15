#!/bin/sh
printf "%-20s %9s %9s %9s %8s %8s %8s\n" FILE RPS RPS_OK MEAN_MS P95_MS FAILED NON2XX
for f in /root/ab_*.txt; do
  n=$(basename "$f" .txt)
  complete=$(grep "Complete requests" "$f" | awk '{print $3}')
  t=$(grep "Time taken for tests" "$f" | awk '{print $5}')
  rps=$(grep "Requests per second" "$f" | awk '{print $4}')
  mean=$(grep "Time per request" "$f" | head -1 | awk '{print $4}')
  p95=$(grep -E "^ +95%" "$f" | awk '{print $2}')
  failed=$(grep "Failed requests" "$f" | awk '{print $3}')
  non2xx=$(grep "Non-2xx" "$f" | awk '{print $3}')
  [ -z "$non2xx" ] && non2xx=0
  ok=$(awk -v c="$complete" -v n="$non2xx" -v t="$t" 'BEGIN{ if (t>0) printf "%.2f", (c-n)/t; else print "-" }')
  printf "%-20s %9s %9s %9s %8s %8s %8s\n" "$n" "$rps" "$ok" "$mean" "$p95" "$failed" "$non2xx"
done