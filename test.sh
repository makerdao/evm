#! /bin/bash

contract="${1:-$(cat /dev/stdin)}"

printf "\n\nstarting tests\n\n"

echo "fallback function"
seth send $contract
printf "^^^^^^^^^^ should fail ^^^^^^^^^^\n\n"

echo "poke"
seth call $contract 'poke(uint256[],uint256[],uint256[],uint8,bytes32,bytes32)' [2,8] [3] [4] 27 0x38408b06af413ecfc9d9b2fc3f0a7919afc0e942db67dacc966fbe63c6ea5359 0x78c0fb75de33406c2d33ea7dc8bb76bdb656e66137e9375462e53697134bfa04
