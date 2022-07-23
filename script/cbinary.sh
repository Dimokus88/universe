#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
ver="1.18.1" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
mkdir -p /root/go/bin/
cd /root/
git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
pwd
sleep 10
sudo make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
