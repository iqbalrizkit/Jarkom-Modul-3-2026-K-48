#!/bin/sh
# pemakaian: sh /root/bench.sh <label> <url> [opsi ab tambahan, mis. -l]
LABEL=$1; URL=$2; shift 2
ab -n 600 -c 30 "$@" "$URL" > /root/ab_$LABEL.txt 2>&1
echo "=== $LABEL ($URL) ==="
grep -E "Time taken|Complete requests|Failed requests|Connect:|Receive:|Length:|Exceptions:|Non-2xx|Requests per second|Time per request" /root/ab_$LABEL.txt
grep -E "^ +(50|95|99|100)%" /root/ab_$LABEL.txt