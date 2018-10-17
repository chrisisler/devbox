REPOSITORY := chrisisler/devbox

all: base

run:
	@docker run --interactive --tty --rm chrisisler/devbox

base:
	@docker build --tag $(REPOSITORY) devbox

dotfiles:
	@docker build --tag $(REPOSITORY) .

clean:
	@docker rmi --force $(REPOSITORY)

.PHONY: all devbox-base dotfiles clean
