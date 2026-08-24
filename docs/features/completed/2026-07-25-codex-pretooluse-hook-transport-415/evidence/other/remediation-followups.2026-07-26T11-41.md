# Deferred Follow-Ups (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P5-T2]

Timestamp: 2026-07-26T11-41

## Follow-up 1 (Minor, code-review finding) — shared parser no longer asserts `hook_event_name`

**Entry.** `ConvertFrom-CodexPreToolUsePayload` in `.codex/hooks/codex-pretooluse-file-mapping.ps1` no longer asserts that the incoming payload's `hook_event_name` equals `'PreToolUse'`. Before the transport extraction, individual handlers performed their own payload validation; the shared parser now throws for exactly four conditions — empty or whitespace-only input, invalid JSON, missing or null `tool_input`, and (only under `-RequireSessionId`) a missing or empty `session_id` — and deliberately performs no tool-name and no event-name assertion.

**Deferral rationale.** Hardening this is NOT trivially adjacent to the R1/R2 remediation scope. Adding the assertion would change the shared module, require the identical change to its bundle mirror at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-pretooluse-file-mapping.ps1` in the same batch to preserve root/bundle byte-identity, and alter transport semantics for all eight handlers registered under the `^(apply_patch|Edit|Write)$` matcher simultaneously. A payload whose `hook_event_name` is absent or different currently parses successfully and is routed by tool name; introducing a throw converts that case from allow-or-route into exit 2 for every handler at once. That is a behavioural change to the transport contract, not a measurement-configuration change, and it exceeds the "trivially adjacent" bar that governs what a remediation cycle may absorb.

**Constraints binding any future fix.**
1. It must not change any handler's deny/allow policy semantics. The handlers' policy functions are out of scope; only the transport-level validation may change.
2. It must mirror root → bundle in the same batch, because `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` asserts exact root/bundle byte-identity for the shared module.
3. It must be accompanied by tests that pin the new fail-closed behaviour for all eight handlers, and by an explicit decision on whether an absent `hook_event_name` (as opposed to a wrong one) is rejected — the current Codex transport supplies it, but the field is not structurally guaranteed.
4. It must not weaken the four existing throw conditions or their hook-named message prefixes.

**Coverage note.** The shared module is now measured at 100.00% line coverage (`evidence/qa-gates/per-file-coverage-final.2026-07-26T11-41.md`), so a future change to this function will produce immediate, visible changed-line coverage evidence.

## Follow-up 2 (defect observed during Phase 3 coverage work) — unreachable branch in `enforce-checkpoint-monotonic.ps1`

**Entry.** Line 260 of `.codex/hooks/enforce-checkpoint-monotonic.ps1` reads:

```powershell
if (-not $payload.PSObject.Properties.Name -contains 'completed_steps') {
```

PowerShell binds `-not` more tightly than `-contains`, so this evaluates as `(-not $payload.PSObject.Properties.Name) -contains 'completed_steps'` — a containment test of a string against a Boolean scalar, which is `$false` for every possible payload. The intended expression is `if (-not ($payload.PSObject.Properties.Name -contains 'completed_steps'))`. The branch body at line 261 is therefore dead code and is the single uncovered line in that file (103 / 104 = 99.04%).

**Impact assessment.** Benign at present. A payload carrying no `completed_steps` falls through to `$steps = @()`, which yields no out-of-order pair and no missing prerequisite, and reaches the same `allow` decision the dead branch would have returned. No allow/deny outcome is currently wrong.

**Deferral rationale.** Plan Hard Constraint 3 forbids editing any `.codex/hooks/*.ps1` production file in this remediation, and Hard Constraint 4 forbids changing any handler's policy function. Correcting the precedence is a policy-function edit, so it is out of scope here.

**Constraints binding any future fix.** Correcting the parenthesization must be mirrored root → bundle in the same batch, must be covered by a case asserting the allow outcome for a checkpoint payload with no `completed_steps` property, and must be re-measured to confirm line 261 becomes covered.

## Follow-up 3 (tooling) — the bundled MCP PoshQC lags the repository `CodeCoverage.Path`

**Entry.** `mcp__drm-copilot__run_poshqc_test` executes the PoshQC module packaged with `@danmoisan/drm-copilot-mcp` (npx cache, currently v1.0.19), whose `resources/powershell/PoshQC/settings/pester.runsettings.psd1` is byte-identical to the repository's pre-remediation bundle copy. Consequently the [P1-T1] `CodeCoverage.Path` additions do not take effect through the MCP tool until the package is republished. Full demonstration, including the commands used to establish it, is recorded in `evidence/other/remediation-phase1-poshqc-loop.2026-07-26T11-41.md`.

**Impact assessment.** No impact on correctness of the fix. The authoritative CI measurement path (`.github/workflows/_poshqc.yml:41-42`) imports the WORKSPACE module, so CI on this branch will measure the expanded set immediately. Local MCP-driven coverage numbers will lag by one release.

**Suggested resolution.** The next extension/MCP release picks up the updated bundled runsettings automatically, since `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` was updated in the same batch as the root copy and the two are byte-identical. No separate action is required beyond the normal release.
