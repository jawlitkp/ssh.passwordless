#!/bin/bash
#Author: kashu
#My Website: https://kashu.org
#Date: 2016-01-25
#Filename: ssh.passwordless.sh
#Description: Set up password-less SSH login (Not only for CentOS/RHEL/Xubuntu)

_ip="$1"
_port="$2"
_username="$3"

i_failed(){
  echo "openssh-clients install failed"
  exit
}

usage(){
  echo "Usage: $0 ip_address port_number username"
	echo "Example 1: ssh.passwordless.sh 192.168.1.1"
	echo "Example 2: ssh.passwordless.sh 192.168.1.1 2222 kashu"
  exit
}

# check IP address
if [ -z "$1" ]; then
  usage
elif ! echo "$1" | egrep -sq "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"; then
	echo "IP address error"; exit
else
	:
fi

# check port number
if [ -z "$2" ]; then
  _port=22
elif [ "`echo ${2}+0|bc 2> /dev/null`" == "${2}" ]; then
  if [ ${2} -le 0 -o ${2} -ge 65535 ]; then
    echo "port number range: 1-65534"
  fi
else
  echo "port nubmer error"
fi

# check username
if [ -z "$3" ]; then
  _username=root
fi

# check if the public and private keys exist (the default type of key is RSA for version 2)
if [ ! -s "${HOME}/.ssh/id_rsa" -o ! -s "${HOME}/.ssh/id_rsa.pub" ]; then
  ssh-keygen -q -t rsa -b 2048 -P "" -f ~/.ssh/id_rsa
fi

# upload the public key to SSH server
if ! ssh-copy-id -p "$_port" -i ~/.ssh/id_rsa.pub "$_username"@"$_ip"; then
  if [ ! -x /usr/bin/scp ]; then
    if [ -x /usr/bin/yum ]; then
      sudo yum -y install openssh-clients || i_failed
    elif [ -x /usr/bin/apt-get ]; then
      sudo apt-get -y install openssh-clients || i_failed
    else
      echo "scp command dose not exist"
      exit
    fi
  fi

  if [ -z "$_username" -o "$_username" == "root" ]; then
    ssh -p "$_port" "$_username"@"$_ip" "mkdir -p /root/.ssh/ &> /dev/null"
    scp -P "$_port" ~/.ssh/id_rsa.pub "$_username"@"$_ip":/root/.ssh/"${_ip}".pub
    ssh -p "$_port" "$_username"@"$_ip" "cat /root/.ssh/"${_ip}".pub >> /root/.ssh/authorized_keys"
  else
    ssh -p "$_port" "$_username"@"$_ip" "mkdir -p /home/${_username}/.ssh/ &> /dev/null"
    scp -P "$_port" ~/.ssh/id_rsa.pub "$_username"@"$_ip":/home/${_username}/.ssh/"${_ip}".pub
    ssh -p "$_port" "$_username"@"$_ip" "cat /home/${_username}/.ssh/"${_ip}".pub >> /root/.ssh/authorized_keys"
  fi
fi
