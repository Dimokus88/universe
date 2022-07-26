source $HOME/.bashrc
if [[ $autodelegate == yes ]]
	then
		source $HOME/.bashrc
		balance=`$binary q bank balances $address -o json | jq -r .balances[].amount `
		echo 'export balance='${balance} >> $HOME/.bashrc
		balance=`printf "%.f \n" $balance`
		echo =================================================
		echo ===============Balance check...==================
		echo =================================================
		echo =================================================
		echo =============Проверка баланса...=================
		echo =================================================
		echo =========================
		echo ==Ваш баланс: $balance ==
		echo = Your balance $balance =
		echo =========================
		sleep 5
		source $HOME/.bashrc
		if [[ `echo $balance` -gt 1000000 ]]
		then
			echo ======================================================================
			echo ============Balance = $balance . Delegate to validator================
			echo ======================================================================
			echo ======================================================================
			echo =============Баланс = $balance . Делегирую валидатору=================
			echo ======================================================================
			stake=$(($balance-500000))
			echo 'export stake='${stake} >> $HOME/.bashrc
			(echo ${PASSWALLET}) | $binary tx staking delegate $valoper ${stake}`echo $denom` --from $address --chain-id $chain --gas="auto" --fees 5555$denom -y
			sleep 5
			stake=0
			balance=0
			echo 'export stake='${stake} >> $HOME/.bashrc
			echo 'export balance='${balance} >> $HOME/.bashrc
			source $HOME/.bashrc
		fi
	else	
		echo ===========================================================
		echo =============== auto-delegation disabled ==================
		echo ===============автоделегирование отключено=================
		echo ===========================================================
	fi
