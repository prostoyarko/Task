Requirements:

Terraform v0.13.5 or higher
AWS user with the following policies:
  AmazonEC2FullAccess
  AmazonVPCFullAccess

Infrastructure deployment steps:

1. Set environment variable for AWS access key in command line via command "set AWS_ACCESS_KEY_ID=<your_key_id>".
2. Set environment variable for AWS secret access key in command line via command "set AWS_SECRET_ACCESS_KEY=<your_secret_access_key_id>".
3. Create local copy of this repository.
4. Navigate to folder with local repository and execute command "terraform init"
5. Execute command "terraform apply" to create the infrastructure

Steps above tested on Windows 10 machine. For Linux OS commands "export AWS_ACCESS_KEY_ID=" and "export AWS_SECRET_ACCESS_KEY=" should be used in step 1 and 2.
