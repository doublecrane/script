#file1 /opt/bin/apk_update.sh

#this script is used to update android phone apps automaticly.
#need android tools environment.

#written by double_crane at 20150418

#!/bin/bash

cp /opt/bin/app_map_list `pwd`
adb shell pm list packages |sed -n '1d;s/package:\(.*\)\r/\1/w app_list'
#\r是末尾的^M符号

cat app_list | while read line_app_com_name
	do
	#echo $line_app_com_name;
	#app_name = sed -n 's/$line:\(.*\)/\1/p' app_map_list
	app_name=`cat app_map_list| grep $line_app_com_name |awk '{print $2}'`
	if [ "$app_name" != "" ] ; then
		app_version=`adb shell dumpsys package $line_app_com_name|grep versionName|sed -n 's/versionName=\(.*\)\r/\1/p'`
		wget -q http://shouji.baidu.com/s?wd=$app_name -O webpage.html
		lastest_version=`cat webpage.html |grep -A1 -B2 $line_app_com_name|head -4|sed -n 's/data_versionname="\(.*\)"/\1/p'`
		if [ -n "$lastest_version" ] ; then
			echo +++++++++++++++++++++++++++++++++++++++++
			echo $app_name, $app_version, $lastest_version,
			echo +++++++++++++++++++++++++++++++++++++++++
			if [ $app_version != $lastest_version ] ; then
			#不能加双引号
			lastest_version_url=`cat webpage.html |grep -A1 -B2 $line_app_com_name|head -4|sed -n 's/data_url="\(.*\)"/\1/p'`
			wget -q $lastest_version_url -O "$app_name.apk"
			adb install -r $app_name.apk
			rm $app_name.apk
			echo update $app_name, primary version is $app_version, current version is $lastest_version;
			else
			echo $app_name is already update ,version is $lastest_version;
			fi
		else
		echo -----------------------------------------
		echo cannot find package $line_app_com_name $app_name in shouji.baidu.com
		echo -----------------------------------------
		fi
	else
	echo packge name $line_app_com_name not in app_map_list
	fi
	done
	rm app_list webpage.html app_map_list
