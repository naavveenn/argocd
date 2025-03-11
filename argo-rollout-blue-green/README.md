# Blue-Green Deployment with Argo Rollouts on Minikube  

## 1. Install Argo Rollouts  

### Install Argo Rollouts Controller  
Create a new namespace and deploy Argo Rollouts:  
```sh
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```  
This creates the **argo-rollouts** namespace where the Argo Rollouts controller will run.  

### Install the Kubectl Plugin  

#### **Using Homebrew (Recommended for macOS)**  
```sh
brew install argoproj/tap/kubectl-argo-rollouts
```  

#### **Manual Installation**  
```sh
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-darwin-amd64
```  
For Linux distributions, replace **darwin** with **linux**.  

Make the binary executable and move it to `/usr/local/bin`:  
```sh
chmod +x ./kubectl-argo-rollouts-darwin-amd64
sudo mv ./kubectl-argo-rollouts-darwin-amd64 /usr/local/bin/kubectl-argo-rollouts
```  

Verify the installation:  
```sh
kubectl argo rollouts version
```  

---

## 2. Build and Load the Docker Image  

Build the Docker image locally:  
```sh
cd blue-green-app
docker build -t blue-green .
docker images |grep 'blue-green'
```  
Since the image is stored locally, it won’t be available inside Minikube. Load it into Minikube:  
```sh
minikube image load blue-green:latest
minikube ssh
docker images |grep 'blue-green'

# Enable ingress on minikube
minikube addons enable ingress
kubectl get pods -n ingress-nginx
```  

---

## 3. Deploy the Application  

Apply the deployment and ingress configurations:  
```sh
cd blue-green-manifests
kubectl apply -f rollout.yaml
kubectl apply -f ingress.yaml
```  
Once all pods are running and the ingress is up, start a Minikube tunnel in a separate terminal:  
```sh
minikube tunnel
```  

---

## 4. Verify the Deployment  

Run the following `curl` command to check if the application is accessible:  
```sh
curl --resolve "blue-green.demo:80:127.0.0.1" -i http://blue-green.demo
```  
You should receive a **200 OK** response.  

Add the following entry to your `/etc/hosts` file:  
```sh
127.0.0.1 blue-green.demo
```  

Test again:  
```sh
curl http://blue-green.demo
```  
You should still receive a **200 OK** response. Open your browser and visit:  
```sh
http://blue-green.demo
```  

```sh
Run below command to open the argo-rollout dashboard
kubectl argo rollouts dashboard
It will give the below output (port might vary)
Argo Rollouts Dashboard is now available at http://localhost:3100/rollouts
```

---

## 5. Testing Blue-Green Deployment  

Modify `rollout.yaml` to update the `html_name` environment variable:  
```yaml
env:
  - name: html_name
    value: "app-v2.html"
```  
Apply the changes:  
```sh
kubectl apply -f rollout.yaml
```  

### Argo Rollouts Behavior  
- **Revision 1** → **Stable & Active**  
- **Revision 2** → **Preview Mode (Not Active Yet)**  

Since `autoPromotionEnabled: false` is set in `rollout.yaml`, the new revision is **not automatically promoted** and must be promoted manually.  

### **Promote the New Deployment**  
#### From CLI:  
```sh
kubectl argo rollouts list rollout
kubectl argo rollouts promote <rollout-name>
```  
#### From Dashboard:  
Click **Promote** in the upper right corner.  

---

## 6. Rolling Back to a Previous Version  

If you need to roll back:  
1. Click **Rollback** in the Argo Rollouts dashboard.  
2. New pods will be created for the previous revision (`blue`), but the app will still be serving the current version (`green`).  
3. Once the rollback pods are up and running, click **Promote** to complete the rollback.  

---

## 7. How Argo Rollouts Tracks Releases  

Argo Rollouts uses **selectors with unique hash values** to manage active and preview versions. These hash values determine which revision is active and can be viewed in the dashboard.  

> **By following this approach, you ensure smooth blue-green deployments with controlled rollouts and rollback capabilities in Minikube using Argo Rollouts.** 

