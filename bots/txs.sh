#!/bin/bash
SNAP_RPC=`cat /root/bot/RPC.txt`
echo "$SNAP_RPC"
txs=`cat /root/bot/tmp/transaction.txt`
JSON="/root/bot/tmp/txs.json"
text="/root/bot/tmp/txs.txt"
$binary query tx $txs --node "$SNAP_RPC" -o json | jq -r > $JSON

if  grep MsgCreateValidator $JSON
then
t=`cat $JSON | jq -r .code`
   if [[ "$t" == 0 ]]
   then
   echo Transaction: > $text
   echo  >> $text
   echo Status: Sucsess >> $text
   echo Type:   Create validator  >> $text 
   echo Moniker: `cat $JSON | grep moniker | uniq | sed 's/            //;s/"moniker": "//;s/",//'` >> $text
   echo Valoper: `cat $JSON | jq -r .raw_log | sed -e "s/^.//;s/.$//" | jq -r .events[2].attributes[0].value` >> $text  
   echo Details: `cat $JSON | grep details | uniq | sed 's/            //;s/"details": "//;s/"//'` >> $text
   echo Website: `cat $JSON | grep website | uniq | sed 's/            //;s/"website": "//;s/",//'` >> $text
   echo Time:    `cat $JSON | grep -m2 "time" | uniq | awk '{print$2}' | sed '2!D;s/"//;s/",//'` >> $text
   else
   echo Transaction: > $text
   echo  >> $text
   echo Status: Fail >> $text
   echo Type:   Create validator  >> $text
   echo Error: `cat $JSON | jq -r .raw_log` >> $text
   fi
elif grep MsgSend $JSON
then
echo Transaction: > $text
echo  >> $text
echo Type:    `cat $JSON | jq -r .raw_log | sed -e "s/^.//;s/.$//" | jq -r .events[3].type | sed "s/t/T/"` >> $text 
echo From: `cat $JSON | jq -r .raw_log | sed -e "s/^.//;s/.$//" | jq -r .events[2].attributes[1].value` >> $text
echo To: `cat $JSON | jq -r .raw_log | sed -e "s/^.//;s/.$//" | jq -r .events[0].attributes[0].value` >> $text  
echo Amount: `cat $JSON | jq -r .raw_log | sed -e "s/^.//;s/.$//" | jq -r .events[0].attributes[1].value` >> $text
echo Memo: `cat $JSON | grep memo | uniq | sed 's/            //;s/"memo": "//;s/",//'` >> $text
echo Height: `cat $JSON | grep -m1 height | awk '{print$2}'|sed 's/"//;s/",//'`>> $text
echo Time:    `cat $JSON | grep -m2 "time" | uniq | awk '{print$2}' | sed '2!D;s/"//;s/",//'` >> $text

else
echo NOT FOUND > $text
fi
