# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
#HISTSIZE=0
#HISTFILESIZE=0
#unset HISTFILE

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

##{{{ git zsh's functions

function git-branch-name {
  git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3
  }
function git-branch-prompt {
  local branch=`git-branch-name`
  if [ $branch ]; then printf " [%s]" $branch; fi
  }
## for bash
# PS1="\u@\h \[\033[0;36m\]\W\[\033[0m\]\[\033[0;32m\]\$(git-branch-prompt)\[\033[0m\] \$ "
##}}}

# Determine active Python virtualenv details.
function git-venv-prompt {
  if [ -n "$VIRTUAL_ENV" ]; then printf " (%s)" "$(basename "$VIRTUAL_ENV")"; fi
}



##{{{ tmux functions
tmux-panel () {
    tmux_win_name="${1}"
    shift
    ## now $1 is the command 

    if [ -n "${1}" ]; then
        ${try} tmux kill-window -t :${tmux_win_name} ; tmux new-window -n ${tmux_win_name} -d "${1}"
        shift
        while [ -n "${1}" ]; do
            ## echo "LOG: WORKING ON command ${1}"
            tmux split-window -t ${tmux_win_name} -d "${1}"
            ## tmux: better visualization
            tmux select-layout -t ${tmux_win_name} tiled
            shift
        done
    fi
}
##}}}

##{{{ generic functions
q-ssh-copy() {
        ssh ${*:1} "cp  ~/.bashrc ~/.bashrc$(date); cat > ~/.bashrc" < ~/.bashrc
}
num-from-string() {
    string="$2";
    module="$1";
    num="$( echo "${string}" | md5sum | grep -Eo "[[:digit:]]{3}"|head -n1 )";
    num="$(( ${num} % ${module} ))"; echo $num;
}
##}}}

 # it returns a nice command prompt string. See https://wiki.archlinux.org/index.php/Color_Bash_Prompt
