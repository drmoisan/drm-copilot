# Remediation Inputs — Issue #928 (re-audit after remediation cycle 2)

Timestamp: 2026-10-16T06-36
Source: feature-review re-audit of branch `bug/subagentstop-hook-uncaught-error-exits-1-928`, head `2f6b960051a92c85a3fcc7ea8c85dd89fea79014`, full branch diff against `origin/main`.
Base for diffs: `5bc97774b8322e57abb94dfac3cd0a000a136c5b` (merge base with `origin/main`; branch 0 commits behind).

Review-Verdict: AWAITING_CI

One finding gates the review. It is CI-dependent and needs no code change. No finding is classified `autonomous`. Remediation cycle 2 resolved CR2-N3 and CR2-N4. CR-N5, CR2-N1, CR2-N2, and CR2-N5 are recorded as accepted orchestrator decisions.

Audit artifacts that produced the findings:
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/policy-audit.2026-10-16T06-36.md` (PA-B1, PA-N11, PA-N12)
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/code-review.2026-10-16T06-36.md` (CR-B1, CR3-N1, CR3-N2)
- `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/feature-audit.2026-10-16T06-36.md` (FA-B1; AC14 PARTIAL, AC15 UNVERIFIED)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (regenerated 2026-10-16 06:34:57 UTC, head `2f6b9600`)

## Remediation-required findings

### F1 — PA-B1 / CR-B1 / FA-B1: PowerShell coverage for six changed hooks not in the local report (AC14 coverage clause)

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: awaited workflow `ci.yml`, job `poshqc / PowerShell QC` (windows coverage job, artifact `poshqc-test-results`) on the PR head; no PR exists for the branch at 2026-10-16T06-36, and the local report was produced by a run scoped to two test folders. The ci-main baseline for the six absent files is 98.06% to 100.00%, so no defect is indicated.
- Files: `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `.claude/hooks/validate-required-artifact-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/subagentstop-envelope.ps1` (absent from `artifacts/pester/powershell-coverage.xml`).
- Rules: `.claude/rules/general-unit-test.md` (line coverage >= 85%; no regression on changed lines); `spec.md` AC14 and AC15.
- Resolution path: wait path, not a remediation task. Open the PR, then at S9 read the `poshqc-test-results` JaCoCo report and record, for each of the ten changed `.claude/hooks` files, line coverage >= 85% and not below the baseline in `evidence/remediation-baseline/poshqc-coverage.2026-10-16T04-51.md`, plus the repo-wide LINE figure >= 85%. Check off AC14 and AC15 after the CI green gate.

## Non-blocking findings (Info; no remediation cycle required)

- N1 (CR3-N1): `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/remediation-plan.2026-10-16T06-40.md` (filename, line 6). The stamp `2026-10-16T06-40` is later than the commit that added the file (`cd709e54b`, 06:06 UTC) and later than the evidence it governed (06-23 to 06-25). This review set (`06-36`, true UTC write time) therefore sorts before the plan by name. No change needed for this item.
- N2 (CR3-N2): `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/issue.md:11`. `Last Updated: 2026-10-15` was left unchanged when line 5 was edited on 2026-10-16. Optional: update it in the S9 check-off commit.

## Accepted (not a finding; orchestrator decisions)

- CR-N5: literal report-and-halt sentence at `validate-discovery-artifact-gate.ps1:253`, `validate-pr-author-output.ps1:129`, `validate-prd-feature-output.ps1:118`, `validate-task-researcher-output.ps1:290` (per-file convention; #929 overlap).
- CR2-N1: U1-ST statement-terminating rows are characterization rows (validators already blocked; fail-before not obtainable).
- CR2-N2: uneven rewrap at `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1:9-11` is within the line limit; left to avoid re-churning the verified AC4/AC9 hunk.
- CR2-N5: `.claude/hooks/validate-bash.ps1:441-443` exit-1 fail-open is unrelated to this item (different hook, event, and contract; file not edited by this item).

## Do not do

- Do not change `.claude/hooks/validate-feature-review-coverage.ps1` or its mirror.
- Do not change `.codex/`, the Codex bundle, `.claude/settings.json`, agent frontmatter, or `core.json`.
- Do not add a whole-script `try` or a `trap`.
- Do not create temporary files in tests.
- Any `.claude` edit must be mirrored byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/`.

## Exit gate

Re-audit is not required for F1: it closes at S9 when the PR-head CI coverage artifact confirms the ten changed files and the repo-wide figure, and AC14 and AC15 are checked off.
