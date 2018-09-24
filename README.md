# NGINX-WAF deploment on Docker & AWS ECS
Deploying NGINX Web Application Firewall as a Docker container and further deployment into AWS ECS.

While microservices can be more secure since each API can have its own built‑in throttling and limits, used to detect error conditions or attempts to overwhelm; application security is one of the largest gaps of microservices. Now that microservices are running via HTTP, the security concerns of traditional application security translate directly to microservices. Data injection attacks, cross‑site scripting, privilege escalation, and command execution are all still relevant. 

According to NGINX's official website "The NGINX Web Application Firewall (WAF) protects applications against sophisticated Layer 7 attacks that might otherwise lead to systems being taken over by attackers, loss of sensitive data, and downtime".

### NGINX-WAF Docker Container Setup:

Prerequisites:
- This setup assumes you are running Docker on an AWS EC2 instance. Follow this doc to install docker: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
- EC2 instance needs to have port 22 open for SSH and 443 open for HTTPS traffic to container.
- EC2 instance needs IAM role that allows bootstrap.sh file to call s3 bucket and download files (if you have files in s3).

Steps:

- Make your project folder inside your AWS EC2 and clone this repository:

      >  mkdir ecs-docker
      >  cd ecs-docker
      >  git clone https://github.com/hamza15/NGINX-WAF-Docker-AWS-ECS.git

- Make your bootstrap.sh file executable for Docker:

      >  chmod 700 bootstrap.sh
      
- Log into your NGINX account, download your nginx-repo.key and nginx-repo.crt files and place in your S3 bucket.

- Update configuration for the following and add files to S3 bucket:

      >  /nginx/modsec/main.conf
      >  /nginx/nginx.conf
      >  /nginx/intenral_ips.conf
      
- Once everything is in place, move to your project directory and build your image:

      >  docker build -t ecs-waf .

- To run the image now interactive mode and connect host port 443 to container port 443, run the following:

      >  docker run -it -p 443:443 ecs-waf /bin/bash
      
- If all your config files are setup correctly your Docker container should launch with NGINX running. You can test nginx status with the following:

      > service nginx status

- You can test your NGINX WAF with the Nikito scanning tool using the following documentation: 

      https://docs.nginx.com/nginx-waf/admin-guide/nginx-plus-modsecurity-waf-owasp-crs/
      
      
### NGINX-WAF AWS EC2 Container Service Setup:

Prerequisites:
- Create the necessary IAM roles for ECS to excute which include ecsInstanceRole and ecsTaskExecutionRole.
- 

Steps:

- Log into the AWS Console and navigate to Elastic Container Service.
- Create a new repository to push your Docker container image to.
- Follow the commands listed to push your image to AWS Elastic Container Registery.
- Once pushed, click done and take note of Repository URI which we will need later.

- Create a new cluster and select EC2 Linux + Networking from the configuration options.
- Select the Type of EC2 instance and the number according to your need. Choose an existing VPC, Subnets (Private or Public according to your need) and your Security Group you configured for Docker Container instance.
- Choose the ecsInstanceRole which allows ECS container agent to make ECS API calls on your behalf, which the w
- Launch the cluster.

- Once cluster is launched, nagivate to Task Definitions.
- Inside Task definitions, create a new task definition with EC2 launch type.
- Name the Task definition and select Bridge for Network mode. Select ecsTaskExecutionRole, which the wizard can produce by default.
- Select add a container and name the container. Paste the Repository URI you noted down from AWS ECR and add port mapping values. 

      Host Port 443 to Container Port 443
- That should be enough to launch your Task Definition.

- Navigate to your cluster and under Services tab, create a new service.
- Select EC2 Launch Type and select all your previous configs along with the number of tasks you would like to run.
- Under Take Placement select One Task Per Host. Each task would run as a container on a separate ECS Instance.
- In most cases one task running an NGINX WAF service is good enough, however if you need you can create a Load Balancer and increase the number of tasks. This would make your load balancer distribute traffic to the number of containers you setup in the background. You can setup the minimum number of containers that should stay active at all times. An auto-scaling group can be added if need be to scale this service, however in test/QA would not be necessary.
- Create your service.

Your NGINX WAF is now protecting your microservices from Layer 7 attacks and is running on a container hosted on AWS ECS like the all cool kids. Congrats!
