# azure_arm_templates
az ad sp create-for-rbac --name "hellentests" --role contributor \
                            --scopes /subscriptions/<id>/resourceGroups/<group> \
                            --json-auth

ref https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-github-actions?tabs=userlevel#code-try-0