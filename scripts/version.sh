
BRANCH=$(git rev-parse --abbrev-ref HEAD)
TAG_NAME=$(echo "$BRANCH" | tr 'A-Z' 'a-z' | tr -cd '[[:alnum:]]')

if [ "x-$BRANCH" = "x-master" ]; then
    npm version patch
else 
    npm version prerelease --preid=$TAG_NAME
fi


