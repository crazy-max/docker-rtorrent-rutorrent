#!/usr/bin/with-contenv sh
RU_DOWNLOAD_FOLDER=${RU_DOWNLOAD_FOLDER:-/downloads}
# Custom Folder
if [[ "${RU_DOWNLOAD_FOLDER}" != "/downloads" ]]; then
   rm -rf /downloads/{complete,temp}
   mkdir -p ${RU_DOWNLOAD_FOLDER} \
            ${RU_DOWNLOAD_FOLDER}/complete \
            ${RU_DOWNLOAD_FOLDER}/temp

  echo "  Enabling Custom Download Folder for rTorrent..."
  sed -i "s#/downloads#${RU_DOWNLOAD_FOLDER}#g" /etc/rtorrent/.rtlocal.rc
  echo "Fixing perms for Custom Folders..."
  chown rtorrent. \
    ${RU_DOWNLOAD_FOLDER} \
    ${RU_DOWNLOAD_FOLDER}/complete \
    ${RU_DOWNLOAD_FOLDER}/temp
fi
#EOF