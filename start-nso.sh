
echo ""
echo "##########################################"
echo "Starting NSO"    
echo "##########################################"
echo "" 
. $HOME/nso-4.7/ncsrc
nso_process="$(ps -A | grep ncs)"
if [[ ! "$nso_process" ]]
then 
   (cd $HOME/nso-run && exec ncs)
fi
nso_status="$(ncs --status | grep status)"
if [[ "$nso_status" == *"started"* ]]
then
   echo "NSO Started ...!!!" && nso_status=true
else 
   echo "NSO NOT Started :-(" && nso_status=fulse && exit
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
