#!/bin/bash
# ===========================================
# = Decloud Nodes Lab. 2023.                =
# = Discord: https://discord.gg/rPENzerwZ8  =
# = Telegram channel: https://t.me/NodesLab =
# = Site: https://declab.pro                =
# ===========================================

if [[ -n $GO_VERSION ]] ; then  wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz &&\
                                tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz &&\
						        rm ./go$GO_VERSION.linux-amd64.tar.gz ; 
						  fi

if [[ -n $LIBWASMVM_VERSION ]] ; then  wget -P /usr/lib/ https://github.com/CosmWasm/wasmvm/releases/download/$LIBWASMVM_VERSION/libwasmvm.x86_64.so ; fi

if [[ -n $SSH_PASS ]] ; then  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config &&\
					  (echo ${SSH_PASS}; echo ${SSH_PASS}) | passwd root &&\
					  service ssh restart ; fi
						
if [[ -n $SSH_KEY ]] ; then  echo $SSH_KEY > /root/.ssh/authorized_keys &&\
					 chmod 0600 /root/.ssh/authorized_keys &&\
					 service ssh restart ; fi

# Часть 2 Переменные
if [[ -n $RPC ]] || [[ -z $CHAIN ]]
then  
	CHAIN=`curl -s $RPC/status | jq -r .result.node_info.network` &&\
	if [[ -z $BINARY_VERSION ]] ; then  BINARY_VERSION=`curl -s $RPC/abci_info | jq -r .result.response.version`;fi
fi
				  
if [[ -z $MONIKER ]] ; then  MONIKER="Powered by Akash Network!"; fi
sleep 1
echo 'export CHAIN='${CHAIN} >> /root/.bashrc
echo 'export MONIKER='${MONIKER} >> /root/.bashrc
echo 'export BINARY_VERSION='${BINARY_VERSION} >> /root/.bashrc
echo 'export CHAIN='${CHAIN} >> /root/.bashrc
echo 'export RPC='${RPC} >> /root/.bashrc
echo 'export GENESIS='${GENESIS} >> /root/.bashrc
 
# Часть 3 Компиляция
if [[ -n $BINARY_LINK ]]
then
        if echo $BINARY_LINK | grep tar
        then
          wget -O /tmp/$BINARY.tar.gz $BINARY_LINK && tar -xvf /tmp/$BINARY.tar.gz -C /usr/bin/
        elif echo $BINARY_LINK | grep zip
        then
          wget -O /tmp/$BINARY.zip $BINARY_LINK && unzip /tmp/$BINARY.zip && mv ./$BINARY /usr/bin/$BINARY
        else
          wget -O /usr/bin/$BINARY $BINARY_LINK
        fi
else
        GIT_FOLDER=`basename $GITHUB_REPOSITORY | sed "s/.git//"` &&\
		git clone $GITHUB_REPOSITORY &&\
		cd $GIT_FOLDER &&\
		git checkout $BINARY_VERSION &&\
        make build &&\
        make install &&\
        BINARY=`ls /root/go/bin`
        if [[ -z $BINARY ]] 
		then 
			BINARY=`ls /root/$GIT_FOLDER/build/` &&\
			cp /root/$GIT_FOLDER/build/$BINARY /usr/bin/$BINARY
		else 
			cp /root/go/bin/$BINARY /usr/bin/$BINARY 
		fi
fi
# Get access
chmod +x /usr/bin/$BINARY &&\
echo $BINARY &&\
BINARY_UPPER=$(echo "$BINARY" | tr '[:lower:]' '[:upper:]') &&\
echo 'export BINARY='${BINARY} >> /root/.bashrc &&\
echo 'export BINARY_UPPER='${BINARY_UPPER} >> /root/.bashrc &&\
$BINARY version

# Часть 4 Конфигурирование
if [[ -n ${RPC} ]] && [[ -z ${GENESIS} ]]
then
        rm /root/$FOLDER/config/genesis.json &&\
		curl -s $RPC/genesis | jq .result.genesis >> /root/$FOLDER/config/genesis.json
        if [[ -z $DENOM ]]
		then 
			DENOM=`curl -s $RPC/genesis | grep denom -m 1 | tr -d \"\, | sed "s/denom://" | tr -d \ `
		fi
fi

$BINARY init "$MONIKER" --chain-id $CHAIN 

if [[ -z $FOLDER ]] ; then  FOLDER=.`echo $BINARY | sed "s/d$//"`; fi
echo 'export FOLDER='${FOLDER} >> /root/.bashrc

