@echo off
echo "[HISUN] Makesure install JDK 7.0+ and set the JAVA_HOME."
echo "[HISUN] Makesure install Maven 3.0+ and set the PATH."

set MVN=mvn
set MAVEN_OPTS=%MAVEN_OPTS% -Xmx1024m -XX:MaxPermSize=128M

(cd ../hisun-pom && call %MVN% clean install -Dmaven.test.skip=true)
&& (cd ../hisun-commons && call %MVN% clean install -Dmaven.test.skip=true)
&& ( cd ../hisun-base && call %MVN% clean install -Dmaven.test.skip=true)
& (cd ../hisun-sys && call %MVN% clean install -Pdevelop -Dmaven.test.skip=true)
& (cd ../hisun-zzb && call %MVN% clean install -Dmaven.test.skip=true)


cd ../hisun-aggregation
call %MVN% clean install -Phisun-zhzg -Dmaven.test.skip=true
if errorlevel 1 goto error

goto end
:error
echo Error Happen!!
:end
pause
