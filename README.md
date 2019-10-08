# This script will create apache spark standalone cluster on AWS using flintrock 

Create an IAM role for EC2 with s3 full access (This role will be attached to all servers in cluster).

Create another IAM role for EC2 with Admin access. (This will be use on machine where will run script).
 
Create a ssh key in aws

Launch a new linux instances in aws with Amazon Linux 2 AMI and attach IAM role created in step2.
      
Login to newly launched server and run below command.

            aws configure 

            Press enter for access key and secrete(keep the blank).
            In default region select us-east-1 and enter 
            For output enter  
Verfy AWS CLI is working by running below commands 

            aws ec2 describe-vpcs    
  
Install git 
 
            yum install -y git 

Copy ssh key to server in /home/ec2-user directory 
     
Download script using git 

             git clone  https://github.com/antimalbn/bashscript.git

Run below command

             mv bashscript/sparkcl.sh . 

                      
Run the script 

            /bin/bash sparkcl.sh

To launch new cluster use AMI ami-0097a939753b36096 . 
