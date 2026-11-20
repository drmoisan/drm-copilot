# Code Review: Documentation reference generator (#1024)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-reference-generator-1024`
**Feature Folder Selection Rule:** Named by the caller; matches issue #1024 and the branch name; single-version feature (no `vN/` folder).
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `a94dea9a4`, the PR #1072 merge for issue 1022)
**Head Branch:** `feature/docs-reference-generator-1024-r2` (head `e273e2adb`, equal to the remote branch; working tree clean before this review; no pull request exists yet)
**Review Type:** Re-review at the exit of remediation cycle 1 (inputs `remediation-inputs.2026-11-04T14-13.md`)

---

## Executive Summary

The branch adds the `generate-reference` subcommand of the documentation-estate tooling: six PowerShell modules under `.claude/lib/docs/` (`DocsReferencePlan`, `DocsReferenceRender`, `DocsReferenceMarkers`, `DocsReferenceFrontMatter`, `DocsReferenceWriter`, `DocsReferenceReport`), one dispatch row in `Invoke-DocsCommand.ps1`, byte-identical bundle copies of all seven files, six `core.json` entries, twelve new Pester suites with one test-support module, and a one-test edit of the 1023-owned `DocsWriteBoundary.Tests.ps1`. The item diff is `git diff a94dea9a4..HEAD` (78 paths, of which 50 are feature-folder Markdown). The integration tip, including issue 1022, is merged into HEAD (`0eed552e7`), so the diff holds only 1024 work.

Since the 2026-11-04T14-03 review, remediation cycle 1 changed three non-Markdown files (`git diff --name-only 0eed552e7..HEAD`): `.claude/lib/docs/DocsReferenceFrontMatter.psm1`, its bundle copy, and `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1`. The broad `try`/`catch` in `ConvertTo-DocsReferenceFrontMatterText` is replaced by a pre-check through the new private predicate `Test-DocsReferenceCanonicalNumberRejected`; seven test cases pin the routing and the propagation. The previous Minor finding is resolved, and the change introduces no new finding.

The reviewer re-ran PSScriptAnalyzer and the formatter over the 21 changed `.ps1`/`.psm1` files outside the bundle (0 findings, 0 differences), the docs-folder Pester suites with coverage off (policy audit section 6), the push-down contract pytest (34 of 34), SHA-256 parity of all seven source/bundle pairs, logical line counts of the 28 covered files, and a per-file parse of the current coverage artifact (every changed production file at or above 85%).

**What changed in cycle 1:**
- `DocsReferenceFrontMatter.psm1` (253 to 288 lines): new private `Test-DocsReferenceCanonicalNumberRejected` (recursive; `[double]`, `[single]` or `[decimal]` that is non-integral or above 9007199254740991); `ConvertTo-DocsReferenceFrontMatterText` routes only an `extensions` value that the predicate flags to `ConvertTo-DocsJsonText` and lets every other `ConvertTo-DocsCanonicalJson` exception propagate. The exported function list is unchanged.
- `DocsReferenceFrontMatter.Tests.ps1` (296 to 363 lines): seven cases (non-integral and above-bound routing, array- and object-nested routing, unrelated-failure propagation for a non-extensions and an integral-only extensions value, and canonical rejection of `title = 1.5`).

**Top 3 risks:**
1. CI has not run on the PR head (AC-27), and the full-tree PowerShell coverage figure is produced only by that run (policy audit F2, F3).
2. The predicate duplicates the number rule of `ConvertTo-DiscoveryCanonicalFragment` (`.claude/lib/discovery-validation/DiscoveryEncoding.psm1` lines 124-127). If the canonical rule changes, the predicate must change with it; the routing tests would then fail, which limits the risk.
3. `.claude/lib/docs` has two write boundaries (`Invoke-DocsArtifactWrite` for 1023 and `Invoke-DocsReferencePageWrite` for 1024); later siblings must extend the guard set deliberately.

