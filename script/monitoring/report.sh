#!/bin/bash
URL="/tmp/URL"
p=0
PROJECT=`cat ~/monitor/base.json | jq -r .[$p].project`
DATE=`date +"%d.%m.%Y"`
echo Отчет по делегациям валидатора \*\*Decloud Nodes Lab\*\* на $DATE.  > /root/monitor/message.txt
while [[ "$PROJECT" != "null" ]]
do
echo $PROJECT this
echo Main
STATUS=`cat ~/monitor/base.json | jq -r .[$p].status`
 if [[ "$STATUS" == "mainnet" ]]
 then
 echo in mainnets
 RPC=`cat ~/monitor/base.json | jq -r .[$p].rpc`
 echo $RPC
 HEX=`cat ~/monitor/base.json | jq -r .[$p].hex`
 echo $HEX
 LINK_PRICE=`cat ~/monitor/base.json | jq -r .[$p].link_price`
 echo $LINK_PRICE
 VOTING_POWER=`curl -s --connect-timeout 10 $RPC/validators?per_page=100 | jq -r ".result.validators[] | select(.address == \"${HEX}\") | .voting_power"`
 echo $VOTING_POWER
 LATEST_VOTING_POWER=`cat /tmp/"$PROJECT"_report.json | jq -r .$PROJECT`
 echo $LATEST_VOTING_POWER
      if [[ -z "$LATEST_VOTING_POWER" ]]
      then
		echo  LATEST_VOTING_POWER clear
        LATEST_VOTING_POWER=VOTING_POWER
      fi
 CHANGE=$((LATEST_VOTING_POWER-VOTING_POWER))
 CHANGE_PERCENT=$(awk "BEGIN {print (($LATEST_VOTING_POWER-$VOTING_POWER)/$VOTING_POWER)*100}")
 PRICE=`curl -s $LINK_PRICE | jq .market_data.current_price.usd`
 DELEGATE_USD=$(echo "$VOTING_POWER * $PRICE" | bc)
 echo \`\`\`\\n Проект: $PROJECT\\nВсего заделегировано токенов: $VOTING_POWER\\nИзменение в делегации: $CHANGE токенов или $CHANGE_PERCENT%\\nЦена $PROJECT на Coingecko: $PRICE\\n Заделегировано в USD: $DELEGATE_USD$\\n\\n\\n \`\`\` >> /root/monitor/message.txt
 echo '{"'$PROJECT'":"'$VOTING_POWER'"}' > /tmp/"$PROJECT"_report.json
 p=$p+1
 PROJECT=`cat ~/monitor/base.json | jq -r .[$p].project`
 else
 echo in testnets
 p=$p+1
 PROJECT=`cat ~/monitor/base.json | jq -r .[$p].project`
 fi

done
echo  END
TEXT=`cat /root/monitor/message.txt`
curl -H "Content-Type: application/json" -X POST -d '{"content": "${TEXT}"}' $URL