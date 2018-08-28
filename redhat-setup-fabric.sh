#!/bin/bash
# --------------------------------------------------------------------
# author:   hoojo
# email:    hoojo_@126.com
# github:   https://github.com/hooj0
# create date: 2018-08-25
# copyright by hoojo@2018
# --------------------------------------------------------------------

# @changelog Redhat-style system Hyperledger fabric prerequisites environment software and tools setup script

set -eu
set -o pipefail
trap "echo 'error: Script failed: see failed command above'" ERR


# env variable
#----------------------------------------------------------------------
export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')")
export MARCH=$(uname -m)

export GOPATH="/opt/gopath"
export GOROOT="/opt/go"
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH



# local variables
#----------------------------------------------------------------------
echo "----------------------local variables-----------------------"

WORKDIR="/tmp/fabric"
HYPERLEDGER_DIR="/opt/gopath/src/github.com/hyperledger"
FABRIC_BINARY_PARENT="$HYPERLEDGER_DIR/fabric/release/$ARCH"
FABRIC_BINARY="$HYPERLEDGER_DIR/fabric/release/$ARCH/bin"

FABRIC_VERSION=v1.1.0
FABRIC_BINARY_VERSION=`echo $FABRIC_VERSION | sed 's/v//g'` 
THIRDPARTY_IMAGE_VERSION=0.4.6

GO_VER=1.11
#GO_URL=https://storage.googleapis.com/golang/go${GO_VER}.linux-amd64.tar.gz
GO_URL=https://studygolang.com/dl/golang/go${GO_VER}.linux-amd64.tar.gz

#ENV_BASHRC="/etc/bashrc"
ENV_BASHRC="/home/$USER/.bashrc"
#ENV_PROFILE="/etc/profile.d/goroot.sh"
#ENV_PROFILE="/etc/profile"
ENV_PROFILE="/home/$USER/.bash_profile"

GIT_VERSOIN="2.7.3"
#GIT_VERSOIN="2.13.1"
GIT_OLD_VERSION="x86_64"

MASTER_WORKDIR="$PWD"


echo "WORKDIR=${WORKDIR}"
echo "HYPERLEDGER_DIR=${HYPERLEDGER_DIR}"
echo "FABRIC_BINARY=${FABRIC_BINARY}"

echo "FABRIC_VERSION=${FABRIC_VERSION}"
echo "FABRIC_BINARY_VERSION=${FABRIC_BINARY_VERSION}"
echo "GO_VERSION=${GO_VER}"

echo "ENV_BASHRC=${ENV_BASHRC}"
echo "ENV_PROFILE=${ENV_PROFILE}"


# set role
#----------------------------------------------------------------------
group="${USER}"
function settingGroup() {
	echo "----------------------setting user & group--------------------"
	set +e
	group="hyperledger" 
	count=`egrep "^$group" /etc/group | wc -l`
	if [ $count -eq 0 ]; then
	    sudo groupadd $group
	fi

	#sudo usermod -a -G $group ${USER}
	sudo gpasswd -a ${USER} $group
	set -e
}


# function
#----------------------------------------------------------------------
echo "-------------------------function difined-----------------------"

function settingEnv() {
log yellow "===> write env to $ENV_BASHRC"

[ ! -f $ENV_BASHRC ] && > $ENV_BASHRC

sudo cat >> $ENV_BASHRC <<-EOF
EOF

# use env
source $ENV_BASHRC
[ -f $ENV_PROFILE ] && source $ENV_PROFILE

}

function settingGoProfile() {
log yellow "===> setting go env to ${ENV_PROFILE}"

[ ! -f $ENV_PROFILE ] && > $ENV_PROFILE

sudo cat >> ${ENV_PROFILE} <<-EOF
export GOPATH="/opt/gopath"
export GOROOT="/opt/go"
export PATH=\$GOROOT/bin:\$GOPATH/bin:\$PATH
EOF

# use env
source $ENV_PROFILE
}

function settingGitProfile() {
log yellow "===> setting git env to ${ENV_PROFILE}"

[ ! -f $ENV_PROFILE ] && > $ENV_PROFILE

sudo cat >> ${ENV_PROFILE} <<-EOF
export PATH=\$PATH:/usr/local/git/bin
EOF

# use env
source $ENV_PROFILE
}


