# !!!!!!!!!!
# Only do these steps if the above Service Principal Role Assignment fails.
# !!!!!!!!!!

 

# Extract Container Registry details needed for Login
# Login Server
az acr show -n scopsbenchmark --query scopsbenchmark.azurecr.io -o table
# Enable ACR admin
az acr update -n scopsbenchmark --admin-enabled true
# Registry Username and Password
az acr credential show -n scopsbenchmark


# Use the login and credential information from above
# USE BELOW AFTER NAME SPACE IS CREATED
kubectl create -n <namespace name>  secret docker-registry regcred \
--docker-server="<docker registry name>" \
--docker-username="<user>" \
--docker-password="<passwd>"
# !!!!!!!!!!
# Only do these steps if the above Service Principal Role Assignment fails.
# !!!!!!!!!!
