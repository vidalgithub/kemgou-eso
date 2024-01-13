WHAT IS ESO?   

The Kubernetes External Secrets Operator (ESO) is like a secret agent responsible for securely fetching and injecting secrets into Kubernetes pods. To understand how it works, let's delve into the concepts of ExternalSecrets and SecretStores.

ExternalSecret:
1. Definition: An ExternalSecret is a custom resource in Kubernetes that represents a reference to an external secret stored outside the cluster.
2. Purpose: It allows you to declare secrets in Kubernetes without exposing the actual sensitive information. Instead, it acts as a pointer or reference to where the real secret is stored.
3. Example: You might create an ExternalSecret that points to a secret stored in a cloud provider's secret manager, like AWS Secrets Manager or HashiCorp Vault.

SecretStore:
1. Definition: A SecretStore is another custom resource in Kubernetes that defines the connection details and authentication needed to access a specific external secret manager platform.
2. Purpose: It serves as a configuration file for ESO, telling it how to communicate with the external secret manager.
3. Example: If your secrets are stored in AWS Secrets Manager, you'd create a SecretStore that contains the AWS credentials and details on how to interact with Secrets Manager.
How They Work Together:
1. Declaration: You declare an ExternalSecret in your Kubernetes cluster, specifying the name, type, and other details. This ExternalSecret doesn't contain the actual secret data.
2. Association: You associate the ExternalSecret with a SecretStore. This tells ESO where to look for the actual secret.
3. ESO Action: The ESO monitors the ExternalSecrets and SecretStores. When it sees a new ExternalSecret associated with a SecretStore, it knows where to look for the real secret.
4. External Secret Fetching: ESO uses the information in the SecretStore to securely communicate with the external secret manager platform. It fetches the actual secret data.
5. Injection into Pods: Once ESO has the secret, it injects it into the specified Kubernetes pods that reference the ExternalSecret. This injection can happen as environment variables, files, or other forms, based on your configuration.

   
Benefits:      

• Centralized Management: Secrets can be managed externally, allowing for centralized control and security policies.   

• Decoupling: ExternalSecrets decouple the declaration of secrets from their actual storage, promoting a cleaner and more secure approach.   

• Dynamic Updates: ESO can dynamically update secrets in pods when they change externally, without requiring manual intervention.   


In summary, ESO acts as a liaison between your Kubernetes cluster and external secret managers. ExternalSecrets represent references to actual secrets, while SecretStores provide the necessary connection details. ESO fetches the secrets securely and injects them into your pods, simplifying secret management in Kubernetes.

_____________________________________________



EXAMPLE OF ESO SETTING UP WITH YAML FILES
 
Here's an example set of YAML files for managing credentials (username and password) stored in AWS Secrets Manager using the Kubernetes External Secrets Operator (ESO). Please note that you need to install the ESO in your cluster before using these resources.

Ensure Helm is Installed:
ESO is often deployed using Helm charts. Ensure that Helm is installed in your Kubernetes cluster. You can install Helm by following the instructions on https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets.

Add the External Secrets Helm Repository:
Add the External Secrets Helm repository to Helm:
helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
helm repo update

Install the External Secrets Helm Chart:
Install the External Secrets Operator using Helm:
helm install external-secrets external-secrets/kubernetes-external-secrets
Replace external-secrets with the desired release name.

Verify the Installation:
After installation, you can verify the status of the External Secrets Operator and its components using the following commands:
kubectl get pods -n external-secrets
kubectl get crd -o wide
Ensure that the pods are running, and the Custom Resource Definitions (CRDs) are present.


1. Create SecretStore YAML file (aws-secretstore.yaml):

![image](https://github.com/vidalgithub/kemgou-eso/assets/88409846/da77429a-ad32-4190-a919-0a8fa31d854b)

apiVersion: kubernetes-client.io/v1
kind: SecretStore
metadata:
  name: aws-secretstore
spec:
  provider: aws
  parameters:
    region: us-east-1
    accessKeyID: YOUR_AWS_ACCESS_KEY
    secretAccessKey: YOUR_AWS_SECRET_KEY!

Replace YOUR_AWS_ACCESS_KEY and YOUR_AWS_SECRET_KEY with your actual AWS credentials.


2. Create ExternalSecret YAML file (aws-externalsecret.yaml):

![image](https://github.com/vidalgithub/kemgou-eso/assets/88409846/ea3e2db6-eb42-4ae2-8be2-1fbef0d1cd27)

apiVersion: kubernetes-client.io/v1
kind: ExternalSecret
metadata:
  name: aws-credentials
spec:
  provider: aws
  secretDescriptor:
    - key: username
      name: my-secret-username
      version: AWSPREVIOUS
    - key: password
      name: my-secret-password
      version: AWSPREVIOUS
  target: my-pod
  refreshInterval: 1h
This ExternalSecret references the AWS SecretStore, specifies the keys (username and password), and sets the target as my-pod.


3. Deployment YAML file (my-pod-deployment.yaml):

![image](https://github.com/vidalgithub/kemgou-eso/assets/88409846/9158449f-5f92-46b2-a96b-512819f15a74)

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-pod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-pod
  template:
    metadata:
      labels:
        app: my-pod
    spec:
      containers:
      - name: my-container
        image: my-image:latest
        env:
        - name: MY_USERNAME
          valueFrom:
            secretKeyRef:
              name: aws-credentials
              key: username
        - name: MY_PASSWORD
          valueFrom:
            secretKeyRef:
              name: aws-credentials
              key: password


This Deployment specifies a pod (my-pod) that uses the credentials from the ExternalSecret (aws-credentials) as environment variables (MY_USERNAME and MY_PASSWORD).


Note:

Ensure that you have the AWS credentials (accessKeyID and secretAccessKey) provided in the SecretStore.
Replace placeholders like my-image:latest and adjust other details based on your actual deployment requirements.
Remember to apply these YAML files to your Kubernetes cluster using the kubectl apply -f filename.yaml command. Ensure that the ESO is installed in your cluster and properly configured to work with AWS Secrets Manager.




_____________________________________________


EXAMPLE SETUP OF ESO IN THIS REPO:   

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

