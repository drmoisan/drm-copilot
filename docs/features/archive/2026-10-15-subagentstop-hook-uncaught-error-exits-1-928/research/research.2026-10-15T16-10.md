# Research: SubagentStop validator uncaught error exits 1 (Issue #928)

- Issue: #928
- Branch: prep/928
- Work mode: full-bug
- Feature folder: docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928
- Date: 2026-10-15
- Method: every finding below was verified by reading the cited file at the cited line in this worktree, or by the cited vendor documentation. Statements that were not run are marked as expected or inferred.

## Summary

- The nine SubagentStop validators that dot-source the shared helper are confirmed (Q1). Six are registered in `.claude/settings.json`; three are registered only in agent frontmatter.
- A load failure of any dependency is already converted to exit 2 by the #786 guard pattern. The remaining exit-1 path is an uncaught terminating error raised after the dependency tail, inside the `Invoke-*` validation call or the decision check (Q2).
- `validate-feature-review-coverage.ps1` already carries the required tail `try`/`catch` (`.claude/hooks/validate-feature-review-coverage.ps1:202-203`). The other eight do not.
- Recommended fix: a per-validator `try`/`catch` around the validation call, placed after the three S1 tail statements, with the `catch` calling `Exit-SubagentStopBlock`. The helper is not changed apart from the requested comment citation. The structural test `HookGuardShape.Helpers.ps1` rules out a whole-script `try` or a leading `trap`, and PowerShell scoping rules out a `trap` declared in the dot-sourced helper (Q3).
- Tests: one new data-driven Pester file with nine rows. Each row drives one validator through the existing in-process `&` route and mocks `Read-SubagentStopEnvelope` to throw. No temporary files and no environment variable are used (Q4).
- No Codex change is required. Both Codex SubagentStop hooks already wrap their bodies in a `try`/`catch` that exits 2, and neither dot-sources the helper (Q5).

## Q1. The nine SubagentStop validators

### Registrations

`.claude/settings.json` `hooks.SubagentStop` (lines 213-286):

| Line | Matcher | Script |
| --- | --- | --- |
| 219 | broad generic-agent matcher (line 215) | `validate-discovery-artifact-gate.ps1` |
| 228 | `feature-review` | `validate-feature-review-coverage.ps1` |
| 237 | `atomic-planner` | `validate-planner-output.ps1` |
| 246 | `prd-feature` | `validate-prd-feature-output.ps1` |
| 255 | `pr-author` | `validate-pr-author-output.ps1` |
| 264, 273, 282 | `orchestrator`, `epic-orchestrator`, `parallel-orchestrator` | `validate-orchestrator-output.ps1` (with `-CheckpointPath`/`-ArtifactType` for the latter two) |

Agent frontmatter `hooks.SubagentStop` blocks (for example `.claude/agents/atomic-executor.md:31-36`):

| Agent file:line | Script |
| --- | --- |
| `.claude/agents/atomic-executor.md:36` | `validate-executor-output.ps1` |
| `.claude/agents/atomic-planner.md:23` | `validate-planner-output.ps1` |
| `.claude/agents/task-researcher.md:19` | `validate-task-researcher-output.ps1` |
| `.claude/agents/prd-feature.md:18`, `:20` | `validate-required-artifact-output.ps1`, `validate-prd-feature-output.ps1` |
| `.claude/agents/epic-review.md:18`, `staged-review.md:19`, `status-updater.md:19` | `validate-required-artifact-output.ps1` |
| `.claude/agents/pr-author.md:27` | `validate-pr-author-output.ps1` |
| `.claude/agents/feature-review.md:22` | `validate-feature-review-coverage.ps1` |
| `.claude/agents/orchestrator.md:42`, `epic-orchestrator.md:29`, `parallel-orchestrator.md:43` | `validate-orchestrator-output.ps1` |

