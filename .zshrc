source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
autoload compinit promptinit bashcompinit
compinit; promptinit; bashcompinit
zstyle ':completion:*' menu select

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
unsetopt share_history

bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin"
export EDITOR=nvim
export ANDROID="/mnt/1TB_HDD/Android"

#LineageOS
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"
ccache -M 50G > /dev/null

setopt rm_star_silent
eval "$(register-python-argcomplete pmbootstrap)"

ucd (){
    depth=$1
    dir="$PWD"
    for iter in $(seq 1 $depth)
    do
        cd ..
    done
    ls
}

base64decode () {
  echo "$1" | base64 -d ; echo
}

pmaports-build () {
  pmbootstrap checksum $1 && pmbootstrap build $1 $2 --force
}

stfu () {
  $@>/dev/null 2>&1 &!
}

heimdall-wait-for-device () {
	echo "< wait for any device >"
	while ! heimdall detect > /dev/null 2>&1; do
		sleep 1
	done
}

fastboot-switch-slot () {
	current_slot=$(fastboot getvar current-slot 2>&1|grep current-slot)
	grep "current-slot: a" <<< $current_slot && fastboot set_active b
	grep "current-slot: b" <<< $current_slot && fastboot set_active a
}

samloader-dl () {
	version=$(samloader -m $1 -r $2 checkupdate)
	samloader -m $1 -r $2 download -v $version -O . -D
}

gencclist () {
	echo "$(./scripts/get_maintainer.pl --nogit --nogit-fallback --norolestats --r "$@" | xargs -I {} echo --to=\"{}\" | tr '\n' ' ')"
}

extract-section0 () {
	uefi-firmware-parser -p -b -e section0 > output.txt && volume=$(grep -o -P '(?<=Wrote: ./).*(?=.fv)' output.txt) && while read -r name && read -r guid <&3; do mv $volume/file-$guid $volume/$name; done <<(grep -o -P '(?<=Name: ).*' output.txt) 3<<(grep -o -P '(?<=: ).*(?= type)' output.txt|tail +3) && rm -rf output.txt
}

alias cdpmaports="cd $HOME/.local/var/pmbootstrap/cache_git/pmaports"
alias edl-flashall="for i in $(ls | sed 's/.bin//g'); do [[ ! $i =~ ^gpt.+$ ]] && [[ $i != 'extracted' ]] && [[ "$i" != 'edl_config.json' ]] && edl --loader $1 w $i $i.bin; done"
alias reboot="read -q '?Reboot? [Y/N]: ' && reboot"
alias symlink-python2="sudo rm -rf /usr/bin/python && sudo ln -s /usr/bin/python2 /usr/bin/python"
alias symlink-python3="sudo rm -rf /usr/bin/python && sudo ln -s /usr/bin/python3 /usr/bin/python"
alias compress-video="ffmpeg -vcodec libx264 -crf 28 output.mp4 -i"
alias rp="realpath"
alias vim="nvim"
alias yt-mp3="yt-dlp -x --audio-format mp3"
alias w-heimdall="heimdall-wait-for-device && heimdall"
alias editor="stfu gnome-text-editor"

# Oh my ZSH
ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi
plugins=(git)
zstyle ':omz:update' mode auto
ZSH_THEME="bira"
ZSH=/usr/share/oh-my-zsh/
source $ZSH/oh-my-zsh.sh
