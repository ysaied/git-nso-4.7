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
sudo rm -rf /var/tmp/*

echo ""
echo "##########################################"
echo "Downloading NSO"
echo "##########################################"
echo ""

mkdir  /var/tmp/ncs-downloads

#remove below
cp ~/nso-4.7-all.tar /var/tmp/ncs-downloads

#echo "Downloading NSO 4.7"
#wget -q --show-progress --no-check-certificate -O /var/tmp/ncs-downloads/nso-4.7-all.tar -L https://cisco.box.com/shared/static/wtde8q1gx68cfhl1r5bm1mc0h13l2wq0.tar > /dev/null
#nso_fsize="$(wc -c </var/tmp/ncs-downloads/nso-4.7-all.tar)"
#if [ "$nso_fsize" -ge "300000000" ]; then echo "NSO file downloaded successfully"; else echo "Failed to downloadi NSO file, exit script" && exit 1; fi 

(cd /var/tmp/ncs-downloads && tar -xf nso-4.7-all.tar) > /dev/null

echo ""
echo "##########################################"
echo "Installing Linux Updates and NSO Dependencies .. that might take sometime depending on your internet connection"
echo "##########################################"
echo "" 
sudo apt-get -y update > /dev/null
sudo apt-get -y upgrade > /dev/null


function install_linux_package()
{
   check_package="$(dpkg -s $1 &> /var/tmp/linux_pak_$1)" 
   if [[ $check_package == *"installed"* ]]
   then
      echo "$1 already installed"
   else
      (sudo apt-get install -y $1 &> /dev/null)
      echo "$1 was not there, but now is installed"
   fi

}

function install_python_package()
{
   check_package="$(pip freeze | grep $1)"
   if [[ "$check_package" ]]
   then
      echo "$1 Python Package Installed"
   else
      (pip install $1 &> /dev/null)
      "$1 Python Package Installed"
   fi

}

#linux packages
install_linux_package "default-jre"
install_linux_package "openjdk-11-jre-headless"
install_linux_package "openjdk-8-jre-headless"
install_linux_package "ant" 
install_linux_package "expect"
install_linux_package "sshpass"
install_linux_package "python"
install_linux_package "python3"
install_linux_package "python-pip" 

#python packages
install_python_package "paramiko"
install_python_package "netmiko"
install_python_package "ncs"


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
echo "Extracting NSO Packages .. that might take few minutes"      
echo "##########################################"
echo "" 

rm -rf $NCS_DIR/packages/*

function install_ned()
{
   (cd /var/tmp/ncs-downloads && sh $2) > /dev/null
   (cd /var/tmp/ncs-downloads && tar -xf $3) > /dev/null
   (cp -r /var/tmp/ncs-downloads/$1 $NCS_DIR/packages) > /dev/null
   (cd $NCS_DIR/packages/$1/src && make) &> /var/tmp/make-$1
   (cd ~/ncs-run/packages/ && ln -s $NCS_DIR/packages/$1)
   if grep -q "BUILD SUCCESSFUL\|Nothing to be done" /var/tmp/make-$1
   then
      echo "$1 NED extracted successfully :-)"
   else
      echo "$1 NED extraction failed :-("
	fi
}

#list NSO packages
install_ned "cisco-ios" "ncs-4.7.1-cisco-ios-6.4.1.signed.bin" "ncs-4.7.1-cisco-ios-6.4.1.tar.gz"
install_ned "cisco-iosxr" "ncs-4.7-cisco-iosxr-7.3.2.signed.bin" "ncs-4.7-cisco-iosxr-7.3.2.tar.gz"
install_ned "juniper-junos" "ncs-4.7.1-juniper-junos-4.0.4.signed.bin" "ncs-4.7.1-juniper-junos-4.0.4.tar.gz"
install_ned "alu-sr" "ncs-4.7-alu-sr-7.10.signed.bin" "ncs-4.7-alu-sr-7.10.tar.gz"
install_ned "viptela-vmanage" "ncs-4.7-viptela-vmanage-1.2.2.signed.bin" "ncs-4.7-viptela-vmanage-1.2.2.tar.gz"



echo ""
echo "##########################################"
echo "Loading Packages in NSO runtime .. that might take few minutes"    
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

function check_ned()
{
   if grep -q "$1" /var/tmp/ncs-ned-output
   then
      echo "$1 NED installed successfully :-)"
   else
      echo "$1 NED not installed :-("
   fi
}

#list NSO packages
check_ned "cisco-ios"
check_ned "cisco-iosxr"
check_ned "juniper-junos"
check_ned "alu-sr"
check_ned "viptela-vmanage"


echo ""
echo "##########################################"
echo "Log into NSO"    
echo "##########################################"
echo "" 
if [ $nso_status == "true" ]
then 
   ncs_cli -u admin
fi
