## Terraform plan to simulate a branch habitat deployment 

## Overview
This terraform plan creates test branch infrastructure and a Chef Automate server

The branch design assumes a linux node for NGINX, windows node(s) for PoS systems, and windows node(s) for display system. 

The linux NGINX node is configured as the habitat permanent peer and loads the `eric/nginx` and `eric/sample`. The nginx config can be used as a cache and the sample app is to simulate running multiple applications. 

The windows quantity of windows nodes can be modified with the `count` variable

You should launch display systems with `--group display` and pos systems with `--group pos`

## usage instructions 

use the `tfvars.example` file to create a `terraform.tfvars` file with your values. 

run `terraform apply`

The output will show you the IP's of all the infrastructure. You can ssh into the linux nodes and RDP into the windows nodes. 

The linux systems are centos with the username `centos` & you set the windows systems passwords 

You'll need to ssh into the Automate server to grab the generated password, and API token. 

`sudo cat automate-credentials.toml`

## to do:
finish windows Habitat install and configuration script - habitat is not install on the windows systems with terraform apply at the moment. 