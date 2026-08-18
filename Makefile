all: create

create:
	@sbx create --name "chrisisler-devbox" copilot .

run:
	@read -p "Enter absolute working directory: " WORKDIR; \
	sbx run --name "chrisisler-devbox" copilot $$WORKDIR

clean:
	@sbx rm "chrisisler-devbox" --force

cached:
	@sbx run --name "chrisisler-devbox" copilot

.PHONY: all create run clean cached update
