# Remediation Inputs: #1050 feature review (opening review)

- Timestamp: 2026-11-19T11-55
- Branch: `feature/push-down-ci-workflows-per-ecosystem-pack-1050` at `f4cf77c6a374e3c8369d6e6abe5506c3d135d5a6`
- Base: `origin/epic/shared-agent-harness-layer-integration`, merge base `021a52e74999d17c6ae67ed7a32c14958448ceab`

Review-Verdict: AWAITING_CI

Remediation-Path: full

## Source audit artifacts

- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/policy-audit.2026-11-19T11-55.md` (PA-B1 open, awaiting CI)
- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/code-review.2026-11-19T11-55.md` (no blocking row; three Minor and five Info rows)
- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/feature-audit.2026-11-19T11-55.md` (23 PASS; S17 and U4 pending CI)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `f4cf77c6a`)

## Pending-CI findings

### PA-B1 - modified-workflow-needs-green-run (S17 / U4)

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: The branch adds four workflow_call-only harness workflows and edits the workflows README; no PR exists yet, so no green CI run on the head and no scratch-destination dispatch of the rendered caller exist. The awaited runs are the repository workflow CI (with CI Required Gate) on the PR head and the plan task P3-T5 dispatch per pack; no branch change can produce them.
- Finding-Scope: contained
- File/location: `.github/workflows/harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, `harness-dotnet.yml`, `.github/workflows/README.md`; `spec.md` S17 and `user-story.md` U4.
- Action (item's own orchestrator run):
  1. Open the PR into `epic/shared-agent-harness-layer-integration` through `Agent(pr-author)`.
  2. Run plan task [P3-T5]: render a reference-mode caller for each language pack, dispatch it once in a scratch destination, and record the check list (the pack check and `CI Required Gate`) under `evidence/` with clock-read timestamps.
  3. At S9, when `ci_gate.conclusion` is `success` on the PR head, check off S17 in `spec.md` and U4 in `user-story.md` from the item worktree, push, and re-run the CI gate so that `ci_gate.head_sha` equals the final head.
- Verification: a green `CI` run on the final PR head, the [P3-T5] dispatch evidence for every pack, and S17 and U4 checked.

## Non-blocking items

- Code review Minor: `scripts/ci/Set-CiRequiredChecks.ps1` line 171 lists rulesets without `--paginate`, so a same-name ruleset outside the first page is not detected before the POST. Add pagination and a two-page Pester case; keep the bundle copy byte-identical. Related to S14; can be fixed inside this item before merge. It does not affect the verdict.
- Code review Minor: `Invoke-GhExe` merges standard error into the parsed output; a `gh` warning with exit 0 produces a JSON parse error instead of the command's message.
- Code review Minor: `harness-powershell.yml` copy mode assumes a top-level `tests` directory; document the layout requirement or fail with a clear message.
- Code review Info: .NET Cobertura totals are summed across test projects; the `withCiWorkflows` marker invariant has no bundle-wide assertion; the Pester mock omits the unused `GhCommand` parameter.

## Do not do

- Do not check off S17 or U4 before the CI evidence exists.
- Do not edit `.github/workflows/ci.yml`, any `_*.yml` workflow, or any hook to satisfy this finding.
- Do not alter or delete existing evidence files; record new results as new files.
