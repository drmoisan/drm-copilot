# Remediation Inputs: #1050 feature review (re-review after the advisory-fix pass)

- Timestamp: 2026-11-19T13-45
- Branch: `feature/push-down-ci-workflows-per-ecosystem-pack-1050` at `fccc2fbcdea8947cc11cba2e063bddfe5f566981`
- Base: `origin/epic/shared-agent-harness-layer-integration`, merge base `021a52e74999d17c6ae67ed7a32c14958448ceab`

Review-Verdict: AWAITING_CI

Remediation-Path: full

## Source audit artifacts

- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/policy-audit.2026-11-19T13-45.md` (PA-B1 open, awaiting CI)
- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/code-review.2026-11-19T13-45.md` (no blocking row; the three previous Minor rows resolved; seven Info rows)
- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/feature-audit.2026-11-19T13-45.md` (23 PASS; S17 and U4 pending CI)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `fccc2fbcd`, generated 2026-11-19 13:44:34 UTC; CI status not available)

## Pending-CI findings

### PA-B1 - modified-workflow-needs-green-run (S17 / U4)

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: The branch adds four workflow_call-only harness workflows (harness-powershell.yml changed again in commit 30280af22) and edits the workflows README; no PR exists yet, so no green CI run on the head and no scratch-destination dispatch of the rendered caller exist. The awaited runs are the repository workflow CI (with CI Required Gate) on the PR head and the plan task P3-T5 dispatch per pack; no branch change can produce them.
- Finding-Scope: contained
- File/location: `.github/workflows/harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, `harness-dotnet.yml`, `.github/workflows/README.md`; `spec.md` S17 and `user-story.md` U4.
- Action (item's own orchestrator run):
  1. Open the PR into `epic/shared-agent-harness-layer-integration` through `Agent(pr-author)`.
  2. Run plan task [P3-T5]: render a reference-mode caller for each language pack, dispatch it once in a scratch destination, and record the check list (the pack check and `CI Required Gate`) under `evidence/` with clock-read timestamps.
  3. At S9, when `ci_gate.conclusion` is `success` on the PR head, check off S17 in `spec.md` and U4 in `user-story.md` from the item worktree, push, and re-run the CI gate so that `ci_gate.head_sha` equals the final head.
- Verification: a green `CI` run on the final PR head, the [P3-T5] dispatch evidence for every pack, and S17 and U4 checked.

## Resolved since the previous review

- Ruleset list pagination in `scripts/ci/Set-CiRequiredChecks.ps1`: resolved (`--paginate --slurp`, flattened pages; second-page test with recorded fail-before run).
- `gh` standard-error handling in `Invoke-GhExe`: resolved (`ErrorOutput` separated; failure messages name the call).
- Copy-mode `tests` directory assumption in `harness-powershell.yml`: resolved (guard with named message and `exit 1`; README bullet; contract negative case).

## Non-blocking items

- Code review Info: the minimum GitHub CLI version for `gh api --slurp` is not documented; an older CLI fails explicitly before any write.
- Code review Info: the copy-mode guard is pinned by text only; S17 dispatches reference mode and does not execute it.
- Code review Info (carried over): .NET Cobertura totals are summed across test projects; the `withCiWorkflows` marker invariant has no bundle-wide assertion; the Pester mocks omit the unused `GhCommand` parameter.

Cost-benefit note (OD-4): none of the Info items changes behavior or safety; fixing them would add a remediation cycle and another full gate run for documentation-level gains, so they are not recommended as blockers for this item.

## Do not do

- Do not check off S17 or U4 before the CI evidence exists.
- Do not edit `.github/workflows/ci.yml`, any `_*.yml` workflow, or any hook to satisfy this finding.
- Do not alter or delete existing evidence files; record new results as new files.
