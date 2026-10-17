# Code Review: subagentstop-envelope-feature-review-coverage (Issue #896) - Remediation Cycle 1 Reaudit

- Timestamp: 2026-10-12T07-59 (local host time)
- Reviewer: feature-review agent
- Branch: `bug/subagentstop-envelope-feature-review-coverage-exec-896` (local `exec-896-ac7`, HEAD `4c324c570`)
- Base: `origin/epic/subagentstop-envelope-integration` @ `486e8c06e` (merge-base `486e8c06e`)
- Scope: full three-dot diff (136 files, 24 commits). Code files: 6 PowerShell production files, 6 production mirrors, 10 PowerShell test files, 1 Python test file, 3 skill/agent texts with mirrors, 2 pack manifests. The remaining files are documentation and evidence under the feature folder.
- Prior review: `code-review.2026-10-12T11-25.md` (no Blocking finding; Minor 2, Nit 2, Info 4).

## Executive Summary

The remediation cycle changed no code. `git diff --name-status f1dc01c3c..HEAD` lists 18 added files, all under `docs/features/active/subagentstop-envelope-feature-review-coverage-896/`, and `git diff --name-only 63513ce0d..HEAD` filtered to paths outside the feature folder prints nothing. The code findings of the prior review therefore stand unchanged; they are restated below so this artifact is complete on its own.

The remediation evidence was reviewed for correctness. The Python coverage run used branch measurement (`--cov-branch`; JSON `meta.branch_coverage` is true), wrote both reports from this worktree (no LCOV source record resolves outside the worktree), and excludes `tests/` from the denominator (zero `tests/` source records), consistent with the Coverage Exclusion Policy. The baseline argument (identical production denominator and numerator) is supported by two committed checks: the `.py` diff against base lists only the test module, and that module imports only `__future__`, `pathlib`, and `pytest` at head and at base.

No Blocking code finding. Typed-Python review: the changed Python file (`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`) is a test module; Black, Ruff, and Pyright are clean (`evidence/qa-gates/remediation-python-*.2026-10-12T07-50.md`), and the reviewer rerun of the six push-down contract modules passed 87 of 87. No finding.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/validate-feature-review-coverage.ps1` | lines 177-182, 191 | When a coverage block carries both a repairable and a non-repairable reason, the message ends with "The subagent cannot repair this condition; report it in the final response and stop." while the hook blocks again for the repairable reason. Carried from the prior review. | When both flags are true, scope the clause to the non-repairable reasons, and add an `E4-TR10` (c) assertion on the wording. | The current wording gives two conflicting instructions in one message. | `E4-TR10c` asserts only `Ok = $false` for the mixed case. |
| Minor | `.codex/hooks/validate-feature-review-coverage.ps1` | `Test-LanguageCoverageRow`, lines 185-186 | The corpus-gate relaxations applied to the Claude rules were not applied to the Codex hook, so the two gates can return different verdicts for the same policy audit. Carried from the prior review. | Record a follow-up to apply FIX-2 to the Codex function, or document the divergence in the Codex hook help. | The issue's impact statement is that the same review can pass on one surface and fail on the other. | `evidence/other/corpus-rule-changes.2026-10-12T06-02.md` FIX-2. |
| Nit | `.codex/hooks/validate-feature-review-coverage.ps1` | line 280 | `Test-Path -Path` and `Get-Content -Path` interpret wildcard characters in the `CLAUDE.md` path. Carried from the prior review. | Use `-LiteralPath` for both calls. | Consistency with the Claude reader. | `validate-feature-review-coverage-metrics.ps1:25` uses `-LiteralPath`. |
| Nit | `.claude/hooks/feature-review-coverage-thresholds.ps1` | lines 17-18 | An extra blank line was added between the help block and the function. Carried from the prior review. | Remove it in the next change to all four byte-identical copies. | Diff hygiene across pinned copies. | Diff hunk `@@ -15,20 +15,28 @@`. |
| Info | `.claude/hooks/validate-feature-review-coverage-rules.ps1` | lines 60-67, 144-155 | Rule relaxations beyond the spec's listed changes, mandated by the operator's corpus gate. Carried from the prior review. | Add a one-line spec note that the corpus amendment authorizes them. | Traceability between spec and code. | `E4-CORPUS-1`, `E4-CORPUS-2`. |
| Info | `.claude/hooks/validate-feature-review-coverage-metrics.ps1` | line 56 | The Claude reader opens `CLAUDE.md` relative to the working directory; the Codex hook joins it to `Get-RepoRoot`. Unchanged from base. Carried from the prior review. | Consider resolving the root explicitly in a later change. | Parity of floor source location. | Codex hook line 278. |
| Info | `.claude/hooks/validate-feature-review-coverage-rules.ps1` | `Get-ChangedLanguageSet`, lines 79-96 | The language set is read only from `- <path> (+a/-d)` lines in the truncated changed-file overview of the PR-context summary. On this branch the Python test file is not listed there, so the gate does not require a Python coverage row although Python changed. This is the mechanism that let PA-1 reach the review stage. Carried from the prior review. | Record a follow-up to read the full changed-file list from the appendix name-status block. | The gate can under-detect changed languages on large diffs. | Reviewer count this cycle: 10 overview lines with a code extension, none `.py`; appendix lists `M tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`. |
| Info | `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | `E4-TR4` | The base-side failure of `E4-TR4` occurs at parameter binding rather than at the unreadable-file behavior. Carried from the prior review. | None required. | AC-24 requires a failing base run, which is met. | `evidence/regression-testing/fail-first.2026-10-12T00-05.md`. |
| Info | `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/remediation-preflight.2026-10-12T12-00.md` | filename and line 3 | New this cycle. The filename timestamp `12-00` disagrees with the body `Timestamp: 2026-10-12T07-46`; the prior review artifacts and the remediation plan use UTC (`11-25`) while the convention requires local time. Policy-audit finding PA-5. | Select review artifacts by reported path; read local time for later artifacts. | Lexical ordering of artifacts no longer matches creation order. | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` line 49; `date` and `date -u` on the host report 07:57 and 11:57. |

## Positive Observations

- The remediation stayed within its stated scope: evidence files only, no source, test, configuration, or policy change, as `evidence/qa-gates/evidence-locations-and-scope.2026-10-12T07-50.md` records and the reviewer delta check confirms.
- The coverage evidence records LCOV and JSON figures that corroborate each other (93.80% and 88.10% from both sources), plus a foreign-path check, which removes the risk of reading a stale or foreign artifact.
- The remediation plan stated a fail-closed disposition rule for below-threshold figures and test failures in advance (PD2, PD3); neither condition arose.

## Verdict

No Blocking code-review finding. Minor: 2. Nit: 2. Info: 5.
