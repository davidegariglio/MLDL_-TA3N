#!/bin/bash
alphas=(-1 0 0.5 1)
beta0=(0.5 0.75 1)
beta1=(0.5 0.75 1)
beta2=(0.5 0.75 1)
gamma=(0.003 0.03 0.3)
bs=(64 128 256)

source=1
target=2
aggr=avgpool
for alpha in "${alphas[@]}"; do
    for b0 in "${beta0[@]}"; do
        for b1 in "${beta1[@]}"; do
            for b2 in "${beta2[@]}"; do
                for g in "${gamma[@]}"; do
                    for b in "${bs[@]}"; do
                        # echo $alpha
                        ./script_test_ta3n.sh true true $source $target $aggr 'N N Y'\
                        $alpha $b0 $b1 $b2 $g $b
                    done
                done
            done
        done
    done
done