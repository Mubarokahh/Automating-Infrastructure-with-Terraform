
# Automate-infrastructure-using-terraform
This project shows how the set up of an AWS infrastructure for two websites can be automated using Terrafoam. In this project, I shall be building a secure and and resilient 3 Tier infrastructure inside our own AWS Virtual Private Cloud network.

![Architecture](Images/Architecture.JPG)

The image above demostrates the 3 tier architecture in this project.
- Tier 1: Public Subnet, hosting the bastion server nad NAT gateway
- Tier 2: Private Subnet, hosting webservers
- Tier 3: Data Layer, hosting Elastic File System EFS and RDS database
 
 The following resources highlighted below will be used to set up the infrastructure for this project

 1. S3 bucket will be used to store Terraform state file.
 2. Bastion host in the public subnet to enable SSH access into other webservers.
 3. VPC will be set-up to isolate the infrastructure in the cloud.
 4. Route53 DNS which will make use of custom domain name and an eentry point to the loadbalancer.
 5. Private and Public subnets for grouping the resources as needed across the avialability zones
 6. Elastic load balancer to route the traffic to the highly avaialable  nginx reverse proxy server
 7. Launch template for autoscaling group.
 8. Target groups for load balancer.
 9. Security groups associated to resources and configured to only allow certain type of traffic from certain ports or IP's.
 10. Internet gateway for the public subnet to be routable.
 11. NAT gataeway to give internet access to the private subnet.
 12. Autoscaling group for the nginx server and webservers 

 EVENTS OF THE PROJECT
 
 - I created an IAM user, named stile and granted the stile  administrativeaccess permissions.
 - I created secret access key adn access ID for the user.
 - I created an amazon S3 bucket for storing terraform statefile
 - I installed AWS SDK for python, to integrate python application with AWS services.
 - I ran the following command to check if i can progrmatically access AWS services ussing AWS CLI
    
    ` import boto3
s3 = boto3.resource('s3')
for bucket in s3.buckets.all():
    print(bucket.name)`


   ![AWS-CLI](Images/AWS-CLI.JPG)

   - I created a folder named 'Terraform-project'. I added a file named 'main.tf'in this folder.

   - Added the following variables to declare AWS as the provider.

   
   # Configure the AWS Provider
    `
     provider "aws" {
        region = "us-east-1"
     }`

   -  I stored the desired VPC CIDR range in a variable

   `variable "vpc_cidr" {
        default = "172.16.0.0/16"
    }`


    - I stored other desired VPC configuration in a variable.
   
   ```
    variable "enable_dns_support" {
        default = "true"
    }    

    variable "enable_dns_hostnames" {
        default ="true" 
    }

   variable "enable_classiclink" {
        default = "false"
    }

   variable "enable_classiclink_dns_support" {
        default = "false"
    }
    ```

    - To create VPC

   ```
    resource "aws_vpc" "main" {
   cidr_block                     = var.vpc_cidr
   enable_dns_support             = var.enable_dns_support
   enable_dns_hostnames           = var.enable_dns_hostnames
   enable_classiclink             = var.enable_classiclink
   enable_classiclink_dns_support = var.enable_classiclink_dns_support
   }```

  - Declared a variable to store the number of desired public subnet and set the default value

    ` variable "preferred_number_of_public_subnets" {
      default = 2 
   }`


  - Create Public Subnets 

  # Create public subnets

  ```
  resource "aws_subnet" "public" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
  vpc_id = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4 , count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
   }
```

   The first part var.preferred_number_of_public_subnets == null checks if the value of the variable is set to null or has some value defined.
The second part ? and length(data.aws_availability_zones.available.names) means, if the first part is true, then use this. In other words, if preferred number of public subnets is null (Or not known) then set the value to the data returned by lenght function.
   The third part : and  var.preferred_number_of_public_subnets means, if the first condition is false, i.e preferred number of public subnets is not null then set the value to whatever is definied in var.preferred_number_of_public_subnets

   - Testing the configuration

      `terraform plan`

 ![image](https://github.com/Mubarokahh/Automate-infrastructure-using-terraform/assets/135038657/ce5a9b26-d17e-4854-a039-f881dccbbad5)


 - To make my code appear more readable and well structured,  I created a new file called variables.tf and copied all the variable declarations into it from main.tf. I created another file named terraform.tfvars and set values for each of the variables. 

      # - Main.tf

       ```
       Get list of availability zones
       data "aws_availability_zones" "available" {
       state = "available"
       }

       provider "aws" {
        region = var.region
       }

      Create VPC
      resource "aws_vpc" "main" {
      cidr_block                     = var.vpc_cidr
      enable_dns_support             = var.enable_dns_support 
      enable_dns_hostnames           = var.enable_dns_support
      enable_classiclink             = var.enable_classiclink
      enable_classiclink_dns_support = var.enable_classiclink

      }

      Create public subnets
      resource "aws_subnet" "public" {
      count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
      vpc_id = aws_vpc.main.id
      cidr_block              = cidrsubnet(var.vpc_cidr, 4 , count.index)
      map_public_ip_on_launch = true
      availability_zone       = data.aws_availability_zones.available.names[count.index]
      
      }```


 # -Variable.tf
   
    ```
     variable "region" {
     default = "us-east-1"
    }
     variable "vpc_cidr" {
     default = "172.16.0.0/16"
    }

     variable "enable_dns_support" {
     default = "true"
    }

     variable "enable_dns_hostnames" {
     default ="true" 
    }

     variable "enable_classiclink" {
     default = "false"
    }

     variable "enable_classiclink_dns_support" {
     default = "false"
    }
   
     variable "desires_number_of_public_subnet" {
    
    }

     variable "preferred_number_of_public_subnets" {
      default = null 
    } ```

   # - Terraform.tfvars

  ```
    region = "us-east-1"

    vpc_cidr = "172.16.0.0/16" 

    enable_dns_support = "true" 

    enable_dns_hostnames = "true"  

    enable_classiclink = "false" 

    enable_classiclink_dns_support = "false" 

    preferred_number_of_public_subnets = 2

  ```

        `Terraform apply`

 
   ![image](https://github.com/Mubarokahh/Automate-infrastructure-using-terraform/assets/135038657/c88d9ef3-05b0-4199-9140-878a23a3370a)


    
    Infrastructure created sucessfully

    VPC
    
   ![image](https://github.com/Mubarokahh/Automate-infrastructure-using-terraform/assets/135038657/67b96334-6854-49b1-ac13-49b62dffa49e)

    PUBLIC SUBNETS

    ![image](https://github.com/Mubarokahh/Automate-infrastructure-using-terraform/assets/135038657/523b6c37-58b7-4720-8b88-e17442cf2dfd)

