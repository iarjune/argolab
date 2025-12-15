# install argocd cli
VERSION=v3.2.1
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

#insecure mode patch
kubectl -n argocd patch svc argocd-server \
  -p '{"spec": {"ports": [{"name": "http", "port": 80, "targetPort": 8080}]}}'

#patch the deployment to disable TLS:
kubectl -n argocd patch deployment argocd-server   -p '{"spec": {"template": {"spec": {"containers": [{"name": "argocd-server", "args": ["/usr/local/bin/argocd-server","--insecure"]}]}}}}'

#Wait for rollout:
kubectl -n argocd rollout status deploy/argocd-server

# Add cicd user account
# kubectl -n argocd patch configmap argocd-cm \
#   --type merge \
#   -p '{"data":{"accounts.cicd":"apiKey"}}'


#Admin password  
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

#GUI  and API Port Forward
kubectl -n argocd port-forward svc/argocd-server 8888:80
kubectl -n argocd port-forward svc/argocd-server 8443:443

firefox localhost:8888

# Login and Gen the Token for the script
argocd login localhost:8443 --insecure

# Now generate a token for the new account: 
# argocd account generate-token --account cicd

# Set the ARGOCD_AUTH_TOKEN var

# argocd app set argocd/argo-bash --server "${ARGOCD_SERVER}" --auth-token "${ARGOCD_AUTH_TOKEN}"  --plaintext  --kustomize-image argo:latest
