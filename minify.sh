#! /bin/bash

sed 's/#.*//g' < /dev/stdin | tr '\n' ' ' | sed 's/ //g'
