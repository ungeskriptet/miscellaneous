#!/usr/bin/zsh
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
mkdir -p \
	$XDG_CACHE_HOME/zsh \
	$XDG_CONFIG_HOME/git \
	$XDG_CONFIG_HOME/gtk-2.0 \
	$XDG_CONFIG_HOME/java \
	$XDG_CONFIG_HOME/mitmproxy \
	$XDG_DATA_HOME/android \
	$XDG_DATA_HOME/cargo \
	$XDG_DATA_HOME/gnupg \
	$XDG_DATA_HOME/gradle
export EDITOR=nvim
export HISTSIZE=50000
export SAVEHIST=10000
export OUT=~/projects/lineage-22.1/out/target/product/e3q
export ANDROID_PRODUCT_OUT=$OUT
export BUILD_HOSTNAME=ryuzu
export BUILD_USERNAME=david
export PIP_BREAK_SYSTEM_PACKAGES=1
export ANDROID_HOME=$HOME/.local/share/android-sdk
export ANDROID_USER_HOME="$XDG_DATA_HOME"/android
export LESS='-R --use-color -Dd+r$Du+b$'
export PATH=$PATH:$HOME/.local/bin:$ANDROID_HOME/cmdline-tools/latest/bin:/var/lib/flatpak/exports/bin:$HOME/.local/share/flatpak/exports/bin
export PYTHON_HISTORY=$XDG_CACHE_HOME/python_history
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export HISTFILE=$XDG_CACHE_HOME/zsh/histfile
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java -Djavafx.cachedir=${XDG_CACHE_HOME}/openjfx"
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export NTFY_TOKEN=""

[[ $XDG_CURRENT_DESKTOP = "KDE" ]] &&
export SSH_ASKPASS_REQUIRE=prefer &&
export SSH_ASKPASS=/usr/bin/ksshaskpass ||
eval $(ssh-agent)

autoload -Uz edit-command-line \
	     bashcompinit \
	     bracketed-paste-magic \
	     compinit \
	     down-line-or-beginning-search \
	     history-search-end \
	     select-word-style \
	     up-line-or-beginning-search \
	     url-quote-magic

select-word-style bash
setopt autocd extendedglob nomatch incappendhistory prompt_subst hist_ignore_all_dups hist_expire_dups_first hist_ignore_space
unsetopt beep
bindkey -e

bashcompinit
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
eval "$(register-python-argcomplete pmbootstrap)"

zle -N bracketed-paste bracketed-paste-magic
zle -N down-line-or-beginning-search
zle -N edit-command-line
zle -N self-insert url-quote-magic
zle -N up-line-or-beginning-search

