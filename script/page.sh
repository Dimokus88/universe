#!/bin/bash
source root/.bashrc
ACCESS
rm /var/www/html/index.nginx-debian.html
cat > /var/www/html/index.html <<EOF 
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="refresh" content="0;URL=$ACCESS_LINK" />
</head>
</html>
EOF
service nginx start
