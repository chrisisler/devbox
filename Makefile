REPOSITORY := chrisisler/devbox
BASE_SYS_REPOSITORY := $(REPOSITORY)-base-sys
TDF_REPOSITORY := chrisisler/tdf
TERMPDF_REPOSITORY := chrisisler/termpdf

all: cached

run:
	@source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY)

everything: base ctdf ctermpdf

ctdf:
	@docker build --tag $(TDF_REPOSITORY) --file base/tdf base

ctermpdf:
	@docker build --tag $(TERMPDF_REPOSITORY) --file base/termpdf base

clean-base:
	@docker rmi --force $(BASE_SYS_REPOSITORY)

clean:
	@docker rmi --force $(REPOSITORY)

base:
	@docker build --tag $(BASE_SYS_REPOSITORY) --file base/Dockerfile.sys base

dotfiles: base
	@docker build --no-cache --tag $(REPOSITORY) .

cached: base
	@docker build --tag $(REPOSITORY) .

update:
	@./dotfiles/update-dotfiles.sh

.PHONY: all base dotfiles everything clean cached ctdf ctermpdf
