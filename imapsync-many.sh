#!/bin/sh
#
# $Id: imapsync-many.sh,v 1.0 2015/09/11 ORCA Services AG $

# Example for imapsync massive migration on Unix systems.
# 
# Data is supposed to be in imapsync.csv in the following format
# user1_001;pass1_001;user2_001;pass2_002
# user1_002;pass1_002;user2_002;pass2_003
# ...
# Separator is character semi-colon ";" 
# Each data line contains 4 columns, columns are parameters for --user1 --password1 --user2 --password2
#
# HashTag # indicates this line to be skipped.
#
# Server names are entered via cli
#
# Usage example: imapsync-many.sh <server1> <server2> <mailbox-file> <options-string>

# Define default values
DEFAULT_MAILBOX_FILE="imapsync.csv";
DEFAULT_OPTIONS="";
SYNC_DATE=`date +%Y-%m-%d_%H-%M-%S`;

if [ -z "$1" ] ; then
	echo "No server 1 given. Exiting.";
	exit 0;
fi
SERVER_1=$1;
echo "Server 1 = ${SERVER_1}";

if [ -z "$2" ] ; then
	echo "No server 2 given. Exiting.";
	exit 0;
fi
SERVER_2=$2;
echo "Server 2 = ${SERVER_2}";

# If no mailbox file was given, use default "imapsync.csv"
MAILBOX_FILE=${DEFAULT_MAILBOX_FILE}
if [ ! -z "$3" ] ; then
	MAILBOX_FILE=$3
fi
echo "Mailbox file = ${MAILBOX_FILE}";

# If no options were given, use default options
SYNC_OPTIONS=${DEFAULT_OPTIONS}
if [ ! -z "$4" ] ; then
	SYNC_OPTIONS=$4
fi
echo "Options = ${SYNC_OPTIONS}";

# Check if mailbox file actually exists.
if [ ! -f ${MAILBOX_FILE} ] ; then
	echo "${MAILBOX_FILE} does not exist. Exiting.";
	exit 0;
fi

echo "Starting IMAP sync with credentials from ${MAILBOX_FILE}.";
echo "";

{ while IFS=';' read  user1 password1 user2 password2
    do 
        { echo "$user1" | egrep "^#" ; } > /dev/null && echo "Skipping commented line." && continue # This skips commented out lines in the mailbox file
        echo "==== Start syncing user $user1 on ${SERVER_1} to user $user2 on ${SERVER_2} ====";
        imapsync  $SYNC_OPTIONS \
			--host1 $SERVER_1 --user1 "$user1" --password1 "$password1" \
            --host2 $SERVER_2 --user2 "$user2" --password2 "$password2"
        
        echo "==== Finished syncing user $user1 on ${SERVER_1} to user $user2 on ${SERVER_2} ====";
        echo "";
    done 
} < ${MAILBOX_FILE}

echo "Finished IMAP sync with credentials from ${MAILBOX_FILE}.";
# TODO Show time taken.
echo "";