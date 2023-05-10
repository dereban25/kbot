# Automatically Deploying Applications to Kubernetes with ArgoCD

ArgoCD is a continuous delivery and deployment tool for Kubernetes that enables users to automate the deployment of their applications from a Git repository to a Kubernetes cluster. With ArgoCD, users can define an application in a declarative manner using Kubernetes manifests, which are then automatically deployed and synced with the Git repository whenever changes are made.

## Setting Up ArgoCD

Before deploying applications with ArgoCD, you must first set up ArgoCD on your Kubernetes cluster. The following steps provide a general overview of the ArgoCD installation process:

1. Install the ArgoCD operator by running the following command:
   ```
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. Expose the ArgoCD server by running the following command:
   ```
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

3. Log in to the ArgoCD web interface using the default username and password:
   ```
   Username: admin
   Password: <output of kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo>
   ```

## Deploying Applications with ArgoCD

Once ArgoCD is set up, you can start deploying your applications to your Kubernetes cluster using ArgoCD. The following steps provide a general overview of how to automatically deploy an application from a Git repository to a Kubernetes cluster with ArgoCD:

1. Create a Git repository that contains the Kubernetes manifests for your application.

2. Create an ArgoCD application YAML file that defines the configuration for your application. This YAML file should specify the Git repository URL, target revision, and path to the Kubernetes manifest files for your application.

   ```yaml
   ---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
    name: my-app
    namespace: argocd
spec:
  project: default
  destination:
      server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/den-vasyliev/go-demo-app.git
    targetRevision: HEAD
    path: helm
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
   ```

3. Apply the ArgoCD application YAML file to your Kubernetes cluster using the `kubectl apply` command.

   ```
   kubectl apply -f argocd-app.yaml
   ```

4. Once the application is deployed, any changes made to the Git repository will automatically be synced with the deployed application. This means that any changes made to the Kubernetes manifests in the Git repository will automatically be applied to the deployed application.

## Conclusion

ArgoCD is a powerful tool that can greatly simplify the process of deploying applications to a Kubernetes cluster. By automating the deployment and synchronization of applications from a Git repository to a Kubernetes cluster, ArgoCD enables developers to focus on writing code and making changes to their applications, rather than worrying about the deployment process.