#! /bin/bash

echo ""
echo "##########################################"
echo "Creating simulated devices"    
echo "##########################################"
echo ""

echo "creating 2xcisco-ios, 2xcisco-ios-xr, 2xjuniper-junos"
mkrdir ~/ncs-netsim
ncs-netsim create-network cisco-ios 2 ios ./ncs-netsim/
ncs-netsim add-to-network cisco-iosxr 2 ios-xr ./ncs-netsim/
ncs-netsim add-to-network juniper-junos 2 junos ./ncs-netsim/
ncs-netsim start --dir ~/ncs-netsim
ncs-setup --netsim-dir ~/ncs-netsim --dest ~/ncs-netsim/