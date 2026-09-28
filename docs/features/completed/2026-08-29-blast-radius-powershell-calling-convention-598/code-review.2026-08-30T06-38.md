# Code Review — issue #598, blast-radius PowerShell calling convention

Timestamp: 2026-08-30T06-38
Reviewer: feature-review
Branch: `feature/blast-radius-powershell-calling-convention-598`
HEAD: `d26beb1e2aef67a3ed1e6f80ac55f69042ed00a5`
Resolved base: `epic/claude-runtime-portability-integration` at `6df37664`

## Change shape

| Category | Count | Detail |
|---|---|---|
| Production modules changed | 56 | 28 under `.claude/lib/`, 28 byte-identical bundle mirrors |
| Test files changed | 2 | 1 new, 1 extended |
| Python files changed | 0 | — |
| Settings/policy files changed | 0 | — |
| Net production line change | +2 to +12 per module | guard line, convention sentence, `-ErrorAction Stop` on imports |

The edit applied to each module is mechanical and uniform: one `$ErrorActionPreference = 'Stop'`
line immediately after the column-0 `Set-StrictMode -Version Latest`, one CONVENTION sentence in the
module-level help, and `-ErrorAction Stop` appended to each column-0 `Import-Module`.

## Design assessment

### Simplicity — strong

The change selects the simplest mechanism that achieves fail-fast module loading: a preference
variable assignment at module root. It introduces no wrapper, no helper module, no shared bootstrap
file, and no indirection. The alternative designs a reviewer would look for and be concerned by — a
shared `Initialize-ClaudeLibModule` called from each module, or a generated prologue — are correctly
absent. `.claude/rules/general-code-change.md` §Design Principles ranks simplicity first, and the
change honours it.

The uniformity is verifiable rather than asserted. All 28 guard lines are identical, with no
per-module variation and no `$global:` scoping:

```
grep -rhn "ErrorActionPreference" --include='*.psm1' .claude/lib | sed 's/^[0-9]*://' | sort | uniq -c
-> 28 $ErrorActionPreference = 'Stop'
```

### Separation of concerns — unaffected

The change adds no logic and moves no logic between layers. The one structural edit, the
condensation in `DiscoveryValidation.psm1`, is confined to comment prose.

### Extensibility — improved

The convention is enforced by a disk-discovering test rather than a maintained list, so a module
added later cannot silently omit the guard. This is the correct mechanism for a convention that must
hold across a growing set, and it is better than the alternative of a static allow-list that drifts.

## Behavioral risk assessment

This is the most consequential aspect of the change and it warrants direct treatment.

Setting `$ErrorActionPreference = 'Stop'` at module root does not only affect load time. In
PowerShell, functions defined in a module execute in that module's session state, so the module-root
preference governs cmdlet error behavior inside every exported function at runtime as well. The
practical blast radius is therefore wider than "import-time failure behavior": any cmdlet inside
these modules that previously emitted a non-terminating error and allowed execution to continue now
throws.

Three independent lines of evidence indicate the realized risk is low.

**1. No module emits a non-terminating error deliberately.**

```
SearchScope: .claude/lib/**/*.psm1 (28 files)
SearchPatterns: Write-Error
SearchResult: 0 matches
```

There is no code in the shared library that calls `Write-Error` expecting the caller to continue.
The failure idiom throughout is `throw` or a returned result object, both of which are unaffected by
the preference variable.

**2. The three sites that depend on non-terminating behavior already override it explicitly.**

```
.claude/lib/discovery-validation/DiscoveryValidation.psm1:363:  -ErrorAction SilentlyContinue -ErrorVariable schemaErrors
.claude/lib/orchestrator-state/OrchestratorState.psm1:437:      Get-Command -Name Get-OrchestratorStateUnconditionalError -ErrorAction SilentlyContinue
.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1:92: Get-Command -Name 'Get-OrchestratorStateBasePresenceError' -ErrorAction SilentlyContinue
```

Two are capability probes and one captures schema violations into `-ErrorVariable`. In all three the
explicit `-ErrorAction` parameter takes precedence over the preference variable, so behavior is
unchanged. These are exactly the sites that would have broken, and they are already immune.

**3. The full suite passes with no repairs required.**