The bundled `settings.json` is kept text-equal to the repository copy by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`.

### Helper consumers

Each of the nine validators guards the helper dot-source in a single-statement `try` (`try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure ... }`):

| Validator | Helper dot-source line |
| --- | --- |
| `validate-discovery-artifact-gate.ps1` | 44 |
| `validate-executor-output.ps1` | 38 |
| `validate-feature-review-coverage.ps1` | 59 |
| `validate-orchestrator-output.ps1` | 63 |
| `validate-planner-output.ps1` | 40 |
| `validate-pr-author-output.ps1` | 34 |
| `validate-prd-feature-output.ps1` | 17 |
| `validate-required-artifact-output.ps1` | 39 |
| `validate-task-researcher-output.ps1` | 28 |

The same nine are listed in `docs/features/active/subagentstop-envelope-core-897/spec.md:106`. Every registered Claude SubagentStop hook uses the helper; no Claude SubagentStop registration names a script outside this set.

## Numeric Derivation Evidence

- Numeric spec.md acceptance criterion: all 9 SubagentStop validators convert an unhandled error to exit 2, with one forced-error test each (9 rows).
- Complete Family: SubagentStop validators
- Exhaustive Search Scope: entire worktree, covering every .claude/hooks/*.ps1 file, .claude/settings.json, and every .claude/agents/*.md frontmatter
- Inclusion Rules: a .claude/hooks script that is registered as a Claude SubagentStop command and dot-sources subagentstop-envelope.ps1 through a guarded try
- Exclusion Rules: dot-sourced siblings that are not registered (validate-orchestrator-output-resolution.ps1, validate-orchestrator-output-routing.ps1, validate-feature-review-coverage-metrics.ps1, validate-feature-review-coverage-rules.ps1), Codex SubagentStop hooks (.codex/hooks), bundle mirror copies, and docstring-only mentions of the helper
- Primary Search Strategy or Query Expression: Grep of .claude for the guarded helper dot-source text `try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') }`, keeping hook files only, to enumerate SubagentStop validators
- Primary Member Set: validate-discovery-artifact-gate.ps1, validate-executor-output.ps1, validate-feature-review-coverage.ps1, validate-orchestrator-output.ps1, validate-planner-output.ps1, validate-pr-author-output.ps1, validate-prd-feature-output.ps1, validate-required-artifact-output.ps1, validate-task-researcher-output.ps1
- Primary Count: 9
- Cross-check Search Strategy or Query Expression: union of the script paths in the hooks.SubagentStop commands of .claude/settings.json and of the hooks.SubagentStop blocks in .claude/agents/*.md frontmatter, deduplicated by file name, to enumerate registered SubagentStop validators
- Cross-check Member Set: validate-discovery-artifact-gate.ps1, validate-feature-review-coverage.ps1, validate-planner-output.ps1, validate-prd-feature-output.ps1, validate-pr-author-output.ps1, validate-orchestrator-output.ps1, validate-executor-output.ps1, validate-required-artifact-output.ps1, validate-task-researcher-output.ps1
- Cross-check Count: 9
- Member-set Comparison: the normalized (lower-cased, sorted) primary and cross-check member sets are identical. Both also match the nine names listed in docs/features/active/subagentstop-envelope-core-897/spec.md line 106.

## Q2. Current top-level structure and exit-1 paths

### Common structure (all nine)

1. `[CmdletBinding()] param(...)`.
2. S1 bootstrap: `$script:HookDependencyGuardLoadFailed = $false; try { . hook-dependency-guard.ps1 } catch { flag = $true }`.
3. Single-statement guarded loads. Each `catch` calls `Add-HookDependencyFailure` (`.claude/hooks/hook-dependency-guard.ps1:24-46`).
4. Function definitions.
5. `if ($MyInvocation.InvocationName -eq '.') { return }` (the dot-source early return for tests).
6. S1 tail, verified by `tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1:35-57`. It consists of exactly these three statements in this order: the bootstrap-flag check (stderr, then `exit 2`), `$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop ...`, and `if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine(...); exit $dependencyDecision.ExitCode }`.
7. The validation call, `if (-not $result.Ok) { Exit-SubagentStopBlock -Message ... }`, and `exit 0`.

### Per-validator detail

| Validator (lines) | `Set-StrictMode` | `$ErrorActionPreference` | Other guarded loads before the helper | Dependency prefix (S1 tail) | Content prefix | Tail lines | Tail `try`/`catch` |
| --- | --- | --- | --- | --- | --- | --- | --- |
| discovery-artifact-gate (253) | none | default (Continue) | none; `DiscoveryValidation.psm1` after the helper (45) | `DISCOVERY_ARTIFACT_GATE_BLOCKED:` | same | 244-253 | no |
| executor-output (322) | Latest (37) | Stop (39) | none | `validate-executor-output:` | `atomic-executor hook:` | 313-322 | no |
| feature-review-coverage (205) | none | Stop (61) | thresholds, metrics, rules siblings (56-58) | `validate-feature-review-coverage:` | same | 195-205 | yes (202-203) |
| orchestrator-output (344) | Latest (53) | Stop (64) | resolution and routing siblings, five modules (55-62) | `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` | `orchestrator hook:` and others | 335-344 | no |
| planner-output (440) | Latest (39) | Stop (41) | none | `validate-planner-output:` | `atomic-planner hook:` | 431-440 | no |
| pr-author-output (129) | none | default (Continue) | none | `PR_AUTHOR_OUTPUT_MISSING:` | `PR_AUTHOR_OUTPUT_*:` | 120-129 | no |
| prd-feature-output (118) | Latest (19) | Stop (20) | none | `validate-prd-feature-output:` | `prd-feature hook:` | 112-118 | no |
| required-artifact-output (199) | Latest (38) | Stop (40) | none | `validate-required-artifact-output:` | `<AgentName> hook:` | 184-199 (argument check 191-196) | no |
| task-researcher-output (290) | Latest (30) | Stop (31) | none | `validate-task-researcher-output:` | `task-researcher hook:` | 282-290 | no |

`$script:SubagentStopReportAndHaltLine` is defined only in executor (40), orchestrator (65), planner (42), and required-artifact (41).

### Paths that end in exit 1 today

1. **Errors before the helper loads.** These are already handled. The guard bootstrap and every guarded load sit in single-statement `try` blocks, so a failed dot-source or `Import-Module` sets the flag or records a failure, and the S1 tail exits 2. Existing tests cover this: B1/B2/B3 in `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1:134-190`, and E-EXE-5/E-EXE-6 in `validate-executor-output.Envelope.Tests.ps1:129-156`. The remaining unguarded statements before the tail (`Set-StrictMode`, the `$ErrorActionPreference` assignment, the halt-line assignment, and function definitions) are not expected to throw.
2. **Errors in the validation call (the gap).** Any terminating error raised inside `Invoke-*Validation` or `Get-PrAuthorOutputDecision` that is not caught locally propagates to the script top level, and `pwsh -File` exits 1. The 897 live differential found that exit 1 does not block (`docs/features/active/subagentstop-envelope-core-897/spec.md:12`). Concrete examples:
   - executor and planner: `Get-Content -ErrorAction Stop` in `Get-PlanFileContent` (`validate-executor-output.ps1:54`, `validate-planner-output.ps1:56`), and `Set-StrictMode` violations in the decision functions.
   - task-researcher: `& $ReadFileContent` (`validate-task-researcher-output.ps1:153`) has no local `catch`.
   - orchestrator: `Get-CheckpointFileContent` (`:88`), `Invoke-RoutingContractValidation` (`:311`), and `Get-OrchestratorOutputWaveBarrierDecision` (`:327`) run outside any local `try`. The resolver call at `:246-251` is caught locally.
   - discovery gate: `Import-Module ... -ErrorAction Stop` inside `Invoke-DiscoveryValidatorExe` (`validate-discovery-artifact-gate.ps1:81`).
   - all nine: `Get-SubagentStopEnvelopeAnomalyReason` throws `ArgumentException` for an unknown code (`.claude/hooks/subagentstop-envelope.ps1:50`). This is not reachable while `Read-SubagentStopEnvelope` keeps to its contract.
3. **Statement-terminating errors when `$ErrorActionPreference` is Continue (discovery gate, pr-author).** A .NET method exception inside a function is statement-terminating, so execution can continue to `exit 0` (fail open) instead of exiting 1. With a `try` on the call stack, PowerShell routes such errors to the enclosing `catch`, so the recommended fix is expected to turn these into exit 2 as well. This behavior was inferred from the documented semantics; no run in this research confirmed it.
4. **Exits that no in-script handler can catch.** A parse error in the script, or a parameter-binding failure of the script's own `param()` under `pwsh -File`, happens before any statement runs. All registrations pass literal arguments, so binding failure is not expected in practice. These remain residual risks, and the existing parse checks (PSScriptAnalyzer and Pester dot-source) mitigate them.

## Q3. Helper contract and design options

### Helper contract (verified)

- Location: `docs/features/active/subagentstop-envelope-core-897/spec.md:10-82`, section `## Authoritative Helper Contract`. `docs/features/archive/` does not exist in this worktree yet.
- File rules (`:16-22`): dot-sourced only, not registered, imports nothing, writes nothing to the success or warning streams, reads no environment variable, and has a byte-identical bundled mirror listed in `core.json`.
- `Exit-SubagentStopBlock -Message` (`:65-69`; implementation `.claude/hooks/subagentstop-envelope.ps1:171-191`): the `Message` parameter is `[Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]`, and the body is `[Console]::Error.WriteLine($Message); exit 2`. A null or empty message fails at parameter binding and does not exit.
- Consumer policy (`:71-78`): item 2 says non-repairable conditions use report-and-halt wording and block once. Item 5 says the S1 dependency tail stays inline and that `Exit-SubagentStopBlock` replaces the final validation-failure exit. Using `Exit-SubagentStopBlock` in a new `catch` is additive to item 5 and does not conflict with the helper contract.

### #786 precedent

#786 (PR #881) introduced `hook-dependency-guard.ps1`, which records each failed load and returns a SubagentStop result `{ ExitCode = 2; Reason }` (`hook-dependency-guard.ps1:79-114`). Each hook writes that result to stderr and exits 2 inline in its tail. The #786 spec records the exit-code rationale (`docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md:24`, D1 at `:50`, R2 at `:259`). The same spec records the per-hook pattern: inline per-hook handling, stderr reason with the hook's own prefix, then `exit 2`. The repository has no centralized wrapper for this.

### Options

**(a) Per-validator tail `try`/`catch` (recommended).** Insert the following after the three S1 tail statements:

```powershell
try { $result = Invoke-<X>Validation <existing args> }
catch { Exit-SubagentStopBlock -Message ('<dependency prefix> validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + '<report-and-halt line>') }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

- This is the existing pattern at `validate-feature-review-coverage.ps1:202-203`, so it introduces no new mechanism.
- It satisfies the S1 structural test. `Get-HookGuardTailFinding` requires the three statements at `index+1..index+3` immediately after the early return, and the `try` occupies `index+4`.
- `Exit-SubagentStopBlock` is guaranteed to be defined at that point, because a helper load failure has already exited 2 through the S1 tail.
- Exits stay outside the `try` body, as in the precedent. PowerShell does not route `exit` through `catch`, but the design does not rely on that.
- Errors raised before the helper loads are already covered by the #786 guard (Q2, path 1), so option (a) needs no pre-helper handling.
- Cost: two to three lines per validator, plus docstring `.NOTES` text.

**(b) Helper-provided wrapper, for example `Invoke-SubagentStopValidator -ScriptBlock {...} -ReasonPrefix ...` (rejected).**

- It changes the governing helper contract (a fourth function and a scriptblock invocation), which requires amending the 897 spec section, which belongs to another item.
- It does not handle anything that option (a) misses, because it can only run after the helper loads.
- The enforcement scan in `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1:368-399` allows `& $ScriptBlock` only through the `[scriptblock]`-parameter carve-out. That adds a constraint on the shape of the wrapper.

**(c) A `trap` declared in the helper (rejected, does not work).**

- about_Trap (PowerShell 7.6, Microsoft Learn) states: "A `trap` statement is scoped to where it compiles. If you have a `trap` statement inside a function or dot sourced script, when the function or dot sourced script exits, all `trap` statements inside are removed." A trap in `subagentstop-envelope.ps1` would therefore not cover the validator's own statements.
- The helper contract also limits the helper to function definitions.
- A script-level `trap` in each validator is also unsuitable:
  - about_Trap states that traps are hoisted to cover every statement in the script block, so the trap would also fire on the statement-terminating `Add-HookDependencyFailure` call inside a load `catch` when the guard bootstrap has failed. That would replace the specific bootstrap reason asserted by B3 (`hook-dependency-failure.Claude.Tests.ps1:183-190`).
  - It would also fire during test dot-sourcing.
  - A whole-script `try` would break the S1 bootstrap check, which requires the flag assignment and the guard `try` to be the first two top-level statements (`HookGuardShape.Helpers.ps1:21-33`).

### Reason text and re-entry

- Use each validator's S1 dependency prefix (the column in Q2), followed by `validator error: <first exception line>; the gate fails closed.`. This matches the precedent and the R-PREFIX table in `hook-dependency-failure.Claude.Tests.ps1:71-102`.
- For the halt sentence, use `$script:SubagentStopReportAndHaltLine` where it is defined. In the other four validators (discovery, pr-author, prd-feature, task-researcher), use the same text as a literal.
- `validate-feature-review-coverage.ps1` keeps its existing text (`:203`).
- Re-entry: the crash block is always applied. The `catch` has no parsed envelope, so it cannot read `stop_hook_active`. This matches the existing always-block behavior of the dependency-failure tail (E-EXE-5 asserts exit 2 with `stop_hook_active: true`, `validate-executor-output.Envelope.Tests.ps1:129-142`) and of the feature-review tail `catch`.
- Residual risk: a deterministic crash re-blocks on every stop. This is the same exposure as an existing dependency failure, and the halt wording directs the subagent to report to the operator.

## Q4. Test infrastructure and fault injection

### Existing mechanisms (verified)

- **In-process `&` route.** Tests run the hook with `& $hookPath`. They swap stdin with `[Console]::SetIn([System.IO.StringReader]::new(...))` and capture stderr with `[Console]::SetError([System.IO.StringWriter]::new())`, read `$LASTEXITCODE`, and restore all of these in `finally`. See `validate-executor-output.Envelope.Tests.ps1:27-56` (`Invoke-HookTail`, which also captures `Thrown`) and `hook-dependency-failure.Claude.Tests.ps1:104-124` (`Invoke-HookProcess`).
- **No subprocess.** In-process, an uncaught throw surfaces to the test as an exception (`Thrown`), and `$LASTEXITCODE` stays 0. A test that asserts `Thrown` is null and `ExitCode` is 2 therefore fails before the fix and passes after it.
- **`Exit-SubagentStopBlock` fixture.** `tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1` dot-sources the helper and calls `Exit-SubagentStopBlock` through the `&` route (used at `subagentstop-envelope.Tests.ps1:255-271`). It does not inject faults.
- **Fault injection.** Existing tests use Pester mocks of seams, which take precedence over the functions the hook redefines when it runs. Examples: `Mock Join-Path { throw ... }` and `Mock Import-Module { throw ... }` (B1), `Mock Get-PlanFileContent` (E-EXE-2), `Mock Resolve-OrchestratorOutputCheckpointPath { throw ... }` (`validate-orchestrator-output.Envelope.Tests.ps1:156`), and `Mock Get-Content { throw ... }` (`validate-task-researcher-output.Coverage.Tests.ps1:154`).
- **Existing forced error for feature-review.** E4-TR3 in `validate-feature-review-coverage.Coverage.Tests.ps1:356-366` forces a validator error. That error is caught by the inner `try` (`:81-187`), not by the tail `catch`.

### Proposed mechanism

`Mock Read-SubagentStopEnvelope { throw 'simulated unhandled error (issue #928)' }`.

- All nine validators call `Read-SubagentStopEnvelope` inside their validation call, after the dependency check. In feature-review the call is at `:72`, outside the inner `try`, so the error reaches the tail `catch`.
- The test file dot-sources `subagentstop-envelope.ps1` in `BeforeAll` so that the command exists when it is mocked.
- `Mock Import-Module { }` keeps module loads inert, following the existing rows.
- `validate-required-artifact-output.ps1` needs `-AgentName` and `-RequiredArtifact` passed through the parameter splat, so that the argument check at `:191-196` is skipped and the validation call is reached.
- Assertions per row: `Thrown` is null; `ExitCode` is 2; `Stderr` starts with the dependency prefix (ordinal comparison) and contains `simulated unhandled error (issue #928)`; and `Should -Invoke Read-SubagentStopEnvelope -Times 1 -Exactly`.

Policy constraints:

- The helper's rule "reads no environment variable" (`897 spec.md:20`) rules out an environment-variable seam in the helper. The mock-based seam needs no environment variable and no production seam change.
- Temporary files are prohibited in tests (`.github/instructions/general-unit-test.instructions.md:82`; `.claude/rules/general-unit-test.md`). `.claude/rules/powershell.md` does not mention `TestDrive`. `TestDrive` is a temporary filesystem location and should not be used. `.claude/hooks/check-powershell-test-purity.ps1:108-118` rejects `New-TemporaryFile`, temp-path use, and `Start-Process`, so a real `pwsh -File` subprocess test is also not permitted. The `&` route is the established substitute.

Placement:

- Create one new file, `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`.
- It holds a nine-row `-ForEach` table with columns Hook, Parameters, and Prefix.
- Add a completeness row, modelled on B4 (`hook-dependency-failure.Claude.Tests.ps1:192-195`). It asserts that the table keys equal the set of `.claude/hooks/*.ps1` files whose AST contains the guarded `subagentstop-envelope.ps1` dot-source, so that a future validator cannot be added without a row.

Fail-first expectation:

- Eight rows are expected to fail before the fix.
- The `validate-feature-review-coverage.ps1` row is expected to pass before the fix, because the tail `catch` already exists. The regression evidence should record this as an expected pre-existing pass, not as a fail-first failure.

## Q5. Mirrors, parity tests, CI, and coverage

- **Claude bundle mirrors.** All nine validators and the helper have bundled copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`) asserts that each repository `.claude` file has text-equal bundle content. `test_planner_review_resources_exist_and_are_byte_identical` (`:113-123`) asserts byte identity for `validate-planner-output.ps1`. The helper docstring states that its mirror is byte-identical (`subagentstop-envelope.ps1:16-17`). Each edited `.claude/hooks` file must therefore be copied byte-for-byte to its mirror. No production file is added, so `core.json` does not change.
- **Codex.** `.codex/config.toml:236-252` registers two SubagentStop hooks, `validate-codex-subagent-routing.ps1` and `validate-feature-review-coverage.ps1`. Neither dot-sources the helper. Both already wrap their bodies in a top-level `try`/`catch` that writes stderr and exits 2 (`.codex/hooks/validate-feature-review-coverage.ps1:244-316`; `.codex/hooks/validate-codex-subagent-routing.ps1:140-159`). The 897 spec excludes `.codex/` (`spec.md:111`). No Codex change and no Codex-bundle change is required.
- **Settings tests.** `tests/scripts/claude-runtime/claude-settings.Tests.ps1:190-193` asserts that no hook command references the helper. That is unaffected because no registration changes.
- **Structural tests.** `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (S1/S2/S3/S6 via `HookGuardShape.Helpers.ps1`) is unaffected if the `try` is placed after the third tail statement. A placement before the tail, or a whole-script wrapper, fails S1.
- **CI.** `.github/workflows/_poshqc.yml` runs two jobs:
  - `poshqc` ("PowerShell QC", windows-latest, `:8-52`): format, analyze, and `Invoke-PoshQCTest` with coverage.
  - `poshqc-linux-hooks` ("PowerShell hook suites (Linux)", `:54-90`): Pester over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with coverage disabled. Placing the new test file under `tests/scripts/claude-hooks/` runs it in both jobs. Its in-memory stdin/stderr swaps contain no Windows-specific path.
  - The Python parity tests run in the pytest job.
- **Coverage.** `config/poshqc-coverage.json` roots include `.claude/hooks`, so all nine validators and the helper are in the Pester coverage population. Bundle mirrors under `extensions/` are not. Pester measures line coverage only, and no branch gate applies to PowerShell. The new `catch` lines are executed in-process by the new rows, so changed-line coverage is expected to be covered.

## Q6. File sizes

Line counts were read from the files in this worktree. Bundle mirrors are text-identical per the parity test, so they share the counts.

| File | Lines now | Expected change | Note |
| --- | --- | --- | --- |
| `.claude/hooks/subagentstop-envelope.ps1` (and mirror) | 191 | citation text only | |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` (and mirror) | 253 | +2 to +4 | |
| `.claude/hooks/validate-executor-output.ps1` (and mirror) | 322 | +2 to +4 | |
| `.claude/hooks/validate-feature-review-coverage.ps1` (and mirror) | 205 | none expected | already compliant |
| `.claude/hooks/validate-orchestrator-output.ps1` (and mirror) | 344 | +2 to +4 | |
| `.claude/hooks/validate-planner-output.ps1` (and mirror) | 440 | +2 to +4 | closest to the 500-line limit; keep the change to the tail and a one-line `.NOTES` addition |
| `.claude/hooks/validate-pr-author-output.ps1` (and mirror) | 129 | +2 to +4 | |
| `.claude/hooks/validate-prd-feature-output.ps1` (and mirror) | 118 | +2 to +4 | |
| `.claude/hooks/validate-required-artifact-output.ps1` (and mirror) | 199 | +2 to +4 | |
| `.claude/hooks/validate-task-researcher-output.ps1` (and mirror) | 290 | +2 to +4 | |
| `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | 278 | citation text only | |
| `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` | new | estimated 120-180 | |

No file is expected to exceed 500 lines.

## Q7. Documentation of the SubagentStop exit-code contract

- The validators' own `.NOTES` blocks describe exit 0 and exit 2 for block decisions, for example `validate-executor-output.ps1:25-30` and `validate-feature-review-coverage.ps1:44-51`. Each changed validator should add one sentence stating that an unhandled error blocks with exit 2.
- `docs/engineering/claude-code-architecture.md:239` states that the SubagentStop hook "exits with code 1 and blocks the subagent from stopping". This is incorrect: exit 1 does not block (897 spec `:12`). It also describes the inline command that #897 removed. This text describes the exit-code contract directly, so it should be corrected in this item. The file is not mirrored.
- Related stale statements outside the hook surface:
  - `.agents/skills/translate-claude-to-codex/SKILL.md:285` ("SubagentStop, exit 1").
  - `.claude/skills/epic-orchestrate/SKILL.md:279-281`, which cites the pre-#904 exit-code defect.

  Editing the `.claude/skills` file requires its bundle mirror. Before editing the `.agents` skill, check whether it has a mirror under `codex-and-agents-customizations`. These two are listed as optional related corrections and are not part of the minimal fix.
- No `.claude/rules` or `.github/instructions` file states the SubagentStop exit-code contract.

## Added scope: 897 spec citations

- Exactly three citations of `docs/features/active/subagentstop-envelope-core-897/spec.md` exist outside `docs/`:
  - `.claude/hooks/subagentstop-envelope.ps1:12`
  - its bundled mirror, at line 12
  - `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1:9`

  These were found by a Grep of the whole worktree excluding `docs/`.
- No test asserts the citation text. The only matches in `tests` are the docstring lines 8-9.
- `docs/features/archive/` does not exist yet, and the 897 folder is still under `docs/features/active/`. To satisfy the either-location rule, cite the archive path and name the active path as the interim location. Example: `docs/features/archive/subagentstop-envelope-core-897/spec.md (issue #897; docs/features/active/subagentstop-envelope-core-897/ until the archive move lands)`.
- The helper and its mirror must stay byte-identical after the edit.

## Automation Feasibility

All work in this item can be automated, with no human-interaction requirement:

- Every change is a text edit to files in the repository: eight validator tails and `.NOTES` blocks, byte copies to the bundle mirrors, three comment citations, one new Pester file, and one docs line.
- Every verification runs locally and in CI without operator action:
  - Pester through the in-process `&` route.
  - PoshQC format, analyze, and test.
  - The pytest bundle-parity tests.
  - The S1 structural test.
- No external service, credential, interactive prompt, or manual runtime observation is required. The behavior under test is established by the existing in-process exit-code harness, so a live Claude Code differential is not needed.
- One known environment caveat: agent worktrees may deny `pwsh` in shell text. Run PoshQC through the `mcp__drm-copilot__run_poshqc_*` tools, as the atomic-executor allowlist provides (`.claude/agents/atomic-executor.md:21-24`).

## Recommended Approach

1. Leave `.claude/hooks/subagentstop-envelope.ps1` functionally unchanged. Change only the line-12 citation, then byte-copy the file to the mirror.
2. In each of the eight non-compliant validators (discovery-artifact-gate, executor, orchestrator, planner, pr-author, prd-feature, required-artifact, task-researcher):
   - Wrap only the validation call in `try { $result = ... } catch { Exit-SubagentStopBlock -Message '<dependency prefix> validator error: <first exception line>; the gate fails closed.<newline><report-and-halt line>' }`, using the precedent at `validate-feature-review-coverage.ps1:202-203`.
   - Place it immediately after the three S1 tail statements, and keep `if (-not $result.Ok) { Exit-SubagentStopBlock ... }` and `exit 0` after it.
   - For pr-author, wrap `$decision = Get-PrAuthorOutputDecision`.
   - For required-artifact, wrap the `Invoke-RequiredArtifactOutputValidation` call. Its argument check (`:191-196`) calls only the helper reader, which does not throw by contract.
   - Add one `.NOTES` sentence about the unhandled-error block.
3. Leave `validate-feature-review-coverage.ps1` unchanged. It is already compliant.
4. Byte-copy each changed hook to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
5. Add `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`:
   - nine data-driven rows, each mocking `Read-SubagentStopEnvelope` to throw and asserting exit 2, the stderr prefix, the error text, no propagated exception, and one call to the mock;
   - a completeness row tying the table to the AST-discovered helper consumers.
6. Update the test docstring citation (`subagentstop-envelope.Tests.ps1:9`) and correct `docs/engineering/claude-code-architecture.md:239`.
7. Fail-first evidence: eight rows fail before the fix (exception propagated, `$LASTEXITCODE` 0). The feature-review row passes before the fix and should be recorded as a characterization row.

Rejected alternatives: a helper-provided wrapper entry point (it requires amending the governing 897 contract and adds nothing for errors before the helper loads); a `trap` in the helper (it is removed when the dot-sourced script exits, per about_Trap); a script-level `trap` or whole-script `try` in each validator (it would conflict with the S1 structural test and the B3 bootstrap reason).

## Files In Scope

.claude/hooks/subagentstop-envelope.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1
.claude/hooks/validate-discovery-artifact-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1
.claude/hooks/validate-executor-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-executor-output.ps1
.claude/hooks/validate-orchestrator-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
.claude/hooks/validate-planner-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1
.claude/hooks/validate-pr-author-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1
.claude/hooks/validate-prd-feature-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1
.claude/hooks/validate-required-artifact-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-required-artifact-output.ps1
.claude/hooks/validate-task-researcher-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1
tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1
tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1
docs/engineering/claude-code-architecture.md

Referenced without expected change (verification only):

.claude/hooks/validate-feature-review-coverage.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1
tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
tests/scripts/claude-runtime/claude-settings.Tests.ps1
