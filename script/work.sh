#!/bin/bash
	sleep 5m
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/info.sh | bash
	source /etc/environment

	#===============СБОР НАГРАД И КОМИССИОННЫХ===================
	reward=`$binary query distribution rewards $address $valoper -o json | jq -r .rewards[].amount`
	reward=`printf "%.f \n" $reward`
	echo ==============================
	echo ==Ваши награды: $reward $denom==
	echo ===Your reward $reward $denom===
	echo ==============================
	source /etc/environment

	sleep 5
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/reward.sh | bash
	source /etc/environment

	#============================================================
	
	#+++++++++++++++++++++++++++АВТОДЕЛЕГИРОВАНИЕ++++++++++++++++++++++++
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/autodelegate.sh | bash
	source /etc/environment

	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	#--------------------------ВЫХОД ИЗ ТЮРЬМЫ--------------------------
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/unjail.sh | bash
	source /etc/environment

	#-------------------------------------------------------------------
