#!/usr/bin/env bash

app=hyperjekyll

if [[ $(hyper ps -q --filter "name=$app" | grep -q . && echo running) = "running" ]]; then
	hyper stop "$app"
	hyper rm "$app"
fi

cd $HOME/Repos/scribble
rm -rf web
mkdir web

bundle install 
bundle exec jekyll build -q -d web

docker build -t hyperjekyll . 
docker tag hyperjekyll greyhoundforty/hyperjekyll
docker push greyhoundforty/hyperjekyll

hyper pull greyhoundforty/hyperjekyll
hyper run -d --name=hyperjekyll -p 80:80 greyhoundforty/hyperjekyll
hyper fip attach greyhoundforty hyperjekyll
