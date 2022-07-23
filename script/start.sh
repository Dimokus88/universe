#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
(echo ${my_root_password}; echo ${my_root_password}) | passwd root
service ssh restart
service nginx start
sleep 5
sudo apt-get install -y nano runit
runsvdir -P /etc/service &
source $HOME/.bash_profile

