#!/bin/bash
#Script that downloads and installs hudson/tomcat
#

APP_DIR=/usr/local


#Get the Tomcat URL
TOMCAT_URL=`curl -s http://tomcat.apache.org/download-60.cgi | grep '.tar.gz\"' | grep -v 'src' | grep -v 'deployer' | head -1 | perl -lne 'print $1 if /<a href="(.*?)">/i;'`
TOMCAT=`echo ${TOMCAT_URL} | perl -lne 'print $1 if /(apache-tomcat-(.*).tar.gz)$/;'`
TOMCAT_DIR=`echo ${TOMCAT_URL} | perl -lne 'print $1 if /(apache-tomcat-(.*)).tar.gz$/;'`



#Download Tomcat
echo "Downloading Tomcat"
cd /tmp/
curl ${TOMCAT_URL} -# -o ${TOMCAT}
tar xfz ${TOMCAT}

#Download Hudson
echo "Downloading Hudson"
cd /tmp/
curl http://hudson-ci.org/latest/hudson.war -L -# -o hudson.war


echo "Installing Tomcat"
if [ -a ${APP_DIR}/tomcat/bin/launchd_tomcat.sh ]; then cp ${APP_DIR}/tomcat/bin/launchd_tomcat.sh /tmp/; fi
rm -fr ${APP_DIR}/tomcat-old
if [ -a ${APP_DIR}/tomcat ]; then mv ${APP_DIR}/tomcat ${APP_DIR}/tomcat-old; fi
mv ${TOMCAT_DIR} ${APP_DIR}/tomcat
rm -fr /Library/Application\ Support/Tomcat
ln -s -f ${APP_DIR}/tomcat /Library/Application\ Support/Tomcat
if [ -a /tmp/launchd_tomcat.sh ]; then mv /tmp/launchd_tomcat.sh ${APP_DIR}/tomcat/bin/; fi

echo "Installing Hudson"
cp hudson.war ${APP_DIR}/tomcat/webapps/
echo "Starting Tomcat..."
launchctl stop org.apache.tomcat
launchctl unload /Library/LaunchDaemons/org.apache.tomcat.plist
launchctl load /Library/LaunchDaemons/org.apache.tomcat.plist
launchctl start org.apache.tomcat
#${APP_DIR}/tomcat/bin/startup.sh
