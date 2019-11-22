# scalr-install
Install and configure Scalr with Terraform

This template will install Scalr on multiple servers. Currently it sets up 4 servers

* Mysql (single server)
* influxDB
* Worker
* Proxy/App

Extending this to HA Mysql, 2 Proxies and an LB is Phase 2
Turning it into a Service Catalog offering is Phase 3

This is built for AWS and has some hardcoded config items in `variables.tf`

* Region = us-east-1
* AMI = Ubuntu 1604
* Instance Type = t3.medium (4GB is the minimum for Scalr)

To use the template

1. Pull the repo.
2. Upload the public key to AWS and set the Key name in variables.tf (key_name)
3. Adjust scalr.ui.login_warning in `scalr_install_set_config.sh` to suit your needs
4. Create a CLI workspace in Scalr Next-Gen and configure the backend to match in `scalr-prod.tf`
5. Create a Terraform Variable `token` in the workspace and set to the value of your download token. Mark as "Sensitive".
6. Create a Terraform Variable `license` in the workspace and copy the full text of you Scalr license file into the value. Mark as "Sensitive".
7. Create a Terraform Variable `private_ssh_key` in the workspace and copy the full text of you private key file in either PEM or PPK format into the value. Mark as "Sensitive".
8. Run `terraform init;terraform apply` and watch the magic happen
 
