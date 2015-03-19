git config user.name lstephen
git config user.email levi.stephen@gmail.com
mkdir -p ~/.ssh
cp ${GIT_SSH_KEY} ~/.ssh/id_rsa
chmod 0600 ~/.ssh/id_rsa
printf "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
git config push.default simple
git checkout master
git pull --rebase
echo ${GIT_COMMIT}
git merge --commit ${GIT_COMMIT}
git push origin
git checkout develop
git pull --rebase
bundle install --path vendor/bundle
bundle exec gem bump --version minor
git push origin

