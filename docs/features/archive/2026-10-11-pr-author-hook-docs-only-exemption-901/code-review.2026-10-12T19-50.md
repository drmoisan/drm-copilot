# Code Review: pr-author hook docs-only exemption (Issue #901)

- Timestamp: 2026-10-12T19-50
- Reviewer: feature-review agent (minor-audit re-audit, remediation cycle 1 exit)
- Branch: `bug/pr-author-hook-docs-only-exemption-901`, HEAD `24cd5c6b54decb51be75bb207f9982d8d0884d9e`
- Base: `origin/main` @ `12b2454256cfa11ff809d5d2333ddaf988574e21`; diff `git diff origin/main...HEAD`
- Companion artifacts: `policy-audit.2026-10-12T19-50.md`, `feature-audit.2026-10-12T19-50.md`
- Prior review: `code-review.2026-10-12T19-05.md` (0 Blocking; CR-1 Medium, CR-2 Low, CR-3 Low, CR-4 and CR-5 Informational)

## Executive Summary

Remediation cycle 1 changed no code and no tests. `git diff --stat c9123db7f HEAD` restricted to `.claude/hooks`, the bundled hook mirror, `pack-manifests`, and `tests/scripts/claude-hooks` is empty, and the branch's code diff against `origin/main` (13 files, +1400/-26) is identical to the diff reviewed in `code-review.2026-10-12T19-05.md`. The prior assessment of the exemption (ordered fail-closed predicate E1 to E7, consulted only after the non-epic preflight fails, receipt checks not relaxed) and of the #850 L19 fix still applies.

New in this review: the CI coverage artifact for PR #924 run `38321045586` lets the reviewer confirm CR-5 empirically. The only uncovered lines in `enforce-pr-author-skill.docs-only.ps1` are 64, 65, 68, and 70, which is the `git` invocation inside `Invoke-PrAuthorDocsOnlyGitExe`. Every changed executable line in `enforce-pr-author-skill-helpers.ps1` (4/4) and `enforce-pr-author-skill.artifact-root.ps1` (13/13) is covered.

The CI jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` passed on run `38321045586`. This exercises the production code paths through mocks only; it does not execute the real `git` capture, so CR-2 (NUL preservation of native stdout) remains open as a recommended follow-up.

No Blocking code finding. CR-1 and CR-2 are carried as non-blocking follow-ups and are listed in the PR #924 body (reviewer `gh pr view 924`).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Medium (non-blocking) | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | `Get-PrAuthorDocsOnlyBaseName`, lines 122-130 | CR-1 (carried, unchanged): the `-B` exclusion checks only tokens that begin with `-B`. A clustered shorthand such as `-dB other` alongside `--base main` resolves `main` for the diff while gh applies `other`. `-R`/`--repo` can also change the effective target. | Follow-up: deny when any single-dash shorthand cluster contains `B`, and when `-R`/`--repo` is present; add a test row for each. | Not one of the AC-2 conditions; exploitation requires deliberate command construction, and the hook `.NOTES` describes it as a policy-level control. | `code-review.2026-10-12T19-05.md` CR-1; PR #924 body |
| Low (non-blocking) | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | lines 64-70 and 162 | CR-2 (carried, unchanged): path separation depends on PowerShell preserving NUL characters in captured native `git` stdout. The CI artifact confirms lines 64-70 are not executed by any test, so this property has no test or empirical evidence on the branch. | Follow-up: return `DOCS_ONLY_EXEMPTION_DIFF_FAILED` when the diff output is non-empty and does not end with `[char]0`; add a test row. | A cheap fail-closed guard removes the dependency on capture behavior. | CI `powershell-coverage.xml` run `38321045586`: lines 64, 65, 68, 70 `ci="0"` |
| Low (non-blocking) | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | diff range on local `HEAD` | CR-3 (carried, recorded decision D5): the diff uses the local `HEAD` of the resolved worktree, which can differ from the pushed head branch gh uses. | No action in this item; revisit if the exemption is broadened. | Recorded as a decision by the operator. | `evidence/other/follow-up-and-decisions.2026-10-11T10-38.md` |
| Info | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | lines 90-93 | CR-4 (carried): `Test-Path -PathType Leaf` reports a directory at the checkpoint path as absent; the preflight has already failed and the remaining conditions still apply. | None required. | Limited to an unusual repository layout. | `code-review.2026-10-12T19-05.md` CR-4 |
| Info | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | `Invoke-PrAuthorDocsOnlyGitExe`, lines 63-70 | CR-5 (carried, now confirmed): the seam success path is not unit-tested by design. CI shows exactly 4 uncovered lines in the file (64, 65, 68, 70); file coverage 93.44% (57/61) remains above the 85% threshold. | None required. | No process start in unit tests is repository policy; the cost is visible in the metric. | CI `poshqc-test-results` run `38321045586` |

## Detailed Notes

### Cycle 1 change set

- Commits `4c602aeab` (CI coverage evidence and AC-9 check-off) and `08ac595a5` (plan checkboxes) touch only `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/`.
- `24cd5c6b5` merges `origin/main` (PR #923, issue #899). Its paths (`.claude/agents`, `.claude/lib/ci-gate`, several skills, Codex agent TOML mirrors, and two tests) are outside the pr-author hook family and contribute nothing to the three-dot diff.

### Coverage reading cross-check

- The reviewer downloaded `poshqc-test-results` for main run `38315946747` and PR run `38321045586` to the session scratchpad and parsed JaCoCo LINE counters. Repo-wide: 16232/17969 (90.33%) to 16300/18041 (90.35%). Per file values match `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` exactly.
- The uncovered lines in the three modified files map one-to-one onto the main uncovered lines after the line shift caused by inserted help text and code (`helpers.ps1` +5, `artifact-root.ps1` +1, main hook +21). No changed hunk contains an uncovered line.

### Unchanged since the prior review

- Fail-closed conditions, deny-message format, receipt-check fall-through, epic-scope exclusion, `ConvertTo-PrAuthorBodyNumber` semantics, test structure, mirror parity, and file sizes are as described in `code-review.2026-10-12T19-05.md` Focus Areas 1 to 4. The reviewer re-ran `cmp -s` on the four mirror pairs and `wc -l` on the eight files at HEAD with identical results.

## Verdict

PASS WITH NOTES. No Blocking code finding. Non-blocking: 1 Medium (CR-1), 2 Low (CR-2, CR-3), 2 Info (CR-4, CR-5). CR-1 and CR-2 are recommended follow-ups recorded in the PR #924 body.