set_prompt () {
    Last_Command=$? # Must come first!
    # DefaultColors
    Blue='\[\e[01;34m\]'
    White='\[\e[01;37m\]'
    Red='\[\e[01;31m\]'
    Green='\[\e[01;32m\]'
    Reset='\[\e[00m\]'
    FancyX='\342\234\227'
    Checkmark='\342\234\223'
    # MyColors: http://misc.flogisoft.com/bash/tip_colors_and_formatting
    Yellow='\[\e[33m\]'
    Magenta='\[\e[35m\]'
    Cyan='\[\e[36m\]'
    LightGray='\[\e[37m\]'
    DarkGray='\[\e[90m\]'
    LightRed='\[\e[91m\]'
    LightGreen='\[\e[92m\]'
    LightYellow='\[\e[93m\]'
    LightBlue='\[\e[94m\]'
    LightMagenta='\[\e[95m\]'
    LightCyan='\[\e[96m\]'
    #
    MyColors=( "$Yellow" "$Magenta" "$Cyan" "$LightGray" "$DarkGray" "$LightRed" "$LightGreen" "$LightBlue" "$LightMagenta" "$LightCyan" )
    HostHash="$(num-from-string "${#MyColors[@]}" $(hostname))"
    
    # Add a bright white exit status for the last command
    LEFT_PROMPT="$White\$? "
    # Decide the color of prompt
    if [[ -z "${SSH_CONNECTION}" ]]; then
	HostColor="$Green"
    elif [[ -n "${ssh_color}" ]]; then
	HostColor="${!ssh_color}"
    else
	HostColor="${MyColors[$HostHash]}"
    fi
    # If it was successful, print a green check mark. Otherwise, print
    # a red X.
    if [[ $Last_Command == 0 ]]; then
        LEFT_PROMPT+="$Green$Checkmark "
    else
        LEFT_PROMPT+="$Red$FancyX "
    fi
    # If root, just print the host in red. Otherwise, print the current user
    # and host in green.
    if [[ $EUID == 0 ]]; then
        LEFT_PROMPT+="$Red\\u${HostColor}@\\h "
    else
        LEFT_PROMPT+="$HostColor\\u@\\h "
    fi
    # Print the working directory and prompt marker in blue, and reset
    # the text color to the default.
    LEFT_PROMPT+="$Blue\\w"      # full path
    #LEFT_PROMPT+="$Blue\\W"     # only parent directory
    # Add git repo
    LEFT_PROMPT+="\$(git-branch-prompt)"
    # Add venv
    LEFT_PROMPT+="\$(git-venv-prompt) "
    # Color reset
    #LEFT_PROMPT+="\\n"           # add new line
    LEFT_PROMPT+="\\\$$Reset "   # add $, reset color
    #RIGHT_PROMPT="\w \$(git-branch-prompt) "
    if [ -n "$RIGHT_PROMPT" ] ; then
	compensate=11
	str_len=${#RIGHT_PROMPT}
	PS1=$(printf "%*s\r%s\$ " "$(($(tput cols)-40+${compensate}-${str_len}))" "$RIGHT_PROMPT" "$LEFT_PROMPT")
	echo $PS1
    else
    	PS1=$LEFT_PROMPT
    fi
}
# With the following command it call set_prompt every prompt it is enought call one time set_prompt.
#PROMPT_COMMAND='set_prompt'

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

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
    # corored
    # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    # my choice
    PROMPT_COMMAND='set_prompt'
else
    # black and white
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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

### functions
# http://unix.stackexchange.com/questions/4290/aliasing-cd-to-pushd-is-it-a-good-idea
pushd_fun()		       
{
  if [ $# -eq 0 ]; then
    local DIR="${HOME}"
  else
    local DIR="$1"
  fi

  builtin pushd "${DIR}" > /dev/null
}

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cd='pushd_fun'
alias p='popd'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export PATH="$PATH:$HOME/h/share/bin"
export PATH="$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin"
alias rm='rm -i'

# ----remote-important-part

## if [ -o $TMUX ] ; then cat /var/run/motd.dynamic  ;fi

BASHRC_TEMP_FILE='~/.bashrc'
alias bash="bash --rcfile ${BASHRC_TEMP_FILE}"
alias sudo-s="sudo bash --rcfile ${BASHRC_TEMP_FILE}" 
alias sudo-i="sudo -i bash --rcfile ${BASHRC_TEMP_FILE}" 
alias histon="export HISTFILE=${HOME}/.bash_history; history -r $HISTFILE"
alias tt="'tmux' new-session -s 0 '/bin/bash --rcfile ${BASHRC_TEMP_FILE}' \; \
      bind c new-window '/bin/bash --rcfile ${BASHRC_TEMP_FILE}' \; \
      bind '\"' split-window '/bin/bash --rcfile ${BASHRC_TEMP_FILE}' \; \
      bind '%' split-window -h '/bin/bash --rcfile ${BASHRC_TEMP_FILE}' \
      || tmux att -t 0"
alias ttt="'tmux' new-session -s 0 '/bin/bash --rcfile ${BASHRC_TEMP_FILE}' \; \
            set -g prefix C-j \; \
      	    bind c new-window '/bin/bash --rcfile ${BASHRC_TEMP_FILE}' \; \
      	    bind '\"' split-window '/bin/bash --rcfile ${BASHRC_TEMP_FILE}' \; \
      	    bind '%' split-window -h '/bin/bash --rcfile ${BASHRC_TEMP_FILE}'  || tmux att -t 0"
#alias tmux='"tmux" set-option -g default-shell "/bin/bash" \; new-session '
#alias tmux2='"tmux" set-option -g default-shell "/bin/bash --rcfile ${BASHRC_TEMP_FILE}" \; new-session '
#alias t='"tmux" set-option -g default-shell "/bin/bash" \; new-session -n ronin -s root  || tmux att -t root'
#alias t2='"tmux" set-option -g default-shell "/bin/bash --rcfile ${BASHRC_TEMP_FILE}" \; new-session -n ronin -s root  || tmux att -t root'

 # other useful
alias d='pwd'
alias u='pwd'
 # git
alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias gco=' git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'
alias glog='$EDITOR "$(git rev-parse --show-toplevel)"/git_partial_commit_gitign'
alias git-root='echo "$(git rev-parse --show-toplevel)"'
alias git-push-continuosly="while : ; do if (git status |grep 'Your branch is ahead') ; then  git push; fi; sleep 1; date ;done"
alias git-keep-synced="
      while : ; do
      	    if (git status |grep 'Your branch is ahead') ; then 
	       git push; 
	    fi; 
	    git fetch;
	    date ;
	    sleep 10; 
      done"
 # git : bash only
alias git-histall-sig="git log --pretty=format:\"%h %ad %G? |%d -----%s [%an]\" --graph --date=short --abbrev=4 --all"
alias git-chist="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias git-chistall="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias git-trash-subdirs='for i in *; do git -C $i status |grep "Your branch is up to date" >> /dev/null && mv $i ~/canc/.; done;'

 # docker
alias docker-rmi-none="docker rmi \$(docker images |grep '^<none>'| awk '{print \$3}')" 

# vars
if which emacs > /dev/null; then
    export EDITOR='emacs'
elif which vim ; then
    export EDITOR='vim'
else
    export EDITOR='nano'
fi

create_bashrc_local_as_default () {
    cat - > ~/.bashrc_local <<EOF
EDITOR=nano
EOF
    
}

if [ -f ~/.bashrc_local ]; then
    . ~/.bashrc_local
else
    create_bashrc_local_as_default
    . ~/.bashrc_local
fi