#Download genesis.json
if [[ -n $GENESIS ]]
then
        if echo $GENESIS | grep tar
        then
                rm /root/$FOLDER/config/genesis.json && mkdir /tmp/genesis/
                wget -O /tmp/genesis/genesis.tar.gz $GENESIS && tar -C /tmp/genesis/ -xf /tmp/genesis/genesis.tar.gz
                rm /tmp/genesis/genesis.tar.gz && mv /tmp/genesis/`ls /tmp/genesis/` /root/$FOLDER/config/genesis.json
                if [[ -z $DENOM ]] ; then  DENOM=`curl -s $RPC/genesis | grep denom -m 1 | tr -d \"\, | sed "s/denom://" | tr -d \ `  ; fi
        else
                rm /root/$FOLDER/config/genesis.json &&\
				wget -O /root/$FOLDER/config/genesis.json $GENESIS
                if [[ -z $DENOM ]] ; then  DENOM=`curl -s $RPC/genesis | grep denom -m 1 | tr -d \"\, | sed "s/denom://" | tr -d \ ` ; fi
		fi		
fi
if [[ -z $DENOM ]] ; then  echo DENOM пуст! DENOM is empty! && sleep infinity ; fi
echo $DENOM
echo 'export DENOM='${DENOM} >> /root/.bashrc

#Download snapshot
if [[ -n $SNAPSHOT ]] 
then  
	$BINARY tendermint unsafe-reset-all --keep-addr-book &&\
	SIZE=`wget --spider $SNAPSHOT 2>&1 | awk '/Length/ {print $2}'` &&\
	echo == Download snapshot == &&\
	(wget -nv -O - $SNAPSHOT | pv -petrafb -s $SIZE -i 5 | lz4 -dc - | tar -xf - -C /root/$FOLDER) 2>&1 | stdbuf -o0 tr '\r' '\n' &&\
	echo == Complited == 
fi

#Download addrbook.json
if [[ -n $ADDRBOOK ]] ; then  wget -O /root/$FOLDER/config/addrbook.json $ADDRBOOK ; fi

#Download validator key
if [[ -n ${VALIDATOR_KEY_JSON_BASE64} ]] ; then  echo $VALIDATOR_KEY_JSON_BASE64 | base64 -d > /root/$FOLDER/config/priv_validator_key.json; fi

# State sync
if [[ "$STATE_SYNC" == "enable" ]] && [[ -n $RPC ]]
then
    echo "State sync ENABLED!"
    export "${BINARY_UPPER}_STATESYNC_ENABLE=true"
    export "${BINARY_UPPER}_STATESYNC_RPC_SERVERS=$RPC,$RPC"
    LATEST_HEIGHT=$(curl -s "$RPC/block" | jq -r .result.block.header.height)
    export "${BINARY_UPPER}_STATESYNC_TRUST_HEIGHT=$LATEST_HEIGHT"
    export "${BINARY_UPPER}_STATESYNC_TRUST_HASH=$(curl -s "$RPC/block?height=$LATEST_HEIGHT" | jq -r .result.block_id.hash)"
fi


# Part 5 Run
# Double signature protection
if [[ -n ${RPC} ]] && [[ -n ${VALIDATOR_KEY_JSON_BASE64} ]]
then
  echo Double sign protection
  HEX=`cat /root/$FOLDER/config/priv_validator_key.json | jq -r .address`
  COUNT=15 && CHECKING_BLOCK=`curl -s $RPC/abci_info? | jq -r .result.response.last_block_height`
  while [[ $COUNT -gt 0 ]]
  do
    CHEKER=`curl -s $RPC/commit?height=$CHECKING_BLOCK | grep $HEX`
    if [[ -n $CHEKER  ]]
    then
        echo ++ Защита от двойной подписи!++
        echo ++ ВНИМАНИЕ! ОБНАРУЖЕНА ПОДПИСЬ В ВАЛИДАТОРА НА БЛОКЕ № $CHECKING_BLOCK ! ЗАПУСК НОДЫ ОСТАНОВЛЕН! ++
        echo ++ Double signature protection!++
        echo ++ WARNING! VALIDATOR SIGNATURE DETECTED ON BLOCK № $CHECKING_BLOCK ! NODE LAUNCH HAS BEEN STOPPED! ++
        sleep infinity
    fi
    let COUNT=$COUNT-1 && let CHECKING_BLOCK=$CHECKING_BLOCK-1 && sleep 1
  done
fi

# Create and start service
runsvdir -P /etc/service &
echo =Run node...=
mkdir -p /root/$BINARY/log
cat > /root/$BINARY/run <<EOF
#!/bin/bash
exec 2>&1
exec $BINARY start
EOF
mkdir /tmp/log/
cat > /root/$BINARY/log/run <<EOF
#!/bin/bash
exec svlogd -tt /tmp/log/
EOF
chmod +x /root/$BINARY/log/run /root/$BINARY/run
ln -s /root/$BINARY /etc/service && ln -s /tmp/log/current /LOG
sleep 5
if [[ "$SERVICE_NODE" == "true" ]] ; then sleep 1m ; /service.sh ; fi
while true ; do tail -f /LOG | grep -iv peer ; done 
