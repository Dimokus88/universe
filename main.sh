#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
source $HOME/.bashrc
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/env.sh | bash
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/start.sh | bash
curl -s https://raw.githubusercontent.com/Dimokus88/scripts/main/logo.sh | bash

#======================================================== НАЧАЛО БЛОКА ФУНКЦИЙ ==================================================

#*******************ФУНКЦИЯ РАБОЧЕГО РЕЖИМА НОДЫ|*************************
WORK (){
while [[ $synh == false ]]
do
	sleep 5m
	curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/info.sh | bash
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
			(echo ${PASSWALLET}) | $binary tx distribution withdraw-rewards $valoper --from $address --gas="auto" --fees 5555$denom --commission -y
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

# ----------УСТАНОВКА GO-----------
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/GoSetup.sh | bash
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

echo ${PASSWALLET}
echo ${WALLET_NAME}
sleep 2

#=======ИНИЦИАЛИЗАЦИЯ БИНАРНОГО ФАЙЛА================
echo =INIT=
rm /root/$folder/config/genesis.json
$binary init "$MONIKER" --chain-id $chain --home /root/$folder
sleep 5
#====================================================

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

#===========ДОБАВЛЕНИЕ GENESIS.JSON===============
wget -O $HOME/$folder/config/genesis.json $genesis
sha256sum ~/$folder/config/genesis.json
cd && cat $folder/data/priv_validator_state.json
#=================================================

#===========ДОБАВЛЕНИЕ ADDRBOOK.JSON===============
rm $HOME/$folder/config/addrbook.json
wget -O $HOME/$folder/config/addrbook.json $addrbook
#==================================================

# ------ПРОВЕРКА НАЛИЧИЯ priv_validator_key--------
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/priv_validator_key_detection.sh | bash
# -----------------------------------------------------------

#-----ВНОСИМ ИЗМЕНЕНИЯ В CONFIG.TOML , APP.TOML.-----------
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/toml_settings.sh | bash
#-----------------------------------------------------------

#|||||||||||||||||||||||||||||||||||ФУНКЦИЯ Backup||||||||||||||||||||||||||||||||||||||||||||||||||||||
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/startup.sh | bash
# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

#===========ЗАПУСК НОДЫ============
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/run_at_service.sh | bash

source $HOME/.bashrc
sleep 20

synh=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
echo $synh
sed -i.bak -e "s/synh=/synh=$synh/;" $HOME/.bashrc
tail -30 /var/log/$binary/current
sleep 2
source $HOME/.bashrc
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
		(echo ${PASSWALLET}) | $binary tx staking create-validator --amount="1000000$denom" --pubkey=$($binary tendermint show-validator) --moniker="$MONIKER" --chain-id="$chain" --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1000000" --gas="auto"	--from=`(echo ${PASSWALLET}) | $$binary keys show $WALLET_NAME -a` --fees="5550$denom" -y
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
