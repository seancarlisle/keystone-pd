#!/bin/bash


# args for Keystone
TENANTNAME=''
USERNAME=''
PASSWORD=''
ROLEROLE=''

function usage {
   echo 'usage: ./$0 <tenant-name> <user-name> <password> <role>'
}


function argParse {
   TENANTNAME=$1
   USERNAME=$2
   PASSWORD=$3
   ROLENAME=$4
}

# Main script logic

if [ $# == 1 ]
then
   usage
   exit 1
fi

#source the credentials file        
source /root/.novarc

argParse

# Get the role ID for the desired role
ROLEID=$(keystone role-list | awk -F '|' '/admin/ {print $2}')

# Create the new tenant
TENANTID=$(keystone tenant-create --name $TENANTNAME | awk -F '|' '/\ id\ / {print $3}')

# Create the new user
USERID=$(keystone user-create --name $USERNAME --tenant-id $TENANTID --pass $PASSWORD | awk -F '|' '/\ id\ / {print $3}')

# Add the new user to the desired tenant
keystone user-role-add --user-id $USERID --tenant-id $TENANTID --role-id $ROLEID &> /dev/null

# Let's make sure things were created correctly
if [ $(keystone tenant-list | grep $TENANTNAME) -ne 0 ]
then
   echo "Something went wrong!  User and tenant were not created successfully!\n"
   exit 1
else
   exit 0
fi
