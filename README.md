# gcp-myFirstProject
Project Title: Deploying a Secure and Scalable Web Application

Objective: Design, deploy, and secure a scalable web application on Google Cloud Platform (GCP) to demonstrate your capabilities in fundamental cloud engineering concepts and services. The project aims to assess your skills in solution architecture, effective use of GCP services, and the implementation of security best practices.

Project Requirements: 

A) Infrastructure as Code (IaC) - TERRAFORM Define and deploy your infrastructure using Terraform:
   
    1. Create a VPC network.
    
    2. Create subnets within the VPC. (Region: europe-west1)
   
    3. Create a Cloud Router in the network and establish a NAT Gateway.
    
    4. Create an Instance template in the subnet.
        ◦ Instance type: e2-micro
        ◦ Boot disk: debian-11
        ◦ Startup script: Include a startup script installing Apache2 or nginx web server and creating an index.html file with a simple welcome message.
   
    5. Use the created template to build a Managed Instance Group.
        ◦ Configuration settings for the Managed Instance Group:
            ▪ No public IP address.
            ▪ Access the internet through the NAT Gateway.
            ▪ Instance zone: europe-west1-d
  
    6. Create an Autoscaler.
        ◦ Target CPU utilization: 50%
   
    7. Create a load balancer in front of the instances.

B) Security: Create a service account for Terraform and link Terraform to the project using this service account. Set the service account permissions according to the least privilege principle.

C) Monitoring and Logging: Create alarms based on CPU usage for the instances you have created.

D) Creating Database: Create a Cloud SQL instance with a Private IP (PostgreSQL). Connect to one of the VMs via SSH. Install Cloud SQL Auth Proxy on the VM. Connect to the Cloud SQL instance using the Private IP.

E) Cloud Storage: Use Google Cloud Storage as the remote backend. The bucket created should not be public and should have versioning enabled. Store your Terraform state file in this bucket.

Project Deployment:
1. For Step A, main.tf file was created containing the necessary IaC to meet the requirements.
   Used comments on the cloud shell are:
     -terraform init
     -terraform plan
     -terraform apply
   To verify the creation process, the resources were checked from the Cloud Console. The IP address of the load balancer was also checked. The screenshot for the Web server page:
   ![image](https://github.com/tuanaguler/gcp-myFirstProject/assets/63639594/1b2ab33e-c590-4606-a49a-2a992d55653c)

2. For Step B, a service account named "terraform-service-account" was created and necessary permissions were given to complete the rest of the project. A key was generated and added to Cloud        Shell. Then the service account was connected to Terraform using the "export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key-file.json" command. The connection was confirmed.

3. For Step B, a CPU usage alert was created with a threshold of 35%.

4. For Step D, a Cloud SQL instance was created named "best-sql-ever" in the region "europe-west1". However, this step could not completed fully due to some connection problems.

5. For Step E, a Cloud Storage Bucket was created and added as a backend to the "main.tf" file.
