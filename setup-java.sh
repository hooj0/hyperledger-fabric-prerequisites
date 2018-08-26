#!/bin/bash
# --------------------------------------------------------------------
# author:   hoojo
# email:    hoojo_@126.com
# github:   https://github.com/hooj0
# create date: 2018-08-26
# copyright by hoojo@2018
# --------------------------------------------------------------------

#@changelog java prerequisites environment software and tools setup script


# import file
#----------------------------------------------------------------------
echo "-------------------------import file-------------------------"
echo "===> source log.sh"
source log.sh

log done "import file"


# Install Java
#----------------------------------------------------------------------
log blue "--------------------install openjdk-8-jdk--------------------"
apt-get install -y openjdk-8-jdk

log done "install openjdk-8-jdk"


# Install wget
#----------------------------------------------------------------------
log blue "-----------------------install wget--------------------------"
if [ `command -v wget` ]
	log yellow "===> already existing wget"
	where wget
else	
	log yellow "===> install wget"
	apt-get install -y wget
fi

log done "install wget"


# Install maven
#----------------------------------------------------------------------
log blue "-----------------------install maven-------------------------"

if [ `command -v mvn` ]
	log yellow "===> already existing maven"
	where mvn
else	
	log yellow "===> install maven"
	apt-get install -y maven
fi

# config env 

log done "install maven"


# Install gradle
#----------------------------------------------------------------------
log blue "-----------------------install gradle------------------------"
if [ `command -v gradle` ]
	log yellow "===> already existing gradle"
	where gradle
else	
	log yellow "===> download gradle"
	wget https://services.gradle.org/distributions/gradle-2.12-bin.zip -P /tmp --quiet

	log yellow "===> unzip gradle"
	unzip -q /tmp/gradle-2.12-bin.zip -d /opt && rm /tmp/gradle-2.12-bin.zip
	ln -s /opt/gradle-2.12/bin/gradle /usr/bin
fi

# config env 

log done "install gradle"