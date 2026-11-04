# Code Review: Docs surface analyzers for Python and configuration (#1022)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `06012704f`)
**Head Branch:** `feature/docs-surface-analyzers-python-config-1022-r2` (head `fc4f2e8d4`; working tree clean apart from this review's artifacts; no pull request yet)
**Review Type:** Initial full-branch review

---

## Executive Summary

The review covers the full branch diff against the epic integration branch (`git diff 06012704f...HEAD`, 114 paths). The head commit `fc4f2e8d4` merges the integration tip, which carries siblings #1020, #1021 and #1023; `git merge-base --all` returns the single commit `06012704f`, equal to the integration tip, so the item diff excludes the siblings' own changes. The three shared files were inspected at their merged state: in `.claude/lib/docs/DocsAnalyzerRegistry.psm1` the five 1022 rows sit directly under `# --- 1022: Python and configuration analyzers ---` in identifier order and above the untouched 1033 anchor; in `.claude/lib/docs/Invoke-DocsCommand.ps1` the single `inventory` row sits under `# --- 1022: inventory ---`, between the intact 1021 `check` row and the intact 1023 rows; in `pack-manifests/core.json` the 18 1022 lines follow the sibling entries with no duplicate path.

The branch adds eighteen PowerShell modules under `.claude/lib/docs/` (the seventeen specified modules plus `DocsPythonBindings.psm1`, split from `DocsPythonSyntax.psm1` under the 500-line rule in the spec's `## API / CLI Surface`), byte-identical bundle copies of the eighteen modules and the two edited 1020 files (20 pairs, equal git blob ids), 18 `core.json` lines, 19 Pester suites, two JSON corpus fixtures, and feature-folder documentation. No `.py`, `.ts`, `.js`, `.cs`, `.sh` or `.bats` file is in the diff, so the approved exception permitting one Python-native analyzer was not used.

The reviewer re-ran PSScriptAnalyzer and the formatter over the 39 changed `.ps1`/`.psm1` source files (0 findings, 0 differences), the docs Pester folder without coverage, the module-convention and no-Python-invocation suites (39 of 39), the push-down contract pytest (34 of 34), and the evidence-location validator (exit 0). Counts are in `policy-audit.2026-11-04T03-37.md` section 6.

**What changed well:**
- Strict purity boundary: `DocsInventory.psm1` is the only new module that references the command context (reviewer search for `Context.ReadText|ReadBytes|ListFile|WriteText|UtcNow|TestFile` over the eighteen modules matches only that file), and no new module calls `Set-Content`, `Out-File`, `New-Item`, `[System.IO.File]`, `Start-Process` or `Invoke-Expression`.
- Every element is built through 1020 `New-DocsSurfaceElement -SourceText`; no 1022 module computes a digest, which keeps `source_sha256` identical across the scanner and the future native analyzer (1031).
- Diagnostic codes conform to the merged 1020 grammar `^[A-Z][A-Z0-9_]*$` (decision D-1022-exec-1); the 1020 `New-DocsDiagnostic` validator would throw otherwise, and the suites exercise every code.
- Seeded property tests cover every pure exported function, with the seed in each `-Because` text; the inventory property suite permutes `ListFile` order and switches the host culture to prove byte-identical, ordinal output.

**Top 3 risks:**
1. Per-file coverage for the PR head is CI-dependent (S22, U14). The local JaCoCo artifact, written by the executor's full single-process run before the final merge commit, reproduces the recorded figures exactly (99.22% to 100% per new module); the `windows-latest` shard report is the source the spec names.
2. `Invoke-DocsInventoryCommand` reads each selected file in full through `Context.ReadBytes` before `New-DocsCapturedInput` applies the 1 MiB per-input bound, so a very large file under a source root is held in memory once before it is rejected. This matches the spec's flow (step 6) and the 256 MiB aggregate bound stops the run after the read; it is recorded as Info.
3. The lexical scanner has a documented precision limit (`## Precision Limit`); constructs outside it are diagnostics or listed as undetectable, and 1023 records the limit as a `deferred` ledger entry. This is a design property, not a defect.

**PR readiness recommendation:** **Ready for PR, pending CI.** No autonomous finding. The only blocking items are the CI-dependent criteria S22 and U14 (`awaiting_ci`).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/docs/DocsJsonSchemaKeys.psm1`, `DocsTomlKeys.psm1`, `DocsYamlKeys.psm1`, `DocsPythonTokens.psm1`, `DocsSourceText.psm1` and others | for example `DocsJsonSchemaKeys.psm1` line 82 (`$escaped -eq 'u'`), `DocsTomlKeys.psm1` lines 55-149 | Several comparisons use the case-insensitive `-eq`/`-ne`/`-split` on single punctuation characters, integers, internal token-type constants and, in one place, the JSON escape letter `u`. The spec's `### Rules for every analyzer` states that every comparison of source text uses `-ceq`, `-cne`, `-clike` or `-cmatch`. | Optional: switch the character comparisons to `-ceq`/`-cne` so the module text matches the rule literally. | No behavioral effect: punctuation and digits have no case, token types are internal constants, and `DocsJsonSchemaKeys` runs after `ConvertFrom-DocsJsonText` has validated the document, where only lowercase `\u` is a legal escape. The case-and-culture property test (S21) passes. | Reviewer AST scan of `BinaryExpressionAst` operators in the eighteen new modules |
| Info | `.claude/lib/docs/DocsInventory.psm1` | `Invoke-DocsInventoryCommand`, lines 229-237 | Each selected file is read in full through `Context.ReadBytes` before the 1 MiB per-input bound is applied by `New-DocsCapturedInput`. | None required; a later revision could list sizes before reading if the 1020 context gains a size member. | The spec's command flow (steps 5 and 6) defines this order; the 256 MiB aggregate bound returns exit 3 once exceeded. | Source inspection |
| Info | `.claude/lib/docs/DocsInventory.psm1` | `Select-DocsInventoryRow`, parameter `$Profile` | The parameter name shadows the automatic `$PROFILE` variable inside the function. | Optional: rename to `$DocsProfile`, as the calling function already does for its local. | Function-scope shadowing only; PSScriptAnalyzer reports no finding and behavior is correct. | Source inspection |
| Info | `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/evidence/qa-gates/self-review.2026-11-04T03-27.md` | row 76 | The self-review states that context members are called "through the 1020 `Invoke-DocsContextMember`"; the helper is a private function of 1022's `DocsInventory.psm1` (line 44) with a `[scriptblock]`-typed parameter. | None required for this item. | The construction is the seam the spec permits ("any seam is a `[scriptblock]`-typed parameter declared in the same file") and `enforcement-hooks-no-python-invocation.Tests.ps1` passes; only the evidence wording is inexact. | Source inspection; reviewer run 33 of 33 |
| Info | `.claude/lib/docs/DocsInventory.psm1` | `Invoke-DocsInventoryCommand` | The function does not declare `SupportsShouldProcess`. It performs no I/O itself: its one write goes through the context member `WriteText`, which the 1020 entry script implements with `SupportsShouldProcess` and `$PSCmdlet.ShouldProcess`, and the command defaults to a dry run with an explicit `-Write` opt-in. | None required. | `.claude/rules/powershell.md` line 30 is satisfied at the write primitive, the precedent established in the 1020 and 1023 reviews. | Source inspection; `grep -l SupportsShouldProcess .claude/lib/docs/*` matches `Invoke-DocsCommand.ps1` |

No covered file is at or above the 700-line advisory tier. The largest covered files are `.claude/lib/docs/Invoke-DocsCommand.ps1` at 467 logical lines (edited 1020 file, merged state), `DocsPythonSyntax.psm1` at 370 among the new modules, and `DocsPythonBindings.Tests.ps1` at 369 among the new suites. `config/file-size-baseline.json` is not in the branch diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Module headers follow the 1020 convention: `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` imports with `-ErrorAction Stop`, and the convention token in comment help (`ClaudeLibModuleConvention.Tests.ps1` 6 of 6 in the reviewer run).
- Module-scope `$script:` variables are constants (command name, limits, patterns); no function assigns a `$script:` variable and no `$global:` reference exists.
- Suppressions are limited to `PSUseShouldProcessForStateChangingFunctions` on pure `New-`/factory functions and one `PSUseSingularNouns` on `Invoke-DocsAnalyzerConfigFiles`, whose name is fixed by the registry contract; each carries a justification.
- The 1020 files change by exactly six lines: five registry rows and one dispatch row, each a single line under its anchor, with byte-identical bundle copies.
- Ordinal sorting through `[System.StringComparer]::Ordinal` and case-sensitive operators on Python names and key paths.

#### API and safety notes

- Usage errors that only the command can detect (non-relative `-Profile`, invalid `-Revision`, unknown or non-intersecting `-Analyzer`) return exit 2 with one `DOCS_CLI_ARGUMENTS` finding; profile and revision checks run before any context read.
- The built snapshot is self-validated against `surface-inventory-snapshot` before any write; a failure is a defect guard that returns exit 3.
- Non-template env-family files are withheld by path before any read and reported as `ENV_FILE_NOT_CAPTURED`; S9 is proven with a recording `ReadBytes` wrapper.

#### Error handling and logging

- `Read-DocsInventoryText` catches only `[System.Management.Automation.ItemNotFoundException]` to treat an absent file as absent; any other read failure propagates.
- The command-level catch in `Invoke-DocsInventoryCommand` converts every exception to one `DOCS_CLI_RUNTIME` finding carrying the exception message (exit 3); no error is discarded.
- The `DocsSourceText.psm1` catch rethrows every error except the 1020 `DOCS_IDENTITY_INPUT_INVALID`, which becomes the specified `DECLARATION_INVALID` diagnostic.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- 19 new suites under `tests/scripts/claude-lib/docs/`, one per new module plus `DocsInventoryProperties.Tests.ps1`, mirroring `.claude/lib/docs/`.
- Two committed corpus files read in place: `fixtures/python-surface-corpus.json` and `fixtures/config-surface-corpus.json` (no CR byte in either; CRLF and CR cases are JSON escapes).
- Executor evidence: `evidence/regression-testing/isolation-shuffled.2026-11-04T03-10.md` (three seeded file-order runs), `evidence/regression-testing/isolation-fresh-run.2026-11-04T03-21.md`, `evidence/qa-gates/qa-test-hygiene.2026-11-04T03-23.md`, `evidence/qa-gates/property-census.2026-11-04T03-24.md`, `evidence/qa-gates/qa-pester-coverage.2026-11-04T03-04.md`, `evidence/qa-gates/coverage-delta.2026-11-04T03-04.md`, `evidence/other/golden-vectors.2026-11-03T23-55.md`.

### Quality assessment prompts

- **Determinism:** seeded `[System.Random]` in 18 of 19 new suites (the command suite uses fixed inputs and the fixed in-memory clock); no `Get-Date`, `[datetime]::Now`, `Start-Sleep` or `Mock` in any new suite (reviewer token scan).
- **Isolation:** analyzers receive captured inputs built from in-test strings; the command suite uses the 1020 in-memory context; every suite removes its modules in `AfterAll`.
- **Speed:** the 19 new suites run in about 100 seconds in one process, dominated by the seeded property loops.
- **Diagnostics:** assertions compare codes, blocking flags, element fields and envelope validity, not message text.
- **Temporary files:** no `TestDrive`, `New-TemporaryFile`, `GetTempPath` or `$env:TEMP` in the new suites (reviewer token scan); `evidence/qa-gates/qa-test-hygiene.2026-11-04T03-23.md` records no purity-hook violation.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or host path in the diff; `evidence/qa-gates/qa-forbidden-tokens.2026-11-04T03-25.md`; configuration values never reach the snapshot (S8 marker property). |
| No unsafe subprocess or command construction | ✅ PASS | No interpreter invocation, `Invoke-Expression` or process start; the one `&` call (`DocsInventory.psm1` line 57) is through a `[scriptblock]`-typed parameter declared in the same file, as the spec permits; `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33. |
| Input validation at boundaries | ✅ PASS | Relative `-Profile`, full-object-id `-Revision` and registered `-Analyzer` validated; per-input and aggregate byte bounds; JSON parsed by the strict 1020 reader before key scanning. |
| Error handling remains explicit | ✅ PASS | Strict mode, `Stop` preference, typed catch for absence, command-level conversion to `DOCS_CLI_RUNTIME`. |
| Configuration and path handling is safe | ✅ PASS | Plain `.env` files are never read or hashed (S9); values are skipped by extent in the TOML, env, JSON Schema and YAML scanners. |

---

## Research Log

No external research was required. Repository sources consulted: `spec.md` (version 0.4), `user-story.md`, `plan.2026-10-30T16-46.md`, the evidence records under `evidence/`, `.claude/rules/powershell.md`, `.claude/rules/general-code-change.md`, and the sibling #1023 review artifacts for the ShouldProcess precedent.

---

## Verdict

No Blocker, Major or Minor code finding. Five Info items are recorded; none requires a change. No file-size Warning applies. The blocking items for this item are CI-dependent and are stated in `remediation-inputs.2026-11-04T03-37.md`: the pending-CI criteria S22 and U14, resolved by the `poshqc / PowerShell QC` coverage report on `windows-latest` for the PR head.
