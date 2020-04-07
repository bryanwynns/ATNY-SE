#Reference: https://www.linuxtechi.com/install-kubernetes-1-7-centos7-rhel7/
# Before starting this process make sure your master node and your worker nodes can communicate with each other by IP and hostname.

# use hostnamectl set-hostname [hostname here]  to make the node hostnames unique.

exec bash
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#disable swap  -BW
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

#firewall rules
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=6781-6783/tcp
firewall-cmd --permanent --add-port=6783-6784/udp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#kube repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#install kube
yum install kubeadm docker -y

#start kube
systemctl restart docker && systemctl enable docker
systemctl  restart kubelet && systemctl enable kubelet
kubeadm init

#config and setup cluster
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
**capture command from cli output for worker nodes to use at end to join cluster**

#setup kube network and dns
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
**verify cluster up with kubectl get nodes**

******************************************
ON EACH WORKER NODE, PREP and INSTALL KUBE
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
firewall-cmd --permanent --add-port=10250/tcp 
firewall-cmd --permanent --add-port=10255/tcp 
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --permanent --add-port=6781-6783/tcp
firewall-cmd --permanent --add-port=6783-6784/udp
firewall-cmd  --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
> [kubernetes]
> name=Kubernetes
> baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
> enabled=1
> gpgcheck=1
> repo_gpgcheck=1
> gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
>         https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
> EOF

#instal Kubeadm and docker on each node  -added by BW
yum  install kubeadm docker -y
systemctl restart docker && systemctl enable docker
systemctl restart kubelet && systemctl enable kubelet

#join cluster with previous captured command
#use kubectl get nodes on master to verify cluster is up and worker nodes "ready"
#use kubectl get pods --all-namespaces to verify all containers are up