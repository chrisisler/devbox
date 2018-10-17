REPOSITORY := chrisisler/devbox

all: base

base:
	@docker build --tag $(REPOSITORY) devbox

dotfiles:
	@docker build --tag $(REPOSITORY) .

clean:
	@docker rmi --force $(REPOSITORY)

.PHONY: all devbox-base dotfiles clean
