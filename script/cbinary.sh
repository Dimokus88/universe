#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
sudo make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
