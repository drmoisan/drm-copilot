# Remediation Inputs: pr-author docs-only exemption hardening (#927), review 2026-10-16T05-09

Review-Verdict: REMEDIATION_REQUIRED

- Branch: `bug/pr-author-docs-only-exemption-hardening-927` at `e4521e5a8e1ef211d8e81e686e8f9bcaf4dbf9f9`
- Base: `main`; merge-base `afa951ac0207eae934ac695e7340f18b3cf77522`
- Review timestamp: 2026-10-16T05-09
- Source artifacts:
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/policy-audit.2026-10-16T05-09.md`
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/code-review.2026-10-16T05-09.md`
  - `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/feature-audit.2026-10-16T05-09.md`

## Remediation Required

### PA-1: regenerate the local PowerShell coverage artifact over the full population

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect is in a gitignored tool output, not in code; a direct Invoke-PoshQCTest run in the item worktree regenerates it without CI, an external service, or an operator decision, and #901 remediation cycle 2 closed the same defect class this way.

- Finding: `artifacts/pester/powershell-coverage.xml` (mtime 2026-10-16 00:40:47 -04:00) was written by a scoped PoshQC MCP run. JaCoCo report-level LINE: covered 8128, missed 4170 (66.09%), below the 85% repo-wide floor. The artifact has no `sourcefile` entry for the new files `.claude/hooks/hook-docs-only-diff.ps1` and `.codex/hooks/hook-docs-only-diff.ps1` or for the modified file `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. The companion `artifacts/pester/pester-junit.xml` reports tests=7155, against 10322 for the full population measured in #901 cycle 2. The reviewer contract designates this path as the PowerShell coverage artifact, and the `validate-feature-review-coverage` stop hook reads it, so the policy audit records PowerShell coverage as FAIL.
- Not a code defect: the four modified hook files that the artifact does measure are at or above their merge-base CI figures, and all 21 changed executable lines in them are covered. The merge-base CI run `38852748136` reports repo-wide LINE 90.42% (16381/18116).
- Required action: produce `artifacts/pester/powershell-coverage.xml` from a Pester run over the full coverage population derived from `config/poshqc-coverage.json` (the CI form at `.github/workflows/_poshqc.yml:38-42`: `Import-Module <worktree>/scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <worktree>`). Invoke the repository module directly; the MCP runner reads installed-extension settings and does not measure the full population. Do not hand-copy or edit the XML. Record the run (command, observed exit code read from the host, XML mtime epoch, report-level and per-file LINE counters, changed-line `ci` values) in a new file under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/`, with the `Timestamp:` row read from the host clock.
- Pass condition: report-level LINE at or above 85.00%; a `sourcefile` entry at or above 85.00% line for each of `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1`; and every changed executable line listed in `evidence/qa-gates/p6-coverage-pending-ci.2026-10-16T04-52.md` with `ci` greater than 0, or a recorded reason for each uncovered one. The AC-9 statement lines (78, 79, 82, 84 of `enforce-pr-author-skill.docs-only.ps1`) should be reported from this run as supporting evidence; AC-9 itself remains CI-dependent.
- Verification commands: parse the regenerated XML for report-level and per-`sourcefile` `LINE` counters; read the `<testsuites>` root of `artifacts/pester/pester-junit.xml` for tests, failures, and errors.

## Related Non-blocking Observations (fix in this item where related)

Each item below is listed with file and line. None changes the review verdict.

1. CR-1 (Medium): hook timeout on the docs-only branch. `.claude/hooks/hook-docs-only-diff.ps1:221` (gh) and `:175` (git) run without a time bound inside PreToolUse hooks registered at `.codex/config.toml:144` (`timeout = 30`) and `.claude/settings.json:114` (runtime default). Action: confirm each runtime's behavior when a hook exceeds its timeout; if it does not deny, bound the calls and deny on expiry, or record the behavior as a residual limit in the headers of `hook-docs-only-diff.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1` (and their mirrors).
2. CR-2 (Medium): ambient working directory not documented. `.claude/hooks/enforce-epic-merge-gate.ps1:420` passes `$sessionRoot` (from `Get-Location`, `enforce-epic-merge-gate-resolution.ps1:111`); `.codex/hooks/enforce-epic-merge-gate.ps1:402` passes `$repositoryRoot`. A `cd` in an earlier Bash call is not visible to M1. Action: add the limit to `hook-docs-only-diff.ps1:43-46`, `enforce-epic-merge-gate.ps1:36-46`, and `.codex/hooks/enforce-epic-merge-gate.ps1:4-16` (and mirrors), or deny when the envelope working directory differs from the lookup root.
3. CR-3 (Low): non-discriminating row. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1:71` (`gh pr create -B=main ...`) has no `--base` and passes under the old and new code. Action: use `gh pr create --base main -B=other ...`.
4. CR-4 (Low): missing rows in `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` for `--match-head-commit=<oid>` (match and mismatch; spec Design item 9), `--auto=<value>` (source `hook-docs-only-diff.ps1:275`), and non-object JSON lookup output such as `[]` (source `:317`).
5. CR-5 (Low): `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:21-22, 26-28, 62` imports Claude worktree-resolution modules, mocks their seams, and runs a Claude-surface interception probe that the Codex gate under test does not use. Action: remove them or use an applicable Codex-surface probe.
6. CR-6 (Low): duplicate research addendum. `research/2026-10-15T19-46-merge-gate-addendum-research.md` (line 8 says "Retain one copy") and `research/research-addendum-merge-gate.2026-10-15T19-46.md`; `spec.md:12` and `plan.2026-10-15T07-41.md:11` cite different copies. Action: keep one and align the citation.
7. CR-7 (Info): `.claude/hooks/enforce-epic-merge-gate.ps1` is 490 lines (limit 500). No action required in this item.
8. CR-8 (Info): `Invoke-PrAuthorDocsOnlyGitExe` (`enforce-pr-author-skill.docs-only.ps1:46-85`) duplicates `Invoke-DocsOnlyGitExe` (`hook-docs-only-diff.ps1:144-182`) by spec Design item 3. No action in this item.
9. CR-9 (Low): rows without an `# Arrange` marker, for example `hook-docs-only-diff.Tests.ps1:207-223` and `hook-docs-only-diff.MergeExemption.Tests.ps1:61-73, 127-133, 193-216`. Action: add `# Arrange: <input source>` lines.
10. CR-10 (Low): `spec.md:337` (AC-M23) and `:360` (AC-18) are not marked CI-dependent, but their analyzer half is deferred to CI. Action: record pass-2 analyzer finding counts from a direct `Invoke-PoshQCAnalyze -Root <worktree>` run and check both criteria off, or add the CI-dependent marker with a spec revision note.

## Pending CI (not findings)

- AC-9, AC-19, AC-21, AC-M24: CI-dependent; checked off at S9 by the item's orchestrator run from the `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` jobs on the PR head.

## Do Not Do

- Do not edit `artifacts/pester/powershell-coverage.xml` by hand or copy it from a CI artifact.
- Do not exclude any production file from coverage measurement or narrow `config/poshqc-coverage.json`.
- Do not edit files under `.claude/rules/` or `.github/instructions/`.
- Do not rename evidence files or edit prior review artifacts.
- Do not change the create-side diff argument list (CR-3 / D5 non-goal).
