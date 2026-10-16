# Remediation Inputs — Issue #928 (re-audit after remediation cycle 1)

Timestamp: 2026-10-16T05-53
Source: feature-review re-audit of branch `bug/subagentstop-hook-uncaught-error-exits-1-928`, head `b222a6baf6dbe42f86a352938a3e8518ca1fedc0`, full branch diff against `origin/main`.
Base for diffs: `5bc97774b8322e57abb94dfac3cd0a000a136c5b` (merge base with `origin/main`; branch 0 commits behind).

Review-Verdict: AWAITING_CI

One finding gates the review. It is CI-dependent and needs no code change. No finding is classified `autonomous`. Remediation cycle 1 resolved CR-N1, CR-N2, CR-N3, and CR-N4; CR-N5 is accepted as a design choice; CR-N6 is resolved.

Audit artifacts that produced the findings:
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/policy-audit.2026-10-16T05-53.md` (PA-B1, PA-N6 to PA-N10)
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/code-review.2026-10-16T05-53.md` (CR-B1, CR2-N1 to CR2-N5)
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/feature-audit.2026-10-16T05-53.md` (FA-B1; AC14 PARTIAL, AC15 UNVERIFIED)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (regenerated 2026-10-16 05:51:13 UTC, head `b222a6ba`)

## Remediation-required findings

### F1 — PA-B1 / CR-B1 / FA-B1: PowerShell coverage for six changed hooks not in the local report (AC14 coverage clause)

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: awaited workflow `ci.yml`, job `poshqc / PowerShell QC` (windows coverage job, artifact `poshqc-test-results`) on the PR head; no PR exists for the branch at 2026-10-16T05-53, and the local report was produced by a run scoped to two test folders. The ci-main baseline for the six absent files is 98.06% to 100.00%, so no defect is indicated.
- Files: `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `.claude/hooks/validate-required-artifact-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/subagentstop-envelope.ps1` (absent from `artifacts/pester/powershell-coverage.xml`).
- Rules: `.claude/rules/general-unit-test.md` (line coverage >= 85%; no regression on changed lines); `spec.md` AC14 and AC15.
- Resolution path: wait path, not a remediation task. Open the PR, then at S9 read the `poshqc-test-results` JaCoCo report and record, for each of the ten changed `.claude/hooks` files, line coverage >= 85% and not below the baseline in `evidence/remediation-baseline/poshqc-coverage.2026-10-16T04-51.md`, plus the repo-wide LINE figure >= 85%. Check off AC14 and AC15 after the CI green gate.

## Non-blocking findings (Info; no remediation cycle required)

- N1 (CR2-N1): `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1:117-134`. The U1-ST rows were not run against the pre-fix validators; their detection of a removed `catch` is inferred from the harness structure (`:72-92`). Optional: record a one-off run against the pre-fix tails in `evidence/regression-testing/`.
- N2 (CR2-N2): `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1:9-11`. Uneven rewrap (68 then 112 characters). Optional reflow of the `.DESCRIPTION` paragraph.
- N3 (CR2-N3): `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/spec.md:6-7`. `Last Updated` and `Version` not updated after cycle-1 edits; update at the next spec edit (for example the S9 check-off).
- N4 (CR2-N4): `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/issue.md:5`. Status path names `docs/features/active/subagentstop-hook-uncaught-error-exits-1/`, which does not exist.
- N5 (CR2-N5, outside item scope): `.claude/hooks/validate-bash.ps1:441-443`. Top-level payload read and decision call have no handler; an unhandled error would exit 1, on which PreToolUse fails open. Do not change in this item; the orchestrator decides whether to file a follow-up.

## Accepted (not a finding)

- CR-N5: the report-and-halt sentence remains a literal in `validate-discovery-artifact-gate.ps1:253`, `validate-pr-author-output.ps1:129`, `validate-prd-feature-output.ps1:118`, and `validate-task-researcher-output.ps1:290`, matching each file's convention and avoiding a wider overlap with #929.

## Do not do

- Do not change `.claude/hooks/validate-feature-review-coverage.ps1` or its mirror.
- Do not change `.codex/`, the Codex bundle, `.claude/settings.json`, agent frontmatter, or `core.json`.
- Do not add a whole-script `try` or a `trap`.
- Do not create temporary files in tests.
- Any `.claude` edit must be mirrored byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/`.

## Exit gate

Re-audit is not required for F1: it closes at S9 when the PR-head CI coverage artifact confirms the ten changed files and the repo-wide figure, and AC14 and AC15 are checked off.
