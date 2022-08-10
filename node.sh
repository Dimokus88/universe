#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/start.sh | bash
curl -s https://raw.githubusercontent.com/Dimokus88/scripts/main/logo.sh | bash
echo 'export my_root_password='${my_root_password}  >> $HOME/.bashrc
echo 'export LINK_KEY='${LINK_KEY}  >> $HOME/.bashrc 
echo 'export MONIKER='${MONIKER} >> $HOME/.bashrc
echo 'export binary='${binary} >> $HOME/.bashrc
echo 'export vers='${vers} >> $HOME/.bashrc
echo 'export genesis='${genesis} >> $HOME/.bashrc
echo 'export folder='${folder} >> $HOME/.bashrc
echo 'export denom='${denom} >> $HOME/.bashrc
echo 'export chain='${chain} >> $HOME/.bashrc
echo 'export gitrep='${gitrep} >> $HOME/.bashrc
echo 'export gitfold='${gitfold} >> $HOME/.bashrc
echo 'export link_peer='${link_peer} >> $HOME/.bashrc
echo 'export PEER='${PEER} >> $HOME/.bashrc
echo 'export link_seed='${link_seed} >> $HOME/.bashrc
echo 'export SEED='${SEED} >> $HOME/.bashrc
echo 'export link_rpc='${link_rpc} >> $HOME/.bashrc
echo 'export SNAP_RPC='${SNAP_RPC} >> $HOME/.bashrc
echo 'export LINK_SNAPSHOT='${LINK_SNAPSHOT} >> $HOME/.bashrc
echo 'export LATEST_HEIGHT='${LATEST_HEIGHT} >> $HOME/.bashrc
echo 'export BLOCK_HEIGHT='${BLOCK_HEIGHT} >> $HOME/.bashrc
echo 'export TRUST_HASH='${TRUST_HASH} >> $HOME/.bashrc
echo 'export SHIFT='${SHIFT} >> $HOME/.bashrc
source $HOME/.bashrc
# ----------УСТАНОВКА GO-----------
ver="1.18.1" 
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 
sleep 5
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" 
rm "go$ver.linux-amd64.tar.gz" 
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bashrc 
source $HOME/.bashrc 
go version
sed -i.bak -e "s~"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"~"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/go/bin:$HOME/go/bin"~;" /etc/sudoers
mkdir -p /root/go/bin/
# ---------------------------------

#-----------КОМПИЛЯЦИЯ БИНАРНОГО ФАЙЛА------------
cd /root/
git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
pwd
whoami
sleep 5
sudo make build
cp $HOME/$gitfold/build/$binary /usr/local/bin/$binary
cp $HOME/go/bin/$binary /usr/local/bin/$binary
$binary version
#-------------------------------------------------

#=======ИНИЦИАЛИЗАЦИЯ БИНАРНОГО ФАЙЛА================
echo =INIT=
rm /root/$folder/config/genesis.json
$binary init "$MONIKER" --chain-id $chain --home /root/$folder
sleep 5
#====================================================

#===========ДОБАВЛЕНИЕ GENESIS.JSON===============
wget -O $HOME/$folder/config/genesis.json $genesis
sha256sum ~/$folder/config/genesis.json
cd && cat $folder/data/priv_validator_state.json
#=================================================

#===========ДОБАВЛЕНИЕ ADDRBOOK.JSON===============
rm $HOME/$folder/config/addrbook.json
wget -O $HOME/$folder/config/addrbook.json $addrbook
#==================================================
#-----ВНОСИМ ИЗМЕНЕНИЯ В CONFIG.TOML , APP.TOML.-----------
if [[ -n $link_peer ]]
then
	PEER=`curl -s $link_peer`
fi

if [[ -n $link_seed ]]
then
	SEED=`curl -s $link_seed`
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

sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/$folder/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/$folder/config/config.toml

snapshot_interval="1000" && \
sed -i.bak -e "s/^snapshot-interval *=.*/snapshot-interval = \"$snapshot_interval\"/" $HOME/$folder/config/app.toml
#-----------------------------------------------------------

#|||||||||||||||||||||||||||||||||||ФУНКЦИЯ Backup||||||||||||||||||||||||||||||||||||||||||||||||||||||
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
fi
#====================================

# ====================RPC======================
if [[ -n $SNAP_RPC ]]
then
	if [[ -n $link_rpc ]]
	then
		RPC=`curl -s $link_rpc`
	else
		RPC=`echo $SNAP_RPC,$SNAP_RPC`
	fi
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
#=========== Установка службы ноды ============
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
LOG=/root/log

cat > /root/$binary/log/run <<EOF 
#!/bin/bash
mkdir $LOG
exec svlogd -tt $LOG
EOF

chmod +x /root/$binary/log/run
ln -s /root/$binary /etc/service
#==================================
echo === Нода запущена ===
sleep 20
for ((;;))
do
curl -s localhost:26657/status | jq 
sleep 10
tail -100 /root/log/current
sleep 10m
done
sleep infinity

