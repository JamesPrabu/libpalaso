#!/bin/bash
# server=build.palaso.org
# build_type=Libpalaso_PalasoWin32masterNostrongnameContinuous
# root_dir=..
# Auto-generated by https://github.com/chrisvire/BuildUpdate.
# Do not edit this file by hand!

cd "$(dirname "$0")"

# *** Functions ***
force=0
clean=0

while getopts fc opt; do
case $opt in
f) force=1 ;;
c) clean=1 ;;
esac
done

shift $((OPTIND - 1))

copy_auto() {
if [ "$clean" == "1" ]
then
echo cleaning $2
rm -f ""$2""
else
where_curl=$(type -P curl)
where_wget=$(type -P wget)
if [ "$where_curl" != "" ]
then
copy_curl "$1" "$2"
elif [ "$where_wget" != "" ]
then
copy_wget "$1" "$2"
else
echo "Missing curl or wget"
exit 1
fi
fi
}

copy_curl() {
echo "curl: $2 <= $1"
if [ -e "$2" ] && [ "$force" != "1" ]
then
curl -# -L -z "$2" -o "$2" "$1"
else
curl -# -L -o "$2" "$1"
fi
}

copy_wget() {
echo "wget: $2 <= $1"
f1=$(basename $1)
f2=$(basename $2)
cd $(dirname $2)
wget -q -L -N "$1"
# wget has no true equivalent of curl's -o option.
# Different versions of wget handle (or not) % escaping differently.
# A URL query is the only reason why $f1 and $f2 should differ.
if [ "$f1" != "$f2" ]; then mv $f2\?* $f2; fi
cd -
}


# *** Results ***
# build: palaso-win32-master-nostrongname Continuous (Libpalaso_PalasoWin32masterNostrongnameContinuous)
# project: libpalaso
# URL: http://build.palaso.org/viewType.html?buildTypeId=Libpalaso_PalasoWin32masterNostrongnameContinuous
# VCS: https://github.com/sillsdev/libpalaso.git [master]
# dependencies:
# [0] build: L10NSharp master continuous (L10NSharp_L10NSharpMasterContinuous)
#     project: L10NSharp
#     URL: http://build.palaso.org/viewType.html?buildTypeId=L10NSharp_L10NSharpMasterContinuous
#     clean: false
#     revision: latest.lastSuccessful
#     paths: {"L10NSharp.dll"=>"lib/Release", "L10NSharp.pdb"=>"lib/Release"}
#     VCS: https://github.com/sillsdev/l10nsharp [master]
# [1] build: L10NSharp master continuous (L10NSharp_L10NSharpMasterContinuous)
#     project: L10NSharp
#     URL: http://build.palaso.org/viewType.html?buildTypeId=L10NSharp_L10NSharpMasterContinuous
#     clean: false
#     revision: latest.lastSuccessful
#     paths: {"L10NSharp.dll"=>"lib/Debug", "L10NSharp.pdb"=>"lib/Debug"}
#     VCS: https://github.com/sillsdev/l10nsharp [master]
# [2] build: TagLib-Sharp Continuous (bt411)
#     project: Libraries
#     URL: http://build.palaso.org/viewType.html?buildTypeId=bt411
#     clean: false
#     revision: latest.lastSuccessful
#     paths: {"taglib-sharp.dll"=>"lib/Release"}
#     VCS: https://github.com/sillsdev/taglib-sharp.git [develop]
# [3] build: TagLib-Sharp Continuous (bt411)
#     project: Libraries
#     URL: http://build.palaso.org/viewType.html?buildTypeId=bt411
#     clean: false
#     revision: latest.lastSuccessful
#     paths: {"taglib-sharp.dll"=>"lib/Debug"}
#     VCS: https://github.com/sillsdev/taglib-sharp.git [develop]

# make sure output directories exist
mkdir -p ../lib/Debug
mkdir -p ../lib/Release

# download artifact dependencies
copy_auto http://build.palaso.org/guestAuth/repository/download/L10NSharp_L10NSharpMasterContinuous/latest.lastSuccessful/L10NSharp.dll ../lib/Release/L10NSharp.dll
copy_auto http://build.palaso.org/guestAuth/repository/download/L10NSharp_L10NSharpMasterContinuous/latest.lastSuccessful/L10NSharp.pdb ../lib/Release/L10NSharp.pdb
copy_auto http://build.palaso.org/guestAuth/repository/download/L10NSharp_L10NSharpMasterContinuous/latest.lastSuccessful/L10NSharp.dll ../lib/Debug/L10NSharp.dll
copy_auto http://build.palaso.org/guestAuth/repository/download/L10NSharp_L10NSharpMasterContinuous/latest.lastSuccessful/L10NSharp.pdb ../lib/Debug/L10NSharp.pdb
copy_auto http://build.palaso.org/guestAuth/repository/download/bt411/latest.lastSuccessful/taglib-sharp.dll ../lib/Release/taglib-sharp.dll
copy_auto http://build.palaso.org/guestAuth/repository/download/bt411/latest.lastSuccessful/taglib-sharp.dll ../lib/Debug/taglib-sharp.dll
# End of script
