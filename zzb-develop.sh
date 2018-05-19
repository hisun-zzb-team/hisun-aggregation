#!/bin/bash

echo "[HISUN] Makesure install JDK 7.0+ and set the JAVA_HOME."
echo "[HISUN] Makesure install Maven 3.0+ and set the PATH."

export MAVEN_OPTS="$MAVEN_OPTS -Xmx1024m -XX:MaxPermSize=128M"

SEND_THREAD_NUM=13   #设置线程数，在这里所谓的线程，其实就是几乎同时放入后台（使用&）执行的进程。
tmp_fifofile="/tmp/$$.fifo" # 脚本运行的当前进程ID号作为文件名
mkfifo "$tmp_fifofile" # 新建一个随机fifo管道文件
exec 6<>"$tmp_fifofile" # 定义文件描述符6指向这个fifo管道文件
rm "$tmp_fifofile"
for ((i=0;i<$SEND_THREAD_NUM;i++));
do
    echo # for循环 往 fifo管道文件中写入13个空行
done >&6

echo "[Step 1] Install hisun-pom modules to local maven repository."
cd ../hisun-pom
mvn clean install -Dmaven.test.skip=true
if [ $? -ne 0 ];then
  echo "Quit  because hisun-pom install fail"
  exit -1
fi
echo "[Step 2] Install hisun-commons modules to local maven repository."
cd ../hisun-commons
mvn clean install -Dmaven.test.skip=true
if [ $? -ne 0 ];then
  echo "Quit  because hisun-commons install fail"
  exit -1
fi

echo "[Step 3] Install hisun-sys modules to local maven repository."
cd ../hisun-sys
mvn clean install -Pdevelop -Dmaven.test.skip=true
if [ $? -ne 0 ];then
  echo "Quit  because Platform install fail"
  exit -1
fi

echo "[Step 4] Install other modules to local maven repository."
read -u6 # 从文件描述符6中读取行（实际指向fifo管道)

{
cd ../hisun-zzb
mvn clean install -Dmaven.test.skip=true

if [ $? -ne 0 ];then
  echo "Quit  because hisun-zzb install fail"
  exit -1
fi
echo >&6 # 再次往fifo管道文件中写入一个空行。
}&


wait    #等到后台的进程都执行完毕。

exec 6>&- #删除文件描述符6

echo "[Step 5] Install all Aggregation to local maven repository."

cd ../hisun-aggregation
mvn -T 2C clean install -Phisun-zhzg -Dmaven.test.skip=true
