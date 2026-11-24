# Code Review: docs-family-gate-and-ia (#1221)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1221-docs-family-gate-and-ia`
**Feature Folder Selection Rule:** Named by the delegation; no version subfolder exists.
**Base Branch:** `origin/epic/documentation-estate-families-integration` (merge base `7a84f85cdea1f1aef83613952277af31566bfcd5`)
**Head Branch:** `feature/docs-family-gate-and-ia-1221` at `40b69e354ea8bd667c295659be8ecd8143bf474c`
**Review Type:** Initial review (S7), epic child of #1217

---

## Executive Summary

The branch adds the documentation family check to the docs-complete validation layer. A new pure module, `.claude/lib/docs/DocsFamilyCheck.psm1` (284 lines), exports `Read-DocsFamilyEvidence`, `Get-DocsFamilyStatus`, and `Get-DocsFamilyFinding`. `Invoke-DocsValidation` gains an optional `-FamilyEvidence` parameter and adds the family findings in docs-complete mode only, after the snapshot and ledger guard. `Invoke-DocsValidateCommand` reads the evidence through the context `ListFile` and `TestFile` seams. The coverage command gains a `families` section built by `Get-DocsCoverageFamilySection` and rendered by `ConvertTo-DocsCoverageFamilyLine`. `Get-DocsCoverageReport` is unchanged. `DocsLedgerCommands.psm1` grows by two lines. The `docs-plan-ia` skill gains a family-planning step 7 and family lines in `## Result` in all four copies through the generator. The two MCP tool descriptions name the new section and findings. No TypeScript logic changed.

The implementation matches spec `## Behavior` row for row. `DocsCompleteGate.psm1`, the receipt and envelope schemas, the merge hook, and the Jest configuration files are byte-identical to the merge base. All five module and bundle pairs are byte-identical. The generator `-Check` reports no drift.

Reviewed evidence: the PR context summary and appendix (generated 2026-11-24 07:45:56 UTC at `40b69e354`), the full branch diff (64 files), the feature evidence under `evidence/{baseline,qa-gates,other}/`, the executor self-review, and the review's own checks. These checks were byte comparisons, the generator check, logical line counts, a root Jest coverage run, a full parallel Pester gate re-run, and a real-filesystem probe of the family evidence path.

**What changed:**
- New `DocsFamilyCheck.psm1`, wiring in `DocsValidation.psm1`, `DocsValidateCommands.psm1`, `DocsCoverageReport.psm1`, and `DocsLedgerCommands.psm1`, plus five bundle mirrors and one `core.json` entry.
- `docs-plan-ia` step 7 and `## Result` family lines (source plus generated and bundle copies); two MCP description strings.
- New Pester suites `DocsFamilyCheck.Tests.ps1`, `DocsValidation.Families.Tests.ps1`, `DocsValidateCommands.Families.Tests.ps1`, and `DocsCoverageReport.Families.Tests.ps1`. The opt-in `-RequiredFamily` and `-LegacyExclusion` parameters were added to `New-DocsLedgerTestProfile`. Jest cases were added in two files. One architecture bullet was added.

**Top 3 risks:**
1. CI has not run: no PR exists yet, so the integration-lane suites (`DocsCompleteIntegration.Tests.ps1`, `DocsReferenceIntegration.Tests.ps1`), which the launcher refuses locally, are unconfirmed at the head (spec AC-26 integration stage).
2. Every consumer repository whose profile was seeded by `docs-init` after #1218 (ten required families, no pages) will fail docs-complete once this lands, until it adds pages or exclusions. This is the intended behavior. The `docs-plan-ia` step and the coverage `families` section give the remediation path.
3. The root-file probe uses `System.IO.File.Exists`, which is case-insensitive on Windows and default macOS file systems. A lowercase `security.md` satisfies the `SECURITY.md` rule there and not on Linux (see the Minor row).

