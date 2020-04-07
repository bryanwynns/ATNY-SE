# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin
alias kc=kubectl
alias getnodes='kubectl get nodes'
alias getpods='kubectl get pods'
alias delete='kubectl delete deployment'
alias apply='kubectl apply -f '
alias an='ansible nodes -a '
alias shutdownall='ansible nodes -a "init 0" '
alias stopai='ansible nodes -a "/opt/Panorama/hedzup/mn/bin/agent stop" '
alias startai='ansible nodes -a "/opt/Panorama/hedzup/mn/bin/agent start"'


export PATH
