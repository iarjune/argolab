# Start port-forward in the background
# kubectl -n argocd port-forward svc/argocd-server 8443:443 >/tmp/argocd-pf.log 2>&1 &
# PF_PID=$!
# trap "kill $PF_PID" EXIT
# sleep 3

# Check if app exists before creating it again
# the goal of cicd with argo is to launch a service after a build.  
# THe pipeline will trigger a argo wf with the following params.  These params are passed to create the deployment configs and app in argocd.
#   service name
#   service version

# The pipeline steps
# Checkout project
# Import cicd.properties
#   DEPLOY_KIND = deployment
#   DEPLOY_DATACENTERS=ric1,pdx1
#   DEPLOY_ENVS = dev,stage
#   DEPLOY_DECOM=false
#   DEPLOY_VARIANT=false
# Checkout cd-deploy-configs
# Check if deployment config exists, if not create it in cd-deploy-configs/apps/<service name>/dev-ric1/
# Checkout cd-releases
# Check if app exists, if not create it in cd-releases/dev/ric1/dev-<service name>.yaml
# The image tag is configured with the app manifest
# Deploy the app to argocd



# Deployment defaults: 
# * dest-server: dev ric1
# * dest-namespace: dev
# * sync-policy is automated
# * auto-prune is true
# * self-heal is true
# * sync-option CreateNamespace is true


ARGOCD_AUTH_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJjaWNkOmFwaUtleSIsIm5iZiI6MTc2NTIyODA5MCwiaWF0IjoxNzY1MjI4MDkwLCJqdGkiOiI2MDg5ZGUyMC1jYjQ4LTQ5NjgtODQ1Yy01NjU3NmIyMTNjNTYifQ.OUX3ob5Ya09xD-VMipEtwGGmJxijtDs_73bHI6MRjZw"

# Use token instead of username/password
ARGOCD_SERVER="localhost:8443"
ARGOCD_AUTH_TOKEN="$ARGOCD_AUTH_TOKEN"   # from CI secret
APP_NAME="test-app"

argocd app create test-app \
  --server "$ARGOCD_SERVER" \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --insecure \
  --project default \
  --repo https://github.com/iarjune/argolab.git \
  --revision main \
  --path apps/test-app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal \
  --sync-option CreateNamespace=true


# argocd app set argocd/test-app --kustomize-image nginx:1.25-alpine

argocd app sync "$APP_NAME" \
  --server "$ARGOCD_SERVER" \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --insecure \
  --prune --timeout 600


argocd app wait "$APP_NAME" \
  --server "$ARGOCD_SERVER" \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --insecure \
  --sync --health --timeout 600
