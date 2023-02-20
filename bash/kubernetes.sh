#!/bin/bash

function install() {
    if [[ "Ubuntu" == *"Ubuntu" ]]; then
        apt update
        apt install -y ca-certificates curl
        apt install -y apt-transport-https
        curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
        apt update
        apt install -y kubectl bash-completion
        echo 'source <(kubectl completion bash)' >>~/.bashrc
    else
        cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
        yum install -y kubectl bash-completion
        echo 'source <(kubectl completion bash)' >>~/.bashrc
    fi
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
    install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
    sysctl net.bridge.bridge-nf-call-iptables=1
    sysctl net.bridge.bridge-nf-call-iptables=1
    mkdir /etc/docker
    cat <<EOF | sudo tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF
    systemctl enable docker
    systemctl daemon-reload
    systemctl restart docker
}

function configure_master(){
    kubeadm init --pod-network-cidr=10.244.0.0/16
    # Non prod:
    kubeadm init --ignore-preflight-errors=NumCPU,Mem --pod-network-cidr=10.244.0.0/16
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    ufw allow 6443
    ufw allow 6443/tcp
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml    	
    kubectl get pods --all-namespaces
    kubectl get componentstatus
    kubectl get cs
    systemctl restart kubelet.service
    # Get Slave Nodes
    kubectl get nodes
}

function configure_slave(){
    kubeadm join 127.0.0.188:6443 --token u81y02.91gqwkxx6rnhnnly --discovery-token-ca-cert-hash sha256:4482ab1c66bf17992ea02c1ba580f4af9f3ad4cc37b24f1
}