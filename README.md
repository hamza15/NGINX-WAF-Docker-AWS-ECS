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


