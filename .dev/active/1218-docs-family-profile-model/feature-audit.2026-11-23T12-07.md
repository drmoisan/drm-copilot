# Feature Audit: Documentation families in the docs profile model (#1218)

**Audit Date:** 2026-11-23
**Feature Folder:** `.dev/active/1218-docs-family-profile-model`
**Base Branch:** `epic/documentation-estate-families-integration`
**Head Branch:** `feature/docs-family-profile-model-1218`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `epic/documentation-estate-families-integration` (merge base `7c4bdc734a0c59f9a3057108b719f67adeef88ca`)
- **Head branch/commit:** `feature/docs-family-profile-model-1218` (commit `321e42ed7888289862b4cc1e2838c2f07bcf241e`)
- **Merge base:** `7c4bdc734a0c59f9a3057108b719f67adeef88ca`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-23 12:02:55 UTC at head `321e42ed7`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1218-docs-family-profile-model/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` re-parsed per file by this review; SHA-256 of every mirror pair; `git diff --name-only 7c4bdc73..HEAD` filtered for forbidden paths; reading of `.agents/skills/docs-init/references/standard.md`
- **Feature folder used:** `.dev/active/1218-docs-family-profile-model`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources; the early-draft list in `issue.md` is not an AC source.
- **Scope note:** Comparisons use the merge base of the integration branch and `HEAD`. AC22 names the merge base with `origin/main`; the executor evidence used that base, and this review repeated the check against the integration merge base with the same result.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1218-docs-family-profile-model/spec.md` — primary source (24 checkbox items AC1 to AC24 under `## Acceptance Criteria`)
- `.dev/active/1218-docs-family-profile-model/user-story.md` — secondary source (8 checkbox items US1 to US8 under `## Acceptance Criteria`)

### Acceptance criteria

The criteria are the checkbox items of the two files, quoted in the source files and summarized by label in the evaluation table below.

---

## Acceptance Criteria Evaluation

### From spec.md

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC1 | Three schema copies declare both keys and three `$defs`; neither in root `required`; equal SHA-256; parity tests pass | PASS | Schema diff matches the spec `$defs` table; SHA-256 `d6e5912e...405d` for all three; pytest gate 0 failures | `sha256sum` of the three copies (this review) | |
| AC2 | `common.schema.json` unchanged, `schema_version` 1.0.0, `$ref` prefixes | PASS | `common.schema.json` absent from the diff; every new `$ref` starts with `urn:drm-copilot:docs:1.0.0:common#` or `#` | `git diff --name-only <MB>..HEAD` | |
| AC3 | Example profile unchanged and valid; profile without the new keys valid | PASS | Example absent from the diff; Schema suite `accepts the unmodified example profile text`, `accepts a profile that omits ...` | Pester gate | |
| AC4 | Empty arrays valid | PASS | `accepts empty required_families and legacy_exclusions arrays with no finding` | Pester gate | |
| AC5 | Missing family field yields `DOCS_SCHEMA_REQUIRED_MISSING`; unknown key yields `DOCS_SCHEMA_PROPERTY_UNKNOWN`; `Ok` false, `Profile` null | PASS | Seven `-ForEach` rows at field pointers; three unknown-key rows | code inspection; Pester gate | |
| AC6 | Type mismatch, enum and item-count codes | PASS | Rows `required as a string`, `review_interval_days as a string`, `as a non-integer number`, `diataxis_mode outside the enum`, `an empty audience` | code inspection | |
| AC7 | `DOCS_SCHEMA_INVALID` cases; interval 1 accepted | PASS | Twelve `DOCS_SCHEMA_INVALID` rows; `accepts review_interval_days of 1` | code inspection | |
| AC8 | Exclusion missing fields rejected; well-formed exclusion accepted with `required` true and false | PASS | Rows `an exclusion without reason`, `without recorded_at`; `accepts a well-formed exclusion with required set to <Required>` | code inspection | |
| AC9 | F1 and F2 at the later entry; case-differing ids not duplicates | PASS | Ordinal hash sets; three `It`s in `DocsProfileFamilies.Tests.ps1` | code inspection | |
| AC10 | F3 at `/required_families/<n>/audience/<m>` | PASS | `reports F3 ... at /required_families/0/audience/1` | code inspection | |
| AC11 | F4 at `/required_families/<n>/diataxis_mode` | PASS | `reports F4 ...` | code inspection | |
| AC12 | F5 segment-wise boundaries | PASS | Accept rows `docs/guide`, `docs/guide/security`; reject rows `docs/guidebook/security`, `docs/security`; nested directory accepted | code inspection | |
| AC13 | L1 at the later entry; legacy path outside roots accepted | PASS | Two `It`s | code inspection | |
| AC14 | Semantic findings severity `error`, field-naming message, next action; ordered with existing findings | PASS | AC14 `-ForEach` rows; `DocsProfile.Tests.ps1` ordering `It` | code inspection | |
| AC15 | `Get-DocsDefaultFamilySet` equals the Data & State table in order, no `exclusion` | PASS | Module rows match the table value for value (read by this review); key-order and values `It`s | code inspection | |
| AC16 | Starter families, empty `legacy_exclusions`, five audiences in order, root audience `maintainers` only | PASS | `DocsProfile.psm1` diff; `declares the default documentation families, ...` | code inspection | |
| AC17 | Indented starter validates for default, `handbook/user`, `sample`, `other-repo` | PASS | `validates the indented starter text with no finding for <Case>` | Pester gate | |
| AC18 | Init dry run and `-Write` seed ids and template ids; path set unchanged; `DocsProfileCommands.psm1` unchanged | PASS | New `It` in `DocsProfileCommands.Tests.ps1`; module absent from the diff | `git diff --name-only <MB>..HEAD` | |
| AC19 | `## Documentation Families` after `## Steps`; standard item; other sections unchanged | PASS | Skill diff adds only the new section; `standard.md` read by this review: OB-5, AC-5 (OB-5), AC-6 renumbered | Read of both files | No test pins `standard.md`; verified by reading (D-EX2). |
| AC20 | Generated `.claude` copy equals the generator rendering; bundle copies equal | PASS | Generator `-Check` no drift; added lines identical to the source; bundle SHA-256 pairs equal; pytest and Pester contract suites pass | `sha256sum`; `cmp` of diff hunks (this review) | |
| AC21 | Module bundle copies equal; `core.json` entry; manifest tests pass | PASS | SHA-256 pairs equal; `core.json` diff; pytest gate 0 failures | `sha256sum` (this review) | |
| AC22 | No TypeScript, Python, hook or `common.schema.json` change | PASS | Filter returned no path against both bases | `git diff --name-only <MB>..HEAD` filtered (this review) | |
| AC23 | Named suites pass in the parallel gate; no new leak finding | PASS | `final-qc-pester.2026-11-23T11-50.md` per-suite counts; leak scan 0 failures | evidence read | |
| AC24 | New module at least 85% line; no regression in `DocsProfile.psm1`; touched files at or below 800 lines | PASS | 65/65 and 91/91 (82/82 at Phase 0); largest covered file 519 lines | re-parse of `artifacts/pester/powershell-coverage.xml`; logical line counts (this review) | |

