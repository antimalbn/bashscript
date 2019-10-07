#!/bin/bash
#Written by Antima Mishra 
#Contact antima@lbncyberlabs.com
#This script use flintrock to create and manage spark cluster 

#Function to setup script firsttime
setupfirsttime(){
	echo "Setting up script,it will take few minutes"
        sudo yum update -y
        sudo yum install -y python3-pip

        ppv=`which pip3`

if [ ! -z "$ppv" ] ;
   then
      pip3 install --user flintrock 
      pip3 install --user "cryptography==2.4.2" 

else
     echo "Unbale to install pip3"
     exit
fi     
        
}

#Create new cluster
createcl(){

dat=$(date +"%Y%m%d%H%M")
sgname=sparkcllanaccess$dat
vpccidr=`aws ec2 describe-vpcs  | grep CidrBlock | grep -v "CidrBlockAssociationSet" | grep -v "CidrBlockState" | head -1 | awk {'print $2'} | tr -d '" ' | tr -d ", "`
vpcid=`aws ec2 describe-vpcs  | grep VpcId | awk {'print $2'} | tr -d '" ' | tr -d ", "`

sgid=`aws ec2 create-security-group --group-name $sgname --description "My security group" --vpc-id $vpcid | grep sg | awk {'print $2'} | tr -d '" ' | tr -d ", "`

aws ec2 authorize-security-group-ingress \
    --group-id $sgid \
    --protocol tcp \
    --port 0-63000 \
    --cidr $vpccidr


read -p "Enter Cluster Name  " clname
read -p "Enter Number of slave to launch " slvnum
read -p "Enter EC2 Key name " keyname
read -p "Enter EC2 key path like /spark/mysrv.pem  " keypath
read -p "Enter AMI ID " amiclid
read -p "Enter Instance type like t2.micro " instancetype
read -p "Enter Instance profile name " imrol

flintrock launch $clname \
    --num-slaves $slvnum \
    --spark-version 2.4.4 \
    --ec2-key-name $keyname \
    --ec2-identity-file $keypath \
    --ec2-ami $amiclid \
    --ec2-user ec2-user \
    --install-hdfs \
    --hdfs-version 2.8.5 \
    --install-spark \
    --ec2-instance-type $instancetype \
    --ec2-instance-profile-name $imrol \
    --ec2-security-group $sgname


flintrock run-command --ec2-identity-file $keypath --ec2-user ec2-user $clname "/bin/bash /home/ec2-user/copys3lib.sh"
flintrock run-command --master-only --ec2-identity-file $keypath --ec2-user ec2-user $clname "/bin/bash /home/ec2-user/script_master.sh"
exit 

}

#Destroy cluster
destroycl(){

read -p "Enter Cluster Name  " clname

 flintrock destroy $clname	
exit

}

#Add slave 
addslave(){

read -p "Enter Cluster Name  " clname
read -p "Enter Number of slave to add  " slvnum
read -p "Enter EC2 key file path " keypath

flintrock add-slaves --ec2-identity-file $keypath --ec2-user ec2-user $clname --num-slaves=$slvnum
flintrock run-command --ec2-identity-file $keypath --ec2-user ec2-user $clname "/bin/bash /home/ec2-user/copys3lib.sh"
exit

}

#Remove slave
removeslave(){

read -p "Enter Cluster Name  " clname
read -p "Enter Number of slave to remove  " slvnum
read -p "Enter EC2 key path like /spark/mysrv.pem  " keypath

flintrock remove-slaves --ec2-identity-file $keypath --ec2-user ec2-user $clname --num-slaves=$slvnum

exit

}

#Start Cluster
startcl(){

read -p "Enter Cluster Name  " clname
read -p "Enter EC2 key path like /spark/mysrv.pem  " keypath
	
flintrock start --ec2-identity-file $keypath --ec2-user ec2-user  $clname

exit

}

#Stop Cluster
stopcl(){

read -p "Enter Cluster Name  " clname

flintrock stop $clname	

exit

}	


#Get details of cl
getcldetails(){

read -p "Enter Cluster Name  " clname

flintrock describe $clname	

exit

}	


#Menu to salect manage cluster option
manageclmenu() {
	while true
	do
            show_menuscl
            read_cloptions	    
    done
}


show_menuscl(){
        echo "~~~~~~~~~~~~~~~~~~~~~"    
        echo " Spark Cluster"
        echo "~~~~~~~~~~~~~~~~~~~~~"
        echo "1. Launch a new spark cluser"
        echo "2. Manage existing spark cluster"
        echo "3. Exit"
      

}


manageexcl() {
 while true
 do	 
     show_menusexclmg
     read_exclmgoptions
done    
}


show_menusexclmg(){

        echo "~~~~~~~~~~~~~~~~~~~~~"    
        echo " Existing Cluster Mangement Options"
        echo "~~~~~~~~~~~~~~~~~~~~~"
        echo "1. Get details of cluster"
        echo "2. Add Slave to cluser"
	echo "3. Remove Slave from cluser"
	echo "4. Stop cluser"
	echo "5. Start cluser"
	echo "6. Destroy cluser"
        echo "7. Exit"


}






# do something
show_menus(){
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Setup Script First Time"
	echo "2. Manage Spark Cluster"
	echo "3. Exit"
}

# Exit when user the user select 3 form the menu option.
read_options(){
	local choice
	read -p "Enter choice [ 1 - 3] " choice
	case $choice in
		1) setupfirsttime ;;
		2) manageclmenu ;;
		3) exit 0 ;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}


read_cloptions(){
        local choicecl
        read -p "Enter choice [ 1 - 3] " choicecl
        case $choicecl in
                1) createcl ;;
                2) manageexcl ;;
                3) exit 0 ;;
                *) echo -e "${RED}Error...${STD}" && sleep 2
        esac
}

read_exclmgoptions(){
        local choiceexclmg
        read -p "Enter choice [ 1 - 7] " choiceexclmg
        case $choiceexclmg in
                1) getcldetails ;;
                2) addslave ;;
                3) removeslave ;;
		4) stopcl ;;
		5) startcl ;;
		6) destroycl ;;
                7) exit 0 ;;
                *) echo -e "${RED}Error...${STD}" && sleep 2
        esac
}




# Step #3: Trap CTRL+C, CTRL+Z and quit singles
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
 
	show_menus
	read_options
done

