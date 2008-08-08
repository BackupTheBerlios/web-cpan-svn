# invoke-rc.d(8) completion
#
# Copyright (C) 2004 Servilio Afre Puentes <servilio@gmail.com>
#
have invoke-rc.d &&
_invoke_rc_d()
{
    local cur prev sysvdir services options valid_options

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    [ -d /etc/rc.d/init.d ] && sysvdir=/etc/rc.d/init.d \
	|| sysvdir=/etc/init.d

    services=( $(echo $sysvdir/!(README*|*.sh|*.dpkg*|*.rpm*)) )
    services=( ${services[@]#$sysvdir/} )
    options=( --help --quiet --force --try-anyway --disclose-deny --query --no-fallback )

    if [[ ($COMP_CWORD -eq 1) || ("$prev" == --* ) ]]; then
	valid_options=( $( \
	    echo ${COMP_WORDS[@]} ${options[@]} \
	    | tr " " "\n" \
	    | sed -ne "/$( echo ${options[@]} | sed "s/ /\\\\|/g" )/p" \
	    | sort | uniq -u \
	    ) )
	COMPREPLY=( $( compgen -W '${valid_options[@]} ${services[@]}' -- \
	    $cur ) )
    elif [ -x $sysvdir/$prev ]; then
	COMPREPLY=( $( compgen -W '`sed -ne "y/|/ /; \
					    s/^.*Usage:[ ]*[^ ]*[ ]*{*\([^}\"]*\).*$/\1/p" \
					    $sysvdir/$prev`' -- \
	    $cur ) )
    else
	COMPREPLY=()
    fi

    return 0
} &&
complete -F _invoke_rc_d invoke-rc.d
