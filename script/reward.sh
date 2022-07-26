#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
source $HOME/.bashrc
reward=`$binary query distribution rewards $address $valoper -o json | jq -r .rewards[].amount`
reward=`printf "%.f \n" $reward`
echo ==============================
echo ==Ваши награды: $reward $denom==
echo ===Your reward $reward $denom===
echo ==============================
source $HOME/.bashrc
sleep 5
if [[ `echo $reward` -gt 1000000 ]]
	then
		echo =============================================================
		echo ============Rewards discovered, collecting...================
		echo =============================================================
		echo =============================================================
		echo =============Обнаружены награды, собираю...==================
		echo =============================================================
		(echo ${PASSWALLET}) | $binary tx distribution withdraw-rewards $valoper --from $address --gas="auto" --fees 5555$denom --commission -y
		reward=0
		sleep 5
		source $HOME/.bashrc

	fi
