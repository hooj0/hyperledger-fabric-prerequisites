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
workdir="/tmp/fabric"
hyperledger_dir="$GOPATH/src/github.com/hyperledger"
fabric_version=v1.1.0
fabric_binary_version=`echo $fabric_version | sed 's/\v//g'` 

GO_VER=1.9
GO_URL=https://storage.googleapis.com/golang/go${GO_VER}.linux-amd64.tar.gz

go_env_file=".env"
go_profile="/etc/profile.d/goroot.sh"

fabric_binary="release/$ARCH/bin"


# function
#----------------------------------------------------------------------
function settingGoEnv() {
log yellow "===> write env to $go_env_file"

#cat > bbcc << EOF
#export GOPATH="/opt/gopath"
#export GOROOT="/opt/go"
#export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
#EOF

# use env
source $go_env_file
}


function settingGoProfile() {
log yellow "===> setting go env to ${go_profile}"

#cat <<EOF >${go_profile}
#cat > aa1aa << EOF
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
	log yellow "===> already existing env $go_env_file"	
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

if [ -d $workdir ]; then
	log yellow "===> already existing workdir $workdir"
else
	log yellow "===> create workdir $workdir"
	mkdir -pv $workdir
fi

log yellow "===> switch workdir $workdir"
echo "current pwd: $PWD" 

cd $workdir
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

if  [ -z "$hyperledger_dir/fabric" ]; then
	log yellow "===> already existing code: $hyperledger_dir/fabric"
else
	log yellow "===> create fabric code dir: $hyperledger_dir/fabric"

	[ ! -z $hyperledger_dir ] && mkdir -pv $hyperledger_dir
	cd $hyperledger_dir

	log yellow "===> clone fabric code to: $PWD/fabric"
	#git clone https://github.com/hyperledger/fabric.git

	#git tag
	log yellow "===> checkout fabric code version to: $fabric_version"
	#git checkout $fabric_version
fi

log done "download fabric code"


# Download Fabric CA
#----------------------------------------------------------------------
log blue "-------------------download fabric ca code-------------------"

if  [ -z "$hyperledger_dir/fabric-ca" ]; then
	log yellow "===> already existing code: $hyperledger_dir/fabric-ca"
else
	log yellow "===> create fabric code dir: $hyperledger_dir/fabric-ca"

	[ ! -z $hyperledger_dir ] && mkdir -pv $hyperledger_dir
	cd $hyperledger_dir

	log yellow "===> clone fabric code to: $PWD/fabric-ca"
	#git clone https://github.com/hyperledger/fabric-ca.git

	#git tag
	log yellow "===> checkout fabric-ca code version to: $fabric_version"
	#git checkout $fabric_version
fi

log done "download fabric-ca code"


# Download Fabric Simple
#----------------------------------------------------------------------
log blue "-----------------download fabric samples code----------------"

if  [ -z "$hyperledger_dir/fabric-samples" ]; then
	log yellow "===> already existing code: $hyperledger_dir/fabric-samples"
else
	log yellow "===> create fabric code dir: $hyperledger_dir/fabric-samples"

	[ ! -z $hyperledger_dir ] && mkdir -pv $hyperledger_dir
	cd $hyperledger_dir

	log yellow "===> clone fabric code to: $PWD/fabric-samples"
	#git clone https://github.com/hyperledger/fabric-samples.git

	#git tag
	log yellow "===> checkout fabric-samples code version to: $fabric_version"
	#git checkout $fabric_version
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
log yellow "===> switch workdir to $hyperledger_dir/fabric"

[ -z fabric ] && cd fabric

if [ -d "$fabric_binary" ]; then
	log yellow "===> already existing release dir: $fabric_binary"
	ls -al ${fabric_binary}

	line=`ls -al ${fabric_binary} | wc -l`
	if (( line <= 0 )); then
		log yellow "===> ${fabric_binary} dir is empty, make binary file"

		#make clean gotools
		#make release
	fi	
else
	log yellow "===> not found fabric tools binary release dir: ${fabric_binary}"
	
	#make clean gotools
	#make release
fi


if [ "`command -v cryptogen`" ]; then
	log yellow "===> already existing cryptogen"
	where cryptogen
else
	log yellow "===> copy ${fabric_binary}/ -->> usr/bin dir"

	#cp -rv $fabric_binary /usr/bin/
fi	

log done "make binary fabric tools"


# Download binary cryptogen/configtxgen/ca-client
#----------------------------------------------------------------------
log blue "--------------download binary fabric tools-------------------"

if [ ! -d "$fabric_binary" ]; then
	
	log yellow "===> create binary dir $fabric_binary"
	mkdir -pv $fabric_binary

	log yellow "===> switch workdir to $fabric_binary"
	cd $fabric_binary
	
	log yellow "===> download binary tools (ca-client): exec bootstrap.sh 1.2.0 -b"
	#source bootstrap.sh ${fabric_binary_version} -b
fi

log done "download binary fabric tools"


# Pull Fabric Docker Images
#----------------------------------------------------------------------
log blue "-----------------pull fabric docker image--------------------"

log yellow "===> pull docker hyperledger/fabric images"
#source bootstrap.sh ${fabric_binary_version} -d

log yellow "===> preview hyperledger/fabric images"
#docker images hyperledger/fabric-*

log done "pull fabric docker image"