#!/bin/bash
rm /root/bot/text.txt
date >> /root/bot/text.txt
echo Status Node>>/root/bot/text.txt
echo >>/root/bot/text.txt
echo 'Blockchain status:' >>/root/bot/text.txt
echo - Moniker: `curl -s localhost:26657/status | jq -r .result.node_info.moniker `>> /root/bot/text.txt
echo - Network: `curl -s localhost:26657/status | jq -r .result.node_info.network ` >> /root/bot/text.txt
echo - Latest block: `curl -s localhost:26657/status | jq -r .result.sync_info.latest_block_height` >> /root/bot/text.txt
echo - Catching up: `curl -s localhost:26657/status | jq -r .result.sync_info.catching_up` >> /root/bot/text.txt
echo  >>/root/bot/text.txt
echo Hardware status: >>/root/bot/text.txt
echo - CPU used: `ps -aux | grep -m1 "$binary start" | awk '{print $3}'`% >> /root/bot/text.txt
echo - RAM used: `ps -aux | grep -m1 "$binary start" | awk '{print $4}'`% >> /root/bot/text.txt
echo - Memory used: `du /root/ -sh |sed 's_G_GiB_' |sed 's_/root/__'` >> /root/bot/text.txt
echo    >> /root/bot/text.txt
echo Powered by Akash Network! >> /root/bot/text.txt
