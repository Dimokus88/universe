#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
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
		source ~/.profile

	fi
