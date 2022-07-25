wget -o $folder.zip $gitrep
unzip $folder.zip
cd $gitfold
sudo make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
