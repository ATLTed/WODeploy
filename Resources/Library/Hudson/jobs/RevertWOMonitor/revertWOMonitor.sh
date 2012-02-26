#!/bin/bash

DO_DOWNLOAD="true"
WEBSERVER_LOCATION=/Library/WebServer/Documents/WebObjects
WEBOBJECTS_LOCATION=/Library/WebObjects/Applications

echo "Downgrading WOMonitor and WOTaskd..."

cd ${WEBOBJECTS_LOCATION}

#
#Install WOMonitor
#
echo "Installing the previous WOMonitor"
WOMONITOR_APP="JavaMonitor.woa"
WOMONITOR="${WOMONITOR_APP}.tar.gz"
PREVIOUS_WOMONITOR="${WOMONITOR_APP}.tar.gz.previous"
if [ -a ${PREVIOUS_WOMONITOR} ]; then 
	rm -fr ${WOMONITOR_APP}
	rm -fr ${WOMONITOR}-tmp
	mv -f ${WOMONITOR} ${WOMONITOR}-tmp 
	mv -f ${PREVIOUS_WOMONITOR} ${WOMONITOR}
	mv -f ${WOMONITOR}-tmp ${PREVIOUS_WOMONITOR}
	tar xfz ${WOMONITOR}
	#Add Rewrite Rule
	REWRITE_RULE="\n\ner.extensions.ERXApplication.replaceApplicationPath.pattern=/cgi-bin/WebObjects/${WOMONITOR_APP}\ner.extensions.ERXApplication.replaceApplicationPath.replace=/WOMonitor\n"=
	echo -e ${REWRITE_RULE} >> ${WOMONITOR_APP}/Contents/Resources/Properties
	#Fix Permissions
	chown -R _appserver:_appserveradm ${WOMONITOR_APP}
fi

#
#Install WOTaskD
#
echo "Installing the previous wotaskd"
WOTASKD_APP="wotaskd.woa"
WOTASKD="${WOTASKD_APP}.tar.gz"
PREVIOUS_WOTASKD="${WOTASKD_APP}.tar.gz.previous"
if [ -a ${PREVIOUS_WOTASKD} ]; then 
	rm -fr ${WOTASKD_APP}
	rm -f ${WOTASKD}-tmp
	mv -f ${WOTASKD} ${WOTASKD}-tmp
	mv -f ${PREVIOUS_WOTASKD} ${WOTASKD}
	mv -f ${WOTASKD}-tmp ${PREVIOUS_WOTASKD}
	tar xfz ${WOTASKD}
	#Make sure SpawnOfWotaskd.sh/javawoservice.sh are executable
	chmod a+x ${WOTASKD_APP}/Contents/Resources/SpawnOfWotaskd.sh
	chmod a+x ${WOTASKD_APP}/Contents/Resources/javawoservice.sh
	#Fix Permissions
	chown -R _appserver:_appserveradm ${WOTASKD_APP}
fi

#
#Instal WOMonitor WebServer Resources
#
echo "Installing the previous WOMonitor WebServer Resources"
cd ${WEBSERVER_LOCATION}
if [ -a ${PREVIOUS_WOMONITOR} ]; then 
	rm -fr ${WOMONITOR_APP}
	tar -xzf ${WEBOBJECTS_LOCATION}/${WOMONITOR} ${WOMONITOR_APP}/Contents/WebServerResources/*
	#Fix Permissions
	chown -R apache:apache ${WOMONITOR_APP}
fi

#
#Restart wotaskd
echo "Restarting WOTaskd"
sudo launchctl stop com.webobjects.wotaskd

exit 0;
