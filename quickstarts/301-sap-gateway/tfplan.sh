echo "########################################################"
echo "## SAP GW Terraform deployment "TERRAFORM PLAN"     ####"
echo "########################################################"
echo "terraform init -upgrade"
terraform init -upgrade
echo "terraform fmt -recursive"
terraform fmt -recursive
echo "terraform validate"
terraform validate
echo "terraform plan -var-file=local.tfvars -out out.plan"
terraform plan -var-file=local.tfvars -out out.plan
