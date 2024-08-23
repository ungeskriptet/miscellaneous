#!/usr/bin/zsh

EDITOR=nvim
HISTSIZE=50000
SAVEHIST=10000
HISTFILE=~/.config/zsh/.histfile
LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=00;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32:'
OUT=~/projects/lineage-21.0/out/target/product/e3q
ANDROID_PRODUCT_OUT=$OUT
BUILD_HOSTNAME=david-ryuzu
BUILD_USERNAME=david
export PIP_BREAK_SYSTEM_PACKAGES=1
export ANDROID_HOME=$HOME/.local/share/android-sdk
export LESS='-R --use-color -Dd+r$Du+b$'
export PATH=$PATH:$HOME/.local/bin:$ANDROID_HOME/cmdline-tools/latest/bin

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

zstyle :compinstall filename '/home/david/.zshrc'
zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' menu select

compinit; bashcompinit

alias clear="clear && printf '\033c'"
alias compress-vid="ffmpeg -vcodec libx264 -crf 28 output.mp4 -i"
alias diff='diff --color=auto'
alias dolphin="stfu dolphin ."
alias gen-vbmeta-disabled="avbtool make_vbmeta_image --flags 2 --padding_size 4096 --output vbmeta_disabled.img"
alias grep='grep --color=auto'
alias heimdall="heimdall-wait-for-device && /usr/bin/heimdall"
alias ip='ip -color=auto'
alias ls="ls --color=auto"
alias reboot="read -q '?Reboot? [Y/N]: ' && sudo reboot"
alias reboot-uefi="systemctl reboot --firmware-setup"
alias rp="realpath"
alias udevreload="sudo udevadm control --reload-rules && sudo udevadm trigger"
alias vim="nvim"

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
	cd $HOME/projects/lineage-21.0/device/$1
}

cdkernel () {
	cd $HOME/projects/lineage-21.0/kernel/$1
}

check-files () {
	unset input_files
	tput smcup
	clear
	tput sc
	echo "Paste in file paths: "
	vared -c input_files

	tput rc
	tput rmcup
	while read -r name; do
	if grep -q "$name" $1; then
		echo "$name found"
	else
		echo "------ $name not found"
	fi
	done <<< "$input_files"
}

clo-manual-clone () {
	vared -p "CLO GitLab path: " -c clopath
	vared -p "Branch: " -c clobranch
	vared -p "Clone into: " -c clodirname
	git clone https://git.codelinaro.org/clo/la/$clopath.git --single-branch --branch $clobranch $clodirname
	unset clopath clobranch clodirname
}

dedup () {
	sort $1 | uniq
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
	printf "Password: "
	read -s pwdisks
	echo
	echo $pwdisks | sudo cryptsetup open /dev/sda 1TB_HDD -
	sudo mount /dev/mapper/1TB_HDD /mnt/1TB_HDD
	echo $pwdisks | sudo cryptsetup open /dev/sdb 1TB_HDD_2 -
	sudo mount /dev/mapper/1TB_HDD_2 /mnt/1TB_HDD_2
	unset pwdisks
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
	find . -iname "*$1*"
}

sourcebuildenvsetup () {
	cd ~/projects/lineage-21.0
	source ~/projects/lineage-21.0/build/envsetup.sh
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

upload-zshrc () {
	[[ -d "miscellaneous" ]] && echo "ERROR: Directory miscellaneous exists already" && return ||
	git clone git@github.com:ungeskriptet/miscellaneous &&
	cd miscellaneous &&
	rm .zshrc &&
	cp $HOME/.zshrc . &&
	perl -pi.bak -e 's/(?<=-F key=)(?!.*(\.zshrc)).*(?=.*(\ \\))/abc/g' .zshrc &&
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