bindkey "^H" backward-kill-word
bindkey "^[[1;5D" backward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[3~" delete-char
bindkey "^[[B" down-line-or-beginning-search
bindkey "^X^E" edit-command-line
bindkey "^[[F" end-of-line
bindkey "^[[1;5C" forward-word
bindkey "^[[A" up-line-or-beginning-search

zstyle :compinstall filename '/home/david/.config/zsh/.zshrc'
zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' menu select

alias adb='HOME="$XDG_DATA_HOME"/android adb'
alias adb-poweroff="adb shell reboot -p"
alias adb-skip-wizard="adb shell settings put secure user_setup_complete 1 && adb shell settings put global device_provisioned 1"
alias clear="clear && printf '\033c'"
alias compress-vid="ffmpeg -vcodec libx264 -crf 28 output.mp4 -i"
alias diff='diff --color=auto'
alias docker-update='docker system prune -a -f && sudo docker-compose -f /opt/docker/compose.yaml pull && sudo docker-compose -f /opt/docker/compose.yaml up -d && docker system prune -a -f'
alias dolphin="stfu dolphin ."
alias gen-vbmeta-disabled="avbtool make_vbmeta_image --flags 2 --padding_size 4096 --output vbmeta_disabled.img"
alias grep='grep --color=auto'
alias heimdall="heimdall-wait-for-device && /usr/bin/heimdall"
alias ip='ip -color=auto'
alias ls="ls --color=auto"
alias mitmproxy="mitmproxy --set confdir=$XDG_CONFIG_HOME/mitmproxy"
alias mitmweb="mitmweb --set confdir=$XDG_CONFIG_HOME/mitmproxy"
alias odin4="heimdall-wait-for-device && sleep 1 && /usr/bin/odin4"
alias reboot="read -q '?Reboot? [Y/N]: ' && sudo reboot"
alias reboot-uefi="systemctl reboot --firmware-setup"
alias rp="realpath"
alias scp='scp -o "AddKeysToAgent yes"'
alias ssh='ssh -o "AddKeysToAgent yes"'
alias udevreload="sudo udevadm control --reload-rules && sudo udevadm trigger"
alias vim="nvim"
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
alias wg-genall="wg genkey | tee $(tty) | wg pubkey && wg genpsk"
alias zshrc="nvim $HOME/.config/zsh/.zshrc"

adb-boot-log () {
	adb wait-for-recovery &&
	adb shell "[ -f /metadata/boot_log.txt ] || mount /dev/block/by-name/metadata /metadata" &&
	rm -rf $HOME/Downloads/boot_log.txt &&
	adb pull /metadata/boot_log.txt $HOME/Downloads/boot_log.txt &&
	[ "$1" = "--view" ] &&
	nvim $HOME/Downloads/boot_log.txt
}

adb-dump-regulators () {
        adb shell 'cd /sys/class/regulator; for i in $(ls); do cat $i/name; [ -f "$i/max_microvolts" ] && echo "$i/name" || echo "$i/name\n"; [ -f "$i/min_microvolts" ] && cat $i/min_microvolts && echo "$i/min_microvolts"; [ -f $i/max_microvolts ] && cat $i/max_microvolts && echo "$i/max_microvolts\n"; done'
}

adb-flash () {
	pv $2 | adb shell "cat > /dev/block/by-name/$1" &&
	echo "Flashing finished" &&
	[ "$3" = "-r" ] && adb reboot $4
}

adb-get-super-size () {
	SUPER_PARTITION_SIZE=$(adb shell "su -c blockdev --getsize64 /dev/block/by-name/super")
	DYNAMIC_PARTITIONS_SIZE=$((SUPER_PARTITION_SIZE - 4194304))
	echo "BOARD_SUPER_PARTITION_SIZE := $SUPER_PARTITION_SIZE"
	echo "BOARD_QTI_DYNAMIC_PARTITIONS_SIZE :: $DYNAMIC_PARTITIONS_SIZE"
}

adb-install-fdroid () {
	echo "< waiting for any device >"
	adb wait-for-device &&
	[ -f F-Droid.apk ] && rm F-Droid.apk
	curl https://f-droid.org/F-Droid.apk -o F-Droid.apk
	adb install F-Droid.apk
	[ -f F-Droid.apk ] && rm F-Droid.apk
}

adb-install-magisk () {
	echo "< waiting for any device >"
	adb wait-for-device &&
	[ -f magisk.apk ] && rm magisk.apk
	MAGISK_VER=$(curl --silent https://api.github.com/repos/topjohnwu/Magisk/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//') &&
	curl -L https://github.com/topjohnwu/Magisk/releases/download/v$MAGISK_VER/Magisk-v$MAGISK_VER.apk -o magisk.apk &&
	adb install magisk.apk
	[ -f magisk.apk ] && rm magisk.apk
}

adb-last-kmsg () {
	echo "< waiting for any device >" &&
	adb wait-for-recovery &&
	rm -rf ~/Downloads/last_kmsg &&
	adb pull /proc/last_kmsg $HOME/Downloads/last_kmsg &&
	[ "$1" = "--view" ] &&
	nvim $HOME/Downloads/last_kmsg
}

adb-restart-root () {
	adb wait-for-device &&
	adb shell su -c "resetprop ro.debuggable 1"
	adb shell su -c "resetprop service.adb.root 1"
	adb shell su -c "magiskpolicy --live \'allow adbd adbd process setcurrent\'"
	adb shell su -c "magiskpolicy --live \'allow adbd su process dyntransition\'"
	adb shell su -c "magiskpolicy --live \'permissive { su }\'"
	adb shell su -c "kill -9 \`ps -A | grep adbd | awk '{print $2}'\`"
}

cddevice () {
	cd $HOME/projects/lineage-22.1/device/$1
}

cddownloads () {
	[ -d $HOME/download ] && cd "$HOME/download/$1" && true ||
	cd $HOME/Downloads/$1
}

cdkernel () {
	cd $HOME/projects/lineage-22.1/kernel/$1
}

check-files () {
	unset input
	clear
	echo "Paste in file paths:"
	vared -c input
	clear
	while read -r name; do
		# Skip comments
		[ "$(echo $name | cut -c1)" = "#" ] &&
		continue ||
		[ -f $name ] &&
		echo "$name found" ||
		echo "------ $name not found"
	done <<< $input
}

clo-manual-clone () {
	vared -p "CLO GitLab path: " -c clopath
	vared -p "Branch: " -c clobranch
	vared -p "Clone into: " -c clodirname
	git clone https://git.codelinaro.org/clo/la/$clopath.git --single-branch --branch $clobranch $clodirname
	unset clopath clobranch clodirname
}

duplines () {
	sort $1 | uniq --count --repeated
}

extract-win-fonts () {
	7z e $1 sources/install.wim -ofonts &&
	7z e fonts/install.wim 1/Windows/{Fonts/'*'.{ttf,ttc},System32/Licenses/neutral/'*'/'*'/license.rtf} -ofonts
}

gh-cherry-pick () {
	curl https://github.com/$1/commit/$2.patch | git am
}

heimdall-wait-for-device () {
	echo "< waiting for any device >"
	while ! /usr/bin/heimdall detect > /dev/null 2>&1; do
		sleep 1
	done
}

libneeds () {
	readelf -d $1 |grep '\(NEEDED\)' | sed -r 's/.*\[(.*)\]/\1/'
}

mnt-disks () {
	kwallet-query -r c08f87b6-f6a6-4089-9bca-46df3349435e kdewallet -f SolidLuks | sudo cryptsetup open /dev/sda 1TB_HDD -
	sudo mount /dev/mapper/1TB_HDD /mnt/1TB_HDD
	kwallet-query -r 152aed26-7e3c-49dc-ad96-b613da8040c2 kdewallet -f SolidLuks | sudo cryptsetup open /dev/sdb 1TB_HDD_2 -
	sudo mount /dev/mapper/1TB_HDD_2 /mnt/1TB_HDD_2
}

pmaports-build () {
	pmbootstrap checksum $1 &&
	pmbootstrap build $1 --force $2
}

precmd () {
	gitinfo=$(git branch --show-current 2> /dev/null)
	[[ -z $gitinfo ]] && return
	[[ -z $(git status --porcelain 2> /dev/null) ]] && gitinfo="%F{green} ($gitinfo)%f" ||
	gitinfo="%F{yellow} ($gitinfo %B●%b)%f"
}

scp-pull () {
	scp $1:$2 .
}

search () {
	[ -z "$2" ] &&
	find . -iname "*$1*" | cut -c3- ||
	find $2 -iname "*$1*"
}

sourcebuildenvsetup () {
	cd ~/projects/lineage-22.1
	source ~/projects/lineage-22.1/build/envsetup.sh
}

stfu () {
	$@>/dev/null 2>&1 &!
}

sync-music () {
	cd "$HOME/Music/Rhythm Game Music" &&
	yt-dlp -x --download-archive downloaded.txt https://youtube.com/playlist\?list\=PLpQJp2SybtJnKlIg3KdrgXc2HJcguh81M
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

upload-zshrc () {
	[[ -d "miscellaneous" ]] && echo "ERROR: Directory miscellaneous exists already" && return ||
	git clone git@github.com:ungeskriptet/miscellaneous &&
	cd miscellaneous &&
	rm .zshrc &&
	cp $XDG_CONFIG_HOME/zsh/.zshrc . &&
	perl -pi.bak -e 's/(?<=-F key=)(?!.*(\.zshrc)).*(?=.*(\ \\))/abc/g' .zshrc &&
	sed -i '0,/export NTFY_TOKEN="tk_.*"/ s/export NTFY_TOKEN="tk_.*"/export NTFY_TOKEN=""/' .zshrc &&
	git diff &&
	git add .zshrc &&
	git commit &&
	git push origin main
}

upload-file () {
	curl \
	-F key=abc \
	-F file=@$1 \
	https://catgirlsare.sexy/api/upload
}

webm2gif() {
    ffmpeg -y -i "$1" -vf palettegen _tmp_palette.png
    ffmpeg -y -i "$1" -i _tmp_palette.png -filter_complex paletteuse -r 10  "${1%.webm}.gif"
    rm _tmp_palette.png
}

PROMPT="╭─%F{magenta}%n@%M%f %F{blue}%~%f\$gitinfo
╰─ "

[[ -e /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ||
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -e /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ||
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
