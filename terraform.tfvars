region = "us-east-1"

vpc_cidr = "172.16.0.0/16" 

enable_dns_support = "true" 

enable_dns_hostnames = "true"  

enable_classiclink = "false" 

enable_classiclink_dns_support = "false" 

preferred_number_of_public_subnets = 2

preferred_number_of_private_subnets = 4




tags = {
  Enviroment      = "production" 
  Owner-Email     = "wurahorlerh@gmail.com"
  Managed-By      = "Terraform"
  Billing-Account = "1234567890"
 }

name = "Terraform"
environment = "dev"
keypair = "devops2"
ami = "ami-0b98a32b1c5e0d105"
account_no =  "099720109477"
db-username = "barakat"
db-password = "devopspbl"





