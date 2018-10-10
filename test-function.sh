#! /bin/bash



#apt-cache show python | grep "Package: python"

function install_linux_package()
{
   check_package="$(dpkg -s $1 &> /dev/null)"
   if [[ $check_package == *"installed"* ]]
   then
      echo "$1 already installed"
   else
      (sudo apt-get install -y $1 &> /dev/null)
      echo "$1 installed"
   fi

}

install_linux_package "default-jre"

