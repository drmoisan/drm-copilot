---
applyTo: "**"
name: "bash-command-shape"
description: "Bash command shape for running a tool or reading a file in another directory without chaining cd"
---

# Bash Command Shape

Never chain `cd` before a read command in one Bash call. On Claude Code, `.claude/hooks/validate-bash.ps1` denies a command line in which a `cd` segment is followed later by `grep`, `cat`, `head`, `tail`, `less`, `more`, `awk`, or `sed -n`, because the Bash permission engine cannot resolve that read against `Read()` rules once the working directory has changed. An output filter such as `| tail -n 20` after a `cd` counts as a read command.

Name the directory on the tool instead of changing into it.

## Forms by Context

| Intent | Agent-isolated worktree | Sibling worktree |
|---|---|---|
| Read a file | Read or Grep tool (absolute-path read) | Read or Grep tool (absolute-path read) |
| git | `git <subcommand>` with no `cd` | `git -C <abs> <subcommand>` |
| Poetry | `env -u VIRTUAL_ENV poetry <command>` with no `cd` | `env -u VIRTUAL_ENV poetry -C <abs> <command>` (long form `--directory <abs>`) |
| npm | `npm <command>` with no `cd` | `npm --prefix <abs> <command>` |
| npx | `npx <tool>` with no `cd` | `npm --prefix <abs> run <script>` when a package script exists, otherwise `sh <SCRATCH>/<file>.sh` |
| Multi-step | the steps with no `cd`, or `sh <SCRATCH>/<file>.sh` | `sh <SCRATCH>/<file>.sh` (the script may `cd` internally) |

`<abs>` is the absolute path of the target directory. `<SCRATCH>` is the issue-scoped scratch directory that the `execution-environment` skill defines.

## Agent-Isolated Worktree

The Bash working directory of an agent-isolated worktree is already the worktree root, so drop the `cd` and call the tool directly. In an agent-isolated worktree, `git -C <other worktree>` is refused. The runtime isolation guard also refuses a `cd <path> &&` prefix before `git`.

## Sibling Worktree

A non-isolated agent working in a sibling worktree has its Bash working directory reset to the session root on each call, so a `cd` does not carry over to the next call. Use the `-C`, `--prefix`, or absolute-path forms in the table, or write the steps to a script under `<SCRATCH>` and run it as `sh <SCRATCH>/<file>.sh`. Do not pass a test path relative to the worktree to `poetry -C <abs> run`; use an absolute path or the `sh` route.

The complete set of command-text restrictions is in `## Command-Text Restrictions` of the `execution-environment` skill.
