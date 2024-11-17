#/bin/bash

host=${1:?Hostname is required}
port=${2:?Port is required}
timeout=${3:-10}

echo "Testing $host:$port with $timeout timeout..."

nc -z -v -u -w$timeout "$host" "$port"
