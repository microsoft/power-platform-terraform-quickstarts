# Usage

1. `terraform init`
1. `terraform plan --var-file=prod.tfvars`
1. `terraform apply --var-file=prod.tfvars`

## Example tfvars file

```hcl
environment_parameters = {
  env_name            = "coe-kit-prod",
  env_location        = "europe",
}

core_components_parameters = {
  admin_AdmineMailPreferredLanguage                    = "en",
  admin_AdminMail                                      = "admin@contoso.com",
  admin_AppConnectionsDataflowID                       = "",
  admin_AppDataflowID                                  = "",
  admin_ApprovalAdmin                                  = "",
  admin_AppUsageDataflowID                             = "",
  admin_AuditLogsAudience                              = "",
  admin_AuditLogsAuthority                             = ""
  admin_AuditLogsClientAzureSecret                     = "/subscriptions/2bc1f261-7e26-490c-9fd5-b7ca72032ad3/resourceGroups/coe-kit/providers/Microsoft.KeyVault/vaults/mawasile-coe-kv1/secrets/foo",
  admin_AuditLogsClientID                              = "",
  admin_AuditLogsClientSecret                          = "",
  admin_Capacityalertpercentage                        = "",
  admin_CoESystemUserID                                = "",
  admin_CommandCenterApplicationClientID               = "",
  admin_CommandCenterClientAzureSecret                 = "",
  admin_CommandCenterClientSecret                      = "",
  admin_CommunityURL                                   = "",
  admin_CompanyName                                    = "",
  admin_ComplianceAppsNumberDaysSincePublished         = "",
  admin_ComplianceAppsNumberGroupsShared               = "",
  admin_ComplianceAppsNumberLaunchesLast30Days         = "",
  admin_ComplianceAppsNumberUsersShared                = "",
  admin_ComplianceChatbotsNumberLaunches               = "",
  admin_DelayInventory                                 = "",
  admin_DelayObjectInventory                           = "",
  admin_DeleteFromCoE                                  = "",
  admin_DeveloperComplianceCenterURL                   = "",
  admin_DisabledUsersareOrphaned                       = "",
  admin_eMailBodyStart                                 = "",
  admin_eMailBodyStop                                  = "",
  admin_eMailHeaderStyle                               = "",
  admin_EnvironmentDataflowID                          = "",
  admin_EnvRequestAutoApproveCertainGroups             = "",
  admin_EnvRequestEnableCostTracking                   = "",
  admin_FlowConnectionsDataflowID                      = "",
  admin_FlowDataflowID                                 = "",
  admin_FlowUsageDataflowID                            = "",
  admin_FullInventory                                  = "",
  admin_GraphURLEnvironmentVariable                    = "",
  admin_HostDomains                                    = "",
  admin_InventoryandTelemetryinAzureDataStorageaccount = "",
  admin_InventoryFilter_DaysToLookBack                 = "",
  admin_isFullTenantInventory                          = "",
  admin_MakerDataflowID                                = "",
  admin_ModelAppDataflowID                             = "",
  admin_PowerAppEnvironmentVariable                    = "",
  admin_PowerAppPlayerEnvironmentVariable              = "",
  admin_PowerAutomateEnvironmentVariable               = "",
  admin_PowerPlatformMakeSecurityGroup                 = "",
  admin_PowerPlatformUserGroupID                       = "",
  admin_ProductionEnvironment                          = "",
  admin_SyncFlowErrorsDeleteAfterXDays                 = "",
  admin_TenantID                                       = "",
  admin_UserPhotosForbiddenByPolicy                    = "",
  coe_EnvironmentRequestAdminAppUrl                    = "",
}

```