**PR readiness recommendation:** **Ready** — no Blocker or Major finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` (and its bundle copy) | whole file | The file is at 762 logical lines (advisory tier, at or above 700). It was 758 before the epic, 760 at the merge base, and 762 at head; this item added 2 lines, within the spec cap of about three. | No action required in this item. A later split of the coverage or ledger command group would restore headroom. | File-size advisory tier; below the 800-line hard limit, and the file is not listed in `config/file-size-baseline.json`. | `awk 'END{print NR}'` = 762; `scope-invariants.2026-11-24T07-06.md` check 5. |
| Minor | `.claude/lib/docs/DocsFamilyCheck.psm1` | `Read-DocsFamilyEvidence`, line 127 | The root-file rule calls `TestFile` with `SECURITY.md` and `CODEOWNERS`. The production seam (`Test-DocsContextFile` in `Invoke-DocsCommand.ps1`) is `[System.IO.File]::Exists`, which is case-insensitive on NTFS. A real-filesystem probe on this Windows host found that a root `security.md` satisfied `SECURITY.md` (`RootFile SECURITY.md -> True`). The same repository fails on a Linux runner. Elsewhere the module compares names ordinally. | Optional, in a later item: confirm the exact root entry name ordinally, for example by listing the root through `ListFile` and matching `SECURITY.md` with `-ceq`, or state the platform-dependent behavior in spec D7. | Platform-dependent outcome for one file-name case. GitHub accepts `SECURITY.md` case-insensitively, so the practical impact is small. Spec D7 names the file without stating case handling. | Review probe over a scratch tree with `Get-DocsContextFileList` and `Test-DocsContextFile` as the seams. |
| Info | `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | line 325 | The sorted key assertion is `deferred, families, parity, placeholders, precision_limits, stale_pages, totals, undocumented`. Spec AC-15 lists seven keys without `placeholders`, which the merged sibling #1219 added. The test also expects the `families:` zero line at `$lines[-5]` and `parity` at `$lines[-6]`, and no assertion was removed. | None. | Spec Risk "coexistence with docs-prose-markdown-lint" anticipated the coverage key test overlap; every key the AC names is asserted. | Diff of the test file; `final-pester.2026-11-24T06-53.md` run 1. |
| Info | `.claude/lib/docs/DocsFamilyCheck.psm1` | `Get-DocsFamilyStatus`, line 209 | `missing_root_files` is filled for a non-excluded `security` entry whatever its `required` value. `DOCS_FAMILY_ROOT_FILE_MISSING` is emitted only for `required: true`. A `required: false` security family therefore shows missing root files in the coverage section and produces no finding. | None. | Matches spec `### Family status` and the findings table; recorded as executor decision 4 (`decisions.2026-11-23T13-10.md`). | Code lines 209 and 264-270; test `reports no root-file finding for an optional security family`. |
| Info | `.claude/lib/docs/DocsFamilyCheck.psm1` | `Get-DocsFamilyFinding`, lines 258-259 and 275 | `related_ids`, `related_paths`, and the legacy `related_paths` are filtered through the identifier pattern and `Test-DocsRelativePath`, so a malformed id or path is dropped from the related arrays instead of failing `New-DocsFinding`. The #1218 schema validates these values before this code runs. | None. | Defensive filtering; the message still names the raw value. | Code lines 258-259, 275. |
| Info | `.claude/lib/docs/DocsValidation.psm1` | lines 359-361 | The family findings are added after the `$index -ge 2` block and outside the `$null -ne $view -and $null -ne $ledger` guard, in docs-complete mode only. This placement implements spec D3. | None. | Verified by the snapshot-absent and ledger-absent cases and the three other-mode cases. | `DocsValidation.Families.Tests.ps1` lines 192-214. |
| Info | `.dev/potential/promoted/2026-11-23-docs-findings-limit-envelope-schema.md` | new file | The branch carries the promotion record of the out-of-scope `FINDINGS_LIMIT` envelope defect (filed as #1230), as spec D13 requires. | None. | Out of scope per the delegation and spec D13. | `decisions.2026-11-24T05-07.md` decision 2. |

No Blocker or Major finding. The Warning, Minor, and Info rows are non-blocking.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `DocsFamilyCheck.psm1` keeps I/O behind the two scriptblock seams. `Get-DocsFamilyStatus` and `Get-DocsFamilyFinding` are pure. `$null` evidence reads every directory as empty and every root file as absent, so a missing family is never reported present (fail closed).
- Directory keys trim trailing `/` and use ordinal dictionaries. Page matching is ordinal `StartsWith("<dir>/")` plus ordinal `EndsWith('.md')`, and legacy paths are excluded with `-ccontains`. Each distinct directory is listed once.
- The real-filesystem probe confirmed several behaviors with the production `Get-DocsContextFileList` seam. The listing is recursive and repository-relative. Nested `docs/architecture/adr/0001.md` counted for both `docs/architecture` and `docs/architecture/adr/`, with the trailing slash trimmed. `docs/securityx/a.md` did not count for `docs/security`. `.png` did not count. A legacy-excluded page left its family `missing`. A family directory absent on disk yielded an empty listing and `DOCS_FAMILY_PAGE_MISSING`. `.github/CODEOWNERS` did not satisfy the `CODEOWNERS` rule.
- `Get-DocsCoverageReport` is unchanged. The `families` key is assigned in `Invoke-DocsCoverageCommand` after `placeholders`, and the family text lines are appended by one delegating line in `ConvertTo-DocsCoverageReportLine`. Both are confined to named functions, so the merge with #1219 needed no production conflict resolution.

#### API and safety notes

- Exports are the three spec functions in `DocsFamilyCheck.psm1` and the two new functions in `DocsCoverageReport.psm1`. `-FamilyEvidence` is optional with default `$null`, so existing callers are unaffected.
- Module conventions hold: `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, column-0 imports with `-ErrorAction Stop`, and the convention sentence in help. The `ClaudeLibModuleConvention` and `DocsNeutrality` suites pass in the gate.

#### Error handling and logging

- A throwing seam inside `Invoke-DocsValidateCommand` or `Invoke-DocsCoverageCommand` propagates to the existing catch, which returns `DOCS_CLI_RUNTIME` (exit 3). No new catch was added.

### TypeScript implementation audit

- Description strings only in `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts`; no logic change and no new file. Jest cases assert the descriptions and the pass-through of a `families` result and family findings, with summary counts.

### Skill text audit

- Step 7 of `docs-plan-ia` names `required_families`, the coverage `families` section, `SECURITY.md`, `CODEOWNERS`, `exclusion`, and `legacy_exclusions`. It follows the element-assignment steps, and `## Result` gains family lines. The source and its codex bundle copy share one hash, and the generated `.claude` copy and its bundle copy share another (the generator applies substitutions). `-Check` reports no drift.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `evidence/qa-gates/final-pester.2026-11-24T06-53.md` — full parallel gate: 29721 passed, 0 failed, 18 skipped; `DocsFamilyCheck.psm1` 100% (95/95).
- `evidence/qa-gates/review-pester-gate.2026-11-24T08-29.md` — the review's full parallel gate re-run at head `40b69e354` (see the policy audit for counts).
- `evidence/qa-gates/final-jest.2026-11-24T06-58.md` and `evidence/qa-gates/review-jest-root.2026-11-24T07-56.md` — extension and root Jest runs, 0 failures; the two docs TypeScript files are at 100% lines.
- `evidence/qa-gates/final-pytest.2026-11-24T07-02.md` — 17104 passed, including the four push-down contract files (43 cases).
- `evidence/other/r1-fixture-inventory.*.md` — every docs-complete fixture found by search, each with its disposition; no fixture needed a page or exclusion because `New-DocsLedgerTestProfile` now declares no families by default.

### Quality assessment

- **Determinism:** in-memory profiles and recording contexts; no clock, network, or temporary file. The scope-invariants check 7 found no temporary-file token.
- **Isolation:** one behavior per `It`; the suites cover every row of the spec findings table and every listed edge case.
- **Discrimination:** the assertions check exact codes, pointers, `related_ids`, `related_paths`, ordering, and the recorded seam calls, so a change in any of these fails a test. The no-family parity test compares the full context call log of docs-complete with matrix mode, which reads the same inputs.
- **Diagnostics:** Arrange-Act-Assert comments and `-Because` clauses on ordering assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | The diff contains no credential or token. |
| No unsafe subprocess or command construction | ✅ PASS | No process call added; file access only through the context seams. |
| Input validation at boundaries | ✅ PASS | Non-dictionary entries are ignored; related ids and paths are validated before `New-DocsFinding`. |
| Error handling remains explicit | ✅ PASS | Fail-closed evidence handling; seam failures propagate to the existing runtime handler. |
| Configuration / path handling is safe | ✅ PASS | Relative POSIX paths; `Get-DocsContextFullPath` resolves under the repository root. |
| Gate integrity | ✅ PASS | `DocsCompleteGate.psm1`, the receipt and envelope schemas, and `enforce-docs-complete-gate.ps1` are unchanged (`git diff --exit-code` exit 0). |

---

## Research Log

No external research was performed. One real-filesystem probe exercised `Read-DocsFamilyEvidence`, `Get-DocsFamilyStatus`, and `Get-DocsFamilyFinding` with the production `Get-DocsContextFileList` and `Test-DocsContextFile` seams over a scratch tree. The probe created the tree in the session scratch directory and removed it afterwards.

---

## Verdict

The implementation meets the spec. No blocking finding exists. The Warning, Minor, and Info rows are non-blocking. The branch is ready for a PR to the integration branch; the integration-lane suites and the CI quality checks remain to be confirmed at the PR head.
