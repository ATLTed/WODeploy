#!/bin/bash
DO_DOWNLOAD="false"
WONDER="Wonder-latest-Frameworks-54.tar.gz"
PREVIOUS_WONDER="Wonder-latest-Frameworks-54.tar.gz.previous"
HUDSON_LOCATION=/Library/Hudson/Dependencies
FRAMEWORKS_LOCATION=/Library/Frameworks
WEBSERVER_LOCATION=/Library/WebServer/Documents/WebObjects/Frameworks

while getopts d o
do	case "$o" in
	d) DO_DOWNLOAD="false";;
	[?])	echo >&2 -e "Usage: $0 \n\t[-d Don't download files (Default =  true] "
		exit 1;;
	esac
done

echo "Upgrading the Wonder Frameworks"

#
#Download the latest build of the Wonder Frameworks
#
if [ ${DO_DOWNLOAD} == "true" ]; then
	echo "Downloading the Wonder Frameworks"
	cd /tmp
	rm -f ${WONDER}
	curl http://webobjects.mdimension.com/hudson/job/Wonder54/lastSuccessfulBuild/artifact/dist/Wonder-Frameworks.tar.gz -L -# -o  ${WONDER}
else
	echo "Skiping Download"
fi


#
#Install The Wonder Frameworks in Hudson/Dependencies
#
echo "Installing the Wonder Frameworks in Hudson/Dependencies"
cd ${HUDSON_LOCATION}
if [ ${DO_DOWNLOAD} == "true" ]; then 
	rm -f ${PREVIOUS_WONDER}
	if [ -a ${WONDER} ]; then mv -f ${WONDER} ${PREVIOUS_WONDER};fi
	mv /tmp/${WONDER} ${WONDER}
fi


#
#Install The Wonder Frameworks in /Library/Frameworks
#
echo "Installing the Wonder Frameworks in /Library/Frameworks"
cd ${FRAMEWORKS_LOCATION}
if [ ${DO_DOWNLOAD} == "true" ]; then 
	rm -f ${PREVIOUS_WONDER}
	if [ -a ${WONDER} ]; then mv -f ${WONDER} ${PREVIOUS_WONDER};fi
	cp ${HUDSON_LOCATION}/${WONDER} ${FRAMEWORKS_LOCATION}/${WONDER}
	FRAMEWORKS_TO_DELETE=${PREVIOUS_WONDER}
else
	FRAMEWORKS_TO_DELETE=${WONDER}
fi

echo "Removing the old Frameworks"
if [ -a ${FRAMEWORKS_TO_DELETE} ]
	then
	for vFRAMEWORK in `tar -ztf ${FRAMEWORKS_TO_DELETE} | grep '.framework/$'`
	do
  		exec `rm -rf $vFRAMEWORK`
	done
fi
echo "Installing the new Frameworks"
tar xfz ${WONDER}

#
#Install The Wonder Frameworks WebServer Resources
#
echo "Installing the Wonder Frameworks WebServer Resources"
if [ ! -d ${WEBSERVER_LOCATION} ]; then mkdir ${WEBSERVER_LOCATION}; fi
cd ${WEBSERVER_LOCATION}
if [ ${DO_DOWNLOAD} == "true" ]; then
	rm -f ${PREVIOUS_WONDER}
	if [ -a ${WONDER} ]; then mv -f ${WONDER} ${PREVIOUS_WONDER};fi
	cp ${HUDSON_LOCATION}/${WONDER} ${WEBSERVER_LOCATION}/${WONDER} 
	FRAMEWORKS_TO_DELETE=${PREVIOUS_WONDER}
else
	FRAMEWORKS_TO_DELETE=${WONDER}
fi

echo "Removing the old Frameworks WebServer Resources"
if [ -a ${FRAMEWORKS_TO_DELETE} ]
	then
	for vFRAMEWORK in `tar -ztf ${FRAMEWORKS_TO_DELETE} | grep '.framework/$'`
	do
  		exec `rm -rf $vFRAMEWORK`
	done
fi
echo "Installing the new Frameworks WebServer Resources"
tar xfz ${WONDER} --wildcards --no-anchored '*.framework/WebServerResources'
chown -R apache:apache ${WEBSERVER_LOCATION}


exit 0;
