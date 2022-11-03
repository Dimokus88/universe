#!/bin/bash
source /root/.bashrc
BINARY=`cat ~/.bashrc | grep BINARY= | sed -e "s_export BINARY=__;"`
DENOM=`cat ~/.bashrc | grep DENOM | sed -e "s_export DENOM=__;"`
CHAIN=`cat ~/.bashrc | grep CHAIN | sed -e "s_export CHAIN=__;"`
MONIKER=`cat ~/.bashrc | grep MONIKER | sed -e "s_export MONIKER=__;"`
echo $BINARY
sleep 1
echo -e "\n=== Starting the script to create the validator =="
echo -e "\n== Начало работы скрипта по созданию валидатора =="
sleep 2
echo -e "\n==== Importing wallet, enter mnemonic and set password (hidden input!) ===="
echo -e "\n== Импортирую кошелек, введите mnemonic и задайте пароль (скрытый ввод!) =="
$BINARY keys add wallet --recover
sleep 2
if [[ -z "$WALLET_PASS" ]]
then
echo -e "\nПовторите ввод пароля от кошелька:"
read -s -p "Re-enter your wallet password: " WALLET_PASS
echo 'export WALLET_PASS='${WALLET_PASS} >> $HOME/.bashrc
fi
address=`(echo ${WALLET_PASS}) | $BINARY keys show wallet -a | sed -e "s_/root/.__;"`
echo 'export address='${address} >> $HOME/.bashrc
sleep 2
valoper=`(echo ${WALLET_PASS}) | $BINARY keys show wallet --bech val -a | sed -e "s_/root/.__;"`
echo 'export valoper='${valoper} >> $HOME/.bashrc
echo -e "\n===== Request tokens from faucet at ${address} ===="
echo -e "\n== Запросите токены из крана на адрес ${address} =="
sleep 5
sync=`curl -s localhost:26657/status | jq .result.sync_info.catching_up`
sleep 2
echo -e "\n== Requesting balance =="
echo -e "\n== Запрашиваю баланс ==="
sleep 2
balance=`$BINARY q bank balances $address -o json | jq -r .balances[0].amount `
sleep 2
echo $balance $DENOM
sleep 2
while [[ `echo $balance` -lt  1000000 ]]
do
echo -e "\n=== Insufficient balance of tokens to create a validator. Tokens on balance $balance $DENOM, minimum 1000000$DENOM required ===="
echo -e "\n===================== Request tokens from faucet at ${address} ==========================="
echo -e "\n== Недостаточный баланс токенов для создания валидатора. Токенов на балансе $balance $DENOM, необходимо минимум 1000000$DENOM =="
echo -e "\n===================== Запросите токены из крана на адрес ${address} ==================="
sleep 1m
balance=`$BINARY q bank balances $address -o json | jq -r .balances[0].amount `
done
sleep 2
echo -e "\n===== Enough balance to create a validator ====="
echo -e "\n== Достаточный баланс для создания валидатора =="
sleep 2
echo $balance $DENOM
sleep 2
echo -e "\n== Creating a validator =="
echo -e "\n==== Создаю валидатора ==="
sleep 2
DATE=`date`
(echo ${WALLET_PASS}) | $BINARY tx staking create-validator --amount="900000$DENOM" --pubkey=$($BINARY tendermint show-validator --home /root/$BINARY) --moniker="$MONIKER" --chain-id="$CHAIN" --identity=86C945B6D5F526E6 --website="https://akash.network/" --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="100000" --from="$address" --details="Powered on Akash Network! Create $DATE" --fees="10000$DENOM" -y
sleep 10
val=`$BINARY query staking validator $valoper -o json | jq -r .description.moniker`
if [[ -z "$val" ]]
then
echo -e "\n========================================= Validator not created! ==========================================="
echo -e "\n======== Check the log for errors, you can contact Akash_ru chat for support: https://t.me/AkashNW ========="
echo -e "\n========================================== Валидатор не создан! ============================================"
echo -e "\n== Проверьте лог на наличие ошибок, за поддержкой можете обратиться в чат Akash_ru: https://t.me/akash_ru =="
else
echo -e "\n== $val validator created successfully! =="
echo -e "\n===== Валидатор $val успешно создан! ====="
fi
sleep 10
echo -e "\n====== Script completed! ======"
echo -e "\n== Работа скрипта завершена! =="
