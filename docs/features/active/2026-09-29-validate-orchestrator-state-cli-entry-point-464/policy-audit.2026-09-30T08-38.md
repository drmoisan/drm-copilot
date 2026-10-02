# Policy Audit: Issue #464 (validate-orchestrator-state CLI entry point)

- Timestamp: 2026-09-30T08-38
- Branch: `bug/validate-orchestrator-state-cli-entry-point-exec-464`
- HEAD: `7cf9f1f5`
- Diff base: merge-base `5b09b53899ac9dad870f855cbcc359098266e213` (integration branch `epic/orchestrator-state-contract-correctness-integration`)
- Work mode: `full-bug` (AC source: `spec.md`; `issue.md` AC section cross-checked)
- Scope: full branch diff against the resolved base (Scope Invariant applied)

## Rejected Scope Narrowing

None. The caller prompt asked for weighing of six review points; these are additional review points and do not narrow scope. All are addressed below in addition to the full-diff audit.

## Executive Summary

Overall verdict: PASS. Blocking findings: 0. Non-blocking findings: 4 (PA-1 to PA-4, see Section 8).

Against the merge-base the diff lists 62 paths. Classification:

- Issue #464 production/test/documentation (8 paths; identical to the change set of commits after pre-execution HEAD `bd8de655`):
  - `scripts/dev_tools/validate_orchestrator_state_cli.py` (A, 173 lines)
  - `scripts/dev_tools/_orchestrator_state_remediation_loop.py` (A, 101 lines)
  - `scripts/dev_tools/validate_orchestrator_state.py` (M, 434 lines after)
  - `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` (A, 371 lines)
  - `.claude/rules/orchestrator-state.md` (M) and mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/`
  - `.claude/skills/orchestrate/SKILL.md` (M) and mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/`
