# Research: remaining-cannot-fail-count-assertions (Issue #711)

- Date: 2026-09-27T03-00
- Requirements source: `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/issue.md`
- Precedent: `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/spec.md`,
  `.../plan.2026-09-25T22-06.md`, `.../research/research.2026-09-25T22-10.md` (issue #513, PR #702,
  merged into this branch's base — `Test-NonVacuousCollection` already exists in
  `BlastRadius.TruthTable.Tests.ps1`).
- Target files (all four read in full or in the relevant regions; line numbers confirmed against
  the current tree, not against the issue's citations from memory):
  - `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` (391 lines)
  - `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (500 lines)
  - `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` (476 lines)
  - `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (203 lines)

## Headline finding

Of the five sites the issue names, **only two are genuinely exploitable "cannot-fail" defects**
under the current producer contract: AC-1 (`mandate_reads`, `BlastRadius.TruthTable.Tests.ps1`) and
AC-5 (`codex-pretooluse-integration.Tests.ps1:133`). The other three (AC-2, AC-3, AC-4) read as the
same textual shape (`@($x).Count | Should -BeGreaterThan 0`) but their guarded values are produced
by functions that always `return , $collection.ToArray()` — the unary-comma "prevent pipeline
flattening" idiom — which guarantees the captured variable is a real (possibly zero-length) array
and never a raw `$null`. Because `@($null)` is the only input for which `@()`-wrapping fabricates a
count of `1`, and that input is unreachable through these three producers, the three assertions
already fail correctly on the reachable empty-collection case. This is evidenced directly in the
production source below (part (a) evidence for each site), not inferred from the shared textual
shape. Section "Decision Point 1" in Recommendations records the options this asymmetry creates.

A second, independently significant finding: `enforcement-hooks-no-python-invocation.Tests.ps1` is
**exactly 500 lines today** — at, not under, the repository's file-size ceiling
(`.claude/rules/general-code-change.md`: "may not exceed 500 lines"). Any line added to this file
breaches the limit. `DiscoveryValidation.Tests.ps1` has only 23 lines of headroom (476 → 499). Both
constraints materially shape the recommended replacement form (Recommendations, Decision Point 2).

## Current State Analysis — per site

### AC-1 — `BlastRadius.TruthTable.Tests.ps1`, `mandate_reads` (two-statement form)

**(a) Current text and producer.** Lines 258–269, `Context 'Read-by-mandate exclusions'`:

```
262:            $entries = @($script:CommittedConfig['mandate_reads'])
...
266:            $entries.Count | Should -BeGreaterThan 0
267:            @($entries | Where-Object { [string]::IsNullOrWhiteSpace($_) }) |
268:                Should -BeNullOrEmpty
```

(Line numbers shifted from the issue's citation of "251/251-253" because `Test-NonVacuousCollection`
and its negative-control `Context` were inserted earlier in the file by the merged #513 fix; the
two-statement `mandate_reads` shape itself is untouched since #513 explicitly excluded it under its
own D3.) `$script:CommittedConfig` is populated at line 64 via
`Get-Content -Raw | ConvertFrom-Json -AsHashtable` reading `config/blast-radius.json`. A `Hashtable`
indexer lookup on an absent key returns `$null` with no throw (ordinary `Hashtable` behavior,
unaffected by `Set-StrictMode`). If `mandate_reads` is absent or explicitly `null` in the committed
JSON, `$entries = @($null)`, whose `.Count` is `1`. **This is vacuous**: `$entries.Count | Should
-BeGreaterThan 0` passes even though the guarded list is empty. This is the identical defect class
#513 fixed at three other lines in the same file, textually disguised across two statements — #513's
own spec.md and research already documented this exact conclusion and deliberately left it out of
scope (D3).

**(b) Recommended replacement.** Reuse the helper `Test-NonVacuousCollection` already defined in the
file's top-level `BeforeAll` (lines 49–57, merged by #513):

```
Test-NonVacuousCollection -Value $entries | Should -BeTrue
```

`$entries` must remain assigned as today (it is consumed again at line 267 for the whitespace
check), so only the assertion line changes. Verified: the helper filters `$Value` through
`Where-Object { $null -ne $_ }` before counting; for `$entries = @($null)` (the vacuous case) the
filter yields zero elements, `Count -gt 0` is `$false`, and `Should -BeTrue` fails — reproducing the
exact discriminating behavior #513 already proved for the three other floors in this file's
"Non-vacuity floor helper" `Context` (lines 303–328).

**(c) Fail-before evidence.** No new negative-control `It` is strictly required: the existing
`Context 'Non-vacuity floor helper'` already asserts `Test-NonVacuousCollection -Value $null |
Should -BeFalse` and documents that the legacy expression `@($null).Count -gt 0` is `$true` (lines
304–306, 325–326). The site-specific fail-before/pass-after evidence is therefore a **token-based
structural check**, matching #513's own AC-1 pattern (P3-T4): before the edit, `Select-String` for
the literal `$entries.Count | Should -BeGreaterThan 0` returns `1`; after the edit, it returns `0`
and a new search for `Test-NonVacuousCollection -Value \$entries \| Should -BeTrue` returns `1`. A
full-directory `Invoke-Pester` run before and after the edit (matching #513's P0-T13/P4-T1 pattern)
confirms no regression and (per AC-6) no reduction in `It` count. No new `It` block is required for
this site, so the file's `It` count for this change is `+0` at this site.

**(d) Vacuous?** Yes — confirmed exploitable (the producer is a raw hashtable read with no
null-safety of its own).

### AC-2 — `enforcement-hooks-no-python-invocation.Tests.ps1:457`

**(a) Current text and producer.** Lines 451–457, `Context 'repository scan' -Tag 'RepositoryScan'`:

```
454:            $files = Get-GuardedPowerShellFile
...
457:            @($files).Count | Should -BeGreaterThan 0
```

`Get-GuardedPowerShellFile` is a **file-local test helper** (defined in this file's own `BeforeAll`,
lines 50–76 — not a production module; grep confirmed it exists nowhere else in the repository). Its
body:

```
55:        $results = [System.Collections.Generic.List[object]]::new()
...
75:        return , $results.ToArray()
```

The leading `,` (unary comma operator) wraps `$results.ToArray()` in a one-element outer array before
`return`. PowerShell's implicit `Write-Output` enumerates that outer array (length 1) and emits
exactly one pipeline object: the inner array itself, intact. When the caller assigns
`$files = Get-GuardedPowerShellFile`, `$files` is bound to that single emitted object — the real
`ToArray()` result — whether it has zero or many elements. **`$files` can never be `$null`**: even
when both scan roots are absent (`Test-Path` false for each) or contain zero matching files, the
`List[object]` stays empty and `.ToArray()` yields a genuine zero-length `object[]`, not `$null`. The
comma-return idiom exists specifically to stop `return` from flattening a real array onto the
pipeline (which would otherwise scatter its elements as separate objects or, for a single-element
array, unwrap it to a bare scalar) — a different PowerShell pitfall from the one this issue targets,
but its side effect here is that it also forecloses the `$null`-wrapping defect. `@($files)` then
re-enumerates an already-real array into a same-length array; `@($files).Count` for zero matches is
`0`, and `Should -BeGreaterThan 0` correctly fails.

**(d) Vacuous? No.** This assertion already fails on the empty case and cannot receive a raw `$null`
input through this producer. It is not exploitable as written.

**(b) Recommended replacement, if the operator elects uniform hardening.** A same-line inline
`Where-Object` filter, matching the file's own established idiom for null-safe pipeline counting:

```
@($files | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0
```

Piping `$null` through `Where-Object` yields zero output elements (documented PowerShell pipeline
behavior, distinct from `@($null)`'s scalar-wrapping — this is the exact mechanism #513's
already-sound `$separatorFree` line at `BlastRadius.TruthTable.Tests.ps1:253` relies on). For
`$files` empty, the filter still yields zero elements; `Count` is `0` either way. This is a
**same-line, zero-line-delta edit** — critical because this file is at the 500-line cap (see below).

**(c) Fail-before evidence, without editing the file.** Because the file has **zero headroom** (see
"File-size headroom" below), the recommended evidence path does not add any `It` block here. Produce
fail-before evidence with an ephemeral scratch PowerShell script (outside the tracked repository, per
the executor convention #513's plan established) that: (i) evaluates `@($null).Count -gt 0` and
confirms `$true` (documents the general defect, already established by the issue's own repro); (ii)
dot-sources or re-declares `Get-GuardedPowerShellFile`'s body against a `$script:ScanRoot` pointing
at a nonexistent path, confirming the returned value's type is `System.Object[]` (not `$null`) and
its `.Count` is `0`; (iii) confirms `@($files).Count -gt 0` is `$false` for that zero-element case —
i.e., the assertion already discriminates correctly without any edit. This scratch script is
evidence tooling, not test code, and is discarded after the evidence artifact is written; it depends
on no temp file inside the tracked tree, no remote ref, and no gitignored state.

### AC-3 — `DiscoveryValidation.Tests.ps1:155`

**(a) Current text and producer.** Lines 146–156, `Context 'profile placeholder contract'`:

```
152:            $errors = Get-DiscoveryProfileValidationError -Text $text
...
155:            @($errors).Count | Should -BeGreaterThan 0
```

`Get-DiscoveryProfileValidationError` (`.claude/lib/discovery-validation/DiscoveryValidation.psm1`,
lines 198–257) declares `[OutputType([object[]])]` and has **four** return points, all of the same
shape:

```
235:        return , $errors.ToArray()   # runtime-version guard
240:        return , $errors.ToArray()   # empty/whitespace document
246:        return , $errors.ToArray()   # non-mapping root
256:        return , $errors.ToArray()   # normal exit (0+ missing-field errors)
```

Every exit point uses the identical guaranteed-array `return , $errors.ToArray()` idiom verified
above for `Get-GuardedPowerShellFile`. `$errors` can never be `$null`.

**(d) Vacuous? No**, for the same reason as AC-2: the guarded value's producer forecloses `$null`.
The malformed-document case exercised at this `It` (line 149, `` "`t- : ::`n" ``) produces a
one-element `errors` array (`'Profile document root must be a mapping.'`), so today's data also does
not exercise the empty case in practice, but the assertion would still correctly fail if it did,
because `$errors` would be a genuine zero-length array, not `$null`.

**(b) Recommended replacement, if uniform hardening is elected:** identical same-line inline filter:

```
@($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0
```

**(c) Fail-before evidence.** With only 23 lines of headroom in this file (476 → 499), the same
no-new-`It`-block, scratch-script evidence approach recommended for AC-2 applies here: confirm via an
external scratch script that `Get-DiscoveryProfileValidationError` returns a real (never-null) array
at every one of its four return points (achievable by feeding each of the four early-exit
conditions: an unsupported `-PowerShellVersion`, an empty `-Text`, a non-mapping `-Text`, and a
normal mapping) and that the resulting `.Count` for each governs the assertion correctly.

### AC-4 — `DiscoveryValidation.Tests.ps1:333`

**(a) Current text and producer.** Lines 324–335, `Context 'schema-governed artifact validation'`:

```
330:            $errors = Get-DiscoverySchemaArtifactValidationError -Text $text
...
333:            @($errors).Count | Should -BeGreaterThan 0
```

`Get-DiscoverySchemaArtifactValidationError` (`.claude/lib/discovery-validation/DiscoveryValidation.psm1`,
lines 303–375) also declares `[OutputType([object[]])]` with **five** return points, all
`return , $errors.ToArray()` (lines 333, 342, 347, 356, 374). Same guaranteed-array contract as AC-3.
The test file itself documents this contract's importance elsewhere, in a different `It` at lines
363–367 ("Regression guard. These helpers emit their array as a single object, so a dispatcher that
wrapped the call in `@()` produced a one-element array whose only element was the real error
array.") — direct, in-repository evidence that this module's authors are already relying on the
comma-return idiom's guarantee, just for a different downstream failure mode (accidental
double-nesting), not the one this issue targets.

**(d) Vacuous? No**, same reasoning as AC-3.

**(b) Recommended replacement, if uniform hardening is elected:** identical same-line inline filter,
`@($errors | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`.

**(c) Fail-before evidence.** Same scratch-script approach as AC-3 (headroom is the same file).

### AC-5 — `codex-pretooluse-integration.Tests.ps1:133`

**(a) Current text and producer.** Lines 126–133:

```
126:        $script:Registrations = Get-CodexPreToolUseRegistration -ConfigPath $script:ConfigPath
127:        $script:RegisteredHookNames = @($script:Registrations | ForEach-Object { $_.HookName } | Select-Object -Unique)
...
133:        @($script:Registrations).Count | Should -BeGreaterThan 0
```

`Get-CodexPreToolUseRegistration` (file-local helper, lines 16–56 of this same test file) builds a
`List[object]` and returns:

```
55:            return $registrations.ToArray()
```

**No leading comma.** This is the opposite idiom from every other producer examined above. Without
the comma, `return`'s implicit `Write-Output` enumerates `$registrations.ToArray()` directly onto the
pipeline: for zero matched registrations, `ToArray()` is a zero-length array and enumerating it emits
**zero pipeline objects**. When PowerShell assigns the output of a call that emits zero objects to a
variable (`$script:Registrations = Get-CodexPreToolUseRegistration ...`), the variable is bound to
`$null` — there is no pipeline object to capture. `@($script:Registrations).Count` is then
`@($null).Count`, which is `1`, so `Should -BeGreaterThan 0` **passes vacuously** on a
zero-registration parse. (For exactly one registration, the single emitted object is captured as a
bare scalar, not an array, and `@()`-wrapping that scalar correctly yields `Count = 1` — not a false
positive, since the value is a genuine single object. For two or more registrations, PowerShell's
multi-object pipeline capture collects them into a real array, and the count is correct. The failure
mode is specific to the zero-registration case.)

**(d) Vacuous? Yes** — confirmed exploitable, and structurally distinct from AC-1: here the defect
lives in the **test-local helper's missing comma**, not in a raw-value read.

**(b) Recommended replacement.** Two independent, non-exclusive fixes are available:

1. **Assertion-side fix (recommended, minimal diff):** same-line inline filter,
   `@($script:Registrations | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0`.
   Piping `$script:Registrations = $null` through `Where-Object` yields zero output elements
   (the same null-source-pipeline behavior relied on throughout this research), so `@()` around that
   pipeline is genuinely zero-length; `Should -BeGreaterThan 0` then correctly fails. This closes the
   defect without touching `Get-CodexPreToolUseRegistration` at all.
2. **Producer-side fix (root cause, larger diff):** add the leading comma to
   `Get-CodexPreToolUseRegistration`'s `return` statement (`return , $registrations.ToArray()`),
   matching the idiom already used by the other three producers examined in this research. This
   would make `$script:Registrations` a guaranteed real array in every case, eliminating the
   root cause rather than only the symptom at the one call site — but it is a change to a
   test-local *helper function*, not merely to an assertion line, so it is a larger, less
   surgical diff for a "Low"-severity bug fix whose stated scope is the assertions themselves.

Recommendation: **apply fix 1 only**, consistent with #513's own precedent of touching only the
assertion lines named in scope and not refactoring the surrounding helper/producer code (#513
`spec.md` Scope section: "No production PowerShell file is changed. The defect is confined to test
code" and its D3 explicitly declining to fix an adjacent, differently-shaped occurrence in the same
pass). Fix 2 remains available as a documented, not-adopted alternative if the operator wants defense
in depth; recording it here satisfies the "candidate approaches" requirement without adopting a
broader-than-necessary diff.

**(c) Fail-before evidence.** This file has ample headroom (203 → 499, 296 lines). Recommend
following the #513 Phase-1/Phase-2 Red→Green pattern directly in the tracked file: add one sibling
`It` (or a small `Context`) asserting, purely in-memory:

```
(@($null).Count -gt 0) | Should -BeTrue   # documents the legacy defect
(@($null | Where-Object { $null -ne $_ }).Count -gt 0) | Should -BeFalse   # proves the fix discriminates
```

This mirrors the existing "documents that the legacy expression ... evaluates to `$true`" `It` that
#513 added to `BlastRadius.TruthTable.Tests.ps1` (lines 325–326), reused here verbatim as the
negative control's first half, plus one additional assertion proving the specific replacement form
discriminates. No temporary file, remote ref, gitignored state, or Windows-only path is involved. A
full-suite `Invoke-Pester` run before and after (matching #513's P0-T13/P4-T1) supplies the
regression evidence and the AC-6 "no reduction in test count" check (count increases by exactly the
number of new `It` cases added here, which is a controlled, expected increase, not a defect —
matching #513's own framing of its 6 new `It` cases).

## File-size headroom (500-line cap, `.claude/rules/general-code-change.md`)

| File | Current lines | Lines available before 500 | Constraint on this change |
| --- | --- | --- | --- |
| `BlastRadius.TruthTable.Tests.ps1` | 391 | 108 | Ample; a one-line AC-1 edit is trivial. |
| `enforcement-hooks-no-python-invocation.Tests.ps1` | **500** | **0** | At the ceiling today; **no line may be added**. Any AC-2 edit must be a same-line replacement (net 0 delta) or no edit at all. |
| `DiscoveryValidation.Tests.ps1` | 476 | 23 | Tight; AC-3/AC-4 edits should stay same-line (net 0 delta each); a new multi-`It` `Context` here is a real risk of breaching the cap. |
| `codex-pretooluse-integration.Tests.ps1` | 203 | 296 | Ample; AC-5's recommended new negative-control `It`s fit comfortably. |

Line counts were read directly from the file content (the `Read` tool's own line numbering, which
terminates at the file's last content line) and cross-checked with a `^`-anchored line-count search
(`Numeric Derivation Evidence` below); both methods agree for all four files.

## Additional occurrences of the vacuous pattern in the four target files

Searched each of the four files (not the wider repository, per the delegation's scope) for
`@(...).Count | Should -BeGreaterThan 0`, `.Count | Should -BeGreaterThan 0`, and `.Count -gt 0` used
as an assertion:

- `BlastRadius.TruthTable.Tests.ps1:253` — `$separatorFree.Count | Should -BeGreaterThan 0`. **Not a
  new candidate; already sound**, and already classified as such by #513's own root-cause analysis:
  `$separatorFree` is the output of a `Where-Object`-filtered pipeline (lines 241–244), not a raw
  `@()`-wrapped scalar, so a `$null` source yields zero elements through the pipeline stage, not a
  one-element wrap. This is the pattern the two recommended replacements above imitate.
- `BlastRadius.TruthTable.Tests.ps1:326` — `(@($null).Count -gt 0) | Should -BeTrue`. This is the
  **intentional legacy-expression documentation `It`** #513 added; it is asserting the defect exists
  as a fact, not guarding a real collection. Not a candidate.
- `BlastRadius.TruthTable.Tests.ps1:56` — `return @($Value | Where-Object { $null -ne $_ }).Count -gt
  0` inside `Test-NonVacuousCollection` itself. This is the helper's own body, already null-safe by
  construction (the property under test), not a candidate.
- `codex-pretooluse-integration.Tests.ps1:134` —
  `@($script:Registrations | ForEach-Object { $_.Matcher } | Select-Object -Unique).Count | Should
  -BeGreaterOrEqual 3`, in the same `It` as AC-5, one line below it. Not matched by the three
  searched patterns literally (`BeGreaterOrEqual`, not `BeGreaterThan`), but structurally related
  enough to check: it pipes `$script:Registrations` through `ForEach-Object` and `Select-Object`
  before the outer `@()`, so a `$null` source (the same zero-registration case AC-5 covers) yields
  zero elements through the pipeline, not a one-element wrap — **already sound**, not a candidate.
- No other occurrences of any of the three searched patterns were found in
  `enforcement-hooks-no-python-invocation.Tests.ps1` or `DiscoveryValidation.Tests.ps1` beyond the
  two already-cited sites in each family (AC-2 alone in the former; AC-3 and AC-4 in the latter).

## How each suite is run

Per `.claude/rules/powershell.md` and #513's own plan/research (which record this precedent
directly): the toolchain order is format → analyze → test, run via `mcp__drm-copilot__run_poshqc_format`,
`mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`. All four target files
sit under `tests/scripts/**`, which `config/poshqc-scan.json`'s `test.scanFolders` (`scripts`,
`tests/powershell`, `tests/scripts`) and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s
`Run.Path` (the same three roots) both include, so all four are in scope for the MCP-driven suite and
for CI's `_poshqc.yml` reusable workflow.

For evidence-gathering during implementation, #513's plan explicitly avoided relying solely on the
MCP test runner ("`mcp__drm-copilot__run_poshqc_test` ... has been observed in this repository to
return no usable output and to read installed-extension settings rather than freshly edited workspace
files") and instead ran `Invoke-Pester` directly from `pwsh`, per-file and per-directory, for example:

```
Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -Output Detailed -PassThru
Invoke-Pester -Path tests/scripts/claude-lib/blast-radius -Output Detailed -PassThru
```

The same pattern applies to the other three target directories/files in this issue
(`tests/scripts/claude-runtime`, `tests/scripts/claude-lib/discovery-validation`,
`tests/scripts/codex-hooks`). This researcher session has no Bash/pwsh execution tool available (the
same constraint #513's research recorded), so no command in this document was actually executed; all
conclusions rest on direct reading of the test files and the production module they call, cross-checked
against documented PowerShell pipeline/array semantics.

**Current `It`-block counts per file** (confirmed by two independent search patterns that agree
exactly — see Numeric Derivation Evidence): `BlastRadius.TruthTable.Tests.ps1` = 23,
`enforcement-hooks-no-python-invocation.Tests.ps1` = 27, `DiscoveryValidation.Tests.ps1` = 40,
`codex-pretooluse-integration.Tests.ps1` = 5.

## Numeric Derivation Evidence

**Claim: `It`-block counts per file are 23 / 27 / 40 / 5 (Blast Radius / enforcement-hooks /
Discovery Validation / codex-pretooluse, respectively).**

- Complete Family: every `Describe`/`Context`-scoped Pester `It` test-case declaration in the named
  file, including parameterized (`-ForEach`) forms.
- Exhaustive Search Scope: the full text of each of the four named files individually (no
  repository-wide scan; the delegation scoped this search to the four target files).
- Inclusion Rules: any line whose first non-whitespace token is the literal `It` followed by a
  space and a quote character opening the test-case name.
- Exclusion Rules: `Describe`/`Context` declarations (different keyword); comments or prose
  mentioning the word "It"; the word "It" appearing mid-line rather than as the line's leading
  token.
- Primary Search Strategy: ripgrep pattern `^\s*It '` (anchors on line start, requires an immediately
  following single-quote — the exclusive quoting convention observed in all four files).
- Primary Member Set: 23 matched lines in `BlastRadius.TruthTable.Tests.ps1` (75, 82, 88, 104, 136,
  158, 170, 182, 190, 204, 216, 233, 259, 270, 295, 304, 308, 312, 316, 320, 325, 331, 366); 27 in
  `enforcement-hooks-no-python-invocation.Tests.ps1`; 40 in `DiscoveryValidation.Tests.ps1`; 5 in
  `codex-pretooluse-integration.Tests.ps1`.
- Primary Count: 23 / 27 / 40 / 5.
- Cross-check Search Strategy: ripgrep pattern `^\s*It\s` (broader — any whitespace after `It`,
  not requiring a single-quote immediately, which would additionally catch double-quoted or
  differently-formatted `It` names if any existed).
- Cross-check Member Set: identical line sets to the primary search in all four files (verified by
  identical match counts; no file contains an `It` declaration using a different quoting style).
- Cross-check Count: 23 / 27 / 40 / 5.
- Member-set Comparison: the primary and cross-check counts are identical for all four files (23=23,
  27=27, 40=40, 5=5), and the broader cross-check pattern introduced no additional matches, so the
  two search strategies enumerate the same member set. No numeric assertion about `It`-count deltas
  is proposed here as a `spec.md` acceptance criterion; this evidence supports the file-size-headroom
  and "no reduction in test count" (AC-6) analysis above, and a future `spec.md` should re-derive its
  own baseline counts at plan-authoring time exactly as #513's plan did (P0-T11/P0-T12), rather than
  citing the counts recorded here as of record.

**Claim: total line counts per file are 391 / 500 / 476 / 203.**

- Complete Family: every line in the named file, including blank lines and the final line.
- Exhaustive Search Scope: the full text of each of the four named files individually.
- Inclusion Rules: every line as delimited by a newline character.
- Exclusion Rules: none (all lines count toward the file-size limit per
  `.claude/rules/general-code-change.md`, which draws no exclusion for blank or comment lines).
- Primary Search Strategy: ripgrep pattern `^` (matches every line unconditionally) with count
  output mode.
- Primary Member Set/Count: 391 / 500 / 476 / 203 (one match per line, by construction).
- Cross-check Search Strategy: direct file read via the `Read` tool, which reports each line's
  1-based line number; the cross-check count is the highest line number reported (the file's last
  content line), read independently of any regex match.
- Cross-check Member Set/Count: 391 / 500 / 476 / 203 — confirmed by reading each file's tail
  region and observing the last numbered content line matches the primary count exactly, with no
  further content line following it.
- Member-set Comparison: primary and cross-check counts agree exactly for all four files. This
  evidence directly supports the file-size-headroom finding (the enforcement-hooks file is at,
  not under, the 500-line ceiling) and is load-bearing for Decision Point 2 in Recommendations, not
  merely descriptive.

## Merge-order independence

None of issues #706–#716 (the concurrent parallel-run siblings) name any of these four files in their
issue bodies. #707 (codex-gates-4-5-lack-epic-scope) and #709 (gate-suites-read-unmocked-local-epic-state)
work in adjacent codex-hook and gate-suite test areas and could plausibly touch
`tests/scripts/codex-hooks/*.Tests.ps1` files other than `codex-pretooluse-integration.Tests.ps1`, or
add/remove `It` blocks near it, without necessarily colliding with this issue's exact edit lines.

Recommendation for the plan: locate every edit site by a **unique, quoted content anchor** rather
than a raw line number, exactly as #513's plan did (its P3-T1..T3, P3-T4, and P3-T6 tasks all quote
the literal token being replaced or preserved, and its acceptance checks are `Select-String` searches
for that literal token, not line-number assertions). Concretely:

- AC-1: anchor on the literal `$entries.Count | Should -BeGreaterThan 0` (unique in the file; the
  file's `mandate_reads` `It` is the only place this exact token appears) rather than "line 266".
- AC-2: anchor on `@($files).Count | Should -BeGreaterThan 0` combined with the enclosing `It`'s name
  (`'enumerates only the two guarded roots and never the bundled mirror'`) for disambiguation, since
  `@($files)` alone is not distinctive.
- AC-3/AC-4: anchor on the enclosing `It` name plus the exact preceding `$errors = ...` call
  (`Get-DiscoveryProfileValidationError` for AC-3, `Get-DiscoverySchemaArtifactValidationError` for
  AC-4), since the literal `@($errors).Count | Should -BeGreaterThan 0` string appears at both line
  155 and line 333 and is not unique by itself.
- AC-5: anchor on `@($script:Registrations).Count | Should -BeGreaterThan 0` (unique in the file).

A plan written this way remains correct whether or not a sibling PR has merged first and shifted line
numbers in these files (none of the siblings' issue bodies indicates they will, but content anchors
are more robust than the alternative and cost nothing extra to author).

## Automation Feasibility

No step in implementing or verifying this fix requires human interaction. Every recommended edit is
a deterministic text change to a tracked test file; every fail-before/pass-after check is an
in-memory Pester assertion or a `Select-String`/`Invoke-Pester` command run non-interactively; the
scratch-script evidence recommended for AC-2/AC-3/AC-4 (proving the "not vacuous" finding rather than
editing the file) runs outside the tracked repository via the same wrapper-script convention #513's
plan used, and requires no credentials, external services, or manual judgment calls.

## Candidate Approaches (replacement form)

1. **Reuse/extend a file-local `Test-NonVacuousCollection`-style helper** (as #513 adopted for
   `BlastRadius.TruthTable.Tests.ps1`).
   - Advantages: single point of predicate coverage; directly negative-control-testable in isolation;
     already merged and proven for AC-1's file.
   - Limitations: requires defining a new helper (and, ideally, its own negative-control `Context`)
     in files that do not yet have one (`DiscoveryValidation.Tests.ps1`,
     `enforcement-hooks-no-python-invocation.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`),
     which costs lines two of those files cannot spare.
2. **Same-line inline `Where-Object`-filtered form** (`@($x | Where-Object { $null -ne $_ }).Count |
   Should -BeGreaterThan 0`), matching the pattern already proven sound elsewhere in three of the
   four files (`BlastRadius.TruthTable.Tests.ps1:253`, `codex-pretooluse-integration.Tests.ps1:134`).
   - Advantages: zero line-count delta (critical for the two headroom-constrained files); no new
     function to introduce, review, or lint; reuses an idiom the codebase already trusts.
   - Limitations: the predicate is not independently unit-testable the way an extracted helper is;
     if the same filter needs to change later, every call site must be edited individually (a cost
     the codebase already accepts at `:253` and `:134`).

**Recommended: Approach 2 (inline filter) for AC-2, AC-3, AC-4, and AC-5; Approach 1 (helper reuse,
already merged) for AC-1**, because AC-1's file already has the helper and headroom to spare, while
the other three files either cannot afford a new helper's line cost (AC-2, AC-3, AC-4) or gain no
extra correctness benefit from one for a single call site (AC-5, where the inline filter alone closes
the exploitable defect).

**Rejected alternative:** `$x | Should -Not -BeNullOrEmpty` (Pester's built-in null/empty handling,
considered and rejected by #513 for the same reason it applies here — it would introduce a second
idiom for the identical property alongside the `Where-Object`-filtered form already established at
`:253` and `:134`, rather than reusing the one idiom the codebase already uses consistently for this
class of check).

## Recommendations

**Decision Point 1 — how to treat the three sites (AC-2, AC-3, AC-4) proven not vacuous under the
current producer contract.**
- Option A: Leave the assertion code at these three sites unchanged; satisfy each AC via a
  documented, evidence-backed finding (the producer's guaranteed-array `return , $x.ToArray()`
  contract) plus a scratch-script demonstration, with no diff to the test files at these three
  lines.
- Option B: Apply the same-line inline `Where-Object`-filtered form at all three sites anyway, for
  defense-in-depth and literal-wording compliance with each AC's "fails when ... null" text, at zero
  line-count cost.
- **Recommended: Option B.** The line-count cost is genuinely zero (same-line edit), the change
  closes the textual defect class uniformly across all five named sites rather than leaving three of
  them as a documented exception a future reader must re-derive, and it directly and unambiguously
  satisfies each AC's literal wording without requiring the spec to carry a "this AC is satisfied by
  inspection, not by code" caveat. Option A remains available if the operator prefers the smaller,
  more literally-scoped diff (consistent with #513's own preference for minimal, targeted edits) and
  is willing to accept that framing in `spec.md`.

**Decision Point 2 — replacement form per site, given the file-size constraints.**
- Recommended: `Test-NonVacuousCollection -Value $entries | Should -BeTrue` for AC-1 (helper reuse,
  ample headroom); same-line inline `Where-Object`-filtered form for AC-2, AC-3, and AC-4 (zero
  headroom / tight headroom, respectively); same-line inline filter for AC-5's assertion, with the
  producer-side comma fix documented as a rejected (not adopted) alternative.

**Decision Point 3 — fail-before evidence mechanism.**
- Recommended: reuse the existing in-file negative controls for AC-1 (no new `It` needed); an
  external scratch-script demonstration (outside the tracked repo, no committed test-file change) for
  AC-2/AC-3/AC-4; a new small in-file `Context`/`It` pair mirroring #513's own legacy-expression
  documentation `It` for AC-5, where headroom comfortably allows it and a permanent regression guard
  is worth the two extra `It` cases.

**Decision Point 4 — additional occurrences found during the search.**
- `BlastRadius.TruthTable.Tests.ps1:253` and `:326`, and `codex-pretooluse-integration.Tests.ps1:134`,
  are all already sound (pipeline-filtered before the outer `@()`, or the intentional legacy-defect
  documentation case). Recommended: no action; do not touch these lines, consistent with #513's own
  precedent of leaving its already-sound `$separatorFree.Count` line untouched.

**Decision Point 5 — AC-5's producer-side comma defect.**
- Recommended: do not fix `Get-CodexPreToolUseRegistration`'s missing leading comma in this change.
  The assertion-side inline filter alone closes the exploitable defect this issue targets; changing
  the helper's `return` statement is a second, independent, root-cause-level fix to test-support code
  that is not named in the issue's scope and would broaden the diff beyond the assertions themselves,
  contrary to `.claude/rules/general-code-change.md`'s "avoid broad refactors" guidance and #513's own
  scoping precedent (D3).
