#! /bin/bash

sed 's/\/\/.*//g' < $1 | tr '\n' ' ' | sed 's/ //g'
