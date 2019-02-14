REMOTE_VERION=$(npm info browserslist-config-akann version)

if [ "x${BRANCH_NAME}" = "x" ]; then
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

TAG_NAME=$(echo "${BRANCH_NAME}" | tr 'A-Z' 'a-z' | tr -cd '[[:alnum:]]')

push_tag () {
    git checkout $BRANCH_NAME
    NEW_VERSION=$(node -pe "require('./package.json').version")

    git add package.json
    git commit -m 'version++'
    git tag -a "v${NEW_VERSION}" -m 'version++'

    git push --set-upstream origin $BRANCH_NAME --follow-tag
}

if [ "x${BRANCH_NAME}" = "xmaster" ]; then
    npm version --no-git-tag-version --allow-same-version --new-version ${REMOTE_VERION}
    npm --no-git-tag-version version patch

    npm publish ./

    push_tag 
else 
    CURRENT_VERSION=$(node -pe "require('./package.json').version")
    CURRENT_TAG_NAME=$(echo ${CURRENT_VERSION} | sed "s/[0-9].*\.[0-9].*\.[0-9].*-\(${TAG_NAME}\)\.[0-9].*$/\1/")

    if [ "x$CURRENT_TAG_NAME" != "x${TAG_NAME}" ]; then
        npm version --no-git-tag-version --new-version ${REMOTE_VERION}
    fi
    
    npm version --no-git-tag-version  prerelease --preid=${TAG_NAME}

    push_tag
fi


