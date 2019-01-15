#! /bin/bash

##
# This script is used to for automatic versioning following the semver standard. 
# Basically, it should work like NPMs `npm version <major|minor|patch>` 
#
# If you run this script, it will automatically bump the version in the specified
# version.json file (e.g. package.json, composer.json, ...).
# 
# If no <bump type> is supplied, it will use `conventional-recommended-bump -p 'angular'`
# to find the recommended next version. 

# After increasing the version, it updates the CHANGELOG.md, creates a new commit and
# git tags the commit with the new version number. Push has to be made manually.
#
# Usage: ./bump.sh -p </path/to/version.json> -b <major|minor|patch>
##

# init vars
use_default_path=true
verbose=false
dry_run=false

# read in args (version.json path, bump type)
while getopts ':vdp:b:' OPTION
do
  case "$OPTION" in
    p)  version_path="$OPTARG"
        use_default_path=false
    ;;
    v)  echo "Verbose execusion"
        verbose=true
    ;;
    d)  echo "Dry run. No changes will be applied."
        dry_run=true
    ;;
    b)  echo "Using supplied bump type."
        bump_type="$OPTARG"
    ;;
    *)  echo "Ignoring unknown parameter."
  esac
done

# set default path
if [ "$use_default_path" == true ]
  then
    version_path="version.json"
fi

# recommended semver bump type (i.e. major, minor, patch)
if [ -z "$bump_type" ]
  then
    bump_type=$( conventional-recommended-bump -p 'angular' )
fi
if [ "$verbose" == true ]
  then
    echo "Bump type is ${bump_type}"
fi

# read the old version from file ({}.version)
old_version=$(jq -r '.version' ${version_path})
# check if version is set, else set 0.0.0
if [ -z ${old_version} ]
  then
    old_version="0.0.0"
fi
if [ "$verbose" == true ]
  then
    echo "Old version is ${old_version}"
fi

# explode version string into array
version_array=( ${old_version//./ } )

# increment version numbers as requested
case $bump_type in
  patch)
    ((version_array[2]++))
    ;;
  minor)
    ((version_array[1]++))
    version_array[2]=0
    ;;
  major)
    ((version_array[0]++))
    version_array[1]=0 
    version_array[2]=0 
    ;;
  *)
    echo "Unknown bump type. Please use major, minor or patch."
    exit 1
    ;;
esac

# combine to new version
new_version="${version_array[0]}.${version_array[1]}.${version_array[2]}"
if [ "$verbose" == true ]
  then
    echo "New version is ${new_version}"
fi

# write back new version in version file
updated_file=$(jq '.version = $new' --arg new ${new_version} ${version_path})
echo "$updated_file" > $version_path

# add version file to git
git add ${version_path}
if [ "$verbose" == true ]
  then
    echo "Updated version file"
fi

# generate CHANGELOG.md
conventional-changelog -p angular -k "${version_path}" -i CHANGELOG.md -s
git add CHANGELOG.md
if [ "$verbose" == true ]
  then
    echo "Updated CHANGELOG.md"
fi

# commit current changes
git commit -am "chore(version): create new ${bump_type} version v${new_version}"

# tag the current commit
git tag -a v${new_version} -m "Automatic version: ${bump_type}"
