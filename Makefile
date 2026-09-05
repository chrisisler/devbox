REPOSITORY := chrisisler/devbox
BASE_SYS_REPOSITORY := $(REPOSITORY)-base-sys
BASE_REPOSITORY := $(REPOSITORY)-base
TDF_REPOSITORY := $(or $(DOCKER_REPO_PREFIX),chrisisler)/tdf

all: cached

run:
	@source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY)

everything: base pdf

pdf:
	@docker build --tag $(TDF_REPOSITORY) --file base/pdf base

clean-base:
	@docker rmi --force $(BASE_REPOSITORY) $(BASE_SYS_REPOSITORY)

clean:
	@docker rmi --force $(REPOSITORY)

base:
	@docker build --tag $(BASE_SYS_REPOSITORY) --file base/Dockerfile.sys base
	@docker build --tag $(BASE_REPOSITORY) --file base/Dockerfile.app base

dotfiles: base
	@docker build --no-cache --tag $(REPOSITORY) .

cached: base
	@docker build --tag $(REPOSITORY) .

update:
	@./dotfiles/update-dotfiles.sh

.PHONY: all base dotfiles everything clean cached pdf
