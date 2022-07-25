wget -o $folder.zip $gitrep
ls
unzip $vers.zip
ls
cd $vers
sudo make install
mv ~/go/bin/$binary /usr/local/bin/$binary
$binary version
