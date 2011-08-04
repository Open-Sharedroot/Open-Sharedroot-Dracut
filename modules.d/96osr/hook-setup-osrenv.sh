#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh
#
# Just sets up the environment for the open sharedroot.
#
# Some parameters might be setup inside this initrd not by the bootloader. This would lead to the usage
# of a shared boot with also shared boot parameters.
# This feature is important e.g. for sharedroot clusters using a common bootloader configuration.

$moddir/setup-osrrenv.awk