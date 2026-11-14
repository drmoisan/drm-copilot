# Code Review: Documentation page quality checker (#1021)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-page-quality-checker-1021`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `fd6ee4e5a`)
**Head Branch:** `feature/docs-page-quality-checker-1021-r2` (head `95aa64e64`)
**Review Type:** Initial feature review

---

## Executive Summary

The branch adds `Invoke-DocsCommand.ps1 -Command check`, which reads the documentation roots of the docs profile through the command context, decodes pages as strict UTF-8, parses a bounded YAML front-matter subset without a YAML module, validates metadata against the new page-metadata schema, and reports broken links and anchors, Diataxis mode drift and orphan pages as `DOCS_PAGE_*` findings. It also adds the base markdownlint and Vale templates that `init` writes. The reviewer read the seven new modules and the three anchor edits, re-ran the docs Pester suites and gate suites (800 of 800), PSScriptAnalyzer and the formatter (0 findings, 0 differences over 32 files), the push-down contract pytest (34 passed), and parsed the coverage artifact (100% per new module).

**What changed:**
Seven modules under `.claude/lib/docs/` (2,030 production lines in total), three one-row anchor edits in 1020 files, one schema with its runtime copy, five templates, byte-identical bundle copies, 13 manifest rows, and 14 Pester suites.

**Top 3 risks:**
1. The front-matter flow-sequence fallback mis-handles a double-quoted item that ends in an escaped backslash and reports a valid value as unsupported (F1, Major). A consumer page with such a value fails its build with exit 1.
2. Required CI (`poshqc / PowerShell QC` on `windows-latest`) has not run for a PR head (F2, `awaiting_ci`).
3. Every decodable page is parsed twice per `check` run (N1). This is a performance cost, not a correctness issue.

**PR readiness recommendation:** **Not ready** - one Major finding (F1) requires a source and test change; F2 resolves at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/lib/docs/DocsPageFrontMatter.psm1` (and its bundle copy) | `ConvertFrom-DocsPageFlowSequence`, line 164 | F1: inside a double-quoted flow item the closing quote is accepted only when `$Text[$index - 1]` is not a backslash. An item that ends in an escaped backslash (`"a\\"`) therefore never closes, the scan consumes the `,` and `]`, and the value resolves to `Construct = 'unclosed flow sequence'`, which `ConvertTo-DocsPageScalarFinding` reports as `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED`. The path is reached only when the whole value is not valid JSON, so it requires a JSON-quoted item ending in `\\` mixed with a plain or single-quoted item. Reviewer probe: `["a\\", b]` gives `Ok=False Construct=unclosed flow sequence`; `["a", b]` gives `a`, `b`. | Track escape state while inside a double-quoted item (for example a boolean set by `\` and cleared by the next character) instead of looking back one character. Add a `DocsPageFrontMatter.Tests.ps1` case for `["a\\", b]` (and `["a\\\"", b]`) expecting the two decoded items and no finding. Re-copy the module to the bundle and keep 100% line coverage. | Spec value-form table (spec line 390) admits JSON double-quoted scalars in a single-line flow sequence and lists only nesting and an unclosed `]` as `UNSUPPORTED`; the result contradicts the spec and fails a consumer build on a valid page. | `pwsh -NoProfile -File <scratch>/probe.ps1`; source inspection |
| Minor | `.claude/lib/docs/DocsPageCheck.psm1` | lines 413 and 309 | N1: `Invoke-DocsCheckCommand` calls `Get-DocsPageLinkMap` to collect external link targets, and `Get-DocsPageCheckFinding` calls it again, so the front matter, line model and links of every page are computed twice per run. | Optional: compute the link map once and pass it to `Get-DocsPageCheckFinding` through an optional parameter, keeping the pure function callable without it. Non-blocking. | Pages are bounded at 1 MiB, so the cost is linear and bounded; it does not change results. | Source inspection |
| Info | `.claude/lib/docs/DocsPageCheck.psm1` | line 274 | The public parameter `-Profile` of `Get-DocsPageCheckFinding` shares its name with the `$PROFILE` automatic variable. PSScriptAnalyzer does not flag it because `$PROFILE` is not read-only, and the name is fixed by the spec. | None required. | The executor already renamed the analogous test helper parameter to `DocsProfile`. | PSSA 0 findings; source inspection |
| Info | `.claude/lib/docs/templates/page-check/vale.ini` | line 6 | `BasedOnStyles = Vale, DocsBase` enables Vale's built-in style, which includes spelling checks; with the shipped empty `accept.txt`, a consumer's first Vale run is likely to report project terms until the consumer adds them. | None required; the line is mandated by spec line 581 and the vocabulary is consumer-owned by design. | Recorded for the consumer onboarding documentation. | Spec line 581 |
| Info | `.claude/lib/docs/DocsPageCheck.psm1`, `DocsPageLinks.psm1` | head commit | The final QA commit added one justified `PSUseSingularNouns` suppression and replaced two literal U+2028/U+2029 characters with a constructed pattern so the module is ASCII-only. Both copies are byte-identical to the bundle. | None. | Verified by `sha256sum` of each pair. | `git show 95aa64e64` |

No covered file is at or above 700 logical lines (maximum 696, `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1`), so no file-size Warning applies. No file above 800 lines and no `config/file-size-baseline.json` change.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The rule functions (`Get-DocsPageCheckFinding`, link, anchor, Diataxis and orphan functions) are pure over in-memory page maps; all repository access is in `Invoke-DocsCheckCommand` through context members, so every rule is testable without the filesystem.
- Decoding is strict (`UTF8Encoding($false, $true)`), BOM-tolerant and size-bounded, with typed catches mapped to findings; other read failures propagate to the exit-3 boundary.
- Determinism: candidate paths go through an ordinal `SortedSet`, page sets are sorted with `StringComparer.Ordinal`, and findings are ordered by `Get-DocsOrderedFinding` inside `New-DocsCommandResult`.
- Masking of fenced code, HTML comments and code spans is done once in the line model, and links, anchors and Diataxis step detection all read the masked text.
- The three 1020 edits add one row each under their anchors and nothing else (`qa-anchor-only-diff.2026-11-04T00-16.md`; reviewer diff confirms).

#### API and safety notes

- `-Path` selection keeps profile-level and path-less findings and computes links and reachability over the full page set, so selecting a subset does not create false orphan or broken-link findings.
- Link resolution rejects targets above the repository root (`DOCS_PAGE_LINK_ESCAPES_REPOSITORY`) and skips scheme and `//` targets; backslash is not treated as a separator.

