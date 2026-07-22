# Feature Audit: native-bash-toolchain-no-poetry (Issue #393) — Remediation Re-Audit (R4)

- Auditor: feature-review agent (Claude Code)
- Date: 2026-07-21T20-09

## Scope and Baseline

- Base branch (resolved): `main` (`origin/main`)
- Merge-base SHA: `193864d87f3dfcc2e2a18987ec2ecc592dfea93b`
- Branch head SHA: `5a5d08ff49b914faed1790dbdca0e403d1552253` (branch `drm-copilot-wt-2026-07-21T17-20`, 3 commits in range: `145dae53` feature, `a87ff2e1` remediation fix, `5a5d08ff` remediation docs)
- Diff range: `193864d87f3dfcc2e2a18987ec2ecc592dfea93b..5a5d08ff49b914faed1790dbdca0e403d1552253` (66 files, +3697/-564)
- Evidence sources: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (refreshed by this reviewer this session against head `5a5d08ff`; the pre-existing pair was stale at head `145dae53`), the feature `evidence/` tree including the remediation evidence, reviewer re-runs, GitHub CLI verification of runs 29878850555 and 29878851590, and a direct parse of the downloaded `shell-coverage` CI artifact.
- Work mode: `full-feature` (persisted marker `- Work Mode: full-feature` in `issue.md`). Acceptance-criteria sources per contract: `spec.md` and `user-story.md`. The caller prompt named `issue.md` as the AC source; the AC1-AC9 text is identical across all three files, so this resolution changes no criterion. `spec.md` carries the ACs in a non-checkbox mapping table; per the tracking skill that format is not reformatted, and checkbox tracking lives in `user-story.md` (mirrored in `issue.md`).
- Prior cycle: `feature-audit.2026-07-21T19-39.md` evaluated AC1-AC9 all PASS with one Blocking policy finding outside the AC set (bash coverage measurement). That finding was remediated in `a87ff2e1` and is verified resolved this cycle.

## Acceptance Criteria Inventory

Source: `user-story.md` `## Acceptance Criteria` (checkbox format) and `spec.md` `## Acceptance Criteria Mapping (AC1-AC9)` (table format). 9 criteria.

