# Research: truth-table-non-emptiness-assertions-cannot-fail (Issue #513)

- Date: 2026-09-25T22-10
- Requirements source: `docs/features/active/2026-08-23-truth-table-non-emptiness-assertions-cannot-fail-513/issue.md`
- Target file: `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`

## 1. Current State — the three defective floors

Line numbers were confirmed against the current tree by direct read (not by memory or
issue-text alone); they match the issue's citations exactly: **72, 171, 172**.

**Line 72** (`Context 'Module map'`, `It 'populates the module map'`):

```powershell
69	    Context 'Module map' {
70	        It 'populates the module map' {
71	            # Assert: an empty map would make the per-module check vacuous.
72	            @($script:CommittedConfig['modules'].Keys).Count | Should -BeGreaterThan 0
73	        }
```

**Lines 171-172** (`Context 'Shared surfaces'`, `It 'populates the shared-surface truth table
and its membership globs'`):

```powershell
168	    Context 'Shared surfaces' {
169	        It 'populates the shared-surface truth table and its membership globs' {
170	            # Assert: either list being empty would make the checks below vacuous.
171	            @($script:CommittedConfig['shared_surfaces']).Count | Should -BeGreaterThan 0
172	            @($script:CommittedConfig['shared_surface_globs']).Count | Should -BeGreaterThan 0
173	        }
```

`$script:CommittedConfig` is populated in the Describe-level `BeforeAll` (line 52) via
`Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Json -AsHashtable`, reading
`config/blast-radius.json`. The test file itself does not call `Set-StrictMode`; PowerShell
script-file scope defaults to strict mode Off unless a script sets it explicitly, so this file's
own top-level code runs without strict-mode member-access checks regardless of what the imported
modules (`.claude/lib/blast-radius/*.psm1`, which do call `Set-StrictMode -Version Latest` — grep
confirmed all eight) do in their own scope.

## 2. What each guarded expression can evaluate to

The issue's own reproduction (`pwsh -c '@($null).Count'` → `1`) is the load-bearing empirical
fact here; this agent has no Bash/pwsh execution tool available in this session; the analysis
below cross-checks that fact against (a) the issue's verified repro output, (b) the already-sound
pattern present later in the same file (section 3), and (c) documented PowerShell
array-subexpression and pipeline semantics, rather than re-executing pwsh independently.

- **Line 72, `$script:CommittedConfig['modules'].Keys`:**
  - `'modules'` key **missing** from the hashtable, or present with an explicit JSON `null`
    value: hashtable indexer lookup on an absent key returns `$null` (no throw — this is
    ordinary `Hashtable` indexer behavior and is unaffected by `Set-StrictMode`, which does not
    apply strict-mode checks to indexer lookups). `.Keys` accessed on `$null` returns `$null`
    (dot-property access on `$null` returns `$null` rather than throwing, for property — as
    opposed to method — access). `@($null).Count` is `1` (array-subexpression wraps a scalar
    `$null` as a one-element array). **The floor passes vacuously.**
  - `'modules'` present as an **empty hashtable** (`{}` in JSON): `.Keys` returns a real,
    zero-length `KeyCollection`. `@(emptyCollection).Count` is `0` because `@()` enumerates an
    already-enumerable, non-null collection rather than wrapping it as a scalar. **This case
    already fails correctly** — the defect is specific to the null/missing-key case, not to a
    populated-but-empty case.
  - Committed `config/blast-radius.json` currently declares 7 module keys, so today's data does
    not trigger the defect; the floor is a regression guard that cannot fire if the data
    regresses to null.

- **Lines 171/172, `shared_surfaces` / `shared_surface_globs`:**
  - Same reasoning: a missing key or an explicit JSON `null` produces `@($null).Count == 1`
    (vacuous pass). A JSON `[]` (empty array) deserializes via `ConvertFrom-Json` to a real
    zero-length array, so `@(emptyArray).Count == 0` and that case already fails correctly.
  - A JSON array with **exactly one string element** is a known `ConvertFrom-Json` quirk: a
    single-element JSON array can deserialize to a bare scalar rather than a one-element array
    (this is why the rest of the file wraps almost every config read in `@(...)` defensively).
    `@("single-string").Count` is `1`, which is a real, correct one-element count — not a false
    positive, since the value is a genuine non-null string, not an empty collection.
  - Committed `config/blast-radius.json` currently declares 10 `shared_surfaces` entries and 3
    `shared_surface_globs` entries, so, as with `modules`, today's data does not trigger the
    defect.

## 3. The sound pattern already in the file, and the recommended replacement

