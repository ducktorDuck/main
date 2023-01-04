# Protect against non-zsh execution of Oh My Zsh (use POSIX syntax here)
[ -n "$ZSH_VERSION" ] || {
  # ANSI formatting function (\033[<code>m)
  # 0: reset, 1: bold, 4: underline, 22: no bold, 24: no underline, 31: red, 33: yellow
  omz_f() {
    [ $# -gt 0 ] || return
    IFS=";" printf "\033[%sm" $*
  }
  # If stdout is not a terminal ignore all formatting
#  [ -t 1 ] || omz_f() { :; }

  omz_ptree() {
    # Get process tree of the current process
    pid=$$; pids="$pid"
    while [ ${pid-0} -ne 1 ] && ppid=$(ps -e -o pid,ppid | awk "\$1 == $pid { print \$2 }"); do
      pids="$pids $pid"; pid=$ppid
    done

    # Show process tree
    case "$(uname)" in
    Linux) ps -o ppid,pid,command -f -p $pids 2>/dev/null ;;
    Darwin|*) ps -o ppid,pid,command -p $pids 2>/dev/null ;;
    esac

    # If ps command failed, try Busybox ps
    [ $? -eq 0 ] || ps -o ppid,pid,comm | awk "NR == 1 || index(\"$pids\", \$2) != 0"
  }

  {
    shell=$(ps -o pid,comm | awk "\$1 == $$ { print \$2 }")
    printf "$(omz_f 1 31)Error:$(omz_f 22) Oh My Zsh can't be loaded from: $(omz_f 1)${shell}$(omz_f 22). "
    printf "You need to run $(omz_f 1)zsh$(omz_f 22) instead.$(omz_f 0)\n"
    printf "$(omz_f 33)Here's the process tree:$(omz_f 22)\n\n"
    omz_ptree
    printf "$(omz_f 0)\n"
  } >&2

  return 1
}

# If ZSH is not defined, use the current script's directory.
[[ -z "$ZSH" ]] && export ZSH="${${(%):-%x}:a:h}"

# Set ZSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache/
if [[ -z "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="/.cache/zsh_cache"
  sudo chown -R me:me /.cache
  sudo chmod -R a+w /.cache
fi

# Make sure $ZSH_CACHE_DIR is writable, otherwise use a directory in $HOME
if [[ ! -w "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="/.cache/zsh_cache"
  sudo chown -R me:me /.cache
  sudo chmod -R a+w /.cache
fi

# Create cache and completions dir and add to $fpath
mkdir -p "$ZSH_CACHE_DIR/completions"
(( ${fpath[(Ie)"$ZSH_CACHE_DIR/completions"]} )) || fpath=("$ZSH_CACHE_DIR/completions" $fpath)

sudo chmod a+w $ZSH_CACHE_DIR/completions
DISABLE_AUTO_UPDATE="true"

# Check for updates on initial load...
if [[ "$DISABLE_AUTO_UPDATE" != true ]]; then
  source "$ZSH/tools/check_for_upgrade.sh"
fi

# Initializes Oh My Zsh

# add a function path
export func="/main/functions"
export f="/functional/functions"
fpath=("$ZSH/functions" "$ZSH/completions" "$func" $fpath)

# Load all stock functions (from $fpath files) called below.
autoload -U compaudit compinit zrecompile

# Set ZSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom/
if [[ -z "$ZSH_CUSTOM" ]]; then
    ZSH_CUSTOM="$ZSH/custom"
fi

is_plugin() {
  local base_dir=$1
  local name=$2
  builtin test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || builtin test -f $base_dir/plugins/$name/_$name
}

# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if is_plugin "$ZSH_CUSTOM" "$plugin"; then
    fpath=("$ZSH_CUSTOM/plugins/$plugin" $fpath)
  elif is_plugin "$ZSH" "$plugin"; then
    fpath=("$ZSH/plugins/$plugin" $fpath)
  else
    echo "[oh-my-zsh] plugin '$plugin' not found"
  fi
done

# Figure out the SHORT hostname
if [[ "$OSTYPE" = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST="${HOST/.*/}"
else
  SHORT_HOST="${HOST/.*/}"
fi

# Save the location of the current completion dump file.
if [[ -z "$ZSH_COMPDUMP" ]]; then
  ZSH_COMPDUMP="/.cache/zsh_compdump.d/.this-shitty-ass-fucnkin-dumpfile-bro.done-with-this"
fi

# Construct zcompdump OMZ metadata
zcompdump_revision="#omz revision: $(builtin cd -q "$ZSH"; git rev-parse HEAD 2>/dev/null)"
zcompdump_fpath="#omz fpath: $fpath"

# Delete the zcompdump file if OMZ zcompdump metadata changed
if ! command grep -q -Fx "$zcompdump_revision" "$ZSH_COMPDUMP" 2>/dev/null \
   || ! command grep -q -Fx "$zcompdump_fpath" "$ZSH_COMPDUMP" 2>/dev/null; then
  command rm -f "$ZSH_COMPDUMP"
  zcompdump_refresh=1
fi

export ZSH_DISABLE_COMPFIX="true"

if [[ "$ZSH_DISABLE_COMPFIX" != true ]]; then
  source "$ZSH/lib/compfix.zsh"
  # Load only from secure directories
  compinit -i -d "$ZSH_COMPDUMP"
fi

# Append zcompdump metadata if missing
if (( $zcompdump_refresh )) \
  || ! command grep -q -Fx "$zcompdump_revision" "$ZSH_COMPDUMP" 2>/dev/null; then
  # Use `tee` in case the $ZSH_COMPDUMP filename is invalid, to silence the error
  # See https://github.com/ohmyzsh/ohmyzsh/commit/dd1a7269#commitcomment-39003489
  tee -a "$ZSH_COMPDUMP" &>/dev/null <<EOF

$zcompdump_revision
$zcompdump_fpath
EOF
fi
unset zcompdump_revision zcompdump_fpath zcompdump_refresh

# zcompile the completion dump file if the .zwc is older or missing.
zrecompile -q -p "$ZSH_COMPDUMP" && command rm -f "$ZSH_COMPDUMP.zwc.old"


# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
  if [[ -f "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" ]]; then
    source "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh"
  elif [[ -f "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ]]; then
    source "$ZSH/plugins/$plugin/$plugin.plugin.zsh"
  fi
done
unset plugin

# Load all of your custom configurations from custom/
for config_file ("$ZSH_CUSTOM"/*.zsh(N)); do
  source "$config_file"
done
unset config_file

# Load the theme
is_theme() {
  local base_dir="$HOME/"
  local sub_dir="bin/"
  local name="theme"
  builtin test -f $base_dir/$sub_dir/$name
}

theme="$HOME/bin/theme"

if [ -f "$theme" ]; then
    source $HOME/bin/theme
else
    echo "[oh-my-zsh] theme '$ZSH_THEME' not found"
fi

# Load syntaxers
if [ -d "/usr/share/zsh/plugins/zsh-syntax-highlighting" ]; then
  export syntax="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  source $syntax
fi
if [ -d "/usr/share/zsh/plugins/zsh-autosuggestions" ]; then
  export suggest="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  #source $suggest
fi
if [ -d "/usr/share/zsh/plugins/zsh-history-substring-search" ]; then
  export substring="/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
  source $substring
fi
