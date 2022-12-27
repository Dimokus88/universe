#!/bin/bash
read -p "Введите имя службы: " SERVICE
sleep 2
read -p "Введите токен Ваш токен авторизации Discord: " TOKEN
sleep 2
read -p "Введите токен id канала Discord faucet: " CHANNEL
sleep 2
read -p "Введите интервал отправки сообщений в канал Discord faucet (в секундах): " INTERVAL
sleep 2
read -p "Введите сообщение, которое необходимо отправить в Discord faucet: " TEXT
echo Разворачиваю сервисный файл...
sleep 4
mkdir -p ~/faucet_discord/$SERVICE/log
cat > ~/faucet_discord/$SERVICE/$SERVICE <<EOF 
for ((;;)); do
    curl -s -H "Authorization: $TOKEN" -H "Content-Type: application/json" -X POST -d '{"content":"$TEXT"}' https://discordapp.com/api/channels/$CHANNEL/messages
    echo
    for (( timer=${INTERVAL}; timer>0; timer-- ))
        do
                printf "* sleep for %02d sec\r" $timer
                sleep 1
        done
done
EOF
echo Устанавливаю службу $SERVICE...
cat > ~/faucet_discord/$SERVICE/run <<EOF 
#!/bin/bash
exec 2>&1
exec ~/faucet_discord/$SERVICE/$SERVICE
EOF

echo Создан ~/faucet_discord/$SERVICE/run !

cat > ~/faucet_discord/$SERVICE/log/run <<EOF 
#!/bin/bash
exec svlogd -tt ~/faucet_discord/$SERVICE/log/
EOF

echo Создан ~/faucet_discord/$SERVICE/log/run !

chmod +x ~/faucet_discord/$SERVICE/run
chmod +x ~/faucet_discord/$SERVICE/log/run
echo Права на исполнение выданы !
ln -s ~/faucet_discord/$SERVICE/ /etc/service
sleep 2 
echo Кран запущен!
