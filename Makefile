REPOSITORY := chrisisler/devbox
BASE_SYS_REPOSITORY := $(REPOSITORY)-base-sys
BASE_REPOSITORY := $(REPOSITORY)-base

all: dotfiles

run:
	@source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY)

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

.PHONY: all base dotfiles clean cached
