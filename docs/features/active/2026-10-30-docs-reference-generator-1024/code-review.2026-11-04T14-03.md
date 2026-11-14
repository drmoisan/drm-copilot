# Code Review: Documentation reference generator (#1024)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-reference-generator-1024`
**Feature Folder Selection Rule:** Named by the caller; matches issue #1024 and the branch name; single-version feature (no `vN/` folder).
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `06012704f`, the PR #1071 merge for issue 1023)
**Head Branch:** `feature/docs-reference-generator-1024-r2` (head `5eda92c12`, equal to the remote branch; working tree clean before this review; no pull request exists yet)
**Review Type:** Initial review

---

## Executive Summary

The branch adds the `generate-reference` subcommand of the documentation-estate tooling: six PowerShell modules under `.claude/lib/docs/` (`DocsReferencePlan`, `DocsReferenceRender`, `DocsReferenceMarkers`, `DocsReferenceFrontMatter`, `DocsReferenceWriter`, and `DocsReferenceReport` under the spec's file-size contingency), one dispatch row in `Invoke-DocsCommand.ps1`, byte-identical bundle copies of all seven files, six `core.json` entries, twelve new Pester suites with one test-support module, and a one-test edit of the 1023-owned `DocsWriteBoundary.Tests.ps1`. The item diff is `git diff 06012704f..HEAD` (57 paths, 9050 insertions, 87 deletions, of which 34 paths are feature-folder Markdown).

The implementation follows the specification closely. Pure planning, rendering, marker parsing, merge and front-matter logic are separated from the single I/O module, every context member is invoked through `[scriptblock]`-typed parameters, every ordering and comparison is ordinal and case-sensitive, and the guarded write sequence (test or digest check immediately before each write, stop on the first conflict) matches `### Write semantics`. The reviewer re-ran PSScriptAnalyzer and the formatter over the 21 changed `.ps1`/`.psm1` files (0 findings, 0 differences), the docs-folder Pester suites with coverage off, the push-down contract pytest (34 of 34) and SHA-256 parity of all seven source/bundle pairs.

**What changed:**
- `DocsReferencePlan.psm1` (411 lines): snapshot conversion, glob and prefix path coverage, output-directory resolution, candidate paths, page plan with owner, root and audience resolution.
- `DocsReferenceRender.psm1` (184 lines): single-line normalization, CommonMark code spans, source and property lines, table-driven block bodies.
- `DocsReferenceMarkers.psm1` (382 lines): marker lines, fence-aware body parse through the 1021 fence classifier, block merge with edit records.
- `DocsReferenceFrontMatter.psm1` (253 lines): delimiter split, validation of existing values through 1021 `Test-DocsPageFrontMatter`, value resolution, canonical `<key>: <JSON value>` rendering.
- `DocsReferenceWriter.psm1` (377 lines) and `DocsReferenceReport.psm1` (191 lines): page composition, structural diff, result object, report lines and the command function.
- `Invoke-DocsCommand.ps1`: one row directly under `# --- 1024: generate-reference ---`.

**Top 3 risks:**
1. The local PowerShell coverage artifact no longer describes the executor's full coverage run (policy audit F1); the per-file figures for three of the seven changed production files can only be confirmed from the CI coverage report.
2. CI has not run on the PR head (AC-27); the Linux host cannot reproduce the `windows-latest` shard runs.
3. `.claude/lib/docs` now has two write boundaries (`Invoke-DocsArtifactWrite` for 1023 and `Invoke-DocsReferencePageWrite` for 1024); the 1023 guard test was widened to admit the second, which later siblings must know about.

**PR readiness recommendation:** **Conditional Go** - no code defect blocks the PR; the two open items are CI-dependent and are tracked in the policy audit and feature audit.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | lines 238-242 (`ConvertTo-DocsReferenceFrontMatterText`) | The `try { ConvertTo-DocsCanonicalJson } catch { ConvertTo-DocsJsonText }` fallback catches every exception, not only the documented non-integral-number case inside `extensions`. An unexpected failure of the canonical serializer would be converted silently into non-canonical output. | Narrow the fallback: test for the documented condition before calling the canonical serializer, or rethrow any exception whose message is not the canonical serializer's non-integral-number error. | `.claude/rules/general-code-change.md` asks that broad catch handlers re-raise or add context. The fallback output is still validated downstream by 1021, so the practical impact is low. | Source inspection; help text of the function documents only the non-integral case. |
| Info | `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` | lines 141-149 | The 1023-owned guard now expects two `WriteText` invokers (`DocsLedgerMutation.psm1/Invoke-DocsArtifactWrite` and `DocsReferenceWriter.psm1/Invoke-DocsReferencePageWrite`). The assertion remains a set equality, so a third invoker still fails. | No change required. Record the second write boundary in the epic notes so later children extend the same set deliberately. | The edit is outside the plan's original artifact classification; it was recorded as a deviation in `evidence/qa-gates/scope-and-purity.2026-11-04T04-32.md`. | `git diff 06012704f..HEAD -- tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` |
| Info | `.claude/lib/docs/DocsReferenceMarkers.psm1` | lines 334-361 (`Merge-DocsReferenceBlock`) | Each new block locates its neighbour with a linear `FindIndex` scan and inserts with `InsertRange`, so inserting many new blocks into one page is quadratic in the page line count. `Get-DocsReferencePageElement` in `DocsReferencePlan.psm1` (lines 300-304) groups options under commands with a nested loop. | No change required at expected page sizes; revisit if a consumer snapshot carries thousands of elements per family page. | Performance note only; behavior is correct and deterministic. | Source inspection. |
| Info | `.claude/lib/docs/DocsReferenceWriter.psm1`, `DocsReferencePlan.psm1` | parameter `-Profile` | The spec-mandated parameter name `Profile` shadows the automatic `$PROFILE` variable inside those functions. | No change required; the name is fixed by the spec and the automatic variable is not used in these modules. | Readability note only. | Source inspection; PSScriptAnalyzer reports no finding. |
| Info | `docs/features/active/2026-10-30-docs-reference-generator-1024/evidence/regression-testing/pester-isolation.2026-11-04T04-31.md` | fresh single-process run | The fresh single-process `tests/scripts` run on the Linux host has 409 failures, all in suites outside this diff (pre-existing families #1066 and #1067). The three seeded shuffled runs over the 16 touched suites pass 390 of 390 each. | No change in this item. The #1066 fix (PR #1070) is on `main` but not yet on the epic integration branch. | Host-specific defects outside the item; `windows-latest` CI is authoritative. | Evidence file; `git merge-base --is-ancestor 930486d46 origin/epic/documentation-estate-tooling-integration` returns false. |

No Blocker or Major findings. No covered file in the branch diff reaches the 700-line advisory tier (largest: `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1` at 646 logical lines; largest production file `DocsReferencePlan.psm1` and its bundle copy at 411), so no file-size Warning row applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Purity is enforced structurally: `DocsReferenceBoundary.Tests.ps1` parses every `DocsReference*.psm1` module and rejects filesystem, clock, randomness and `Invoke-Expression` commands, `[System.IO.File]`/`[System.IO.Directory]` type expressions, `$Context` outside the writer and excluded imports, each with an in-memory positive control.
- Ordering and matching use `[System.StringComparer]::Ordinal`, `SortedDictionary`/`SortedSet` with ordinal comparers, `-ceq`/`-cne`/`-ccontains`, and a hand-built anchored glob regex instead of `-like`; no `Sort-Object` is used in production code.
- The writer computes every page before any write, gates writes on the absence of error findings, and re-checks the target (`TestFile` for create, `ReadBytes` digest for update) immediately before each write, as `### Write semantics` requires.
- The file-size contingency was applied when the writer reached 542 lines, moving the diff, result and report functions to `DocsReferenceReport.psm1` with unchanged bodies (`evidence/other/writer-size-decision.2026-11-04T02-53.md`).
- 1021 functions are reused for fence classification and front-matter parsing and validation, so generator and checker read pages identically; no page-metadata pattern constant is defined in 1024 code (asserted by the boundary suite).

#### API and safety notes

- Every function is an advanced function with `[CmdletBinding()]` and `[OutputType()]`; mandatory parameters carry `AllowNull`, `AllowEmptyString` or `AllowEmptyCollection` where the contract allows those values; `ValidateSet` with `IgnoreCase = $false` guards `Position` and `Mode`.
- Exports are explicit (`Export-ModuleMember -Function`); private helpers are not exported. The `PSUseShouldProcessForStateChangingFunctions` suppressions are limited to in-memory `New-` factories and carry a justification.
- State-changing work happens only through the context member `WriteText`, which the 1020 context implements with `Write-DocsFileText`; the 1024 modules contain no filesystem write primitive (reviewer `grep` and the boundary suite).
- PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: 0 findings over 21 files; `Invoke-Formatter` comparison: 0 differences.

#### Error handling and logging

- Module scope sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`; every sibling import uses `-ErrorAction Stop`.
- Expected failure conditions become findings with fixed next actions; a `ReadText` exception other than absence propagates to the 1020 entry boundary (`DOCS_CLI_RUNTIME`, exit 3); a `WriteText` exception is caught once and reported as `REFERENCE_WRITE_FAILED` with the count of pages already written.
- The snapshot-element catch in `ConvertFrom-DocsReferenceSnapshotText` (lines 127-131) converts a rebuild exception into `REFERENCE_SNAPSHOT_INVALID` with the exception message; this is explicit. The front-matter serializer fallback is the one broad catch (Minor finding above).
- No logging is added, which matches the spec (`Logging: none`).

---

## Test Quality Audit

The twelve new suites cover every public function with example-based tests and seeded property tests (seeds 11, 23, 47, 101, 211, one case per seed, seed in the test name and in `-Because`), every finding code in the catalog, every exit code, conflict on create and on update, an injected `WriteText` exception, and an end-to-end run of the 1021 `check` subcommand over generated pages. Command tests run through `Invoke-DocsCommandCli` with an in-memory context whose `UtcNow` and `InvokeProcess` members throw.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocsReference*.Tests.ps1` (12 suites) and `DocsReference.TestSupport.psm1` - reviewer run results are in the policy audit section 6; no temporary file, `TestDrive`, `Start-Process` or sleep (reviewer token scan: 0 matches).
- `tests/scripts/claude-lib/docs/DocsReferenceBoundary.Tests.ps1` - AST boundary, pattern-constant, `DOCS_PAGE_` code and property-test inventory checks, each with an in-memory positive control.
- `tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1` - check-command integration, front-matter contract, envelope validation for five exit cases, determinism and block removal.
- `evidence/qa-gates/coverage-final.2026-11-04T04-00.md` and `coverage-delta.2026-11-04T04-00.md` - executor-recorded 100% per new module; not re-derivable from the current local artifact (policy audit F1).
- `evidence/regression-testing/pester-isolation.2026-11-04T04-31.md` - three seeded shuffled orders pass; single-process host failures are pre-existing.
- `evidence/other/bundle-parity.2026-11-04T03-27.md` and `evidence/qa-gates/pushdown-parity.2026-11-04T03-30.md` - parity and manifest evidence, re-verified by the reviewer.

### Quality assessment prompts

- **Determinism:** seeded `[System.Random]` generators in the support module; properties assert relations, not drawn values; no clock read; in-memory BOM and CRLF fixtures.
- **Isolation:** each suite imports with `-Force` in `BeforeAll` and removes the `Docs*` modules in `AfterAll`; the shuffled file-order runs show no order dependence.
- **Speed:** the docs-folder run completes in minutes on the shared host; no sleeps or waits.
- **Diagnostics:** assertions compare finding codes, pointers, exit codes and page texts with `-Because` text naming the seed or case.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential, token or host name in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | No process start, no `Invoke-Expression`; the boundary suite asserts both. |
| Input validation at boundaries | ✅ PASS | `-Profile`, `-Snapshot`, `-OutputDirectory` validated with `Test-DocsRelativePath` (exit 2); snapshot and profile schema-validated; element identifiers checked with `Test-DocsElementId` before forming markers. |
| Error handling remains explicit | ⚠️ PARTIAL | Explicit findings and exit codes throughout; one broad catch in the front-matter serializer fallback (Minor). |
| Configuration / path handling is safe | ✅ PASS | All paths are repository-relative POSIX strings built by concatenation; `Join-Path` only for `$PSScriptRoot` sibling imports; no absolute path reaches output. |
| Rendered Markdown cannot inject markers, HTML or links | ✅ PASS | Every consumer string passes `ConvertTo-DocsReferenceSingleLine` and `ConvertTo-DocsReferenceCodeSpan`; no rendered line other than a marker starts with `<` (render and writer property tests). |

---

## Research Log

No external research was required. The review relied on the spec, the plan, the evidence artifacts and the repository rules.

---

## Verdict

The change is ready for the normal PR flow from a code-quality standpoint: no Blocker or Major finding, analyzer and formatter clean, parity and manifest checks verified. The one Minor finding (broad catch in the front-matter serializer fallback) is non-blocking and can be addressed in this item if a remediation cycle runs for another reason. The overall review verdict is governed by the two CI-dependent items recorded in the policy audit (F1, coverage evidence) and the feature audit (AC-27), both of which are `awaiting_ci`.