- Release-bump files inherited through the branch base (6 paths; not authored by this work): `.codex/config.toml`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, `packages/mcp-server/package.json`, `packages/mcp-server/package-lock.json`. Verified with `git diff --stat 5b09b538 bd8de655`: exactly these six paths, 8 insertions and 8 deletions, from commit `ac1166db` (PR #785).
- Feature-folder documents and evidence (issue.md, spec.md, plan, 45 evidence files in the branch diff, research).

Languages with changed files: Python only. No TypeScript, PowerShell, or C# source changed (the only `.json`/`.toml` changes are release-version fields).

## 1. General Unit Test Policy Compliance

| # | Policy | Verdict | Evidence |
|---|---|---|---|
| 3 | Test file location mirrors source | PASS | `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` mirrors `scripts/dev_tools/`. No colocated tests. |
| 4 | No temporary files, subprocesses, or wall-clock use in unit tests | PASS | Test file read in full: the single I/O seam `read_checkpoint_text` is replaced with in-memory stubs via `monkeypatch`; no `tmp_path`, `tempfile`, `subprocess`, `time`, or `sleep`. |
| 5 | Arrange-Act-Assert structure, descriptive names, docstrings | PASS | Every test carries `# Arrange` / `# Act` / `# Assert` markers (or `# Act / Assert` for `pytest.raises`) and a docstring; assertions carry messages where non-obvious. |
| 13 | Coverage exclusion policy (no production file excluded) | PASS | `pyproject.toml` not in the diff. `[tool.coverage.run] omit` lists only test and site-packages paths; the `if __name__ == .__main__.:` `exclude_lines` entry is pre-existing and line-pattern scoped, not a file exclusion. |

### 1.1 Coverage Thresholds

Python (Pytest with coverage; branch-capable). Thresholds per `.claude/rules/quality-tiers.md`: line >= 85%, branch >= 75%, no regression on changed lines. Coverage verdicts are in Section 5.

### 1.2 Coverage Baseline and Post-Change Evidence

Artifact: `artifacts/python/lcov.info` (present; parsed by reviewer, it matches the executor's recorded `TOTAL` Stmts 16974 and Branch 6110 from `pytest-final.md`).

- Python baseline coverage artifact: `pytest-dev-tools-baseline.md` under `evidence/baseline/` (TOTAL Cover 91%)
- Python post-change coverage artifact: `artifacts/python/lcov.info` and `pytest-dev-tools-after.md` (TOTAL Cover 92%)
- TypeScript baseline coverage artifact: not applicable (no TypeScript files changed)
- TypeScript post-change coverage artifact: not applicable (no TypeScript files changed)
- PowerShell baseline coverage artifact: not applicable (no PowerShell files changed)
- PowerShell post-change coverage artifact: not applicable (no PowerShell files changed)
- Per-language comparison summary: Python only; baseline 91% versus post-change 92% TOTAL, see Section 1.2.1

Regression on changed lines: the moved block remains exercised through `validate_orchestrator_state_text` by the unchanged `test_validate_orchestrator_state_remediation_loop.py`. The `if __name__ == "__main__":` guard lines in the validator are excluded by the pre-existing `exclude_lines` pattern and are protected by the `runpy` guard test, not by the coverage number.

The stricter 90% new-file rule quoted in the agent procedure text is superseded by the uniform 85/75 rule in `.claude/rules/quality-tiers.md`; both new files exceed 90% line coverage in any case.

#### Coverage Metrics Table

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 4 (3 production, 1 test) | 31 CLI and remediation-loop tests; 5718 passed in full suite | PASS | 91% TOTAL | 92% TOTAL | CLI 97.0% line / 100% branch; remediation loop 97.2% line / 87.5% branch |
| TypeScript | 0 | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 91% TOTAL; Post-change: 92% TOTAL; Change: +1 percentage point, no regression; New/changed-code coverage: 97.0% line and 100% branch for the CLI module, 97.2% line and 87.5% branch for the remediation loop module; Disposition: PASS; Evidence: `artifacts/python/lcov.info`, `evidence/baseline/pytest-dev-tools-baseline.md`, `pytest-dev-tools-after.md`, `coverage-new-modules.md`

## 2. General Code Change Policy Compliance

| # | Policy | Verdict | Evidence |
|---|---|---|---|
| 1 | Tonality (`.claude/rules/tonality.md`) in added docs, docstrings, and evidence | PASS | Added rules paragraph (`## Bare-Module CLI Contract`), SKILL.md replacements, module docstrings, and evidence files use factual, literal wording. No humor, hyperbole, or metaphor found on read-through of all added prose. |
| 2 | 500-line file cap | PASS | `wc -l` executed by reviewer: validator 434, CLI 173, remediation loop 101, CLI test 371. Validator headroom 66 lines (was 492, research figure). |
| 6 | Fail fast; no broad catch-all | PASS | `main` catches only `(OSError, UnicodeDecodeError)` around the read; `test_main_does_not_swallow_unexpected_read_errors` proves `RuntimeError` propagates. |
| 7 | Mirror parity for `.claude/**` edits | PASS | Reviewer ran `cmp` on both pairs: both report identical. Executor `git hash-object` evidence: rules pair `371943249df506815c6f145a52b4ef0b18ca2131`, skill pair `90716dea99c3d8bd7294db7793da153c6ddac832`. |
| 8 | Skill bundle contract (#762): no invocation form added to any `SKILL.md` | PASS | SKILL.md diff shows two replacements, each a citation of `.claude/rules/orchestrator-state.md`; no `python -m` or `scripts/` form. `skill-bundle-contract-test.md`: 1 passed. |
| 9 | Hooks and `.claude/lib` untouched; no Python leg added to any hook (`enforcement-hooks-must-not-use-python`) | PASS | `git diff --name-only 5b09b538 HEAD -- .claude/hooks .claude/lib .agents` printed nothing (reviewer-executed). The only Python files changed are under `scripts/dev_tools/` and `tests/`. |
| 10 | Issue #769 files untouched; dispatcher untouched | PASS | The diff inventory contains no `validate_orchestration_artifacts.py` and no #769 paths. `evidence/other/scope-forbidden-surfaces.md` reports both anchored checks empty. |
| 12 | Evidence Location Compliance | PASS | See the Evidence Location Compliance section below. |
| 14 | `.claude/rules/**` edit authorization | PASS | See review point 3 in Section 9. |

### Evidence Location Compliance

No violations. `validate_evidence_locations.py --root .` exited 0 with no findings. All evidence lies under `evidence/baseline`, `evidence/other`, `evidence/qa-gates`, `evidence/regression-testing`. No file in the branch diff is under `artifacts/baselines`, `artifacts/qa`, `artifacts/evidence`, or `artifacts/coverage`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event was needed.

## 3. Language-Specific Code Change Policy Compliance

Python (`.claude/rules/python.md`): applicable. The changed Python files are the CLI module, the remediation-loop module, the validator diff, and the CLI test file.

| # | Policy | Verdict | Evidence |
|---|---|---|---|
| 11a | Format and lint (Black, Ruff) | PASS | Reviewer re-ran check-only `ruff check` (All checks passed) and `black --check` (4 files unchanged) on the four Python files. |
| 11b | Type checking (Pyright) | PASS | Pyright was not re-run by the reviewer; relied on `pyright-final.md` (0 errors, 0 warnings, 0 informations) from executor `qa-loop-summary.md`. |

TypeScript, PowerShell, and C#: not applicable; zero changed files for each language.

## 4. Language-Specific Unit Test Policy Compliance

Python (`.claude/rules/python.md` unit test section): applicable.

| # | Policy | Verdict | Evidence |
|---|---|---|---|
| 11c | Unit tests (pytest) | PASS | 31 CLI and remediation-loop tests passed in the reviewer run. Executor evidence: `qa-loop-summary.md` records one clean pass (Black 534 unchanged, Ruff clean, Pyright 0/0/0, pytest 5718 passed, 6 skipped). |

TypeScript (Jest), PowerShell (Pester), and C# (MSTest): not applicable; zero changed files for each language.

## 5. Test Coverage Detail

Artifact: `artifacts/python/lcov.info`. Coverage verification is explicit PASS for Python, the only language with changed files.

| Scope | Line | Branch | Threshold | Verdict |
|---|---|---|---|---|
| Repo-wide (`scripts/dev_tools`) | 15847 / 16974 = 93.4% | 5275 / 6110 = 86.3% | line >= 85%, branch >= 75% | PASS |
| New: `validate_orchestrator_state_cli.py` | 32 / 33 = 97.0% | 4 / 4 = 100% | line >= 85%, branch >= 75% | PASS |
| New: `_orchestrator_state_remediation_loop.py` | 35 / 36 = 97.2% | 14 / 16 = 87.5% | line >= 85%, branch >= 75% | PASS |
| Modified: `validate_orchestrator_state.py` | 168 / 170 = 98.8% | 80 / 82 = 97.6% | line >= 85%, branch >= 75%, no regression | PASS |

Regression on changed lines: baseline `TOTAL` Cover 91% (`pytest-dev-tools-baseline.md`) versus 92% after (`pytest-dev-tools-after.md`).

## 6. Test Execution Metrics

- Reviewer run: 31 CLI and remediation-loop tests passed; `ruff check` clean; `black --check` 4 files unchanged.
- Executor run (`qa-loop-summary.md`): one clean pass; Black 534 files unchanged, Ruff clean, Pyright 0 errors / 0 warnings / 0 informations, pytest 5718 passed, 6 skipped.
- Reviewer re-ran the three reproductions and observed exit 2, 0, and 1 as recorded (see PA-3).

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Black (format) | PASS (4 changed Python files unchanged by `black --check`) |
| Ruff (lint) | PASS (All checks passed) |
| Pyright (type check) | PASS (recorded by executor in `pyright-final.md`; not re-run by reviewer) |
| Pytest | PASS (31 targeted tests in reviewer run; 5718 passed, 6 skipped in executor full run) |
| Evidence location validator | PASS (`validate_evidence_locations.py --root .` exit 0) |

## 8. Gaps and Exceptions

| ID | Severity | Finding |
|---|---|---|
| PA-1 | Non-blocking | The branch carries six release-bump paths from PR #785 that are absent from the epic integration branch (diffing against `origin/epic/...` printed the same extra paths). A PR to the epic will show these paths even though #464 did not author them, and the spec states no version bump is part of this fix. Mitigation: sync the integration branch with `main`, or state in the PR description that the six paths are inherited. |
| PA-2 | Non-blocking | Acceptance `1 passed` for the mirror-parity test and suite-level `0 failed` hold only for isolated runs because of issue #510. Independent `cmp` and `git hash-object` checks substitute. CI is expected to pass; confirm on the PR. |
| PA-3 | Non-blocking | The spec Test Strategy items "Integration scenario to retest" and "Manual verification notes" remain `[ ]` in `issue.md` and `spec.md`, although the executed before/after reproductions and dispatcher comparison exist in evidence. These are not acceptance criteria. Reviewer also re-ran the three reproductions and observed exit 2, 0, and 1 as recorded. |
| PA-4 | Non-blocking | Plan acceptance items P8-T10 and P7-T1 could not be satisfied as written in this environment. Plan text should reference the recorded merge-base and account for #510 in future plans (process note, not a defect in the change set). |

Remediation triggers: none. No blocking findings; no `remediation-inputs` artifact is required.

## 9. Summary of Changes

Review points requested by the caller:

1. Deviation 2 (P8-T10, eleven paths instead of eight). Not blocking. Verified independently: `git diff --stat 5b09b538 bd8de655` (merge-base to pre-execution HEAD) lists exactly six release-bump paths (three inside the plan's `scripts tests .claude extensions` pathspec, three outside it), and `git diff --name-only bd8de655 HEAD -- . ':!docs'` lists exactly the eight expected paths. The literal plan acceptance was not met; the substitute anchored check is sound and was disclosed in `plan.*.md` `## Implementation Notes` item 3 and in `scope-change-set.md`. Residual concern recorded as non-blocking finding PA-1 (PR diff will carry the release bump).
2. Deviation 1 (local #510 workaround). Not blocking. `test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates the filesystem and fails when the gitignored `.claude/state/python-batch-budget.*.json` exists. The executor moved the file aside for the pytest process only and restored it; `git hash-object` `a3b7c655...` was identical before and after, so nothing was deleted. The issue is independent of #464 code, CI has no such file, and byte identity of both mirrored pairs was independently confirmed by `git hash-object` and by reviewer `cmp`. Recorded as non-blocking finding PA-2.
3. Operator-approved edits to `.claude/rules/orchestrator-state.md` and mirror. Limited to the plan. The rules diff contains exactly two hunks: the P5-T1 parenthetical rewording (`accepted by the dispatcher orchestrator-state subcommand and by the bare-module CLI; MCP parameter ...`) and the P5-T2 `## Bare-Module CLI Contract` section (one paragraph: literal command with five flags, dispatcher remains available, exit-code contract). No other rule text changed. The mirror is byte-identical. No other file under `.claude/rules/` changed.
4. No hook, #769 file, or dispatcher change; no Python leg added. Verified (Section 2 rows 9 and 10).
5. File sizes and coverage. Verified (Section 2 row 2 and Section 5).
6. Tonality. Verified (Section 2 row 1).

## 10. Compliance Verdict

PASS. Blocking findings: 0. Non-blocking findings: 4 (PA-1 to PA-4). All coverage verdicts for Python (the only language with changed files) are explicit PASS. No remediation required.

## Appendix A: Test Inventory

| Test file | Status | Notes |
|---|---|---|
| `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` | Added (371 lines) | 21 tests: valid checkpoint, `--require-complete`, error ordering, five flags true and all-false, missing path, `PermissionError`, `IsADirectoryError`, non-UTF-8, unexpected exception propagation, unknown flag, missing positional, empty and non-JSON text, dispatcher exit-code parity, `runpy` guard test. |
| `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py` | Unchanged | Passes unchanged; exercises the moved remediation-loop block. |

## Appendix B: Toolchain Commands Reference

- `black --check` on the four changed Python files
- `ruff check` on the four changed Python files
- `pyright` (executor evidence `pyright-final.md`)
- `pytest` with coverage (executor evidence `pytest-final.md`; reviewer targeted run of 31 tests)
- `python scripts/dev_tools/validate_evidence_locations.py --root .`
- `git diff --stat 5b09b538 bd8de655` and `git diff --name-only bd8de655 HEAD -- . ':!docs'` for scope verification
- `cmp` and `git hash-object` for mirror parity
