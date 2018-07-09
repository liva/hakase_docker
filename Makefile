NAME   := pf.is.s.u-tokyo.ac.jp/~awamoto/docker/hakase/qemu
TAG    := $$(git log -1 --pretty=%!H(MISSING))
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

build:
	@if [ $$(( git diff; git diff --cached; ) | wc -l) -ne 0 ]; then echo "please commit all changes before building docker image.";exit 1; fi
	@docker build -t ${IMG} .
	@docker tag ${IMG} ${LATEST}

push:
	@docker push ${NAME}
