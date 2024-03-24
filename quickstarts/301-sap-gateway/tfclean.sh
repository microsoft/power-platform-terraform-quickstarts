echo "#######################################"
echo "##     Remove Terraform files 	   ##"
echo "#######################################"
echo "rm .terraform.lock.hcl"
rm .terraform.lock.hcl
echo "rm terraform.tfstate"
rm terraform.tfstate
echo "rm terraform.tfstate.backup"
rm terraform.tfstate.backup
echo "rm out.plan"
rm out.plan
