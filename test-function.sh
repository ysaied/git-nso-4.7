#! /bin/bash



#apt-cache show python | grep "Package: python"

function install_linux_package()
{
#   rm -rf /var/tmp/linux_pak_$1 &> /dev/null
   (check_package="($dpkg -s $1)") &> /dev/null 
   if grep -q "Status: install ok installed" $check_package
   then
      echo "$1 already installed"
   else
      (sudo apt-get install -y $1 &> /dev/null)
      echo "$1 was not found, now get installed"
   fi
}

install_linux_package "default-jre"

