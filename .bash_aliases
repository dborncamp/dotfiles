# File for extra aliases and only aliases

# common ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Always perserve when copying, why isn't this the default?
alias cp='cp -p'

# Docker

# Hunt the whale and kill it all
alias ahab='docker ps -a | grep -v CONTAINER | awk '\''{print $1}'\'' | xargs docker stop | xargs docker rm; docker volume ls -qf dangling=true | xargs docker volume rm | docker system prune -af'



# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Kubectl
alias k=kubectl
complete -o default -F __start_kubectl k

