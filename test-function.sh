#! /bin/bash



#apt-cache show python | grep "Package: python"

function install_linux_package()
{
   rm -rf /var/tmp/linux_pak_$1
   dpkg -s $1 &> /var/tmp/linux_pak_$1 
   if grep -q "Status: install ok installed" /var/tmp/linux_pak_$1
   then
      echo "$1 already installed"
   else
      (sudo apt-get install -y $1 &> /dev/null)
      echo "$1 was not there, but now is installed"
   fi
}

install_linux_package "default-jre"

