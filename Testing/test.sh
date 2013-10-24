#!/bin/bash

echoerr() { echo "$@" 1>&2; }

BASEDIR=$(dirname $0)
pushd $BASEDIR > /dev/null

TMP="tmp"
HASH=`../bin/tlsh_version | head -1 | cut -f1`
CHKSUM=`../bin/tlsh_version | tail -1 | cut -f1`

if test ! -f ../bin/tlsh_unittest
then
	echoerr "error: (127), you must compile tlsh_unittest"
        popd > /dev/null
	exit 127
fi

if test ! -d tmp
then
    mkdir tmp
fi

#
# this function will be run twice, "" and "-xlen"
#
runit() {

if test "$1" = "-xlen"
then
    XLEN="xlen"
    echo
    echo "Running, considering len, ..."
else
    XLEN="len"
    echo "Running, not considering len, ..."
fi  

########################################################
# Test 1
#	get the TLSH values for a directory of files
########################################################

echo
echo "test 1"
echo

echo "../bin/tlsh_unittest -r ../Testing/example_data > $TMP/example_data.out"
      ../bin/tlsh_unittest -r ../Testing/example_data > $TMP/example_data.out

diffc=`diff --ignore-all-space $TMP/example_data.out exp/example_data.$HASH.$CHKSUM.$XLEN.out_EXP | wc -l`
if test ! $diffc = 0
then
	echoerr "error: (1), diff $TMP/example_data.out exp/example_data.$HASH.$CHKSUM.$XLEN.out_EXP"
        popd > /dev/null
	exit 1
fi

echo "passed"

########################################################
# Test 2
#	calculate scores of a file (website_course_descriptors06-07.txt) compared to the directory of files
########################################################

echo
echo "test 2"
echo

if test $XLEN = "xlen"
then
echo "../bin/tlsh_unittest -xlen -r ../Testing/example_data -c ../Testing/example_data/website_course_descriptors06-07.txt > $TMP/example_data.scores"
      ../bin/tlsh_unittest -xlen -r ../Testing/example_data -c ../Testing/example_data/website_course_descriptors06-07.txt > $TMP/example_data.scores
else
echo "../bin/tlsh_unittest -r ../Testing/example_data -c ../Testing/example_data/website_course_descriptors06-07.txt > $TMP/example_data.scores"
      ../bin/tlsh_unittest -r ../Testing/example_data -c ../Testing/example_data/website_course_descriptors06-07.txt > $TMP/example_data.scores
fi

diffc=`diff --ignore-all-space $TMP/example_data.scores exp/example_data.$HASH.$CHKSUM.$XLEN.scores_EXP | wc -l`
if test ! $diffc = 0
then
	echoerr "error: (2), diff $TMP/example_data.scores exp/example_data.$HASH.$CHKSUM.$XLEN.scores_EXP"
        popd > /dev/null
	exit 2
fi

echo "passed"

########################################################
# Test 3
#	calculate scores of a file (website_course_descriptors06-07.txt) compared to hashes listed in a file
#	far more efficient
########################################################

echo
echo "test 3"
echo

if test $XLEN = "xlen"
then
echo "../bin/tlsh_unittest -xlen -l $TMP/example_data.out -c ../Testing/example_data/website_course_descriptors06-07.txt > $TMP/example_data.scores.2"
      ../bin/tlsh_unittest -xlen -l $TMP/example_data.out -c ../Testing/example_data/website_course_descriptors06-07.txt > $TMP/example_data.scores.2
else
echo "../bin/tlsh_unittest -l $TMP/example_data.out -c ../Testing/example_data/website_course_descriptors06-07.txt > $TMP/example_data.scores.2"
      ../bin/tlsh_unittest -l $TMP/example_data.out -c ../Testing/example_data/website_course_descriptors06-07.txt > $TMP/example_data.scores.2
fi

diffc=`diff --ignore-all-space $TMP/example_data.scores.2 exp/example_data.$HASH.$CHKSUM.$XLEN.scores.2_EXP | wc -l`
if test ! $diffc = 0
then
	echoerr "error: (3) diff $TMP/example_data.scores.2 exp/example_data.$HASH.$CHKSUM.$XLEN.scores.2_EXP"
        popd > /dev/null
	exit 3
fi

echo "passed"

}

runit 
runit "-xlen"

popd > /dev/null
