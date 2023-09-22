#!/bin/bash
source ~/.bashrc
sed -i 's/worker_processes auto;/worker_processes 1;/g' /etc/nginx/nginx.conf
SYNC=`$BINARY status --node $AKASH_RPC_LADDR | jq .SyncInfo.catching_up`
while [[ "$SYNC" != "false" ]]
do
echo catching_up: $SYNC
sleep 1m
SYNC=`$BINARY status --node $AKASH_RPC_LADDR | jq .SyncInfo.catching_up`
tail /LOG
done
cat > /root/snapshot.sh <<EOF
#!/bin/bash
while true
do
sv stop $BINARY
rm /root/latest.tar.lz4
tar -cf - -C /root/$FOLDER --exclude=config . | lz4 -9 - /root/latest.tar.lz4
sv start $BINARY
echo "done!"
echo `date`
sleep 12h
done
EOF
chmod +x /root/snapshot.sh
mkdir -p /root/snap/log
cat > /root/snap/run <<EOF
#!/bin/bash
exec 2>&1
exec /root/snapshot.sh
EOF
mkdir -p /tmp/snap/log/
cat > /root/snap/log/run <<EOF
#!/bin/bash
exec svlogd -tt /tmp/snap/log/
EOF
chmod +x /root/snap/log/run /root/snap/run
ln -s /root/snap /etc/service && ln -s /tmp/snap/log/current /LOG_SNAP

cat > /etc/nginx/sites-available/default <<EOF
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	root /root/;
	index index.html index.htm index.nginx-debian.html;
	server_name _;
	location / {
		try_files $uri $uri/ =404;
	}
}
EOF
service nginx start

# Enable proposal monitoring
if [[ -n $WEBHOOKS ]]
then
	echo Включаю детектор пропозалов!
	wget -O /prop_detect.sh https://raw.githubusercontent.com/DecloudNodesLab/CodeBase/main/scripts/prop_detect.sh && chmod +x /prop_detect.sh
	mkdir -p /root/prop_detect/log
cat > /root/prop_detect/run <<EOF
#!/bin/bash
exec 2>&1
exec /prop_detect.sh
EOF
	mkdir -p /tmp/prop_detect/log/
cat > /root/prop_detect/log/run <<EOF
#!/bin/bash
exec svlogd -tt /tmp/prop_detect/log/
EOF
	chmod +x /root/prop_detect/log/run /root/prop_detect/run
	ln -s /root/prop_detect /etc/service && ln -s /tmp/prop_detect/log/current /PROP
fi
