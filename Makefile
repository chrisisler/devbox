REPOSITORY := chrisisler/devbox

all: base

run:
	@docker run --interactive --tty --rm --volume "${HOME}/.ssh/devbox:/home/devuser/.ssh" $(REPOSITORY)

clean:
	@docker rmi --force $(REPOSITORY)

base:
	@docker build --tag $(REPOSITORY) base

dotfiles: base
	@docker build --no-cache --tag $(REPOSITORY) .

.PHONY: all base dotfiles clean echo