1. AC1: Native bash wrapper `scripts/bash/shell-qc.sh` provides `check`, `format`, `test` invoking shfmt/shellcheck/bats directly; no Python, no Poetry.
2. AC2: `test` supports a coverage mode running bats under kcov, emitting a Cobertura `cov.xml`, preserving prior behavior.
3. AC3: Wrapper reproduces prior discovery rules (roots, suffix/shebang, exclusions, test dirs).
4. AC4: `shell_qc.py` removed; all five Poetry console-script entries removed from `pyproject.toml`.
5. AC5: No component of the shell toolchain (local or CI) invokes Python or Poetry.
6. AC6: Both workflows invoke the native wrapper with no Poetry install or `poetry run`.
7. AC7: `.claude/rules/shell.md` exists, path-scoped, documenting toolchain/invocation/coverage policy.
8. AC8: Native wrapper covered by bats tests under `tests/shell/`.
9. AC9: Green CI run against the branch head verifies the modified workflows.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC1 | PASS | `scripts/bash/shell-qc.sh` dispatches `check`/`format`/`test [--coverage]`/`--help` (103 lines); library invokes tools directly via `resolve_tool`. No `python`/`poetry` invocation on the shell path. Reviewer re-ran `check` (exit 0), `--help` (exit 0), and `test` (exit 0, exact skip marker) this session; CI ran all subpaths green at head `5a5d08ff`. |
| AC2 | PASS (prior caveat resolved) | `run_test_coverage` runs kcov per test dir (without `--cobertura-only` after remediation `a87ff2e1`), merges runs, copies the merged report to the canonical `<out>/cov.xml`, and prints the summary. CI run 29878850555 (head `5a5d08ff`, success) uploaded the `shell-coverage` artifact containing `cov.xml` at the canonical root (byte-identical to `kcov-merged/cov.xml`, verified by this reviewer) and its log prints `Bash coverage (lines): 88.2%`. The prior cycle's caveat — empty merged report and non-printing summary — is resolved; the coverage numbers are real (194/220 lines). |
| AC3 | PASS | `discover_shell_scripts`/`is_shell_script`/`extract_shebang_command` implement roots `tools/`+`scripts/`, `.sh` suffix or bash/sh shebang (env, `env -S`, uppercase forms), the five excluded dirs, and `LC_ALL=C sort -u` ordering; `find_bats_test_dirs` checks `tests/shell` then `tests/bash`. All contract points asserted by the 11-test discovery suite, green on CI at head `5a5d08ff` (run log `ok 34`-`ok 44`). |
| AC4 | PASS | `scripts/dev_tools/shell_qc.py` deleted in the diff (D, -495); `pyproject.toml` contains no `shell-qc`/`shell_qc` console-script entries (all five removed). Unchanged since the prior cycle. |
| AC5 | PASS | No Python/Poetry invocation in `shell-qc.sh`, `shell_qc_lib.sh`, or `_shell-coverage.yml`; `fix_all_branches.py` repoints all three shell command lists to `bash scripts/bash/shell-qc.sh <cmd>`; `.vscode/tasks.json` shell tasks use `command: bash`; `_build-check.yml`'s remaining pip/venv usage belongs to the Python wheel smoke, not the shell path. Unchanged since the prior cycle (remediation touched only the kcov argv and report path). |
| AC6 | PASS | `_shell-coverage.yml` has no Poetry steps and runs `bash scripts/bash/shell-qc.sh test --coverage`; `_build-check.yml` runs the native `--help` smoke. Both executed green against the current head (AC9 runs). |
| AC7 | PASS | `.claude/rules/shell.md` exists with frontmatter path scoping; content covers toolchain order, native invocation/WSL/CI environment, discovery contract, coverage expectations (kcov line-only, uniform >= 85% line threshold, no bash branch gate), CI-vs-local drift, and coding standards. The documented coverage behavior (`cov.xml` under `artifacts/pester/kcov`, summary line printed) is now observably true on CI after the remediation. Byte-identical extension mirror unchanged. |
| AC8 | PASS | `tests/shell/test_shell_qc_discovery.bats` (11 tests) and `tests/shell/test_shell_qc_commands.bats` (18 tests) exercise discovery, check, format, test, coverage, missing-tool, and usage contracts via checked-in stubs; the coverage-argv test now guards the remediation (asserts `--cobertura-only` absent). CI run 29878850555 reports 44 `ok`, zero failures. Measured line coverage of the code under test: 88.6% (`shell-qc.sh`), 87.6% (`shell_qc_lib.sh`). |
| AC9 | PASS | Two green `workflow_dispatch` runs against the current head `5a5d08ff`, independently verified by this reviewer via `gh run view`: 29878850555 (Shell Coverage (reusable)) and 29878851590 (Build Check (reusable)), both `status: completed`, `conclusion: success`, `headSha: 5a5d08ff49b914faed1790dbdca0e403d1552253`. Satisfies `modified-workflow-needs-green-run` for the post-remediation head (the prior cycle's runs at `145dae53` were superseded by the remediation commits, as the prior remediation-inputs anticipated). |

## Summary

- 9 of 9 acceptance criteria PASS. The feature delivers the native bash toolchain with verified behavior parity, complete consumer migration, documented rule coverage, and green CI runs against the current branch head.
- The prior cycle's Blocking policy finding (bash line coverage unmeasured) and Major finding (summary line not printing) are resolved by remediation commit `a87ff2e1` and independently verified: bash line coverage 88.2% repo-wide, 88.6% / 87.6% for the two new production files (uniform >= 85% line gate met; no bash branch gate per `.claude/rules/shell.md`), canonical `cov.xml` present, summary line printing on CI.
- Zero Blocking findings remain. One new Minor code-review observation (CR-1, error suppression on the canonical-path copy) and carried Info items do not gate the PR.
- Go/no-go: **go for PR authoring.** See `policy-audit.2026-07-21T20-09.md` (verdict: COMPLIANT) and `code-review.2026-07-21T20-09.md`.

### Acceptance Criteria Status
- Source: docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/user-story.md (checkboxes) and docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/spec.md (non-checkbox mapping table)
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

Per the acceptance-criteria-tracking protocol:

- `user-story.md` `## Acceptance Criteria`: all 9 items were already checked off during the prior review cycle and remain `[x]` (verified this session: 9 of 9 checked). No new check-offs required.
- `issue.md` `## Acceptance Criteria (early draft)`: all 9 items already `[x]` (verified this session).
- `spec.md`: no checkbox AC section exists (mapping table format); statuses are recorded in this audit instead of reformatting the source file, per the no-reformat rule.
