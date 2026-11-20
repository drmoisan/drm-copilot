# Feature Audit: native-bash-toolchain-no-poetry (Issue #393)

- Auditor: feature-review agent (Claude Code)
- Date: 2026-07-21T19-39

## Scope and Baseline

- Base branch (resolved): `main` (`origin/main`)
- Merge-base SHA: `193864d87f3dfcc2e2a18987ec2ecc592dfea93b`
- Branch head SHA: `145dae538d732a908d6e1e0e8eb3d5a053e8a7d5` (branch `drm-copilot-wt-2026-07-21T17-20`, one commit in range)
- Diff range: `193864d87f3dfcc2e2a18987ec2ecc592dfea93b..145dae538d732a908d6e1e0e8eb3d5a053e8a7d5` (59 files, +2891/-564)
- Evidence sources: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (both generated 2026-07-21 23:29 UTC against the current head; verified fresh), the feature `evidence/` tree, reviewer re-runs, and GitHub CLI verification of the two `workflow_dispatch` runs.
- Work mode: `full-feature` (persisted marker `- Work Mode: full-feature` in `issue.md`). Acceptance-criteria sources per contract: `spec.md` and `user-story.md`. The caller prompt named `issue.md` as the AC source; the AC1-AC9 text is identical across all three files, so this resolution changes no criterion. Documented assumption: `spec.md` carries the ACs in a non-checkbox mapping table (`## Acceptance Criteria Mapping (AC1-AC9)`); per the tracking skill, that format is not reformatted, and checkbox check-off is performed in `user-story.md` (and mirrored in `issue.md` for consistency with its existing partial check-offs).

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
| AC1 | PASS | `scripts/bash/shell-qc.sh` dispatches `check`/`format`/`test [--coverage]`/`--help` (103 lines); library invokes tools directly via `resolve_tool`. Reviewer grep of both new files plus the shell path finds no `python`/`poetry` invocation; reviewer ran `check` (exit 0) and `--help` (exit 0) locally; CI ran all subpaths green. |
| AC2 | PASS (with recorded caveat) | `run_test_coverage` runs `kcov --cobertura-only` per test dir with the documented include/exclude patterns, merges runs, and always removes `.kcov_runs`; CI run 29877012724 executed it green and uploaded `cov.xml` inside the `shell-coverage` artifact (`kcov-merged/cov.xml`, 35 files, `if-no-files-found: error` satisfied). Prior behavior is preserved byte-for-byte, including the pre-existing quirk that the merged report lands under `kcov-merged/` and aggregates zero lines, so the summary line does not print. The quirk is handled as the coverage Blocking finding (policy audit Section 8 / remediation inputs), not an AC2 failure, because AC2's contract is "emits a Cobertura cov.xml, preserving the prior behavior" — both verified true against the `main` baseline artifact (run 29735688734, identical structure and values). |
| AC3 | PASS | `discover_shell_scripts`/`is_shell_script`/`extract_shebang_command` implement roots `tools/`+`scripts/`, `.sh` suffix or bash/sh shebang (env, `env -S`, uppercase forms), the five excluded dirs, and `LC_ALL=C sort -u` ordering; `find_bats_test_dirs` checks `tests/shell` then `tests/bash`. All contract points asserted by the 11-test discovery suite (green on CI) against checked-in fixtures, including exact 5-line sorted output. |
| AC4 | PASS | `scripts/dev_tools/shell_qc.py` deleted in the diff (D, -495); reviewer grep of `pyproject.toml` for `shell-qc|shell_qc` returns no matches (all five entries removed: `shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`, `dev.shell-qc`). |
| AC5 | PASS | Reviewer grep across `scripts/bash/shell-qc.sh`, `scripts/bash/shell_qc_lib.sh`, and `_shell-coverage.yml` finds no Python/Poetry invocation; `fix_all_branches.py` repoints all three shell command lists to `bash scripts/bash/shell-qc.sh <cmd>`; `.vscode/tasks.json` shell tasks now use `command: bash`; `_build-check.yml`'s remaining pip/venv usage belongs to the Python wheel smoke (`atomic-executor --help`), not the shell path. Executor reference sweep evidence: qa-gates/reference-sweep.2026-07-21T18-45.md (exit 0). |
| AC6 | PASS | Diff of `_shell-coverage.yml` removes Set up Python, Install Poetry, venv cache, and both poetry install steps; run step is `bash scripts/bash/shell-qc.sh test --coverage`. `_build-check.yml` adds the native `--help` smoke step and drops the console-script smoke. Both executed green against the branch head (AC9 runs). |
| AC7 | PASS | `.claude/rules/shell.md` exists with frontmatter `paths: **/*.sh, **/*.bats, scripts/bash/**, tests/shell/**`; content covers toolchain order with restart-loop rule, native invocation/WSL/CI environment, the discovery contract, coverage expectations (kcov line-only, uniform >= 85% line threshold, no bash branch gate), CI-vs-local drift with CI-canonical resolution, and coding standards. Byte-identical mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md` verified with `cmp` (the pre-existing bundle contract test enforces it). |
| AC8 | PASS | `tests/shell/test_shell_qc_discovery.bats` (11 tests) and `tests/shell/test_shell_qc_commands.bats` (18 tests) exercise discovery, check, format, test, coverage, missing-tool, and usage contracts via checked-in stubs; CI run 29877012724 reports `1..44` with 44 `ok` and zero failures (29 new + 15 pre-existing shell tests). Note: functional coverage is complete; the kcov numeric measurement gap is tracked as the policy-audit Blocking finding, not an AC8 gap. |
| AC9 | PASS | Two green `workflow_dispatch` runs against head `145dae53`, independently verified by the reviewer via `gh run view`: 29877012724 (Shell Coverage (reusable)) and 29877013754 (Build Check (reusable)), both `status: completed`, `conclusion: success`, `headSha` exactly matching the branch head. Evidence doc: evidence/qa-gates/workflow-dispatch-green-runs.2026-07-21T23-35.md. Satisfies `modified-workflow-needs-green-run` (workflow_dispatch runs qualify per the skill). |

## Summary

- 9 of 9 acceptance criteria PASS. The feature delivers the native bash toolchain with verified behavior parity, complete consumer migration, documented rule coverage, green CI runs against the branch head, and a clean Python toolchain with improved coverage (90.9% lines / 81.6% branches).
- One Blocking policy finding exists outside the AC set: measured bash line coverage for the two new production files is 0.0% because the CI kcov merged report instruments zero lines (identical on the `main` baseline; pre-existing measurement defect preserved by the parity requirement). Fail-closed coverage policy blocks PR readiness until remediated. See `policy-audit.2026-07-21T19-39.md` Section 8 and `remediation-inputs.2026-07-21T19-39.md`.
- Go/no-go: **no-go for PR authoring until the coverage-measurement remediation lands**; all other dimensions are merge-ready.

### Acceptance Criteria Status
- Source: docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/user-story.md (checkboxes) and docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/spec.md (non-checkbox mapping table)
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

Performed by this reviewer per the acceptance-criteria-tracking protocol (evidence before check-off; text preserved; `[ ]` -> `[x]` only):

- `user-story.md` `## Acceptance Criteria`: AC1-AC9 all newly checked off (all were unchecked before this review).
- `issue.md` `## Acceptance Criteria (early draft)`: AC2, AC3, AC6, AC8, AC9 newly checked off (AC1, AC4, AC5, AC7 were already checked by the executor); performed for cross-file consistency since the issue mirror carries identical AC text.
- `spec.md`: no checkbox AC section exists (mapping table format); statuses are recorded in this audit instead of reformatting the source file. The spec's `## Definition of Done` and `## Seeded Test Conditions` checklists are planning checklists, not acceptance criteria, and were left untouched per the no-phantom-criteria rule.
