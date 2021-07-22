#! /bin/bash

addr=$(xargs seth send --create --gas 500000 < /dev/stdin)
echo "code: $(seth code ${addr})"
echo "address: ${addr}"
