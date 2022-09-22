# Test task in Terraform

Test task to create N machines and check if every machine can ping its neighbor in the round-robin way. 

## Prerequisites

Perform login on Azure CLI:

`az login`

Install *sshpass*:

On Ubuntu/Debian:

`apt-get install sshpass`

On Mac:

`brew install hudochenkov/sshpass/sshpass`

Check Python3 is installed:

`python3 --version`

Install python dependencies:

'pip3 install terraform-external-data'

## Run

For the first run:

`terraform init`

Default parameters:

`terraform apply`

With specific parameters:

`terraform apply -var="vm_count=3"`

With *.tfvars* file:

`terraform apply -var-file="testing.tfvars"`
