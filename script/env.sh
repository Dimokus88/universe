#!/bin/bash
#By Dimokus (https://t.me/Dimokus)
echo 'export my_root_password='${my_root_password}  >> ~/.profile
echo 'export MONIKER='${MONIKER} >> ~/.profile
echo 'export MNEMONIC='${MNEMONIC} >> ~/.profile
echo 'export LINK_KEY='${LINK_KEY} >> ~/.profile
echo 'export binary='${binary} >> ~/.profile
echo 'export vers='${vers} >> ~/.profile
echo 'export genesis='${genesis} >> ~/.profile
echo 'export folder='${folder} >> ~/.profile
echo 'export denom='${denom} >> ~/.profile
echo 'export chain='${chain} >> ~/.profile
echo 'export gitrep='${gitrep} >> ~/.profile
echo 'export gitfold='${gitfold} >> ~/.profile
echo 'export link_peer='${link_peer} >> ~/.profile
echo 'export PEER='${PEER} >> ~/.profile
echo 'export link_seed='${link_seed} >> ~/.profile
echo 'export SEED='${SEED} >> ~/.profile
echo 'export link_rpc='${link_rpc} >> ~/.profile
echo 'export SNAP_RPC='${SNAP_RPC} >> ~/.profile
echo 'export LINK_SNAPSHOT='${LINK_SNAPSHOT} >> ~/.profile
echo 'export LATEST_HEIGHT='${LATEST_HEIGHT} >> ~/.profile
echo 'export BLOCK_HEIGHT='${BLOCK_HEIGHT} >> ~/.profile
echo 'export TRUST_HASH='${TRUST_HASH} >> ~/.profile
echo 'export SHIFT='${SHIFT} >> ~/.profile
echo 'export address='${address} >> ~/.profile
echo 'export valoper='${valoper} >> ~/.profile
echo 'export synh='${synh} >> ~/.profile
echo 'export val='${val} >> ~/.profile
echo 'export balance='${balance} >> ~/.profile
echo 'export PASSWALLET='${PASSWALLET} >> ~/.profile
echo 'export WALLET_NAME='${WALLET_NAME} >> ~/.profile
echo 'export file='${file} >> ~/.profile
echo 'export stake='${stake} >> ~/.profile
echo 'export reward='${reward} >> ~/.profile
echo 'export jailed='${jailed} >> ~/.profile
source ~/.profile
