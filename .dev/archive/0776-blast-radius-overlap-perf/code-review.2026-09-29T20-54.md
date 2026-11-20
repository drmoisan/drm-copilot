# Code Review: Blast-radius overlap and cost performance (#776)

**Review Date:** 2026-09-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-29-blast-radius-overlap-perf-776`
**Feature Folder Selection Rule:** The only active feature folder in the branch diff; its suffix matches issue 776 in the branch name.
**Base Branch:** `main` (merge base `37096891e1c3b93d222f772f3b1e3581298e0af0`)
**Head Branch:** `bug/blast-radius-overlap-perf-776` (`0f54efe14f48af70a590af4897fd83edb6b61eb8`)
**Review Type:** Initial review (after remediation cycle 1)

---

## Executive Summary

The branch removes the quadratic advanced-function call cost from the PowerShell blast-radius overlap path without changing results. Three production modules and their bundled mirrors change; four Pester files are added. The review inspected the full diff and the four new test files. It re-ran PSScriptAnalyzer, a formatter idempotence check, and the blast-radius Pester directory, re-parsed the JaCoCo coverage file, and recomputed changed-line coverage against the merge base. It also ran six mutants against a scratch copy of the library and a subsumption probe over all fixture paths. The implementation is correct on every route examined, and the test suite discriminates the regressions that matter (ordering, reverse containment, equality lookup, cache store).

**What changed:**
- `BlastRadiusGlob.psm1`: `Test-GlobEntry` and `Get-LiteralPrefix` use one `IndexOfAny` over `[char[]]('*', '?')`; `Test-GlobMatch` reads a compiled regex from `$script:GlobRegexCache` through the simple function `Get-GlobRegex`; `Test-EntryOverlap` scans each entry once and evaluates the two literal nest tests before the pattern match.
- `BlastRadiusConflict.psm1`: new `ConvertTo-PathOverlapRecord` (per-entry facts computed once), `Test-PathOverlapRecordPair` (record-form decision), and exported `Get-OverlappingPathPair`. It finds concrete pairs through three ordinal dictionaries (exact entries of B, trimmed entries of B, trimmed entries of A) probed at every `/` position, decides glob pairs by record comparison, de-duplicates through a `HashSet[long]` of `i * |B| + j` keys, and sorts the keys to restore nested-loop order. `Get-SmallestPathOverlap` keeps a running ordinal minimum over that enumeration.
- `BlastRadiusScheduling.psm1`: `Get-BlastRadiusPairCost` sums `Get-PathPairWeight` over `Get-OverlappingPathPair` (486 to 483 lines).

**Top 3 risks:**
1. AC-3 (CI PowerShell QC duration below 838 s) has no evidence yet; no PR or workflow run exists for the branch.
2. `Test-PathOverlapRecordPair` carries an unreachable concrete-concrete branch whose comment claims parity-test protection; a future caller that routes concrete pairs through it would rely on untested code.
3. `Get-OverlappingPathPair` is dense (several multi-statement one-line loops) to stay under the line target; this raises the cost of future maintenance for the most complex function in the change.

**PR readiness recommendation:** **Conditional Go** — no Blocker or Major finding; the condition is a green PR CI run that records the AC-3 duration.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/blast-radius/BlastRadiusConflict.psm1` | lines 236-248 (`Test-PathOverlapRecordPair`, first branch) | The two-concrete-records branch is unreachable: `Get-OverlappingPathPair` resolves every concrete pair by dictionary lookup and calls this function only when at least one record is a glob. The comment above the function says its four cases are protected by the parity test, which is not true for this case. | Remove the branch and state in the comment that concrete pairs are decided by lookup, or add an `InModuleScope` test that drives the branch directly against `Test-EntryOverlap`. | Dead code with an inaccurate protection claim can be reused later without a test. It is also the only uncovered changed line. | JaCoCo `artifacts/pester/powershell-coverage.xml`: line 245 `mi>0`; changed-line coverage 62/63. Mutant M6 (branch returns `$false`) survived 50 of 50 new tests and the full blast-radius directory contains no other caller (grep of `.claude/lib`, `scripts`). |
| Nit | `.claude/lib/blast-radius/BlastRadiusConflict.psm1` | lines 316-324 (`Get-OverlappingPathPair` dictionary setup) | `$exactB, $trimmedB, $trimmedA = @(1..3 \| ForEach-Object { ... })` and the paired `foreach ($target in @(@($exactB, ...), @($trimmedB, ...)))` loop are compact but hard to read. They depend on PowerShell not enumerating a dictionary on output. | Declare the three dictionaries with three explicit assignments and populate the two B maps with two plain statements, if the line budget allows. | Readability of the most complex function in the change. | Diff inspection; file is 469 lines, so about 30 lines of headroom remain. |
| Info | `.claude/lib/blast-radius/BlastRadiusGlob.psm1`, `BlastRadiusConflict.psm1` | `Test-EntryOverlap` glob/concrete branches; `Test-PathOverlapRecordPair` lines 249-258 | The `Test-GlobMatch` term is logically subsumed by the two literal nest tests: any string a glob matches starts with the glob's literal prefix, which makes one nest test true. After the reorder, `Test-GlobMatch` runs only for pairs it cannot match. | No action on this branch. Removing the term would require a matching change and a parity argument in the Python port (`scripts/dev_tools/compute_blast_radius.py`); consider it as a separate follow-up. | Explains the surviving mutant M4 as an equivalent mutant rather than a test gap, and identifies further possible speed-up. | Probe over 148 glob and 1253 concrete fixture paths (185,444 pairs) found 0 pairs where the pattern matched and neither nest test held. Mutant M4 (term replaced by `$false`) survived. |
| Info | `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | line 51 (`$script:GlobRegexCache`) | Mutable script-scoped state, which `.claude/rules/powershell.md` asks to avoid. The cache is documented, ordinal, pure in effect, and bounded by the number of distinct patterns seen per module instance. | None required. | Recorded for transparency; the deviation is justified by the issue's performance objective. | Module header note; cache tests in `BlastRadiusGlob.RegexCache.Tests.ps1`. |
| Info | `.claude/lib/blast-radius/BlastRadiusConflict.psm1` | line 362 (`[System.Math]::Floor($key / $countB)`) | Decoding uses floating-point division of two `long` values. It is exact for keys below 2^53, far above any realistic `|A| x |B|`. | None required; `[long][Math]::DivRem(...)` would remove the double conversion if the function is touched again. | Correctness margin noted for reviewers. | Diff inspection. |
| Info | `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/plan.2026-09-29T18-10.md` | lines 187-213 | Tasks P2-T6 through P2-T14 remain unchecked; they were superseded by the remediation plan, which records their equivalents (34 of 34 tasks checked). | None required; optionally annotate the original plan as superseded. | Avoids a reader mistaking the original plan for incomplete work. | `grep -c` of unchecked items: 9 in the original plan, 0 in the remediation plan. |
| Info | `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/issue.md` | line 5 (`Status:`) | The status line points to `docs/features/active/blast-radius-overlap-perf/`, which is not the actual folder name. | Correct the path when the folder is next edited. | Traceability. | File inspection. |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The containment rewrite is correct. `X.StartsWith(T + '/')` with `T = Y.TrimEnd('/')` holds exactly when `X[|T|] = '/'` and `X.Substring(0, |T|) = T`. Probing a trimmed-entry dictionary at each separator position of X therefore finds every containing entry, including the empty-`T` case (root `/` or empty entries) through a separator at index 0. Probing both directions (B's trimmed map from A, then A's trimmed map from B) covers both `StartsWith` terms of the concrete-concrete rule.
- Ordering is restored deterministically: each pair is recorded once under `i * |B| + j` in a `HashSet[long]`, so a pair found by both the equality and the containment probe (for example `x/` against `x/`) is emitted once, and repeated entries yield one pair per occurrence.
- Glob pairs are split without double counting: the PathA pass decides glob-A against all of B, and the PathB pass decides glob-B only against concrete A.
- `Get-SmallestPathOverlap` returns `$null` for no overlap, matching the previous `Get-OrdinalSmallestEntry` contract for an empty collection.
- The scheduling change is a three-line substitution that keeps `Get-PathPairWeight` per overlapping pair and leaves the module term unchanged; 132 pinned fixture costs are hash-equal to the pre-change pin.
- Mirrors are byte-identical to the primaries (SHA-256 recomputed in this review).

#### API and safety notes

- One export added, `Get-OverlappingPathPair`, with `[CmdletBinding()]`, `[OutputType([System.Object[]])]`, and mandatory `PathA`/`PathB` parameters that accept empty collections and empty strings, consistent with `Get-SmallestPathOverlap`. The 64 baseline export signatures are unchanged.
- `Get-GlobRegex` and `Test-PathOverlapRecordPair` are deliberately simple functions on the hot path; both carry a comment giving the reason. Neither is exported.
- PSScriptAnalyzer reports 0 findings on all seven changed files.

#### Error handling and logging

- No new error path or catch block. Module-scope `$ErrorActionPreference = 'Stop'` is unchanged. The regex constructor can throw only for a malformed translation, which `ConvertTo-GlobRegexText` prevents by escaping literals; this is unchanged from the previous per-call construction.

---

## Test Quality Audit

The four new Pester files add 50 test cases. The order and parity tests compare `Get-OverlappingPathPair` with a nested `Test-EntryOverlap` reference loop over a 17-entry matrix that includes empty, root, trailing-separator, doubled-separator, glob, sibling-prefix, and repeated entries, in both orientations. Cost tests pin seven values computed against the pre-change nested loop. Whole-fixture equivalence of costs and pair lists is recorded in evidence.

Mutation results from this review, run against a scratch copy of `.claude/lib` (the repository was not modified):

| Mutant | Change | New-test failures |
|---|---|---|
| M0 | none (control) | 0 of 50 |
| M1 | remove the key sort | 3 |
| M2 | remove the reverse containment probe | 5 |
| M3 | do not store the compiled regex | 3 |
| M4 | replace the left-glob `Test-GlobMatch` term with `$false` | 0 (equivalent mutant; see Info finding) |
| M5 | remove the exact-equality probe | 9 |
| M6 | make the concrete-concrete branch return `$false` | 0 (unreachable branch; see Minor finding) |

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1` — order, empty inputs, four cases, reference-loop parity; kills M1, M2, M5.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1` — record-form parity in both argument orders, ordinal minimum, record fields.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.RegexCache.Tests.ps1` — cache hit and miss, ordinal keying, anchoring, cached/uncached agreement; kills M3.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1` — seven pinned costs.
- `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/qa-gates/r1-cost-and-pairs-equivalence.2026-09-29T20-31.md` — 132 cost lines and all pair lists hash-equal to the pre-change pin.
- `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/qa-gates/r1-historical-runs-timing.2026-09-29T20-33.md` and `r1-timing-comparison.2026-09-29T20-33.md` — median 40.09 s against 213.12 s, ratio 5.32.
- `docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/qa-gates/r1-full-suite-pester.2026-09-29T20-41.md` — 5726 cases, 0 failed.

### Quality assessment prompts

- **Determinism:** Pure string inputs; cache tests clear their own keys first.
- **Isolation:** One behavior per `It`; `InModuleScope` only where internal state is the behavior.
- **Speed:** Each new file runs in under 1 s; HistoricalRuns took 46.1 s in this review.
- **Diagnostics:** Joined-string `-BeExactly` comparisons show the full pair list on failure; cost rows carry `-Because` text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credential, token, or URL added. |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation or `Invoke-Expression` added. |
| Input validation at boundaries | ✅ PASS | New export binds typed `string[]` parameters with explicit empty-collection and empty-string allowance. |
| Error handling remains explicit | ✅ PASS | No catch-all added; fail-fast module settings unchanged. |
| Configuration / path handling is safe | ✅ PASS | Paths are treated as data strings only; no file-system access added. Regex patterns are built from escaped glob text and are case-sensitive, as before. |
| Behavior preservation | ✅ PASS | Parity suite (80 tests), HistoricalRuns (9), cost and pair pins, and the export subset check all pass; the Python port is unchanged. |

---

## Research Log

No external research was required. The containment identity and the glob-match subsumption were verified by reasoning and by the probes described above.

---

## Verdict

The change is ready for normal PR flow. The implementation preserves results on every route examined, the exported surface grows by one authorized function, and the tests discriminate the regressions that would matter. The Minor finding (unreachable branch with an inaccurate comment) and the Nit (dense setup statements) can be handled in this PR or in a follow-up. Neither blocks merge.

Merge readiness depends on the PR CI run, which must show the `poshqc / PowerShell QC` job duration below the 838 s recorded in run 1043 (AC-3).
