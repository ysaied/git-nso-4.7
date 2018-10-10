#! /bin/bash



sudo rm -rf /var/tmp/*
sudo rm -rf ~/ncs-4.7
sudo rm -rf ~/ncs-run
mkdir /var/tmp/ncs-downloads
mkdir ~/ncs-4.7
NCS_DIR="/home/admin/ncs-4.7"
mkdir ~/ncs-4.7/packages
mkdir ~/ncs-run
mkdir ~/ncs-run/packages

cp ~/ncs-4.7.1-cisco-ios-6.4.1.signed /var/tmp/ncs-downloads/

function install_ned()
{
	(cd /var/tmp/ncs-downloads && sh $2) > /dev/null
	(cd /var/tmp/ncs-downloads && tar -xf $3) > /dev/null
	(cp -r /var/tmp/ncs-downloads/$1 $NCS_DIR/packages) > /dev/null
	(cd $NCS_DIR/packages/$1/src && make) > /var/tmp/make-$1
    (cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/$1)
	if grep -q "Nothing to be done" /var/tmp/make-$1
	then
    	echo "$1 NED compiled successfully :-)"
	else
		echo "$1 NED compilation failed :-("
	fi
}

install_ned "cisco-ios" "ncs-4.7.1-cisco-ios-6.4.1.signed" "ncs-4.7.1-cisco-ios-6.4.1.tar.gz"