`evidence/qa-gates/final-pester-suite.2026-08-30T02-22.md` records 3881 passed, 0 failed, 9 skipped,
against a post-merge baseline of 3873 passed / 9 skipped. The increase of 8 is exactly the 8 tests
this feature added. No pre-existing test was repaired, weakened, or newly skipped. Acceptance
criterion 18 anticipated repairs as in-scope work; none were needed, which is a stronger outcome than
the criterion required.

**Caller preference is genuinely unchanged after import.** This was verified by execution, not by
reasoning alone: `It 'leaves the caller error preference unchanged after import'` passes, and the
mechanism is sound because module scope is a distinct session state and no module writes
`$global:ErrorActionPreference`. The `grep` above confirms all 28 assignments are unscoped module-root
assignments.

**Residual risk — consumer repositories.** The 28 bundle mirrors are delivered to consumer
repositories by push-down. A consumer whose own code depends on one of these modules tolerating a
non-terminating error would now see a throw. This risk cannot be measured from this repository. It is
low given finding 1 above — the modules do not emit non-terminating errors — but it is the correct
place to note that the change crosses a distribution boundary. The change is a revert of a commit
range with no state migration, so rollback is clean.

## Test quality assessment

### `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (new, 137 lines)

**Discovery cannot silently return an empty set.** The root is resolved with `Resolve-Path` at lines
25–26, which throws on a missing path rather than yielding `$null`. Discovery at lines 30–33 uses
`Get-ChildItem -Path $LibraryRoot -Filter '*.psm1' -File -Recurse` with no name restatement, and the
result is wrapped in `@(...)` so a single-item result does not collapse to a scalar. The anti-vacuity
`It` at line 45 asserts the count exceeds zero.

**All six `It` blocks can genuinely fail.** This was verified by negative control rather than by
inspection. A synthetic module lacking the guard, lacking the convention sentence, and carrying an
unguarded `Import-Module` was placed in a scratchpad directory outside the repository, and the three
primary assertion mechanisms were run against it verbatim:

```
discovered=1
guardTest_offender=True
importTest_offenders=1
helpTest_offender=True
```

Each mechanism flagged the violation. The assertions are not vacuous.

The remaining three blocks are sound by construction: the anti-vacuity block asserts a numeric floor;
the line-limit block collects offenders and asserts the collection is empty; the preference block
compares a captured value against a post-import read.

**The line-limit block counts physical lines.** Line 129 uses
`@(Get-Content -LiteralPath $path).Count`, not `Measure-Object -Line`. The comment at lines 124–125
states the reason correctly — `Measure-Object -Line` counts non-empty lines and would under-report a
module sitting at the cap. This matters here: two modules are at exactly 500 lines, so a
non-empty-line count would have concealed a future overrun. This is a considered choice, not an
accident.

**Independent execution.**

