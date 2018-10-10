#! /bin/bash



#apt-cache show python | grep "Package: python"

function install_linux_package()
{
   check_package="$(apt-cache show $1 | grep 'Package: $1')" &> /dev/null
   if [ -z $check_package ]
   then
      echo "$1 Installed"
   else
      (sudo apt-get install -y $1 &> /dev/null)
      echo "$1 Installed"
   fi

}

install_linux_package "default-jre"

