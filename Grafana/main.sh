#!/bin/bash
runsvdir -P /etc/service &
# ++++++++++++ Установка удаленного доступа ++++++++++++++
echo 'export MY_ROOT_PASSWORD='${MY_ROOT_PASSWORD} >> /root/.bashrc
apt install tmate -y
mkdir /root/tmate && mkdir /root/tmate/log
cat > /root/tmate/run <<EOF 
#!/bin/bash
exec 2>&1
exec tmate -F
EOF
cat > /root/tmate/log/run <<EOF 
#!/bin/bash
mkdir /var/log/tmate
exec svlogd -tt /var/log/tmate
EOF
chmod +x /root/tmate/run
chmod +x /root/tmate/log/run
ln -s /root/tmate /etc/service

if [[ -n $MY_ROOT_PASSWORD ]]
then
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  (echo ${MY_ROOT_PASSWORD}; echo ${MY_ROOT_PASSWORD}) | passwd root && service ssh restart
else
  apt install -y goxkcdpwgen 
  MY_ROOT_PASSWORD=$(goxkcdpwgen -n 1)
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  (echo ${MY_ROOT_PASSWORD}; echo ${MY_ROOT_PASSWORD}) | passwd root && service ssh restart
  echo ============= SSH PASS: $MY_ROOT_PASSWORD ==============
  sleep 10
fi
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wget https://github.com/prometheus/prometheus/releases/download/v2.28.1/prometheus-2.28.1.linux-amd64.tar.gz && \
tar xvf prometheus-2.28.1.linux-amd64.tar.gz && \
rm prometheus-2.28.1.linux-amd64.tar.gz && \
mv prometheus-2.28.1.linux-amd64 prometheus
wget -O $HOME/prometheus/prometheus.yml $LINKPROMETHEUS
chmod +x $HOME/prometheus/prometheus
#--------------------------------------------------------------
mkdir -p /root/prometheusd/log
   
cat > /root/prometheusd/run <<EOF 
#!/bin/bash
exec 2>&1
exec $HOME/prometheus/prometheus --config.file="$HOME/prometheus/prometheus.yml
EOF
chmod +x /root/prometheusd/run
LOG=/var/log/prometheusd
cat > /root/prometheusd/log/run <<EOF 
#!/bin/bash
mkdir $LOG
exec svlogd -tt $LOG
EOF
chmod +x /root/prometheusd/log/run
ln -s /root/prometheusd /etc/service
#----------------------------------------------------
