# hyperledger fabric prerequisites
:bento: Hyperledger fabric prerequisites environment software and tools, and its surrounding eco-software scripts.


# setup hyperledger-fabric env
execute the script below:
```sh
$ sudo setup-fabric.sh
```

start install fabric prerequisites environment software and tools.

## software and tools list
+ apt-get
+ curl
+ golang 1.9+
+ git
+ fabric code
+ fabric-ca code
+ fabric-sample code
+ docker
+ docker-compose
+ make & download fabric binary file
+ pull fabric required docker image

## run fabric e2e examples
```sh
cd /opt/gopath/src/github.com/hyperledger/fabric/examples/e2e_cli
./network_setup.sh up mychannel
```

# setup java dev env
execute the script below:
```sh
$ sudo setup-java.sh
```

start install java prerequisites develop environment software and tools.

## software and tools list
+ wget
+ openjdk-8-jdk
+ maven
+ gradle


# setup hyperledger-composer env
execute the script below:
```sh
$ sudo setup-composer.sh
```

start install composer prerequisites environment software and tools.


# setup blockchain-explorer env
execute the script below:
```sh
$ sudo setup-explorer.sh
```

start install explorer prerequisites environment software and tools.