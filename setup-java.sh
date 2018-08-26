#!/bin/bash
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
apt-get install -y openjdk-8-jdk maven

log done "install openjdk-8-jdk"


# Install wget
#----------------------------------------------------------------------
log blue "-----------------------install wget--------------------------"
if [ `command -v wget` ]
	log yellow "===> already existing wget"
	where wget
else	
	log yellow "===> download wget"
	wget https://services.gradle.org/distributions/gradle-2.12-bin.zip -P /tmp --quiet

	log yellow "===> unzip wget"
	unzip -q /tmp/gradle-2.12-bin.zip -d /opt && rm /tmp/gradle-2.12-bin.zip
	ln -s /opt/gradle-2.12/bin/gradle /usr/bin
fi

log done "install wget"