The issue names lines "148, 238, 251-252" as the already-sound pattern. Direct inspection shows
this is only **partially** accurate — one of the three is not sound, which the recommendation
below accounts for.

- **Line 238** (`It 'gives every separator-free bundled shared surface no wildcard'`) **is
  sound**:
  ```powershell
  226	            $separatorFree = @(
  227	                $script:BundledConfig['shared_surfaces'] |
  228	                    Where-Object { -not $_.Contains('/') }
  229	            )
  ...
  238	            $separatorFree.Count | Should -BeGreaterThan 0
  ```
  `$separatorFree` is built by piping the raw config value through `Where-Object`. Piping `$null`
  into a pipeline stage causes that stage to execute **zero times** (this is a documented
  PowerShell-specific behavior distinct from `@($null)`: `$null` does not enumerate as one
  element when it is the pipeline's upstream source). So `$null | Where-Object {...}` yields no
  output at all, and wrapping *that* result in `@()` — an empty enumeration — gives `Count == 0`,
  correctly failing. The `Where-Object` stage is what converts a null source into a genuinely
  empty collection; the outer `@()` wrapping is then safe because it is wrapping an
  already-enumerated (possibly zero-length) sequence, not a raw scalar/`$null`.

- **Line 148** (`It 'maps every module to a non-empty glob list'`) is a **different kind of
  check**, not a non-emptiness floor: it uses `@($moduleMap[$_]).Count -eq 0` *inside* a
  `Where-Object` filter to select modules whose glob list is empty, then asserts the filtered
  list `Should -BeNullOrEmpty`. This is not the "does the top-level list exist" floor pattern and
  is not a direct precedent for the three defective lines. It is also worth noting for future
  attention (not in scope here): if some module's glob value were itself `$null` rather than an
  empty array, `@($null).Count -eq 0` is `False` (since `@($null).Count` is `1`), so that specific
  module would **not** be selected as "empty" by this filter — the identical root defect
  (`@($null).Count == 1`) applied in the opposite polarity. This is a related, currently
  unexploited latent issue in the same file, outside the three lines this issue names.

- **Line 251** (`It 'declares mandate_reads as a list of non-empty strings'`) is **not sound** —
  it is the identical defect to the three named lines, just split across two statements instead
  of one:
  ```powershell
  247	            $entries = @($script:CommittedConfig['mandate_reads'])
  ...
  251	            $entries.Count | Should -BeGreaterThan 0
  ```
  `$entries` is assigned directly from `@(rawValue)` with no intervening `Where-Object`/pipeline
  step, so a `$null` `mandate_reads` value would give `$entries.Count == 1` and the assertion
  would pass vacuously — the same defect class as lines 72/171/172, textually disguised by the
  two-line form. It happens not to be exercised today because the committed config declares
  `mandate_reads` with 11 entries. This is **not** in the issue's named scope (72, 171, 172) and
  is reported here as an accuracy correction to the "sound pattern at line 251-252" premise, not
  as something this fix should touch (see section 6 for the scope recommendation).

  Line 252's own check (`@($entries | Where-Object { [string]::IsNullOrWhiteSpace($_) }) | Should
  -BeNullOrEmpty`) is a genuinely sound Where-Object-filtered check, consistent with line 238's
  pattern.

**Recommended replacement form (option (a)):** adopt the `@($x | Where-Object { $null -ne $_
}).Count | Should -BeGreaterThan 0` form, mirroring the file's own line 226-229/238 pattern:

```powershell
# Line 72 replacement
@($script:CommittedConfig['modules'].Keys | Where-Object { $null -ne $_ }).Count |
    Should -BeGreaterThan 0

# Lines 171-172 replacement
@($script:CommittedConfig['shared_surfaces'] | Where-Object { $null -ne $_ }).Count |
    Should -BeGreaterThan 0
@($script:CommittedConfig['shared_surface_globs'] | Where-Object { $null -ne $_ }).Count |
    Should -BeGreaterThan 0
```

Piping a `$null` source through `Where-Object` (regardless of the filter's predicate) yields zero
output elements, so `@(...)` around that pipeline is a genuinely zero-length array whenever the
source is `$null` or empty, and remains a genuine populated array whenever the source has real
elements (the `$null -ne $_` predicate additionally strips any literal null elements inside a
non-null array, which is a strictly stronger guarantee than the bug required, at no extra cost).

**Alternative considered and not recommended:** `$x | Should -Not -BeNullOrEmpty` (option (b)).
Pester's `-BeNullOrEmpty` assertion has its own explicit null/empty-collection handling and would
also discriminate correctly (a raw `$null` value fails `-Not -BeNullOrEmpty` directly, without
needing the `@()`-wrapping workaround at all). It was not selected because the issue's own
"Suspected Cause / Notes" section explicitly directs adopting "the pattern already in the file" —
the `Where-Object`-filtered form — and using the same form for all three (plus the pre-existing
sound instance at line 238) keeps the file's non-emptiness-floor idiom uniform rather than
introducing a second idiom for the identical property. Option (b) remains a reasonable fallback
if a future maintainer prefers Pester's built-in semantics.

## 4. Proving the fix discriminates — negative-control test, without temp files/remote refs

**No shared test-helper module exists** in `tests/scripts/claude-lib/blast-radius/`. Every file
in that directory that needs comparison/filter helper logic defines its own `function` inside a
top-level or Describe-level `BeforeAll` block local to that file — e.g. this file's own
`Get-ReasonSignature` (lines 36-45), and `BlastRadius.Parity.Tests.ps1`'s `Get-FixtureContent`,
`Get-FixtureRadius`, `Get-ValidationTargetRadius`, `Get-RadiusSignature`, `Get-FindingSignature`,
`Get-ReasonSignature`, and `Get-ConflictEdge`. This is the established local convention; there is
no shared `TestHelpers`/`Common` module in this directory to add the helper to instead.

**Recommendation:** extract the floor expression into a small helper function inside this file's
existing top-level `BeforeAll` block (lines 21-46), alongside `Get-ReasonSignature`:

```powershell
function Test-NonVacuousCollection {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [object] $Value
    )
    return @($Value | Where-Object { $null -ne $_ }).Count -gt 0
}
```

Then:
1. Rewrite the three floors (line 72, 171, 172) to call
   `Test-NonVacuousCollection -Value <expr> | Should -BeTrue`.
2. Add a new `Context 'Non-vacuity floor helper'` (or similarly named) block containing negative-
   control `It` cases that exercise `Test-NonVacuousCollection` directly against in-memory
   values with no filesystem, network, or environment dependency:
   - `Test-NonVacuousCollection -Value $null | Should -BeFalse` (proves the null case that
     motivated the bug now fails as intended).
   - `Test-NonVacuousCollection -Value @() | Should -BeFalse` (empty array case).
   - `Test-NonVacuousCollection -Value @($null, $null) | Should -BeFalse` (array of nulls case).
   - `Test-NonVacuousCollection -Value @('a') | Should -BeTrue` (positive control).

This satisfies every stated constraint: no temporary files (pure in-memory PowerShell values), no
remote git refs (`origin/main` or otherwise — the test never invokes git), no gitignored state
(nothing read from disk beyond the two already-read committed JSON files), and no Windows-only
paths or drive roots (the values are literal PowerShell expressions, not paths). It also directly
demonstrates the "before" defect would have been caught: applying the *old* raw
`@($x).Count -gt 0` expression to `$null` returns `$true` (1 > 0), which is exactly the false
positive the issue reports; the new helper returns `$false` for the identical input. A reviewer
can reproduce that contrast by temporarily swapping the helper body, though the committed test
suite need only assert the new (correct) behavior.

## 5. How the test is run

- **CI invocation:** `.github/workflows/_poshqc.yml` (a reusable workflow, `workflow_call`) runs
  `Invoke-PoshQCTest -Root <workspace>` after `Invoke-PoshQCFormat` and `Invoke-PoshQCAnalyze`,
  uploading `artifacts/pester/pester-junit.xml` and coverage XML as artifacts. `PoshQC.psm1`'s
  `Invoke-PoshQCTest` uses `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, whose
  `Run.Path` is `@('scripts', 'tests/powershell', 'tests/scripts')` — this file is inside
  `tests/scripts/...` and is therefore included. `config/poshqc-scan.json`'s
  `test.scanFolders` (`scripts`, `tests/powershell`, `tests/scripts`) likewise covers it.
