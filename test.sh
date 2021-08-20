#! /bin/bash

contract="${1:-$(cat /dev/stdin)}"

printf "\n\nstarting tests\n\n"

echo "fallback function"
seth send $contract
printf "^^^^^^^^^^ should fail ^^^^^^^^^^\n\n"

hash=$(seth keccak 0x0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000004)

signature=$(ethsign msg --data $hash --passphrase-file ~/.dapp/password)

r="${signature:0:66}"
s="0x${signature:66:64}"
v="0x${signature:130}"

echo "poke"
seth call $contract 'poke(uint256[],uint256[],uint256[],uint8,bytes32,bytes32)' [2,8] [3] [4] $v $r $s
printf "^^^^^ should revert with                              $ETH_FROM ^^^^^\n\n"

echo "lift"
seth send $contract 'lift(address)' $ETH_FROM
printf "^^^^ should succeed ^^^^^^\n\n"

echo "poke"
seth call $contract 'poke(uint256[],uint256[],uint256[],uint8,bytes32,bytes32)' [2,8] [3] [4] $v $r $s
printf "^^^^^ should be         $ETH_FROM\n\n"
