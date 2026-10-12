# Code Review (minor-audit) - Issue #884, bash half

- Timestamp: 2026-10-12T14-00
- Branch: bug/compute-concurrency-batches-coverage-884
- Reviewed head: 3fc983f03 (base: main, merge-base 72ba7058b)
- Review mode: minor-audit (small path)
- Scope: full branch diff against origin/main: 18 files, 590 insertions. One production-adjacent file added, `tests/shell/compute_concurrency_batches_cli.bats` (50 lines). All other changes are feature-folder documents and evidence. `.claude/lib/bash/compute-concurrency-batches.sh` is unchanged (verified by `git diff --stat origin/main...HEAD`, which lists no path outside `tests/shell/` and the feature folder).

## Executive Summary

No blocking findings. Two non-blocking informational observations are recorded (CR-1, CR-2). The change adds five bats cases covering usage and error paths of the script, with no production change.

Verdict: PASS. Blocking findings: 0.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (CR-1) | `tests/shell/compute_concurrency_batches_cli.bats` | usage-error test cases | The tests assert the usage line and the `Options:` marker through `${lines[0]}` and `$output`. Because bats `run` merges stderr into `$output`, the tests do not distinguish which stream carries the usage text. The file header states this explicitly. The AC-3 clause covers stdout/stderr/exit-code stability; stream separation is not asserted. | Optional: use `run --separate-stderr` for the three usage-error cases. Not required by any AC. | No AC requires stream separation. | File read; file header note. |
| Non-blocking (CR-2) | `tests/shell/compute_concurrency_batches_cli.bats` | first assertion in `assert_usage_text` | The assertion `[ "${lines[0]}" = "$USAGE_LINE" ]` hard-codes the usage string. A wording change in the script will require a test update. | No action required. | Accepted trade-off for a CLI-contract test. | File read. |

## Review Checks

| Check | Result | Evidence |
|---|---|---|
| File size <= 500 lines | PASS | 50 lines |
| Location mirrors production (`tests/shell/`) | PASS | `tests/shell/compute_concurrency_batches_cli.bats` |
| No temporary files | PASS | Inputs are literals; `bats-file-no-temp-file-check` evidence plus read of the file show no `mktemp`, `BATS_TMPDIR`, or redirect to a file |
| Determinism | PASS | No clock, RNG, sleep, or network use; fixed literal arguments |
| Arrange-Act-Assert and naming | PASS | Descriptive `@test` names; `setup()` arranges; `run` acts; assertions follow; shared `assert_usage_text` helper avoids duplication |
| Style consistency | PASS | 4-space indentation matches the existing `tests/shell/*.bats` files (shfmt discovery does not include `#!/usr/bin/env bats` files, so the tab rule is not applied by tooling) |
| Scenario coverage | PASS | `--help`, `-h`, `--keys` and `--max-concurrency` missing a value, unknown option; exit codes 0 and 2 |
| Production code unchanged | PASS | Blob `aa456265f35b756f606264cf4f203a4f6089bd1b` equal to baseline (script-unchanged-check evidence) |
| Simplicity / separation of concerns | PASS | Test-only change; no production refactor |

## Verification Limits

No shfmt, shellcheck, bats, or kcov run was performed by this reviewer (tooling restrictions). Toolchain results are taken from CI run 38281234678 on head 9292d3d2b: job "Shell Coverage (Bats + kcov)" and steps "Run shell-qc check (shfmt diff + shellcheck)" and "Run shell-qc test with coverage" concluded success. Commit 3fc983f03 is documentation-only after the CI-tested SHA.

## Verdict

PASS. Blocking findings: 0. Non-blocking: CR-1, CR-2.