### From user-story.md

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| US1 | `docs-init` writes exactly the ten families with table values and the profile validates | PASS | as AC15, AC17, AC18 | as above | |
| US2 | A different documentation root places directories beneath it and validates | PASS | as AC17 (`handbook/user`) and the `places every directory beneath handbook/user` `It` | as above | |
| US3 | Exclusion with reason and UTC time accepted; missing field rejected | PASS | as AC8 | as above | |
| US4 | Legacy entries; repeated path `DOCS_PROFILE_LEGACY_DUPLICATE`; `..` rejected by schema | PASS | as AC7, AC13 | as above | |
| US5 | Malformed family entries rejected with code, pointer and next action | PASS | as AC5 to AC12, AC14 | as above | |
| US6 | Existing profiles validate as before | PASS | as AC3 | as above | |
| US7 | Skill text in every copy; generator and parity checks pass | PASS | as AC19, AC20 | as above | |
| US8 | Schema copies byte-identical; parity checks pass | PASS | as AC1 | as above | |

### Reviewer judgment: mixed-mode family directories

The epic Shared Design treats a family's Diataxis mode as the default for its pages, and a family directory may hold pages of another mode. The implementation adds no page-mode constraint: F4 checks only that the family mode is listed in `diataxis_policy.modes`, no `directory_modes` entry is derived from a family, and the module reads no page. The skill text and module help state that the mode is a default. Recorded by the executor as D-EX1; this review accepts it.

### Reviewer judgment: fixture deviation

Four fixture sites outside the planned file set changed the undeclared audience `operators` to `auditors`. The edit preserves each test's scenario (an undeclared audience reference) and leaves the assertions unchanged, and the executor recorded the deviation. This review accepts it.

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 32 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. At S9, confirm the CI Required Gate on the PR head. No criterion depends on CI.
2. The spec `## Definition of Done` and `## Seeded Test Conditions` checkboxes (not AC) are unchecked; the orchestrator may update them.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `.dev/active/1218-docs-family-profile-model/spec.md`, `.dev/active/1218-docs-family-profile-model/user-story.md`
- Total AC items: 32
- Checked off (delivered): 32
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 24 | 24 | 0 | Checkbox-backed. Definition of Done and Seeded Test Conditions (not AC) unchecked. |
| `user-story.md` | 8 | 8 | 0 | Checkbox-backed. |

No source-file checkbox change was made by this review: every PASS item was already checked by the executor, and this review independently verified each one.
