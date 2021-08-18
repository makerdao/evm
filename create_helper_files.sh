#! /bin/bash

yes '' | head -n $(wc -l "$1" | cut -f 1 -d ' ') > "${1}.stack"; echo '.' >> "${1}.stack"
yes '' | head -n $(wc -l "$1" | cut -f 1 -d ' ') > "${1}.memsto"; echo '.' >> "${1}.memsto"
