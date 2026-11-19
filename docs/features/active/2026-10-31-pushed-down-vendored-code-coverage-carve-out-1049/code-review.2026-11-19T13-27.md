# Code Review: Pushed-Down Vendored Code Coverage Carve-Out (#1049)

**Review Date:** 2026-11-19
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049`
**Feature Folder Selection Rule:** Named by the caller for canonical issue #1049; matches the branch suffix `-1049`.
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration` (merge base `021a52e74999d17c6ae67ed7a32c14958448ceab`)
**Head Branch:** `feature/pushed-down-vendored-code-coverage-carve-out-1049` (`a9fcaf343c8966df05f10a517b0cae9b3d0bb358`)
**Review Type:** Opening review (full branch scope)

---

## Executive Summary

The branch adds a manifest-derived vendored-code exception to the pushed-down coverage rule and implements it in PoshQC. The full diff from the merge base is 121 files (+3281/-112); 40 files lie outside the feature folder.

- New PowerShell submodule `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1` (352 lines) with its byte-identical bundle copy: canonical content hash, manifest parser, status classifier, opt-in reader, population subtraction, report renderer and report writer.
- Call sites only in `PoshQC.Coverage.psm1` (`Get-PoshQCCoverageConfigRoot` returns `ExemptUnchangedPushDownFiles`; `Resolve-PoshQCCoveragePopulation` applies the exemption for the `config` source only) and `PoshQC.Testing.psm1` (one report seam and one call site). Wiring in `PoshQC.psm1` and `PoshQC.psd1`.
- Rule source `scripts/harness-generation/sources/rules/general-unit-test.md` gains the **Vendored push-down files** paragraph and a revised **Enforcement** sentence; the Copilot target now lists `coverage-exclusion-policy`. Generated rule outputs, the feature-review agent step, and six execution-environment brief copies are regenerated.
- Tests: four Pester files (45 + 5 + 10 + 41 new cases), two Jest files (hash parity over a shared corpus, apply hash-of-written-bytes invariant), one shared JSON corpus, one line added to an existing Python parity test.

Evidence reviewed: the PR context summary and appendix at `a9fcaf343`, the feature evidence (`evidence/baseline/`, `evidence/other/`, `evidence/qa-gates/`), the coverage reports `artifacts/pester/powershell-coverage.xml` and `extensions/drm-copilot/coverage/lcov.info` (recomputed by the reviewer), and direct inspection of the production and test sources.

**Top 3 risks:**
1. A listed file reached through a symbolic-link parent directory is hashed through the link and can be reported `exempt`; only the leaf is tested for a reparse point. The hash still has to match the pushed-down content, so the residual risk is limited.
2. PowerShell 7 `ConvertFrom-Json` rejects a JSON object whose keys differ only in case, so a manifest that lists two case-variant paths (possible on a case-sensitive destination) fails the opted-in coverage run instead of classifying the paths. The failure is in the fail-closed direction.
3. CI has not yet run on this head (no PR exists); all results are local evidence.

