#!/bin/bash
# Call this from Hudson as the first build stage:
#
# /Path/to/Deps/setupWorkspace.sh "${WORKSPACE}" 53
#
# Expects a Deps folder that contains:
#     this script
#     WebObjects53 folder with System/Library/Frameworks, etc
#     WebObjects54 folder with the same (if you use 54)
#     Wonder-latest-Frameworks-53.tar.gz (unless you build Wonder in Hudson)
#     Wonder-latest-Frameworks-54.tar.gz (if you use 54, unless you build Wonder in Hudson)
#     woproject.jar (WOLips woproject.jar ant tasks)

WORKSPACE=$1
DEPS=`dirname $0`
WO_VERSION=$2
ROOT=$WORKSPACE/Root
WONDER=Wonder-latest-Frameworks-${WO_VERSION}.tar.gz
WOPROJECT=woproject.jar
JOB_ROOT=${WORKSPACE}/../..
echo 'Variables:'
echo ${DEPS}/${WONDER}
echo 'End Variables'
if [ "$WORKSPACE" == "" ]; then
	echo "You must provide a workspace setting."
	exit 1
fi

if [ "$WO_VERSION" == "" ]; then
	echo "You must provide a WO version."
	exit 1
fi

# Make sure the Libraries folder exists
mkdir -p ${WORKSPACE}/Libraries

# Setup System and Library
#rm -rf ${ROOT}
mkdir -p ${ROOT}
mkdir -p ${ROOT}/lib
cp ${DEPS}/${WOPROJECT} ${ROOT}/lib
rm -rf ${ROOT}/Library/Frameworks
mkdir -p ${ROOT}/Library/Frameworks
mkdir -p ${ROOT}/Library/WebObjects/Extensions
mkdir -p ${ROOT}/Network/Library/Frameworks
mkdir -p ${ROOT}/User/Library/Frameworks
rm ${ROOT}/System
ln -sf ${DEPS}/WebObjects${WO_VERSION}/System ${ROOT}/System

# Setup Wonder
# If you want to use the Wonder in Deps, use this:
(cd ${ROOT}/Library/Frameworks; tar xfz ${DEPS}/${WONDER})
# If you build Wonder in Hudson, use this:
#(cd ${ROOT}/Library/Frameworks; tar xfz ${JOB_ROOT}/Wonder/lastSuccessful/archive/dist/Wonder-*-Frameworks-${WO_VERSION}.tar.gz)

# Copy other frameworks from Hudson build folders based on .classpath entries -- if you don't build everything
# in Hudson, you will need to copy these in yourself
FRAMEWORKS=`cat ${WORKSPACE}/.classpath  | grep WOFramework/ | sed 's#.*WOFramework/\([^"]*\)"/>#\1#'`
for FRAMEWORK in $FRAMEWORKS; do
	if [ -e "${JOB_ROOT}/${FRAMEWORK}" ]; then
		(cd ${ROOT}/Library/Frameworks; tar xfz ${JOB_ROOT}/${FRAMEWORK}/lastSuccessful/archive/dist/${FRAMEWORK}.tar.gz)
	fi
done

# Setup ATL Frameworks
# Copy other frameworks from Hudson build folders based on .classpath entries -- if you don't build everything
# in Hudson, you will need to copy these in yourself
FRAMEWORKS=`cat ${WORKSPACE}/.classpath  | grep combineaccessrules | sed 's#.*path="/\([^"]*\)"/>#\1#'`
for FRAMEWORK in $FRAMEWORKS; do
	if [ -e "${JOB_ROOT}/${FRAMEWORK}" ]; then
		(cd ${ROOT}/Library/Frameworks; tar xfz ${JOB_ROOT}/${FRAMEWORK}/lastSuccessful/archive/dist/${FRAMEWORK}.tar.gz)
	fi
done

# Setup wolips.properties
cat >> ${ROOT}/wolips.properties << END
wo.system.root=${ROOT}/System
wo.user.frameworks=${ROOT}/User/Library/Frameworks
wo.system.frameworks=${ROOT}/System/Library/Frameworks
wo.bootstrapjar=${ROOT}/System/Library/WebObjects/JavaApplications/wotaskd.woa/WOBootstrap.jar
wo.network.frameworks=${ROOT}/Network/Library/Frameworks
wo.api.root=/Developer/ADC%20Reference%20Library/documentation/WebObjects/Reference/API/
wo.network.root=${ROOT}/Network
wo.extensions=${ROOT}/Library/WebObjects/Extensions
wo.user.root=${ROOT}/User
wo.local.frameworks=${ROOT}/Library/Frameworks
wo.apps.root=${ROOT}/Library/WebObjects/Applications
wo.local.root=${ROOT}
END

