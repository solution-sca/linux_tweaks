#!/bin/bash
rsync -r sys_files/etc/* /etc/
rsync -r sys_files/usr/* /usr/
for user in `ls -1 /home/`; do
    su -c "rsync -ar sys_files/etc/skel/ /home/$user/" $user
done
