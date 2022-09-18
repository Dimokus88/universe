#!/bin/bash
signed_blocks_window=`$binary query slashing params --node "$SNAP_RPC" -o json | jq -r .signed_blocks_window`
min_signed_per_window=`$binary query slashing params --node "$SNAP_RPC" -o json | jq -r .min_signed_per_window | awk '{printf("%.2f\n",$1)}' | sed "s/0.//"`
let downtime_jail_duration=`$binary query slashing params --node "$SNAP_RPC" -o json | jq -r .downtime_jail_duration | sed "s/s//"`/60
slash_fraction_double_sign=`$binary query slashing params --node "$SNAP_RPC" -o json | jq -r .slash_fraction_double_sign | awk '{printf("%.2f\n",$1)}' | sed "s/0.0//"`
slash_fraction_downtime=`$binary query slashing params --node "$SNAP_RPC" -o json | jq -r .slash_fraction_downtime | awk '{printf("%.2f\n",$1)}' | sed "s/0.0//"`

echo Signed blocks window: $signed_blocks_window > /root/bot/tmp/slash_info.txt
echo Min signed per window: $min_signed_per_window%  >> /root/bot/tmp/slash_info.txt
echo Downtime jail duration: $downtime_jail_duration minutes >> /root/bot/tmp/slash_info.txt
echo Slash fraction double sign: $slash_fraction_double_sign% >> /root/bot/tmp/slash_info.txt
echo Slash fraction downtime: $slash_fraction_downtime% >> /root/bot/tmp/slash_info.txt
