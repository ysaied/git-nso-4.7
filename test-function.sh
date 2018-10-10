#! /bin/bash


pkill ncs
if [ -d $HOME/nso-tmp ]; then sudo rm -r $HOME/nso-tmp && echo "nso-tmp directory deleted"; fi
if [ -d $HOME/nso-4.7 ]; then sudo rm -r $HOME/nso-4.7 && echo "nso-4.7 directory deleted"; fi
if [ -d $HOME/nso-run ]; then sudo rm -r $HOME/nso-run && echo "nso-run directory deleted"; fi
if [ -d $HOME/ncs-4.7 ]; then sudo rm -r $HOME/ncs-4.7 && echo "ncs-4.7 directory deleted"; fi
if [ -d $HOME/ncs-run ]; then sudo rm -r $HOME/ncs-run && echo "ncs-run directory deleted"; fi
if [ -f ~/.bash_aliases ]; then sudo rm ~/.bash_aliases && echo "bash_aliases file deleted"; fi
touch /var/tmp/test; sudo rm -r /var/tmp/*

mkdir  /var/tmp/ncs-downloads

echo "Downloading NSO 4.7"
wget -q --show-progress --no-check-certificate -O /var/tmp/ncs-downloads/ncs-4.7.1-cisco-ios-6.4.1.signed -L https://cisco.box.com/shared/static/z7uyxa9152brxnp2im0s1ujol3jj4l6x.bin > /dev/null


function install_ned()
{
(cd /var/tmp/var/tmp/ncs-downloads && sh $1) > /dev/null
(cd /var/tmp/ncs-downloads && tar -xf $2) > /dev/null
(cp -r /var/tmp/ncs-downloads/$3 $NCS_DIR/packages) > /dev/null
(cd $NCS_DIR/packages/$3/src && make) > /var/tmp/ned-$3
(cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/$3)
if grep -q "Nothing to be done" /var/tmp/ned-$3
then
    echo "$3 NED compiled successfully :-)"
else
	echo "$3 NED compilation failed :-("
fi

}

install_ned