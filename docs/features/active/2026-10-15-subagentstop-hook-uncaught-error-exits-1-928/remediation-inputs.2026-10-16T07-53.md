# Remediation Inputs — Issue #928 (re-audit after remediation cycle 3)

Timestamp: 2026-10-16T07-53
Source: feature-review re-audit of branch `bug/subagentstop-hook-uncaught-error-exits-1-928`, head `a210f5cf92fbbc09679dab9fa3b2756538b076f0` (code head `b43188f8377b5c2bbbfd5484f52b7fc226876353`), full branch diff against `origin/main`.
Base for diffs: `5bc97774b8322e57abb94dfac3cd0a000a136c5b` (merge base; the branch is 34 ahead and 55 behind `origin/main`).

Review-Verdict: REMEDIATION_REQUIRED

Two findings gate the review. Both concern the state of the local coverage artifacts that the review procedure and the `validate-feature-review-coverage.ps1` SubagentStop gate evaluate. Neither indicates a code or coverage defect: the PR-head CI artifacts pass for both languages. No production, test, or documentation change is required.

The remediation loop guard (three completed attempts) has been reached. If another cycle is not permitted, the orchestrator needs an operator decision: either regenerate the local artifacts outside the loop, or accept the PR-head CI artifacts as the coverage source of record.

Audit artifacts that produced the findings:
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/policy-audit.2026-10-16T07-53.md` (PA-B1, PA-B2, PA-N1, PA-N2)
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/code-review.2026-10-16T07-53.md` (CR4-B1, CR4-B2, CR4-N1, CR4-N2)
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/feature-audit.2026-10-16T07-53.md` (FA-B1, FA-B2; AC1-AC16 PASS)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (regenerated 2026-10-16 07:52:36 UTC, head `a210f5cf9`)

## Remediation-required findings

### F1 — PA-B1 / CR4-B1 / FA-B1: local PowerShell coverage artifact below the repo-wide floor

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: regenerating the local report requires only a full-scope PoshQC coverage run at the code head; no code change, external party, or policy decision is involved.
- File: `artifacts/pester/powershell-coverage.xml` (local; written 2026-10-16 05:38 UTC by a run scoped to `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`).
- Observed: repo-wide LINE 52.00% (6387/12283). Six changed hooks are absent from the report: executor, pr-author, prd-feature, required-artifact, task-researcher, and subagentstop-envelope.
- Context: CI run 38867388618 on `b43188f` (same PowerShell code) reports 90.45% repo-wide (16434/18170) and 98.08%-100.00% for each of the ten changed hooks; all eight new catch lines are covered.
- Rules: `.claude/rules/general-unit-test.md` (line coverage >= 85%); feature-review verification procedure step 3.
- Resolution: run the full-scope PoshQC coverage (`mcp__drm-copilot__run_poshqc_test` with coverage over the full test tree, as CI `poshqc / PowerShell QC` does) at the code head so that `artifacts/pester/powershell-coverage.xml` reflects the whole suite. Record the figures under `evidence/qa-gates/`, then re-run the review.

### F2 — PA-B2 / CR4-B2 / FA-B2: local Python coverage artifact absent

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the artifact is produced by the existing pytest configuration (`addopts` writes `artifacts/python/lcov.info`); one local run at the code head creates it.
- File: `artifacts/python/lcov.info` (absent).
- Observed: the branch changes one Python file, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, a test-support module that `[tool.coverage.run] omit` excludes from measurement.
- Context: CI job 116863252017 on `b43188f` reports TOTAL 17638 statements, 1108 missed (93.72% lines); 6368 branches, 504 partial; the `--min-line 85 --min-branch 75` threshold step passed. The merge-base figures are identical.
- Rules: feature-review verification procedure step 4 (coverage verification is mandatory for all languages with changed files).
- Resolution: run `poetry run pytest --cov --cov-branch` at the code head, record the repo-wide line and branch figures under `evidence/qa-gates/`, then re-run the review.

## Non-blocking findings (Info; no remediation cycle required)

- N1 (PA-N1 / CR4-N1): CI on the final head `a210f5cf9` had 8 of 20 checks pending at 07:50 UTC; `b43188f` was 20 of 20 success. Gate on the final head before DONE.
- N2 (PA-N2 / CR4-N2): the branch is 55 commits behind `origin/main` (`mergeStateStatus: BEHIND`, `MERGEABLE`, no overlapping files). Update from `main` before merge and re-gate.

## Accepted (not a finding; orchestrator decisions)

- CR-N5, CR2-N1, CR2-N2, CR2-N5, CR3-N1, CR3-N2.
- Out-of-loop observation: `.claude/hooks/validate-planner-output.ps1:186` rejects root-level `CITATION:` paths (pre-existing; outside this branch's hunks).

## Do not do

- Do not change production code, tests, or documentation to address F1 or F2.
- Do not change `.claude/hooks/validate-feature-review-coverage.ps1` or its supporting scripts.
- Do not copy or hand-edit coverage files to satisfy the gate; regenerate them with the toolchain.
- Do not add a `tests/` or production path to any coverage exclusion.

## Exit gate

F1 and F2 close when a re-review finds `artifacts/pester/powershell-coverage.xml` at >= 85% repo-wide line coverage, with each changed hook >= 85% and not below baseline, and `artifacts/python/lcov.info` present at >= 85% line and >= 75% branch. Alternatively, they close when the operator records a decision accepting the PR-head CI artifacts as the coverage source of record.
