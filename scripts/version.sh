CURRENT_VERSION=$(node -pe "require('./package.json').version")

if [ "x${BRANCH_NAME}" = "x" ]; then
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

TAG_NAME=$(echo "${BRANCH_NAME}" | tr 'A-Z' 'a-z' | tr -cd '[[:alnum:]]')

if [ "x${BRANCH_NAME}" != "xmaster" ]; then
    CURRENT_TAG_NAME=$(echo ${CURRENT_VERSION} | sed "s/[0-9].*\.[0-9].*\.[0-9].*-\(${TAG_NAME}\)\.[0-9].*$/\1/")

    IS_MODIFIED=$(git ls-files -m | grep package.json)

    if [ "x${IS_MODIFIED}" != 'xpackage.json' ]; then
        if [ "x$CURRENT_TAG_NAME" != "x${TAG_NAME}" ]; then
            npm --no-git-tag-version version patch
        fi
        
        npm version --no-git-tag-version  prerelease --preid=${TAG_NAME}
    fi

    git add package.json
fi


