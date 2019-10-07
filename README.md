# bashscript

Create an IAM role for EC2 with s3 full access (we will use to during cluster creation).
Create an IAM role for EC2 with Amin access.
Create a ssh key in aws
Launch a new linux instances in aws with Amazon Linux 2 AMI and attach IAM role created in step2.
      
Login to newly launched server and run below command.

             aws configure 

            Press enter for access key and secrete(keep the blank).
            In default region select us-east-1 and enter 
            For output enter  
  
Install git 
 
            yum install -y git 

Copy ssh key to server in /home/ec2-user directory 
     
Download script using git 

             git clone  https://github.com/antimalbn/bashscript.git

Run below command

mv bashscript/sparkcl.sh . 

                      
Run the script 

            /bin/bash sparkcl.sh
