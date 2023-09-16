# SSH user jail with docker container

## Why?

Idea is based on

- SFTPGo
  - https://github.com/drakkan/sftpgo/
  - https://hub.docker.com/r/drakkan/sftpgo/
- Docker Jail
  - https://github.com/chazlever/docker-jail

I want a shell for customers for following features:

- restricted
- isolated
- interactive
- minimal
- volatile chroot filesystem
- minimalistic filesystem structure for user view

If you need ONLY sftp chroot without any other features so use OpenSSH's own features. :P
SFTPGo is a good tool for sftp chroot with many other features which we don't need here. We use only the sftp subsystem feature because it used a virtual chroot view by default.

### What's the problem with OpenSSH's own features?
SFTP-only is very easy and nice. But chroot for an interactive shell with OpenSSH's chroot feature is painfull.

Disadvanteges:

- you have to manage the chroot environments by your own
- one persistent chroot for all users or multiple chroots on the host
- only one chroot directory possible, so if you want to offer a shell then the classic linux directory structure needs to be available (/bin, /lib, /etc, ...) and the user will see these also in a sftp session.

### Why don't use rssh?

http://www.pizzashack.org/rssh/ - Note as of september 2023:

> Sadly RSSH died a horrible death in 2019 when it became clear that providing restricted access to arbitrary programs is nearly impossible, particularly without being extremely expert in all of the programs involved (including sshd and all of the applications you wish to restrict). This proved to be an unmanageable task, and support for RSSH ended with unpatched (and I believe unpatchable) security issues, not entirely the fault of RSSH itself.

### So what are the advanteges of a ssh user jail with containers?

- easy automatic build of environments with special needs
  - envs possible without shell and only few specific tools (e.g. rsync)
  - envs possible with full interactive shell and all tools that you need 
- different envs for different user possible
- just keep the container image up to date, the users could use always the newest available version. Each connection has it's own container

### Are there also disadvanteges?

Of course. You will loose several OpenSSH forwarding features.

### Is this solution secure?
I hope so but I don't know it.

## Build container image and install wrapper script

```shell
    git clone https://github.com/mjaepel/ssh_user_jail_with_docker.git
    docker build -t ssh_user_jail:latest ssh_user_jail_with_docker

    sudo cp ssh_user_jail_with_docker/ssh_jail.sh /usr/local/bin/ssh_jail.sh
```

## OpenSSH configuration

```shell
    Subsystem sftp internal-sftp

    Match User <myusername>
        ForceCommand /usr/local/bin/ssh_jail.sh
        AllowTcpForwarding no
        PermitTunnel no
        X11Forwarding no
```

Only one sftp subsystem could be defined per OpenSSH instance. If you need any other than _internal-sftp_ change also line 45 in ssh_jail.sh.

