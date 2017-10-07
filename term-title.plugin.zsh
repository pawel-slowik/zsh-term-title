: ${TERM_TITLE_SET_MULTIPLEXER:=1}

function term_set_title() {
	emulate -L zsh
	local term_is_known=0 term_is_multi=0
	if [[ \
		$TERM == rxvt-unicode*
		|| $TERM == xterm*
		|| ! -z $TMUX
	]] then
		term_is_known=1
	fi
	if [[ ! -z $TMUX ]] then
		term_is_multi=1
	fi
	if [[ $term_is_known -ne 1 ]] then
		return
	fi
	printf '\033]0;%s\007' ${1//[^[:print:]]/}
	if [[ \
		$TERM_TITLE_SET_MULTIPLEXER -eq 1
		&& $term_is_multi -eq 1
	]] then
		printf '\033k%s\033\\' ${1//[^[:print:]]/}
	fi
}

function term_title_get_command() {
	emulate -L zsh
	local job_text job_key
	typeset -g RETURN_COMMAND
	RETURN_COMMAND=$1
	# Since ~4.3.5, patch:
	# "users/11818: allow non-numeric keys for job status parameters"
	# it is possible to use the `fg ...` or `%...` description as a key
	# in $jobtexts.
	case $1 in
		%*) job_key=$1 ;;
		fg) job_key=%+ ;;
		fg*) job_key=${(Q)${(z)1}[2,-1]} ;;
		*) job_key='' ;;
	esac
	if [[ -z $job_key ]] then
		# not a "job to foreground" command - use it as is
		return
	fi
	job_text=${jobtexts[$job_key]} 2> /dev/null
	if [[ -z $job_text ]] then
		# job lookup failed - use the original command
		return
	fi
	RETURN_COMMAND=$job_text
}

function term_title_precmd() {
	emulate -L zsh
	local cmd='zsh'
	local dir='%~'
	term_set_title $cmd:${(%)dir}
}

function term_title_preexec() {
	emulate -L zsh
	term_title_get_command $1
	local cmd=$RETURN_COMMAND
	local dir='%~'
	term_set_title $cmd:${(%)dir}
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd term_title_precmd
add-zsh-hook preexec term_title_preexec
