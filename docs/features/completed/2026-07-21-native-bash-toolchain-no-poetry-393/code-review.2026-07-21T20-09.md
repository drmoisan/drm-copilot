# Code Review: native-bash-toolchain-no-poetry (Issue #393) — Remediation Re-Audit (R4)

- Reviewer: feature-review agent (Claude Code)
- Date: 2026-07-21T20-09
- Base: `main` @ merge-base `193864d87f3dfcc2e2a18987ec2ecc592dfea93b`
- Head: `drm-copilot-wt-2026-07-21T17-20` @ `5a5d08ff49b914faed1790dbdca0e403d1552253`
- Scope: full branch diff (66 files, +3697/-564; 3 commits)
- Prior review: `code-review.2026-07-21T19-39.md` (1 Blocking, 1 Major, 2 Minor, 4 Info)

## Executive Summary

This re-review covers the full feature-vs-base diff after the cycle-1 remediation commit `a87ff2e1` and the docs commit `5a5d08ff`. The feature replaces the Python/Poetry-driven shell quality-control toolchain with a native bash wrapper (`scripts/bash/shell-qc.sh`) and function library (`scripts/bash/shell_qc_lib.sh`), removes `scripts/dev_tools/shell_qc.py` and its five Poetry console-script entries, repoints all consumers, and adds a path-scoped `.claude/rules/shell.md` with a byte-identical extension mirror.

The prior review's Blocking finding (kcov coverage pipeline produced an empty merged report) and Major finding (coverage summary line never printed on CI) are both resolved by the remediation and independently verified by this reviewer:

- The per-run kcov invocation no longer passes `--cobertura-only`, so per-run coverage databases feed `kcov --merge`. The merged Cobertura from CI run 29878850555 (headSha = current branch head, conclusion = success) records 88.2% bash line coverage (194/220) with per-file rates of 88.6% (`shell-qc.sh`) and 87.6% (`shell_qc_lib.sh`) — both above the uniform 85% line gate.
- The merged report is copied to the canonical `<out>/cov.xml` (verified byte-identical to `kcov-merged/cov.xml` in the downloaded artifact), and the CI run log prints `Bash coverage (lines): 88.2%`.
- The bats coverage-argv test was updated into a regression guard: it asserts `--cobertura-only` is absent and `kcov --include-pattern=` is present, with an inline rationale comment referencing issue #393.

The remediation is minimal, well-commented, and format/lint clean (reviewer re-ran `shell-qc check`, exit 0). One new Minor finding is recorded (CR-1, error suppression on the canonical-path copy); it does not gate the PR. The prior review's Minor and Info items carry forward unchanged except the spurious `#ISO-8601` autoclose candidate, which is resolved in the refreshed PR context.

Recommendation: no code changes required. Go for PR authoring.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (was Blocking) | scripts/bash/shell_qc_lib.sh | `run_test_coverage` (lines 328-355) | Prior cycle: CI coverage pipeline yielded no line-coverage data (merged report `lines-valid="0"`). Remediation `a87ff2e1` removed `--cobertura-only` from the per-run kcov invocation with an explanatory comment. Verified: run 29878850555 merged cov.xml records 88.2% (194/220); per-file 88.6% / 87.6%, both >= 85%. | None; resolved. | Uniform coverage gate now met with a real numeric at the current head. | Downloaded CI artifact `shell-coverage` (id 8514019872) of run 29878850555; evidence/qa-gates/bash-coverage-fixed.2026-07-21T23-56.md. |
| Resolved (was Major) | scripts/bash/shell_qc_lib.sh | `run_test_coverage` (lines 349-354, 358-361) | Prior cycle: `Bash coverage (lines): NN.N%` never printed because the merged report landed at `kcov-merged/cov.xml` while the parser read `<out>/cov.xml`. Remediation copies the merged report to the canonical path before the summary parse. Verified: run 29878850555 log prints `Bash coverage (lines): 88.2%`; artifact contains `cov.xml` at the root, byte-identical to `kcov-merged/cov.xml`. | None; resolved. | The advertised summary output is now observable on CI, matching spec AC2's verifiable outcome. | Run 29878850555 step log; artifact diff performed by this reviewer. |
| Minor (new) | scripts/bash/shell_qc_lib.sh | line 353 (`cp -f "$out_dir/kcov-merged/cov.xml" "$out_dir/cov.xml" \|\| true`) | The or-true suffix suppresses a failed copy. If `cp` fails (for example, permissions or disk full), the run still exits 0 and the summary parse silently no-ops, hiding the failure. The preceding `[[ -f ... ]]` guard makes this unlikely, and `print_coverage_summary` tolerating an absent file is pre-existing design, but the suppression is not strictly necessary. | Optional hardening in a later touch: drop `\|\| true` and let a copy failure surface (or capture `rc` and warn). Not required for this branch. | General code-change policy prefers failing fast over silently ignoring errors; the observable symptom (summary line absent) is detectable but indirect. | scripts/bash/shell_qc_lib.sh lines 349-354; `git show a87ff2e1`. |
| Minor (carried) | tests/shell/test_shell_qc_commands.bats | `setup`/`teardown` and the coverage-path test | The coverage-path test directs production output to `artifacts/pester/kcov-bats` (gitignored) through the documented `SHELL_QC_KCOV_OUT_DIR` seam and `teardown` removes it. Production-code output during a unit test, not test-created temporary fixture files. | Acceptable as-is; stricter isolation optional later. | The no-temporary-files rule targets fixture creation at test time; exercising the production output-directory contract is the behavior under test. | tests/shell/test_shell_qc_commands.bats lines 15-27, 118-133. |
| Minor (carried) | scripts/bash/shell_qc_lib.sh | `run_test` vs `run_test_coverage` failure semantics | `run_test` runs every test directory even when an earlier one fails; `run_test_coverage` stops at the first failing directory. Intentional parity with the removed module, documented in spec and comments. | None. Keep the documented behavior. | Behavior parity was an explicit acceptance constraint. | spec.md `test` / `test --coverage` sections; shell_qc_lib.sh comments. |
| Info (carried) | .claude/skills/feature-review-workflow/SKILL.md (reference target) | `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` | The skill names a supporting validator script that does not exist in the repository. The `modified-workflow-needs-green-run` rule was evaluated manually this cycle (again). | Track separately: add the validator or update the skill text. Pre-existing, outside this feature's scope. | A named enforcement artifact that is absent weakens the deterministic second line of defense the rule promises. | `ls scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` fails (re-verified this session). |
| Info (carried) | quality-tiers.yml (absent) | repo root | `.claude/rules/quality-tiers.md` declares `quality-tiers.yml` at repo root as the tier source of truth; the file does not exist on `main` or this branch. Uniform coverage thresholds apply regardless. | Track separately as a repo hygiene item (pre-existing). | Rule text and repo state disagree. | `ls quality-tiers.yml` fails (re-verified this session). |
| Info (carried) | docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/issue.md | line 5 | Status line names `docs/features/active/native-bash-toolchain-no-poetry/` while the actual folder is `2026-07-21-native-bash-toolchain-no-poetry-393`. Cosmetic. | Optional correction during any later doc touch. | Path references in scoping docs should match the canonical folder. | issue.md line 5 vs. actual folder path. |
| Info (resolved) | artifacts/pr_context.summary.txt | Close candidates section | Prior cycle: the author-asserted autoclose list contained a spurious `#ISO-8601` placeholder alongside `#393`. The PR context refreshed this session lists only `#393`. | None; resolved. | Prevents an invalid closing reference in the PR description. | artifacts/pr_context.summary.txt (refreshed 2026-07-21T20-09 session), Close candidates section. |

