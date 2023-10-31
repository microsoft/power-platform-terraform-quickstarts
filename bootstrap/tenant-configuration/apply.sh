az login

# Call terraform init with backend.tfvars as backend config file
terraform init -backend-config=../../backend.tfvars

# Run terraform apply and get the output values into variables
terraform apply