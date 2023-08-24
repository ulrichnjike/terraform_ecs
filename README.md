 confiration of AWS Credential by set up (access and secret key) using AWS CLI .

 creation of the environment where we will run the terraform code named (provider.tf) .

 creation of a file named 'main.tf' to define the terraform configuration that will automate creation of ecs cluster, ecs task definition to run docker container with the web application and deploy the task on the ecs cluster as a service .

 then set up an application load balancer (ALB) to distribute traffic to the ECS service and configure necessary security groups.

 Implimentation of auto scaling based on the CPU usage then set up an Amazon CloudWatch alarm to monitor the CPU usage of the ECS task and configuration of application auto scaling policy to adjust the desired count of the ECS service based of on the alarm's threshold

 i did make use of terraform code to set up CI/CD pipeline using codepipeline AWS Codebuild then i create a code for IAM role named (iam.tf) and S3 bucket named (S3.tf) .


