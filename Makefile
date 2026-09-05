REPOSITORY := chrisisler/devbox
BASE_SYS_REPOSITORY := $(REPOSITORY)-base-sys
TDF_REPOSITORY := chrisisler/tdf
TERMPDF_REPOSITORY := chrisisler/termpdf
IMAGEMAGICK_REPOSITORY := chrisisler/imagemagick
LILYPOND_REPOSITORY := chrisisler/lilypond
SYNCTHING_REPOSITORY := chrisisler/syncthing

all: cached

run:
	@source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY)

everything: base tdf termpdf cimagemagick clilypond csyncthing

tdf:
	@docker build --tag $(TDF_REPOSITORY) --file base/tdf base

termpdf:
	@docker build --tag $(TERMPDF_REPOSITORY) --file base/termpdf base

cimagemagick:
	@docker build --tag $(IMAGEMAGICK_REPOSITORY) --file base/imagemagick base

clilypond:
	@docker build --tag $(LILYPOND_REPOSITORY) --file base/lilypond base

csyncthing:
	@docker build --tag $(SYNCTHING_REPOSITORY) --file base/syncthing base

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

.PHONY: all base dotfiles everything clean cached tdf termpdf \
	cimagemagick clilypond csyncthing
