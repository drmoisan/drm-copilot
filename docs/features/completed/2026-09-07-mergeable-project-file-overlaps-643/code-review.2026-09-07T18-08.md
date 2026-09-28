# Code Review: mergeable-project-file-overlaps (Issue #643)

**Review Date:** 2026-09-07
**Timestamp clock:** UTC (`2026-09-07T18-08` = 2026-09-07 18:08Z)
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643`
**Feature Folder Selection Rule:** Sole active folder whose suffix matches the issue number in the branch name (`feature/mergeable-project-file-overlaps-643`), and the only folder with changed scoping docs in the branch diff.
**Base Branch:** `main` @ `ef83a2e0e26fc8486d6b9be259bf195f0a8e29c9` (merge base)
**Head Branch:** `feature/mergeable-project-file-overlaps-643` @ `515bf1547dcebf029238d3c04ac764ea0462876d`
**Review Type:** Initial review

---

## Executive Summary

This branch removes a scheduling defect in the parallel-orchestration blast-radius model. Two work
items that each append a distinct entry to the same `.csproj` item list were being scored as
contending on two independent signals — a `path_overlap` on the project file and a `module_overlap`
on the assembly whose directory contained it — and were therefore serialized into separate cohorts.
The change addresses both signals and then adds the machinery to resolve the textual conflict that
running such items concurrently will eventually produce.

The implementation is in three parts. First, an optional `mergeable_paths` list is added to both
truth-table copies and applied at exactly one place per runtime: inside the Python `conflicts`
relation and inside the PowerShell `Test-BlastRadiusConflict`, on copies of both radii's `paths`
immediately before the smallest-path-overlap computation. Nothing is removed from any stored record,
so derivation, normalization, the V1/V2/V3 audits, and `detect_escaped_paths` all read exactly the
paths they read before. Second, the .NET manifest family is reclassified at push-down as a structure
signal that suppresses the top-level-directory fallback but contributes no module, so a multi-project
solution derives `{ "config": ["config/**"] }` rather than one module per assembly. Third, a new
three-file PowerShell library resolves a merge conflict confined to project files as a keyed union,
under a never-drop post-condition, with all-or-nothing escalation.

Evidence reviewed: the PR-context summary and appendix at head `515bf154` against base `main`; all 44
evidence artifacts under the feature folder; the full branch diff; and the three coverage artifacts,
which the reviewer parsed directly. The reviewer independently re-ran format, lint, and type check
for Python and TypeScript, the feature's Python and Jest suites, the full blast-radius and
project-file-merge Pester suites, the `claude-lib` module-convention suite, an SHA-256 mirror-parity
check over all 12 published pairs, a 500-line scan over the change set, a suppression-token scan over
the added lines, and `validate_evidence_locations.py`. All passed.

Implementation quality is high. The most consequential design decision is that the merge library
treats project-file text as lines rather than XML: no DOM is constructed and no reserialization
occurs, so indentation, attribute order, BOM, and per-line terminators survive a merge because the
kept lines are the bytes one side wrote. The second-most consequential is that the grammar is
deliberately narrow — a side is parsed only when every one of its lines is an admitted shape, and
anything else escalates. Together those two choices mean the failure mode of an unfamiliar input is
"decline and hand it to a human", not "rewrite the file in a way nobody reviewed".

**What changed:**

- `scripts/dev_tools/_blast_radius_mergeable.py` (new, 160 lines) — the reader, the matcher, and the
  filter. Pure; the first two of its three matching steps delegate to the existing
  `matches_mandate_read` rather than restating them.
- `scripts/dev_tools/_blast_radius_conflicts.py` — the single Python application point, four lines
  inside `conflicts`.
- `.claude/lib/blast-radius/BlastRadiusConflict.psm1` (new, 290 lines) — the PowerShell mirror of the
  above, plus `Get-SmallestPathOverlap` and `Get-SmallestCommonEntry` relocated out of
  `BlastRadius.psm1` to keep the facade under the line ceiling.
- `.claude/lib/project-file-merge/` (new) — `ProjectFileMergeGrammar.psm1` (318), `ProjectFileMerge.psm1`
  (355), `Resolve-MergeableConflict.ps1` (229).
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` (new, 200 lines) —
  the manifest vocabulary and step-2 classification, split out of the derivation core and re-exported
  from it.
