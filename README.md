# wordpress-kbc


This project focuses on building a resilient and scalable WordPress deployment on AWS, leveraging Terraform for infrastructure as code (IaC). The deployment architecture includes multiple availability zones (AZs) to ensure high availability and fault tolerance. Key components of the architecture include:


* Networking Infrastructure:
    * Creation of a Virtual Private Cloud (VPC) spanning multiple AZs.
    * Configuration of public and private subnets for web servers, database servers, and load balancers.
    * Setup of internet gateway, route tables, and NAT gateways for inbound and outbound traffic.
* Compute Resources:
    * Launching EC2 instances for WordPress web servers across multiple AZs, configured to automatically scale based on demand.
    * Implementation of an Auto Scaling Group to manage the EC2 instances and maintain desired capacity.
    * Installation and configuration of WordPress on EC2 instances , web server should be nginx. 
* Database Setup:
    * Provisioning an RDS (Relational Database Service) instance based on Postgres 16 for WordPress database backend. 
    * Configuration of RDS Multi-AZ deployment for high availability and data redundancy.
    * Securing database access and setting up appropriate permissions.
* Load Balancing and Traffic Distribution:
    * Deployment of Elastic Load Balancer (ELB) to distribute incoming traffic across multiple EC2 instances.
    * Configuration of health checks and load balancing policies to ensure optimal performance and fault tolerance.
    * Integration of ELB with Auto Scaling Group to dynamically adjust the number of instances based on traffic patterns.
* Security and Access Control:
    * Implementation of security groups to control inbound and outbound traffic to EC2 instances and RDS.
    * Configuration of Network Access Control Lists (NACLs) for subnet-level security.
    * Management of IAM roles and policies for least privilege access.
* Monitoring and Logging:
    * Integration with AWS CloudWatch for monitoring resource utilization, performance metrics, and alarms.
    * Configuration of logging for EC2 instances, RDS, and ELB to capture relevant logs for troubleshooting and analysis.


* Expected results:
    * Single Terraform apply command to deploy whole infrastructure of this project
    * No manual work
    