```
Invoke-Pester -Path './tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1' -Output Detailed
-> Tests Passed: 6, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

**Structure and hygiene.** Every block carries explicit Arrange/Act/Assert comments and a rationale
sentence explaining why the assertion matters, not merely what it does. The file creates no temporary
file, starts no process, reads no clock, and makes no network call. Comparison uses `-ceq` at line 61,
so a case variation in the guard line is caught rather than tolerated. Trimming before lookup at line
59 prevents trailing whitespace from producing a false negative, and the reason is stated in the
comment.

**Weaknesses.** Three, all recorded in the policy audit as W2, W3, W4: the anti-vacuity floor is zero
rather than a count; the non-leakage block samples `$DiscoveredModule[0]` rather than iterating; and
the imported module is not removed in an `AfterAll`, leaving it loaded for the remainder of the run.
None affects the current verdict; the first two would strengthen the test against future regressions
and the third is a test-independence hygiene item.

### `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` (extended, +25 lines)

**The date-coercion test distinguishes coercion from blanket conversion.** This is the point on which
such a test usually fails, and this one handles it correctly. The test asserts two things, not one:

```powershell
$result.State.last_updated | Should -BeOfType [System.DateTime]
$result.State.objective    | Should -BeOfType [System.String]
```

The second assertion is what makes the first meaningful. If `ConvertFrom-Json` converted every string
value, the first assertion would still pass and the test would prove nothing. Asserting that
`objective` — value `'deliver portable preflight'`, a non-date string — remains `System.String`
establishes that the conversion is selective and keyed on parseability. The test discriminates.

**The fixture value choice is correct and necessary.** The shared template `New-ReadyCheckpoint` sets
`last_updated = '2026-07-06T00-00'` at line 49. That value is not a parseable instant — the
`T00-00` time component uses hyphens rather than colons — so `ConvertFrom-Json` never coerces it and
it remains a `String`. A test built on the unmodified template would have asserted
`Should -BeOfType [System.DateTime]` against a `String` and failed, or, if written the other way,
would have asserted nothing about coercion at all. The test overrides the field with
`'2026-08-29T20:38:00Z'` and states the reason in the Arrange comment. This is the correct handling
and the rationale is recorded where a future maintainer will find it.

**The help-contract test is width-pinned.** `Get-Help -Full | Out-String -Width 500` at the Act step
prevents console width from wrapping the asserted literal and producing a spurious failure. The
matching token exists at `.claude/lib/orchestrator-state/OrchestratorState.psm1:145`.

**Fixture hygiene.** `Set-CheckpointFixture` mocks `Test-Path` and `Get-Content` against
module-scoped variables. No file is written. Both added tests use fixed literals with no clock or RNG
dependency, satisfying `.claude/rules/general-unit-test.md` §Determinism Infrastructure.

**Independent execution.**

```
Invoke-Pester -Path 'tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1' -PassThru
-> OS PASSED=48 FAILED=0
Passed :: returns an ISO-8601 valued checkpoint key as a DateTime under default date handling
Passed :: documents the checkpoint date-coercion contract in its comment-based help
```

## Specific code observations

### The 28th module's new help block is clean

`.claude/lib/requirements/GeneratedDocumentCounters.psm1` had no module-level help: `Set-StrictMode`
was line 1 and the first `#>` closed the help block of `Get-NamedSectionCheckboxCount`. An 11-line
module-level block was inserted above line 1.

The insertion is correct. The new block opens at line 1 and closes at line 10, two lines above
`Set-StrictMode` at line 12. The function's own help block, now beginning at line 15, is untouched
and still binds to `Get-NamedSectionCheckboxCount`. There is no nesting, no unterminated comment
region, and no ambiguity about which block belongs to which target. The convention test's help
assertion — which requires the token on a line preceding `Set-StrictMode` — passes for this module,
confirming the block is in the module-level position rather than the function-level one.

The text was fixed verbatim in the plan rather than improvised by the executor, which is visible in
the result: the SYNOPSIS and DESCRIPTION describe the module's actual behavior ("a pure function
that counts the markdown checkbox items contained by a named heading section. It reads no file,
starts no process, and never mutates its input") and are accurate against the implementation.

### The condensation in `DiscoveryValidation.psm1` removed no content

The module sat at exactly 500 lines before the change and needed two lines of headroom. The diff
shows a 16-line comment paragraph re-wrapped to 14 lines at a wider column. Comparing the two
versions word by word, no sentence, no error-family literal, and no divergence note was dropped. The
version-floor rationale required by acceptance criterion 7 is intact:

```
grep -c "Draft 2020-12 support in PowerShell 7.4" .claude/lib/discovery-validation/DiscoveryValidation.psm1
-> 2
```

`DiscoveryValidation.VersionFloor.Tests.ps1` is unmodified relative to base and passes:

```
git diff --name-only 6df37664..HEAD -- tests/.../DiscoveryValidation.VersionFloor.Tests.ps1  -> 0 paths
Invoke-Pester -> VF PASSED=13 FAILED=0
```

Re-wrapping prose to free headroom is the correct response here. The alternative — deleting
rationale — would have traded a durable explanation for two lines.

### Help-section placement of the convention sentence is inconsistent

Severity: Warning (Low). Not previously recorded.

The CONVENTION sentence lands in three different comment-based-help sections across the 28 modules:

```
26 modules -> .DESCRIPTION
 1 module  -> .EXAMPLE   (.claude/lib/discovery-validation/DiscoveryValidation.psm1:50)
 1 module  -> .NOTES     (.claude/lib/hook-payload/HookPayload.psm1:40)
```

`.NOTES` is a defensible location for a convention statement. `.EXAMPLE` is not: in
`DiscoveryValidation.psm1` the sentence follows the line
`Returns @{ ExitCode = 0; Output = '' } when the artifact conforms.`, so `Get-Help` renders it as
explanatory text belonging to that example rather than as a module-level statement.

