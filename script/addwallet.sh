#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
source $HOME/.bashrc
(echo "${MNEMONIC}"; echo ${PASSWALLET}; echo ${PASSWALLET}) | $binary keys add ${WALLET_NAME} --recover
address=`(echo ${PASSWALLET}) | $(which $binary) keys show $WALLET_NAME -a`
valoper=`(echo ${PASSWALLET}) | $(which $binary) keys show $WALLET_NAME  --bech val -a`
echo 'export address='${address} >> $HOME/.bashrc
echo 'export valoper='${valoper} >> $HOME/.bashrc
echo =====Ваш адрес =====
echo ===Your address ====
echo $address
echo ==========================
echo =====Your valoper=====
echo ======Ваш valoper=====
echo $valoper
echo ===========================
source $HOME/.bashrc