**PR readiness recommendation:** **Ready for PR** — no blocking finding; CI confirmation at the PR head is the remaining step.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1` | `Test-PoshQCReparsePoint`, lines 67-76; use at line 192 | Only the leaf path is tested for `ReparsePoint`. A listed file whose parent directory is a symbolic link or junction is read through the link and can be `exempt` when its content hash matches. | Optional hardening in a later change: walk the path segments under `Root` and treat any reparse-point segment as `modified`. | The spec defines the rule for "a symlink or reparse point at a listed path", which the leaf check satisfies literally; the hash condition still guarantees the measured bytes equal the pushed-down bytes. Non-blocking. | Source inspection; spec `### Canonical Hash Rule` and `### Status Vocabulary` |
| Minor | `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1` | `ConvertFrom-PoshQCPushDownManifest`, lines 100-105 | `ConvertFrom-Json` (PowerShell 7, without `-AsHashtable`) rejects an object whose keys differ only in case; such a manifest is reported as "not valid UTF-8 JSON" and fails the run. | Optional: parse with `-AsHashtable` (case-sensitive dictionary) or document the limitation in the README. | The behavior is fail-closed (no file is wrongly exempted), but the message names a JSON error rather than the case collision. Non-blocking. | Source inspection; no test on the branch exercises case-variant keys |
| Nit | `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1` | line 107 | The throw for a manifest document that parses to a non-object JSON value is the one uncovered line of the new module (109/110, 99.09%). | Optional: add one `-ForEach` case such as `'[]'` to the invalid-manifest table. | Above every threshold. | `artifacts/pester/powershell-coverage.xml` (reviewer read: LINE missed 1, covered 109); `evidence/qa-gates/coverage-delta-powershell.2026-11-19T13-06.md` |
| Nit | `scripts/powershell/PoshQC/PoshQC.VendoredCoverage.psm1` | `Write-PoshQCVendoredCoverageReport`, line 337 | `Set-Content -Encoding utf8` writes a byte-order mark on Windows PowerShell 5.1 and none on PowerShell 7. | None required; PoshQC targets PowerShell 7+. Use `utf8NoBOM` if 5.1 support of the writer is ever required. | Report readers tolerate a BOM; the canonical-hash code paths read bytes and are unaffected. | Source inspection; `.claude/rules/powershell.md` `## Compatibility` |
| Info | `.github/instructions/general-unit-test.instructions.md` (and bundle copy) | new unnumbered `## Coverage Exclusion Policy` between `## 2.` and `## 3.` | The Copilot target now carries the whole Coverage Exclusion Policy section, not only the new paragraph. | None. | This is the spec's OQ-3 default (`### Rule Source`) and is covered by `## Owner Authorization`; the generator check reports no drift. | `evidence/qa-gates/rules-generation.2026-11-19T11-36.md`; `evidence/qa-gates/final-contracts.2026-11-19T13-07.md` |
| Info | `.claude/agents/feature-review.md` | `## Coverage Verification` step 2 | The new exemption-report step is present in the branch copy; this review applied it manually because the running agent definition is loaded from the default branch. | None. | No `vendored-coverage-exemptions.json` exists (this repository does not opt in), no coverage `exclude` entry changed, and no `.push-down-manifest.json` exists or changed. | `ls artifacts/pester/`; `git diff --name-only` of the configuration files (empty) |

No Blocker or Major findings. No covered file in the diff is at or above 700 logical lines (largest: `PoshQC.Testing.psm1` and its bundle copy, 567), so no Warning row applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- New logic is confined to `PoshQC.VendoredCoverage.psm1`; the existing modules gain one seam parameter and one call site each, matching spec decision AD-1 and keeping `PoshQC.Testing.psm1` at 567 lines.
- `Get-PoshQCCanonicalContentHash` normalizes at byte level in one pass (CR LF to LF, lone CR to LF), keeps a BOM, and uses `SHA256.Create()`. The shared corpus (CRLF, lone CR, BOM, non-ASCII, empty, `abc`) gives identical digests in Pester and Jest.
- `Read-PoshQCFileByte` uses `ReadAllBytes` with `Write-Output -NoEnumerate`, so an empty file produces an empty array rather than `$null`.
- Manifest validation fails closed with a message naming `.push-down-manifest.json` for invalid UTF-8 (strict decoder), malformed JSON, non-semver or unknown-major version, missing `files`, malformed `sha256`, and empty, absolute, UNC, drive-letter, backslash or `..` keys. Unknown fields are ignored.
- Matching is ordinal and case-sensitive throughout (`Dictionary`/`HashSet` with `StringComparer.Ordinal`, `-ceq`, `-cnotmatch`), and output is sorted ordinally.
- The opt-in is read through `PSObject.Properties` in both places, so a configuration record without the property means no opt-in, and a non-boolean value throws a message naming `config/poshqc-coverage.json`.
- The `settings` and `fallback` population sources are untouched; every result now carries `Exemptions` (`$null` unless applied), and `Invoke-PoshQCTest` writes the report only when `Exemptions` is non-null.

#### Design and maintainability

- All file-system and logging effects go through narrow script-block seams with safe defaults, in the existing `Get-PoshQCCoverageConfigRoot` style (`.claude/rules/powershell.md` `## Design Seams`, option 2).
- Functions use approved verbs (`Get`, `Read`, `Test`, `ConvertFrom`, `ConvertTo`, `Resolve`, `Write`) and `CmdletBinding`; PSScriptAnalyzer reports 0 findings.
- Only `Get-PoshQCVendoredCoverageStatus` is exported; helpers stay module-internal.

