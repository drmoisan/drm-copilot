# Code Review: Documentation families in the docs profile model (#1218)

**Review Date:** 2026-11-23
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1218-docs-family-profile-model`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1218; no version subfolder exists
**Base Branch:** `epic/documentation-estate-families-integration` (merge base `7c4bdc734a0c59f9a3057108b719f67adeef88ca`)
**Head Branch:** `feature/docs-family-profile-model-1218` (head `321e42ed7888289862b4cc1e2838c2f07bcf241e`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds one PowerShell production module (`.claude/lib/docs/DocsProfileFamilies.psm1`, 202 lines) and modifies one (`.claude/lib/docs/DocsProfile.psm1`), each with a byte-identical Claude bundle copy; extends the docs profile schema in three byte-identical copies; adds one Claude core pack-manifest entry; adds a `## Documentation Families` section to the docs-init skill (`.agents` source, generator-produced `.claude` copy, both bundle copies) and OB-5 / AC-5 / renumbered AC-6 to `references/standard.md` and its bundle copy; adds two Pester suites; and edits six existing suites.

Evidence reviewed: the full branch diff, the new module (read in full), the `DocsProfile.psm1` diff, the schema diff, the new and edited test files, the coverage artifact (re-parsed per file), SHA-256 of every mirror pair, and the feature evidence. Implementation quality is good: the module is pure, uses ordinal hash sets, matches the spec rule table F1 to F5 and L1 code for code and pointer for pointer, and reuses the existing finding factory and codes.

**What changed:**
Schema root properties `required_families` and `legacy_exclusions` with `$defs` `documentation-family`, `family-exclusion` and `legacy-exclusion` (all `additionalProperties: false`, neither key in root `required`); `Get-DocsDefaultFamilySet` (ten families, keys in fixed order, no `exclusion`); `Test-DocsProfileFamilySemantic` appended to `Test-DocsProfileSemantic` before ordering; starter profile gains four audiences, `required_families` and an empty `legacy_exclusions`; skill and standard text.

**Specific checks requested by the delegation:**

| Check | Result | Evidence |
|---|---|---|
| Schema in three copies | PASS | SHA-256 `d6e5912e...405d` for all three copies |
| `DocsProfile.psm1` and `DocsProfileFamilies.psm1` bundle copies | PASS | SHA-256 `252ae2dc...68ca` and `29153bc1...d1b6`, each pair equal |
| `core.json` entry | PASS | `.claude/lib/docs/DocsProfileFamilies.psm1` added after `DocsProfile.psm1` |
| docs-init `SKILL.md` generated, not hand-edited, and bundled | PASS | Added lines of `.claude/skills/docs-init/SKILL.md` equal those of the `.agents` source (`cmp` of the two diff hunks, exit 0); generator `-Check` no drift; `.claude` and `.agents` bundle pairs SHA-256 equal (`71dab8ee...c820`, `919890a7...ef9`) |
| `standard.md` OB-5 / AC-5 / AC-6 and bundle copy | PASS | Read by this review: `**OB-5** Documentation Families: ...` after OB-4; `**AC-5** (OB-5) An expression of the skill states the behavior described under Documentation Families, ...`; former AC-5 renumbered to `**AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5)`. Bundle copy SHA-256 equal (`9b1b39d2...9628`). |
| Fixture edits `operators` to `auditors` | PASS | `New-DocsLedgerTestProfile` wraps `New-DocsStarterProfile`, which now declares `operators`; `auditors` is declared nowhere in `.claude/lib/docs`; the assertions (`DOCS_PROFILE_AUDIENCE_UNKNOWN` count 1, `Ok` false, fail receipt, exit 1, property-test code containment) are unchanged. The deviation is recorded in `evidence/other/task-check.P2-T3.2026-11-23T08-55.md`. |
| Family `diataxis_mode` is a default, not a page constraint | PASS | F4 checks only membership in `diataxis_policy.modes`; the module derives no `directory_modes` entry and reads no page (search for `directory_modes` in the module returned no match). Module help and skill text both state the mode is a default for the family's pages. |
| No new Python, no hand-edited generated files, 800-line limit, no temporary files in tests, tonality | PASS | No `.py`/`.ts`/`.js`/`.sh`/hook path in the diff; largest covered file 519 lines; no `TestDrive`/`New-TemporaryFile`/`GetTempPath`/`Out-File`/`Set-Content`/`New-Item` in new or edited suites; added text is neutral. |

**Top 3 risks:**
1. The default family table is stated twice (module rows and the skill text table). The skill-text suite pins the ids and template ids in all four copies, but not the modes or review intervals, so a later change to a mode or interval in the module could leave the skill table stale.
2. Starter profiles written after this change declare five audiences while `documentation_roots[0].audience_ids` stays `maintainers` (D4). This is intended, and it changes the starter output that downstream tooling sees.
3. F5 compares the family directory to the root path text exactly; a root path recorded with a trailing `/` would make every family under it fail F5. The common `relative-path` definition and the starter do not produce such a root, so the risk applies only to hand-authored profiles.