# import file
#----------------------------------------------------------------------
echo "-------------------------import file-------------------------"
echo "===> source log.sh"
source log.sh

log done "import file"


# validate feasibility
#----------------------------------------------------------------------
log blue "------------------validate feasibility-----------------------"

log yellow "===> system type: `uname -s`-`uname -m`"
cat /etc/redhat-release
echo 

#read -p "Whether to continue executing the script[y/n]:" execScript

#if [ $execScript != "y" ]; then
#	log red "<<<<=== Terminate execution script...."
#	exit 1
#fi	


# Update the entire system to the latest releases
#----------------------------------------------------------------------
log blue "----------------------update system--------------------------"

if [ `command -v yum` ]; then
	log yellow "===> already existing yum, update yum"
	which yum

	# update yum
	#sudo yum -y update

	# Install some basic utilities
	log yellow "===> Install some basic utilities packages"
	#Install Basic build essential packages
	sudo yum install -y gcc-c++ python-devel device-mapper libtool-ltdl-devel libffi-devel openssl-devel \
		make unzip tar gcc bzip2
else
	log red "===> not found yum command, check your system style is Redhat-style?"	
	exit 1
fi

log done "update system"


# export env
#----------------------------------------------------------------------
log blue "-------------------------export env--------------------------"

settingEnv

log yellow "===> env | grep go"
#env | grep go
echo "GOPATH=${GOPATH}"
echo "GOROOT=${GOROOT}"
echo "PATH=${PATH}"

log done "export env"


# switch workdir
#----------------------------------------------------------------------
log blue "-----------------------switch workdir------------------------"

if [ -d "$WORKDIR" ]; then
	log yellow "===> already existing workdir $WORKDIR"
else
	log yellow "===> create workdir $WORKDIR"
	mkdir -pv $WORKDIR
fi

log yellow "===> switch workdir $WORKDIR"
echo "current pwd: $PWD" 

cd $WORKDIR
log white "latest pwd: $PWD"

log done "switch workdir"


# Install CURL
#----------------------------------------------------------------------
log blue "------------------------install curl------------------------"

if [ `command -v curl` ]; then
	log yellow "===> already existing curl tools"
	which curl
else
	log yellow "===> install curl tools"

	# install
	sudo yum install -y curl
	# sudo yum -y upgrade
fi	

log done "install curl"


# Install Go 1.9+
#----------------------------------------------------------------------
log blue "----------------------install golang 1.9+--------------------"

if [ `command -v go` ]; then
	log yellow "===> already existing language"
	which go
else
	log yellow "===> install go language 1.9+"			

	log yellow "===> create go language compiler dir"
	[ ! -d $GOROOT ] && sudo mkdir -pv $GOROOT
	[ ! -d $GOPATH/bin ] && sudo mkdir -pv $GOPATH/bin
	[ ! -d $GOPATH/pkg ] && sudo mkdir -pv $GOPATH/pkg

	sudo chown -R $USER:$group $GOPATH
	sudo chown -R $USER:$group $GOPATH/bin
	sudo chown -R $USER:$group $GOPATH/pkg

	#sudo chmod -R +777 $GOROOT
	#sudo chmod -R +777 $GOPATH/bin
	#sudo chmod -R +777 $GOPATH/pkg

	log yellow "===> download go language: ${GO_URL}, to directory: $GOROOT"
	#curl -sL $GO_URL | (cd $GOROOT && tar --strip-components 1 -xz)	
	if [ ! -f "go${GO_VER}.linux-amd64.tar.gz" ]; then
		wget $GO_URL 
	fi

	ls -al
	sudo tar -zxvf go${GO_VER}.linux-amd64.tar.gz -C /opt/

	settingGoProfile
fi	

go version

log done "install golang"


# Install Git 
#----------------------------------------------------------------------
log blue "------------------------install git--------------------------"

