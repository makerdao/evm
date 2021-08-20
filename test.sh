#! /bin/bash

contract="${1:-$(cat /dev/stdin)}"

printf "\n\nstarting tests\n\n"

echo "fallback function"
seth send $contract
printf "^^^^^^^^^^ should fail ^^^^^^^^^^\n\n"

hash=$(seth keccak 0x000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000001686f6c6100000000000000000000000000000000000000000000000000000000)

signature=$(ethsign msg --data $hash --passphrase-file ~/.dapp/password)

r="${signature:0:66}"
s="0x${signature:66:64}"
v="0x${signature:130}"

echo "poke"
seth call $contract 'poke(uint8,bytes32,bytes32,uint256[],uint256[],bytes32[])' $v $r $s [2,8] [3] [0x686f6c6100000000000000000000000000000000000000000000000000000000]
printf "^^^^^ should revert with                              $ETH_FROM ^^^^^\n\n"

echo "lift"
seth send $contract 'lift(address)' $ETH_FROM
printf "^^^^ should succeed ^^^^^^\n\n"

echo "poke"
seth call $contract 'poke(uint8,bytes32,bytes32,uint256[],uint256[],bytes32[])' $v $r $s [2,8] [3] [0x686f6c6100000000000000000000000000000000000000000000000000000000]
printf "^^^^^ should be         $ETH_FROM\n\n"
