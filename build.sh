#!/bin/bash

REPOSITORY=stevemcgrath/nessus_scanner
IMAGE_NAME=nessus_scanner

function build_image {
	# Build the container
	docker build $(dirname "$0") -t ${IMAGE_NAME}:latest

	# Lets get the version information...
	local version=$(docker run --rm -it nessus:latest /opt/nessus/sbin/nessusd --version | awk '{print $3}' | head -n1)
	local major=$(echo ${version} | cut -d '.' -f 1)
	local minor=$(echo ${version} | cut -d '.' -f 2)

	# If the container built successfully, and we have marked the build
	# for upload, then we should tag and upload the build based on the
	# version information.
	if [ -n "${major}" ];then
		docker tag ${IMAGE_NAME}:latest ${REPOSITORY}:${major}
		docker push ${REPOSITORY}:${major}
		docker rmi ${REPOSITORY}:${major}
	fi

	if [ -n "${minor}" ];then
		docker tag ${IMAGE_NAME}:latest ${REPOSITORY}:${major}.${minor}
		docker push ${REPOSITORY}:${major}.${minor}
		docker rmi ${REPOSITORY}:${major}.${minor}
	fi

	docker tag ${IMAGE_NAME}:latest ${REPOSITORY}:latest
	docker push ${REPOSITORY}:latest
	docker rmi ${REPOSITORY}:latest
}

build_image