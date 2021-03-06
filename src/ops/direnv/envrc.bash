watch_file "$EVALUATION_ROOT"

function declare() {
    if [ "$1" == "-x" ]; then shift; fi

    function punt () {
        :
    }

    function prepend() {
        varname=$1 # example: varname might contain the string "PATH"

        # drop off the varname, so the remaining arguments are the
        # arguments to export
        shift

        # set $original to the contents of the the variable $varname
        # refers to
        eval original=\$$varname

        # effectfully accept the new variable's contents
        export "$@";

        # re-set $varname's variable to the contents of varname's
        # reference, plus the current (updated on the export) contents.
        eval $varname=\$$varname:$original
    }

    # Some variables require special handling.
    #
    # - punt:    don't set the variable at all
    # - prepend: take the new value, and put it before the current value.
    case "$1" in
        # vars from: https://github.com/NixOS/nix/blob/92d08c02c84be34ec0df56ed718526c382845d1a/src/nix-build/nix-build.cc#L100
        "HOME="*) punt;;
        "USER="*) punt;;
        "LOGNAME="*) punt;;
        "DISPLAY="*) punt;;
        "PATH="*) prepend "PATH" "$@";;
        "TERM="*) punt;;
        "IN_NIX_SHELL="*) punt;;
        "TZ="*) punt;;
        "PAGER="*) punt;;
        "NIX_BUILD_SHELL="*) punt;;
        "SHLVL="*) punt;;

        # vars from: https://github.com/NixOS/nix/blob/92d08c02c84be34ec0df56ed718526c382845d1a/src/nix-build/nix-build.cc#L385
        "TEMPDIR="*) punt;;
        "TMPDIR="*) punt;;
        "TEMP="*) punt;;
        "TMP="*) punt;;

        # vars from: https://github.com/NixOS/nix/blob/92d08c02c84be34ec0df56ed718526c382845d1a/src/nix-build/nix-build.cc#L421
        "NIX_ENFORCE_PURITY="*) punt;;

        *)
            export "$@"
            ;;
    esac
}

export IN_NIX_SHELL=1
. "$EVALUATION_ROOT"

unset declare
