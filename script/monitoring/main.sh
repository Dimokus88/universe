#!/bin/bash
apt install -y wget jq runit bc nano cron
echo 1
export EDITOR=nano
echo 2
mkdir /root/.ssh/; echo $SSH_KEY > /root/.ssh/authorized_keys &&\
echo 3
chmod 0600 /root/.ssh/authorized_keys &&\
echo 4
apt install ssh -y
service ssh restart
echo 5
runsvdir -P /etc/service 
echo 6
echo $URL > /tmp/URL
#wget -O /root/monitor.sh https://raw.githubusercontent.com/Dimokus88/universe/main/script/monitoring/monitor.sh
wget -O /root/monitor.sh https://raw.githubusercontent.com/Dimokus88/universe/main/script/monitoring/mon_alpha.sh
chmod +x /root/monitor.sh
mkdir -p /root/monitor/log
cat > /root/monitor/run <<EOF 
#!/bin/bash
exec 2>&1
exec /root/monitor.sh
EOF
cat > /root/monitor/log/run <<EOF 
#!/bin/bash
mkdir -p /root/monitor/log
exec svlogd -tt /root/monitor/log/
EOF
chmod +x /root/monitor/run
chmod +x /root/monitor/log/run
ln -s /root/monitor /etc/service
sleep 20
tail -f /root/monitor/log/current
sleep infinity
