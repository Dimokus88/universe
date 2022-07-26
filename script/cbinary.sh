source $HOME/.bashrc
cd /root/
git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
pwd
whoami
sleep 5
sudo make build
cp $HOME/$gitfold/build/$binary /usr/local/bin/$binary
cp $HOME/go/bin/$binary /usr/local/bin/$binary
$binary version
