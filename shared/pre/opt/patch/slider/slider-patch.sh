#!/bin/bash

: ${LOGFILE:=/var/log/slider-os-patch.log}

: ${SLIDER_TAR_NAME:=slider-agent.tar.gz}
: ${TMP_EXTRACT_DIR:=temp_extract_dir_slider}

main(){
  hdp_version=$(ls /usr/hdp/ | head -1);
  echo "Found HDP version: $hdp_version"
  SLIDER_TAR_PATH="/usr/hdp/$hdp_version/slider/lib/$SLIDER_TAR_NAME"

  if [[ ! -f "$SLIDER_TAR_PATH" ]]; then
    echo "$SLIDER_TAR_NAME does not exist, skipping.."
    exit 0
  fi

  cd /tmp
  tar_file=$(basename $SLIDER_TAR_PATH)

  echo "Copying $SLIDER_TAR_NAME to /tmp"
  cp $SLIDER_TAR_PATH /tmp

  rm -rf $TMP_EXTRACT_DIR && mkdir $TMP_EXTRACT_DIR && cd $TMP_EXTRACT_DIR
  echo "Extracting $tar_file."
  tar -zxf ../$tar_file

  patch -b slider-agent/resource_management/libraries/functions/os_check.py /opt/patch/slider/os_check.diff

  echo "Removing $tar_file."
  rm -f "../$tar_file"

  echo "Creating new $tar_file with the patched python."
  tar -zcf "../$tar_file" $(ls)

  echo "Replacing $tar_file."
  cp /tmp/$SLIDER_TAR_NAME $SLIDER_TAR_PATH

  echo "Cleaning up local fs."
  rm -f "../$tar_file"
  cd .. && rm -rf $TMP_EXTRACT_DIR
}

exec &>> "$LOGFILE"
[[ "$0" == "$BASH_SOURCE" ]] && main "$@"