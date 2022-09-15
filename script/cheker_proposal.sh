#!/bin/bash
binary=$1
TOKEN=$2
CHAT_ID=$3
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
TTL="10"
PARSER="HTML"
count=0
id=`$binary q gov proposals -o json | jq -r .proposals[$count].proposal_id`
$binary q gov proposals -o json | jq .proposals[$count] > /root/tmp/proposal$id.txt
while [[ "$id" -ne "null" ]]
do
let count=$count+1
id=`$binary q gov proposals -o json | jq -r .proposals[$count].proposal_id`
if [[ "$id" -ne "null" ]]
then
$binary q gov proposals -o json | jq .proposals[$count] > /root/tmp/proposal$id.txt
sleep 1
MESSAGE=`cat /root/tmp/proposal$id.txt`
TEXT="%0AFind proposal:  %0A$MESSAGE"
curl -s --max-time $TTL -d "chat_id=$CHAT_ID&parse_mode=$PARSER&disable_web_page_preview=1&text=$TEXT" $URL
sleep 2
fi
echo complited
done

for ((;;))
do
id=`$binary q gov proposals -o json | jq -r .proposals[$count].proposal_id`
if [[ "$id" -ne "null" ]]
then
$binary q gov proposals -o json | jq .proposals[$count] > /root/tmp/proposal$id.txt
sleep 1
MESSAGE=`cat /root/tmp/proposal$id.txt`
TEXT="%0AFind NEW proposal:  %0A$MESSAGE"
curl -s --max-time $TTL -d "chat_id=$CHAT_ID&parse_mode=$PARSER&disable_web_page_preview=1&text=$TEXT" $URL
let count=$count+1
fi
echo search
sleep 30m
done
