autoload -U colors && colors
autoload -U add-zsh-hook
setopt prompt_subst

local sep="%F{242}•%f"

function _prompt_git() {
    local ref
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
        ref=$(command git rev-pase --short HEAD 2> /dev/null) || return 0

    echo "%F{246}$(_prompt_git_remote)${ref#refs/heads/}%f $sep $(_prompt_git_status)"
}

function _prompt_git_status() {
    if [[ -n $(command git status --porcelain 2> /dev/null | tail -n1) ]]; then
        echo "%F{124}⬡ %f"
    else
        echo "%F{70}⬢ %f"
    fi
}

function _prompt_git_remote() {
    local_commit="$(git rev-parse "@" 2> /dev/null)"
    remote_commit="$(git rev-parse "@{u}" 2> /dev/null)"

    if [[ $local_commit == "@" || $local_commit == $remote_commit ]]; then
        echo -n ""
        return
    fi

    common_base="$(git merge-base "@" "@{u}" 2> /dev/null)"
    if [[ $common_base == $remote_commit ]]; then
        echo -n "⇡ "
    elif [[ $common_base == $local_commit ]]; then
        echo -n "⇣ "
    else
        echo -n "⇡⇣ "
    fi
}

function _prompt_virtualenv() {
    if [[ "${VIRTUAL_ENV}x" == "x" ]]; then
        echo -n ""
        return
    fi

    local actual_base base
    actual_base=$(basename "$VIRTUAL_ENV")
    if [[ $actual_base == "env" ]]; then
        base=$(basename $(dirname "$VIRTUAL_ENV"))
    else
        base=$actual_base
    fi

    echo -n "%F{108}${base}"
}

function _prompt_status() {
    local git_prompt venv_prompt
    git_prompt=$(_prompt_git)
    venv_prompt=$(_prompt_virtualenv)

    if [[ $venv_prompt != "" ]]; then
        echo -n "${venv_prompt}"
        if [[ $git_prompt != "" ]]; then
            echo -n " $sep "
        fi
    fi

    if [[ $git_prompt != "" ]]; then
        echo -n "${git_prompt}"
    fi
}

function _prompt() {
    echo -n "\n $prompt_prefix %{$fg[blue]%}$me%{$fg[cyan]%}@$short_host%{$reset_color%}"
    local status_prompt
    status_prompt="$(_prompt_status)"
    if [[ "$status_prompt" != "" ]]; then
        echo -n " $sep $status_prompt"
    fi
    echo -n "\n"

    echo -n "   %{$bright_yellow%}%~ %{$fg[red]%}%(!.#.»)%{$reset_color%} "
}

function _prompt_render() {
    if [ $? -eq 0 ]; then
        prompt_prefix="%F{green}▲%{$reset_color%}"
    else
        prompt_prefix="%F{red}△%{$reset_color%}"
    fi

    local bright_yellow=$'\e[93m'
    local short_host=`echo $HOST | cut -d. -f1`
    local me=`whoami`

    PROMPT="$(_prompt)"
}

add-zsh-hook precmd _prompt_render
PROMPT2=" ◇ "
