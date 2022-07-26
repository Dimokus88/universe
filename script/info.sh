#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
source $HOME/.bashrc
date
	echo =======================================================================
	echo =============Check if the validator keys are correct! =================
	echo =======================================================================
	echo =======================================================================
	echo =============Проверьте корректность ключей валидатора!=================
	echo =======================================================================
	cat /root/$folder/config/priv_validator_key.json
	sleep 20
	echo =====Ваш адрес =====
	echo ===Your address ====
	(echo ${PASSWALLET}) | $(which $binary) keys show $WALLET_NAME -a
	echo ==========================
	echo =====Your valoper=====
	echo ======Ваш valoper=====
	(echo ${PASSWALLET}) | $(which $binary) keys show $WALLET_NAME  --bech val -a
	echo ===========================
	echo =================================================
	echo ===============WALLET NAME and PASS==============
	echo =================================================
	echo =========== Name ${WALLET_NAME} Имя =============
	echo ========== Pass ${PASSWALLET} Пароль ============
	echo =================================================
	echo =============Имя кошелька и его пароль===========
	echo =================================================
	sleep 10
	tail -30 /var/log/$binary/current
	sleep 10
