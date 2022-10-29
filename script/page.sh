#!/bin/bash
source root/.bashrc
echo ========================================================
echo ==== Доступ через WEB консоль к серверу по сссылке: ====
echo == Access via WEB console to the server via the link: ==
echo ===== $ACCESS_LINK =====!!!!!!!!!!!!!!!!!!!!
echo ========================================================
rm /var/www/html/index.nginx-debian.html
cat > /var/www/html/index.html <<EOF 
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="refresh" content="0;URL="$ACCESS_LINK"" />
</head>
</html>
EOF
service nginx start
