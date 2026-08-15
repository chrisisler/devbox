REPOSITORY := chrisisler/devbox

all: dotfiles

run:
	@read -p "Enter absolute working directory: " WORKDIR; \
  source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY) $$WORKDIR

clean-base:
	@docker rmi --force $(REPOSITORY)-base

clean:
	@docker rmi --force $(REPOSITORY)

base:
	@docker build --tag $(REPOSITORY)-base base

dotfiles: base
	@docker build --no-cache --tag $(REPOSITORY) .

cached: base
	@docker build --tag $(REPOSITORY) .

update:
	@./dotfiles/update-dotfiles.sh

.PHONY: all base dotfiles clean cached
