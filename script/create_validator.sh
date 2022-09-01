#!/bin/bash
source /root/.bashrc
sleep 1
echo $binary
echo == Начало работы скрипта по созданию валидатора ==
sleep 5
if [[ -z "$MNEMONIC" ]]
then
echo "Введите мнемоник от кошелька (скрытый ввод):"
read -s -p "Enter mnemonic (hidden input): " MNEMONIC
fi
sleep 2
if [[ -z "$wallet_name" ]]
then
echo "Введите имя кошелька:"
read -p "Enter wallet name: " wallet_name
echo 'export wallet_name ='${wallet_name} >> $HOME/.bashrc
fi
sleep 2
if [[ -z "$pass_wallet" ]]
then
echo "Введите пароль от кошелька (скрытый ввод):"
read -s -p "Enter wallet password (hidden input): " pass_wallet
echo 'export pass_wallet='${pass_wallet} >> $HOME/.bashrc
fi
echo == Импортирую кошелек ==
(echo ${MNEMONIC}; echo ${pass_wallet}; echo ${pass_wallet}) | $binary keys add ${wallet_name} --recover
sleep 2
echo == Запрашиваю баланс ==
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
echo == Недостаточный баланс токенов для создания валидатора. Токенов на балансе $balance $denom, необходимо минимум 1001000$denom ==
sleep 1m
done
sleep 2
echo == Достаточный баланс для создания валидатора ==
sleep 2
echo == Создаю валидатора ==
sleep 2
DATE=`date`
(echo ${pass_wallet}) | $binary tx staking create-validator --amount="1000000$denom" --pubkey=$($binary tendermint show-validator) --moniker="$MONIKER" --chain-id="$chain" --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --min-self-delegation="1000000" --from="$address" --details="Powered on Akash Network! Create $DATE" --fees="5550$denom" --gas="auto" -y
sleep 10
val=`$binary query staking validator $valoper -o json | jq -r .description.moniker`
if [[ -z "$val" ]]
then
echo == Валидатор не создан! ==
echo == Проверьте лог на наличие ошибок, за поддержкой можете обратиться в чат Akash_ru: https://t.me/akash_ru ==
else
echo == Валидатора $val успешно создан! ==
fi
sleep 10
echo == Работа скрипта завершена! ==
