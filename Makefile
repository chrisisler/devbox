REPOSITORY := chrisisler/devbox-neovim

all: dotfiles

run:
	@source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY)

clean:
	@docker rmi --force $(REPOSITORY)

base:
	@docker build --tag $(REPOSITORY)-base base

dotfiles: base
	@docker build --no-cache --tag $(REPOSITORY) .

cached: base
	@docker build --tag $(REPOSITORY) .

.PHONY: all base dotfiles clean cached
