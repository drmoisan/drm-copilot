# subagentstop-hook-uncaught-error-exits-1 (Spec)

- **Issue:** #928
- **Parent (optional):** none (follow-up to epic #904, code-review finding NB-6)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T06-23
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-bug (AC source: this file only)
- **Research:** `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/research/research.2026-10-15T16-10.md`

## Context

SubagentStop validators block with exit 2 for deliberate block decisions (epic #904). An uncaught terminating error raised inside a validator's validation call still ends the `pwsh -File` process with exit 1. SubagentStop does not block on exit 1 (897 live differential, `docs/features/active/subagentstop-envelope-core-897/spec.md:12`), so a crashing validator lets the subagent result through unchecked (E3 code-review NB-6).

Environment:
- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. Make any SubagentStop validator (for example `.claude/hooks/validate-task-researcher-output.ps1`) throw an unhandled terminating error inside its validation call.
2. Observe exit code 1; the SubagentStop event is not blocked.

Expected:
Any unhandled error in a SubagentStop validator blocks (exit 2) with a reason, consistent with fail-closed hook policy.

Actual:
The process exits 1 and the event proceeds.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: E3 code-review NB-6 (`docs/features/active/subagentstop-envelope-artifact-gates-905/code-review.2026-10-12T04-58.md`): "An uncaught terminating error in any hook still ends the pwsh -File process with exit 1, which does not block a SubagentStop event."

Concrete exit-1 sources identified in research (Q2, path 2): `Get-Content -ErrorAction Stop` in `Get-PlanFileContent` (`validate-executor-output.ps1:54`, `validate-planner-output.ps1:56`); `& $ReadFileContent` without a local `catch` (`validate-task-researcher-output.ps1:153`); `Get-CheckpointFileContent`, `Invoke-RoutingContractValidation`, and `Get-OrchestratorOutputWaveBarrierDecision` outside any local `try` (`validate-orchestrator-output.ps1:88`, `:311`, `:327`); `Import-Module ... -ErrorAction Stop` in `Invoke-DiscoveryValidatorExe` (`validate-discovery-artifact-gate.ps1:81`).

## Scope & Non-Goals

- In scope:
  - Converting any unhandled terminating error raised in the validation call of each SubagentStop validator to `Exit-SubagentStopBlock` (exit 2) with a reason.
  - One data-driven Pester file that forces an unhandled error in each validator and asserts exit 2 with reason text, plus a completeness row.
  - Byte-identical bundle mirrors for every changed `.claude` file.
  - Updating the comment and docstring citations of the 897 spec to the archive path.
  - Correcting stale documentation of the SubagentStop exit-code contract (operator policy: related follow-ups are fixed inside the item).
- Out of scope / non-goals: see `## Out of Scope`.
- Explicitly excluded systems, integrations, or datasets: `.codex/` hooks and the Codex bundle (no change required; see Non-change: Codex below).

## Root Cause Analysis

- The SubagentStop validators family (research `## Numeric Derivation Evidence`; primary and cross-check member sets identical, count 9) is: `validate-discovery-artifact-gate.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`, `validate-orchestrator-output.ps1`, `validate-planner-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, all under `.claude/hooks/`.
- Dependency load failures are already converted to exit 2 by the #786 guard pattern (single-statement guarded loads plus the S1 tail; covered by B1/B2/B3 in `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1:134-190`).
- The remaining gap is the validation call that follows the S1 tail. Any terminating error raised there that is not caught locally propagates to the script top level, and `pwsh -File` exits 1.
- `validate-feature-review-coverage.ps1` already wraps its validation call in a tail `try`/`catch` (`:202-203`) and is compliant. The other validators in the family have no such wrapper.
- In `validate-discovery-artifact-gate.ps1` and `validate-pr-author-output.ps1`, `$ErrorActionPreference` is the default (Continue), so a .NET method exception can be statement-terminating and fall through to `exit 0`. With a `try` on the call stack, PowerShell routes such errors to the enclosing `catch`; the fix is expected to convert these to exit 2 as well (confirmed in-process by the U1-ST rows of tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1, remediation cycle 1).

## Proposed Fix

### Design summary (what changes where)

Per research option (a), each non-compliant validator gains a tail `try`/`catch` around its validation call, using the existing precedent at `.claude/hooks/validate-feature-review-coverage.ps1:202-203`:

```powershell
try { $result = Invoke-<X>Validation <existing args> }
catch { Exit-SubagentStopBlock -Message ('<dependency prefix> validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + '<report-and-halt line>') }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

The non-compliant validators and their changes:

| Validator | Wrapped call | Reason prefix (S1 dependency prefix) | Halt line source |
| --- | --- | --- | --- |
| `validate-discovery-artifact-gate.ps1` | existing validation call | `DISCOVERY_ARTIFACT_GATE_BLOCKED:` | literal |
| `validate-executor-output.ps1` | existing validation call | `validate-executor-output:` | `$script:SubagentStopReportAndHaltLine` |
| `validate-orchestrator-output.ps1` | existing validation call | `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` | `$script:SubagentStopReportAndHaltLine` |
| `validate-planner-output.ps1` | existing validation call | `validate-planner-output:` | `$script:SubagentStopReportAndHaltLine` |
| `validate-pr-author-output.ps1` | `$decision = Get-PrAuthorOutputDecision ...` | `PR_AUTHOR_OUTPUT_MISSING:` | literal |
| `validate-prd-feature-output.ps1` | existing validation call | `validate-prd-feature-output:` | literal |
| `validate-required-artifact-output.ps1` | `Invoke-RequiredArtifactOutputValidation ...` (argument check at `:191-196` stays outside) | `validate-required-artifact-output:` | `$script:SubagentStopReportAndHaltLine` |
| `validate-task-researcher-output.ps1` | existing validation call | `validate-task-researcher-output:` | literal |

Where the halt line is literal, the text is the same as the `$script:SubagentStopReportAndHaltLine` value used by the other validators.

### Boundaries and invariants to preserve

- The `try` is placed immediately after the three S1 tail statements (bootstrap-flag check, `Get-HookDependencyFailureDecision`, dependency-decision exit). The S1 structural test (`tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1:35-57`) requires those three statements at `index+1..index+3` after the dot-source early return; the `try` occupies `index+4`.
- No whole-script `try`, no script-level `trap`, and no `trap` in the helper. A whole-script `try` breaks the S1 bootstrap check (`HookGuardShape.Helpers.ps1:21-33`); a script-level `trap` is hoisted and would replace the B3 bootstrap reason (`hook-dependency-failure.Claude.Tests.ps1:183-190`) and fire during test dot-sourcing; a `trap` in the dot-sourced helper is removed when the helper exits (about_Trap).
- `exit` statements stay outside the `try` body, matching the precedent.
- `.claude/hooks/subagentstop-envelope.ps1` is not changed functionally. Its only change is the line-12 citation. The helper contract in the 897 spec (`## Authoritative Helper Contract`) is unchanged; using `Exit-SubagentStopBlock` in a new `catch` is additive to consumer-policy item 5.
- `validate-feature-review-coverage.ps1` and its bundle mirror are unchanged.
- Each changed `.claude` file stays byte-identical to its bundle mirror.
- The crash block always applies, regardless of `stop_hook_active`, because the `catch` has no parsed envelope. This matches the existing dependency-failure tail behavior (E-EXE-5, `validate-executor-output.Envelope.Tests.ps1:129-142`).

### Dependencies or blocked work

- None blocking. `docs/features/archive/` does not exist yet; the 897 folder remains at `docs/features/active/subagentstop-envelope-core-897/`. The updated citations name the archive path and the active path as the interim location, so either location is accepted.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

See `## Files In Scope`.

#### Functions/classes/CLI commands impacted

- Top-level script tails of the non-compliant validators listed in the design table. No function signature changes.
- `.NOTES` docstring of each changed validator: one sentence stating that an unhandled error during validation blocks with exit 2 and a reason.

#### Data flow and validation changes

- None for successful validation paths. Only the error path of the validation call changes: exit 1 (or a fall-through to `exit 0` under Continue) becomes exit 2 with a stderr reason.

#### Error handling and logging updates

- Reason text: `<dependency prefix> validator error: <first exception message line>; the gate fails closed.` followed by a newline and the report-and-halt line. Written to stderr by `Exit-SubagentStopBlock`.

#### Rollback/feature-flag considerations (if applicable)

- No flag. Rollback is a revert of the tail `try`/`catch` in each validator and its mirror.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Input: unchanged SubagentStop stdin envelope.
- Output on unhandled error: exit code 2; stderr begins with the validator's dependency prefix and contains the first line of the exception message.

#### Required configuration keys and defaults

- None. No registration in `.claude/settings.json`, agent frontmatter, or `core.json` changes.

#### Backward-compatibility expectations

- Exit 0 and existing exit-2 block decisions are unchanged. Only a previously unhandled error path changes behavior.

#### Performance constraints (latency/throughput/memory)

- No measurable change expected; one `try` block per invocation.

### Non-change: Codex

No `.codex/` or Codex-bundle change is made. Evidence (research Q5): `.codex/config.toml:236-252` registers two SubagentStop hooks, `.codex/hooks/validate-codex-subagent-routing.ps1` and `.codex/hooks/validate-feature-review-coverage.ps1`. Neither dot-sources the helper, and both already wrap their bodies in a top-level `try`/`catch` that writes stderr and exits 2 (`.codex/hooks/validate-feature-review-coverage.ps1:244-316`; `.codex/hooks/validate-codex-subagent-routing.ps1:140-159`). The 897 spec excludes `.codex/` (`spec.md:111`).

## Documentation Corrections

Mirror existence was verified by file search in this worktree on 2026-10-15.

| Source location | Current statement | Correction | Mirror (verified) |
| --- | --- | --- | --- |
| `docs/engineering/claude-code-architecture.md:239` | the SubagentStop hook "exits with code 1 and blocks the subagent from stopping" and describes the removed inline matcher command | state that the per-agent SubagentStop validators block with exit 2 and a stderr reason (including on an unhandled error), and that exit 1 does not block | none (not mirrored) |
| `.claude/skills/epic-orchestrate/SKILL.md:279-281` | runtime effect "is likely to depend on the `SubagentStop` transport and exit-code defect" in the potential record | state that the transport and exit-code defect was resolved by epic #904 and issue #928, and that a violation blocks with exit 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` (same text at line 281) |
| `.agents/skills/translate-claude-to-codex/SKILL.md:285` | mapping-table row `.claude/hooks/*.ps1` (SubagentStop, exit 1) | change to exit 2 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md` (same text at line 285) |
| `.claude/agents/epic-orchestrator.md:133-135` | same stale "transport and exit-code defect" sentence as the epic-orchestrate skill | same correction as the epic-orchestrate skill | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md` (same text at line 135) |
| `.claude/hooks/enforce-epic-wave-barrier.ps1:34-35` (comment only) | "runtime effect is likely to depend on the SubagentStop transport defect" | same correction, comment text only; no code change | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1` (same text at line 35) |

Notes:
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md` exists but does not contain the stale sentence (search for the potential-record path returned no match there); it is not changed.
- The last two rows were found by a worktree search (excluding `docs/`) for the potential-record path `2026-08-21-subagentstop-validators-read-undocumented-envelope.md`. They carry the same stale statement as the epic-orchestrate skill and are included under the related-follow-up policy.

## Assumptions, Constraints, Dependencies

- Assumptions: Pester mocks take precedence over functions the hook redefines when invoked through the in-process `&` route (established by existing rows, research Q4).
- Constraints: no temporary files, no `TestDrive`, no `Start-Process` subprocess, no environment-variable seam (helper contract: "reads no environment variable", 897 `spec.md:20`). File size limit 500 lines; `validate-planner-output.ps1` is at 440 lines and its change is limited to the tail and one `.NOTES` sentence. Agent worktrees may deny `pwsh` in shell text; PowerShell QC runs through the `mcp__drm-copilot__run_poshqc_*` tools.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: SubagentStop validators block (exit 2) on an unhandled error instead of exiting 1.
- Data or migration considerations: none.
- Logging/telemetry updates: new stderr reason text on the unhandled-error path.
- Compatibility notes: no registration, schema, or `core.json` change.

## Test Strategy

Seeded from issue:

- [ ] Add a top-level trap/try in each validator (or in the shared helper's entry contract) that converts any unhandled error to `Exit-SubagentStopBlock` with a reason. (Resolved as a per-validator tail `try`/`catch`; trap and helper-wrapper variants rejected, see Boundaries.)
- [ ] Add one test per validator that forces an unhandled error and asserts exit 2.
- [ ] Mirror to the bundled copies.

- Regression tests to add: `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`.
  - `BeforeAll` dot-sources `.claude/hooks/subagentstop-envelope.ps1` so `Read-SubagentStopEnvelope` exists for mocking.
  - One `-ForEach` row per validator in the family (columns Hook, Parameters, Prefix). Each row mocks `Read-SubagentStopEnvelope { throw 'simulated unhandled error (issue #928)' }` and `Import-Module { }`, swaps stdin with `[Console]::SetIn` and stderr with `[Console]::SetError`, invokes the hook with `&`, and restores all state in `finally`.
  - `validate-required-artifact-output.ps1` row passes `-AgentName` and `-RequiredArtifact` so that the argument check is skipped.
  - Per-row assertions: no exception propagated to the test; `$LASTEXITCODE` equals 2; stderr starts with the row's prefix (ordinal) and contains `simulated unhandled error (issue #928)`; `Should -Invoke Read-SubagentStopEnvelope -Times 1 -Exactly`.
  - Completeness row (modelled on B4, `hook-dependency-failure.Claude.Tests.ps1:192-195`): the table's Hook keys equal the set of `.claude/hooks/*.ps1` files whose AST contains the guarded `subagentstop-envelope.ps1` dot-source.
- Unit tests: Pester only (no pytest unit tests for this change). Existing pytest bundle-parity tests are rerun.
- Edge cases: the `validate-feature-review-coverage.ps1` row is a characterization row and passes before the fix. Statement-terminating errors under `$ErrorActionPreference = Continue` (discovery gate, pr-author) are exercised by the U1-ST rows, whose mock raises a .NET method exception.
- Error handling verification: stderr reason text asserted per row.
- Coverage: line coverage >= 85% for changed PowerShell under `.claude/hooks` (in the `config/poshqc-coverage.json` population). No branch-coverage gate applies to Pester. New `catch` lines are executed by the new rows.
- Toolchain commands: PoshQC MCP tools in order format, analyze, test (`mcp__drm-copilot__run_poshqc_*`); `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Type checking does not apply to PowerShell.
- Fail-before evidence: run the new test file against the unfixed validators and record that the non-compliant validator rows fail (exception propagated, `$LASTEXITCODE` 0) and the feature-review row passes, under `<FEATURE>/evidence/regression-testing/`.
- Manual validation: none required.

## Acceptance Criteria

- [x] AC1: Each of `validate-discovery-artifact-gate.ps1`, `validate-executor-output.ps1`, `validate-orchestrator-output.ps1`, `validate-planner-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, and `validate-task-researcher-output.ps1` under `.claude/hooks/` wraps its validation call in a `try`/`catch` placed immediately after the three S1 tail statements, whose `catch` calls `Exit-SubagentStopBlock` with a message that begins with that validator's S1 dependency prefix and contains the first line of the exception message; `if (-not $result.Ok)` (or the pr-author decision check) and `exit 0` remain after the `try`/`catch`.
- [x] AC2: Each validator changed under AC1 has one added `.NOTES` sentence stating that an unhandled error during validation blocks with exit 2 and a reason.
- [x] AC3: `.claude/hooks/validate-feature-review-coverage.ps1` and its bundle mirror are unchanged (verified by `git diff --quiet` on both paths against the merge base), and it is covered by a characterization row in the new test file.
- [x] AC4: `.claude/hooks/subagentstop-envelope.ps1` has no functional change; its only diff is the line-12 citation.
- [x] AC5: `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` exists and contains one data-driven row for each of the 9 SubagentStop validators listed in Root Cause Analysis; each row mocks `Read-SubagentStopEnvelope` to throw, uses the in-process `&` route with no temporary files, no `TestDrive`, no subprocess, and no environment variable, and asserts no propagated exception, exit code 2, the stderr prefix, the injected error text, and exactly one call to the mock.
- [x] AC6: The new test file contains a completeness test asserting that the table's hook set equals the set of `.claude/hooks/*.ps1` files whose AST contains the guarded `subagentstop-envelope.ps1` dot-source.
- [x] AC7: Fail-before evidence under `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/regression-testing/` records that, against the unfixed validators, every row for a validator named in AC1 fails and the `validate-feature-review-coverage.ps1` row passes as a characterization row; fail-after evidence records all rows passing.
- [x] AC8: Every changed file under `.claude/` is byte-identical to its counterpart under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and `.agents/skills/translate-claude-to-codex/SKILL.md` is byte-identical to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
- [x] AC9: The citations of `docs/features/active/subagentstop-envelope-core-897/spec.md` in `.claude/hooks/subagentstop-envelope.ps1` (line 12), `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1` (line 12), and `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` (line 9) cite `docs/features/archive/subagentstop-envelope-core-897/spec.md` and name `docs/features/active/subagentstop-envelope-core-897/` as the interim location, so either location is accepted.
- [x] AC10: `docs/engineering/claude-code-architecture.md` (line 239 region) no longer states that a SubagentStop exit 1 blocks; it states that SubagentStop validators block with exit 2 and a stderr reason, including on an unhandled error.
- [x] AC11: The stale SubagentStop "transport and exit-code defect" statements in `.claude/skills/epic-orchestrate/SKILL.md` (lines 279-281), `.claude/agents/epic-orchestrator.md` (lines 133-135), and `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment lines 34-35), and the "SubagentStop, exit 1" row in `.agents/skills/translate-claude-to-codex/SKILL.md` (line 285), are corrected to describe exit-2 blocking, together with their bundle mirrors listed in Documentation Corrections; `enforce-epic-wave-barrier.ps1` has no non-comment change.
- [x] AC12: No file under `.codex/` or `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/` is changed, and no registration in `.claude/settings.json`, `.claude/agents/*.md` frontmatter, or `core.json` is changed.
- [x] AC13: Existing suites still pass, including `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (S1 structural shape), `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (B1-B4), and `tests/scripts/claude-runtime/claude-settings.Tests.ps1`.
- [x] AC14: PoshQC format, analyze, and test (via the `mcp__drm-copilot__run_poshqc_*` tools) pass with zero analyzer errors, and line coverage for changed PowerShell under `.claude/hooks` is >= 85%.
- [x] AC15: CI on the PR head reports success for `poshqc / PowerShell QC` (windows coverage job) and `poshqc / PowerShell hook suites (Linux)` (Pester over `tests/scripts/claude-hooks`), and for the pytest job running the bundle-parity tests. (CI-dependent; checked off at S9.)
- [x] AC16: Every changed or added production, test, or script file is at most 500 lines.

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
.claude/hooks/enforce-epic-wave-barrier.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
.claude/skills/epic-orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md
.claude/agents/epic-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md
.agents/skills/translate-claude-to-codex/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md
docs/engineering/claude-code-architecture.md
tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1
tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1
tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1
tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1

Referenced without change (verification only):

.claude/hooks/validate-feature-review-coverage.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1
.codex/hooks/validate-feature-review-coverage.ps1
.codex/hooks/validate-codex-subagent-routing.ps1
tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1
tests/scripts/claude-runtime/claude-settings.Tests.ps1
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py

## Out of Scope

- Any functional change to `.claude/hooks/subagentstop-envelope.ps1` or the 897 helper contract, including a helper-provided wrapper entry point (rejected, research Q3 option b).
- Any change to `.claude/hooks/validate-feature-review-coverage.ps1` (already compliant).
- `.codex/` hooks, `.codex/config.toml`, and the Codex bundle (already exit 2 in a top-level `try`/`catch`; see Non-change: Codex).
- Errors that no in-script handler can catch: script parse errors and parameter-binding failures of the script's own `param()` under `pwsh -File` (residual risk; mitigated by PSScriptAnalyzer and Pester dot-source parse checks).
- Errors raised before the helper loads (already converted to exit 2 by the #786 guard pattern).
- Re-entry suppression on the crash path: the crash block always applies regardless of `stop_hook_active`.
- Moving `docs/features/active/subagentstop-envelope-core-897/` to `docs/features/archive/`; only the citations change.
- Citations of the 897 spec inside `docs/` other than those listed in AC9.
- Any change to `docs/engineering/claude-code-architecture.md` other than the line-239 paragraph (AC10) and the line-237 PreToolUse sentence (corrected in remediation cycle 1, CR-N3).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md` (does not contain the stale statement).
- Any change to hook registrations, agent frontmatter hook blocks, or `core.json`.
- Live Claude Code differential runs; the in-process exit-code harness is the verification route.

## Risks & Mitigations

- Risk: a deterministic validator crash re-blocks on every stop. Mitigation: the reason ends with the report-and-halt line directing the subagent to report to the operator; this matches the existing dependency-failure tail exposure.
- Risk: placing the `try` before or around the S1 tail breaks the S1 structural test. Mitigation: AC1 placement rule and AC13 rerun of `hook-dependency-guard-completeness.Tests.ps1`.
- Risk: mirror drift. Mitigation: byte copies and AC8 parity test.
- Risk: the Continue-preference conversion for the discovery gate and pr-author could differ from documented semantics. Mitigation: the U1-ST rows exercise those validators with a statement-terminating .NET method exception and assert exit 2 (observed in remediation cycle 1).
- Rollback: revert the tail `try`/`catch` edits and their mirrors.

## Rollout & Follow-up

- Release/rollout steps: merge to main; bundled copies ship with the next extension build.
- Post-fix monitoring or clean-up tasks: archive move of the 897 folder (separate item).
- Links: issue #928; epic #904; #786 (PR #881); E3 code-review NB-6.
