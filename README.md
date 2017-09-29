# greyhoundforty.com

The repository for [greyhoundforty.com](http://greyhoundforty.com). This site uses a Git Post Commit hook to run a deploy script which in turn builds a docker container and pushes it to [hyper.sh](https://hyper.sh). 

## Post Commit Hook

```shell
#!/usr/bin/env bash

blogdir="$HOME/Repos/greyhoundfortydotcom"
logfile="$HOME/Repos/greyhoundfortydotcom/deploylog.txt"

cd "$blogdir"

bash deploy.sh >>"$logfile" 2>&1

git push
```

## deploy.sh

```shell
#!/usr/bin/env bash

app=hyperjekyll
apphome='$HOME/Repos/greyhoundfortydotcom'

# If app is already running kill the container
if [[ $(hyper ps -q --filter "name=$app" | grep -q . && echo running) = "running" ]]; then
    hyper stop "$app"
    hyper rm "$app"
fi

cd "$apphome"
rm -rf _site
mkdir _site

# Build jekyll site
bundle install 
bundle exec jekyll build -q -d _site

docker build -t hyperjekyll . 
docker tag hyperjekyll greyhoundforty/hyperjekyll
docker push greyhoundforty/hyperjekyll

hyper pull greyhoundforty/hyperjekyll
hyper run -d --name=hyperjekyll -p 80:80 greyhoundforty/hyperjekyll
hyper fip attach greyhoundforty hyperjekyll

for i in $(hyper images -f "dangling=true" -q); do hyper rmi "$i";done
```
