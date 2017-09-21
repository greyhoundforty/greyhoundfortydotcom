#!/usr/bin/env bash

app=hyperjekyll
apphome='$HOME/Repos/greyhoundfortydotcom'

if [[ $(hyper ps -q --filter "name=$app" | grep -q . && echo running) = "running" ]]; then
	hyper stop "$app"
	hyper rm "$app"
fi

cd "$apphome"
rm -rf _site
mkdir _site

bundle install 
bundle exec jekyll build -q -d _site

docker build -t hyperjekyll . 
docker tag hyperjekyll greyhoundforty/hyperjekyll
docker push greyhoundforty/hyperjekyll

hyper pull greyhoundforty/hyperjekyll
hyper run -d --name=hyperjekyll -p 80:80 greyhoundforty/hyperjekyll
hyper fip attach greyhoundforty hyperjekyll

for i in $(hyper images -f "dangling=true" -q); do hyper rmi "$i";done
