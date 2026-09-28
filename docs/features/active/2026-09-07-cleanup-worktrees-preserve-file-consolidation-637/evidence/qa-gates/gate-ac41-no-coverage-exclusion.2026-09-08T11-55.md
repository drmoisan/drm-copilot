# Gate — AC-41, no coverage exclusion was added for a production path

Timestamp: 2026-09-08T11-55
Task: `[P9-T4]`
Command: git diff epic/cleanup-merged-worktrees-hardening-integration -- scripts/bash/shell_qc_lib.sh scripts/bash/shell-qc.sh .github/workflows/_shell-coverage.yml
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: the diff printed nothing and exited 0. No line was added to any of the three files,
so no added line can introduce an exclusion matching a path under `scripts/`.

The three files named are the entire coverage-configuration surface for the bash toolchain: the
library that discovers the file set and runs `kcov`, the entry point that dispatches the coverage
stage, and the workflow that runs it in CI. An empty diff across all three is a stronger result
than an added-line inspection would have been, because it establishes that the coverage
configuration is byte-identical to the epic integration branch rather than merely free of one
particular pattern.

The two new production files, `scripts/bash/cleanup_worktrees_preserve_lib.sh` and
`scripts/bash/cleanup_worktrees_preserve_eol_lib.sh`, are therefore in the coverage denominator on
the same terms as every other file under `scripts/bash/`. That is the intended outcome: the
Coverage Exclusion Policy directs that untestable lines be minimized by refactoring rather than
excluded from measurement, which is why the writing phase was reduced to `mkdir -p`, a byte copy, an
append, and a staging call, with every decision in the read-only phase.

Verdict: PASS.
