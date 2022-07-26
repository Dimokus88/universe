#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
source $HOME/.bashrc
wget -O /var/www/html/priv_validator_key.json ${LINK_KEY}
file=/var/www/html/priv_validator_key.json
source $HOME/.bashrc

if  [[ -f "$file" ]]
then
	cd /
	rm /root/$folder/config/priv_validator_key.json
	echo ==========priv_validator_key found==========
	echo ========Обнаружен priv_validator_key========
	cp /var/www/html/priv_validator_key.json /root/$folder/config/
	echo ========Validate the priv_validator_key.json file=========
	echo ==========Сверьте файл priv_validator_key.json============
	cat /root/$folder/config/priv_validator_key.json
else
	echo =====================================================================
	echo =========== priv_validator_key not found, making a backup ===========
	echo =====================================================================
	echo =====================================================================
	echo ====== priv_validator_key не обнаружен, создаю резервную копию ======
	echo =====================================================================
	sleep 2
	cp /root/$folder/config/priv_validator_key.json /var/www/html/
	echo =========================================================================================
	echo = priv_validator_key has been created! Save the output to a .json file on google drive. =
	echo == Place a direct link to download the file in the manifest and update the deployment! ==
	echo ==================================Work has been suspended!===============================
	echo =========================================================================================
	echo = priv_validator_key создан! Сохраните вывод в файл с расширением .json на google диск. =
	echo ==== Разместите прямую ссылку на скачивание файла в манифесте и обновите деплоймент! ====
	echo ====================================Работа приостановлена!===============================
	cat /root/$folder/config/priv_validator_key.json
	sleep infinity
fi
