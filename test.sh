#! /bin/bash

contract=$(cat /dev/stdin)

seth send $contract
printf "^^^^^^^^^^ should fail ^^^^^^^^^^\n\n"

seth call $contract 'balanceOf(address)' $ETH_FROM
printf "^^^^^^^^^^ should be 0 ^^^^^^^^^^\n\n"

seth call $contract 'balanceOf(address)' 0x123
printf "^^^^^^^^^^ should be 0 ^^^^^^^^^^\n\n"

seth send $contract 'transfer(address,uint256)' 0x123 0xa
printf "^^^^^^^^^^ should fail ^^^^^^^^^^\n\n"

seth send $contract 'mint(address,uint256)' $ETH_FROM 0xdada
printf "^^^^^^^^^^ should succeed ^^^^^^^^^^\n\n"

seth call $contract 'balanceOf(address)' $ETH_FROM
printf "^^^^^^^^^^ should be 0xdada ^^^^^^^^^^\n\n"

seth send $contract 'transfer(address,uint256)' 0x123 0xa
printf "^^^^^^^^^^ should succeed ^^^^^^^^^^\n\n"

seth call $contract 'balanceOf(address)' 0x123
printf "^^^^^^^^^^ should be 0xa ^^^^^^^^^^\n\n"

seth call $contract 'balanceOf(address)' $ETH_FROM
printf "^^^^^^^^^^ should be 0xdad0 ^^^^^^^^^^\n\n"
