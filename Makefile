PROJECT_ROOT = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DOCKER_IMAGE = imagemagick-builder
TARGET ?=/opt/

MOUNTS = -v $(PROJECT_ROOT):/var/task \
	-v $(PROJECT_ROOT)result:$(TARGET)

DOCKER_BUILD = docker build -t $(DOCKER_IMAGE) .
DOCKER_RUN = docker run -it --rm -w=/var/task $(MOUNTS)

build result:
	mkdir -p $@

clean:
	rm -rf build result

build-image:
	$(DOCKER_BUILD)

list-formats: build-image
	$(DOCKER_RUN) $(DOCKER_IMAGE) /opt/bin/identify -list format

bash: build-image
	$(DOCKER_RUN) $(DOCKER_IMAGE)

all libs: build-image
	$(DOCKER_RUN) $(DOCKER_IMAGE) --entrypoint /usr/bin/make TARGET_DIR=$(TARGET) -f ../Makefile_ImageMagick $@

STACK_NAME ?= imagemagick-layer

result/bin/identify: all

build/layer.zip: result/bin/identify build
	# Compress symlinks as symlinks to avoid packaging issues
	cd result && zip -ry $(PROJECT_ROOT)$@ *

build/output.yaml: template.yaml build/layer.zip
	aws cloudformation package --template $< --s3-bucket $(DEPLOYMENT_BUCKET) --output-template-file $@

deploy: build/output.yaml
	aws cloudformation deploy --template $< --stack-name $(STACK_NAME)
	aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query Stacks[].Outputs --output table

deploy-example: deploy
	cd example && \
		make deploy DEPLOYMENT_BUCKET=$(DEPLOYMENT_BUCKET) IMAGE_MAGICK_STACK_NAME=$(STACK_NAME)