- Truth tables, pack manifest, Pester coverage allow-list, Jest per-file threshold, `.gitattributes`,
  the parallel-orchestration rule file, three skills, two agents, and the status-projection template.
- 47 new fixtures and 8 new or extended test suites across three runtimes.

**Top 3 risks:**

1. `Invoke-GitExe` merges stderr into its returned line array (`2>&1`), so a git advisory line on a
   zero-exit call becomes indistinguishable from content. Bounded: every downstream consequence
   pushes toward escalation rather than toward a wrong merge. See finding CR-1.
2. The `app.config` `oldVersion` retarget only rewrites the range form `oldVersion="a-b"`. A legal
   single-version `oldVersion="a"` alongside a chosen higher `newVersion` would be retained
   unchanged, leaving a redirect that does not cover the version it pins. No fixture exercises this
   shape. See finding CR-2.
3. The merge step is exercised only against synthetic fixtures. Its first contact with a real
   consumer-repository conflict is also its first production run. The (a)–(d) skill steps mitigate
   this with `dotnet csharpier check` and `dotnet build` after every resolution and a
   `git reset --hard HEAD~1` revert on failure, which is the right control, but it has not yet been
   exercised end to end. Informational, not a code defect.

**PR readiness recommendation:** **Go** — zero Blocker and zero Major findings; the three Minor and
two Info findings below are appropriate as follow-up work rather than pre-merge work.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` | `Invoke-GitExe`, `$output = & git @GitArgs 2>&1` | stderr is merged into the returned `[string[]]`. On a zero exit code a git advisory or warning line is indistinguishable from stdout content. For `git diff --name-only --diff-filter=U` such a line would be read as a conflicted path; for `git show :N:<path>` it would perturb the never-drop key sets. | Capture stderr into a separate variable and include it only in the throw message, e.g. redirect with `-ErrorVariable` or `2>$null` plus a separate capture, leaving `$output` as stdout only. Add one test that mocks a warning-on-stderr success. | The current shape works because git is quiet on success for these three subcommands, but that is an environment property (locale, `advice.*` settings, `core.quotePath`) rather than a contract. Both failure modes are fail-safe toward escalation, so this is not blocking. | Read of the function body; no test covers a stderr-on-success case in `Resolve-MergeableConflict.Tests.ps1` |
| Minor | `.claude/lib/project-file-merge/ProjectFileMerge.psm1` | `$script:OldVersionRangePattern = '(oldVersion=")([^"-]*)(-)([^"]*)(")'` and `ConvertTo-RetargetedRedirectLine` | The retarget only matches the range form. A binding redirect written as `oldVersion="4.0.0.0"` (a legal single-version form) is retained verbatim when the higher `newVersion` from the other side is chosen, producing a redirect whose old-version coverage does not include the version it now pins. | Either escalate when the chosen side's `oldVersion` carries no `-`, or normalize the single-version form to `0.0.0.0-<chosen>`. Add an `appconfig-singleversion-oldversion` fixture pair either way. | The XML stays well-formed and the file still loads, so the blast radius is a silently narrower redirect rather than a crash. NuGet and Visual Studio both emit the range form, which is why the fixture corpus did not surface it. The written acceptance criterion speaks only of "the `oldVersion` upper bound", so this is a gap in the spec as much as in the code. | `tests/fixtures/project_file_merge/appconfig-newversion-differs.conflicted.config` uses `oldVersion="0.0.0.0-4.0.0.0"`; no single-version fixture exists |
| Minor | `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/` | `file-size-compliance.2026-09-07T18-22.md`, `scope-verification.2026-09-07T19-38.md` | Both artifacts record `Command: git diff c3ffb080 ...`, the pre-rebase merge base, rather than the post-rebase base `ef83a2e0`, and the file-size artifact predates the final PowerShell fix (it lists `Resolve-MergeableConflict.ps1` at 226 lines; the final tree has 229). | On a future rebase, re-run the two scope-shaped gates against the new merge base so the evidence and the audited range agree. | The stale base does not change either conclusion — the reviewer re-ran both checks against `ef83a2e0..515bf154` and reproduced them — but an artifact that names a base the PR is not opened against is misleading to a later reader. | Reviewer scan: zero files over 500 lines; zero diff paths under a forbidden evidence prefix; `wc -l` on the final tree gives 229 |
| Info | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` | `MANIFEST_SUFFIXES`, `isManifestFileName` | Both symbols lost their production consumer in this change: classification now calls `isModuleManifestFileName` / `isNonModuleManifestFileName`. A grep across `extensions/drm-copilot/src/` finds `isManifestFileName` only in the core's compatibility re-export list. | No action now. If a future change confirms no external consumer, remove both and drop the re-export in the same commit. | This is a deliberate backward-compatibility surface and the module docstring says so ("`MANIFEST_SUFFIXES` is the concatenation of the two families, so `isManifestFileName` keeps its previous behaviour"). Recorded so the context is not lost. | `grep -rn "isManifestFileName\|MANIFEST_SUFFIXES" extensions/drm-copilot/src/` — matches only in the definition and the re-export |
| Info | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` | `export const MODULE_MANIFEST_SUFFIXES: ReadonlyArray<string> = []` | The module family is empty, so `isModuleManifestFileName` currently reduces to an exact-name lookup in `MANIFEST_FILENAMES`. | Keep. The empty array is the declared extension point for a future suffix-based module family and is directly asserted by a test, so it cannot silently acquire a member. | An empty constant can read as dead code; it is not, and the test `expect(MODULE_MANIFEST_SUFFIXES).toEqual([])` pins it. | `blast-radius-derive-manifests.test.ts:97` |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- **The application point is a single expression.** `conflicts` gains four lines: read the key, then
  filter both `paths` collections inline in the `_smallest_path_overlap` call. The comment above it
  states the invariant that makes the design safe — the filter returns new tuples and neither radius
  object is rewritten — so a later reader does not have to derive it from the call shape.
- **The matcher reuses rather than restates the mandate-read rules.** `matches_mergeable_path` calls
  `matches_mandate_read` for steps one and two and adds only the third, anchor-stripping step. The
  comment gives the reason: "a divergence would silently split two exclusions that share a
  vocabulary." That is the correct instinct for two features that must agree about what a glob means.
- **The third matching step is justified in prose rather than asserted.** The docstring explains why
  an anchored pattern needs the extra step (an anchored pattern requires a separator and so excludes
  a root-level file) and why a glob entry is never mergeable unless it matches verbatim (pattern
  subsumption is not a comparison this vocabulary supports). Both are the kind of decision that gets
  reverted by accident when it is unexplained.
- **The module docstring is a contract, not a summary.** Purpose, Responsibilities, Invariants /
  Constraints, and Side Effects are all present, and the Invariants section states the two properties
  the rest of the feature depends on: the exclusion changes no radius record, and the key is optional
  and fail-closed.
- **The facade re-export is minimal.** `compute_blast_radius.py` gains one import and one `__all__`
  entry, and the relation reads the key itself rather than accepting a pre-filtered radius, so no
  caller can forget to filter.

#### Typing and API notes

Three public functions, all fully annotated, with `Mapping`/`Sequence` parameter types and concrete
`tuple[str, ...]` / `bool` returns. `from __future__ import annotations` plus a `TYPE_CHECKING`-guarded
`collections.abc` import keeps the runtime import graph unchanged. `__all__` is explicit. The
truth-table key is bound to a module constant, `CONFIG_MERGEABLE_PATHS`, so the reader, its tests, and
the PowerShell mirror all name one string rather than three copies of a literal. Pyright reports zero
errors and no suppression appears anywhere in the Python diff.

#### Error handling and logging

Validation is delegated to the existing `config_string_list`, which raises `TypeError` for a non-list
value and `ValueError` for a blank entry; both are asserted by tests. No `except` clause is added
anywhere in the Python diff, so there is no place for an error to be swallowed. There is no logging,
which is correct for a pure function on a scheduling hot path.

### TypeScript implementation audit

#### What changed well

- **The split is motivated by a stated constraint and pays for itself.** The derivation core was
  approaching the 500-line ceiling; moving the manifest vocabulary and step 2 out leaves the core at
  380 and the new module at 200, and the core's branch coverage rose from 95.83% to 97.50% as a side
  effect of the narrower surface.
- **Every moved symbol is re-exported from the original module.** Eight values and two types are
  re-exported from `claude-blast-radius-derive-core.ts`, so no existing import path breaks. The test
  suite imports `isManifestFileName` both directly and as `coreIsManifestFileName` through the
  re-export, which gates the compatibility surface rather than assuming it.
- **The suppression of the top-level fallback is expressed as data, not as a special case.**
  `classifyProjectDirectories` returns `{ modulePaths, structureObserved }`; a directory carrying only
  a non-module manifest contributes no path but sets `structureObserved`. The alternative — a boolean
  parameter threaded through the caller — would have put the .NET-specific knowledge in the caller.
- **The carriage change is one array append plus one object property.** `mergeable_paths` is appended
  to `CARRIED_KEYS` rather than inserted, and the assembly literal indexes the array positionally with
  a comment explaining that inserting mid-array would shift every existing index. Omission when the
  source lacks the key falls out of `JSON.stringify` dropping `undefined`, which the comment also
  states, so no conditional spread is needed.
- **The new file was added to the Jest per-file threshold map in the same change.** The comment
  states the reason: the map carries no `global` key, so a new production file without its own entry
  would be completely ungated. This is the kind of gap that normally surfaces three features later.

#### Type safety and maintainability

No `any`, no `as any`, no `@ts-ignore`, and no `@ts-expect-error` anywhere in the diff. Exported
arrays are `ReadonlyArray<string>`, exported sets are `ReadonlySet<string>`, and both exported
interfaces have `readonly` members throughout. `compareOrdinal` is exported so the core and the
manifests module sort identically, which is what makes the emitted document byte-stable. TSDoc is
present on every export. `tsc --noEmit` and ESLint both report zero.

#### Error handling and logging

No new failure path is introduced: `classifyProjectDirectories` is total over its input and the
existing `BlastRadiusDeriveError` / `BlastRadiusGuardError` classes are untouched. The forbidden-glob
guard still receives a non-vacuous input, which is asserted by the retained core tests with the
`.csproj`-derived cases re-pointed at a non-.NET manifest.

### PowerShell implementation audit

#### What changed well

- **Line-oriented merging instead of an XML DOM.** This is the decision the whole library rests on.
  Because a kept line is copied rather than re-serialized, BOM, per-line terminators, indentation,
  attribute order, and self-closing spacing all survive without any of them being handled explicitly.
  The one deliberate exception, the `oldVersion` upper bound, is rewritten in place with a regex and
  is called out in the module docstring as the exception.
- **The grammar refuses by default.** `Get-MergeableUnit` returns `$null` unless every line of a side
  is an admitted shape, and the caller turns `$null` into an escalation. The module docstring states
  the reasoning directly: "a mechanical union of a conflict nobody understands is worse than a human
  one."
- **All-or-nothing at two separate points.** Classification runs over the whole conflicted set before
  any file is read, and every file is merged into a `$pending` list before any file is written. The
  comment states the resulting property: a partially merged worktree is not a reachable state. That
  is a stronger guarantee than "we try to clean up on failure".
- **The never-drop post-condition is a real check, not a comment.** `Test-NeverDropPostCondition`
  compares the merged file's unit-key set against the `:1:`, `:2:`, and `:3:` stage texts read from
  git, and a violation escalates without writing. `Get-UnitKeySet` offers the grammar a widening
  window at each position and steps over any line no window parses, so surrounding project structure
  contributes no key and cannot make the comparison pass vacuously.
- **A single executable seam.** Every git invocation goes through `Invoke-GitExe`, which lets the
  test suite mock one function instead of an executable. The docstring says exactly this. See CR-1
  for the one issue with its implementation.
- **The import-order comment is the kind that saves an hour.** `Resolve-MergeableConflict.ps1`
  explains that the nested `-Force` import inside `ProjectFileMerge.psm1` removes an already-loaded
  grammar module and re-imports it into that module's own scope, so importing the grammar first would
  take its commands out of the script's scope. That is a non-obvious PowerShell module-scoping
  behavior and it is documented at the point where reversing the two lines would break the script.
- **The relocation out of `BlastRadius.psm1` preserved the public surface.** `Get-SmallestPathOverlap`
  and `Get-SmallestCommonEntry` were module-private before and are exported from the new module now;
  the facade's `Export-ModuleMember` list is unchanged at six functions, so no consumer's contract
  moved.
- **Coverage measurement was extended in the same change.** All four new files were appended to the
  Pester `CodeCoverage.Path` allow-list, with a comment noting that the list is an explicit per-file
  allow-list so an unlisted file would simply not be measured — and, separately, that the entry script
  is measured like the two modules because its suite dot-sources it behind a guarded entry-point body.

#### API and safety notes

Every function is an advanced function with `[CmdletBinding()]` and a declared `[OutputType]`.
`Write-MergedFile`, the only destructive function, declares `SupportsShouldProcess = $true` and
assembles the byte array *before* the `ShouldProcess` guard, so `-WhatIf` exercises the whole assembly
and suppresses only the write — which is what makes the `-WhatIf` test meaningful rather than a
tautology. Parameters use `[AllowEmptyCollection()]` / `[AllowEmptyString()]` where an empty input is
legal, so an empty conflict set does not fail on binding. All string comparison is
`[System.StringComparison]::Ordinal` or `[StringComparer]::Ordinal`, and the one case-insensitive
comparison (`Get-ProjectFileKind` on a leaf name) is deliberately `OrdinalIgnoreCase` with a comment
explaining that whole-name shapes must settle before the shared `.config` extension is considered.
`Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` are set at module scope in all
four files, and every sibling `Import-Module` carries `-ErrorAction Stop`. The dot-source guard
(`if ($MyInvocation.InvocationName -ne '.')`) follows the existing `Invoke-ReleaseReconciliation.ps1`
precedent and is cited as such.

PSScriptAnalyzer reports zero findings. Notably, the ten findings from an earlier iteration
(`PSProvideCommentHelp` on two relocated helpers, `PSUseOutputTypeCorrectly` on `Invoke-GitExe`,
`PSReviewUnusedParameter` on four mock parameters) were fixed rather than suppressed — no
`SuppressMessageAttribute` appears anywhere in the diff.

#### Error handling and logging

`Invoke-GitExe` throws with the joined output when `$LASTEXITCODE` is non-zero, so a failed git call
stops the run rather than producing an empty result that would read as "no conflicts". The only
`catch` in the whole diff is `catch [System.Text.DecoderFallbackException]`, narrowly typed, returning
`$null` for a documented escalation path rather than swallowing. The entry script's contract is
explicit and unusual in a useful way: it exits 0 for both verdicts and puts the verdict in the JSON
`result` field, reserving a non-zero exit for an unexpected error with the message on stderr. That
separation means a caller cannot confuse "declined to merge" with "the tool broke".

### C# implementation audit

Not applicable. `git ls-files "*.cs"` returns zero paths across the repository. The 37 `.csproj` and
9 `.config` files in the diff are all inert text fixtures under `tests/fixtures/project_file_merge/`
(verified: zero non-fixture project files in the diff). No C# is compiled, analyzed, or covered by
this repository.

---

## Test Quality Audit

The test evidence is unusually complete for a change of this shape, and its strongest property is
that the cross-runtime claims are pinned by shared fixtures rather than by parallel assertions. The
two new `tests/fixtures/blast_radius/` files are consumed by both the Python and the Pester parity
suites through directory globs, so neither suite had to be edited for them and neither can drift from
the other without the fixture failing in one language. Both suites additionally assert a corpus floor
and that the glob reaches every JSON file on disk, so a broken pattern cannot silently empty the
parametrized set.

The reviewer confirmed this rather than assuming it: `test_blast_radius_parity.py` declares
`MINIMUM_FIXTURE_COUNT = 30` and asserts `len(FIXTURE_PATHS) == len(on_disk)`;
`test_parallel_cohort_bash_parity.py` declares `MINIMUM_FIXTURE_COUNT = 20` with the same
double-assertion comment; `BlastRadius.Parity.Tests.ps1` enumerates the same directory and asserts a
minimum count. That is what makes the acceptance criteria which name those suites verifiable without
those files appearing in the diff.

The negative-path corpus is the other notable strength. The merge library has more escalation fixtures
than resolution fixtures: unparseable version, same key at the same version with differing attributes,
a line outside the grammar, an unterminated hunk, invalid UTF-8, and a non-mergeable path beside a
mergeable one. That ratio matches the design intent stated in the module docstring.

One process detail is worth recording as a positive: the PowerShell loop's third restart was triggered
by `Resolve-MergeableConflict.ps1` measuring 84.62% line coverage, below the 85 floor, and the
response was to commit an invalid-UTF-8 fixture and add an `It` covering the
`DecoderFallbackException` branch — raising it to 86.15%. The gate caught a genuinely untested error
path rather than being satisfied by a coverage-shaped edit.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` — 17 cases covering the reader's four
  validation outcomes, both matcher edge cases, the filter, the committed-config shape, the facade
  re-export, four relation behaviors, and three isolation proofs (`validate_blast_radius` symmetry,
  `derive_blast_radius` retention, `detect_escaped_paths` unaffected). The isolation trio is what
  turns "the exclusion is applied only inside the contention relation" from a claim into a test.
