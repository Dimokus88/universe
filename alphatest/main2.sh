#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/start.sh | bash
curl -s https://raw.githubusercontent.com/Dimokus88/scripts/main/logo.sh | bash
echo 'export my_root_password='${my_root_password}  >> $HOME/.bashrc
echo 'export MONIKER='${MONIKER} >> $HOME/.bashrc
echo 'export MNEMONIC='${MNEMONIC} >> $HOME/.bashrc
echo 'export LINK_KEY='${LINK_KEY} >> $HOME/.bashrc
echo 'export binary='${binary} >> $HOME/.bashrc
echo 'export vers='${vers} >> $HOME/.bashrc
echo 'export genesis='${genesis} >> $HOME/.bashrc
echo 'export folder='${folder} >> $HOME/.bashrc
echo 'export denom='${denom} >> $HOME/.bashrc
echo 'export chain='${chain} >> $HOME/.bashrc
echo 'export gitrep='${gitrep} >> $HOME/.bashrc
echo 'export gitfold='${gitfold} >> $HOME/.bashrc
echo 'export link_peer='${link_peer} >> $HOME/.bashrc
echo 'export autodelegate='${autodelegate}  >> $HOME/.bashrc
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
echo 'export synh='${synh} >> $HOME/.bashrc
echo 'export PASSWALLET='${PASSWALLET} >> $HOME/.bashrc
echo 'export WALLET_NAME='${WALLET_NAME} >> $HOME/.bashrc
echo 'export validator_node='${validator_node} >> $HOME/.bashrc
source $HOME/.bashrc
echo  часть 1
#======================================================== НАЧАЛО БЛОКА ФУНКЦИЙ ==================================================
#-------------------------- Установка GO и кмопиляция бинарного файла -----------------------
INSTALL (){
# ----------УСТАНОВКА GO-----------
ver="1.18.1" 
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 
sleep 5
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
echo OK
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
wget -O binary.tar.gz $gitrep
file=`tar -tf binary.tar.gz`
tar -xvzf binary.tar.gz
chmod +x $file
ls
mv ./$file /usr/local/bin/$binary
cd /
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
#================================================
# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

}

#--------------------------------------------------------------------------------------------
#*******************ФУНКЦИЯ РАБОЧЕГО РЕЖИМА НОДЫ|*************************
WORK (){
while [[ $synh == false ]]
do
	sleep 5m
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
	#===============СБОР НАГРАД И КОМИССИОННЫХ===================
	reward=`$binary query distribution rewards $address $valoper -o json | jq -r .rewards[].amount`
	reward=`printf "%.f \n" $reward`
	echo ==============================
	echo ==Ваши награды: $reward $denom==
	echo ===Your reward $reward $denom===
	echo ==============================
	source $HOME/.bashrc
	sleep 5
	if [[ `echo $reward` -gt 1000000 ]]
		then
			echo =============================================================
			echo ============Rewards discovered, collecting...================
			echo =============================================================
			echo =============================================================
			echo =============Обнаружены награды, собираю...==================
			echo =============================================================
			(echo ${PASSWALLET}) | $binary tx distribution withdraw-rewards $valoper --from $address --gas="auto" --chain-id $chain --fees 5555$denom --commission -y
			reward=0
			sleep 5
	fi
#============================================================
	
#+++++++++++++++++++++++++++АВТОДЕЛЕГИРОВАНИЕ++++++++++++++++++++++++
	if [[ $autodelegate == yes ]]
	then
		balance=`$binary q bank balances $address -o json | jq -r .balances[].amount `
		balance=`printf "%.f \n" $balance`
		echo =================================================
		echo ===============Balance check...==================
		echo =================================================
		echo =================================================
		echo =============Проверка баланса...=================
		echo =================================================
		echo =========================
		echo ==Ваш баланс: $balance ==
		echo = Your balance $balance =
		echo =========================
		sleep 5
		if [[ `echo $balance` -gt 1000000 ]]
		then
			echo ======================================================================
			echo ============Balance = $balance . Delegate to validator================
			echo ======================================================================
			echo ======================================================================
			echo =============Баланс = $balance . Делегирую валидатору=================
			echo ======================================================================
			stake=$(($balance-500000))
			(echo ${PASSWALLET}) | $binary tx staking delegate $valoper ${stake}`echo $denom` --from $address --chain-id $chain --gas="auto" --fees 5555$denom -y
			sleep 5
			stake=0
			balance=0
		fi
	else	
		echo ===========================================================
		echo =============== auto-delegation disabled ==================
		echo ===============автоделегирование отключено=================
		echo ===========================================================
	fi
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
#--------------------------ВЫХОД ИЗ ТЮРЬМЫ--------------------------
	jailed=`$binary query staking validator $valoper -o json | jq -r .jailed`
	while [[  $jailed == true ]] 
	do
		echo ==Внимание! Валидатор в тюрьме, попытка выхода из тюрьмы произойдет через 30 минут==
		echo =Attention! Validator in jail, attempt to get out of jail will happen in 30 minutes=
		sleep 30m
		(echo ${PASSWALLET}) | $binary tx slashing unjail --from $address --chain-id $chain --fees 5000$denom -y
		sleep 10
		jailed=`$binary query staking validator $valoper -o json | jq -r .jailed`
		
	done
#-------------------------------------------------------------------
done
}
#*************************************************************************

