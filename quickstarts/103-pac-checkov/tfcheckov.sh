echo "##############################################################################"
echo "# Commands nedded to check the Terraform code for the SAP Gateway Quickstart #"
echo "##############################################################################"
echo "terraform init"
terraform init -upgrade
echo "terraform fmt -recursive"
terraform fmt
echo "terraform validate"
terraform validate
echo "terraform plan -var-file=local.tfvars -out tf.plan"
terraform plan -var-file=local.tfvars -out tf.plan
echo "terraform show -json tf.plan  > tf.json  # required for checkov"
terraform show -json tf.plan  > tf.json 
echo "checkov excecution"
checkov -f tf.json
echo "##############################################################################"