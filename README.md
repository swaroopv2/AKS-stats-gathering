
## Pre requisites 
1. AKS Cluster, or you can have it created as well. Uncomment line  ```az aks create -g  $1 -n --cluster-name $3 ``` in [file](/automation/stat/run-stat-test.sh)
2. Create [AZURE_CREDENTIALS](https://github.com/Azure/login#configure-deployment-credentials) in GitHub secrets

## CPU and Storage tests on AKS

To run CPU and Storage Test update and commit [run-test-for](/automation/stat/run-test-for.txt) in below format

```<Resource-Group-Name> <AKS-Cluster-Name> <Kubernetes-Namespace-Name> <Nodepool-VM-SKU>```

eg. AKS kluster m128r Standard_M128

Once changes to this file are committed , the Github Actions would start , which will create the nodedepool/namespace and will also execute the tests. It filnanly delete the nodepool/kubernetes resources created for the tests.

Tests Included:

1. CPU Testing using  ```sysbench```
2. Sequential Reads on NODE's OS disk using ```fio```
3. Sequential Writes on NODE's OS disk using  ```fio```
4. Sequential Reads on NODE's TEMP disk using  ```fio```
1. Sequential Writes on NODE's TEMP disk using  ```fio```
1. Sequential Reads in a debian POD AZURE Files Standard using ```fio```
1. Sequential Writes in debian POD AZURE Files Standard ```fio```
1. Sequential Reads in a debian POD AZURE Files Premium ```fio```
1. Sequential Writes in debian POD AZURE Files Premium using ```fio```

Results: 
The results for each run can be found under Artifacts section of each run. [Here](https://github.com/krishnaji/AKS-stats-gathering/actions)

Configs:

To increase Azure Files Standard and Premium storage capacity update below section in [Azure-Files-PVC](/automation/stat/azure-file-pvc.yaml)
```yml
 resources:
    requests:
      storage: 128Gi
```

To increase OS Disk size on Nodes update below [node pool parameter](/automation/stat/run-stat-test.sh)
```bash
--node-osdisk-size 128 
```

Note: Updates to below section would need docker build/push and updates  to stat.yaml.

To execute same test multiple times update below section in [Tests](/automation/stats/stat-run.sh) file
```bash
for i in {1..1}
```

Below are defults that run as part of the tests.
Sysbech
```bash 
sysbench  --test=cpu  --cpu-max-prime=20000 run
```
Fio
```bash
fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=8 --size=1G --runtime=600  --group_reporting
```
To make --size dynamic based on the avilable Node Memory update --size parameter as below. [eg](https://github.com/krishnaji/AKS-stats-gathering/blob/6ac2e3a28ea3c4806140ccba4b73bb754e56eb04/automation/stat/stat-run.sh#L35) here the --size is twice the total memory on the node
```bash
--size=$(($(grep MemTotal /proc/meminfo|awk '{print $2}') * 2))K
```