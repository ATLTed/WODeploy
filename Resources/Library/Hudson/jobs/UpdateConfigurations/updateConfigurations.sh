#!/bin/bash
#
CONFIG_DIRS=( Library usr )
cd /tmp 
rm -fr tmp_downloads;mkdir tmp_downloads;cd tmp_downloads

THE_DIR=Library

for CONFIG_DIR in ${CONFIG_DIRS[@]}; do
  		svn checkout --username hudson --password wolips http://woserver.archtransco.com/svn/Configurations/trunk/Resources/${CONFIG_DIR} ${CONFIG_DIR}
		rsync -avx ${CONFIG_DIR} /${CONFIG_DIR}
done

rm -fr tmp_downloads