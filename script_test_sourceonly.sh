#!/bin/bash

#====== parameters ======#
dataset="epic" # hmdb_ucf | hmdb_ucf_small | ucf_olympic
num_class='8,8' # formato: verb, noun (noi abbiamo teoricamente 8,0)
training=$1 # true | false
testing=$2 # true | false
modality=RGB
frame_type=feature # frame | feature
num_segments=5 # sample frame # of each video for training
test_segments=5
val_segments=5
baseline_type=video
frame_aggregation=$5 # method to integrate the frame-level features (avgpool | trn | trn-m | rnn | temconv)
add_fc=1
fc_dim=512
arch=TBN # resnet50
use_target=none #uSv # Sv # uSv # none | Sv | uSv
share_params=Y # Y | N
pred_normalize="N"
weighted_class_loss_DA="N"
weighted_class_loss="N"

if [ "$use_target" = "none" ] 
then
	exp_DA_name=baseline
else
	exp_DA_name=DA
fi

#====== select dataset ======#
path_data_root="/content/drive/MyDrive/MLDL_2022/project/EGO_Project_correct/Pre-extracted_feat/RGB/ek_tsm" # depend on users
path_labels_root="/content/drive/MyDrive/MLDL_2022/project/pkl_files" #"/jmain01/home/JAD026/dxd01/jjm50-dxd01/DA_Features/train_test/train/" # depend on users
path_exp_root="model/action-model/" # depend on users
train_metric="verb"
if [ "$dataset" = "epic" ]
then
	# dataset_source="source_train" # Dx-Dx.train
	# dataset_target="target_train" # depend on users
	# dataset_val="target_test" # _noun" # depend on users
	num_source=16115 # number of training data (source)
	num_target=26115 # number of training data (target)

  source=$3
  target=$4

	path_data_source=$path_data_root'/D'$source'-D'$source'_train'
	path_data_target=$path_data_root'/D'$target'-D'$target'_train'
	path_data_val=$path_data_root'/D'$source'-D'$target'_test' #missing _test

	train_source_list=$path_labels_root'/D'$source'_train.pkl' # '/domain_adaptation_source_train_pre-release_v3.pkl'
	train_target_list=$path_labels_root'/D'$target'_train.pkl' # '/domain_adaptation_target_train_pre-release_v6.pkl'
	val_list=$path_labels_root'/D'$target'_test.pkl' # '/domain_adaptation_target_test_pre-release_v3.pkl' # 'domain_adaptation_validation_pre-release_v3.pkl'

	path_exp=$path_exp_root'Testexp'

fi

pretrained=none

#====== parameters for algorithms ======#
# parameters for DA approaches
dis_DA=none # none | DAN | JAN
alpha=0 # depend on users

adv_pos_0=Y # Y | N (discriminator for relation features)
adv_DA=RevGrad # none | RevGrad
beta_0=0.75 # 0.75 #0.75 # U->H: 0.75 | H->U: 1
beta_1=0.75 #0.75 # U->H: 0.75 | H->U: 0.75
beta_2=0.5 #0.5 # U->H: 0.5 | H->U: 0.5

use_attn=TransAttn # none | TransAttn | general
n_attn=1
use_attn_frame=none # none | TransAttn | general

use_bn=none # none | AdaBN | AutoDIAL
add_loss_DA=attentive_entropy # none | target_entropy | attentive_entropy
gamma=0.003 # U->H: 0.003 | H->U: 0.3

ens_DA=none # none | MCD
mu=0

# parameters for architectures
bS=64 # batch size
bS_2=$((bS * num_target / num_source ))

echo '('$bS', '$bS_2')'

lr=3e-3
optimizer=SGD

