# NGINX-WAF-Docker-ECS
Deploying NGINX Web Application Firewall as a Docker container and further deployment into AWS ECS.

While microservices can be more secure since each API can have its own built‑in throttling and limits, used to detect error conditions or attempts to overwhelm, application security is one of the largest gaps of microservices. Now that microservices are running via HTTP, the security concerns of traditional application security translate directly to microservices. Data injection attacks, cross‑site scripting, privilege escalation, and command execution are all still relevant. 

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

      > https://docs.nginx.com/nginx-waf/admin-guide/nginx-plus-modsecurity-waf-owasp-crs/
      
      