- **Coverage scope:** `CodeCoverage.Path` in the runsettings file is an explicit per-file
  allow-list (not a glob), and `.claude/lib/blast-radius/BlastRadius.psm1` (imported by this test
  file's facade import) is already registered there (line 169 of the psd1), so the production
  module this test exercises indirectly (via `Get-BlastRadius`/`Test-BlastRadiusConflict` in the
  `Disjoint work items` context) remains inside the coverage denominator. The three floors and
  the new negative-control block are test code, not production code, so they do not need — and
  per the general-unit-test policy's coverage-exclusion rule, could not legitimately gain — a
  `CodeCoverage.Path` entry of their own.
- **Current test count:** the target file has **17** `It` blocks (confirmed by `grep -c '^\s*It
  ''`), and the `tests/scripts/claude-lib/blast-radius/` directory has **303** `It` blocks across
  its 14 files. Adding the negative-control `Context` (4 `It` cases, per section 4) would bring
  the file to 21 and the directory to 307; that is a controlled, expected increase, not a defect.
- **File size after the change:** the file is currently **349 lines**. The three one-line floors
  become two-line-wrapped expressions (roughly +3 lines total), the helper function adds
  approximately 9 lines, and the new negative-control `Context`/`It` block adds approximately
  15-20 lines. The projected total is roughly **375-385 lines**, comfortably under the 500-line
  production/test file limit in `.claude/rules/general-code-change.md`.
- **Evidence-gathering caveat:** per prior verified experience with this repository's MCP test
  runner, `mcp__drm-copilot__run_poshqc_test` results can carry no usable output, and the MCP
  runner has been observed to read installed-extension settings rather than the freshly-edited
  workspace settings — so newly added coverage entries or freshly edited test files are not
  reliably reflected through that MCP path. A direct `pwsh` invocation is preferable for evidence
  on this fix, for example:
  ```powershell
  Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -Output Detailed
  ```
  or, for full-directory parity with the issue's own proposed validation ("full
  `tests/scripts/claude-lib/blast-radius` directory run; the total should be unchanged" — aside
  from the intentional new negative-control cases):
  ```powershell
  Invoke-Pester -Path tests/scripts/claude-lib/blast-radius -Output Detailed
  ```