function upgradeGit() {
	log yellow "===> upgrade git version to ${GIT_VERSOIN}"	

	log yellow "===> upgrade git dependency base package"
	sudo yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel
	sudo yum install -y gcc perl-ExtUtils-MakeMaker	

	sudo yum list installed | grep git
	sudo yum -y remove "git.$GIT_OLD_VERSION"

	log yellow "===> download git version: ${GIT_VERSOIN} to $PWD"
	
	if [ ! -f "git-${GIT_VERSOIN}.tar.gz" ]; then
		wget https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSOIN}.tar.gz
	fi	
	
 	sudo tar -zxvf git-${GIT_VERSOIN}.tar.gz

	cd git-${GIT_VERSOIN}

	log yellow "===> make git ${GIT_VERSOIN} to '/usr/local/git'"
	# ./configure --without-iconv
	# make CFLAGS=-liconv prefix=/usr/local/git all
	# make CFLAGS=-liconv prefix=/usr/local/git install

	sudo make prefix=/usr/local/git all
	sudo make prefix=/usr/local/git install

	log yellow "===> setting git env"
	settingGitProfile	
}

if [ `command -v git` ]; then
	log yellow "===> already existing git"
	which git

	log yellow "===> git version"

	git_ver="`git --version`"
	echo "git version: $git_ver"

	
	if [ "$git_ver" == "git version ${GIT_VERSOIN}" ]; then
		log yellow "current is latest version $git_ver"		
	else				
		log yellow "===> remove old version git.$GIT_OLD_VERSION"

		upgradeGit
	fi	
else
	upgradeGit		
fi	

git --version

log done "install git"


# Download Fabric 
#----------------------------------------------------------------------
log blue "---------------------download fabric code--------------------"

if  [ -d "$HYPERLEDGER_DIR/fabric" ]; then
	log yellow "===> already existing code: $HYPERLEDGER_DIR/fabric"	
else
	log yellow "===> create fabric code dir: $HYPERLEDGER_DIR/fabric"

	[ ! -z $HYPERLEDGER_DIR ] && sudo mkdir -pv $HYPERLEDGER_DIR
	cd $HYPERLEDGER_DIR
	
	log yellow "===> clone fabric code to: $PWD/fabric"
	sudo mkdir -pv $HYPERLEDGER_DIR/fabric && \
	sudo chmod -R +777 $HYPERLEDGER_DIR/fabric	

	git clone https://github.com/hyperledger/fabric.git fabric
	sudo chown -R $USER:$group $HYPERLEDGER_DIR/fabric	

	log yellow "===> enter the source directory: $HYPERLEDGER_DIR/fabric"
	cd "$HYPERLEDGER_DIR/fabric"

	#log yellow "===> pull the latest code"
	#git pull origin master
		
	log yellow "===> fabric code tag"
	git tag

	log yellow "===> checkout fabric code version to: $FABRIC_VERSION"
	git checkout $FABRIC_VERSION
fi


log done "download fabric code"


# Download Fabric CA
#----------------------------------------------------------------------
log blue "-------------------download fabric ca code-------------------"

if  [ -d "$HYPERLEDGER_DIR/fabric-ca" ]; then
	log yellow "===> already existing code: $HYPERLEDGER_DIR/fabric-ca"
else
	log yellow "===> create fabric code dir: $HYPERLEDGER_DIR/fabric-ca"

	[ ! -d $HYPERLEDGER_DIR ] && sudo mkdir -pv $HYPERLEDGER_DIR

	log yellow "===> switch workdir $WORKDIR"
	cd $HYPERLEDGER_DIR
	echo "current pwd: $PWD" 

	log yellow "===> clone fabric-ca code to: $PWD/fabric-ca"
	sudo mkdir -pv $HYPERLEDGER_DIR/fabric-ca
	sudo chmod -R +777 $HYPERLEDGER_DIR/fabric-ca

	git clone https://github.com/hyperledger/fabric-ca.git
	sudo chown -R $USER:$group $HYPERLEDGER_DIR/fabric-ca
	

	log yellow "===> enter the source directory: $HYPERLEDGER_DIR/fabric-ca"
	cd $HYPERLEDGER_DIR/fabric-ca

	#log yellow "===> pull the latest code"
	#git pull origin master

	log yellow "===> fabric-ca code tag"
	git tag

	log yellow "===> checkout fabric-ca code version to: $FABRIC_VERSION"
	git checkout $FABRIC_VERSION
