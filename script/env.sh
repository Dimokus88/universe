#!/bin/bash
#By Dimokus (https://t.me/Dimokus)
echo 'export my_root_password='${my_root_password}  >> /etc/environment
echo 'export MONIKER='${MONIKER} >> /etc/environment
echo 'export MNEMONIC='${MNEMONIC} >> /etc/environment
echo 'export LINK_KEY='${LINK_KEY} >> /etc/environment
echo 'export binary='${binary} >> /etc/environment
echo 'export vers='${vers} >> /etc/environment
echo 'export genesis='${genesis} >> /etc/environment
echo 'export folder='${folder} >> /etc/environment
echo 'export denom='${denom} >> /etc/environment
echo 'export chain='${chain} >> /etc/environment
echo 'export gitrep='${gitrep} >> /etc/environment
echo 'export gitfold='${gitfold} >> /etc/environment
echo 'export link_peer='${link_peer} >> /etc/environment
echo 'export PEER='${PEER} >> /etc/environment
echo 'export link_seed='${link_seed} >> /etc/environment
echo 'export SEED='${SEED} >> /etc/environment
echo 'export link_rpc='${link_rpc} >> /etc/environment
echo 'export SNAP_RPC='${SNAP_RPC} >> /etc/environment
echo 'export LINK_SNAPSHOT='${LINK_SNAPSHOT} >> /etc/environment
echo 'export LATEST_HEIGHT='${LATEST_HEIGHT} >> /etc/environment
echo 'export BLOCK_HEIGHT='${BLOCK_HEIGHT} >> /etc/environment
echo 'export TRUST_HASH='${TRUST_HASH} >> /etc/environment
echo 'export SHIFT='${SHIFT} >> /etc/environment
echo 'export address='${address} >> /etc/environment
echo 'export valoper='${valoper} >> /etc/environment
echo 'export synh='${synh} >> /etc/environment
echo 'export val='${val} >> /etc/environment
echo 'export balance='${balance} >> /etc/environment
echo 'export PASSWALLET='${PASSWALLET} >> /etc/environment
echo 'export WALLET_NAME='${WALLET_NAME} >> /etc/environment
echo 'export file='${file} >> /etc/environment
echo 'export stake='${stake} >> /etc/environment
echo 'export reward='${reward} >> /etc/environment
echo 'export jailed='${jailed} >> /etc/environment
source /etc/environment
