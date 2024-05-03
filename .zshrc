#!/usr/bin/zsh

HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000
PATH=$PATH:$HOME/.local/bin
export SSH_ASKPASS=/usr/bin/ksshaskpass
export SSH_ASKPASS_REQUIRE=prefer
EDITOR=nvim

autoload -Uz edit-command-line \
             history-search-end \
             compinit \
             bashcompinit \
             bracketed-paste-magic \
             url-quote-magic

setopt autocd extendedglob nomatch incappendhistory
unsetopt beep
bindkey -e

zle -N edit-command-line
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

bindkey "^[[3~" delete-char
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^X^E" edit-command-line

zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' menu select
zstyle ':completion:*' insert-tab false
zstyle :compinstall filename '/home/david/.config/zsh/.zshrc'

compinit; bashcompinit
PROMPT="╭─%F{magenta}%n@%M%f %F{blue}%~%f >
╰─ "

adb-dump-regulators () {
        adb shell 'cd /sys/class/regulator; for i in $(ls); do cat $i/name; [ -f "$i/max_microvolts" ] && echo "$i/name" || echo "$i/name\n"; [ -f "$i/min_microvolts" ] && cat $i/min_microvolts && echo "$i/min_microvolts"; [ -f $i/max_microvolts ] && cat $i/max_microvolts && echo "$i/max_microvolts\n"; done'
}

adb-flash () {
        cat $2 | adb shell "cat > /dev/block/by-name/$1" &&
        echo "Flashing finished" &&
        [ "$3" = "-r" ] && adb reboot $4
}

adb-install-magisk () {
        [ -f magisk.apk ] && rm magisk.apk
        MAGISK_VER=$(curl --silent https://api.github.com/repos/topjohnwu/Magisk/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//') &&
        curl -L https://github.com/topjohnwu/Magisk/releases/download/v$MAGISK_VER/Magisk-v$MAGISK_VER.apk -o magisk.apk &&
        adb install magisk.apk &&
        [ -f magisk.apk ] && rm magisk.apk
}

adb-restart-root () {
        adb shell su -c "resetprop ro.debuggable 1"
        adb shell su -c "resetprop service.adb.root 1"
        adb shell su -c "magiskpolicy --live \'allow adbd adbd process setcurrent\'"
        adb shell su -c "magiskpolicy --live \'allow adbd su process dyntransition\'"
        adb shell su -c "magiskpolicy --live \'permissive { su }\'"
        adb shell su -c "kill -9 \`ps -A | grep adbd | awk '{print $2}'\`"
}

git-branch-name() {
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '- ('$branch')'
  fi
}

heimdall-wait-for-device () {
        echo "< wait for any device >"
        while ! heimdall detect > /dev/null 2>&1; do
                sleep 1
        done
}

scp-pull () {
        scp $1:$2 .
}

search () {
        find . -iname "*$1*"
}

stfu () {
        $@>/dev/null 2>&1 &!
}

ucd () {
        depth=$1
        dir="$PWD"
        for iter in $(seq 1 $depth)
        do
                cd ..
        done
        pwd
}

alias gen-vbmeta-disabled="avbtool make_vbmeta_image --flags 2 --padding_size 4096 --output vbmeta_disabled.img"
alias heimdall="heimdall-wait-for-device && heimdall"
alias reboot="read -q '?Reboot? [Y/N]: ' && sudo reboot"
alias rp="realpath"
alias vim="nvim"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
