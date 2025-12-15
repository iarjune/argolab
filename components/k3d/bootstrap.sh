curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash  
k3d cluster create argocd-lab --servers 1 --agents 1 --port 8081:80@loadbalancer
