install argocd cli
VERSION=v3.2.1
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash  
k3d cluster create argocd-lab --servers 1 --agents 1 --port 8081:80@loadbalancer
kubectl apply -n argocd   -f install.yaml # https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get nodes

#The default Argo CD server listens on HTTPS, but we want to use k3d LB on 8080 cleanly.

#insecure mode patch
kubectl -n argocd patch svc argocd-server \
  -p '{"spec": {"ports": [{"name": "http", "port": 80, "targetPort": 8080}]}}'

#patch the deployment to disable TLS:
kubectl -n argocd patch deployment argocd-server   -p '{"spec": {"template": {"spec": {"containers": [{"name": "argocd-server", "args": ["/usr/local/bin/argocd-server","--insecure"]}]}}}}'

#Wait for rollout:
kubectl -n argocd rollout status deploy/argocd-server

# Add cicd user account
kubectl -n argocd patch configmap argocd-cm \
  --type merge \
  -p '{"data":{"accounts.cicd":"apiKey"}}'


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
argocd account generate-token --account cicd

# Set the ARGOCD_AUTH_TOKEN var

# Deploy argo workflow
kubectl create namespace argo
kubectl -n argo apply -f https://github.com/argoproj/argo-workflows/releases/download/v3.5.0/install.yaml
kubectl -n argo patch deployment argo-server --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": ["server","--auth-mode=server"]}]'
kubectl -n argo patch svc argo-server -p '{"spec": {"type": "NodePort"}}'
kubectl -n argo port-forward svc/argo-server 2746:2746

firefox localhost:2746

# TEST
argo submit -n argo --watch https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml

# Apply workflow templates
kubectl apply -f git-clone-template.yaml -n argo
kubectl apply -f argocd-set-image-template.yaml -n argo

# Example: Submit git-clone workflow
argo submit --from workflowtemplate/git-clone-template -n argo \
  -p bb_user="" \
  -p bb_token="" \
  -p git_repo="cd-deploy-configs" \
  -p branch="master"

# Example: Submit argocd-set-image workflow
argo submit --from workflowtemplate/argocd-set-image-template \
  -p argocd_server="argocd-server.argocd:80" \
  -p app_name="argocd/test-app" \
  -p image="nginx:1.25-alpine"

kubectl -n argo create secret docker-registry dockerhub-creds \
  --docker-server="https://index.docker.io/v1/" \
  --docker-username="YOUR_DOCKERHUB_USERNAME" \
  --docker-password="YOUR_ACCESS_TOKEN" \
  --docker-email="you@example.com"

argocd app set argocd/argo-bash --server "${ARGOCD_SERVER}" --auth-token "${ARGOCD_AUTH_TOKEN}"  --plaintext  --kustomize-image argo:latest

<<<<<<< HEAD

Kargo
iarjune@fedora:~/git/argolab/k3d/kargo$ pass="$(openssl rand -base64 48 | tr -d '=+/' | head -c 24)"
echo "ADMIN_PASSWORD=$pass"
ADMIN_PASSWORD=AbZoD9a4EtNlMLJLtHhuMJMe
iarjune@fedora:~/git/argolab/k3d/kargo$ hash="$(htpasswd -bnBC 10 "" "$pass" | tr -d ':\n')"
echo "PASSWORD_HASH=$hash"
PASSWORD_HASH=$2y$10$rWZraAj.rDzP.FA6epyKZ.FerftB0IPdf9mZnGMmOx1wDY0ta0QP.
iarjune@fedora:~/git/argolab/k3d/kargo$ key="$(openssl rand -base64 48 | tr -d '=+/' | head -c 32)"
echo "TOKEN_SIGNING_KEY=$key"
TOKEN_SIGNING_KEY=E2sigQSHva7IIjDCgCCOZuYvbDHooiEU


Create project kgo-project
Add git secret for git creds in the projects namespace

apiVersion: v1
kind: Secret
metadata:
  name: git-creds
  namespace: kgo-project
  labels:
    kargo.akuity.io/cred-type: git
stringData:
  repoURL: https://github.com/<org>/<repo>.git
  username: <anything-often-ok>
  password: <PAT-or-password>
=======
>>>>>>> cd42458115297f496ded7f8c3d2d4204d1ffc607
