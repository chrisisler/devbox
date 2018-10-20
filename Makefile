REPOSITORY := chrisisler/devbox

all: base

run:
	@docker run --interactive --tty --rm $(REPOSITORY)

clean:
	@docker rmi --force $(REPOSITORY)

base:
	@docker build --tag $(REPOSITORY) base

dotfiles: base
	@docker build --no-cache --tag $(REPOSITORY)-dotfiles .

.PHONY: all base dotfiles clean