**PR readiness recommendation:** **Conditional Go** - no code defect blocks the PR; the open items are CI-dependent and are tracked in the policy audit and feature audit.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | lines 220-251 (`Test-DocsReferenceCanonicalNumberRejected`) | Resolved: the previous Minor finding (broad catch in the serializer fallback) is closed. The predicate restates the canonical number rule (`Floor(x) -ne x` or `Abs(x) -gt 9007199254740991` for `[double]`, `[single]`, `[decimal]`), and the type sets of `ConvertTo-DiscoveryCanonicalFragment` and `Write-DocsJsonValue` are equal, so for every value the JSON writer can render the new routing gives the same output as the old fallback; only a rejected number outside `extensions` now propagates. That case is not reachable from the command path: `Resolve-DocsReferenceFrontMatterValue` casts `owner`, `last_reviewed` and `audience` to strings, sets `diataxis_mode` and `surface_refs` itself, and copies `title` only from the existing front matter, which its help text states is already validated (title is a string in the page-metadata schema). | No change required. | Duplicated rule is small and pinned by the routing tests. 1020 parses JSON numbers as `[long]` or `[double]` (`DocsJson.psm1` lines 127-130), both handled. | `git diff 0eed552e7..HEAD -- .claude/lib/docs/DocsReferenceFrontMatter.psm1`; source of `DiscoveryEncoding.psm1` lines 108-151 and `DocsJson.psm1` lines 187-229. |
| Info | `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1` | lines 297-362 | The new cases use `Mock -ModuleName DocsReferenceFrontMatter` for the two serializers, scoped per `It`; the earlier suites used no mock. The mocks pin the routing contract (call counts) and the propagation of an arbitrary exception, which a real input cannot trigger. | No change required. | Mocking is limited to the two collaborators of the function under test; the `title = 1.5` case and the 24 earlier cases use real code paths. | Source inspection; `evidence/regression-testing/fail-before.2026-11-04T14-51.md` (7 of 31 fail before the fix). |
| Info | `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` | lines 141-149 | The 1023-owned guard expects two `WriteText` invokers (`DocsLedgerMutation.psm1/Invoke-DocsArtifactWrite` and `DocsReferenceWriter.psm1/Invoke-DocsReferencePageWrite`). The assertion remains a set equality, so a third invoker still fails. | No change required. Record the second write boundary in the epic notes. | Recorded deviation in `evidence/qa-gates/scope-and-purity.2026-11-04T04-32.md`; unchanged since the prior review. | `git diff a94dea9a4..HEAD -- tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` |
| Info | `.claude/lib/docs/DocsReferenceMarkers.psm1` | lines 334-361 (`Merge-DocsReferenceBlock`) | Linear `FindIndex` plus `InsertRange` per new block is quadratic in the page line count; `Get-DocsReferencePageElement` groups options under commands with a nested loop. | No change required at expected page sizes. | Performance note only; unchanged since the prior review. | Source inspection. |
| Info | `.claude/lib/docs/DocsReferenceWriter.psm1`, `DocsReferencePlan.psm1` | parameter `-Profile` | The spec-mandated parameter name `Profile` shadows the automatic `$PROFILE` variable inside those functions. | No change required. | Readability note only; the automatic variable is not used. | Source inspection; PSScriptAnalyzer reports no finding. |

No Blocker, Major or Minor findings. No covered file in the branch diff reaches the 700-line advisory tier (largest: `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1` at 646 logical lines; largest production file `Invoke-DocsCommand.ps1` and its bundle copy at 468; largest new module `DocsReferencePlan.psm1` and its copy at 411), so no file-size Warning row applies. `config/file-size-baseline.json` is not in the diff.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The cycle-1 change replaces exception-driven control flow with an explicit pre-check, so the fallback can no longer hide an unrelated serializer failure. The predicate is private, has comment-based help, `[CmdletBinding()]` and `[OutputType([bool])]`, and collects children into a `List[object]` so nested containers are not unrolled.
- Purity is enforced structurally: `DocsReferenceBoundary.Tests.ps1` parses every `DocsReference*.psm1` module and rejects filesystem, clock, randomness and `Invoke-Expression` commands; the new predicate adds no command of those kinds (the suite passes in the reviewer run).
- Ordering and matching remain ordinal and case-sensitive (`-ceq 'extensions'` in the new routing condition); no `Sort-Object` in production code.
- 1021 functions are reused for fence classification and front-matter parsing and validation; the writer computes every page before any write and re-checks each target immediately before writing.

#### API and safety notes

- Exports are unchanged (`Export-ModuleMember` lists the same four functions in `DocsReferenceFrontMatter.psm1`); the predicate is not exported.
- PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: 0 findings over 21 files; `Invoke-Formatter` comparison: 0 differences (reviewer run at HEAD). The changed lines were also inspected for operator spacing, which the repository formatter settings do not check; none found.
- The source and bundle copies of `DocsReferenceFrontMatter.psm1` have equal SHA-256 (`9ADC52ABED98...`).

