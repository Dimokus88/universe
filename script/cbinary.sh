git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
pwd
whoami
sleep 5
make
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
