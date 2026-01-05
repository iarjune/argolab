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
# kubectl apply -f git-clone-template.yaml -n argo
# kubectl apply -f argocd-set-image-template.yaml -n argo

# Example: Submit git-clone workflow
# argo submit --from workflowtemplate/git-clone-template -n argo \
#   -p bb_user="" \
#   -p bb_token="" \
#   -p git_repo="cd-deploy-configs" \
#   -p branch="master"

# Example: Submit argocd-set-image workflow
# argo submit --from workflowtemplate/argocd-set-image-template \
#   -p argocd_server="argocd-server.argocd:80" \
#   -p app_name="argocd/test-app" \
#   -p image="nginx:1.25-alpine"

# kubectl -n argo create secret docker-registry dockerhub-creds \
#   --docker-server="https://index.docker.io/v1/" \
#   --docker-username="YOUR_DOCKERHUB_USERNAME" \
#   --docker-password="YOUR_ACCESS_TOKEN" \
#   --docker-email="you@example.com"
