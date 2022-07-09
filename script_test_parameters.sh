#!/bin/bash
alphas=(-1 0 0.5 1)
beta0=(0.5 0.75 1)
beta1=(0.5 0.75 1)
beta2=(0.5 0.75 1)
gamma=(0.003 0.03 0.3)
bs=(64 128 256)

source=1
target=3
aggr=avgpool
if [ $aggr = "avgpool" ];then
  g=0.003
  b=64
else
  g=0.03
  b=128
fi

path='../drive/MyDrive/MLDL_2022/project/parameters_D'$source'-D'$target'_'$aggr'_N_N_Y.txt'

for alpha in "${alphas[@]}"; do
  echo "Alpha: $alpha" >> "$path"
    #for b0 in "${beta0[@]}"; do
      #echo -e "\tBeta0: $b0" >> $path
        #for b1 in "${beta1[@]}"; do
          #echo -e "\t\tBeta1: $b1" >> $path
            for b2 in "${beta2[@]}"; do
              echo -e "\tBeta2: $b2" >> $path
                for g in "${gamma[@]}"; do
                  echo -e "\t\tGamma: $g" >> $path
                    for b in "${bs[@]}"; do
                      echo -e "\t\t\tBatch: $b" >> $path
                      rm -rf model
                      ./script_test_ta3n.sh true true $source $target $aggr 'N N Y'\
                      $alpha -1 -1 $b2 $g $b
                    done
                done
            done
        #done
    #done
done