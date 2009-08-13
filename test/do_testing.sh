#!/bin/dash
testdir=$(dirname $0)
libdir=${testdir}/..

root_filesystems="gfs ocfs2 ext3"
cluster_types="gfs"
distributions="rhel5 sles10"

testing_errors=0
PYTHONPATH=$PYTHONPATH:../../../comoonics-clustersuite/python/lib
export testing_errors PYTHONPATH

if [ -z "$1" ]; then
  tests=$(find $testdir -type f -name "test*.sh" -not -path '*/lib/*')
else
  tests=$*
fi

if [ -z "$tests" ]; then
	echo "No tests found."
	exit 0
fi

. $testdir/lib/test-lib.sh

for testscript in $tests; do
	testname=$(basename $testscript)
    testname=${testname#test-}
    testname=${testname%.sh}
#    testname=${testname//-/_}
    preparetest
	. $testscript
	if [ $? -ne 0 ]; then
		echo "Error during execution of test \"$testscript\". Terminating!"
		exit 1
	else
	    echo "$testscript DONE"
    fi
    for distribution in $distributions; do
    	for clutype in $cluster_types; do
    		for rootfs in $root_filesystems; do
    		    #echo "Testing distribution dependent files $clutype $rootfs $distribution"
    			for testscript in $(find $testdir/$distribution -type f -name "test*.sh" -not -path '*/lib/*' 2>/dev/null); do
	    			preparetest $clutype $rootfs $distribution
	    			. "$testscript"
					if [ $? -ne 0 ]; then
						echo "Error during execution of test \"$testscript\". Terminating!"
						exit 1
					else
	    				echo "$testscript DONE"
	    				eval ${testname}_done=1
    				fi
    			done
    			#echo "Testing cluster dependent files $clutype $rootfs $distribution"
    			for testscript in $(find $testdir/$clutype -type f -name "test*.sh" -not -path '*/lib/*' 2>/dev/null); do
	    			preparetest $clutype $rootfs $distribution
	    			. "$testscript"
					if [ $? -ne 0 ]; then
						echo "Error during execution of test \"$testscript\". Terminating!"
						exit 1
					else
	    				echo "$testscript DONE"
	    				eval ${testname}_done=1
    				fi
    			done
    			#echo "Testing rootfs dependent files $clutype $rootfs $distribution"
    			for testscript in $(find $testdir/$rootfs -type f -name "test*.sh" -not -path '*/lib/*' 2>/dev/null); do
	    			preparetest $clutype $rootfs $distribution
	    			. "$testscript"
					if [ $? -ne 0 ]; then
						echo "Error during execution of test \"$testscript\". Terminating!"
						exit 1
					else
	    				echo "$testscript DONE"
	    				eval ${testname}_done=1
    				fi
    			done
    			lastroofs=$rootfs
    		done
    		lastclutype=$clutype
    	done
    	lastdistribution=$distribution
    done
done
errormsg
exit $?