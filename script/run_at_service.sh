#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
source $HOME/.bashrc
echo =Run node...=
cd /
mkdir /root/$binary
mkdir /root/$binary/log

cat > /root/$binary/run <<EOF 
#!/bin/bash
exec 2>&1
exec $binary start
EOF

chmod +x /root/$binary/run
LOG=/var/log/$binary
echo 'export LOG='${LOG} >> $HOME/.bashrc

cat > /root/$binary/log/run <<EOF 
#!/bin/bash
mkdir $LOG
exec svlogd -tt $LOG
EOF

chmod +x /root/$binary/log/run
ln -s /root/$binary /etc/service
source $HOME/.bashrc

