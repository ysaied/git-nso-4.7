#! /bin/bash
username=admin
password=Cisco@1234

echo "##########################################"
echo "Cisco NSO Installtion"
echo "##########################################"
echo ""
echo "##########################################"
echo "Clean-Up"
echo "##########################################"
echo "" 

pkill ncs
if [ -d $HOME/nso-tmp ]; then sudo rm -r $HOME/nso-tmp && echo "nso-tmp directory deleted"; fi
if [ -d $HOME/nso-4.7 ]; then sudo rm -r $HOME/nso-4.7 && echo "nso-4.7 directory deleted"; fi
if [ -d $HOME/nso-run ]; then sudo rm -r $HOME/nso-run && echo "nso-run directory deleted"; fi

echo ""
echo "##########################################"
echo "Install Dependencies"
echo "##########################################"
echo "" 
sudo apt -y update
sudo apt -y upgrade

sudo apt install -y default-jre            
sudo apt install -y openjdk-11-jre-headless
sudo apt install -y openjdk-8-jre-headless

sudo apt install -y expect
sudo apt install -y sshpass

sudo apt install -y python
sudo apt install -y python3
sudo apt install -y python-pip

pip install Paramiko
pip install ncs
echo ""
echo "##########################################"
echo "Install Ant"
echo "##########################################"
echo "" 
sudo apt install -y ant
echo ""
echo "##########################################"
echo "Download NSO Installer"
echo "##########################################"
echo "" 
mkdir $HOME/nso-tmp
sshpass -p $password scp -o StrictHostKeyChecking=no $username@10.71.247.158:/home/admin/cisco-nso/nso-4.7.linux.x86_64.installer.bin $HOME/nso-tmp/nso.installer.bin
if [ -f $HOME/nso-tmp/nso.installer.bin ]; then echo "NSO Installer downloaded successfully ...!!!"; else echo "NSO Installer download failed" && exit; fi 
echo ""
echo "##########################################"
echo "Extract NSO Files"
echo "##########################################"
echo "" 
mkdir $HOME/nso-4.7
sh $HOME/nso-tmp/nso.installer.bin $HOME/nso-4.7 --local-install
. $HOME/nso-4.7/ncsrc
echo "Directory nso-4.7 created ...!!!"
(cd $HOME/nso-4.7 && exec ncs-setup --dest $HOME/nso-run)
echo "Directory nso-run created ...!!!"
echo ""
echo "##########################################"
echo "Starting NSO"    
echo "##########################################"
echo "" 
(cd $HOME/nso-run && exec ncs)
nso_status="$(ncs --status | grep status)"
if [[ "$nso_status" == *"started"* ]]
then
   echo "NSO Started, Congratulations :-)" && nso_status=true
else 
   echo "NSO NOT Started :-(" && nso_status=fulse
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