fi

log done "download fabric-ca code"


# Download Fabric Simple
#----------------------------------------------------------------------
log blue "-----------------download fabric samples code----------------"

if  [ -d "$HYPERLEDGER_DIR/fabric-samples" ]; then
	log yellow "===> already existing code: $HYPERLEDGER_DIR/fabric-samples"
	sudo chmod -R +777 $HYPERLEDGER_DIR/fabric-samples
else
	log yellow "===> create fabric code dir: $HYPERLEDGER_DIR/fabric-samples"

	[ ! -d $HYPERLEDGER_DIR ] && sudo mkdir -pv $HYPERLEDGER_DIR
	cd $HYPERLEDGER_DIR

	log yellow "===> clone fabric samples code to: $PWD/fabric-samples"
	sudo mkdir -pv $HYPERLEDGER_DIR/fabric-samples
	sudo chmod -R +777 $HYPERLEDGER_DIR/fabric-samples

	git clone https://github.com/hyperledger/fabric-samples.git
	sudo chown -R $USER:$group $HYPERLEDGER_DIR/fabric-samples	
	
	log yellow "===> enter the source directory: $HYPERLEDGER_DIR/fabric-samples"
	cd $HYPERLEDGER_DIR/fabric-samples

	#log yellow "===> pull the latest code"
	#git pull origin master

	log yellow "===> fabric samples code tag"
	git tag

	log yellow "===> checkout fabric-samples code version to: $FABRIC_VERSION"
	git checkout $FABRIC_VERSION
fi

log done "download fabric-samples code"


# Install Docker v1.12+
#----------------------------------------------------------------------
log blue "----------------------install docker-------------------------"

if [ "`command -v docker`" ]; then
	log yellow "===> already existing docker"
	which docker
else
	log yellow "===> download docker & install docker"

	log yellow "===> remove old docker & install docker"
	sudo yum remove -y docker \
	          docker-client \
	          docker-client-latest \
	          docker-common \
	          docker-latest \
	          docker-latest-logrotate \
	          docker-logrotate \
	          docker-selinux \
	          docker-engine-selinux \
	          docker-engine

	log yellow "===> Install required packages"
	sudo yum install -y yum-utils device-mapper-persistent-data lvm2

	log yellow "===> add docker repository"
	sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo	

	log yellow "===> install docker"
	sudo yum install -y docker-ce-18.03.1.ce
	#sudo yum list docker-ce --showduplicates | sort -r
	#sudo yum install docker-ce-<VERSION STRING>
	#sudo yum install docker-ce-[18.03.0.ce]
	
	log yellow "===> add ${USER} to docker group"
	sudo gpasswd -a ${USER} docker

	log yellow "===> start docker service"
	sudo systemctl start docker	
	#sudo service docker start		
fi	

docker -v

log done "install docker"


# Install Docker Compose v1.8
#----------------------------------------------------------------------
log blue "------------------install docker compose---------------------"

if [ "`command -v docker-compose`" ]; then
	log yellow "===> already existing docker-compose"
	which docker-compose
