

### Wie einloggen?
```shell
# User
az login 

# Service Principal
az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant>

# In Subscription wechseln
az account set --subscription "Subscription Name";
```


### Neuen Service Principal anlegen 
https://learn.microsoft.com/en-us/cli/azure/azure-cli-sp-tutorial-1?tabs=bash
```shell
az ad sp create-for-rbac --name myServicePrincipalName2 --role reader --scopes \
    /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myRG1 \
    /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myRG2/providers/Microsoft.Compute/virtualMachines/myVM
```


### AKS Service Principal Secret erneuern:
```shell
az aks update-credentials \
    --resource-group <cluster-resource-group> \
    --name <cluster-name> \
    --reset-service-principal \
    --service-principal <app id> \
    --client-secret 'secret'
```


### Kube-Config erzeugen:
```shell
az aks get-credentials --name <cluster name> --resource-group <cluster resource group>
```
