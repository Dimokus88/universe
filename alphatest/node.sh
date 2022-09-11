#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
(echo ${my_root_password}; echo ${my_root_password}) | passwd root && service ssh restart
sleep 5
runsvdir -P /etc/service &
if [[ -n $SNAP_RPC ]]
then 
chain=`curl -s "$SNAP_RPC"/genesis | jq -r .result.genesis.chain_id`
denom=`curl -s "$SNAP_RPC"/genesis | jq -r .result.genesis.app_state.bank.params.send_enabled[0].denom`
folder=`curl -s "$SNAP_RPC"/abci_info | jq -r .result.response.data`
binary=`echo "$folder"d`
folder=`echo $folder | sed "s/$folder/.$folder/"`
vers=`curl -s "$SNAP_RPC"/abci_info | jq -r .result.response.version`
fi

echo $chain
echo $denom
echo $folder
echo $binary
echo $vers
sleep 10
echo 'export MONIKER='${MONIKER} >> $HOME/.bashrc
echo 'export binary='${binary} >> $HOME/.bashrc
echo 'export denom='${denom} >> $HOME/.bashrc
echo 'export chain='${chain} >> $HOME/.bashrc
source $HOME/.bashrc
#======================================================== НАЧАЛО БЛОКА ФУНКЦИЙ ==================================================
#-------------------------- Установка GO и кмопиляция бинарного файла -----------------------
INSTALL (){
#-----------КОМПИЛЯЦИЯ БИНАРНОГО ФАЙЛА------------
cd /root/
git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
sudo make build
sudo make install
cp $HOME/$gitfold/build/$binary /usr/bin/$binary
cp $HOME/go/bin/$binary /usr/bin/$binary
$binary version
#-------------------------------------------------

#=======ИНИЦИАЛИЗАЦИЯ БИНАРНОГО ФАЙЛА================
echo =INIT=
rm /root/$folder/config/genesis.json
$binary init "$MONIKER" --chain-id $chain --home /root/$folder
sleep 5
$binary config chain-id $chain
$binary config keyring-backend os
#====================================================

#===========ДОБАВЛЕНИЕ GENESIS.JSON===============
if [[ -n $SNAP_RPC ]]
then 
rm /root/$folder/config/genesis.json
curl -s "$SNAP_RPC"/genesis | jq .result.genesis >> $HOME/$folder/config/genesis.json
else
rm /root/$folder/config/genesis.json
wget -O $HOME/$folder/config/genesis.json $genesis
sha256sum ~/$folder/config/genesis.json
cd && cat $folder/data/priv_validator_state.json
fi
#=================================================

#-----ВНОСИМ ИЗМЕНЕНИЯ В CONFIG.TOML , APP.TOML.-----------

if [[ -n $SNAP_RPC ]]
then
n_peers=`curl -s $SNAP_RPC/net_info? | jq -r .result.n_peers`
let n_peers="$n_peers"-1
RPC="$SNAP_RPC"
echo -n "$RPC," >> /root/RPC.txt
p=0
count=0
echo "Search peers..."
while [[ "$p" -le  "$n_peers" ]] && [[ "$count" -le  10 ]]
do
	PEER=`curl -s  $SNAP_RPC/net_info? | jq -r .result.peers["$p"].node_info.listen_addr`
        if [[ ! "$PEER" =~ "tcp" ]] 
        then
			id=`curl -s  $SNAP_RPC/net_info? | jq -r .result.peers["$p"].node_info.id`
            		echo -n "$id@$PEER," >> /root/PEER.txt
			echo $id@$PEER
			rm /root/addr.tmp
			echo $PEER | sed 's/:/ /g' > /root/addr.tmp
			ADDRESS=(`cat /root/addr.tmp`)
			ADDRESS=`echo ${ADDRESS[0]}`
			PORT=(`cat /root/addr.tmp`)
			PORT=`echo ${PORT[1]}`
			let PORT=$PORT+1
			RPC=`echo $ADDRESS:$PORT`
			let count="$count"+1
			if [[ `curl -s http://$RPC/abci_info? --connect-timeout 5 | jq -r .result.response.last_block_height` -gt 0 ]]
			then
				echo "$RPC"
				echo -n "$RPC," >> /root/RPC.txt
				RPC=0
			fi
			RPC=0
   	     fi
	p="$p"+1
	done
echo "Search peers is complete!"
PEER=`cat /root/PEER.txt | sed 's/,$//'`
RPC=`cat /root/RPC.txt | sed 's/,$//'`
else
	if [[ -n $link_peer ]]
	then
		PEER=`curl -s $link_peer`
	fi

	if [[ -n $link_seed ]]
	then
		SEED=`curl -s $link_seed`
	fi
fi
echo $PEER
echo $SEED
sleep 5
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$denom\"/;" $HOME/$folder/config/app.toml
sleep 1
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEED\"/;" $HOME/$folder/config/config.toml
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEER\"/;" $HOME/$folder/config/config.toml
sed -i.bak -e "s_"tcp://127.0.0.1:26657"_"tcp://0.0.0.0:26657"_;" $HOME/$folder/config/config.toml
pruning="custom" && \
pruning_keep_recent="5" && \
pruning_keep_every="1000" && \
pruning_interval="50" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$folder/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$folder/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$folder/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$folder/config/app.toml
snapshot_interval="1000" && \
sed -i.bak -e "s/^snapshot-interval *=.*/snapshot-interval = \"$snapshot_interval\"/" $HOME/$folder/config/app.toml
#-----------------------------------------------------------

#|||||||||||||||||||||||||||||||||||ФУНКЦИЯ Backup||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ====================RPC======================
if [[ -n $SNAP_RPC ]]
then
	RPC=`echo $SNAP_RPC,$RPC`
	echo $RPC
	LATEST_HEIGHT=`curl -s $SNAP_RPC/block | jq -r .result.block.header.height`; \
	BLOCK_HEIGHT=$((LATEST_HEIGHT - $SHIFT)); \
	TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
	echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
	sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
	s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC\"| ; \
	s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
	s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$folder/config/config.toml
	echo RPC
fi
#================================================
# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
wget -O /tmp/priv_validator_key.json ${LINK_KEY}
file=/tmp/priv_validator_key.json
if  [[ -f "$file" ]]
then
	      sleep 2
	      cd /
	      rm /root/$folder/config/priv_validator_key.json
	      echo ==========priv_validator_key found==========
	      echo ========Обнаружен priv_validator_key========
	      cp /tmp/priv_validator_key.json /root/$folder/config/
	      echo ========Validate the priv_validator_key.json file=========
	      echo ==========Сверьте файл priv_validator_key.json============
	      cat /tmp/priv_validator_key.json
	      sleep 10
    else     	
    	echo "==================================================================================="
	echo "======== priv_validator_key not found! Specify direct download link ==============="
	echo "===== of the validator key file in the LINK_KEY variable in your deploy.yml ======="
	echo "===== If you don't have a key file, use the instructions at the link below ======="
	echo "== https://github.com/Dimokus88/guides/blob/main/Cosmos%20SDK/valkey/README.md ===="
	echo "==================================================================================="
	echo "========  priv_validator_key ненайден! Укажите ссылку напрямое скачивание  ========"
	echo "========  файла ключа валидатора в переменной LINK_KEY в вашем deploy.yml  ========"
	echo "=====  Если у вас нет файла ключа, воспользуйтесь инструкцией по ссылке ниже ====="
	echo "== https://github.com/Dimokus88/guides/blob/main/Cosmos%20SDK/valkey/README.md ===="
	echo "==================================================================================="
	echo "============= The node is running with the generated validator key! ==============="
	echo "==================================================================================="
	echo "================= Нода запущена с сгенерированным ключом валидатора! =============="
	echo "==================================================================================="
	RUN
	sleep infinity 	
    fi
}

RUN (){
#===========ЗАПУСК НОДЫ============
echo =Run node...=
cd /
mkdir /root/$binary
mkdir /root/$binary/log
    
cat > /root/$binary/run <<EOF 
#!/bin/bash
exec 2>&1
exec $binary start
EOF
chmod +x /root/$binary/run
LOG=/var/log/$binary

cat > /root/$binary/log/run <<EOF 
#!/bin/bash
mkdir $LOG
exec svlogd -tt $LOG
EOF
chmod +x /root/$binary/log/run
ln -s /root/$binary /etc/service
}
#--------------------------------------------------------------------------------------------
#======================================================== КОНЕЦ БЛОКА ФУНКЦИЙ ====================================================
INSTALL
sleep 15
RUN
sleep 1m
# -----------------------------------------------------------
for ((;;))
  do    
    tail -100 /var/log/$binary/current | grep -iv peer
    sleep 10m
  done
fi
