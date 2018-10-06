#! /bin/bash

echo "##########################################"
echo "Welcome NSO Installation Script"
echo "##########################################"
echo ""
echo "Maintained by Yasser Saied (ysaied@cisco.com)
Revision 06-Oct-2018"

echo ""
echo "##########################################"
echo "Clean-Up"
echo "##########################################"
echo "" 

pkill ncs
if [ -d $HOME/nso-tmp ]; then sudo rm -r $HOME/nso-tmp && echo "nso-tmp directory deleted"; fi
if [ -d $HOME/nso-4.7 ]; then sudo rm -r $HOME/nso-4.7 && echo "nso-4.7 directory deleted"; fi
if [ -d $HOME/nso-run ]; then sudo rm -r $HOME/nso-run && echo "nso-run directory deleted"; fi
if [ -d $HOME/ncs-4.7 ]; then sudo rm -r $HOME/ncs-4.7 && echo "ncs-4.7 directory deleted"; fi
if [ -d $HOME/ncs-run ]; then sudo rm -r $HOME/ncs-run && echo "ncs-run directory deleted"; fi
if [ -f ~/.bash_aliases ]; then sudo rm ~/.bash_aliases && echo "bash_aliases file deleted"; fi
touch /var/tmp/test; sudo rm -r /var/tmp/*

echo ""
echo "##########################################"
echo "Downloading NSO"
echo "##########################################"
echo ""

mkdir  /var/tmp/ncs-downloads
echo "Downloading NSO 4.7 Main Software"
wget -q --show-progress --no-check-certificate -O /var/tmp/ncs-downloads/nso-4.7.linux.x86_64.signed.bin -L https://cisco.box.com/shared/static/sxuxink81v3klkwkjx2edbe9c5eekhyp.bin > /dev/null
ncs_fsize="$(wc -c </var/tmp/ncs-downloads/nso-4.7.linux.x86_64.signed.bin)"
if [ "$ncs_fsize" -ge "180000000" ]; then echo "NSO file downloaded successfully"; else echo "Failed downloading NSO file, exit script" && exit 1; fi 

echo ""
echo "Downloading Nokia ALU SR Package"
wget -q --show-progress --no-check-certificate -O /var/tmp/ncs-downloads/ncs-4.7-alu-sr-7.10.signed.bin -L https://cisco.box.com/shared/static/vq56lc76qoomyesqcgerk5sva0of6ehm.bin > /dev/null
alu_fsize="$(wc -c </var/tmp/ncs-downloads/ncs-4.7-alu-sr-7.10.signed.bin)"
if [ "$ncs_fsize" -ge "8000000" ]; then echo "NOKIA ALU SR Package downloaded successfully"; else echo "Failed downloading NOKIA ALU SR Package, exit script" && exit 1; fi 

echo ""
echo "Downloading Cisco Viptela SD-WAN vManage Package"
wget -q --show-progress --no-check-certificate -O /var/tmp/ncs-downloads/ncs-4.7-viptela-vmanage-1.2.2.signed.bin -L https://cisco.box.com/shared/static/dy15l1apk5c51bf2h69izf4p4f2v7uxg.bin > /dev/null
viptela_fsize="$(wc -c </var/tmp/ncs-downloads/ncs-4.7-viptela-vmanage-1.2.2.signed.bin)"
if [ "$ncs_fsize" -ge "1000000" ]; then echo "SD-WAN Viptela Package downloaded successfully"; else echo "Failed downloading SD-WAN Viptela Package, exit script" && exit 1; fi 



echo ""
echo "##########################################"
echo "Installing Linux Updates and NSO Dependencies .. that might take sometime depending on your internet connection"
echo "##########################################"
echo "" 
sudo apt-get -y update > /dev/null
sudo apt-get -y upgrade > /dev/null

check_package="$(apt list --installed show default-jre)"
if [[ $check_package == *"installed"* ]]
then 
   echo "Default JRE Installed"
else
   (sudo apt-get install -y default-jre > /dev/null)
fi

check_package="$(apt list --installed show openjdk-11-jre-headless)"
if [[ $check_package == *"installed"* ]]
then 
   echo "Open JDK 11 Installed"
else
   (sudo apt-get install -y openjdk-11-jre-headless > /dev/null)
fi

check_package="$(apt list --installed show openjdk-8-jre-headless)"
if [[ $check_package == *"installed"* ]]
then 
   echo "Open JDK 8 Installed"
else
   (sudo apt-get install -y openjdk-8-jre-headless > /dev/null)
fi      

check_package="$(apt list --installed show expect)"
if [[ $check_package == *"installed"* ]]
then 
   echo "Expect Installed"
else
   (sudo apt-get install -y expect > /dev/null)
fi 

check_package="$(apt list --installed show sshpass)"
if [[ $check_package == *"installed"* ]]
then 
   echo "SSH Pass Installed"
else
   (sudo apt-get install -y sshpass > /dev/null)
fi 

check_package="$(apt list --installed show python)"
if [[ $check_package == *"installed"* ]]
then 
   echo "Python 2.7 Installed"
else
   (sudo apt-get install -y python > /dev/null)
fi 

check_package="$(apt list --installed show python3)"
if [[ $check_package == *"installed"* ]]
then 
   echo "Python 3.6 Installed"
else
   (sudo apt-get install -y python3 > /dev/null)
fi 

check_package="$(apt list --installed show python-pip)"
if [[ $check_package == *"installed"* ]]
then 
   echo "Python PIP Installed"
else
   (sudo apt-get install -y python-pip python3-pip > /dev/null)
fi 

check_package="$(pip freeze | grep paramiko)"
if [[ "$check_package" ]]
then 
   echo "Paramiko Python Package Installed"
else
   (pip install Paramiko > /dev/null)
fi 

check_package="$(pip freeze | grep ncs)"
if [[ "$check_package" ]]
then 
   echo "NCS Python Package Installed"
else
   (pip install ncs > /dev/null)
fi 
 
check_package="$(apt list --installed show ant)"
if [[ $check_package == *"installed"* ]]
then 
   echo "Ant Installed"
else
   (sudo apt-get install -y ant > /dev/null)
fi 

echo ""
echo "##########################################"
echo "Extract NSO Files"
echo "##########################################"
echo "" 

mkdir $HOME/ncs-4.7
(cd /var/tmp/ncs-downloads && sh /var/tmp/ncs-downloads/nso-4.7.linux.x86_64.signed.bin) > /dev/null
sh /var/tmp/ncs-downloads/nso-4.7.linux.x86_64.installer.bin $HOME/ncs-4.7 --local-install  > /dev/null
. $HOME/ncs-4.7/ncsrc
touch ~/.bash_aliases
echo "if [ -f $HOME/ncs-4.7/ncsrc ]
then
   . $HOME/ncs-4.7/ncsrc
fi" | tee -a ~/.bash_aliases > /dev/null

echo "Directory ncs-4.7 created ...!!!"
(cd $HOME/ncs-4.7 && exec ncs-setup --dest $HOME/ncs-run)
echo "Directory ncs-run created ...!!!"
echo ""
echo "##########################################"
echo "Starting NSO"    
echo "##########################################"
echo "" 
(cd $HOME/ncs-run && exec ncs)
nso_status="$(ncs --status | grep status)"
if [[ "$nso_status" == *"started"* ]]
then
   echo "NSO Started, Congratulations :-)" && nso_status=true
else 
   echo "NSO NOT Started :-(" && nso_status=fulse
fi
echo ""
echo "##########################################"
echo "Compile NSO NEDs"    
echo "##########################################"
echo "" 

(cd $NCS_DIR/packages/neds/cisco-ios/src && make) > /var/tmp/ned-cisco-ios
(cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/neds/cisco-ios)
if grep -q "Nothing to be done" /var/tmp/ned-cisco-ios
then
    echo "Cisco IOS/IOS-XE NED compiled successfully :-)"
else
	echo "Cisco IOS/IOS-XE NED compilation failed :-("
fi

(cd $NCS_DIR/packages/neds/cisco-iosxr/src && make) > /var/tmp/ned-cisco-iosxr
(cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/neds/cisco-iosxr)
if grep -q "Nothing to be done" /var/tmp/ned-cisco-iosxr
then
    echo "Cisco IOS-XR NED compiled successfully :-)"
else
	echo "Cisco IOS-XR NED compilation failed :-("
fi

(cd $NCS_DIR/packages/neds/cisco-nx/src && make) > /var/tmp/ned-cisco-nxos
(cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/neds/cisco-nx)
if grep -q "Nothing to be done" /var/tmp/ned-cisco-nxos
then
    echo "Cisco NXOS NED compiled successfully :-)"
else
	echo "Cisco NXOS NED compilation failed :-("
fi

(cd $NCS_DIR/packages/neds/juniper-junos/src && make) > /var/tmp/ned-junos
(cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/neds/juniper-junos)
if grep -q "Nothing to be done" /var/tmp/ned-junos
then
    echo "Juniper JUNOS NED compiled successfully :-)"
else
	echo "Juniper JUNOS NED compilation failed :-("
fi

##For NSO packages not included by default and downloaded from box

## NOKIA ALU SR Package
(cd /var/tmp/ncs-downloads && sh ncs-4.7-alu-sr-7.10.signed.bin) > /dev/null
(cd /var/tmp/ncs-downloads && tar -xf ncs-4.7-alu-sr-7.10.tar.gz) > /dev/null
(cp -r /var/tmp/ncs-downloads/alu-sr $NCS_DIR/packages/neds) > /dev/null
(cd $NCS_DIR/packages/neds/alu-sr/src && make) > /var/tmp/ned-alu-sr
(cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/neds/alu-sr)
if grep -q "BUILD SUCCESSFUL" /var/tmp/ned-alu-sr
then
    echo "Juniper ALU SR NED compiled successfully :-)"
else
	echo "Juniper ALU SR NED compilation failed :-("
fi


## Cisco Viptela SD-WAN vManage Package
(cd /var/tmp/ncs-downloads && sh ncs-4.7-viptela-vmanage-1.2.2.signed.bin) > /dev/null
(cd /var/tmp/ncs-downloads && tar -xf ncs-4.7-viptela-vmanage-1.2.2.tar.gz) > /dev/null
(cp -r /var/tmp/ncs-downloads/viptela-vmanage $NCS_DIR/packages/neds) > /dev/null
(cd $NCS_DIR/packages/neds/viptela-vmanage/src && make) > /var/tmp/ned-viptela-vmanage
(cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/neds/viptela-vmanage)
if grep -q "BUILD SUCCESSFUL" /var/tmp/ned-viptela-vmanage
then
    echo "Cisco Viptela SD-WAN vManage NED compiled successfully :-)"
else
	echo "Cisco Viptela SD-WAN vManage NED compilation failed :-("
fi

echo ""
echo "##########################################"
echo "Loading NEDs in NSO .. that might take few minutes"    
echo "##########################################"
echo ""

ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2024" > /dev/null
echo '#!/usr/bin/expect -f
spawn sshpass -p admin ssh -o StrictHostKeyChecking=no admin@localhost -p 2024
expect "> "
send "request packages reload force \r"
expect "> "
send "show packages package package-version | save /var/tmp/ncs-ned-output \r"
expect "> "
send "exit \r"
interact' | sudo tee /var/tmp/ncs-ned-activate.sh > /dev/null
sudo chmod 775 /var/tmp/ncs-ned-activate.sh
(cd /var/tmp && ./ncs-ned-activate.sh) > /dev/null

if grep -q "cisco-ios" /var/tmp/ncs-ned-output
then
    echo "Cisco IOS/IOS-XE NED installed successfully :-)"
else
   echo "Cisco IOS/IOS-XE NED not installed :-(" 
fi

if grep -q "cisco-iosxr" /var/tmp/ncs-ned-output
then
    echo "Cisco IOS-XR NED installed successfully :-)"
else
   echo "Cisco IOS-XR NED not installed :-(" 
fi

if grep -q "cisco-nx" /var/tmp/ncs-ned-output
then
    echo "Cisco NXOS NED installed successfully :-)"
else
   echo "Cisco NXOS NED not installed :-(" 
fi

if grep -q "juniper-junos" /var/tmp/ncs-ned-output
then
    echo "Juniper JUNOS NED installed successfully :-)"
else
   echo "Juniper JUNOS NED not installed :-(" 
fi

if grep -q "alu-sr" /var/tmp/ncs-ned-output
then
    echo "Alcatel SR NED installed successfully :-)"
else
   echo "Alcatel SR NED not installed :-(" 
fi

if grep -q "viptela-vmanage" /var/tmp/ncs-ned-output
then
    echo "Cisco Viptela SD-WAN vManage NED installed successfully :-)"
else
   echo "Cisco Viptela SD-WAN vManage NED not installed :-(" 
fi

echo ""
echo "##########################################"
echo "Log into NSO"    
echo "##########################################"
echo "" 
if [ $nso_status == "true" ]
then 
   ncs_cli -u admin
fi
