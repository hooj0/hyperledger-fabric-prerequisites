#!/bin/bash
#@changelog Hyperledger fabric prerequisites environment software and tools setup script

set -e
set -uo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR


# env variable
#----------------------------------------------------------------------
export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')")
export MARCH=$(uname -m)


# variables
#----------------------------------------------------------------------
WORKDIR="/tmp/fabric"
HYPERLEDGER_DIR="$GOPATH/src/github.com/hyperledger"
FABRIC_BINARY="release/$ARCH/bin"

FABRIC_VERSION=v1.1.0
FABRIC_BINARY_VERSION=`echo $FABRIC_VERSION | sed 's/\v//g'` 

GO_VER=1.9
GO_URL=https://storage.googleapis.com/golang/go${GO_VER}.linux-amd64.tar.gz

GO_ENV_FILE=".env"
GO_PROFILE="/etc/profile.d/goroot.sh"


# function
#----------------------------------------------------------------------
function settingGoEnv() {
log yellow "===> write env to $GO_ENV_FILE"

#cat > $GO_ENV_FILE << EOF
#export GOPATH="/opt/gopath"
#export GOROOT="/opt/go"
#export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
#EOF

# use env
source $GO_ENV_FILE
}


function settingGoProfile() {
log yellow "===> setting go env to ${GO_PROFILE}"

#cat <<EOF >${GO_PROFILE}
#cat > ${GO_PROFILE} << EOF
#export GOROOT=$GOROOT
#export GOPATH=$GOPATH
#export PATH=\$PATH:$GOROOT/bin:$GOPATH/bin
#EOF
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

read -p "Whether to continue executing the script[y/n]:" execScript

if [ $execScript != "y" ]; then
	log red "<<<<=== Terminate execution script...."
	exit 1
fi	


# Update the entire system to the latest releases
#----------------------------------------------------------------------
log blue "----------------------update system--------------------------"

if [ `command -v apt-get` ]; then
	log yellow "===> already existing apt-get, update apt-get"
	where apt-get

	# update
	apt-get update
	##apt-get dist-upgrade -y

	# Install some basic utilities
	log yellow "===> Install some basic utilities (build-essential make unzip g++ libtool)"
	#apt-get install -y build-essential git make curl unzip g++ libtool
	apt-get install -y build-essential make unzip g++ libtool
else
	log red "===> not found apt-get command, check your system style is ubuntu?"	
	#exit 1
fi

log done "update system"


# export env
#----------------------------------------------------------------------
log blue "-------------------------export env--------------------------"

if [ -z ${GOPATH} ]; then	
	settingGoEnv
else
	log yellow "===> already existing env $GO_ENV_FILE"	
fi

log yellow "===> env | grep go"
#env | grep go
echo "GOPATH=${GOPATH}"
echo "GOROOT=${GOROOT}"
echo "PATH=${PATH}"

log done "export env"


# switch workdir
#----------------------------------------------------------------------
log blue "-----------------------switch workdir------------------------"

if [ -d $WORKDIR ]; then
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
	where curl
else
	log yellow "===> install curl tools"

	# install
	apt-get install -y curl
fi	

log done "install curl"


# Install Go 1.9+
#----------------------------------------------------------------------
log blue "----------------------install golang 1.9+--------------------"

if [ `command -v go` ]; then
	log yellow "===> already existing language"
	where go
else
	log yellow "===> install go language 1.9+"	
	
	# Set Go environment variables needed by other scripts
	PATH=$GOROOT/bin:$GOPATH/bin:$PATH

	settingGoProfile

	log yellow "===> create go language compiler dir"
	[ ! -d $GOROOT ] && mkdir -pv $GOROOT
	[ ! -d $GOPATH/bin ] && mkdir -pv $GOPATH/bin
	[ ! -d $GOPATH/pkg ] && mkdir -pv $GOPATH/pkg

	log yellow "===> download go language: ${GO_URL}"
	curl -sL $GO_URL | (cd $GOROOT && tar --strip-components 1 -xz)
fi	

log done "install golang"


# Install Git 
#----------------------------------------------------------------------
log blue "------------------------install git--------------------------"

if [ `command -v go` ]; then
	log yellow "===> already existing git"
	where git
else
	log yellow "===> install git"

	#yum install git-core
	apt-get install git
fi

log done "install git"


# Download Fabric 
#----------------------------------------------------------------------
log blue "---------------------download fabric code--------------------"

if  [ -z "$HYPERLEDGER_DIR/fabric" ]; then
	log yellow "===> already existing code: $HYPERLEDGER_DIR/fabric"
else
	log yellow "===> create fabric code dir: $HYPERLEDGER_DIR/fabric"

	[ ! -z $HYPERLEDGER_DIR ] && mkdir -pv $HYPERLEDGER_DIR
	cd $HYPERLEDGER_DIR

	log yellow "===> clone fabric code to: $PWD/fabric"
	#git clone https://github.com/hyperledger/fabric.git

	#git tag
	log yellow "===> checkout fabric code version to: $FABRIC_VERSION"
	#git checkout $FABRIC_VERSION
fi

log done "download fabric code"


# Download Fabric CA
#----------------------------------------------------------------------
log blue "-------------------download fabric ca code-------------------"

if  [ -z "$HYPERLEDGER_DIR/fabric-ca" ]; then
	log yellow "===> already existing code: $HYPERLEDGER_DIR/fabric-ca"
else
	log yellow "===> create fabric code dir: $HYPERLEDGER_DIR/fabric-ca"

	[ ! -z $HYPERLEDGER_DIR ] && mkdir -pv $HYPERLEDGER_DIR
	cd $HYPERLEDGER_DIR

	log yellow "===> clone fabric code to: $PWD/fabric-ca"
	#git clone https://github.com/hyperledger/fabric-ca.git

	#git tag
	log yellow "===> checkout fabric-ca code version to: $FABRIC_VERSION"
	#git checkout $FABRIC_VERSION
fi

log done "download fabric-ca code"


# Download Fabric Simple
#----------------------------------------------------------------------
log blue "-----------------download fabric samples code----------------"

if  [ -z "$HYPERLEDGER_DIR/fabric-samples" ]; then
	log yellow "===> already existing code: $HYPERLEDGER_DIR/fabric-samples"
else
	log yellow "===> create fabric code dir: $HYPERLEDGER_DIR/fabric-samples"

	[ ! -z $HYPERLEDGER_DIR ] && mkdir -pv $HYPERLEDGER_DIR
	cd $HYPERLEDGER_DIR

	log yellow "===> clone fabric code to: $PWD/fabric-samples"
	#git clone https://github.com/hyperledger/fabric-samples.git

	#git tag
	log yellow "===> checkout fabric-samples code version to: $FABRIC_VERSION"
	#git checkout $FABRIC_VERSION
fi

log done "download fabric-samples code"


# Install Docker v1.12+
#----------------------------------------------------------------------
log blue "----------------------install docker-------------------------"

if [ "`command -v docker`" ]; then
	log yellow "===> already existing docker"
	where docker
else
	log yellow "===> download docker & install docker"

	# Update system
	log yellow "===> apt-get update"
	apt-get update -qq

	log yellow "===> Prep apt-get ca for docker install"
	apt-get install -y apt-transport-https ca-certificates

	log yellow "===> download docker"
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

	log yellow "===> add docker repository"
	add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"

	# Update system
	log yellow "===> apt-get update"
	apt-get update -qq

	log yellow "===> install docker"
	##apt-get install -y docker-ce=17.06.2~ce~0~ubuntu  # in case we need to set the version
	apt-get install -y docker-ce
fi	

log done "install docker"


# Install Docker Compose v1.8
#----------------------------------------------------------------------
log blue "------------------install docker compose---------------------"

if [ "`command -v docker-compose`" ]; then
	log yellow "===> already existing docker-compose"
	where docker-compose
else	
	log yellow "===> download docker compose & install docker-compose"
	# Install docker-compose
	curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

	log yellow "===> add ubuntu user to the docker group"
	usermod -a -G docker ubuntu 
fi

# Test docker
log yellow "===> test docker"
#docker run --rm busybox echo All good

log done "install docker compose"


# Make Binary Fabric File
#----------------------------------------------------------------------
log blue "-----------------make binary fabric tools--------------------"

#create var/hyperledger dir
#sudo mkdir -pv /var/hyperledger
#sudo chown -R ubuntu:ubuntu /var/hyperledger

log yellow "===> current workdir to $PWD"
log yellow "===> switch workdir to $HYPERLEDGER_DIR/fabric"

[ -z fabric ] && cd fabric

if [ -d "$FABRIC_BINARY" ]; then
	log yellow "===> already existing release dir: $FABRIC_BINARY"
	ls -al ${FABRIC_BINARY}

	line=`ls -al ${FABRIC_BINARY} | wc -l`
	if (( line <= 0 )); then
		log yellow "===> ${FABRIC_BINARY} dir is empty, make binary file"

		#make clean gotools
		#make release
	fi	
else
	log yellow "===> not found fabric tools binary release dir: ${FABRIC_BINARY}"
	
	#make clean gotools
	#make release
fi


if [ "`command -v cryptogen`" ]; then
	log yellow "===> already existing cryptogen"
	where cryptogen
else
	log yellow "===> copy ${FABRIC_BINARY}/ -->> usr/bin dir"

	#cp -rv $FABRIC_BINARY /usr/bin/
fi	

log done "make binary fabric tools"


# Download binary cryptogen/configtxgen/ca-client
#----------------------------------------------------------------------
log blue "--------------download binary fabric tools-------------------"

if [ ! -d "$FABRIC_BINARY" ]; then
	
	log yellow "===> create binary dir $FABRIC_BINARY"
	mkdir -pv $FABRIC_BINARY

	log yellow "===> switch workdir to $FABRIC_BINARY"
	cd $FABRIC_BINARY
	
	log yellow "===> download binary tools (ca-client): exec bootstrap.sh 1.2.0 -b"
	#source bootstrap.sh ${FABRIC_BINARY_VERSION} -b
	
	log yellow "===> Downloading platform specific fabric binaries"
	#curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${FABRIC_BINARY_VERSION}/hyperledger-fabric-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz | tar xz

	log yellow "===> Downloading platform specific fabric-ca-client binary"
	#curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric-ca/hyperledger-fabric-ca/${ARCH}-${FABRIC_BINARY_VERSION}/hyperledger-fabric-ca-${ARCH}-${FABRIC_BINARY_VERSION}.tar.gz
fi

log done "download binary fabric tools"


# Pull Fabric Docker Images
#----------------------------------------------------------------------
log blue "-----------------pull fabric docker image--------------------"

log yellow "===> pull docker hyperledger/fabric images"
#source bootstrap.sh ${FABRIC_BINARY_VERSION} -d

log yellow "===> preview hyperledger/fabric images"
#docker images hyperledger/fabric-*

log done "pull fabric docker image"