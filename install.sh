#!/bin/bash -e

echo "================= Adding some global settings ==================="
mkdir -p "$HOME/.ssh/"
mv /c7cpp/config "$HOME/.ssh/"
cat /c7cpp/90forceyes >> /etc/yum.conf
touch "$HOME/.ssh/known_hosts"
mkdir -p /etc/drydock

echo "================= Installing basic packages ================"

yum -y install  \
sudo \
wget \
curl \
openssh-client \
ftp \
gettext \
samba-client \
openssl

echo "================= Installing Python packages ==================="
sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
#adding key required to install python
gpgkey=http://springdale.math.ias.edu/data/puias/6/x86_64/os/RPM-GPG-KEY-puias

sudo yum install -y \
  python-devel \
  python-pip

sudo pip2 install virtualenv==16.5.0
sudo pip2 install pyOpenSSL==19.0.0

export JQ_VERSION=1.5*
echo "================= Adding JQ $JQ_VERSION ==================="
sudo yum install -y jq-"$JQ_VERSION"

echo "================= Installing CLIs packages ======================"

export GIT_VERSION=2.22.0
echo "================= Installing Git $GIT_VERSION ===================="
sudo yum install -y http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm
sudo yum install -y git-"$GIT_VERSION"

export GCLOUD_SDKREPO=253.0*
echo "================= Adding gcloud $GCLOUD_SDKREPO  ============"
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
#adding key required to install gcloud
rpm --import  https://packages.cloud.google.com/yum/doc/yum-key.gpg
rpm --import  https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
sudo yum install -y google-cloud-sdk-"$GCLOUD_SDKREPO"

export AWS_VERSION=1.16.192
echo "================= Adding awscli $AWS_VERSION ===================="
sudo pip install awscli=="$AWS_VERSION"

AZURE_CLI_VERSION=2.0*
echo "================ Adding azure-cli $AZURE_CLI_VERSION  =============="
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
sudo yum install -y azure-cli-$AZURE_CLI_VERSION

export JFROG_VERSION=1.26.1
echo "================= Adding jfrog-cli $JFROG_VERSION==================="
wget -nv https://api.bintray.com/content/jfrog/jfrog-cli-go/"$JFROG_VERSION"/jfrog-cli-linux-amd64/jfrog?bt_package=jfrog-cli-linux-amd64 -O jfrog
sudo chmod +x jfrog
sudo mv jfrog /usr/bin/jfrog

KUBECTL_VERSION=v1.15.0
echo "================= Adding kubectl "$KUBECTL_VERSION" ==================="
curl -LO https://storage.googleapis.com/kubernetes-release/release/"$KUBECTL_VERSION"/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "======================= Installing gcc ======================"

yum -y update
sudo yum install -y yum-utils
sudo yum install -y centos-release-scl
sudo yum-config-manager --enable rhel-server-rhscl-8-rpms
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
sudo yum install -y devtoolset-8
export PATH="/opt/rh/devtoolset-8/root/usr/bin:$PATH"
echo 'export PATH="/opt/rh/devtoolset-8/root/usr/bin:$PATH"' >> /etc/drydock/.env
scl enable devtoolset-8 bash
gcc --version
g++ --version

echo "==================== Installing clang ==============="

#Add this 3rd party repo to install clang-6
echo "[leonmaxx-clang-7-epel]
name=Copr repo for clang-7-epel owned by leonmaxx
baseurl=https://copr-be.cloud.fedoraproject.org/results/leonmaxx/clang-7-epel/epel-7-x86_64/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/leonmaxx/clang-7-epel/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1" >> /etc/yum.repos.d/epel.repo

sudo rpm --import https://copr-be.cloud.fedoraproject.org/results/leonmaxx/clang-7-epel/pubkey.gpg
yum install clang -y

clang --version
