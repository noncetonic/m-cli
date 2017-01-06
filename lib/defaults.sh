_mcli_read() {
    local domain="$1"
    local key="$2"
    local sudo="$3"

    [ -n "${domain}" ] && [ -n "${key}" ] || return 1
    [[ -n "${sudo}" ]] && sudo="sudo"

    ${sudo} defaults read "${domain}" "${key}" 2> /dev/null
}

_mcli_write_integer() {
    local domain="$1"
    local key="$2"
    local value="$3"
    local sudo="$4"

    [ -n "${domain}" ] && [ -n "${key}" ] && [ -n "${value}" ] || return 1
    [[ -n "${sudo}" ]] && sudo="sudo"

    ${sudo} defaults write "${domain}" "${key}" -int "${value}"
}

_mcli_read_boolean_as_yes_no() {
    local value="$(_mcli_read $@)"

    case "${value}" in
        0|[nN][oO]|[fF][aA][lL][sS][eE])
            echo "NO"
            ;;
        1|[yY][eE][sS]|[tT][rU][eE])
            echo "YES"
            ;;
    esac
}

_mcli_read_number() {
    local value="$(_mcli_read $@)"

    echo "${value}"
}

_mcli_read_inverted_boolean() {
    local value="$(_mcli_read_boolean $@)"

    if [[ "${value}" == "YES" ]]; then
        echo "NO"
    else
        echo "YES"
    fi
}

_mcli_defaults_yes_no_to_integer() {
    _mcli_defaults_yes_no_to_type "integer" "yes_no_to_boolean" $@
}

_mcli_defaults_yes_no_to_boolean() {
    _mcli_defaults_yes_no_to_type "boolean" "yes_no_to_boolean" $@
}

_mcli_defaults_yes_no_to_inverted_boolean() {
    _mcli_defaults_yes_no_to_type "boolean" "yes_no_to_inverted_boolean" $@
}

_mcli_defaults_number() {
    local domain="$1"
    local key="$2"
    local new_value="$3"
    local sudo="$4"
    local transformed="$(_mcli_number_to_number "${new_value}")"

    case "${transformed}" in
        [0-9][.][0-9])
            ${sudo} defaults write "${domain}" "${key}" -float "${transformed}"
            ;;
        [0-9]*)
            ${sudo} defaults write "${domain}" "${key}" -int "${transformed}"
            ;;
    esac

    _mcli_read_integer "${domain}" "${key}"
}

_mcli_defaults_yes_no_to_type() {
    local type="$1"
    local transformer="$2"
    local domain="$3"
    local key="$4"
    local new_value="$5"
    local sudo="$6"
    local transformed="$(_mcli_${transformer} "${new_value}")"

    if [ -n "${new_value}" ] && [[ "${transformed}" != "ERROR" ]]; then
      ${sudo} defaults write "${domain}" "${key}" -${type} "${transformed}"
    fi

    _mcli_read_boolean "${domain}" "${key}"
}
