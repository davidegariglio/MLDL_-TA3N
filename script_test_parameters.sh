#!/usr/bin/env bash

alpha=( -1 0 0.5 1 )
B1=( 0.75 1 )
B2=( 0.75 )
B3=( 0.5 )
gamma=( 0.3 0.003 )
Bs=( 64 128 256 )

./script_test_ta3n.sh false true 1 2 avgpool 'Y Y Y' $alpha $B1 $B2 $B3 $gamma $Bs