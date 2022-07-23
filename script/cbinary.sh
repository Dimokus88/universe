git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
pwd
sleep 5
sudo make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