if [ "$use_target" = "none" ] 
then
	dis_DA=none
	alpha=0
	adv_pos_0=N
	adv_DA=none
	beta_0=0
	beta_1=0
	beta_2=0
	use_attn=none
	use_attn_frame=none
	use_bn=none
	add_loss_DA=none
	gamma=0
	ens_DA=none
	mu=0
	j=0

	exp_path=$path_exp'-'$optimizer'-share_params_'$share_params'/'$dataset'-'$num_segments'seg_'$j'/'
else
	exp_path=$path_exp'-'$optimizer'-share_params_'$share_params'-lr_'$lr'-bS_'$bS'_'$bS_2'/'$dataset'-'$num_segments'seg-disDA_'$dis_DA'-alpha_'$alpha'-advDA_'$adv_DA'-beta_'$beta_0'_'$beta_1'_'$beta_2'-useBN_'$use_bn'-addlossDA_'$add_loss_DA'-gamma_'$gamma'-ensDA_'$ens_DA'-mu_'$mu'-useAttn_'$use_attn'-n_attn_'$n_attn'/'
fi

#====== select mode ======#
if ($training) 
then
	
	val_segments=$test_segments

	# parameters for optimization
	lr_decay=10
    	lr_adaptive=none # dann # none | loss | dann
    	lr_steps_1=10
    	lr_steps_2=20
    	epochs=30
	gd=20
	
	#------ main command ------#

	python main.py $num_class $modality $train_source_list $train_target_list $val_list $path_data_val $path_data_source $path_data_target --exp_path $exp_path \
	--train_metric $train_metric --dann_warmup --arch $arch --pretrained $pretrained --baseline_type $baseline_type --frame_aggregation $frame_aggregation \
	--num_segments $num_segments --val_segments $val_segments --add_fc $add_fc --fc_dim $fc_dim --dropout_i 0.5 --dropout_v 0.5 \
	--use_target $use_target --share_params $share_params \
	--dis_DA $dis_DA --alpha $alpha --place_dis N N N \
	--adv_DA $adv_DA --beta $beta_0 $beta_1 $beta_2 --place_adv N N N \
	--use_bn $use_bn --add_loss_DA $add_loss_DA --gamma $gamma \
	--ens_DA $ens_DA --mu $mu \
	--use_attn $use_attn --n_attn $n_attn --use_attn_frame $use_attn_frame \
	--pred_normalize $pred_normalize --weighted_class_loss_DA $weighted_class_loss_DA --weighted_class_loss $weighted_class_loss \
	--gd $gd --lr $lr --lr_decay $lr_decay --lr_adaptive $lr_adaptive --lr_steps $lr_steps_1 $lr_steps_2 --epochs $epochs --optimizer $optimizer \
	--n_rnn 1 --rnn_cell LSTM --n_directions 1 --n_ts 5 --tensorboard \
	-b $bS $bS_2 $bS -j 4 -ef 1 -pf 50 -sf 50 --copy_list N N --save_model --eval_freq 5 \

fi

if ($testing)
then
	model=checkpoint # checkpoint | model_best
	#echo $model

	# testing on the validation set
	echo 'testing on the test set'
  echo 'source: '$source',target: '$target',aggregation: '$frame_aggregation
	python test_models.py $num_class $modality $val_list \
	 $exp_path$modality'/'$model'.pth.tar' $path_data_val 'test.json'\
	--arch $arch --test_segments $test_segments \
	--save_scores $exp_path$modality'/scores_'$dataset_target'-'$model'-'$test_segments'seg' --save_confusion $exp_path$modality'/confusion_matrix_'$dataset_target'-'$model'-'$test_segments'seg' \
	--n_rnn 1 --rnn_cell LSTM --n_directions 1 --n_ts 5 \
	--use_attn $use_attn --n_attn $n_attn --use_attn_frame $use_attn_frame --use_bn $use_bn --share_params $share_params \
	-j 4 --bS 512 --top 1 3 5 --add_fc 1 --fc_dim $fc_dim --baseline_type $baseline_type --frame_aggregation $frame_aggregation

fi

# ----------------------------------------------------------------------------------
exit 0
