
# resource "powerplatform_billing_policy" "pay_as_you_go" {
#   name     = "${powerplatform_environment.foo.name}-pay-as-you-go"
#   location = "unitedstates"
#   status   = "Enabled"
#   billing_instrument = {
#     resource_group  = "resource_group_name"
#     subscription_id = "00000000-0000-0000-0000-000000000000"
#   }
# }

# resource "powerplatform_billing_policy_environment" "pay_as_you_go_policy_envs" {
#   billing_policy_id = powerplatform_billing_policy.pay_as_you_go.id
#   environments      = [ powerplatform_environment.foo.id ]
# }
