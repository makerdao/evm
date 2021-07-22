#! /bin/bash

sed '/^\/\//d' < /dev/stdin | tr '\n' ' ' | sed 's/ //g'
