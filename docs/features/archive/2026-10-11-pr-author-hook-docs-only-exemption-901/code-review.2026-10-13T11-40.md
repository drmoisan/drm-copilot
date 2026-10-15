# Code Review: pr-author hook docs-only exemption (Issue #901)

- Timestamp: 2026-10-13T11-40
- Reviewer: feature-review agent (minor-audit re-audit, remediation cycle 2 exit)
- Branch: `bug/pr-author-hook-docs-only-exemption-901`, HEAD `70e58ca8401ce229a761c45d9cc49c04fb73997f`
- Base: `origin/main`, merge-base `12b2454256cfa11ff809d5d2333ddaf988574e21`; diff `git diff origin/main...HEAD`
- Companion artifacts: `policy-audit.2026-10-13T11-40.md`, `feature-audit.2026-10-13T11-40.md`
- Prior review: `code-review.2026-10-12T19-50.md` (PASS WITH NOTES; 0 Blocking; CR-1 Medium, CR-2 and CR-3 Low, CR-4 and CR-5 Informational)

## Executive Summary

The reviewer re-read the whole code diff against `origin/main` (13 files outside `docs/`, +1400/-26): `enforce-pr-author-skill.docs-only.ps1` (new, 265 lines), the modified `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.artifact-root.ps1`, and `enforce-pr-author-skill.ps1`, their four bundled mirrors, the one-line `core.json` registration, and four new Pester suites. Remediation cycles 1 and 2 changed no code and no tests; cycle 2 commits `ff1b7cbd4`, `395a94432`, and `70e58ca84` touch only the feature folder.

Assessment of the change:

- The exemption is consulted only inside the non-epic branch of `Get-PrAuthorBypassReason`, after `Invoke-OrchestratorStatePreflight` has failed. A passing checkpoint never reaches it (AC-3), and epic scope never reaches it.
- `Get-PrAuthorDocsOnlyExemption` evaluates E1 to E7 in order and returns at the first failure. Every git call is wrapped in `try`/`catch`, the seam itself never throws, and each failure maps to a named sub-code appended to the existing `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` denial. An exempt result falls through to the unchanged receipt checks, so the exemption replaces only the checkpoint preflight.
- Path classification is ordinal and case-sensitive on `docs/` with a length guard, so `docs`, `docsx/`, and `doc/` deny. `--no-renames` reports the old path of a rename. `-z` avoids quoted paths.
- `ConvertTo-PrAuthorBodyNumber` uses `[int]::TryParse` with `NumberStyles.None` and a round-trip comparison, so overflow, leading zeros, and non-ASCII digits return `$null` and the caller denies with the generic reason instead of throwing.
- Cycle 2 now shows the same per-file coverage locally as CI: `docs-only.ps1` 93.44%, `helpers.ps1` 97.37%, `enforce-pr-author-skill.ps1` 92.98%, `artifact-root.ps1` 96.97%.

No Blocking code finding. CR-1 and CR-2 remain recommended follow-ups.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Medium (non-blocking) | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | `Get-PrAuthorDocsOnlyBaseName`, lines 122-130 | CR-1 (carried, unchanged): the `-B` exclusion checks only tokens that begin with `-B`. A clustered shorthand such as `-dB other` alongside `--base main` lets the diff use `main` while gh applies `other`. `-R`/`--repo` can also retarget the PR. | Follow-up: deny when any single-dash shorthand cluster contains `B`, and when `-R`/`--repo` is present; add a test row for each. | Outside the AC-2 condition list; requires deliberate command construction; receipt checks still apply after an exemption. | Source lines 122-130; `code-review.2026-10-12T19-05.md` CR-1 |
| Low (non-blocking) | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | lines 64-70 and 162 | CR-2 (carried, unchanged): path separation depends on PowerShell preserving NUL characters in captured native `git` stdout. Lines 64, 65, 68, and 70 are not executed by any test (local XML and CI agree), so this property has no test evidence on the branch. | Follow-up: return `DOCS_ONLY_EXEMPTION_DIFF_FAILED` when the diff output is non-empty and does not end with `[char]0`; add a test row. | A cheap fail-closed guard removes the dependency on capture behavior. | `artifacts/pester/powershell-coverage.xml`: `docs-only.ps1` LINE missed=4 |
| Low (non-blocking) | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | line 251, diff range on local `HEAD` | CR-3 (carried, recorded decision D5): the diff uses the local `HEAD` of the resolved worktree, which can differ from the pushed head branch gh uses. | No action in this item; revisit if the exemption is broadened. | Recorded operator decision. | `evidence/other/follow-up-and-decisions.2026-10-11T10-38.md` |
| Info | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | lines 90-93 | CR-4 (carried): `Test-Path -PathType Leaf` reports a directory at the checkpoint path as absent; the preflight has already failed and E3 to E7 still apply. | None required. | Limited to an unusual repository layout. | Source lines 90-93 |
| Info | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | `Invoke-PrAuthorDocsOnlyGitExe`, lines 63-70 | CR-5 (carried): the seam success path is not unit-tested by design; file coverage 93.44% (57/61) remains above 85%. | None required. | No process start in unit tests is repository policy; the cost is visible in the metric. | Local XML and CI run `38321045586` agree on 57/61 |

## Detailed Notes

### Cycle 2 change set

- `ff1b7cbd4`: 14 evidence files (remediation baseline, MCP attempt, direct run, coverage read, AC state, scope check).
- `395a94432`: remediation plan checkboxes.
- `70e58ca84`: four rerun evidence files with an observed exit code.
- No `.ps1`, `.json`, or mirror path changed. Evidence timestamp accuracy is reported in the policy audit as PA-N3; it does not affect code quality.

### Coverage cross-check

- Reviewer parse of the local XML: per-file LINE counters match the CI artifact of run `38321045586` exactly for all four changed hook files. Repo-wide local 16309/18041 (90.40%) against CI 16300/18041 (90.35%); the small difference is in files outside this branch's scope and does not affect any changed file.

### Unchanged since the prior review

- Fail-closed conditions, deny-message format, receipt-check fall-through, epic-scope exclusion, body-number semantics, test structure (Arrange/Act/Assert, `-ForEach` rows, mocks on the seam only), mirror parity (`cmp -s` identical for four pairs at HEAD), and file sizes (maximum 438 lines) are as described in `code-review.2026-10-12T19-05.md`.

## Verdict

PASS WITH NOTES. No Blocking code finding. Non-blocking: 1 Medium (CR-1), 2 Low (CR-2, CR-3), 2 Info (CR-4, CR-5). CR-1 and CR-2 are recommended follow-ups.
