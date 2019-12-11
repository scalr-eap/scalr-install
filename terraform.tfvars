# Example entries for use with local runs

/* Never put the next 2 in this file. Supply the values at the prompts or by exporting TF_VAR_ variables for each
scalr_aws_secret_key
scalr_aws_access_key
*/

# 48 char hex string. This is supplied in the email with your Scalr license
token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Indicates to get the license from ./license/license.json in the repo
license = "FROM_FILE"

# AWS region
region = "us-east-1"

instance_type = "t3.medium"

# SSH Key name in AWS
key_name = "MyKey-RSA"

# Indicates to get the SSH private key from ./ssh/id_rsa  in the repo
ssh_private_key = "FROM_FILE"

vpc = "vpc-123456678"

subnet = "subnet-12345678"

name_prefix = "ABC"
