#!/bin/bash
URL=`cat /tmp/URL`
p=0
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/monitoring/base.json > ~/monitor/base.json
wget -P /root/monitor/ https://raw.githubusercontent.com/Dimokus88/universe/main/script/monitoring/emoji.json
crontab -l > current_cron
echo "0 10 * * * curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/monitoring/report.sh | bash " >> ~/monitor/current_cron
crontab -l | cat - ~/monitor/current_cron | crontab -
service cron start
for (( ;; ))
do
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/monitoring/base.json > ~/monitor/base.json
PROJECT=`cat ~/monitor/base.json | jq -r .[$p].project`
PROJECT_FOLDER=`ls ~/monitor/ | grep $PROJECT`
if [[ $PROJECT_FOLDER !=  $PROJECT && "$PROJECT" != "null" ]]
then
date
echo New project found $PROJECT, create a monitor...
sleep 5
RPC=`cat ~/monitor/base.json | jq -r .[$p].rpc`
USER=`cat ~/monitor/base.json | jq -r .[$p].user`
HEX=`cat ~/monitor/base.json | jq -r .[$p].hex`
mkdir -p ~/monitor/$PROJECT/log
cat > ~/monitor/$PROJECT/$PROJECT.sh <<EOF 
#!/bin/bash
mkdir -p /tmp/$PROJECT/
for ((;;))
do
RPC=\`cat ~/monitor/base.json | jq -r .[$p].rpc\`
LAST_BLOCK=\`curl -s \$RPC/abci_info? | jq -r .result.response.last_block_height\`
while [[ -z \$LAST_BLOCK ]]
do
LAST_BLOCK=\`curl -s \$RPC/abci_info? | jq -r .result.response.last_block_height\`
EMOJI=\$(cat /root/monitor/emoji.json | jq -r .alarm[] | shuf -n 1)
curl -s -H "Content-Type: application/json" -X POST -d '{"content":"'\$EMOJI' Внимание! RPC нода $PROJECT недоступна !"}' $URL
sleep 10m
curl -s https://raw.githubusercontent.com/Dimokus88/universe/main/script/monitoring/base.json > ~/monitor/base.json
done
COUNT=19
SIGN=0
NOSIGN=0

while [[ \$COUNT != 0 ]]
do
sleep 2
curl -s \$RPC/commit?height=\$LAST_BLOCK > /tmp/$PROJECT/HEX.json
sleep 2
if grep $HEX /tmp/$PROJECT/HEX.json
then
DATE=\`date\`
echo Block № \$LAST_BLOCK SIGN. \$DATE
let SIGN=\$SIGN+1
else
DATE=\`date\`
echo Block № \$LAST_BLOCK NOT SIGN! . \$DATE
let NOSIGN=\$NOSIGN+1
fi
let LAST_BLOCK=\$LAST_BLOCK-1
let COUNT=\$COUNT-1
done

if [ "\$NOSIGN" -gt "\$SIGN" ]
then
EMOJI=\$(cat /root/monitor/emoji.json | jq -r .panic[] | shuf -n 1)
curl -s -H "Content-Type: application/json" -X POST -d '{"content":"'\$EMOJI' Node $PROJECT Alert $USER !\\nВнимание! Нода пропускает блоки! \\n**Срочно проверьте работоспособность!** \\n\`\`\`Подписано '\$SIGN' блоков из 19. \\nНе подписано '\$NOSIGN' блоков из 19. \`\`\`"}' $URL
fi

sleep 10m
done
EOF
chmod +x ~/monitor/$PROJECT/$PROJECT.sh
echo Создан $PROJECT.sh !
cat > ~/monitor/$PROJECT/run <<EOF 
#!/bin/bash
exec 2>&1
exec ~/monitor/$PROJECT/$PROJECT.sh
EOF
echo Создан ~/monitor/$PROJECT/run !
cat > ~/monitor/$PROJECT/log/run <<EOF 
#!/bin/bash
mkdir -p ~/monitor/log/$PROJECT
exec svlogd -tt ~/monitor/log/$PROJECT
EOF
echo Создан ~/monitor/$PROJECT/log/run !
chmod +x ~/monitor/$PROJECT/run
chmod +x ~/monitor/$PROJECT/log/run
echo Права на исполнение выданы !
ln -s ~/monitor/$PROJECT /etc/service
echo Монитор $PROJECT создан!
#Proposals
mkdir -p ~/monitor/"$PROJECT"_PROP/log
cat > ~/monitor/"$PROJECT"_PROP/"$PROJECT"_PROP.sh <<EOF
#!/bin/bash
mkdir -p /tmp/"$PROJECT"_PROP/
while true
do
RPC=\`cat ~/monitor/base.json | jq -r .[$p].rpc\`
L_BL=\`curl -s \$RPC/block?latest | jq -r .result.block.header.height\`
while [[ -z \$L_BL ]]
do
EMOJI=\$(cat /root/monitor/emoji.json | jq -r .panic[] | shuf -n 1)
curl -s -H "Content-Type: application/json" -X POST -d '{"content":"'\$EMOJI' $PROJECT Alert $USER !\\nВнимание! RPC нода '\$RPC' не доступна! \\n**Проверьте RPC!**"}' $URL
sleep 30m
L_BL=\`curl -s \$RPC/block?latest | jq -r .result.block.header.height\`
done
if [[ \$L_BL -gt \$BL ]]
then
BL=\$L_BL
echo \$BL
curl -s \$RPC/block?height=\$BL | jq -r .result.block.data.txs[] | base64 -d > /tmp/"$PROJECT"_PROP/txs.txt
if grep -a MsgSubmitProposal /tmp/"$PROJECT"_PROP/txs.txt
then
EMOJI=\$(cat /root/monitor/emoji.json | jq -r .happy[] | shuf -n 1)
curl -s -H "Content-Type: application/json" -X POST -d '{"content":"'\$EMOJI' $PROJECT Alert $USER !\\nВнимание! в сети обнаружено новое голосование! \\n**Проверьте сеть!**"}' $URL
fi
else
echo Ожидание следующего блока..
fi
L_BL=\`curl -s \$RPC/block?latest | jq -r .result.block.header.height\`
done
EOF

chmod +x ~/monitor/"$PROJECT"_PROP/"$PROJECT"_PROP.sh
echo Создан "$PROJECT"_PROP.sh !
EMOJI=$(cat /root/monitor/emoji.json | jq -r .happy[] | shuf -n 1)
curl -s -H "Content-Type: application/json" -X POST -d '{"content":"'$EMOJI' Создано оповещение и проверка новых голосований '$PROJECT' для '$USER' ."}' $URL
cat > ~/monitor/"$PROJECT"_PROP/run <<EOF 
#!/bin/bash
exec 2>&1
exec ~/monitor/"$PROJECT"_PROP/"$PROJECT"_PROP.sh
EOF
echo Создан ~/monitor/"$PROJECT"_PROP/run !
cat > ~/monitor/"$PROJECT"_PROP/log/run <<EOF 
#!/bin/bash
mkdir -p ~/monitor/log/"$PROJECT"_PROP
exec svlogd -tt ~/monitor/log/"$PROJECT"_PROP
EOF
echo Создан ~/monitor/"$PROJECT"_PROP/log/run !
chmod +x ~/monitor/"$PROJECT"_PROP/run
chmod +x ~/monitor/"$PROJECT"_PROP/log/run
echo Права на исполнение выданы !
ln -s ~/monitor/"$PROJECT"_PROP /etc/service
echo Проверка голосований для "$PROJECT"_PROP создана!

let p=$p+1
sleep 5
fi
if [[ "$PROJECT_FOLDER" == "$PROJECT" && "$PROJECT" != "null" ]]
then
date
echo Монитор $PROJECT_FOLDER существует!
sleep 5
let p=$p+1
fi
if [[ -z "$PROJECT" || "$PROJECT" == "null" ]]
then
date
echo Новых проектов нет, проверка через 10 минут
sleep 10m
fi
done
