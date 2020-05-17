#!/bin/sh
#
# TODO
# - Add S3 sync
# - Move file to /tmp delete folder for removal purpose
# - Save file to somewhere
# - Protected RM command: https://stackoverflow.com/questions/992737/safe-rm-rf-function-in-shell-script
#
## Fail when variable is undefined
set -u
start=`date +%s`

BASE=/mnt/GastlandMail/mailing/mail/vhosts
TARGET=/tmp/archive
READY_TO_REMOVE=/tmp/sync_done
TODAY=`date +"%Y%m%d"`

function mailarchive() {
    archiveToDir="${TARGET}/${TODAY}"
    email=$1
    tarname=$2
    source=$3
    tarBASE=${BASE}/$4

    echo -n "  Start email ($email) backup..."

    [ ! -d "${archiveToDir}" ] && mkdir -p $archiveToDir
    [ ! -d "${tarBASE}/$source" ] && echo "Not found following mail directory: ${tarBASE}/${source}" && exit 1

    tar --directory=$tarBASE -cjf - "$source" | cat > ${archiveToDir}/${tarname}
    result=$?
    [ $result == 0 ] && echo "success." || echo "failed."
    return $result
}

function remove_old_data() {
  # Delete emails which are more than a weeks old
  #-not -name user -not -name mail
  BASE_TO_REMOVE=${READY_TO_REMOVE##*/}
  for i in `find ${READY_TO_REMOVE} -maxdepth 5 -type d -not -name ${BASE_TO_REMOVE} -mtime +1 -print`
  do
   echo -e "  Deleting directory $i";
   rm -rf $i;
  done
}

function sync_to_s3() {
  echo "  Docker command for AWS S3 Sync"

  return 0
}

echo "[CLEANUP] Delete old archives under ${READY_TO_REMOVE} folder"
remove_old_data()

echo "[RESYNC] Run S3 sync again if the active archive folder is not empty"

echo "[ARCHIVE] Mailboxes ..."
for dir in ${BASE}/*/
do
  dir=${dir%*/}
  domain=${dir##*/}
  for email in ${dir}/*/
  do
    email=${email%*/}
    tarname="${email##*/}@${domain}.tar.gz"
    echo "************"
    echo "  ${tarname} => ${domain}/${email##*/}"
    CHECK=`du -hs "$email" | cut -f1`
     echo "  size:$CHECK"
     mailarchive "${email##*/}@${domain}" "${tarname}" "${email##*/}" "${domain}"
     [ $? == 0 ] && sync_to_s3 || echo "  Mailbox archive failed skip"; continue;
     [ $? == 0 ] && (echo "  Remove archive file ${tarname}" && mv ${tarname} /tmp/${tarname}) || echo "  => S3 sync failed, please run only the sync command again"; contine;
  done
done
echo -e "[ARCHIVE] Done"

end=`date +%s`

runtime=$((end-start))

dd=$(echo "$runtime/86400" | bc)
dt2=$(echo "$runtime-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)

LC_NUMERIC=C printf "Total runtime: %d:%02d:%02d:%02.4f\n\n" $dd $dh $dm $ds
