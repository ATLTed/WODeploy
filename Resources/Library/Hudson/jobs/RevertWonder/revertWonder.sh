#!/bin/bash
DO_DOWNLOAD="true"
WONDER="Wonder-latest-Frameworks-54.tar.gz"
PREVIOUS_WONDER="Wonder-latest-Frameworks-54.tar.gz.previous"
HUDSON_LOCATION=/Library/Hudson/Dependencies
FRAMEWORKS_LOCATION=/Library/Frameworks
WEBSERVER_LOCATION=/Library/WebServer/Documents/WebObjects/Frameworks

echo "Downgrading the Wonder Frameworks"

#
#Downgrading The Wonder Frameworks in Hudson/Dependencies
#
echo "Downgrading the Wonder Frameworks in Hudson/Dependencies"
cd ${HUDSON_LOCATION}
if [ -a ${PREVIOUS_WONDER} ]; then 
	rm -fr ${WONDER}-tmp
	mv -f ${WONDER} ${WONDER}-tmp 
	mv -f ${PREVIOUS_WONDER} ${WONDER}
	mv -f ${WONDER}-tmp ${PREVIOUS_WONDER}
	tar xfz ${WONDER}
fi

#
#Downgrading The Wonder Frameworks in /Library/Frameworks
#
echo "Downgrading the Wonder Frameworks in /Library/Frameworks"
cd ${FRAMEWORKS_LOCATION}
if [ -a ${PREVIOUS_WONDER} ]; then 
	rm -fr ${WONDER}-tmp
	mv -f ${WONDER} ${WONDER}-tmp 
	mv -f ${PREVIOUS_WONDER} ${WONDER}
	mv -f ${WONDER}-tmp ${PREVIOUS_WONDER}
	FRAMEWORKS_TO_DELETE=${PREVIOUS_WONDER}
	#tar xfz ${WONDER}
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
#Downgrading The Wonder WebServer Resources
#
echo "Downgrading the Wonder WebServer Resources"
cd ${WEBSERVER_LOCATION}
if [ -a ${PREVIOUS_WONDER} ]; then 
	rm -fr ${WONDER}-tmp
	mv -f ${WONDER} ${WONDER}-tmp 
	mv -f ${PREVIOUS_WONDER} ${WONDER}
	mv -f ${WONDER}-tmp ${PREVIOUS_WONDER}
	FRAMEWORKS_TO_DELETE=${PREVIOUS_WONDER}
	#tar xfz ${WONDER}
fi

echo "Removing the old Frameworks"
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
