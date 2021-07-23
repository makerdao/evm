#! /bin/bash

addr=$(xargs seth send --create --gas 500000 < /dev/stdin)
echo "code: $(seth code ${addr})" > /dev/stderr
echo "address: ${addr}" > /dev/stderr
echo $addr > /dev/stdout