#======================================================== КОНЕЦ БЛОКА ФУНКЦИЙ ====================================================


if [[ $validator_node == yes ]] 
then
    INSTALL
    PASSWALLET=q542we221
    WALLET_NAME=My_wallet
    echo ${PASSWALLET}
    echo ${WALLET_NAME}
    sleep 2
#===========ДОБАВЛЕНИЕ КОШЕЛЬКА============
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
#=========================================
    
# ------ПРОВЕРКА НАЛИЧИЯ priv_validator_key--------
    wget -O /var/www/html/priv_validator_key.json ${LINK_KEY}
    file=/var/www/html/priv_validator_key.json
    if  [[ -f "$file" ]]
    then
        cd /
	      rm /root/$folder/config/priv_validator_key.json
	      echo ==========priv_validator_key found==========
	      echo ========Обнаружен priv_validator_key========
	      cp /var/www/html/priv_validator_key.json /root/$folder/config/
	      echo ========Validate the priv_validator_key.json file=========
	      echo ==========Сверьте файл priv_validator_key.json============
	      cat /root/$folder/config/priv_validator_key.json
    else
      	echo =====================================================================
	      echo =========== priv_validator_key not found, making a backup ===========
	      echo =====================================================================
	      echo =====================================================================
	      echo ====== priv_validator_key не обнаружен, создаю резервную копию ======
	      echo =====================================================================
	      sleep 2
	      cp /root/$folder/config/priv_validator_key.json /var/www/html/
	      echo =========================================================================================
	      echo = priv_validator_key has been created! Save the output to a .json file on google drive. =
	      echo == Place a direct link to download the file in the manifest and update the deployment! ==
	      echo ==================================Work has been suspended!===============================
	      echo =========================================================================================
	      echo = priv_validator_key создан! Сохраните вывод в файл с расширением .json на google диск. =
	      echo ==== Разместите прямую ссылку на скачивание файла в манифесте и обновите деплоймент! ====
	      echo ====================================Работа приостановлена!===============================
	      cat /root/$folder/config/priv_validator_key.json
	      sleep infinity
    fi
# -----------------------------------------------------------
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
    sleep 20
    synh=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
    echo $synh
    sed -i.bak -e "s/synh=/synh=$synh/;" $HOME/.bashrc
    tail -30 /var/log/$binary/current
    sleep 2
#==================================

#=========Пока нода не синхронизирована - повторять===========
  while [[ $synh == true ]]
  do
  	source $HOME/.bashrc
  	echo ==============================================
	  echo =Нода не синхронизирована! Node is not sync! =
	  echo ==============================================
	  tail -30 /var/log/$binary/current
	  sleep 5m
	  echo =====Ваш адрес =====
	  echo ===Your address ====
	  (echo ${PASSWALLET}) | $(which $binary) keys show $WALLET_NAME -a
	  echo ==========================
	  echo =====Your valoper=====
	  echo ======Ваш valoper=====
	  (echo ${PASSWALLET}) | $(which $binary) keys show $WALLET_NAME  --bech val -a
	  echo ===========================
	  date
	  curl -s localhost:26657/status
	  synh=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
	  if [[ $synh == false ]]
	  then
	  sed -i.bak -e "s/synh=true/synh=$synh/;" $HOME/.bashrc
	  fi		
	  echo $synh
  done

#=======Если нода синхронизирована - начинаем работу ==========
  while	[[ $synh == false ]]
  do 	
	
      	sleep 10
      	date
	      echo ================================================================
	      echo =Нода синхронизирована успешно! Node synchronized successfully!=
	      echo ================================================================
	     val=`$binary query staking validator $valoper -o json | jq -r .description.moniker`
	     echo $val
	     sed -i.bak -e "s/val=/val=$val/;" $HOME/.bashrc
	
	  if [[ -z "$val" ]]
	  then		
	  	  echo =Создание валидатора... Creating a validator...=
	  	  (echo ${PASSWALLET}) | $binary tx staking create-validator --amount="850000$denom" --pubkey=$($binary tendermint show-validator) --moniker="$MONIKER"	--chain-id="$chain" --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="800000" --gas="auto"	--from="$address" --fees="5550$denom" -y
	  	  sleep 20
	  	  val=`$binary query staking validator $valoper -o json | jq -r .description.moniker`
	  	  echo $val
	  	  sed -i.bak -e "s/val=/val=$val/;" $HOME/.bashrc		
	  else		
		    val=`$binary query staking validator $valoper -o json | jq -r .description.moniker`
		    echo $val
		    MONIKER=`echo $val`
		    WORK		
  	fi
	  source $HOME/.bashrc
  done
else
echo  часть 2
    INSTALL
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
    	for ((;;))
    	do
      		 sleep 10m
     		  tail -100 /var/log/$binary/current
  	  done
fi
