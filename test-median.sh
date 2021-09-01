#! /bin/bash

contract="${1:-$(cat /dev/stdin)}"

echo ""
echo "poke: bar too low"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164])
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164]) &> /dev/stdout | grep "error:\s*data" | sed s/.*0x// | seth --to-ascii
echo ""

echo "setBar"
seth send $contract 'setBar(uint256)' 2
echo ""

echo "poke: wrong array length"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' [2] [3] [4] [0x0000000000000000000000000000000000000000000000000000000000000005] [0x0000000000000000000000000000000000000000000000000000000000000006,0x0000000000000000000000000000000000000000000000000000000000000006]
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' [2] [3] [4] [0x0000000000000000000000000000000000000000000000000000000000000005] [0x0000000000000000000000000000000000000000000000000000000000000006,0x0000000000000000000000000000000000000000000000000000000000000006] &> /dev/stdout | grep "error:\s*data" | sed s/.*0x// | seth --to-ascii
echo ""

echo "poke: invalid oracle"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164])
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164]) &> /dev/stdout | grep "error:\s*data" | sed s/.*0x// | seth --to-ascii
echo ""

echo "lift"
seth send $contract 'lift(address[])' [$ETH_FROM,$ETH_FROM_2]
echo ""

echo "poke: not in order"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3248,3245] [1630513154,1630513164])
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3248,3245] [1630513154,1630513164]) &> /dev/stdout | grep "error:\s*data" | sed s/.*0x// | seth --to-ascii
echo ""

echo "poke: already signed"
export ETH_ACCOUNTS_BACKUP=$ETH_ACCOUNTS
export ETH_ACCOUNTS=$(echo $ETH_ACCOUNTS | tr ' ' '\n' | head -n 1)
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164])
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164]) &> /dev/stdout | grep "error:\s*data" | sed s/.*0x// | seth --to-ascii
export ETH_ACCOUNTS=$ETH_ACCOUNTS_BACKUP
echo ""

echo "poke"
seth send $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164])
echo ""

echo "poke: stale message"
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164])
seth call $contract 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' $(./sign.sh [3245,3248] [1630513154,1630513164]) &> /dev/stdout | grep "error:\s*data" | sed s/.*0x// | seth --to-ascii
echo ""
