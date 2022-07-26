#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
#=======Загрузка снепшота блокчейна===
source $HOME/.bashrc
if [[ -n $LINK_SNAPSHOT ]]
then
	cd /root/$folder/
	wget -O snap.tar $LINK_SNAPSHOT
	tar xvf snap.tar 
	rm snap.tar
	echo ===============================================
	echo ===== Snapshot загружен!Snapshot loaded! ======
	echo ===============================================
	cd /
	source $HOME/.bashrc

fi
#====================================

# ====================RPC======================
if [[ -n $SNAP_RPC ]]
then
	if [[ -n $link_rpc ]]
	then
		RPC=`curl -s $link_rpc`
		echo 'export RPC='${RPC} >> $HOME/.bashrc
		source $HOME/.bash_profile
	else
		RPC=`echo $SNAP_RPC,$SNAP_RPC`
		echo 'export RPC='${RPC} >> $HOME/.bashrc
		source $HOME/.bash_profile
	fi
	echo $RPC
	LATEST_HEIGHT=`curl -s $SNAP_RPC/block | jq -r .result.block.header.height`; \
	BLOCK_HEIGHT=$((LATEST_HEIGHT - $SHIFT)); \
	TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
	echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
	sed -i.bak -e "s/LATEST_HEIGHT=/LATEST_HEIGHT=$LATEST_HEIGHT/;" $HOME/.bashrc
	sed -i.bak -e "s/BLOCK_HEIGHT=/BLOCK_HEIGHT=$BLOCK_HEIGHT/;" $HOME/.bashrc
	sed -i.bak -e "s/TRUST_HASH=/TRUST_HASH=$TRUST_HASH/;" $HOME/.bashrc
	sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
	s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC\"| ; \
	s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
	s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$folder/config/config.toml
	echo RPC
	source $HOME/.bashrc

fi
#================================================