This does not affect any test. The convention test asserts only that the token appears on a line
preceding `Set-StrictMode`, which holds in all three placements. The finding is about rendered
documentation quality for the consumer repositories that receive these modules.

Recommendation: move the sentence in `DiscoveryValidation.psm1` from the `.EXAMPLE` block into
`.DESCRIPTION`, matching the other 26 modules. This is a one-line move in two files (module and
mirror) and would need to preserve the 500-line count.

### Bundle mirror parity is byte-exact

Verified independently with a byte comparison rather than the string comparison the evidence
artifact used:

```
for f in $(find .claude/lib -name '*.psm1' | sort); do
  m="extensions/drm-copilot/resources/claude-customizations/$f"
  cmp -s "$f" "$m" || echo "MISMATCH $f"
done
-> DISCOVERED=28 MISMATCHED=0
```

All 28 pairs are byte-identical. The pytest contract test also passes
(`final-bundle-parity.2026-08-30T02-28.md`, `EXIT_CODE: 0`, `1 passed in 0.11s`). Two independent
mechanisms agree.

### File size limit

No module exceeds 500 lines. Two are at exactly 500 (`DiscoveryValidation.psm1` and its mirror),
which is compliant but leaves zero headroom. Five further modules are between 490 and 499. Seven of
28 modules therefore have 10 lines or fewer of headroom.

This is not a defect. It is a maintenance observation: the next feature that must edit
`DiscoveryValidation.psm1` will have to condense or split before it can add a line, and the
condensation lever has now been used once. The spec anticipated this and allocated headroom
explicitly, which was the right planning decision.

## Standards conformance

| Standard | Source | Result |
|---|---|---|
| Approved verbs, descriptive nouns | `.claude/rules/powershell.md` | PASS — no new functions introduced |
| No `Invoke-Expression`, secrets, hard-coded credentials | `.claude/rules/powershell.md` | PASS |
| `throw`/`Write-Error` over silent catch-all | `.claude/rules/powershell.md` | PASS — change strengthens this |
| PowerShell 7+ compatible | `.claude/rules/powershell.md` | PASS — PSScriptAnalyzer clean |
| Files under 500 lines | `.claude/rules/general-code-change.md` | PASS — maximum 500 |
| No broad refactor of unrelated modules | `.claude/rules/powershell.md` §Prohibited | PASS — every edit serves the stated convention |
| Assertions not weakened to pass | `.claude/rules/powershell.md` §Prohibited | PASS — no pre-existing test modified |
| No sleeps, retries, timing hacks | `.claude/rules/powershell.md` §Prohibited | PASS |
| Tone of authored prose | `.claude/rules/tonality.md` | PASS |

Tonality verification across all feature-authored Markdown and the new code comments:

```
SearchScope: docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/**/*.md,
             tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1,
             .claude/lib/requirements/GeneratedDocumentCounters.psm1
SearchPatterns: amazing|incredible|awesome|perfect|flawless|revolutionary|world-class|seamless|
                effortless|magic|blazing|rock-solid|bulletproof|delightful|painless|just works;
                emoji ranges U+1F300-1FAFF and U+2700-27BF; exclamation marks
SearchResult: 0 matches in all categories
```

The prose is measured throughout. Notably, the evidence artifacts distinguish command coverage from
line coverage explicitly and state that the two "are different metrics over different denominators
and must not be compared with each other" rather than quoting whichever figure looked better. The
`### Execution deviations` section states the coverage gap plainly, including the sentence "this
feature did not remedy it." That is evidence-first wording matching the strength of the evidence.

## Summary

The implementation is disciplined and the mechanical edit is applied uniformly across all 56 files
with no per-module drift. The test work is above average: the convention test is disk-discovering
and non-vacuous under negative control, and the date-coercion test asserts the discriminating
negative case rather than only the positive one. Behavioral risk from the module-scope preference is
real in principle but empirically low here, because no module in the set emits a non-terminating
error and the three sites depending on non-terminating behavior already override the preference
explicitly.

Findings recorded by this review: 0 Blocking, 1 new Warning (Low) for the `.EXAMPLE` help placement,
in addition to the 6 findings recorded in the policy audit.
