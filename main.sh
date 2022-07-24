#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/start.sh | bash
curl -s https://raw.githubusercontent.com/Dimokus88/scripts/main/logo.sh | bash

#======================================================== НАЧАЛО БЛОКА ФУНКЦИЙ ==================================================

#*******************ФУНКЦИЯ РАБОЧЕГО РЕЖИМА НОДЫ|*************************
WORK (){
while [[ $synh == false ]]
do
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/work.sh | bash
done
}
#*************************************************************************

#======================================================== КОНЕЦ БЛОКА ФУНКЦИЙ ====================================================

# ----------УСТАНОВКА GO-----------
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/GoSetup.sh | bash
# ---------------------------------

#-----------КОМПИЛЯЦИЯ БИНАРНОГО ФАЙЛА------------
sudo curl -s  https://raw.githubusercontent.com/Dimokus88/universe/main/script/cbinary.sh | bash
#-------------------------------------------------
echo ${PASSWALLET}
echo ${WALLET_NAME}
source $HOME/.bash_profile
sleep 2

#=======ИНИЦИАЛИЗАЦИЯ БИНАРНОГО ФАЙЛА================
echo =INIT=
rm /root/$folder/config/genesis.json
$binary init "$MONIKER" --chain-id $chain --home /root/$folder
sleep 5
#====================================================

#===========ДОБАВЛЕНИЕ КОШЕЛЬКА============
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/addwallet.sh | bash
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

$binary config chain-id $chain
$binary config keyring-backend os

#-----ВНОСИМ ИЗМЕНЕНИЯ В CONFIG.TOML , APP.TOML.-----------
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/toml_settings.sh | bash
#-----------------------------------------------------------

#|||||||||||||||||||||||||||||||||||ФУНКЦИЯ Backup||||||||||||||||||||||||||||||||||||||||||||||||||||||
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/startup.sh | bash
# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

#===========ЗАПУСК НОДЫ============
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/run_at_service.sh | bash

source $HOME/.bash_profile
sleep 20

synh=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
echo $synh
tail -30 /var/log/$binary/current
sleep 2
source $HOME/.bash_profile
#==================================

#=========Пока нода не синхронизирована - повторять===========
while [[ $synh == true ]]
do
	echo ==============================================
	echo =Нода не синхронизирована! Node is not sync! =
	echo ==============================================
	tail -30 /var/log/$binary/current
	sleep 5m
	echo =====Ваш адрес =====
	echo ===Your address ====
	echo $address
	echo ==========================
	echo =====Your valoper=====
	echo ======Ваш valoper=====
	echo $valoper
	echo ===========================
	date
	curl -s localhost:26657/status
	synh=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
	echo $synh
	source $HOME/.bash_profile
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
	echo $synh
	source $HOME/.bash_profile
	if [[ -z "$val" ]]
	then
		echo =Создание валидатора... Creating a validator...=
		(echo ${PASSWALLET}) | $binary tx staking create-validator --amount="1000000$denom" --pubkey=$($binary tendermint show-validator) --moniker="$MONIKER"	--chain-id="$chain"	--commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1000000" --gas="auto"	--from="$address" --fees="5550$denom" -y
		sleep 20
		val=`$binary query staking validator $valoper -o json | jq -r .description.moniker`
		echo $val
		source $HOME/.bash_profile
	else
		val=`$binary query staking validator $valoper -o json | jq -r .description.moniker`
		echo $val
		MONIKER=`echo $val`
		WORK
		source $HOME/.bash_profile
	fi
done
