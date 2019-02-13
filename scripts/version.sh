REMOTE_VERION=$(npm info browserslist-config-akann version)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
TAG_NAME=$(echo "${BRANCH}" | tr 'A-Z' 'a-z' | tr -cd '[[:alnum:]]')

if [ "x-${BRANCH}" = "x-master" ]; then
    npm version --no-git-tag-version --new-version ${REMOTE_VERION}
    npm --no-git-tag-version version patch
else 
    CURRENT_VERSION=$(node -pe "require('./package.json').version")
    CURRENT_TAG_NAME=$(echo ${CURRENT_VERSION} | sed "s/[0-9].*\.[0-9].*\.[0-9].*-\(${TAG_NAME}\)\.[0-9].*$/\1/")

    if [ "x$CURRENT_TAG_NAME" != "x${TAG_NAME}" ]; then
        npm version --no-git-tag-version --new-version ${REMOTE_VERION}
    fi
    
    npm version prerelease --preid=${TAG_NAME} -m 'version++'
fi


