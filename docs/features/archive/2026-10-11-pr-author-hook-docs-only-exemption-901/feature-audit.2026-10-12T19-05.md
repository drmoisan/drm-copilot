# Feature Audit: pr-author hook docs-only exemption (#901)

- Branch: `bug/pr-author-hook-docs-only-exemption-901` at `bdbf8851e`
- Base: `origin/main` at `7d9a5c33526d7a98d5577ab4a9ad6f465f3dff3c`
- Work mode: `minor-audit`
- AC source: `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md`, section `## Acceptance Criteria` only
- Review timestamp: 2026-10-12T19-05

## Baseline

On `origin/main`, `Get-PrAuthorBypassReason` returned `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` for any non-epic `gh pr create --body-file` whose checkpoint failed `--require-pr-creation-ready`, including when no checkpoint existed. Body numbers were parsed with `[int]` casts. Baseline evidence: `evidence/baseline/p0-poshqc-test` (tests=6025, failures=0; pr-author family 170 passed), `p0-line-counts-parity`, `p0-ci-baseline` (main run `38315946747`).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 docs-only branch allowed without checkpoint; Pester asserts allow | PASS | `DocsOnly.Decision.Tests.ps1` "allows a docs-only gh pr create with no checkpoint (AC-1)" asserts `permissionDecision = 'allow'` through `Invoke-PrAuthorSkillDecision`. `DocsOnly.Exemption.Tests.ps1` "exempts a docs-only create". |
| AC-2 fail-closed branches, each with its own test | PASS | Outside `docs/`: `.claude/`, `.github/`, `README.md`, `docsx/`, `doc/` (helper rows plus Exemption and Decision rows). Rename: "denies a rename from outside docs reported as delete plus add", with `--no-renames` asserted. Empty diff: "denies an empty diff". No `--base`: "denies without an explicit --base" and the Decision row. Base unresolvable: rev-parse non-zero, non-OID, throw. Diff fails: exit 128. Diff throws: throw row. Reviewer trace of the source confirms each path returns `Exempt = $false` (code review, Focus Area 1). Two evasion shapes outside the AC-2 list are recorded as non-blocking CR-1 and CR-2. |
| AC-3 checkpoint branches unchanged; existing suites pass | PASS | Decision "never consults the exemption when the preflight passes (AC-3)" (zero seam calls, allow). `evidence/qa-gates/p2-scope`: no existing `enforce-pr-author-skill*.Tests.ps1` edited. `p2-pester`: tests=6093 failures=0; family 230 = 170 baseline + 60 new, 0 failed. |
| AC-4 mirrors byte-identical; new sibling in `core.json` | PASS | Reviewer `cmp` of four pairs: identical. `evidence/qa-gates/ac4-mirror-parity` (five hash pairs equal). `evidence/regression-testing/p1-bundle-parity` (parity pytest passed). `core.json` line 52 adds `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. |
| AC-5 L19: overflow and leading zero deny deterministically | PASS | `ConvertTo-PrAuthorBodyNumber` (strict TryParse plus round-trip). `BodyNumber.Tests.ps1`: overflow relative and absolute, leading zero relative and absolute, non-ASCII digits, canonical accept, end-to-end deny with `Should -Not -Throw`. |
| AC-6 L20 recorded with file, line, covering row, rationale | PASS | `evidence/other/note-850-L20-record`: `enforce-epic-merge-gate-resolution.ps1:151` and `:186`, test file lines 238 and 258, `COVERING-ROW`, `DECISION: NO-CHANGE-IN-THIS-ITEM`, and the operator scope rationale. |
| AC-7 L21, L22, L23 fixed or recorded with rationale | PASS | `evidence/other/notes-850-L21-L23-no-change`: each note has file:line, `DECISION: NO-CHANGE`, rationale, and a trigger. |
| AC-8 L25 `.NOTES` corrected in main hook and helpers | PASS | Diff replaces "No external module dependencies" in both files with an accurate in-repo dependency list and the runtime `git` dependency. |
| AC-9 500 lines; format and analyze clean; family Pester passes; CI per-file line coverage >= 85% | PENDING CI | Sub-items verified locally: line counts (max 438), format (no change), analyze (MCP returned, status empty), family Pester (230 passed, 0 failed). Sub-item pending: CI per-file line coverage. No PR or CI run exists yet. The local artifact shows helpers at 97.37% and the main hook at 92.98%, and does not measure `docs-only.ps1` or `artifact-root.ps1` (scoped MCP run). No independent defect was found in this criterion. It remains unchecked. |
| AC-10 header documents the exemption and fail-closed conditions | PASS | `enforce-pr-author-skill.ps1` `.DESCRIPTION` adds the "Docs-only" stage listing all conditions and six sub-codes, and states that the exemption never applies under epic scope. The sibling file header lists E1 to E7. |

## Acceptance Criteria Check-off

No check-off changes were made. AC-1 through AC-8 and AC-10 were already checked in `issue.md` and are confirmed PASS by this review. AC-9 remains unchecked (PENDING CI).

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` (`## Acceptance Criteria`)
- Total AC items: 10
- Checked off (delivered): 9
- Remaining (unchecked): 1
- Items remaining: AC-9 (CI per-file line coverage >= 85% for the edited hook files; the other AC-9 sub-items are verified locally)

## Relationship to the Policy Audit

The policy audit records the PowerShell coverage verdict as FAIL (P20) because the reviewer contract requires PASS or FAIL for every changed language, and the existing artifact does not measure two changed files. That finding and AC-9 resolve together: one CI `poshqc-test-results` reading showing the four files at or above 85.00% line coverage closes both.

## Out-of-Scope Items (recorded, not findings)

- #850 note L20 (merge-gate file) is recorded only, by operator decision.
- The agent and skill documentation follow-ups (`.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, orchestrator documents) are recorded in `evidence/other/follow-up-and-decisions` and were not filed.

## Overall Verdict

- Verdict: CHANGES REQUESTED
- Blocking count: 1 (policy audit P20: PowerShell coverage evidence incomplete for `enforce-pr-author-skill.docs-only.ps1` and `enforce-pr-author-skill.artifact-root.ps1`; resolved by the CI coverage reading AC-9 already requires, with no code change indicated).
- Non-blocking: CR-1 (clustered `-dB` shorthand and `-R/--repo` can change the effective PR target), CR-2 (NUL preservation of native capture is not verified and has no terminator guard), CR-3 to CR-5 informational.
