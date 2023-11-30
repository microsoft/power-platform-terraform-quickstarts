#Currently licensing requries username/password authentication (internal icm: 437373148)

# resource "powerplatform_billing_policy" "pay_as_you_go" {
#   name     = "BillingPolicyPayAsYouGo"
#   location = "unitedstates"
#   status   = "Enabled"
#   billing_instrument = {
#     resource_group  = var.billing_policy_resource_group
#     subscription_id = var.billing_policy_subscription_id
#   }
# }

# resource "powerplatform_billing_policy_environment" "pay_as_you_go_policy_envs" {
#   billing_policy_id = powerplatform_billing_policy.pay_as_you_go.id
#   environments      = [ powerplatform_environment.foo.id ]
# }