## 6. Same defective pattern elsewhere in `tests/`

A grep for the exact single-line shape `@(...).Count | Should -BeGreaterThan 0` across `tests/`
returned 8 matches; manual inspection of each (reading surrounding context) classifies them as
follows:

- **Genuinely defective (raw value wrapped and counted, no null-safe filter upstream):**
  - `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:457` — `$files
    = Get-GuardedPowerShellFile` (line 454) then `@($files).Count | Should -BeGreaterThan 0`.
  - `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1:155` — `$errors =
    Get-DiscoveryProfileValidationError -Text $text` then `@($errors).Count | Should
    -BeGreaterThan 0`.
  - `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1:333` — same
    shape (not individually re-inspected beyond confirming the grep hit; same file/pattern as
    line 155).
  - `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:133` — `$script:Registrations
    = Get-CodexPreToolUseRegistration -ConfigPath $script:ConfigPath` (line 126) then
    `@($script:Registrations).Count | Should -BeGreaterThan 0`.
  - `BlastRadius.TruthTable.Tests.ps1:251` (this file, `mandate_reads` — see section 3): the
    two-statement variant of the same defect, not matched by the single-line grep but confirmed
    by manual read.
- **Already sound (the wrapped value is itself the output of a `Where-Object` pipeline, so a
  null/absent source already collapses to zero elements):**
  - `tests/scripts/claude-runtime/claude-settings.Tests.ps1:128` — the `@(...)` content is
    `$broadOnly.hooks.SubagentStop | Where-Object { $_.matcher -match ... }`.

**Scope recommendation:** fix only the three lines the issue names (72, 171, 172), consistent
with the issue's explicit proposed-fix section and with the general-code-change policy's
"avoid broad refactors across unrelated scripts" guidance. The other four genuinely-defective
occurrences (three distinct files plus this file's own line 251) share the identical root cause
and idiom, and are good candidates for a single dedicated follow-up issue that sweeps the whole
repository for this class — the issue itself frames the defect as "an instance of the recurring
class tracked in `.claude/rules/plan-acceptance-gates.md`," which supports treating a full sweep
as separate, deliberately-scoped work rather than folding it into this bug fix.

## 7. Automation Feasibility

No human interaction is required to implement, verify, or evidence this fix. The change is a
pure text edit to one test file plus a Pester run; there are no manual UI steps, no external
service approvals, and no credentials or interactive prompts involved. `Invoke-Pester` runs
non-interactively from `pwsh`, and the negative-control assertions in section 4 are self-verifying
(they compare a helper function's boolean return against literal expected values with no manual
judgment call).

## Summary of files the fix will touch

- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` — the only file this
  issue's scope authorizes changing: rewrite lines 72, 171, 172 to the `Where-Object`-filtered
  form; add a small helper function to the existing top-level `BeforeAll`; add one new `Context`
  with in-memory negative-control `It` cases.

No production PowerShell file changes are required; this is a test-only fix.
