#!/bin/bash
echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
sleep 1
binary=`cat ~/.bashrc | grep binary | sed -e "s_export binary=__;"`
denom=`cat ~/.bashrc | grep denom | sed -e "s_export denom=__;"`
chain=`cat ~/.bashrc | grep chain | sed -e "s_export chain=__;"`
MONIKER=`cat ~/.bashrc | grep MONIKER | sed -e "s_export MONIKER=__;"`
echo $binary
echo $denom
echo $chain
echo $MONIKER
echo -e "\n== Начало работы скрипта по созданию валидатора =="
sleep 5
if [[ -z "$MNEMONIC" ]]
then
echo -e "\nВведите мнемоник от кошелька (скрытый ввод):"
read -s -p "Enter mnemonic (hidden input): " MNEMONIC
echo $MNEMONIC
fi
sleep 2
if [[ -z "$wallet_name" ]]
then
echo -e "\nВведите имя кошелька:"
read -p "Enter wallet name: " wallet_name
echo 'export wallet_name ='${wallet_name} >> $HOME/.bashrc
fi
sleep 2
if [[ -z "$pass_wallet" ]]
then
echo -e "\nВведите пароль от кошелька (скрытый ввод):"
read -s -p "Enter wallet password (hidden input): " pass_wallet
echo 'export pass_wallet='${pass_wallet} >> $HOME/.bashrc
fi
echo -e "\n== Импортирую кошелек =="
echo -e "${MNEMONIC}\n${PASWD}\n${PASWD}\n" | $binary keys add ${wallet_name} --recover
sleep 2
echo -e "\n== Запрашиваю баланс =="
address=`$binary keys show $wallet_name -a | sed -e "s_/root/.__;"`
echo 'export address='${address} >> $HOME/.bashrc
sleep 2
valoper=`$binary keys show $wallet_name --bech val -a | sed -e "s_/root/.__;"`
echo 'export valoper='${valoper} >> $HOME/.bashrc
sleep 2
balance=`$binary q bank balances $address -o json | jq -r .balances[0].amount `
sleep 2
echo $balance $denom
sleep 2
while [[ `echo $balance` -lt  1001000 ]]
do
echo -e "\n== Недостаточный баланс токенов для создания валидатора. Токенов на балансе $balance $denom, необходимо минимум 1001000$denom =="
sleep 1m
done
sleep 2
echo -e "\n== Достаточный баланс для создания валидатора =="
sleep 2
echo -e "\n== Создаю валидатора =="
sleep 2
DATE=`date`
(echo ${pass_wallet}) | $binary tx staking create-validator --amount="1000000$denom" --pubkey=$($binary tendermint show-validator) --moniker="$MONIKER" --chain-id="$chain" --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1000000" --from="$address" --details="Powered on Akash Network! Create $DATE" --fees="5550$denom" --gas="auto" -y
sleep 10
val=`$binary query staking validator $valoper -o json | jq -r .description.moniker`
if [[ -z "$val" ]]
then
echo "\n== Валидатор не создан! =="
echo "\n== Проверьте лог на наличие ошибок, за поддержкой можете обратиться в чат Akash_ru: https://t.me/akash_ru =="
else
echo "\n== Валидатора $val успешно создан! =="
fi
sleep 10
echo "\n== Работа скрипта завершена! =="
