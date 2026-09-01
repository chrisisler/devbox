# gh-axi evaluation

## Summary

`gh-axi` is an agent-oriented wrapper around the official `gh` CLI. It
transforms command output into token-efficient TOON, adds contextual
next-step suggestions, and provides structured errors. It does **not** remove
the need for `gh`, GitHub authentication, or GitHub's API; it changes the
interface used by the agent.

The current upstream package is `gh-axi` `0.1.35` and requires Node.js 20 or
newer. The project documents `npx -y gh-axi` as zero-install usage and
`npm install -g gh-axi` as the global-install path. The package is MIT
licensed.

Sources:

- <https://github.com/kunchenguid/gh-axi>
- <https://github.com/kunchenguid/gh-axi/blob/main/VISION.md>
- <https://www.npmjs.com/package/gh-axi>

## Potential benefits for devbox

- Lower agent context usage for issue, pull request, workflow, project, and
  search operations through compact TOON output.
- A single command-first interface for GitHub operations, which may reduce
  the number of exploratory calls currently needed with raw `gh` or the
  GitHub MCP server.
- Agent-focused handling for long CI logs, check-rollup states, repeated
  flags, validation errors, and non-interactive mutations.
- Optional Codex/OpenCode/Claude Code session hooks can provide ambient
  repository context.
- It can replace direct agent use of `gh` and remove dependence on the
  GitHub MCP server for routine GitHub tasks.

The upstream README reports an AXI benchmark result of 46,462 average input
tokens and 15.7 seconds per task for `gh-axi`, compared with 47,076 and
17.4 seconds for raw `gh`, and 137,409 and 43.4 seconds for the tested GitHub
MCP code-execution setup. These are upstream results for 17 benchmark tasks,
not measurements of this repository or this container.

## Costs and ways it can break the current flow

- `gh-axi` still shells out to `gh`; installing it does not eliminate the
  `gh` package or the existing GitHub authentication path.
- Existing scripts, documentation, and agents that expect human-readable
  `gh` output or JSON must be migrated and tested. TOON is optimized for
  agents, not a stable scripting API.
- Feature parity is an upstream goal, not a guarantee. Less-common `gh`
  extensions, flags, Enterprise behavior, or newly released commands may
  lag.
- Stacked PR operations additionally require the official
  `github/gh-stack` extension.
- `npx -y` and an unpinned global install introduce npm/network and
  supply-chain risk. A production image should pin the package version and
  review lockfile or integrity metadata where practical.
- Optional session hooks modify agent startup behavior and add another
  mutable integration point. They should not be enabled until startup,
  failure, and offline behavior are tested for Codex, OpenCode, and FCC.
- `gh-axi` does not improve credential confidentiality. `GH_TOKEN` remains
  readable by an agent if it is injected into the agent container. It also
  does not replace the need for short-lived, least-privilege credentials or
  a capability broker.
- The current image already has Node.js and `gh`, but introducing a global
  npm package adds another build input and should be pinned alongside the
  other agent tools.

## Proposed adoption path

1. Install a pinned `gh-axi` version in the app image without enabling
   automatic self-update or session hooks.
2. Keep `gh` installed as its implementation dependency and emergency
   fallback during evaluation.
3. Exercise read-only commands first: dashboard, issue list, PR view, PR
   checks, run list/view, and repository search.
4. Compare latency, output size, exit codes, and task success against the
   current raw-`gh` flow before migrating mutations.
5. Migrate PR/issue/workflow operations only after testing the exact flags
   used by this repository, especially body files, check status, and
   non-interactive behavior.
6. Revisit authentication separately. Do not treat `gh-axi`, SOPS, Vault,
   Swarm secrets, or TOON output as a credential boundary.

## Risk assessment

| Risk | Level | Impact | Mitigation |
| --- | --- | --- | --- |
| npm/package compromise or mutable install | High | Agent commands or build tooling could be altered | Pin `gh-axi`, review releases, avoid `npx -y` in the image, and verify package integrity |
| Credential exposure | Critical | An agent can exfiltrate GitHub credentials regardless of output format | Remove raw `GH_TOKEN`; use a host-side capability broker and short-lived scoped credentials |
| Wrapper/`gh` compatibility gap | Medium | Existing GitHub workflows may fail or produce different results | Keep `gh` during migration; test read and write commands used by devbox |
| TOON treated as a stable machine API | Medium | Scripts may break after upstream output changes | Use documented command semantics, not output parsing; retain raw `gh` for imperative automation |
| Session-hook regression | Medium | Codex/OpenCode/FCC startup may slow or fail | Defer hooks; test offline and failure paths before enabling |
| Added dependency and network availability | Low | Builds or first-run commands may fail without npm/GitHub access | Pin in the image and provide a documented fallback to `gh` |
| False security expectation | High | Team may assume the wrapper hides tokens or isolates agents | Document that `gh-axi` is an ergonomics layer, not a security boundary |

## Recommendation

Adopt `gh-axi` as an evaluated, pinned agent interface for routine GitHub
operations, while retaining `gh` underneath and as a temporary fallback.
It is a credible way to reduce agent context and latency, but it should not
be presented as a replacement for the `gh` dependency or as a solution to
the token/account security problem. Credential isolation should be handled
as a separate capability-broker project.