#### Error handling and logging

- Module scope sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`.
- No broad catch remains in the six modules. The snapshot-element catch in `ConvertFrom-DocsReferenceSnapshotText` converts a rebuild exception into `REFERENCE_SNAPSHOT_INVALID` with the message, and the `WriteText` catch produces `REFERENCE_WRITE_FAILED`; both are explicit.
- An exception from `ConvertTo-DocsCanonicalJson` now propagates to the 1020 entry boundary (`DOCS_CLI_RUNTIME`, exit 3), as the updated `.DESCRIPTION` states.
- No logging is added, which matches the spec (`Logging: none`).

---

## Test Quality Audit

The twelve suites cover every public function with example-based tests and seeded property tests (seeds 11, 23, 47, 101, 211), every finding code, every exit code, conflict on create and on update, an injected `WriteText` exception, and an end-to-end run of the 1021 `check` subcommand. Cycle 1 added seven cases to `DocsReferenceFrontMatter.Tests.ps1` (31 tests in the suite).

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1` - seven new cases; reviewer run results are in the policy audit section 6.
- `evidence/regression-testing/fail-before.2026-11-04T14-51.md` - the seven new cases fail against the unchanged module (31 total, 7 failed), and every earlier case passes.
- `evidence/qa-gates/pester-docs.2026-11-04T15-25.md` - `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs`, 1666 of 1666; this run wrote the current `artifacts/pester/powershell-coverage.xml` (JUnit `tests="1666"`, file time 15:24Z, after the last production commit `b025f925a` at 14:56Z).
- `evidence/qa-gates/coverage-delta.2026-11-04T15-25.md` - FrontMatter 100% (77/77 before, 90/90 after); `Invoke-DocsCommand.ps1` 87.82% before and after; AST mapping shows 22 of 22 instruction-bearing lines in the two changed function bodies covered. The reviewer parse of the artifact confirms these figures and 100% for the other five new modules.
- `evidence/regression-testing/pester-shuffle.2026-11-04T15-28.md` - three seeded file orders over five suites, 125 of 125 each.
- `evidence/qa-gates/mirror-identity.2026-11-04T15-25.md` and `push-down-contracts.2026-11-04T15-25.md` - parity and contract evidence, re-verified by the reviewer.

### Quality assessment prompts

- **Determinism:** in-memory values only in the new cases; no clock, random, file or environment input.
- **Isolation:** mocks are scoped to each `It` through `-ModuleName`; the shuffled runs show no order dependence.
- **Speed:** each new case runs in milliseconds (fail-before evidence).
- **Diagnostics:** exact-message `Should -Throw -ExpectedMessage` and `Should -Invoke ... -Exactly -Times 0` assertions name the violated routing.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential, token or host name in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | No process start, no `Invoke-Expression`; the boundary suite asserts both. |
| Input validation at boundaries | ✅ PASS | Path options validated with `Test-DocsRelativePath` (exit 2); snapshot and profile schema-validated; the predicate accepts `$null`, strings, dictionaries, custom objects and enumerables. |
| Error handling remains explicit | ✅ PASS | The broad catch is removed (cycle 1); canonical serializer exceptions propagate unchanged, asserted by two propagation tests. |
| Configuration / path handling is safe | ✅ PASS | Repository-relative POSIX paths; no absolute path reaches output; unchanged in cycle 1. |
| Rendered Markdown cannot inject markers, HTML or links | ✅ PASS | Consumer strings pass `ConvertTo-DocsReferenceSingleLine` and `ConvertTo-DocsReferenceCodeSpan`; unchanged in cycle 1. |

---

## Research Log

No external research was required. The review compared the new predicate with `ConvertTo-DiscoveryCanonicalFragment` and `Write-DocsJsonValue` in the repository source.

---

## Verdict

The change is ready for the normal PR flow from a code-quality standpoint: no Blocker, Major or Minor finding, analyzer and formatter clean, parity and manifest checks verified, and the previous Minor finding resolved without introducing a new one. The overall review verdict is governed by the CI-dependent items recorded in the policy audit (F2, F3) and the feature audit (AC-27), all `awaiting_ci`.
