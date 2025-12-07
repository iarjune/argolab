install argocd cli
VERSION=v3.2.1
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash  
k3d cluster create argocd-lab --servers 1 --agents 1 --port 8081:80@loadbalancer >> run.sh 
kubectl apply -n argocd   -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get nodes

#The default Argo CD server listens on HTTPS, but we want to use k3d LB on 8080 cleanly.

#insecure mode patch
kubectl -n argocd patch svc argocd-server \
  -p '{"spec": {"ports": [{"name": "http", "port": 80, "targetPort": 8080}]}}'

#patch the deployment to disable TLS:
kubectl -n argocd patch deployment argocd-server \
  -p '{"spec": {"template": {"spec": {"containers": [{"name": "argocd-server", "args": ["--insecure"]}]}}}}'

#Wait for rollout:
kubectl -n argocd rollout status deploy/argocd-server

#Admin password  3WpZmCZrGqZI6HQZ
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

#GUI 
kubectl -n argocd port-forward svc/argocd-server 8888:80
firefox localhost:8888

# Generate an API token for cicd
kubectl -n argocd port-forward svc/argocd-server 8443:443
argocd login localhost:8443 --insecure

# Now generate a token for the new account: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJjaWNkOmFwaUtleSIsIm5iZiI6MTc2NTA4MzkxMywiaWF0IjoxNzY1MDgzOTEzLCJqdGkiOiJkNmZlZGM0NC1mMmZlLTRjMjQtODIyOC0yNzI5MDIyMWZmMGMifQ.qA_J9o-Pxo-oDef_Io8k5qNSjTVH1CB7XlNUnlAQ5uM
argocd account generate-token --account cicd

# Set the ARGOCD_AUTH_TOKEN var


