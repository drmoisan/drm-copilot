# Remediation Inputs — Issue #928

Timestamp: 2026-10-16T03-30
Source: feature-review initial audit of branch `bug/subagentstop-hook-uncaught-error-exits-1-928`, head `20c7a8088093a13f1937a4e75f7ed7f581f76a8b`.
Base for diffs: `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99` (merge base with `origin/main`).

Review-Verdict: AWAITING_CI

One finding gates the review. It is CI-dependent and needs no code change. No finding is classified `autonomous`.

Audit artifacts that produced the findings:
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/policy-audit.2026-10-16T03-30.md` (PA-B1, PA-N1 to PA-N6)
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/code-review.2026-10-16T03-30.md` (CR-B1, CR-N1 to CR-N6)
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/feature-audit.2026-10-16T03-30.md` (FA-B1; AC14 PARTIAL, AC15 UNVERIFIED)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (regenerated 2026-10-16 03:28:12 UTC, head `20c7a808`)

## Remediation-required findings

### F1 — PA-B1 / CR-B1 / FA-B1: PowerShell coverage for six changed hooks not in the local report (AC14 coverage clause)

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: awaited workflow `ci.yml`, job `poshqc / PowerShell QC` (windows coverage job, artifact `poshqc-test-results`) on the PR head; no PR exists at 2026-10-16T03-30 and the local report was produced by a run scoped to two test folders.
- Files: `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `.claude/hooks/validate-required-artifact-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/subagentstop-envelope.ps1` (absent from `artifacts/pester/powershell-coverage.xml`).
- Rules: `.claude/rules/general-unit-test.md` (line coverage >= 85%; no regression on changed lines); `spec.md` AC14 and AC15.
- Resolution path: wait path, not a remediation task. Open the PR, then at S9 read the `poshqc-test-results` JaCoCo report and record, for each of the ten changed `.claude/hooks` files, line coverage >= 85% and not below the baseline in `evidence/baseline/poshqc-coverage.2026-10-16T01-32.md`, plus the repo-wide LINE figure >= 85%. Check off AC14 and AC15 after the CI green gate.

## Related non-blocking findings (for a remediation cycle per operator policy)

These do not gate the review. They are related to the files or behavior of this item and are listed for the orchestrator's remediation cycle.

- N1 (CR-N1, Medium): `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` lines 393-408. U1 injects only a script-terminating `throw`. Add U1 variant rows for `validate-discovery-artifact-gate.ps1` and `validate-pr-author-output.ps1` whose `Read-SubagentStopEnvelope` mock raises a statement-terminating error (for example `[int]::Parse('not-a-number')`), asserting no escaped exception, exit 2, the prefix, and the error text. Basis: `spec.md:63` (inferred, not observed) and `spec.md:289`. Keep U2 unchanged (its table holds hooks, not variants) or extend it so the added rows do not break the set comparison.
- N2 (CR-N2, Low): `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` line 369. Save `$global:LASTEXITCODE` before invocation and restore it in the `finally` block after capturing the exit code.
- N3 (CR-N3, Low): `docs/engineering/claude-code-architecture.md` line 237. Replace "the hook exits with code 1 and the Bash command is rejected" with a description of the `permissionDecision: deny` JSON output (`.claude/hooks/validate-bash.ps1:14-22`) and exit 2 on a dependency load failure (`:437`). `spec.md:279` excluded this line; inclusion is under the related-follow-up policy and requires an orchestrator decision to widen scope.
- N4 (CR-N4, Low): re-wrap the citation sentence at `.claude/hooks/subagentstop-envelope.ps1:12` (and its byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`) and at `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1:9` to the surrounding paragraph width. AC4 permits only a citation diff in the helper; a re-wrap of the same citation stays within that constraint.
- N5 (CR-N5, Info, optional): the report-and-halt sentence is a literal at `validate-discovery-artifact-gate.ps1:253`, `validate-pr-author-output.ps1:129`, `validate-prd-feature-output.ps1:118`, `validate-task-researcher-output.ps1:290`. Optionally define `$script:SubagentStopReportAndHaltLine` in those four files. Do not change `validate-feature-review-coverage.ps1` (AC3). Coordinate with #929 for the task-researcher file.
- N6 (CR-N6, Info): update the branch from `origin/main` (`97559c3e`, PR #943) before opening the PR; no path overlaps.

## Do not do

- Do not change `.claude/hooks/validate-feature-review-coverage.ps1` or its mirror.
- Do not change `.codex/`, the Codex bundle, `.claude/settings.json`, agent frontmatter, or `core.json`.
- Do not add a whole-script `try` or a `trap`.
- Do not create temporary files in tests.
- Any `.claude` edit must be mirrored byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/`.

## Exit gate

Re-audit with the count of gating findings at zero once the PR-head CI coverage artifact confirms F1; non-blocking items N1-N5 recorded as resolved or explicitly deferred.
