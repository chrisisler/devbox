REPOSITORY := chrisisler/devbox

all: base

run:
	@docker run --interactive --tty --rm chrisisler/devbox

clean:
	@docker rmi --force $(REPOSITORY)

base:
	@docker build --tag $(REPOSITORY) base

dotfiles: base
	@docker build --tag $(REPOSITORY) .

.PHONY: all base dotfiles clean
