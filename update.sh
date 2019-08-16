#!/bin/bash

repo_path=$(cd "$(dirname "$0")"; pwd)
ssh_key_path=$(cd "$(dirname "${repo_path}")"; pwd)/ssh/id_rsa
ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
local_ip_record=$repo_path/local_ip_record
local_ip=""
if [ -f ${local_ip_record} ]; then
  local_ip=$(cat $local_ip_record)
fi
if [[ ${#ip} > 0 && "$ip" != "$local_ip" ]]; then
  rm -f $local_ip_record
  echo "${ip}" > $local_ip_record
  file=index.html
  file_path=$repo_path/$file
  BUILD_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  rm -f $file
  bash -c "echo '<!DOCTYPE html><html><head><meta content=\"text/html; charset=UTF-8\"></head><body><a href=\"http://${ip}:8080\">Jenkins Updated at ${BUILD_TIMESTAMP}</a></body></html>' > ${file_path}"
  git -C $repo_path add $file $local_ip_record
  git -C $repo_path commit -m "Updated at ${BUILD_TIMESTAMP}"
  bash -c "ssh-agent bash -c 'ssh-add ${ssh_key_path}; git -C ${repo_path} push origin --force'"
fi
