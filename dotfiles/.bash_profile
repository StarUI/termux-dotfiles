: "${HOME:=/data/data/com.termux/files/home}"
: "${PREFIX:=/data/data/com.termux/files/usr}"
: "${TMPDIR:=/data/data/com.termux/files/usr/tmp}"
export HOME PREFIX TMPDIR

export LOCAL_PREFIX="$HOME/.local"
export PATH="$LOCAL_PREFIX/bin:$HOME/bin:$PREFIX/bin:$PREFIX/bin/applets"
export EDITOR="$PREFIX/bin/micro"

if grep -q "https://termux.net" "$PREFIX/etc/apt/sources.list" || [ -e "$PREFIX/bin/termux-upgrade-repo" ]; then
	export LD_LIBRARY_PATH="$LOCAL_PREFIX/lib:$PREFIX/lib"
fi

## Proot link2symlink directory.
if [ "$(id -u)" != "0" ]; then
	export PROOT_L2S_DIR="$LOCAL_PREFIX/var/lib/proot-l2s"
	[ ! -e "$PROOT_L2S_DIR" ] && mkdir -p "$PROOT_L2S_DIR" > /dev/null 2>&1
fi

## Load bashrc if shell is interactive.
if [[ "$-" == *"i"* ]]; then
	if [ -r "${HOME}/.bashrc" ]; then
		. "${HOME}"/.bashrc
	fi
fi
