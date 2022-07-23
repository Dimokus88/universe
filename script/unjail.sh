#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
jailed=`$binary query staking validator $valoper -o json | jq -r .jailed`
source $HOME/.bash_profile
	while [[  $jailed == true ]] 
	do
		echo ==Внимание! Валидатор в тюрьме, попытка выхода из тюрьмы произойдет через 30 минут==
		echo =Attention! Validator in jail, attempt to get out of jail will happen in 30 minutes=
		sleep 30m
		(echo ${PASSWALLET}) | $binary tx slashing unjail --from $address --chain-id $chain --fees 5000$denom -y
		sleep 10
		jailed=`$binary query staking validator $valoper -o json | jq -r .jailed`
		source $HOME/.bash_profile
	done
