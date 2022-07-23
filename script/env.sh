#!/bin/bash
#By Dimokus (https://t.me/Dimokus)
echo 'export my_root_password='${my_root_password}  >> $HOME/.bash_profile
echo 'export MONIKER='${MONIKER} >> $HOME/.bash_profile
echo 'export MNEMONIC='${MNEMONIC} >> $HOME/.bash_profile
echo 'export LINK_KEY='${LINK_KEY} >> $HOME/.bash_profile
echo 'export binary='${binary} >> $HOME/.bash_profile
echo 'export vers='${vers} >> $HOME/.bash_profile
echo 'export genesis='${genesis} >> $HOME/.bash_profile
echo 'export folder='${folder} >> $HOME/.bash_profile
echo 'export denom='${denom} >> $HOME/.bash_profile
echo 'export chain='${chain} >> $HOME/.bash_profile
echo 'export gitrep='${gitrep} >> $HOME/.bash_profile
echo 'export gitfold='${gitfold} >> $HOME/.bash_profile
echo 'export link_peer='${link_peer} >> $HOME/.bash_profile
echo 'export PEER='${PEER} >> $HOME/.bash_profile
echo 'export link_seed='${link_seed} >> $HOME/.bash_profile
echo 'export SEED='${SEED} >> $HOME/.bash_profile
echo 'export link_rpc='${link_rpc} >> $HOME/.bash_profile
echo 'export SNAP_RPC='${SNAP_RPC} >> $HOME/.bash_profile
echo 'export LINK_SNAPSHOT='${LINK_SNAPSHOT} >> $HOME/.bash_profile
echo 'export LATEST_HEIGHT='${LATEST_HEIGHT} >> $HOME/.bash_profile
echo 'export BLOCK_HEIGHT='${BLOCK_HEIGHT} >> $HOME/.bash_profile
echo 'export TRUST_HASH='${TRUST_HASH} >> $HOME/.bash_profile
echo 'export SHIFT='${SHIFT} >> $HOME/.bash_profile
echo 'export address='${address} >> $HOME/.bash_profile
echo 'export valoper='${valoper} >> $HOME/.bash_profile
echo 'export synh='${synh} >> $HOME/.bash_profile
echo 'export val='${val} >> $HOME/.bash_profile
echo 'export balance='${balance} >> $HOME/.bash_profile
echo 'export PASSWALLET='${PASSWALLET} >> $HOME/.bash_profile
echo 'export WALLET_NAME='${WALLET_NAME} >> $HOME/.bash_profile
echo 'export file='${file} >> $HOME/.bash_profile
echo 'export stake='${stake} >> $HOME/.bash_profile
echo 'export reward='${reward} >> $HOME/.bash_profile
echo 'export jailed='${jailed} >> $HOME/.bash_profile
source $HOME/.bash_profile