#### Error handling and logging

- `$ErrorActionPreference = 'Stop'` inside the functions that perform I/O; no catch-all handler except the JSON parse, which rethrows with context.
- An absent manifest logs exactly one warning through the injectable logger.

### TypeScript implementation audit

- No TypeScript production file changed (`git diff <merge-base>..HEAD -- extensions/drm-copilot/src` is empty per `final-jest.2026-11-19T13-07.md`; the branch diff lists only two `test/` files).
- `push-down-apply-hash-invariant.test.ts` drives the real child 4 `runPushDownPipeline` and `applyPushDownPlan` over the in-memory file system with an injected clock, and recomputes the hash independently with `node:crypto`.

### Python implementation audit

- One line added to the `POSHQC_PARITY_PATHS` tuple of `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`; no Python file added (no-new-Python rule met).

### Rule and generator-source audit

- Edits are made in the generator sources (`sources/rules/general-unit-test.md`, `.json`, `sources/agents/feature-review.md`) and in the brief source `.agents/skills/execution-environment/SKILL.md`; generated outputs were regenerated, and `-Surface all -Check` reports no drift.
- The rule text avoids `not used in this repository` and consuming-product names; the guarding pytest modules pass unmodified.
- The policy-file edits fall within `spec.md` `## Owner Authorization` (the vendored paragraph, the Enforcement sentence, the Copilot section inclusion under OQ-3, and the brief sentence).

---

## Test Quality Audit

Final runs at the reviewed code state: Pester 29313 tests, 0 failed, 18 skipped (+101 against the Phase 0 baseline); Jest 6142 (extension) and 6159 (root) passed; pytest 17122 passed. PowerShell coverage of the new module 99.09% lines; changed lines of the modified modules 100% covered; repo-wide PowerShell 96.77% to 96.78%.

### Reviewed test and QA artifacts

- `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.Tests.ps1` — corpus digests, `exempt`/`modified`/`missing`/`unlisted`, case-renamed path, reparse point, destination-added hook, unknown fields, higher minor version, ten invalid-manifest cases, absent manifest with one warning, default seams, report rendering and writing. All file access is in-memory except reads of the committed corpus fixture.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingVendoredReport.Tests.ps1` — report seam receives the exemptions and effective coverage output path; no call without exemptions; an invalid manifest stops the run before Pester.
- `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` (new cases) — opt-in values, subtraction only for `config` with the opt-in, `settings` and `fallback` unchanged, destination-added hook retained.
- `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1` — this repository does not opt in and has no root manifest; every rule, agent, brief and README copy carries the required text.
- `extensions/drm-copilot/test/lib/push-down/push-down-hash-parity.test.ts` and `push-down-apply-hash-invariant.test.ts`.

### Quality assessment prompts

- **Determinism:** No clock, randomness or temporary file; CRLF content is built in code and the committed corpus is ASCII with no CR (asserted by a test).
- **Isolation:** One behavior per `It`; state reset in `BeforeEach`.
- **Speed:** All new suites are in-memory.
- **Diagnostics:** Status assertions name the path; invalid-manifest cases assert the file name in the message.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens; the report excludes absolute paths and host names. |
| No unsafe subprocess or command construction | ✅ PASS | The new module starts no process and uses no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Manifest keys, versions and hashes validated; opt-in must be boolean. |
| Error handling remains explicit | ✅ PASS | Invalid manifest throws a message naming the file; absent manifest warns once. |
| Configuration / path handling is safe | ✅ PASS | No exclusion path is written to any configuration file (test asserts the writer touches only the report); exemption only by exact ordinal path and hash. |

---

## Research Log

No external research was required. Findings derive from the repository tree, the spec and child 4 contracts, and the feature evidence.

---

## Verdict

The vendored-code exemption is implemented as specified: narrow, fail-closed, opt-in, and verifiable through a deterministic report, with the policy text, generated copies and briefs consistent. Test coverage of the new behavior is thorough. The two Minor findings are hardening opportunities that do not affect the fail-closed guarantee. No blocking finding; the branch can proceed to PR authoring, with CI on the PR head as the remaining confirmation.
