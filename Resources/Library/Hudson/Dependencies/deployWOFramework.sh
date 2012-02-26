#!/bin/bash
# Call this from Hudson to deploy a build on the same server
# This script assumes you are archiving the .tar.gz files

THE_APP_NAME=${JOB_NAME}
THE_HOST_NAME=`hostname`
WEBAPP_LOCATION=/Library/Frameworks
WEBSERVER_LOCATION=/Library/WebServer/Documents/WebObjects/Frameworks

if [ -z ${JOB_NAME} ] ; then
	JOB_NAME="\$JOB_NAME"
fi

while getopts a:h:p:P:A:W:s o
do	case "$o" in
	a) THE_APP_NAME="$OPTARG";;
	h) THE_HOST_NAME="$OPTARG";;
	p) JAVAMONITOR_PW="$OPTARG";;
	P) JAVAMONITOR_PORT="$OPTARG";;
	s) HTTP="https";;
	[?])	echo >&2 -e "Usage: $0 \n\t[-a App Name (Default =  ${JOB_NAME})] \n\t[-h Host Name (Default = ${THE_HOST_NAME})] \n\t[-p JavaMonitor Password] \n\t[-P JavaMonitor Port (Default = 56789)] \n\t[-s (JavaMonitor will use https instead http)] \n\t[-A App Location (Default = /Library/WebObjects/Applications)] \n\t[-W Web Doc Location (Default = /Library/WebServer/Documents/WebObjects)]"
		exit 1;;
	esac
done



echo -e "\n"
echo -e "deploy:\n"
echo "Starting ${THE_APP_NAME}.framework deployment on ${THE_HOST_NAME}"
##############
# Copy the new framework
##############
# Remove the old tar.gz just in case
rm -f ${WEBAPP_LOCATION}/${THE_APP_NAME}.tar.gz

# Copy the fresh tar.gz from the archive to the WO app folder
echo "Copying ${THE_APP_NAME}.tar.gz to Frameworks"
cp ${WORKSPACE}/../builds/${BUILD_NUMBER}/archive/dist/${THE_APP_NAME}.tar.gz ${WEBAPP_LOCATION}/ 

# Remove the previous backup
rm -f -r ${WEBAPP_LOCATION}/${THE_APP_NAME}_old.framework

# Move the current .framework to the newest backup (if it exists)
echo "Backing up the old framework to ${THE_APP_NAME}_old.framework"
if [ -d ${WEBAPP_LOCATION}/${THE_APP_NAME}.framework ] ; then
  mv -f ${WEBAPP_LOCATION}/${THE_APP_NAME}.framework ${WEBAPP_LOCATION}/${THE_APP_NAME}_old.framework
fi

# Untar the app
echo "Untarring ${THE_APP_NAME}.tar.gz"
cd ${WEBAPP_LOCATION}/
tar -xzf ${WEBAPP_LOCATION}/${THE_APP_NAME}.tar.gz

# Fix permissions
#chown -R _appserver:_appserveradm ${WEBAPP_LOCATION}/${THE_APP_NAME}.framework


# Remove the .tar.gz 
rm -f ${WEBAPP_LOCATION}/${THE_APP_NAME}.tar.gz


##############
# Copy the new app's web server resources.
##############

# Remove the old tar.gz just in case
rm -f ${WEBSERVER_LOCATION}/${THE_APP_NAME}-WebServerResources.tar.gz

# Copy the fresh tar.gz from the archive to the WO app folder
echo "Copying ${THE_APP_NAME}-WebServerResources.tar.gz to WebServer Documents"
cp ${WORKSPACE}/../builds/${BUILD_NUMBER}/archive/dist/${THE_APP_NAME}.tar.gz ${WEBSERVER_LOCATION}/ 

# Remove the previous backup
rm -f -r ${WEBSERVER_LOCATION}/${THE_APP_NAME}_old.framework

# Move the current .framework to the newest backup
echo "Backing up the old webserver resources to ${THE_APP_NAME}_old.framework"
if [ -d ${WEBSERVER_LOCATION}/${THE_APP_NAME}.framework ] ; then
  mv -f ${WEBSERVER_LOCATION}/${THE_APP_NAME}.framework ${WEBSERVER_LOCATION}/${THE_APP_NAME}_old.framework
fi

# Untar the app
echo "Untarring ${THE_APP_NAME}.tar.gz"
cd ${WEBSERVER_LOCATION}/
tar -xzf ${WEBSERVER_LOCATION}/${THE_APP_NAME}.tar.gz

# Fix permissions
#chown -R apache:apache ${WEBSERVER_LOCATION}/${THE_APP_NAME}.framework

# Remove the .tar.gz 
rm -f ${WEBSERVER_LOCATION}/${THE_APP_NAME}.tar.gz
rm -f -r ${WEBSERVER_LOCATION}/${THE_APP_NAME}.framework/Resources

echo "${THE_APP_NAME}.framework succesfully deployed"
echo -e "\n\n"

exit 0;
