#!/bin/bash
# Original from https://github.com/chazlever/docker-jail
# Modifications:
#   - Debug Log
#   - sftp subsystem wrapper for SFTPGo
#   - some small code style changes :P

DEBUG=0
DEBUG_LOG=/var/log/jail.log
DOCKER_IMAGE=ssh_user_jail:latest

###################################################################

containerize()
{
    docker run --rm $1 \
               -v $HOME:/home \
               --workdir /home \
               --hostname ssh-jail-$USER \
               -u 1000:1000 \
               ${DOCKER_IMAGE} ${SSH_ORIGINAL_COMMAND=/bin/sh}

    # Original parameters of chazlever to keep the jail more transparent
    # it depends on your use case if you need the version below or above.

    # docker run --rm $1 \
    #            -v /etc/group:/etc/group:ro \
    #            -v /etc/passwd:/etc/passwd:ro \
    #            -v $HOME:$HOME \
    #            --workdir $HOME \
    #            --hostname $(hostname) \
    #            -u $(id -u $USER):$(id -g $USER) \
    #            ${DOCKER_IMAGE} $SSH_ORIGINAL_COMMAND
}

###################################################################

if [ $DEBUG -eq 1 ]; then
    date -R >> "${DEBUG_LOG}"
    set >> "${DEBUG_LOG}"
fi

###################################################################

if [ "xinternal-sftp" == "x${SSH_ORIGINAL_COMMAND}" ]; then
	[ $DEBUG -eq 1 ] && echo "### START SFTP ###" >> "${DEBUG_LOG}"
	SSH_ORIGINAL_COMMAND="/bin/sftpgo startsubsys"
fi

###################################################################

# Check if TTY allocated
if tty -s; then
    containerize -it
else
    containerize -i
fi
