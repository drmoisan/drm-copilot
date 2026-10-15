# Feature Audit: pr-author hook docs-only exemption (Issue #901)

- Timestamp: 2026-10-12T19-50
- Reviewer: feature-review agent (minor-audit re-audit, remediation cycle 1 exit)
- Companion artifacts: `policy-audit.2026-10-12T19-50.md`, `code-review.2026-10-12T19-50.md`

## Scope and Baseline

- Branch: `bug/pr-author-hook-docs-only-exemption-901`, HEAD `24cd5c6b54decb51be75bb207f9982d8d0884d9e`.
- Base: `origin/main` @ `12b2454256cfa11ff809d5d2333ddaf988574e21` (merge-base). Diff: `git diff origin/main...HEAD`, 55 files (+3436/-26): 4 canonical hook files (1 new, 3 modified), 4 byte-identical bundled mirrors, `pack-manifests/core.json` (1 line), 4 new Pester suites, and the feature folder (issue, plan, research, review and remediation artifacts, evidence).
- Work mode: `minor-audit`. AC source: `issue.md` `## Acceptance Criteria` (AC-1 to AC-10). `spec.md` and `user-story.md` are absent.
- Baseline behavior on main (`7d9a5c33`, the base used for the original change and for CI baseline run `38315946747`): `Get-PrAuthorBypassReason` returned `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` for any non-epic `gh pr create --body-file` without a ready checkpoint, including when no checkpoint existed; body numbers were parsed with `[int]` casts that throw above Int32.MaxValue and normalize leading zeros. The later `origin/main` advance to `12b245425` (PR #923) does not touch the pr-author hook family.
- Remediation history: cycle 1 (R1, PowerShell coverage evidence for the changed hook files). Closed per `policy-audit.2026-10-12T19-50.md` section 8.

## Acceptance Criteria Inventory

| ID | Criterion (short form) | State before review |
|---|---|---|
| AC-1 | Docs-only branch allowed without a checkpoint; Pester asserts allow | checked |
| AC-2 | Exemption fails closed on every listed condition, each with its own test | checked |
| AC-3 | Checkpoint branches behave as before; existing suites pass | checked |
| AC-4 | Mirrors byte-identical; new sibling registered in `core.json` | checked |
| AC-5 | #850 L19: overflow and leading-zero body numbers deny deterministically | checked |
| AC-6 | #850 L20 recorded with file, line, covering row, and rationale | checked |
| AC-7 | #850 L21, L22, L23 fixed or recorded with rationale | checked |
| AC-8 | #850 L25: `.NOTES` dependency text corrected in main hook and helpers | checked |
| AC-9 | 500 lines; format and analyze clean; family Pester passes; CI line coverage of edited hook files >= 85% | checked (in cycle 1) |
| AC-10 | Header documentation describes the exemption and fail-closed conditions | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | `DocsOnly.Decision.Tests.ps1` "allows a docs-only gh pr create with no checkpoint (AC-1)" asserts `permissionDecision = 'allow'`; `DocsOnly.Exemption.Tests.ps1` "exempts a docs-only create". Test files unchanged since the prior audit; CI poshqc jobs SUCCESS on run `38321045586`. |
| AC-2 | PASS | One row each for `.claude/`, `.github/`, `README.md`, `docsx/`, `doc/`, rename from outside into `docs/` (`--no-renames` asserted), empty diff, absent `--base`, unresolvable base (non-zero exit, non-OID output, throw), diff exit 128, diff throw. Source trace in `code-review.2026-10-12T19-05.md` Focus Area 1. CR-1 and CR-2 are evasion shapes outside the AC-2 list and are non-blocking. |
| AC-3 | PASS | Decision row "never consults the exemption when the preflight passes (AC-3)"; `evidence/qa-gates/p2-scope.2026-10-11T10-38.md` shows no existing suite edited; family 230 passed (170 baseline + 60 new), 0 failed; CI poshqc jobs SUCCESS. |
| AC-4 | PASS | Reviewer `cmp -s` at HEAD: four pairs identical. `core.json` line 52 registers `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. `evidence/regression-testing/p1-bundle-parity.2026-10-11T10-38.md`. |
| AC-5 | PASS | `ConvertTo-PrAuthorBodyNumber` (strict `TryParse` plus round-trip); `BodyNumber.Tests.ps1` overflow and leading-zero rows (relative and absolute) and end-to-end deny with `Should -Not -Throw`. All 13 changed executable lines in `artifact-root.ps1` covered in CI. |
| AC-6 | PASS | `evidence/other/note-850-L20-record.2026-10-11T10-38.md`: file, lines, covering row, `DECISION: NO-CHANGE-IN-THIS-ITEM`, operator scope rationale. |
| AC-7 | PASS | `evidence/other/notes-850-L21-L23-no-change.2026-10-11T10-38.md`: each note with file:line, decision, rationale. |
| AC-8 | PASS | Diff replaces "No external module dependencies" in both files with the in-repo dependency list and the runtime `git` use (`git diff -U0 origin/main...HEAD`). |
| AC-9 | PASS | Line counts at HEAD: maximum 438 (`helpers.ps1`). Format and analyze: `evidence/qa-gates/p2-poshqc-format.2026-10-11T10-38.md`, `p2-poshqc-analyze.2026-10-11T10-38.md`, CI `poshqc / PowerShell QC` SUCCESS. Family Pester: 230 passed, 0 failed. CI line coverage (run `38321045586`, artifact `poshqc-test-results`): `docs-only.ps1` 93.44% (57/61), `helpers.ps1` 97.37% (111/114), `enforce-pr-author-skill.ps1` 92.98% (53/57), `artifact-root.ps1` 96.97% (64/66); all at or above 85%. Recorded in `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` and reproduced by the reviewer from the downloaded artifact. Hook files at HEAD are identical to the CI-tested head `c9123db7f`. |
| AC-10 | PASS | `enforce-pr-author-skill.ps1` `.DESCRIPTION` "Docs-only" stage lists every condition, six sub-codes, and the epic-scope exclusion; the sibling header enumerates E1 to E7. |

## Summary

- AC verdicts: 10 PASS (AC-1 to AC-10), 0 PARTIAL, 0 FAIL, 0 pending.
- Relative to the main baseline, the branch delivers the docs-only exemption from the orchestrator-state preflight with fail-closed behavior on every listed condition, a non-throwing strict body-number parse (#850 L19), corrected `.NOTES` text (#850 L25), recorded dispositions for #850 L20 to L23, byte-identical bundled mirrors, and line coverage at or above 85% on every edited hook file as reported by CI.
- Prior blocking finding: P20 (PowerShell coverage evidence) closed by the PR #924 CI artifact.
- Non-blocking: PA-N1 (CI run `38323590007` on HEAD in progress at review time; merge gate to confirm), PA-N2 (`issue.md` `## Evidence Checklist` unchecked; not an AC section), CR-1 (Medium), CR-2 and CR-3 (Low), CR-4 and CR-5 (Info).
- New blocking finding: PA-1 (policy audit). The contract-designated local PowerShell coverage artifact `artifacts/pester/powershell-coverage.xml` reads 59.49% repo-wide and omits `docs-only.ps1` and `artifact-root.ps1`; the `validate-feature-review-coverage` stop hook reads that path. AC-9 remains PASS because its text names CI as the coverage source and CI reports every edited hook file at or above 85%. PA-1 requires regenerating local evidence only; no code change is indicated.
- Overall review verdict: **CHANGES REQUESTED**. Blocking count: 1 (PA-1). Non-blocking count: 7.

## Acceptance Criteria Check-off

- AC-1 to AC-10 were already checked in `issue.md`; each is evaluated PASS above, so no change to `issue.md` was required.
- No AC was unchecked, no AC text was modified, and no criterion was added.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md` (`## Acceptance Criteria`)
- Total AC items: 10
- Checked off (delivered): 10
- Remaining (unchecked): 0
- Items remaining: none
