#!/usr/bin/igawk -f

@include /lib/osr/lib-std.awk
@include /lib/osr/lib-repository.awk

BEGIN{
    main_function()
}

function main_function( _libdir,_predir,_shellrcfile)
{
    _libdir = std_getLibDir()
    _predir = ""

    std_paramStore( "logofile",         "/etc/atix-logo.txt")
    std_paramStore( "shellrcfile",      _libdir "/shinitrc")
    std_paramStore( "shellissue",       _predir "/etc/issue")
    std_paramStore( "shellissuetmp",    _predir "/tmp/issue")
    _shellrcfile = repository_getValue("shellrcfile")
    if( _shellrcfile == "EXCEPTION@file no found")
    {
        _shellrcfile = ""
    }
    std_paramStore( "shell",            "/bin/bash --rcfile" _shellrcfile)
    std_paramStore( "sysctlfile",       _predir "/etc/sysctl.conf")
    std_paramStore( "xtabfile",         "/etc/xtab")
    std_paramStore( "xrootfsfile",      "/etc/xrootfs")
    std_paramStore( "xkillallprocsfile", "/etc/xkillallprocs")
}

# # Sources the libraries needed. Sets up clutype and distribution in repository.
# sourceLibs ${libdir}
# 
# # don't fail fi root is not ok.
# [ -z "$rootok" ] && rootok=1
# # [ -z "$root" ] && root=autodetect
# [ -z "$root" ] && root=/dev/root
# # Just to delay the decision can be set later on also
# [ -z "$netroot" ] && netroot="osr"
# 
# osr_param_store logofile "/etc/atix-logo.txt"
# osr_param_store shellrcfile ${libdir}/shinitrc
# osr_param_store shellissue ${predir}/etc/issue
# osr_param_store shellissuetmp ${predir}/tmp/issue
# osr_param_store shell "/bin/bash --rcfile $(repository_get_value shellrcfile)"
# osr_param_store sysctlfile "${predir}/etc/sysctl.conf"
# osr_param_store xtabfile /etc/xtab
# osr_param_store xrootfsfile /etc/xrootfs
# osr_param_store xkillallprocsfile /etc/xkillallprocs