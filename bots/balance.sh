#!/bin/bash
SNAP_RPC=`cat /root/bot/RPC.txt`
addr=`cat /root/bot/tmp/address.txt`
$binary query bank balances $addr --node "$SNAP_RPC" -o json > /root/bot/tmp/balance.json
$binary query staking delegations $addr --node "$SNAP_RPC" -o json > /root/bot/tmp/delegate.json
bal=`cat /root/bot/tmp/balance.json | jq -r .balances[0].amount`
den=`cat /root/bot/tmp/balance.json | jq -r .balances[0].denom`
count=0
a=`cat /root/bot/tmp/delegate.json | jq  -r .delegation_responses[$count].balance.amount`
amount=$a
while [[ "$a" -ne "null" ]]
do 
   let count="$count"+1
   a=`cat /root/bot/tmp/delegate.json | jq  -r .delegation_responses[$count].balance.amount`
   amount=$(echo "$a+$amount" | bc)
   
done

echo Balances: > /root/bot//tmp/balance.txt
echo  >> /root/bot//tmp/balance.txt
echo Address: $addr >> /root/bot//tmp/balance.txt
echo Spendable Balance: $bal $den >> /root/bot/tmp/balance.txt
echo Delegated: $amount $den >> /root/bot/tmp/balance.txt
