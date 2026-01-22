# --- BASIC SETTINGS ---
# Set history file and size
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY      # Append to history file instead of overwriting
setopt HIST_IGNORE_SPACE   # Dont save is prefixed with space
setopt HIST_IGNORE_DUPS    # No Duplicats
setopt SHARE_HISTORY       # Share history across all active sessions
setopt autocd extendedglob
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export GROFF_NO_SGR=1
export DOTFILES="$HOME/.dotfiles"
export PATH="$HOME/bin:$PATH"
bindkey -v

# The following lines were added by compinstall
zstyle :compinstall filename '/home/mawo/.zshrc'
# --- COMPLETION SYSTEM ---
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select # Use arrow keys to select from completion menu
# --- PURE CUSTOMIZATION ---
# Set the symbol color to red (you can also use a number like 1, or 196 for bright red)
zstyle :prompt:pure:prompt:success color red

# If you want to change the symbol itself to something else:
# PURE_PROMPT_SYMBOL="➜"
# --- PLUGINS ---
# Load the plugins first
# Check system path first, then local path
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f $HOME/.dotfiles/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source $HOME/.dotfiles/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

source <(fzf --zsh)
# Load your custom aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# --- CUSTOMIZATIONS (Must come AFTER plugins) ---
ZSH_HIGHLIGHT_STYLES[path]='fg=red'

# Initialize the prompt
#if (( $+commands[starship] )); then
#    eval "$(starship init zsh)"
#else
#    # Fallback to Pure when Starship isn't installed
    fpath+=$HOME/pure
    autoload -Uz promptinit; promptinit
    prompt pure
#fi