- `tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1` — the keyed-union matrix
  (5 item types × 2 syntactic forms), the two `.config` shapes, the never-drop post-condition with
  injected stage texts, and the BOM/CRLF preservation cases. Reviewer-run: passes.
- `tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1` — the entry-script
  contract: one compressed JSON object, three keys, escalation before any read for a non-mergeable
  set, no staging and no commit, and a `-WhatIf` case asserting `Test-Path ... | Should -BeFalse`.
  Reviewer-run: passes.
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts` — the suffix-family
  split, per-suffix classification, the nine-project layout yielding zero module paths and
  `structureObserved = true`, the same layout deriving exactly `{ "config": ["config/**"] }`, a nested
  solution file yielding no module, and a mixed layout retaining a non-.NET manifest directory's
  module. Reviewer-run: passes.
- `tests/scripts/dev_tools/test_parallel_mergeable_cohort.py` — computes the edges from radii through
  the real `conflicts` relation, asserts the edge list is empty for every pair, then asserts
  `compute_cohorts` puts all four keys in one cohort, and finally asserts the committed corpus fixture
  agrees with the computed result. The three-step shape is what prevents the fixture from being a
  restatement of itself.
- `docs/features/.../evidence/qa-gates/coverage-delta.2026-09-07T19-35.md` — baseline-versus-final per
  language with source integers, not just percentages. The reviewer re-derived every figure from the
  coverage artifacts and reproduced them.
- `docs/features/.../evidence/qa-gates/final-qa-loop-outcome.2026-09-07T19-32.md` — per-language stage
  table with restart counts and an explicit ordering statement that the recorded pass of every stage
  occurred after the last source change. The reviewer verified that claim independently: the only
  commit after the post-rebase QA run adds a single documentation file, and the working tree is clean.
- `docs/features/.../evidence/qa-gates/post-rebase-qa.2026-09-07T17-56.md` — the full three-language
  loop re-run on the rebased head, recording that `origin/main` (PR #638) overlapped this feature's
  files only at `.gitattributes` and two files this branch does not touch.

### Quality assessment prompts

- **Determinism:** No wall-clock read, no RNG, no network, no real filesystem in unit scope. Ordering
  is ordinal in all three runtimes, which is what lets the parity fixtures assert identical results.
  The single executable dependency is mocked. The banned-API list (`setTimeout`, `Thread.Sleep`,
  `Date.now()` outside a clock interface) does not appear in the added tests.
- **Isolation:** Each case names one behavior. The Pester suites build fixtures in `BeforeAll` into
  `$script:`-scoped variables rather than sharing mutable state across `It` blocks. Targeted runs in
  isolation pass, which they could not do under order dependence.
- **Speed:** 166 Python cases in 0.38 s; 192 Jest cases in 0.85 s; 488 Pester cases in 26.2 s, of
  which 16.3 s is the pre-existing `BlastRadius.Parity.Tests.ps1`. The new suites are fast.
- **Diagnostics:** Escalation reasons name the offending key and the 1-based hunk line; the corpus
  guards print discovered-versus-expected counts; parity failures name the offending key. A failure
  in this suite tells you where to look.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection over all 10,860 added lines; no token, key, credential, or `.env` file |
| No unsafe subprocess or command construction | ✅ PASS | `& git @GitArgs` splats a `[string[]]`, so no argument is shell-interpreted; there is no `Invoke-Expression`, no string-built command line, and no new `subprocess` call in Python |
| Input validation at boundaries | ✅ PASS | `require_mapping` and `config_string_list` on the truth table; `Get-ProjectFileKind` returns `$null` for any unrecognized leaf name, which the caller converts to an escalation; strict UTF-8 decoding with an explicit typed fallback |
| Error handling remains explicit | ✅ PASS | `Invoke-GitExe` throws on non-zero exit with the joined output; the only `catch` is narrowly typed and feeds a documented escalation; no broad handler anywhere in the diff |
| Configuration / path handling is safe | ✅ PASS | `Join-Path`, `-LiteralPath`, and `[System.IO.Path]::GetFileName` throughout. Conflicted paths originate from `git diff --diff-filter=U` against the index, not from user input; a path git quotes (`core.quotePath`) would fail `Test-MergeablePath` and escalate rather than being written |
| Write path is guarded and reversible | ✅ PASS | `SupportsShouldProcess` on the only write; nothing is staged or committed by the script, so a resolution is inspectable before it becomes history; the skill's step (c) reverts with `git reset --hard HEAD~1` if the formatter check or build fails |
| No coverage exclusion of production code | ✅ PASS | Both coverage-configuration edits add gating (four PowerShell files to the Pester allow-list, one TypeScript per-file threshold). No `exclude`, `omit`, or `coveragePathIgnorePatterns` entry appears in the diff |
| Agent allowlist scoped to the new step | ✅ PASS | `parallel-orchestrator.md` gains exactly four entries — the single `pwsh -NoProfile -File .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` shape plus `dotnet tool restore`, `dotnet csharpier check`, and `dotnet build` — and the surrounding prose states that they are scoped to that step and to no other |
| Fail-closed rollout | ✅ PASS | An absent or empty `mergeable_paths` reproduces pre-change behavior exactly, asserted in both Python and Pester. A destination that has not received the published truth table is unaffected, and the merge step escalates rather than resolving whenever the key is absent |

---

## Research Log

No external research was required. All questions were answered from the repository: the policy rules
under `.claude/rules/`, the shared skills under `.claude/skills/`, the feature folder's own documents
and evidence, the branch diff, and the three coverage artifacts. The one behavior that could not be
settled by reading — whether the parity and convention suites auto-discover the new fixtures and
modules without being edited — was settled by reading their discovery code and then running them.

---

## Verdict

The change is ready for normal PR flow. It is a well-scoped fix to a real scheduling defect, and the
implementation choices that matter most — applying the exclusion at exactly one point per runtime,
leaving every recorded radius untouched, merging project files as lines rather than as XML, and
refusing by default when the grammar does not recognize an input — are the ones that keep the blast
radius of a mistake small. The three-runtime parity is pinned by shared fixtures rather than by
parallel assertions, which is the durable form of that guarantee. Coverage, formatting, linting,
typing, file size, mirror parity, and evidence location were all independently re-verified by the
reviewer and all pass.

Two follow-ups are worth filing but not worth blocking on. CR-1, the stderr merge in `Invoke-GitExe`,
is a robustness gap whose failure modes all point toward escalation rather than toward a wrong merge.
CR-2, the single-version `oldVersion` form, is a narrow correctness gap in a shape that neither NuGet
nor Visual Studio emits, and the written acceptance criterion does not cover it either — so the code
matches its spec and the spec is what is incomplete. CR-3 is documentation hygiene on two evidence
artifacts whose conclusions the reviewer reproduced independently.

Consistent with the Findings Table and the readiness recommendation above: **Go**, with three Minor
and two Info items recorded for follow-up.
