REPOSITORY := chrisisler/devbox

all: dotfiles

run:
	@source ./dotfiles/devbox-scripts.sh && devbox

clean:
	@docker rmi --force $(REPOSITORY)

clean-unused-images:
	@source ./dotfiles/devbox-scripts.sh && cleanUnusedImages

base:
	@docker build --tag $(REPOSITORY) base

dotfiles: base
	@docker build --no-cache --tag $(REPOSITORY) .

.PHONY: all base dotfiles clean
