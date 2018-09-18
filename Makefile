help:
	@cat Makefile

DOCKER_FILE=Dockerfile
PYTHON_VERSION?=3.6
SRC?=$(CURDIR)
TAG_NAME ?= autoeda

test2:
	echo $(SRC)

build:
	docker build -t $(TAG_NAME) --build-arg python_version=$(PYTHON_VERSION) -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run -it -v $(SRC)/workdir:/workdir -v $(DATA):/data --env KERAS_BACKEND=$(BACKEND) bash

ipython: build
	$(DOCKER) run -it -v $(SRC)/workdir:/workdir -v $(DATA):/data $(TAG_NAME) ipython

notebook: build
	docker run -it -v $(SRC)/workdir:/workdir -v $(DATA):/data --net=host --privileged=true $(TAG_NAME)

train: build
	docker run -i -v $(SRC)/workdir:/workdir -v $(DATA):/data --net=host --privileged=true bash -c "cd /workdir && jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=None $(NOTE)"
