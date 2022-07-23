#!/bin/bash
	sleep 5m
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/info.sh | bash
	source $HOME/.bash_profile

	#===============СБОР НАГРАД И КОМИССИОННЫХ===================
	reward=`$binary query distribution rewards $address $valoper -o json | jq -r .rewards[].amount`
	reward=`printf "%.f \n" $reward`
	echo ==============================
	echo ==Ваши награды: $reward $denom==
	echo ===Your reward $reward $denom===
	echo ==============================
	source $HOME/.bash_profile
	sleep 5
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/reward.sh | bash
	source $HOME/.bash_profile

	#============================================================
	
	#+++++++++++++++++++++++++++АВТОДЕЛЕГИРОВАНИЕ++++++++++++++++++++++++
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/autodelegate.sh | bash
	source $HOME/.bash_profile

	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	#--------------------------ВЫХОД ИЗ ТЮРЬМЫ--------------------------
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/unjail.sh | bash
	source $HOME/.bash_profile

	#-------------------------------------------------------------------
