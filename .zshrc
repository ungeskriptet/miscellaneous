source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
autoload compinit promptinit bashcompinit
compinit; promptinit; bashcompinit
zstyle ':completion:*' menu select

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
unsetopt share_history
setopt nobeep

bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin"
export EDITOR=nvim
export ANDROID="/mnt/1TB_HDD/Android"
export OO_PS4_TOOLCHAIN="$HOME/Projects/PS4/OpenOrbis/PS4Toolchain"

#LineageOS
#export USE_CCACHE=1
#export CCACHE_EXEC=/usr/bin/ccache
#ccache -M 50G > /dev/null

setopt rm_star_silent
eval "$(register-python-argcomplete pmbootstrap)"

adb-flash () {
	adb push $2 /tmp
	adb shell "cat /tmp/$(basename $2) > /dev/block/by-name/$1" && echo "$2 flashed to $1 successfully" &&
	[ "$3" = "-r" ] && adb reboot $4
}

ucd () {
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

gencclist () {
	echo "$(./scripts/get_maintainer.pl --nogit --nogit-fallback --norolestats --r "$@" | xargs -I {} echo --to=\"{}\" | tr '\n' ' ')"
}

upload-file () {
	curl \
	-F key=[ let's not ] \
	-F file=@$1 \
	https://catgirlsare.sexy/api/upload
}

search () { find . -iname "*$1*"}

confirm-multiboot () { grub-file --is-x86-multiboot $1 && echo "Multiboot 1 confirmed" || echo "No multiboot header found!" }

fritz-reconnect () {
	curl \
	-H 'Content-Type: text/xml; charset="utf-8"' \
	-H "SoapAction: urn:schemas-upnp-org:service:WANIPConnection:1#ForceTermination" \
	-d '<?xml version="1.0" encoding="utf-8"?> <s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"> <s:Body> <u:ForceTermination xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1" /> </s:Body> </s:Envelope>' \
	"http://fritz.box:49000/igdupnp/control/WANIPConn1"
}

adb-restart-root () {
	adb shell su -c "resetprop ro.debuggable 1"
	adb shell su -c "resetprop service.adb.root 1"
	adb shell su -c "magiskpolicy --live \'allow adbd adbd process setcurrent\'"
	adb shell su -c "magiskpolicy --live \'allow adbd su process dyntransition\'"
	adb shell su -c "magiskpolicy --live \'permissive { su }\'"
	adb shell su -c "kill -9 \`ps -A | grep adbd | awk '{print $2}'\`"
}

hexdiff () {
	diff <(hexdump -C $1) <(hexdump -C $2)
}

adb-dump-regulators () {
	adb shell 'cd /sys/class/regulator; for i in $(ls); do cat $i/name; [ -f "$i/max_microvolts" ] && echo "$i/name" || echo "$i/name\n"; [ -f "$i/min_microvolts" ] && cat $i/min_microvolts && echo "$i/min_microvolts"; [ -f $i/max_microvolts ] && cat $i/max_microvolts && echo "$i/max_microvolts\n"; done'
}

gen-dtbo-empty () {
	if [ -z "$1" ]; then
		echo "DTBO partition size in bytes required"
	else
		dd if=/dev/zero of=empty_dtbo.img count=1
		avbtool add_hash_footer --partition_name dtbo --partition_size $1 --image empty_dtbo.img
	fi
}

adb-install-magisk () {
	[ -f magisk.apk ] && rm magisk.apk
	MAGISK_VER=$(curl --silent https://api.github.com/repos/topjohnwu/Magisk/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//') &&
	curl -L https://github.com/topjohnwu/Magisk/releases/download/v$MAGISK_VER/Magisk-v$MAGISK_VER.apk -o magisk.apk &&
	adb install magisk.apk &&
	[ -f magisk.apk ] && rm magisk.apk
}

alias cdpmaports="cd $HOME/.local/var/pmbootstrap/cache_git/pmaports"
alias reboot="read -q '?Reboot? [Y/N]: ' && reboot"
alias symlink-python2="sudo rm -rf /usr/bin/python && sudo ln -s /usr/bin/python2 /usr/bin/python"
alias symlink-python3="sudo rm -rf /usr/bin/python && sudo ln -s /usr/bin/python3 /usr/bin/python"
alias compress-video="ffmpeg -vcodec libx264 -crf 28 output.mp4 -i"
alias rp="realpath"
alias vim="nvim"
alias yt-mp3="yt-dlp -x --audio-format mp3"
alias heimdall="heimdall-wait-for-device && heimdall"
alias editor="stfu gnome-text-editor"
alias gen-vbmeta-disabled="avbtool make_vbmeta_image --flags 2 --padding_size 4096 --output vbmeta_disabled.img"
alias mpv-hdmi="mpv --demuxer-lavf-o=video_size=1280x720,input_format=mjpeg av://v4l2:/dev/video0 --profile=low-latency"

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
