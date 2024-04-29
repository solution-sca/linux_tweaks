#!/bin/bash
rsync -r sys_files/etc/* /etc/
for user in `ls -1 /home/`; do
    # su -c "cp -r ./sys_files/etc/skel/.* /home/$user/" $user
    su -c "rsync -ar sys_files/etc/skel/* /home/$user/" $user
    # su -c "rsync -r sys_files/etc/skel/.* /home/$user/" $user
done
