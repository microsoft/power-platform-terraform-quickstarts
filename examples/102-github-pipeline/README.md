1. run bootstrap with azurerm backend
2. run mirror.sh if needed
3. every time set env variables



terraform init -backend-config=../../backend.tfvars
terraform apply