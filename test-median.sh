#! /bin/bash

contract="${1:-$(cat /dev/stdin)}"

echo ""
echo "poke: bar too low"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh)
echo ""

echo "setBar"
seth send $contract 'setBar(uint256)' 1
echo ""

echo "poke: wrong array length"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' [2] [3] [4] [0x0000000000000000000000000000000000000000000000000000000000000005] [0x0000000000000000000000000000000000000000000000000000000000000006,0x0000000000000000000000000000000000000000000000000000000000000006]
echo ""

echo "poke: invalid oracle"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh)
echo ""

echo "lift"
seth send $contract 'lift(address[])' [$ETH_FROM]
echo ""

echo "poke"
seth send $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh)
echo ""

echo "poke: stale message"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh)
echo ""
