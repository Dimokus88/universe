#!/bin/bash
TOKEN=`cat /tmp/TOKEN`
CHAT_ID=`cat /tmp/CHAT_ID`
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
p=0
for (( ;; ))
do
PROJECT=`cat ~/monitor/base.json | jq -r .[$p].project`
PROJECT_FOLDER=`ls ~/monitor/ | grep $PROJECT`
if [[ $PROJECT_FOLDER !=  $PROJECT && "$PROJECT" != "null" ]]
then
date
echo Обнаружен новый проект $PROJECT, создаю монитор...
sleep 5
RPC=`cat ~/monitor/base.json | jq -r .[$p].rpc`
USER=`cat ~/monitor/base.json | jq -r .[$p].user`
HEX=`cat ~/monitor/base.json | jq -r .[$p].hex`
mkdir -p ~/monitor/$PROJECT/log

cat > ~/monitor/$PROJECT/alert_$PROJECT.sh <<EOF 
#!/bin/bash
mkdir -p /tmp/$PROJECT/
for ((;;))
do
LAST_BLOCK=\`curl -s $RPC/abci_info? | jq -r .result.response.last_block_height\`
while [[ -z \$LAST_BLOCK ]]
do
LAST_BLOCK=\`curl -s $RPC/abci_info? | jq -r .result.response.last_block_height\`
done
COUNT=19
SIGN=0
NOSIGN=0

while [[ \$COUNT != 0 ]]
do
sleep 2
curl -s $RPC/commit?height=\$LAST_BLOCK > /tmp/$PROJECT/HEX.json
sleep 2
if grep $HEX /tmp/$PROJECT/HEX.json
then
DATE=\`date\`
echo Блок №\$LAST_BLOCK подписан. \$DATE
let SIGN=\$SIGN+1
else
DATE=\`date\`
echo Блок №\$LAST_BLOCK НЕ подписан. \$DATE
let NOSIGN=\$NOSIGN+1
fi
let LAST_BLOCK=\$LAST_BLOCK-1
let COUNT=\$COUNT-1
done

if [ "\$NOSIGN" -gt "\$SIGN" ]
then
DATE=\`date\`
TTL="10"
PARSER="Markdown"
TEXT=" %0A*\$DATE  %0A %0A*%F0%9F%9A%A8 Node $PROJECT Alert $USER! %0A %0A Внимание! Нода пропускает блоки! %0A Срочно проверьте работоспособность! %0A Подписано \$SIGN блоков из 19 %0A Не подписано \$NOSIGN блоков из 19"
curl -s -d "chat_id=$CHAT_ID&parse_mode=$PARSER&disable_web_page_preview=1&text=\$TEXT" $URL
fi

sleep 10m
done
EOF
chmod +x ~/monitor/$PROJECT/alert_$PROJECT.sh
echo Создан alert_$PROJECT.sh !
cat > ~/monitor/$PROJECT/run <<EOF 
#!/bin/bash
exec 2>&1
exec ~/monitor/$PROJECT/alert_$PROJECT.sh
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
p=$p+1
echo Монитор $PROJECT создан!
sleep 5
fi
if [[ "$PROJECT_FOLDER" == "$PROJECT" && "$PROJECT" != "null" ]]
then
date
echo Монитор $PROJECT_FOLDER существует!
sleep 5
p=$p+1
fi
if [[ -z "$PROJECT" || "$PROJECT" == "null" ]]
then
date
echo Новых проектов нет, проверка через 5 минут
sleep 5m
fi
done
