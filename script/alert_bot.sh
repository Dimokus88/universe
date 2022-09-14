#!/bin/bash
CHAT_ID=$1
binary=$2
valoper=$3
rm /root/bot/text.txt
echo -e "\n\xF0\x9F\x94\x97Blockchain status:" >>/root/bot/text.txt
echo - Moniker: `curl -s localhost:26657/status | jq -r .result.node_info.moniker | sed "s/_/ /"`>> /root/bot/text.txt
echo - Network: `curl -s localhost:26657/status | jq -r .result.node_info.network | sed "s/_/-/"` >> /root/bot/text.txt
echo - Latest block: `curl -s localhost:26657/status | jq -r .result.sync_info.latest_block_height` >> /root/bot/text.txt
echo - Catching up: `curl -s localhost:26657/status | jq -r .result.sync_info.catching_up` >> /root/bot/text.txt
echo - Jailed: `$binary query staking validator $valoper -o json | jq -r .jailed` >> /root/bot/text.txt
echo -e "\n\xF0\x9F\x92\xBBHardware status:" >>/root/bot/text.txt
echo - CPU used: `ps -aux | grep -m1 "$binary start" | awk '{print $3}'`% >> /root/bot/text.txt
echo - RAM used: `ps -aux | grep -m1 "$binary start" | awk '{print $4}'`% >> /root/bot/text.txt
echo  -Memory used: `du /root/ -sh |sed "s_G_GiB_" |sed "s_/root/__"` >> /root/bot/text.txt
TOKEN='5413800716:AAHAwfZgg-c02OD3hYDH_QD8QwLKBEE-VL4'
echo $CHAT_ID $TOKEN
DATE=`date`
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
TTL="10"
PARSER="Markdown"
MESSAGE=`cat /root/bot/text.txt`
TEXT=" %0A*$DATE  *%0A %0A*%E2%9C%85 Node status:* %0A %0A$MESSAGE  %0A *%0A%F0%9F%9A%80Powered by Akash Network%F0%9F%9A%80* %0A %0ADiscord: https://discord.gg/ybKMsYYZkx %0ATelegram EN: https://t.me/AkashNW  %0ATelegram RU: https://t.me/akash\_ru"
curl -s --max-time $TTL -d "chat_id=$CHAT_ID&parse_mode=$PARSER&disable_web_page_preview=1&text=$TEXT" $URL
sleep 20
