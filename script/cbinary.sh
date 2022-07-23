git clone $gitrep && cd $gitfold
echo $vers
sleep 5
git checkout $vers
pwd
sleep 10
bash ./configure --prefix=$HOME
bash ./make
bash ./make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
