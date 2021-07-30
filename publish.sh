#!/bin/sh
../../bin/hugo
git push -u origin main
cd public
git add .
git commit -m "Rebuild site"
git push origin master
