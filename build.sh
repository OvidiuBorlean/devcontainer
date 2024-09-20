docker build -t devcontainer .
TOKEN=$(az acr login --name myregistry.azurecr.io --expose-token --output tsv --query accessToken)
docker login myregistry.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password-stdin <<< $TOKEN
docker tag devcontainer myregistry.azurecr.io/devcontainer
docker push cmyregistry.azurecr.io/devcontainer

