# Exit on errors
set -o errexit

# Configure git
git config --global push.default simple
git config --global user.email `git log --max-count=1 --format='%ae'`
git config --global user.name `git log --max-count=1 --format='%an'`
git remote set-url origin git@github.com:greenelab/continuous_analysis.git

# Decrypt and add SSH key
# Change openssl arguments for your Travis encrypted key
openssl aes-256-cbc \
  -K $encrypted_REPLACE_key \
  -iv $encrypted_REPLACE_iv \
  -in travis-ci/deploy.key.enc \
  -out travis-ci/deploy.key -d
eval `ssh-agent -s`
chmod 600 travis-ci/deploy.key
ssh-add travis-ci/deploy.key

# Commit message
MESSAGE="\
`git log --max-count=1 --format='%s'`

This build is based on
https://github.com/$TRAVIS_REPO_SLUG/commit/$TRAVIS_COMMIT.

This commit was created by the following Travis CI build and job:
https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID
https://travis-ci.org/$TRAVIS_REPO_SLUG/jobs/$TRAVIS_JOB_ID

[ci skip]

The full commit message that triggered this build is copied below:

$TRAVIS_COMMIT_MESSAGE
"

git checkout master
git add travis-ci
git commit --all --message="$MESSAGE"
git push
