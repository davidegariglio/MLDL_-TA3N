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
if [ $aggr = "avgpool" ];then
  g=0.003
  b=64
else
  g=0.03
  b=128
fi
for alpha in "${alphas[@]}"; do
  echo "Alpha: $alpha" >> ../drive/MyDrive/MLDL_2022/project/parameters_D1-D2_avgpool.txt
    #for b0 in "${beta0[@]}"; do
      #echo -e "\tBeta0: $b0" >> ../drive/MyDrive/MLDL_2022/project/parameters_D1-D2_avgpool.txt
        #for b1 in "${beta1[@]}"; do
          #echo -e "\t\tBeta1: $b1" >> ../drive/MyDrive/MLDL_2022/project/parameters_D1-D2_avgpool.txt
            for b2 in "${beta2[@]}"; do
              echo -e "\tBeta2: $b2" >> ../drive/MyDrive/MLDL_2022/project/parameters_D1-D2_avgpool.txt
                for g in "${gamma[@]}"; do
                  echo -e "\t\tGamma: $g" >> ../drive/MyDrive/MLDL_2022/project/parameters_D1-D2_avgpool.txt
                    for b in "${bs[@]}"; do
                      echo -e "\t\t\tBatch: $b" >> ../drive/MyDrive/MLDL_2022/project/parameters_D1-D2_avgpool.txt
                        rm -rf model
                        ./script_test_ta3n.sh true true $source $target $aggr 'N N Y'\
                        $alpha -1 -1 $b2 $g $b
                    done
                done
            done
        #done
    #done
done