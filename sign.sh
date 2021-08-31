#! /usr/bin/env bash

value=3425
date=1630084111
name=ethusd

val=$(seth --to-uint256 $value)
age=$(echo $date | seth --to-uint256)
wat=$(seth --from-ascii $name | seth --to-bytes32)
data="$val${age/0x/}${wat/0x/}"

echo $data

hash=$(seth keccak $data)

signature=$(seth sign $hash)
r=${signature:0:66}
s="0x${signature:66:64}"
vbin=${signature:130:2}
v=$(seth --to-dec "0x${vbin}")

echo $signature

echo ""
echo ""
echo "[$value] [$date] [$v] [$r] [$s]"
