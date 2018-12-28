#!/bin/bash

read INFO  #请求格式：websocket.send("/stock/stockMarket/baseInfo?code=000001.SHI")

#cmd定义
RedisCli="redis-cli"
Curl="curl"

#输出日志
HQ_CONNECTER_DEBUG=1
function log(){
	if [ "$HQ_CONNECTER_DEBUG" -ne "1" ];then
		 return 
	fi

	d=`date +%Y%m%d`
	echo $1 >> ./hq_connecter_$d.log
	return
}

#获取行情
function getHQ(){
	time=`date +%s`
	let timeKey=$time/3 #间隔3秒取一次数据
	url=$1
	urlmd5=`echo $url|md5`
	timeKey="$urlmd5::$timeKey"
	
	while true;
	do
		data=`$RedisCli get $timeKey`
		if [ -n "$data" ] ;then
			log "去cache取信息：$timeKey"
			break
		fi

		r=`$RedisCli setnx $timeKey"_lock" 1`
		#log "$RedisCli setnx $timeKey"_lock" 1"
		$RedisCli expire $timeKey_lock 10 > /dev/null
		if [ "$r" = "0" ] ; then 
			log "9999"
			sleep 0.1
			continue
		fi

  		data=`$Curl $url -s `
  		log "去server取信息：$timeKey $url"
  		$RedisCli set $timeKey $data > /dev/null
  		$RedisCli expire $timeKey 5 > /dev/null
	  
	done

	echo $data
}

#输出行情
for ((COUNT = 1; COUNT <= 1000000; COUNT++)); do
	log "---------------------------------------------------"
	url="http://mt.tougub.com/$INFO"
 	data=`getHQ $url`
 	echo $data
 	n=${#data}
  	log "内容长度：$n"

  	
  	#echo $ACT,$CODE,$timeKey
  	sleep 1
done
