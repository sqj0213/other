#!/bin/sh
#日志推送程序
#作者：孙全军
#时间：20140724 19:06
#功能：推送手机微博日志到业务方

function help()
{
	echo "参数错误：\n"
	echo "/bin/sh ./pushLog.sh v4 category rsyncAddr date hour"
	echo "example: /bin/sh ./pushLog.sh v4 mweibo_newUser r2.data.sina.com.cn::PSO/bushu 20140719 01"
	exit
}


function getLocalPath()
{
	categoryList=(weibo_activation weibo_search_log weibo_common_http weibo_newUser weibo_admob weibo_imei lbs_passive weibo_httplog weibo_huatiAction weibo_common_act weibo_imei_install weibo_imei_active weibo_guest2account weibo_page_visit weibo_apache_access weibo_webInf www_weibomobile03x4ts1kl_mweibo device_info mweibo_feedexpo_mobi)
	v4fileList=(/data1/sinawap/var/logs/wapcommon/ttt/activation__Y__M__D_.log /data1/sinawap/var/logs/wapcommon/ttt/search_log__Y__M__D_.log __nouse__ /data1/sinawap/var/logs/wapcommon/ttt/_Y_/_M_/_D_/newUser__H_.log /data1/sinawap/var/logs/wapcommon/ttt/_Y_/_M_/_D_/admob__H_.log /data1/sinawap/var/logs/wapcommon/ttt/api_log_minfo__Y__M__D_.log /data1/sinawap/var/logs/wapcommon/ttt/clientad_lbs__Y__M__D_.log __nouse__ /data1/sinawap/var/logs/wapcommon/ttt/_Y_/_M_/_D_/huatiAction__H_.log /data1/sinawap/var/logs/wapcommon/ttt/_Y_/_M_/_D_/act__H_.log /data1/sinawap/var/logs/wapcommon/ttt/imei__Y__M__D_.log /data1/sinawap/var/logs/wapcommon/ttt/api_log_push_minfo__Y__M__D_.log /data1/sinawap/var/logs/wapcommon/ttt/guest2account__Y__M__D_.log /data1/sinawap/var/logs/wapcommon/ttt/page_visit__Y__M__D_.log __nouse__ /data1/sinawap/var/logs/wapcommon/ttt/_Y_/_M_/_D_/webInf__H_.log /data1/sinawap/logs/apache/access/3g/_Y_/_M_/_D_/_H_/default.log /data1/sinawap/var/logs/wapcommon/ttt/api_log_check_install__Y__M__D_.log __nodata__)
	v5fileList=(/data1/v5.weibo.cn/logs/ttt/weibo_activation__Y__M__D_.log /data1/v5.weibo.cn/logs/ttt/weibo_search_log__Y__M__D_.log __nouse__ /data1/v5.weibo.cn/logs/ttt/_Y_/_M_/_D_/weibo_newUser__H_.log /data1/v5.weibo.cn/logs/ttt/_Y_/_M_/_D_/weibo_admob__H_.log /data1/v5.weibo.cn/logs/ttt/weibo_imei__Y__M__D_.log /data1/v5.weibo.cn/logs/ttt/lbs_passive__Y__M__D_.log __nouse__ /data1/v5.weibo.cn/logs/ttt/_Y_/_M_/_D_/weibo_huatiAction__H_.log /data1/v5.weibo.cn/logs/ttt/_Y_/_M_/_D_/weibo_common_act__H_.log /data1/v5.weibo.cn/logs/ttt/weibo_imei_install__Y__M__D_.log /data1/v5.weibo.cn/logs/ttt/weibo_imei_active__Y__M__D_.log /data1/v5.weibo.cn/logs/ttt/weibo_guest2account__Y__M__D_.log /data1/v5.weibo.cn/logs/ttt/weibo_page_visit__Y__M__D_.log __nouse__ /data1/v5.weibo.cn/logs/ttt/_Y_/_M_/_D_/weibo_webInf_v5__H_.log /data1/v5.weibo.cn/logs/nginx/access/_Y_/_M_/_D_/_H_/api.v5.weibo.cn.log /data1/v5.weibo.cn/logs/ttt/device_info__Y__M__D_.log __nodata__)
	i=0
	category=$1
	date=$2
	Y=${date:0:4}
	M=${date:4:2}
	D=${date:6:2}
	H=$3
	version=$4

	index=0
	retValue=""
	for val in ${categoryList[@]}
	do
		if [ "X${val}" = "X${category}" ]; then
			let "index=$i"
			if [ "${version}" = "v4" ]; then
				retValue=${v4fileList[$index]}
			else
				retValue=${v5fileList[$index]}
			fi
			retValue=${retValue/_Y_/$Y}
			retValue=${retValue/_M_/$M}
			retValue=${retValue/_D_/$D}
			retValue=${retValue/_H_/$H}
		fi
		let "i=$i+1"
	done
	echo "$retValue"
}

function pushLog()
{
	ipaddress=$(/sbin/ifconfig eth0|grep "inet addr"|awk '{print $2}'|cut -d: -f2)
	localPath=$1
	rsyncAddr=$2
	category=$3
	hour=$4
	filename=${localPath##*/}
	if [ "${filename}" = "default.log" -o "${filename}" = "api.v5.weibo.cn.log" ]; then
		remoteLog="${filename%.*}_${hour}.log"
	else
		remoteLog="$filename"
	fi
	if [ -f "${localPath}" ]; then
		#用来创建子目录
		#echo "rsync -av /tmp/11qazxsw23edc.txt $rsyncAddr/$category/"
		rsync -av /tmp/11qazxsw23edc.txt $rsyncAddr/$category/
		#用来创建ip地址
		#echo "rsync -av /tmp/11qazxsw23edc.txt $rsyncAddr/$category/$ipaddress/"
		rsync -av /tmp/11qazxsw23edc.txt $rsyncAddr/$category/$ipaddress/
		#推送文件
		#echo "rsync -av $localPath $rsyncAddr/$category/$ipaddress/$remoteLog"
		rsync -av $localPath $rsyncAddr/$category/$ipaddress/$remoteLog
	else
		echo "file is not exists:${localPath}"
	fi
}
if [ $# -lt 3 ]; then
	help
	exit 1
fi
version=$1
category=$2
rsyncAddr=$3
date=$4
hour=$5
echo "log version:$version"
echo "category:$category"
echo "rsyncAddr:$rsyncAddr"
echo "date:$date"
echo "hour:$hour"
echo ${categoryList[@]} echo ${fileList[@]}
localPath=$(getLocalPath $category $date $hour $version)
echo $localPath
pushLog $localPath $rsyncAddr $category $hour
