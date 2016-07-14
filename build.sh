#!/bin/sh

REPOS="numnine"
PROJECT="octobercms"
VERSION="latest"

docker build -t $REPOS/$PROJECT .

