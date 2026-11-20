# Remediation Inputs: #1050 feature review (remediation cycle 1, R4 re-audit)

- Timestamp: 2026-11-19T14-44
- Branch: `feature/push-down-ci-workflows-per-ecosystem-pack-1050` at `5ab48d8308964a34b7ec79cef4ba7e0a0a8f5261`
- Base: `origin/epic/shared-agent-harness-layer-integration`, merge base `021a52e74999d17c6ae67ed7a32c14958448ceab`; PR #1210

Review-Verdict: AWAITING_CI

Remediation-Path: full

## Source audit artifacts

- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/policy-audit.2026-11-19T14-44.md` (PA-B1 open, awaiting CI)
- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/code-review.2026-11-19T14-44.md` (no blocking row; CI-1 resolved; seven Info rows)
- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/feature-audit.2026-11-19T14-44.md` (25 PASS; 0 UNVERIFIED)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (generated 2026-11-19 14:38:12 UTC at `6db294022`)
- Dispatch evidence: `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/evidence/qa-gates/ci-dispatch.2026-11-19T14-42.md`

## Pending-CI findings

### PA-B1 - modified-workflow-needs-green-run

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: The branch adds four workflow_call harness workflows and harness-python.yml changed in commit 6db294022 after the last completed green pull_request run (44539291819 on 9d75fe2be). The pull_request run on the final head 5ab48d830 is in progress at review time per gh pr view 1210. All five scratch dispatch runs concluded success, so no branch change is needed; only the CI result on the final head is awaited.
- Finding-Scope: contained
- File/location: `.github/workflows/harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, `harness-dotnet.yml`, `.github/workflows/README.md`.
- Action (item's own orchestrator run): at S9, wait for the `pull_request` run on the final PR head to conclude; when `ci_gate.conclusion` is `success` and `ci_gate.head_sha` equals the final head, the item proceeds to merge under the epic's recorded directives.
- Verification: a green `CI` run, including `CI Required Gate`, on the final PR head.

## Resolved since the previous review

- CI-1 (`harness-python.yml` coverage threshold step could not parse the coverage.py JSON report): resolved by commit `6db294022` (`ConvertFrom-Json -AsHashtable`, hashtable access, byte-identical bundle copy, contract test `python harness threshold step parses the report with -AsHashtable` with three negative inputs); Python scratch run 44545593464 at the fixed ref concluded `success`.
- S17 and U4: supported by five successful scratch dispatch runs, confirmed by the reviewer through `gh run view`.

## Non-blocking items

- Code review Info: the cycle-1 phase-gate record stamp was composed before the clock was read; disclosed in `evidence-stamp-correction.2026-11-19T14-32.md` and kept unchanged (append-only).
- Code review Info: the scratch branches were removed, so the caller content cannot be re-read; the run records and referenced harness refs remain.
- Code review Info (carried over): copy-mode guard pinned by text only; no documented minimum `gh` version for `--slurp`; .NET Cobertura totals summed; no bundle-wide marker assertion; type-only contract module at 0%.

Cost-benefit note (OD-4): none of the Info items changes behavior or safety, and fixing them would add a remediation cycle and another full gate run for documentation-level gains, so they are not recommended as blockers for this item.

## Do not do

- Do not edit `.github/workflows/ci.yml`, any `_*.yml` workflow, or any hook to satisfy this finding.
- Do not alter or delete existing evidence files; record new results as new files.