else	
	log yellow "===> download docker compose & install docker-compose"

	log yellow "===> switch workdir $WORKDIR"
	echo "current pwd: $PWD" 

	cd $WORKDIR
	log yellow "latest pwd: $PWD"

	# Install docker-compose
	sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` > docker-compose
	sudo mv -v docker-compose /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose	
fi

docker-compose -v

# Test docker
log yellow "===> test docker"
#docker run --rm busybox echo 'docker fabric image is good'
sudo docker run hello-world

log done "install docker compose"


# Make Binary Fabric File
#----------------------------------------------------------------------
function skip() {
	log blue "-----------------make binary fabric tools--------------------"

	#create var/hyperledger dir
	#sudo mkdir -pv /var/hyperledger
	#sudo chown -R ubuntu:ubuntu /var/hyperledger

	log yellow "===> current workdir to $PWD"
	log yellow "===> switch workdir to $HYPERLEDGER_DIR/fabric"

	cd $HYPERLEDGER_DIR/fabric

	if [ -d "$FABRIC_BINARY" ]; then
		log yellow "===> already existing release dir: $FABRIC_BINARY"
		ls -al ${FABRIC_BINARY}

		line=`ls -al ${FABRIC_BINARY} | wc -l`
		if (( line <= 0 )); then
			log yellow "===> ${FABRIC_BINARY} dir is empty, make binary file"

			sudo make clean gotools
			sudo make release
		fi	
	else
		log yellow "===> not found fabric tools binary release dir: ${FABRIC_BINARY}"
		
		sudo make clean gotools
		sudo make release
	fi

	if [ "`command -v cryptogen`" ]; then
		log yellow "===> already existing cryptogen"
		which cryptogen
	else
		log yellow "===> copy ${FABRIC_BINARY}/ -->> 'usr/bin' dir"

		sudo cp -rv $FABRIC_BINARY /usr/bin/
	fi	

	log done "make binary fabric tools"
}

# Download binary cryptogen/configtxgen/ca-client
#----------------------------------------------------------------------
log blue "--------------download binary fabric tools-------------------"

if [ ! -d "$FABRIC_BINARY" ]; then

	log yellow "===> current workdir to $PWD"
	log yellow "===> switch workdir to $HYPERLEDGER_DIR/fabric"

	cd $HYPERLEDGER_DIR/fabric
	
	log yellow "===> create binary dir $FABRIC_BINARY"
	sudo mkdir -pv $FABRIC_BINARY \
	&& sudo chown -R $USER:$group $FABRIC_BINARY
	sudo chmod -R +777 $FABRIC_BINARY

	log yellow "===> switch workdir to $MASTER_WORKDIR"
	cd $MASTER_WORKDIR
	
	log yellow "===> prepar download binary tools (ca-client, cryptogen, configtxgen): exec bootstrap-1.1.sh ${FABRIC_BINARY_VERSION}"	
	source bootstrap-1.1.sh ${FABRIC_BINARY_VERSION}
		
	log yellow "===> switch workdir to $WORKDIR"
	cd $WORKDIR
	
	log yellow "===> Downloading platform specific fabric binaries"
	#curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${FABRIC_BINARY_VERSION}/hyperledger-fabric-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz | tar xz
	if [ ! -f "hyperledger-fabric-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz" ]; then
		wget https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${FABRIC_BINARY_VERSION}/hyperledger-fabric-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz
	fi

	ls -al
	sudo tar -zxvf hyperledger-fabric-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz -C $FABRIC_BINARY_PARENT
	

	log yellow "===> Downloading platform specific fabric-ca-client binary"	
	#curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric-ca/hyperledger-fabric-ca/${ARCH}-${FABRIC_BINARY_VERSION}/hyperledger-fabric-ca-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz | tar xz
	if [ ! -f "hyperledger-fabric-ca-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz" ]; then
		wget https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric-ca/hyperledger-fabric-ca/${ARCH}-${FABRIC_BINARY_VERSION}/hyperledger-fabric-ca-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz
	fi

	ls -al
	sudo tar -zxvf hyperledger-fabric-ca-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz -C $FABRIC_BINARY_PARENT

	sudo chmod -R +777 $FABRIC_BINARY
	sudo chown -R $USER:$group $FABRIC_BINARY
fi

if [ "`command -v cryptogen`" ]; then
	log yellow "===> already existing cryptogen"
	which cryptogen
else
	log yellow "===> copy ${FABRIC_BINARY}/ -->> 'usr/bin' dir"

	sudo cp -rv $FABRIC_BINARY /usr/bin/
fi	

log done "download binary fabric tools"


# Pull Fabric Docker Images
#----------------------------------------------------------------------
log blue "-----------------pull fabric docker image--------------------"

log yellow "===> switch workdir to $MASTER_WORKDIR"
cd $MASTER_WORKDIR
sudo mkdir -pv /var/hyperledger && sudo chown -R $USER:$group /var/hyperledger && sudo chown -R +777 /var/hyperledger

log yellow "===> pull docker hyperledger/fabric images"
source bootstrap-1.1.sh ${FABRIC_BINARY_VERSION}
dockerHyperledgerImagePull

log yellow "===> preview hyperledger/fabric images"
sudo docker images "hyperledger/fabric-"

log done "pull fabric docker image"