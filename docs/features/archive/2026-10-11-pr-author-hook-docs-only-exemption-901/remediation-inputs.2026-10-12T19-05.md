# Remediation Inputs: pr-author hook docs-only exemption (#901)

- Branch: `bug/pr-author-hook-docs-only-exemption-901` at `bdbf8851e`
- Review timestamp: 2026-10-12T19-05
- Source artifacts:
  - `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/policy-audit.2026-10-12T19-05.md`
  - `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/code-review.2026-10-12T19-05.md`
  - `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/feature-audit.2026-10-12T19-05.md`

## Remediation Required

### R1 (blocking): PowerShell coverage evidence for the changed hook files

- Finding: policy audit P20. The local artifact `artifacts/pester/powershell-coverage.xml` does not measure `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (new) or `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` (modified), and its repo-wide line figure (59.49%) comes from a scoped run.
- Required action: open the pull request, let `ci.yml` run, and read the `poshqc-test-results` artifact using the rule in `evidence/qa-gates/p2-ci-pending.2026-10-11T10-38.md`. Record per-file line coverage for the four `COVERAGE_TARGET` files and the repo-wide PowerShell line figure in a new evidence file under `evidence/qa-gates/`.
- Pass condition: each of the four files at or above 85.00% line coverage, and the repo-wide PowerShell figure at or above 85.00% or not regressed from main run `38315946747`.
- If a file is below 85.00%: add Pester rows for the uncovered lines (the expected gap in `docs-only.ps1` is the seam success path, lines 63-70), then rerun the toolchain.
- On pass: check off AC-9 in `issue.md`.

## Recommended Follow-ups (non-blocking; not required for merge)

- CR-1: in `Get-PrAuthorDocsOnlyBaseName`, deny when any single-dash shorthand cluster contains `B` (for example `-dB`), and when `-R`/`--repo` is present. Add test rows for both.
- CR-2: in `Get-PrAuthorDocsOnlyExemption`, return `DOCS_ONLY_EXEMPTION_DIFF_FAILED` when the diff output is non-empty and does not end with `[char]0`. Add a test row.
