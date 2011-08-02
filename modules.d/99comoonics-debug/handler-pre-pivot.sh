#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

echo "====================[communics-debugging]================================="
echo " handler pre-pivot ............................\n"
echo "=========================================================================="
echo "====================[communics-debugging]================================="
echo oldroot: "$oldroot"
echo "=========================================================================="
echo "====================[communics-debugging]================================="
echo "value of /tmp/root.info...\n"
cat /tmp/root.info
echo "=========================================================================="
echo "====================[communics-debugging]================================="
echo "Ping-Test with arping:"
/sbin/arping -c 1 192.168.1.99
echo "=========================================================================="