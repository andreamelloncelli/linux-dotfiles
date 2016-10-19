#!/bin/sh

################################################################
### BEGIN_SET_VAR
## parameters
## eval ${1##--}=$2 ## to improve

## DEBIAN_FRONTEND
#export DEBIAN_FRONTEND=noninteractive

## User working directory
USER_WD=`pwd -P`
pushd `dirname $0` > /dev/null
## path of this script file
SCRIPTPATH=`pwd -P`
popd > /dev/null

### END_SET_VAR

#df_path="h/dotfiles"
df_path=${SCRIPTPATH%%/bin*}
installsh="${SCRIPTPATH}/install.sh"

echo 'cd ~' >| $installsh

## Istruction to create links to dir or file in config directory.
##
rh_dir="${df_path}/config"
files=`cd $rh_dir && find . -mindepth 1 -maxdepth 1 -not -iname '*_bak' `
for file in $files; do
    file=${file##./}
    echo "[ -e $HOME/$file ] || ln -s --verbose ${df_path}/config/$file ~/" >> $installsh
done

## Istruction to create links to files in single_config_files.
##
## the find istruction take files and symlinks, obviously NO directories.
##
config_files_dir="${df_path}/single_config_files"
if [[ -d "${config_files_dir}" ]]; then
    files=`cd $config_files_dir && find . -mindepth 1 \( -type f -or -type l \) -not -iname '*_bak' `
    for file in $files; do
	file=${file#./}
	[ -d "$HOME/$(dirname $file)" ] || mkdir -p ~/$(dirname $file)/
	echo "[ -e $HOME/$file ] || ln -s --verbose ~/${df_path}/single_config_files/$file ~/$(dirname $file)/" >> $installsh
    done
fi

echo
echo -e "In order to make dotfiles effective please run:

\tbash ${installsh}
"

exit 0
	

