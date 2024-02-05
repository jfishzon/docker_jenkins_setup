# Information
This repository contains the following:
- DockerFile that sets-up jenkins automatically with a list of plugins to install & username + password setup.
- Terraform code to create an EC2 instance with an SG attached and SSH Access (server-wise & SG-wise) open to a given port (from jenkins pipeline) with access from 0.0.0.0
- 3 Jenkins pipelines:
  1. A pipeline that runs 10 agents, each generates a number between 2000 to 50,000, the pipeline will select the max number between all these agent and stores it as an artifact.
  2. Runs a terraform apply with the artifact of the given number from pipeline 1.
  3. runs a terraform destroy for the terraform resources.
- Bash Script that receives github pat, aws access key & secret key and sets up all of the above, as well as adding the secrets given as parameters to jenkins & creating the pipelines.


# Installation
## Prerequisites
- Ubuntu Server
- Internet Access
- AWS Programmatic Access

## How to install
Run the configure.sh script with sudo, make sure to run with the sh command.

### Flags
- a AWS Access Key
- s AWS Secret Key
- g Github Key

### Example:
- sudo sh configure.sh -a my_access_key -s my_secret_key -g github_key