## Remediation Diff Review (a87ff2e1)

- `scripts/bash/shell_qc_lib.sh` (+9/-2 in `run_test_coverage`): the flag removal carries a three-line rationale comment; the canonical-path copy carries a rationale comment naming the downstream consumers (summary parse, Coverage Gutters). shfmt-clean and shellcheck-clean (reviewer re-run, exit 0). File grew from 354 to 363 lines, still under the 500-line limit.
- `tests/shell/test_shell_qc_commands.bats` (+4/-1): the assertion flip is a true regression guard (asserts absence of the defective flag plus presence of the include-pattern argv), not a weakened test; the surrounding assertions (exclude-pattern, test-dir, merge invocation, run-dir cleanup) are unchanged. File is 168 lines.
- `5a5d08ff` adds only `remediation-plan.2026-07-21T19-39.md` and `evidence/qa-gates/bash-coverage-fixed.2026-07-21T23-56.md` (docs; tone-compliant; evidence paths canonical).
- No production file other than `shell_qc_lib.sh` changed between the prior audit head `145dae53` and the current head (`git diff --name-status a87ff2e1..5a5d08ff` shows docs only; `145dae53..a87ff2e1` shows the lib, the bats file, and docs).

## Design and Implementation Notes (non-findings)

- Exit-code integrity under `set -e` remains correct: every legitimately-non-zero tool call is captured, and the wrapper source-guard re-exits the captured code.
- The kcov argv change trades slightly larger per-run output directories for a correct merge; the per-run directories are still deleted unconditionally via `rm -rf "$runs_dir"` on success and failure, so no waste persists.
- The measured 88.2% includes the two pre-existing demo scripts at 100%; the gate-relevant per-file numbers for the new files were parsed individually rather than inferred from the aggregate.
- Byte-identical contracts (skip markers, missing-tool block) consumed by `fix_all.py` are untouched by the remediation, as the remediation plan required.

## Toolchain Verification (reviewer re-runs, check-only, this session)

| Check | Command | Result |
|---|---|---|
| Bash format+lint | `bash scripts/bash/shell-qc.sh check` | exit 0 (4 scripts discovered) |
| Bash help smoke | `bash scripts/bash/shell-qc.sh --help` | exit 0 |
| Bash test (local, bats absent) | `bash scripts/bash/shell-qc.sh test` | exit 0, exact skip marker printed |
| File-size limit | `wc -l` on wrapper, lib, both bats suites | 103 / 363 / 168 / 84 — all under 500 |
| Python format | `poetry run black --check .` | exit 0 (329 files unchanged) |
| Python lint | `poetry run ruff check .` | exit 0 |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 |
| CI green runs | `gh run view 29878850555 / 29878851590` | both `conclusion: success`, headSha = `5a5d08ff` (current branch head) |
| Coverage numeric | downloaded artifact 8514019872, parsed cov.xml | 88.2% overall; 88.6% / 87.6% per new file; canonical cov.xml byte-identical to kcov-merged/cov.xml |
| Summary line | `gh run view 29878850555 --log` grep | `Bash coverage (lines): 88.2%` present |
