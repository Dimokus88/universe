cd /root/
git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
pwd
whoami
sleep 5
sudo make build
cp $HOME/$folders/build/$binary /usr/local/bin/$binary
$binary version
