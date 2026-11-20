# Remediation Plan — Issue #393, Cycle 1

- Entry timestamp (UTC): 2026-07-21T19-39
- Inputs: remediation-inputs.2026-07-21T19-39.md
- Applied by: orchestrator (main session)

## Rationale for orchestrator-applied remediation

The findings are confined to the native bash toolchain (`scripts/bash/shell_qc_lib.sh`)
and its bats test, and their verification requires executing `kcov` and `bats`. No delegate
in this repository can execute or verify that toolchain: the `atomic-executor` Bash allowlist
is `poetry run`/`npx`/`pwsh`/`git`, and `bats`/`kcov` are not installed on the host. The
authoritative verification is a green `_shell-coverage.yml` run on `ubuntu-latest`, which only
the orchestrator drives. The fix is therefore applied directly and verified via a CI dispatch,
consistent with the orchestrator's shell-QC gate role for this feature (the same path used for
the earlier SC1091 correction).

## Findings addressed

- REM-1 (Blocking): Bash line coverage for `scripts/bash/shell-qc.sh` and
  `scripts/bash/shell_qc_lib.sh` reported 0.00% (`lines-valid="0"`). Root cause: the per-run
  `kcov` invocation passed `--cobertura-only`, which suppresses the per-run coverage database
  that `kcov --merge` consumes, so the merged report contained no source data
  (`<source>not set/</source>`, zero classes). This defect pre-existed in the removed
  `shell_qc.py` and was faithfully reproduced by the parity requirement.
- REM-2 (Major, same root cause): the `Bash coverage (lines): NN.N%` summary never printed on
  CI because the merged report is written to `<out>/kcov-merged/cov.xml`, not the
  `<out>/cov.xml` path the summary read.

## Changes

1. `scripts/bash/shell_qc_lib.sh` (`run_test_coverage`): removed `--cobertura-only` from the
   per-run `kcov` invocation so each run writes a full coverage database; after `kcov --merge`,
   copy `<out>/kcov-merged/cov.xml` to the canonical `<out>/cov.xml` and read that path for the
   summary.
2. `tests/shell/test_shell_qc_commands.bats`: replaced the `--cobertura-only` assertion with a
   regression guard asserting `--cobertura-only` is absent and per-run `kcov --include-pattern=`
   is present.

## Verification

- Local: `shfmt -d` clean; `bash scripts/bash/shell-qc.sh check` exit 0; file <= 500 lines.
- CI: `_shell-coverage.yml` dispatched against the post-fix head; the merged `cov.xml` must
  report `lines-valid > 0` and the summary line must print. Recorded in the checkpoint
  `remediation_loop` and re-audited by `feature-review` (R4).