#### Error handling and logging

- `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at module scope; sibling imports use `-ErrorAction Stop`.
- A schema composition failure throws with a code prefix, which the entry boundary reports as `DOCS_CLI_RUNTIME`.

---

## Test Quality Audit

Reviewed: reviewer re-run of 22 docs suites and two gate suites (800 of 800); push-down contract pytest 34 passed; executor evidence for Phases 0-6.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` (77 tests) - exit codes, envelope validation, byte-identical `-Json` output across runs and reversed listing order, 1024-shape fixture.
- `tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1` (107 tests) - value forms, parse codes, line numbers, seeded comment and blank-line insertion. No case covers an escaped backslash at the end of a quoted flow item (F1).
- `tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1` (12 tests) - static import closure with a positive control.
- `evidence/regression-testing/isolation-shuffled.2026-11-03T23-46.md` - seeds 1021, 20261030, 7.
- `evidence/qa-gates/coverage-delta.2026-11-04T00-15.md` - per-module and edited-file comparison.

### Quality assessment prompts

- **Determinism:** fixed seeds printed through `-Because`; no clock, timer or sleep.
- **Isolation:** in-memory command contexts; no temporary files.
- **Speed:** the 800-test reviewer run completed in one Pester process.
- **Diagnostics:** `-Because` texts carry seed and round.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token in the diff; token scan evidence `qa-token-scan.2026-11-04T00-17.md`. |
| No unsafe subprocess or command construction | ✅ PASS | No process, `Invoke-Expression` or dot-sourcing in the page modules (`DocsPageImportIsolation.Tests.ps1`). |
| Input validation at boundaries | ✅ PASS | `-Profile` and `-Path` checked with `Test-DocsRelativePath` before any read; page size bounded at 1 MiB. |
| Error handling remains explicit | ✅ PASS | Typed catches only. |
| Parser correctness against the spec | ❌ FAIL | F1: a valid flow-sequence value form is reported as unsupported. |

---

## Research Log

No external research was required. Repository sources consulted: `spec.md` (`## Front-matter subset`, `## Finding-code catalog`, page-check templates), `.claude/rules/powershell.md`, `.claude/rules/general-code-change.md`, and the 1020 review artifacts for the shared modules.

---

## Verdict

The implementation is well structured, fully covered and passes every local gate. One Major spec-conformance defect in the front-matter flow-sequence fallback (F1) must be fixed with a regression test before the PR. The CI-dependent criteria (F2) resolve through `windows-latest` CI on the PR head.
