#!/bin/bash

function file_increment ()
{
  [[ $# != 2 ]] && { echo "[-] This Function take only one argu which is file name (ex: error.log.1 error.log)"; exit 2; }
  log_file="${1}"
  base_file="${2}"

  num=$(echo ${log_file} | awk -F. '{print $NF}')
  new_num=$(( ${num} + 1 ))
  [[ -f "${base_file}.${new_num}" || -d "${base_file}.${new_num}" ]] && { echo "There is file or dir with same name"; exit 2; } 
  mv "${log_file}" "${base_file}.${new_num}"
}

for i in $(ls -1 | grep -E "\.log$")
do
  base_file="${i}"
  echo "${i}"
  for f in $(ls -1 | grep -E "\.log\.[1-9]+$" | grep -E "^${base_file}" | awk -F. '{print $NF,$0}' | sort -nr | cut -d ' ' -f 2)
  do
    file_increment "${f}" "${base_file}"
    echo -e "\t${f}\t${base_file}"
  done
  [[ -f "${base_file}.1" ]] && { echo "[-] Something wrong, ${base_file}.1 , exist"; exit 1; }
  owner_group="$(ls -al ${base_file} | awk '{print $3, $4}' | tr ' ' ':')"
  mv "${base_file}" "${base_file}.1"
  touch "${base_file}"
  chown "${owner_group}" "${base_file}"
done
