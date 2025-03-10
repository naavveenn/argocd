# Canary Deployment with ArgoCD and Argo Rollouts on Minikube  

## 1. Deploy the ArgoCD App

Apply the application.yaml 
```sh
kubectl apply -f application.yaml

This will create the application in ArgoCD and will deploy the resources like argo-rollout, pods, svc and ingress.
```  
Once all pods are running and the ingress is up, start a Minikube tunnel in a separate terminal:  
```sh
# For ArgoCD Dashboard
minikube service -n argocd argocd-server --url
kubectl get secret -n argocd argocd-initial-admin-secret -o yaml
argocd login 127.0.0.1:58584 --insecure

# For Argo Rollout
minikube tunnel
kubectl argo rollouts dashboard

It will give the below output (port may vary):
Argo Rollouts Dashboard is now available at http://localhost:3100/rollouts
```  

---

## 2. Verify the Deployment  

Run the following `curl` command to check if the application is accessible:  
```sh
curl --resolve "rollouts-setweight.demo:80:127.0.0.1" -i http://rollouts-setweight.demo
```  
You should receive a **200 OK** response.  

Add the following entry to your `/etc/hosts` file:  
```sh
127.0.0.1 rollouts-setweight.demo
```  

Test again:  
```sh
curl http://rollouts-setweight.demo
```  
You should still receive a **200 OK** response. Open your browser and visit:  
```sh
http://rollouts-setweight.demo
```  

```sh
Run below command to open the argo-rollout dashboard:

kubectl argo rollouts dashboard

It will give the below output (port may vary):

Argo Rollouts Dashboard is now available at http://localhost:3100/rollouts
```

---

## 3. Testing Canary Deployment  

Modify `app/dev/service/demo/custom-values.yaml` to update the `html_name` environment variable:  
```yaml
env:
  html_name: "app-v2.html"
```  
Push the changes:  
```sh
git add .
git commit -m "Updated the env variable"
git push
```  

### ArgoCD will attempt to sync the changes based on the Argo Rollout configuration. Since the rollout includes an **infinite pause**, ArgoCD will pause after shifting **20% of the traffic** (visible in the ArgoCD dashboard). At this point, manual intervention is required to **promote the rollout** via the Argo Rollouts dashboard. Once promoted, the updated version will be deployed gradually, following the **canary deployment strategy** defined in the rollout configuration.


