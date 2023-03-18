In this repository, there are the main three files necessary to create a secret in a kubernetes cluster from an external secret management system (AWS SECRET MANAGER), as well as a shell script containing the kubernetes commands to retrieve the secret values from the kubernetes cluster.

1- ADD HELM CHART REPO AND INSTALL THE ESO CHART IN YOUR NAMESPACE IN THE CLUSTER 
The first thing is to install the ESO (External Secret Operator) CHART in the cluster. It will help kubernetes to manage the CRDs created as the native kubernetes objects. To do that:
  add the external-secrets helm chart repo to your environment using the following command: 
helm repo add external-secrets https://charts.external-secrets.io
  list the charts you can install using the following command:
helm search repo external-secrets
  install the chart external-secrets/external-secrets in your namespace using the following command:
helm install <release-name> external-secrets/external-secrets --namespace <your-namespace>
  
2- INSTALL THE CRD IN YOUR NAMESPACE
  install the three yaml files in your namespace using kubectl. You can also attach those file to your helm chart e.g. dependencies and install at once with helm using the following command:
kubectl create --namespace <your-namespace> -f secret-for-aws.yaml,secretstore.yaml,external-secret.yaml

3- CHECK THE VALUES OF THE SECRET IN THE CLUSTER AND COMPARE TO THE ONES IN THE EXTERNAL SECRET MANAGER SYSTEM. EDIT THE SECRET IN THE EXTERNAL SECRET MANAGER SYSTEM AND CHECK THE CHANGE IN THE KUBERNETES CLUSTER
  execute the script get-secret.sh to retrieve the value of the secret using the following command:
bash get-secret.sh
Edit the secret values in AWS SM, wait a little more than one minute and execute the script get-secret.sh again to ensure that the values of the secret have changed in the cluster. This is a proof that the secret in the cluster reconcile automatically with the external secret ibn AWS SM.

