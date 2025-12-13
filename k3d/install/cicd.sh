# the goal of cicd with argo is to launch a service after a build.  

# TODO: 
# Workflow Inputs
#   DEPLOY_KIND = deployment
#   DEPLOY_DATACENTERS=ric1,pdx1
#   DEPLOY_ENVS = dev,stage
#   DEPLOY_DECOM=false
#   DEPLOY_VARIANT=false

# add secret for bb token 
# Add docker registry for amp
# clone cd-deploy-configs
# Check if configs app exists before creating it again
# THe pipeline will trigger a argo wf with the following params.  These params are passed to create the deployment configs and app in argocd.
#   service name
#   service version

# set ARGOCD_AUTH_TOKEN 
 
# Checkout cd-deploy-configs
# Check if deployment config exists, if not create it in cd-deploy-configs/apps/<service name>/dev-ric1/
# Checkout cd-releases
# Check if app exists, if not create it in cd-releases/dev/ric1/dev-<service name>.yaml
# The image tag is configured with the app manifest
# Deploy the app to argocd




ARGOCD_SERVER="localhost:8443"
APP_NAME="test-app"

argocd app create test-app \
  --server "$ARGOCD_SERVER" \
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
