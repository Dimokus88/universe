git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
pwd
sleep 10
sudo make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
