#!/bin/bash
# To run the test execute run-sta-test.sh
# ./run-sta-test.sh <resoruce-group-name> <AKS-Cluser-Name> <Node-Pool-Name> <VM-SKU>
# eg. ./run-stat-test.sh k8s cluster m128 Standard_M128

# Create the group
az group create --name $1 --location eastus

# Create AKS Cluster
# az aks create --resource-group hpccops-testrg001 --name aks-hpcc --node-vm-size Standard_H16 --node-count 2 --enable-managed-identity
az aks create -g  $1 -n --cluster-name $3 --enable-managed-identity

#create new nodepool
az aks nodepool add -g $1 --cluster-name $2 --name $3 --node-vm-size $4 --node-count 1 --mode User --labels allow-stat-test=True kubernetes.azure.com/aks-local-ssd=True --no-wait

# Get nodepool status
nodepool_status=""
while [ "$nodepool_status" != "Succeeded" ];do
    nodepool_status=$(az aks nodepool show -g $1 --cluster-name $2 --name $3   --query provisioningState -o tsv);
    echo "Nodepool $3 Provisioning state: $nodepool_status...";
    sleep 5;
done;

# Get Creds
az aks get-credentials -g $1 -n $2

# Docker login
docker login aksbenchmarkregistry.azurecr.io

# Create Name Space
kubectl create namespace $3

# Make sure the name space can access the Docker registry

# Apply Kubernetes Manifests
kubectl apply -f ../lcl-strg-prvsn/storage-local-static-provisioner.yaml

sleep 3s

kubectl apply -f . -n $3

Pod_status=""
while [ "$Pod_status" != "Running" ];do
    Pod_status=$(kubectl get pods -l job-name=statjob  -n $3  -o jsonpath="{.items[*].status.phase}");
    echo "Pod state: $Pod_status...";
done;

for pod in $(kubectl get pod -n $3  -l job-name=statjob| grep statjob | awk '{print $1}') ; do
    kubectl logs -f $pod -n $3 | tee $4-$pod.log;
done

cat  $4-$pod.log| grep Finished_Tests
if [ $? -eq 0 ]
then
kubectl delete -f . -n $3 && kubectl delete namespace $3 && az aks nodepool delete -g $1 --cluster-name $2 --name $3 --no-wait
echo "Finished tests"
fi
cat  $4-$pod.log||egrep "cat|CPU Run|threads:|Prime numbers limit:|events per second:|total time:|total number of events:|min:|avg:|max:|approx.  95 percentile:|Sequential Reads|READ:|Sequential Writes|WRITE:" > summary.log

# Finally Delete AKS cluster
az aks delete  -g  $1 -n  $3 
