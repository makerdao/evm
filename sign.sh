#! /usr/bin/env bash

values_string=${1:-[3425,3488]}
dates_string=${2:-[1630084111,1630085739]}
name=${3:-ethusd}

no_brackets=${values_string:1:-1}
values=(${no_brackets//,/ })

no_brackets=${dates_string:1:-1}
dates=(${no_brackets//,/ })

vs="["
rs="["
ss="["

for i in "${!values[@]}"
do
    value="${values[i]}"
    date="${dates[i]}"

    from=$(echo $ETH_ACCOUNTS | tr ' ' '\n' | head -n $((i+1)) | tail -n 1)

    val=$(seth --to-uint256 $value)
    age=$(echo $date | seth --to-uint256)
    wat=$(seth --from-ascii $name | seth --to-bytes32)
    data="$val${age/0x/}${wat/0x/}"

    hash=$(seth keccak $data)

    signature=$(ethsign msg --data $hash --passphrase-file $ETH_PASSWORD --from $from)
    r=${signature:0:66}
    s="0x${signature:66:64}"
    vbin=${signature:130:2}
    v=$(seth --to-dec "0x${vbin}")

    vs+="${v},"
    rs+="${r},"
    ss+="${s},"

done

vs=${vs::-1}
rs=${rs::-1}
ss=${ss::-1}

vs+="]"
rs+="]"
ss+="]"

echo "${values_string} ${dates_string} ${vs} ${rs} ${ss}"
