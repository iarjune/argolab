kubectl -n argo port-forward svc/argo-server 2746:2746 &>/dev/null &
kubectl -n argocd port-forward svc/argocd-server 8888:80 &>/dev/null &
kubectl -n argocd port-forward svc/argocd-server 8443:443 &>/dev/null &
kubectl -n kargo port-forward svc/kargo-api 31444:443 &>/dev/null &

