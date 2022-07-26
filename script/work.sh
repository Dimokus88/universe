#!/bin/bash
source $HOME/.bashrc
	sleep 5m
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/info.sh | bash
	source $HOME/.bashrc

	#===============СБОР НАГРАД И КОМИССИОННЫХ===================
	
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/reward.sh | bash
	source $HOME/.bashrc

	#============================================================
	
	#+++++++++++++++++++++++++++АВТОДЕЛЕГИРОВАНИЕ++++++++++++++++++++++++
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/autodelegate.sh | bash
	source $HOME/.bashrc

	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	#--------------------------ВЫХОД ИЗ ТЮРЬМЫ--------------------------
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/unjail.sh | bash
	source $HOME/.bashrc

	#-------------------------------------------------------------------
