# Kargo Lab
# CLI
 wget https://github.com/akuity/kargo/releases/download/v1.8.4/kargo-linux-amd64
 chmod +x kargo-linux-amd64
 sudo mv kargo-linux-amd64 /usr/local/bin/kargo

# Auth
iarjune@fedora:~/git/argolab/k3d/kargo$ pass="$(openssl rand -base64 48 | tr -d '=+/' | head -c 24)"
echo "ADMIN_PASSWORD=$pass"
ADMIN_PASSWORD=AbZoD9a4EtNlMLJLtHhuMJMe
iarjune@fedora:~/git/argolab/k3d/kargo$ hash="$(htpasswd -bnBC 10 "" "$pass" | tr -d ':\n')"
echo "PASSWORD_HASH=$hash"
PASSWORD_HASH=$2y$10$rWZraAj.rDzP.FA6epyKZ.FerftB0IPdf9mZnGMmOx1wDY0ta0QP.
iarjune@fedora:~/git/argolab/k3d/kargo$ key="$(openssl rand -base64 48 | tr -d '=+/' | head -c 32)"
echo "TOKEN_SIGNING_KEY=$key"
TOKEN_SIGNING_KEY=E2sigQSHva7IIjDCgCCOZuYvbDHooiEU

The server install is in /apps/kargo-server

# Watch promotions
kubectl get promotions -n kargo-simple -w
# Watch workflows
kubectl get workflows -n kargo-simple -w
# Check workflow logs
kubectl logs -n kargo-simple -l workflows.argoproj.io/workflow=<workflow-name> -f