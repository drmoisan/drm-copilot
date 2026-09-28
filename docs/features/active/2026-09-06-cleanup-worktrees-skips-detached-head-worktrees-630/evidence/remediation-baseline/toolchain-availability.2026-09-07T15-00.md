# Toolchain Availability

Timestamp: 2026-09-07T15-00
Task: [P0-T4]

## Command 1

Command: `npx --yes bats --version`
EXIT_CODE: 0

```
Bats 1.13.0
```

## Command 2

Command: `shfmt --version`
EXIT_CODE: 0

```
v3.12.0
```

## Command 3

Command: `shellcheck --version`
EXIT_CODE: 0

```
ShellCheck - shell script analysis tool
version: 0.11.0
license: GNU General Public License, version 3
website: https://www.shellcheck.net
```

## Command 4

Command: `gh --version`
EXIT_CODE: 0

```
gh version 2.87.3 (2026-02-23)
https://github.com/cli/cli/releases/tag/v2.87.3
```

## Supplementary observation — kcov

Command: `command -v kcov`
EXIT_CODE: 1

Stdout was empty.

Output Summary: all four required commands ran and exited 0. The four printed version strings are
`Bats 1.13.0`, `v3.12.0` (shfmt), `version: 0.11.0` (shellcheck), and
`gh version 2.87.3 (2026-02-23)`. None of the four was refused. `kcov` has no local route in this
worktree: `command -v kcov` exits 1 with empty stdout, so no local coverage run is possible.
Coverage for this cycle is therefore produced by `.github/workflows/_shell-coverage.yml`, which runs
`scripts/bash/shell-qc.sh test --coverage` on `ubuntu-latest` where kcov is installed.
