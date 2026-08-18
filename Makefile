REPOSITORY := chrisisler/devbox

all: run

create:
	@read -p "Enter absolute working directory: " WORKDIR; \
	@sbx create --name "chrisisler-devbox" copilot $$WORKDIR

run:
	@source ./dotfiles/devbox-scripts.sh && devbox $(REPOSITORY)

clean:
	@sbx rm "chrisisler-devbox" --force

cached:
	@sbx run --name "chrisisler-devbox" copilot

.PHONY: all create run clean cached update
