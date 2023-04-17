#!/bin/bash
URL=`cat /tmp/URL`
p=0
PROJECT=`cat ~/monitor/base.json | jq -r .[$p].project`
DATE=`date +"%d.%m.%Y"`
TEXT=":saluting_face: Отчет по делегациям валидатора **Decloud Nodes Lab** на "$DATE"."
TEXT=$(echo -e "${TEXT}" | jq -Rs .)
echo $TEXT
curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": ${TEXT} }" $URL
TOTAL_DELEGATE=0
while [[ "$PROJECT" != "null" ]]
do
STATUS=`cat ~/monitor/base.json | jq -r .[$p].status`
 if [[ "$STATUS" == "mainnet" ]]
 then
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
        LATEST_VOTING_POWER=VOTING_POWER
      fi
 CHANGE=$((LATEST_VOTING_POWER-VOTING_POWER))
 CHANGE_PERCENT=$(awk "BEGIN {print (($LATEST_VOTING_POWER-$VOTING_POWER)/$VOTING_POWER)*100}")
 PRICE=`curl -s $LINK_PRICE | jq .market_data.current_price.usd`
 DELEGATE_USD=$(printf "%.0f" $(echo "$VOTING_POWER * $PRICE" | bc))
 TEXT="Проект: **"$PROJECT"**\nВсего заделегировано токенов: **"$VOTING_POWER"**\nИзменение в делегации: **"$CHANGE"** токенов или **"$CHANGE_PERCENT"%**\nЦена "$PROJECT" на Coingecko: **"$PRICE"\$**\nЗаделегировано в USD: **"$DELEGATE_USD"\$**\n "
 TEXT=$(echo -e "${TEXT}" | jq -Rs .)
 echo $TEXT
 echo $URL
 curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": ${TEXT} }" $URL
 echo '{"'$PROJECT'":"'$VOTING_POWER'"}' > /tmp/"$PROJECT"_report.json
 p=$p+1
 PROJECT=`cat ~/monitor/base.json | jq -r .[$p].project`
TOTAL_DELEGATE=$(echo "$TOTAL_DELEGATE + $DELEGATE_USD" | bc)

 else
 p=$p+1
 PROJECT=`cat ~/monitor/base.json | jq -r .[$p].project`
 fi

done
TEXT=":rocket: ** Всего на Decloud Nodes Lab заделегировано "$TOTAL_DELEGATE"$ ** :rocket:"
TEXT=$(echo -e "${TEXT}" | jq -Rs .)
echo $TEXT
curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": ${TEXT} }" $URL 
echo  END
