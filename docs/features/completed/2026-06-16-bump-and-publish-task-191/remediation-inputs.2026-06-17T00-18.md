# Remediation Inputs: bump-and-publish-task (Issue #191)

**Entry Timestamp:** 2026-06-17T00-18
**Feature Folder:** `docs/features/active/2026-06-16-bump-and-publish-task-191`
**Base Branch:** `main`
**Head SHA:** `62e7f291c69d4debce2aca82115c7907af7df295`
**Source audit artifacts:**
- `docs/features/active/2026-06-16-bump-and-publish-task-191/policy-audit.2026-06-17T00-18.md`
- `docs/features/active/2026-06-16-bump-and-publish-task-191/code-review.2026-06-17T00-18.md`
- `docs/features/active/2026-06-16-bump-and-publish-task-191/feature-audit.2026-06-17T00-18.md`

## Reason for Remediation

The feature-review cycle produced one Blocking finding and one material PARTIAL finding. All six acceptance criteria pass at the code level; remediation addresses policy/evidence gaps that block merge, not unmet acceptance criteria.

## Enumerated Fix List

### F1 — BLOCKING: satisfy `modified-workflow-needs-green-run`

- **File / path:** `.github/workflows/publish-mcp-npm.yml`
- **Finding:** The branch diff modifies a path under `.github/workflows/**`. The `modified-workflow-needs-green-run` policy (`.claude/skills/feature-review-workflow/SKILL.md`) requires evidence of a green workflow run whose head SHA equals the current branch head before merge. No such evidence exists; the branch head is not pushed to any remote (`git branch -r --contains 62e7f29` returns empty), so no PR-context or `workflow_dispatch` run against the head can be present.
- **Expected behavior:** A green workflow run against branch head `62e7f29...` (or the head SHA current at remediation time) is recorded as remediation evidence. A green `workflow_dispatch` run against the branch head satisfies the rule, addressing the chicken-and-egg case where the tag-triggered publish workflow cannot run in PR context.
- **Required actions:**
  1. Push branch `feature/bump-and-publish-task-191` to origin.
  2. Trigger or obtain a green run of the affected workflow against the branch head. Because `publish-mcp-npm.yml` triggers only on `push` of `mcp-server-v*` tags, either (a) add a `workflow_dispatch` trigger for verification and run it against the branch head, or (b) obtain an equivalent green run exercising the changed steps (provenance publish path / id-token permission) against the head SHA.
  3. Record the run in remediation evidence under `<FEATURE>/evidence/qa-gates/` including the workflow name, head SHA, run URL, and `conclusion: success`.
- **Verification commands / checks:**
  - `actionlint .github/workflows/publish-mcp-npm.yml` (must remain EXIT 0).
  - Confirm recorded green-run evidence head SHA matches the branch head reported by `git rev-parse HEAD`.
- **Validator:** `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` implements the trigger-path and evidence-presence logic; the green-run evidence must make this validator pass.

### F2 — PARTIAL: provide a measured branch-coverage metric for new PowerShell code

- **File / path:** `scripts/dev-tools/Invoke-FullRelease.ps1` (new-code coverage); coverage artifacts `artifacts/pester/fullrelease-coverage.xml`, `artifacts/pester/powershell-coverage.xml`.
- **Finding:** New-code line coverage is 88.0% (>= 85% PASS), but the Pester/CoverageGutters output emits no BRANCH counter (0 BRANCH counters confirmed in both coverage XML files). The uniform >= 75% branch-coverage threshold (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`) cannot be numerically verified. The coverage-delta evidence argues by branch enumeration that all decision branches are exercised, but this is not a measured metric.
- **Expected behavior:** Either (a) produce a coverage report that emits a numeric branch-coverage metric for `Invoke-FullRelease.ps1` and confirm it is >= 75%, or (b) record an explicit, policy-sanctioned exception documenting that the Pester coverage tooling does not emit a branch counter, with the per-branch enumeration as the supporting argument, and obtain sign-off that line coverage plus branch enumeration is the accepted standard for this repository's PowerShell tooling.
- **Verification commands / checks:**
  - `mcp__drm-copilot__run_poshqc_test` and inspect `artifacts/pester/powershell-coverage.xml` / targeted `fullrelease-coverage.xml` for a `type="BRANCH"` counter.
  - If no branch metric is emitted, record the tooling-limitation exception in `<FEATURE>/evidence/qa-gates/coverage-delta.md`.

## Do-Not-Do List

- Do not narrow the audit scope to any plan/task/phase subset; scope is the full branch diff vs `main`.
- Do not weaken or modify any policy document under `.claude/rules/` or `.github/instructions/`.
- Do not lower the coverage thresholds in `quality-tiers.md` or `general-unit-test.md`.
- Do not remove or disable the `modified-workflow-needs-green-run` rule or its validator.
- Do not mock raw `git`/`npm` directly; preserve the wrapper-seam mocking pattern.
- Do not introduce temporary files in tests or commit a permanent dot-source coverage harness.
- Do not push the `mcp-server-v*` release tag or publish any artifact as part of remediation verification; verification must not produce immutable Marketplace/npm releases.
- Do not write evidence to non-canonical paths; all evidence goes under `<FEATURE>/evidence/<kind>/`.
- Do not alter the six acceptance criteria or their checked-off state (all PASS).

## Handoff

Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, the next step is for `atomic-planner` to author `remediation-plan.2026-06-17T00-18.md` in this feature folder conforming to `.claude/skills/atomic-plan-contract/SKILL.md`, followed by `atomic-executor` preflight and execution, then a `feature-review` reaudit at the exit timestamp. This artifact is the cycle-entry input for that chain.
