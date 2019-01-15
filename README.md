# Auto semver
This shell script automates the process of bumping a version number in a JSON formatted version file following semver standard (major, minor, patch).

## Usage
`./automatic-semver-version.sh -p <path/to/version.json> -b <major|minor|patch>`

## What it does
- reads old version from file (default "version.json")
- gets recommended bump type reading commit messages (using conventional-recommended-bump)
- bumps the version accordingly
- writes new version back to file
- updates CHANGELOG.md (using conventional-changelog)
- creates a version commit
- tags the commit with the new version 

## What it needs to run
- bash (to run the script)
- jq (to parse JSON)
- [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog) (to create the changelog)
- [conventional-recommended-bump](https://github.com/conventional-changelog/conventional-changelog/tree/master/packages/conventional-recommended-bump) (to get the default bump type, if not supplied)
- git (to commit and tag)

## Helper
There is a package.json which installs the above mentioned JavaScript dependencies.
Just call `npm install`.

## License
Free software, see LICENSE file for further information.
