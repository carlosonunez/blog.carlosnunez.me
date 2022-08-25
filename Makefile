#!/usr/bin/env make

BLOG_GEN_VERSION ?= 2.0.9
ENVIRONMENT_FILE ?= .env

export ENVIRONMENT_FILE
export BLOG_GEN_VERSION

.PHONY: fetch_blog_gen decrypt_env deploy test test_keep

decrypt_env:
	ENV_PASSWORD=$${ENV_PASSWORD} ./blog-gen/scripts/decrypt_env.sh

encrypt_env:
	ENV_PASSWORD=$${ENV_PASSWORD} ./blog-gen/scripts/encrypt_env.sh

fetch_blog_gen:
	test -d ./blog-gen || \
		git clone -b "v$${BLOG_GEN_VERSION}" https://github.com/carlosonunez/https-hugo-bloggen ./blog-gen

deploy: fetch_blog_gen
deploy:
	./blog-gen/scripts/deploy

test: fetch_blog_gen
test:
	./blog-gen/scripts/deploy --test
