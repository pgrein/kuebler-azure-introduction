# After first checkout

```shell
terraform init
```

# Perform Terraform planning

```shell
bin/tf-plan
```

# Apply the plan

```shell
bin/tf-apply
```



# Kubernetes Config

### Mac / Linux / MinGW / Cygwin Setups Only: Update Admin Kube-Config


Put this in `.bashrc`:
```shell
export KUBECONFIG=$(echo $(ls ~/.kube/config*) | awk '{ gsub(/ /,":");print}')
```

Retrieve and write this clusters kube-config:
```shell
terraform output -raw kube_config > ~/.kube/config-test-cluster
source ~/.bashrc
```



# Destroy created infrastructure
```shell
bin/tf-destroy
```
