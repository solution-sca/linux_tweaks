set -a
fg_off=$(tput sgr0)
format_off=$(tput sgr0)
fg_default="\e[39m"
fg_black=$(tput setaf 0)
fg_red=$(tput setaf 1)
fg_green=$(tput setaf 2)
fg_yellow=$(tput setaf 3)
fg_blue=$(tput setaf 4)
fg_magenta=$(tput setaf 5)
fg_cyan=$(tput setaf 6)
fg_white=$(tput setaf 7)
fg_gray=$(tput setaf 8)
fg_brown=$(tput setaf 94)
fg_orange=$(tput setaf 208)
fg_amber=$(tput setaf 136)
#fg_amber=$(tput setaf 214)
bg_blue=$(tput setab 4)
bg_red=$(tput setab 1)
bg_burowy=$(tput setab 236)
fg_rev=$(tput rev)
set +a

# Colors for hostname types
hostname_color=${fg_green}
if [ ${UID} -eq 0 ]; then
    hostname_color=${fg_red}
elif $(command -v vbox-greeter >/dev/null 2>&1); then
    hostname_color=${fg_amber}
elif [[ -n "${SSH_CLIENT}" ]]; then
    hostname_color=${fg_cyan}
fi
buf=fg_${NETNS//-/_}
ns_colour=${!buf}
ns_colour="${ns_colour:-${fg_amber}}"
#`p1 10.0.2.140`

function is_vpn_connection(){
    ip link show dev tun0 2>/dev/null | grep -c LOWER_UP
}

# shellcheck disable=2154
# Bez zamknięcia nazw kolorów w \[${nazwa}\] PS1 działa, ale rozwala się przewijanie historii strzałką (dziwne rzeczy, gdy po dłuższym tekscie jest krótszy)
PS1="\[\033[0;31m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")\
[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]root'${fg_red}@${hostname_color}'\h'; else echo '\[\033[0;39m\]\u'${fg_amber}@${hostname_color}'\h'; fi)\
\[\033[0;31m\]]\
\$( [ -n \"${NETNS}\" ]  &&  echo \"\342\224\200[\[${ns_colour}\]netns \${NETNS}\[${fg_red}\]]\"    )\
\$( [ -n \"\${tag}\" ]  &&  echo \"\342\224\200[\[${fg_amber}tag \${tag}\[${fg_red}\]]\"    )\
\$( [ -n \"\${build}\" ]  &&  echo \"\342\224\200[\[${fg_amber}build \${build}\[${fg_red}\]]\"    )\
\342\224\200[${fg_amber}\W\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\
\$( [ -n \"\${PGRENV_DATESTAMP}\" ]  &&  echo \"\342\224\200[\[${fg_amber}\]\$(date +\%Y-\%m-\%d-\%H:\%M:\%S)${fg_red}]\")\
\$( [ -n \"\${PPJ1_CLIGRP}\" ]  &&  echo \"\342\224\200[\[${fg_amber}\]voipgrp \${PPJ1_CLIGRP}\[${fg_red}\]]\"    )\
\$( [ -n \"\${ipaddr}\" ]  &&  echo \"\342\224\200[\[${fg_amber}\]ipaddr \${ipaddr}\[${fg_red}\]]\"    )\
\$( [ \"\$(is_vpn_connection)\" -eq 1 ]  &&  echo \"\342\224\200[\[${fg_red}\]VPN]\"    )\
\342\224\200 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\] "
# else
#     PS1='─[\u@\h]─[\W]\n└── \$ '
# fi

# Set 'man' colors
man() {
env \
LESS_TERMCAP_mb=$'\e[01;31m' \
LESS_TERMCAP_md=$'\e[01;31m' \
LESS_TERMCAP_me=$'\e[0m' \
LESS_TERMCAP_se=$'\e[0m' \
LESS_TERMCAP_so=$'\e[01;44;33m' \
LESS_TERMCAP_ue=$'\e[0m' \
LESS_TERMCAP_us=$'\e[01;32m' \
man "$@"
}
