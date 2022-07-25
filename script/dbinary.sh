wget -o $folder.zip $gitrep
ls
unzip $folder.zip
ls
cd $gitfold
sudo make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
