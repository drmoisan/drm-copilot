# Remediation Inputs: pr-author hook docs-only exemption (#901), cycle 2

- Branch: `bug/pr-author-hook-docs-only-exemption-901` at `24cd5c6b5`
- Review timestamp: 2026-10-12T19-50
- Source artifacts:
  - `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/policy-audit.2026-10-12T19-50.md`
  - `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/code-review.2026-10-12T19-50.md`
  - `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/feature-audit.2026-10-12T19-50.md`

## Remediation Required

### PA-1 (blocking): regenerate the local PowerShell coverage artifact

- Finding: `artifacts/pester/powershell-coverage.xml` (written 2026-10-12 18:59) is a scoped PoshQC MCP run. JaCoCo LINE totals: covered 7308, missed 4977 (59.49%). It has no `sourcefile` entry for `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` or `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`. The reviewer contract designates this path as the PowerShell coverage artifact, and the `validate-feature-review-coverage` stop hook reads it, so the policy audit must record PowerShell coverage as FAIL.
- Not a code defect: CI run `38321045586` (artifact `poshqc-test-results`) reports 90.35% repo-wide and 92.98% to 97.37% for the four changed hook files, on hook code identical to HEAD.
- Required action: produce `artifacts/pester/powershell-coverage.xml` from a Pester run over the full coverage population defined in `config/poshqc-coverage.json` (the same population CI measures with `Invoke-PoshQCTest -Root <workspace>`). Use the self-hosted PoshQC module invoked directly if the MCP runner ignores repository coverage settings. Do not hand-copy or edit the file.
- Pass condition: repo-wide JaCoCo LINE coverage at or above 85.00%, and a `sourcefile` entry at or above 85.00% for each of `enforce-pr-author-skill.docs-only.ps1`, `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.ps1`, and `enforce-pr-author-skill.artifact-root.ps1`. Record the counters in a new evidence file under `evidence/qa-gates/`.
- No code, test, or `issue.md` change is required. AC-9 remains checked.

## Recommended Follow-ups (non-blocking; not required for merge)

- CR-1: in `Get-PrAuthorDocsOnlyBaseName`, deny when any single-dash shorthand cluster contains `B` (for example `-dB`), and when `-R`/`--repo` is present. Add test rows for both.
- CR-2: in `Get-PrAuthorDocsOnlyExemption`, return `DOCS_ONLY_EXEMPTION_DIFF_FAILED` when the diff output is non-empty and does not end with `[char]0`. Add a test row.
- PA-N1: confirm every check of CI run `38323590007` on HEAD `24cd5c6b5` is SUCCESS before merge.