**PR readiness recommendation:** **Go**. No Blocker or Major finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.agents/skills/docs-init/SKILL.md` (and generated and bundle copies) | `## Documentation Families` table | The Mode and Review interval columns duplicate values from `Get-DocsDefaultFamilySet`; `docs-authoring-roles.WorkflowText.Tests.ps1` pins the ids and template ids only. | Optionally extend the token list to the mode and interval values in a later edit of that suite. | The duplication can drift without a test failure. | Branch diff; `WorkflowText` `It 'places the Documentation Families section ...'` token list |
| Info | `.claude/lib/docs/DocsProfileFamilies.psm1` | `Test-DocsProfileFamilySemantic`, parameter `-Profile` | The parameter shadows the automatic variable `$PROFILE` inside the function. It matches the existing `Test-DocsProfileSemantic -Profile` signature, and PSScriptAnalyzer reports 0 findings. | None required. | Consistency with the existing API outweighs the rename. | `final-qc-static-powershell.2026-11-23T11-29.md` |
| Info | `tests/scripts/claude-lib/docs/DocsValidation.Tests.ps1`, `DocsValidateCommands.Tests.ps1`, `DocsValidation.Properties.Tests.ps1` | four fixture sites | Edited outside the planned file set (the plan listed them as unchanged). The edit is necessary because `operators` became a declared audience, and it is recorded as a deviation with cause and disposition. | None required. | Assertion meaning preserved; deviation disclosed. | `evidence/other/task-check.P2-T3.2026-11-23T08-55.md`; this review's inspection of the helper and assertions |
| Info | `evidence/qa-gates/coverage-and-scope.2026-11-23T11-51.md` | Scope line | The forbidden-path scope check used the merge base with `origin/main` (`3d905ca0`) rather than the integration branch merge base. AC22 states the `origin/main` merge base, so the evidence matches the criterion; this review repeated the check against `7c4bdc73` with the same result (no forbidden path). | None required. | Both bases give the same result. | This review: `git diff --name-only 7c4bdc73..HEAD` filtered |

No Blockers or Major findings. No covered file in the branch diff is at or above 700 logical lines (largest `tests/scripts/claude-lib/docs/DocsValidateCommands.Tests.ps1`, 519), so no `Warning` row applies; `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python file changed (owner language rule); the push-down contract tests ran unchanged and passed.

#### Typing and API notes

- No Python API surface changed.

#### Error handling and logging

- Not applicable.

### TypeScript implementation audit

#### What changed well

- No TypeScript file changed. The MCP docs tools reach the new validation through the library (spec `## Constraints & Risks`).

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- Not applicable.

### PowerShell implementation audit

#### What changed well

- Duplicate detection uses `HashSet[string]` with `StringComparer]::Ordinal`, so ids differing only in case are distinct (AC9) and the later entry is reported (D12).
- F5 is segment-wise with ordinal `Equals` and `StartsWith(root + '/')`; no `Join-Path`, resolution or case folding, as the spec boundary requires.
- `Get-DocsFamilyList` tolerates absent or null members, so profiles without the new keys produce no family finding (AC3).
- `Get-DocsDefaultFamilySet` casts `review_interval_days` to `[long]` and `audience` to `[string[]]`, so the serialized starter matches the schema integer and array types (AC17).
- `DocsProfile.psm1` changes are additive: one import, one `foreach` append before `Get-DocsOrderedFinding`, and three starter keys; signatures are unchanged.

#### API and safety notes

- Advanced functions with `[OutputType()]`; explicit `Export-ModuleMember` of the two public functions. PSScriptAnalyzer reports 0 findings over the 12 changed PowerShell files.
- The module reads no file, clock, environment or process.

#### Error handling and logging

- `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, and `-ErrorAction Stop` on the sibling import, matching the module convention checked by `ClaudeLibModuleConvention.Tests.ps1` (6/6).

---

## Test Quality Audit

The Pester gate at the reviewed head reports 29216 passed and 0 failed, and this review re-parsed the coverage artifact per file: `DocsProfileFamilies.psm1` 65/65 and `DocsProfile.psm1` 91/91.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocsProfileFamilies.Tests.ps1`: default set values and key order, alternate root, empty root throws, fresh set per call, F1 to F5, L1, case-differing ids, nested directories, legacy path outside roots, exclusion on a required family, finding shape per code.
- `tests/scripts/claude-lib/docs/DocsProfileFamilies.Schema.Tests.ps1`: example profile, absent keys, empty arrays, seven required-missing rows at field pointers (D16), unknown keys in three record types, type, enum, item count, exclusion required-missing, twelve `DOCS_SCHEMA_INVALID` rows, interval of 1, exclusion with `required` true and false.
- `tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1` and `DocsProfileCommands.Tests.ps1`: ordering with existing findings, starter content (AC16), indented starter validation for four argument sets (AC17), dry run and `-Write` seeding with the unchanged path set (AC18).
- `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1`: section position and tokens in four skill copies.
- `evidence/qa-gates/final-qc-pester.2026-11-23T11-50.md`, `final-qc-pytest.2026-11-23T11-50.md`, `final-qc-static-powershell.2026-11-23T11-29.md`, `coverage-and-scope.2026-11-23T11-51.md`.

### Quality assessment prompts

- **Determinism:** in-memory profiles; no clock, sleep or temporary file.
- **Isolation:** one rule per `It`; `AfterAll` `Remove-Module` lists include `DocsProfileFamilies`.
- **Speed:** 64 new tests within an eight-worker run of 744.56 s.
- **Diagnostics:** schema rows assert code and pointer together and name the case in `-Because`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token in any added file; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | The module starts no process and uses no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Shape rules in the schema layer; cross-field rules only on schema-valid profiles. |
| Error handling remains explicit | ✅ PASS | Strict mode and fail-fast import; every finding has severity `error`. |
| Configuration / path handling is safe | ✅ PASS | `relative-path` rejects absolute, `..`, backslash and glob paths; F5 performs no filesystem access. |

---

## Research Log

No external research was required; all findings derive from the branch diff, repository rules and the feature evidence.

---

## Verdict

The change is ready for the normal PR flow into the integration branch. The findings are four Info notes; none blocks merge, and none is carried into remediation inputs.
