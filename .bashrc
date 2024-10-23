# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


export SSL_CERT_FILE=~/ball_pem_builder/Ball.pem
export CURL_CA_BUNDLE=~/ball_pem_builder/Ball.pem
export REQUESTS_CA_BUNDLE=~/ball_pem_builder/Ball.pem
export DOCKER_BUILDKIT=0

source ~/.tokens
export CI_SERVER_HOST="gitlab.aero.ball.com"

# WSL on Global Protect
#wsl.exe -d wsl-vpnkit service wsl-vpnkit start
#echo "Remember to run: sudo /home/dave/wsl-vpnkit"

# Start in home directory
cd ~


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=80000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes
# Otherwise define some colors:
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'              # No Color

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Set different color for a remote terminal
if [[ "${DISPLAY#$HOST}" != ":0.0" &&  "${DISPLAY}" != ":0" ]]; then  
    HILIT=${red}   # remote machine: prompt will be partly red
else
    HILIT=${cyan}  # local machine: prompt will be partly cyan
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# kubernetes auto complete
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Now have some fun
#
# Many of these functions were stolen from:
#
# http://www.tldp.org/LDP/abs/html/sample-bashrc.html
#
#
# useful/fun functions
#

# nuke all docker images. remove all processes amd images, keeps volumes and networks
function docker_nuke(){
    docker rm -f $(docker ps -a -q)
    docker rmi -f $(docker images -a -q)
}

# get the size of the docker cache
function dockersize() {
    ncdu -X .dockerignore
}

# Find a file with a pattern in name:
function ff() { 
    echo "$*"
    find . -type f -iname '*'"$*"'*' -ls 2>&- ; 
}

function fer() {
# Find a file with pattern $1 in name and Execute $2 on it recursively:
    echo "Running ${1} on ${2}"
    ${1} `find -name '*'"*${2}"'*'`
}


function fe() {
# Find a file with pattern $1 in name and Execute $2 on it:
    echo "Running ${2:-file} on ${1:-}"
    find . -type f -iname '*'"${1:-}"'*' \
-exec ${2:-file} {} \;  ; 
}

# Search for things within a file
function findgrep(){
    echo "Remember, do not use wildcards in filename. Automatically added";
    echo "Finding '$1' in '*$2'";
    grep "$1" `find . -type f -iname '*'"$2"`;
}

function histsearch(){
    echo "Looking for $1 in history";
    history | grep "$1";
}

# Remove matching file
function findrm(){
    echo "Recursivley removing any filename matching *$**"
    find . -type f -iname '*'"${1:-}"'*' -exec rm {} \;
}

# Search a man page for a given option
function manopt() {
    echo "searching for option $2 on command $1."
    man $1 | less -p "^ +$2"; 
}


# kill by process name
function killps()  
{
    local pid pname sig="-TERM"   # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: killps [-SIGNAL] pattern"
        return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
    do
        pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
        if ask "Kill process $pid <$pname> with signal $sig?"
            then kill $sig $pid
        fi
    done
}
function my_ps() { ps $@ -o pid,%cpu,%mem,command ; }
function pp() { my_ps -f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

function my_ip() # Get IP adress on ethernet.
{
    /sbin/ifconfig | grep 'inet '
}

function ask()          # See 'killps' for example of use.
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function ii()   # get current host related info
{
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; w -h
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Memory stats :$NC " ; free
    my_ip 2>&- ;
    echo -e "\n${RED}Local IP Address :$NC" ; echo ${MY_IP:-"Not connected"}
    echo -e "\n${RED}ISP Address :$NC" ; echo ${MY_ISP:-"Not connected"}
    echo
}

#conversions
# converts decimal to binary
function dtb() { 
	printf '%d in binary is \e[1;93m' "$1"
	echo "obase=2;$1" | bc; 
	printf "\e[0m"
}
# converts decimal to hex
function dth() { 
	printf '%s in decimal is \e[1;93m 0x' "$@"                
	echo "obase=16; ibase=10; $@"|bc
	printf "\e[0m"       
}
# converts binary to decimal
function btd() { 
	printf '%d in decimal is \e[1;93m%d\n\e[0m' "$1" "$((2#$1))" 
}
# converts binary to hex
function bth() { 
	printf '%d in hex is \e[1;93m0x%X\n\e[0m' "$1" "$((2#$1))" 
}
# converts hex to binary
function htb() { 
	hex=$@                                                   
	val=$(echo $hex | cut -d'x' -f 2)
	printf '%s in binary is \e[1;93m' "$hex"
	echo "obase=2; ibase=16; $val"|bc
	printf "\e[0m"
}
# converts hex to decimal
function htd() { 
	hex=$@
	val=$(echo $hex | cut -d'x' -f 2)
	printf '%s in decimal is \e[1;93m' "$hex"                
	echo "obase=10; ibase=16; $val"|bc
	printf "\e[0m"        
}  


# Complete for terraform
complete -C /usr/local/bin/terraform terraform


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/dave/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/dave/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/dave/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/dave/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# Set up vcpkg
VCPKG_ROOT=/home/dave/playpen/vcpkg/vcpkg/
export PATH="$PATH:/home/dave/playpen/vcpkg/vcpkg/"


# setup GOlang
export PATH=$PATH:/usr/local/go/bin

