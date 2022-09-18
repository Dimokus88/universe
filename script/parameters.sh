#!/bin/bash
txt="/root/bot/tmp/parameters.txt"
slash="/root/bot/tmp/slash.json"
stake="/root/bot/tmp/stake.txt"
#Slashing info
$binary query slashing params --node "$SNAP_RPC" -o json >> $slash
$binary query staking params --node "$SNAP_RPC" >> $stake
signed_blocks_window=`cat $slash | jq -r .signed_blocks_window`
min_signed_per_window=`cat $slash | jq -r .min_signed_per_window | awk '{printf("%.2f\n",$1)}' | sed "s/0.//"`
let downtime_jail_duration=`cat $slash | jq -r .downtime_jail_duration | sed "s/s//"`/60
slash_fraction_double_sign=`cat $slash | jq -r .slash_fraction_double_sign | awk '{printf("%.2f\n",$1)}' | sed "s/0.0//"`
slash_fraction_downtime=`cat $slash | jq -r .slash_fraction_downtime | awk '{printf("%.2f\n",$1)}' | sed "s/0.0//"`
#Staking info
echo Blockchain parameters: > $txt
echo  >> $txt
echo Staking: >> $txt
cat $stake | grep bond_denom | sed "s/_/ /" | sed "s/b/B/" >> $txt
cat $stake | grep historical_entries | sed "s/_/ /" | sed "s/h/H/" >> $txt
cat $stake | grep max_entries | sed "s/_/ /" | sed "s/m/M/" >> $txt
cat $stake | grep max_validators | sed "s/_/ /" | sed "s/m/M/" >> $txt
cat $stake | grep max_validators | sed "s/_/ /" | sed "s/m/M/" >> $txt
let unbonding_time=`$binary query staking params --node "$SNAP_RPC" -o json | jq -r .unbonding_time | sed "s/s//"`/60/60/24
echo "Unbonding time: $unbonding_time days" >> $txt
echo  >> $txt
echo Slashing: >> $txt
echo Signed blocks window: $signed_blocks_window >> $txt
echo Min signed per window: $min_signed_per_window%  >> $txt
echo Downtime jail duration: $downtime_jail_duration minutes >> $txt
echo Slash fraction double sign: $slash_fraction_double_sign% >> $txt
echo Slash fraction downtime: $slash_fraction_downtime% >> $txt
rm /root/bot/tmp/slash.json
rm /root/bot/tmp/stake.txt
