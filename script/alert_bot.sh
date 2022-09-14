#!/bin/bash
CHAT_ID=$1
rm /root/bot/text.txt
echo Network: `curl -s localhost:26657/status | jq -r .result.node_info.network` >> /root/bot/text.txt
echo Latest block: `curl -s localhost:26657/status | jq -r .result.sync_info.latest_block_height` >> /root/bot/text.txt
echo Catching up: `curl -s localhost:26657/status | jq -r .result.sync_info.catching_up` >> /root/bot/text.txt
echo Memory used: `du -sh | sed "s/G/GiB/" | sed "s/.$//"` >> /root/bot/text.txt
TOKEN='5413800716:AAHAwfZgg-c02OD3hYDH_QD8QwLKBEE-VL4'
echo $CHAT_ID $TG_KEY
DATE=`date`
URL="https://api.telegram.org/bot$TG_KEY/sendMessage"
TTL="10"
PARSER="Markdown"
MESSAGE=`cat /root/text.txt`
TEXT=" %0A*$DATE* *%F0%9F%8E%AANode status:* %0A$MESSAGE  %0ARev.%0ATelegram EN: https://examplelink.com %0ATelegram RU: https://t.me/akash_ru"
curl -s --max-time $TTL -d "chat_id=$CHAT_ID&parse_mode=$PARSER&disable_web_page_preview=1&text=$TEXT" $URL
