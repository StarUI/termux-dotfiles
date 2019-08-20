#!/data/data/com.termux/files/usr/bin/bash
##
##  A wrapper for the 'su' utility from Lineage OS.
##  Dependencies: bash, coreutils, gawk.
##

set -e

PREFIX="/data/data/com.termux/files/usr"

declare -a SU_ARGS SU_ENV

SU_EXEC_COMMAND=""
SU_SHELL="/data/data/com.termux/files/usr/bin/bash"
SU_SHELL_FALLBACK="/system/bin/sh"
SU_USE_LOGIN_SHELL=false
SU_USER="root"
SU_PATH="/system/xbin/su"

show_usage() {
	{
		echo
		echo "Usage: su [options] [-] [<user> [--] [<argument>...]]"
		echo
		echo "Change the effective user ID to that of <user>."
		echo "A mere - implies -l.  If <user> is not given, root is assumed."
		echo
		echo "Options:"
		echo
		echo "  -h, --help                 Show this help information."
		echo
		echo "  -c, --command <command>    Pass a single command to the shell"
		echo "                             with argument '-c'."
		echo
		echo "  -, -l, --login             Start login shell."
		echo
		echo "  -s, --shell <shell>        Run a <shell> instead of a default."
		echo
		echo "Default shell for 'root' and '$(whoami)' is '\$PREFIX/bin/bash'."
		echo "Other users will use '/system/bin/sh' as default shell."
		echo
	} >&2
}

if [ ! -e "$SU_PATH" ] || [ ! -x "$SU_PATH" ]; then
	echo "Utility '$SU_PATH' is not found on your OS." >&2
	exit 1
fi

if [[ $("$SU_PATH" -v | awk '{ print $2 }') != cm-su ]]; then
	echo "Your 'su' binary isn't from Lineage OS addonsu." >&2
	exit 1
fi

while (($# > 0)); do
	case "$1" in
		-h|--help)
			show_usage
			exit 0
			;;
		-c|--command)
			if [ $# -gt 1 ] && [[ $2 != -* ]]; then
				if [ -n "$2" ]; then
					SU_EXEC_COMMAND="$2"
					shift 1
				else
					echo "Execution command cannot be empty." >&2
					show_usage
					exit 1
				fi
			else
				echo "Option '--command' requires an argument." >&2
				show_usage
				exit 1
			fi
			;;
		-|-l|--login)
			SU_USE_LOGIN_SHELL=true
			;;
		-s|--shell)
			if [ $# -gt 1 ] && [[ $2 != -* ]]; then
				if [ -n "$2" ]; then
					if [ -f "$2" ] && [ -x "$2" ]; then
						SU_SHELL="$2"
						shift 1
					else
						echo "Cannot use '$2' as shell." >&2
						show_usage
						exit 1
					fi
				else
					echo "Shell cannot be empty." >&2
					show_usage
					exit 1
				fi
			else
				echo "Option '--shell' requires an argument." >&2
				show_usage
				exit 1
			fi
			;;
		--)
			shift 1
			if [ $# -ge 1 ]; then
				SU_ARGS+=("${@}")
			fi
			break
			;;
		*)
			if [[ $1 != -* ]]; then
				SU_ARGS+=("$1")
			else
				echo "Unknown option '$1'." >&2
				show_usage
				exit 1
			fi
			;;
	esac
	shift 1
done

if [ ${#SU_ARGS[@]} -ge 1 ]; then
	SU_USER=${SU_ARGS[0]}
	SU_ARGS=("${SU_ARGS[@]:1}")

	if ! id -u "$SU_USER" > /dev/null 2>&1; then
		echo "Invalid user '$SU_USER'." >&2
		exit 1
	fi
fi

if [ "$(id -u "$SU_USER")" != "0" ] && [ "$(id -u "$SU_USER")" != "$(id -u)" ]; then
	# If user id is not current or 0 (root), user can't use Termux shells.
	SU_SHELL=$SU_SHELL_FALLBACK
fi

# Do not preload libraries under su.
unset LD_PRELOAD

# Append system utilities in case if target user won't be able to
# use Termux environment due to permission issues.
export PATH="$PATH:/system/bin:/system/xbin"

# Discard su's shell history.
# Note that shell's rc files may override this.
SU_ENV+=("HISTFILE=/dev/null")

# For login shell a clean environment will be used.
if $SU_USE_LOGIN_SHELL; then
	SU_ENV+=("ANDROID_DATA=/data")
	SU_ENV+=("ANDROID_ROOT=/system")
	SU_ENV+=("EXTERNAL_STORAGE=${EXTERNAL_STORAGE}")
	SU_ENV+=("LANG=${LANG}")
	SU_ENV+=("TERM=${TERM}")

	if [ "$(id -u "$SU_USER")" != "0" ] && [ "$(id -u "$SU_USER")" != "$(id -u)" ]; then
		# If user id is not current or 0 (root), user can't access the Termux
		# environment.
		SU_ENV+=("HOME=/")
		SU_ENV+=("PATH=/system/bin:/system/xbin")
	else
		SU_ENV+=("HOME=/data/data/com.termux/files/home")
		SU_ENV+=("PATH=${PREFIX}/bin:${PREFIX}/bin/applets:/system/bin:/system/xbin")
		SU_ENV+=("PREFIX=${PREFIX}")
		SU_ENV+=("TMPDIR=${PREFIX}/tmp")
	fi
else
	while read -r envvar; do
		SU_ENV+=("$envvar")
	done < <(printenv)
fi

if [ -n "$SU_EXEC_COMMAND" ]; then
	if $SU_USE_LOGIN_SHELL; then
		set -- "cd \"\$HOME\"; unset OLDPWD; $SU_EXEC_COMMAND"
	else
		set -- "cd \"$PWD\"; OLDPWD=\"$OLDPWD\"; $SU_EXEC_COMMAND"
	fi
else
	if [ ${#SU_ARGS[@]} -ge 1 ]; then
		for ((i=0; i<${#SU_ARGS[@]}; i++)); do
			SU_ARGS[$i]="\"${SU_ARGS[$i]}\""
		done

		if $SU_USE_LOGIN_SHELL; then
			set -- "cd \"\$HOME\"; unset OLDPWD; ${SU_ARGS[*]}"
		else
			set -- "cd \"$PWD\"; OLDPWD=\"$OLDPWD\"; ${SU_ARGS[*]}"
		fi
	else
		if $SU_USE_LOGIN_SHELL; then
			set -- "cd \"\$HOME\"; unset OLDPWD; $SU_SHELL -l"
		else
			set -- "cd \"$PWD\"; OLDPWD=\"$OLDPWD\"; $SU_SHELL"
		fi
	fi
fi

RET=0

echo -ne "\\a" >&2

if $SU_USE_LOGIN_SHELL; then
	"$SU_PATH" -p -- "$SU_USER" -- \
		/system/bin/env -i "${SU_ENV[@]}" "$SU_SHELL" -l -c "${*}"
	RET=$?
else
	"$SU_PATH" -p -- "$SU_USER" -- \
		/system/bin/env -i "${SU_ENV[@]}" "$SU_SHELL" -c "${*}"
	RET=$?
fi

stty sane

exit $RET
