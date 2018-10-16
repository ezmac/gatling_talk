#!/bin/bash
# don't judge me, I just wanted to make it run.
docker run --name gatling_talk_apache  -p 8888:80 -v "$PWD":/usr/local/apache2/htdocs/ httpd:2.4  || true &
docker start gatling_talk_apache  || true &

for i in {1..19}; do
  slides="$slides slides/$i.md"
done

vim "+noremap n :next<CR>" "+noremap p :prev<CR>" $slides


docker stop gatling_talk_apache || true
