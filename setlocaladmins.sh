#!/bin/bash
ADMINS=("Clark Beverlin:cdbeverlin.admin:1000:ssh-rsa MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCNtatAdXWnmQ9ljFi4XaUF8a3u
jz4j7ke+Q73mIYmNKlV/BFO5K03dGRO95YEn+3aKJn/CnDWugkbbFVICHrddmFHj
FerMTwVF6fYuTUCkL6bZ/B0uOj5wAVpD8CMhYH8BjAAw1Xkl9QdqE8hW5JFsxXMu
xil2v8Dc74bb+OY9dwIDAQAB clark@theuniverseistoast.com"
""
"")

PASSWDFILE=/etc/passwd
GROUPFILE=/etc/group
BAR = "\033[38;5;148m-----------------------------------------------------------\033[39m"

echo -e "${BAR}"
for USER in "${ADMINS[@]}"
do
	NAME=$(echo $USER|cut -d":" -f1)
	LOGIN=$(echo $USER|cut -d":" -f2)
	USRID=$(echo $USER|cut -d":" -f3)
	PUBKEY=$(echo $USER|cut -d":" -f4)
	HOMEDIR=/home/${LOGIN}
	QUERY1=$(grep "$LOGIN" $PASSWDFILE)
	if [ -z "${QUERY1}" ]; then
		echo "Creating a new account for ${NAME}"
		useradd -c \""${NAME}"\" -u ${USRID} ${LOGIN}
	else
		echo "An account exists for ${LOGIN}"
		CURRENTUID=$(echo ${QUERY1}|cut -d":" -f3)
		CURRENTGID=$(echo ${QUERY1}|cut -d":" -f4)
	
		echo "Checking to see if UID and GID needs to be updated."
		if [ ${CURRENTUID} -ne ${USRID} ] && [ -z $(grep ${USRID} ${PASSWDFILE}) ]; then
			echo "Updating UID from ${CURRENTUID} to ${USRID}"
			usermod -u ${USRID} -c \""${NAME}"\" ${LOGIN}
			find / -uid ${CURRENTUID} -exec chown "$USRID" "{}" \;
		else
			echo "Skipping, UID is currently in use."
		fi
		if [ ${CURRENTGID} -ne ${USRID} ] && [ -z $(grep ${USRID} ${GROUPFILE}) ]; then
			echo "Updating GID from ${CURRENTGID} to ${USRID}"
			groupmod -g ${USRID} ${LOGIN}
			usermod -g ${USRID} ${LOGIN}
			find / -gid ${CURRENTGID} -exec chgrp "${USRID}" "{}" \;
		else
			echo "Skipping, GID currently is currently in use."
		fi
	fi
	echo "Importing public keys"
	if [ ! -d ${HOMEDIR}/.ssh ]; then
		mkdir ${HOMEDIR}/.ssh
	fi
	echo "${PUBKEY}" > ${HOMEDIR}/.ssh/authorized_keys
	chmod 700 ${HOMEDIR}/.ssh
	chmod 600 ${HOMEDIR}/.ssh/authorized_keys
	chown -R ${USRID}:${USRID} ${HOMEDIR}/.ssh
	echo -e "${BAR}"
done
exit
