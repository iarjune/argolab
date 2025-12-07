# Start port-forward in the background
# kubectl -n argocd port-forward svc/argocd-server 8443:443 >/tmp/argocd-pf.log 2>&1 &
# PF_PID=$!
# trap "kill $PF_PID" EXIT
# sleep 3

ARGOCD_AUTH_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJjaWNkOmFwaUtleSIsIm5iZiI6MTc2NTA4MzkxMywiaWF0IjoxNzY1MDgzOTEzLCJqdGkiOiJkNmZlZGM0NC1mMmZlLTRjMjQtODIyOC0yNzI5MDIyMWZmMGMifQ.qA_J9o-Pxo-oDef_Io8k5qNSjTVH1CB7XlNUnlAQ5uM"

# Use token instead of username/password
ARGOCD_SERVER="localhost:8443"
ARGOCD_AUTH_TOKEN="$ARGOCD_AUTH_TOKEN"   # from CI secret
APP_NAME="my-app"

# With token auth, skip login and pass --auth-token directly to each command:
echo sync
argocd app sync "$APP_NAME" \
  --server "$ARGOCD_SERVER" \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --insecure \
  --prune --timeout 600

echo wait
argocd app wait "$APP_NAME" \
  --server "$ARGOCD_SERVER" \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --insecure \
  --sync --health --timeout 600
