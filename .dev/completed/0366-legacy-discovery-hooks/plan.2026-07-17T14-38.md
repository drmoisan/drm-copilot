# 2026-07-17-legacy-discovery-hooks — Plan

- **Issue:** #366
- **Parent (epic):** legacy-discovery-and-parity (manifest placeholder #9004)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-38
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Required References

- Repository tone/communication policy: `.github/copilot-instructions.md`
- General Coding Standards: `.github/instructions/general-code-change.instructions.md`
- General Unit Test Policy: `.github/instructions/general-unit-test.instructions.md`
- PowerShell Code Standards: `.github/instructions/powershell-code-change.instructions.md`
- PowerShell Unit Test Policy: `.github/instructions/powershell-unit-test.instructions.md`
- Repo-local mirrors (auto-loaded, path-scoped): `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`
- Design source: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/spec.md`, `.../user-story.md`, `.../issue.md`, `.../research/research-input.md`
- Epic shared design: `docs/features/epics/legacy-discovery-and-parity/epic.md` ("Hook conventions", "Quality gates")

**All work must comply with these policies; do not duplicate their content here.**

## Scope Guardrails (do not violate)

- Exactly two production PowerShell files: `.claude/hooks/enforce-discovery-artifact-gate.ps1` (PreToolUse) and `.claude/hooks/validate-discovery-artifact-gate.ps1` (SubagentStop). Each carries its own copy of the ~10-line `Invoke-DiscoveryValidatorExe` wrapper. Do NOT create a third shared production file.
- Exactly two mirrored Pester test files: `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`, `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`.
- One edit to `.claude/settings.json`: register `enforce-discovery-artifact-gate.ps1` under the existing `PreToolUse` → `"Write|Edit"` matcher group, and `validate-discovery-artifact-gate.ps1` under the existing broad generic-agent `SubagentStop` matcher group (the one matching `atomic-planner|atomic-executor|feature-review|...`). Do NOT create a new agent-specific `SubagentStop` matcher.
- Do NOT implement or design the discovery validators (owned by feature #361 / #9003). Both hooks call `Invoke-DiscoveryValidatorExe` → `python -m scripts.dev_tools.validate_discovery_artifacts <artifact-type> <path>` and interpret only exit code and captured text.
- Do NOT mirror the new `.claude/hooks/*.ps1` assets into `resources/` (feature #9012, out of scope).
- Do NOT build a capability-detection/portable-fallback path that reimplements validator logic in PowerShell.
- Hook source, comments, and emitted messages (`permissionDecisionReason`, `Write-Error` text) must contain no `TaskMaster`, `TMW`, `Outlook`, `VSTO`, or task-management-specific identifier.
- `Get-DiscoveryArtifactType` carries an explicit `# TODO(#9002)` comment (artifact-type path lookup depends on the not-yet-finalized schema-versioning convention).
- The required-artifact-declaration reader carries an explicit `# TODO(#9001)` comment and fails open (allow, validator never invoked) when the domain profile or required-artifact declaration is absent.
- Pester tests mock `Invoke-DiscoveryValidatorExe` only; production tests must never mock `python`.

## Evidence Location (canonical, non-overridable)

All evidence artifacts produced while executing this plan MUST be written under:
`docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/<kind>/`

using sub-kinds `baseline/`, `qa-gates/`, `other/` as directed per task below. No artifact in this plan may be written to any `artifacts/` sub-path other than `artifacts/orchestration/` (not used by this plan). Timestamps use ISO-8601 `yyyy-MM-ddTHH-mm` format.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `.github/copilot-instructions.md` and record its tone/communication constraints applicable to this feature
  - Acceptance: file read in full; no policy document under `.claude/rules/` or `.github/instructions/` is modified as a side effect.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md`
  - Acceptance: file read in full prior to any Phase 1+ code edit.
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md`
  - Acceptance: file read in full prior to any Phase 1+ test edit.
- [x] [P0-T4] Read `.github/instructions/powershell-code-change.instructions.md`
  - Acceptance: file read in full prior to any Phase 1+ code edit.
- [x] [P0-T5] Read `.github/instructions/powershell-unit-test.instructions.md`
  - Acceptance: file read in full prior to any Phase 1+ test edit.
- [x] [P0-T6] Write the Phase 0 policy-read evidence artifact to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/phase0-instructions-read.md`
  - Acceptance: artifact contains `Timestamp:`, a `Policy Order:` list reproducing P0-T1..P0-T5 in order, and an explicit list of the five files read.
- [x] [P0-T7] Capture a PowerShell formatting baseline by running `mcp__drm-copilot__run_poshqc_format` scoped to `.claude/hooks/` and `tests/scripts/claude-hooks/`, and write the result to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/poshqc-format-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:` (the exact MCP invocation and scope), `EXIT_CODE:`, and `Output Summary:` (pass/fail and file-changed count for the pre-existing scope).
- [x] [P0-T8] Capture a PowerShell lint baseline by running `mcp__drm-copilot__run_poshqc_analyze` scoped to `.claude/hooks/` and `tests/scripts/claude-hooks/`, and write the result to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/poshqc-analyze-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (rule-violation count, currently 0 for pre-existing scope).
- [x] [P0-T9] Capture a Pester test baseline with coverage by running `mcp__drm-copilot__run_poshqc_test` against the repo's existing Pester suite using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and write the result to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/pester-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric pre-change line-coverage percent and branch-coverage percent headline values (not placeholders).

### Phase 1 — `enforce-discovery-artifact-gate.ps1` (PreToolUse)

- [x] [P1-T1] Create `.claude/hooks/enforce-discovery-artifact-gate.ps1` with a `.SYNOPSIS`/`.DESCRIPTION` comment header, `[CmdletBinding()] param()`, and no domain-specific identifiers
  - Acceptance: file exists at that path; comment header describes a domain-neutral PreToolUse discovery-artifact completion gate; `git diff` shows no other file changed by this task.
- [x] [P1-T2] Implement `Invoke-DiscoveryValidatorExe -ValidatorArgs <string[]>` in `.claude/hooks/enforce-discovery-artifact-gate.ps1`, calling `python -m scripts.dev_tools.validate_discovery_artifacts @ValidatorArgs 2>&1` and returning `@{ ExitCode = $LASTEXITCODE; Output = ($output | Out-String).Trim() }`
  - Acceptance: function signature matches exactly; parameter name is `ValidatorArgs` (not `Args`); function body contains no `TaskMaster`/`TMW`/`Outlook`/`VSTO` token.
- [x] [P1-T3] Implement `Get-DiscoveryArtifactType -Path <string>` in `.claude/hooks/enforce-discovery-artifact-gate.ps1`, mapping a normalized file path to one of the eight tokens `profile | feature-contract | coverage-ledger | runtime-scenario | parity-matrix | unspecified-behavior | product-decision | evidence-reference`, or `$null` when unrecognized
  - Acceptance: function body carries an explicit `# TODO(#9002)` comment documenting the open schema-versioning-convention seam; returns `$null` for at least one non-matching sample path exercised later in P1-T10.
- [x] [P1-T4] Implement a `RequiredArtifactPathsReader`-shaped seam function (e.g. `Get-RequiredDiscoveryArtifactDeclaration`) in `.claude/hooks/enforce-discovery-artifact-gate.ps1` that returns the domain-profile required-artifact declaration when present, or an explicit "absent" sentinel when no domain profile exists
  - Acceptance: function body carries an explicit `# TODO(#9001)` comment documenting the open domain-profile seam; default behavior on absence is documented inline as fail-open (allow).
- [x] [P1-T5] Implement `Invoke-DiscoveryArtifactGateDecision` in `.claude/hooks/enforce-discovery-artifact-gate.ps1`: parses `$env:CLAUDE_TOOL_INPUT`-shaped JSON (`file_path`, and `content` for `Write` or `old_string`/`new_string` for `Edit`), resolves artifact type via `Get-DiscoveryArtifactType`, checks the required-artifact seam, allows `Edit` calls unconditionally, and for a recognized `Write` target invokes `Invoke-DiscoveryValidatorExe` and maps a non-zero exit or non-empty error output to `permissionDecision = 'deny'` with `permissionDecisionReason` prefixed `DISCOVERY_ARTIFACT_GATE_BLOCKED:` followed by the trimmed validator output
  - Acceptance: function returns an `[ordered]` hashtable shaped `{ hookSpecificOutput: { hookEventName: 'PreToolUse'; permissionDecision; permissionDecisionReason? } }`; throws on malformed JSON input rather than swallowing the error.
- [x] [P1-T6] Add the thin entrypoint block to `.claude/hooks/enforce-discovery-artifact-gate.ps1`: dot-source guard `if ($MyInvocation.InvocationName -eq '.') { return }` followed by a call to the decision function, `ConvertTo-Json -Compress -Depth 5` to stdout on success and `exit 0`, and `Write-Error $_; exit 1` on a caught malformed-input exception
  - Acceptance: dot-sourcing the file in a PowerShell session (`. .claude/hooks/enforce-discovery-artifact-gate.ps1`) does not invoke `exit` or write to stdout.
- [x] [P1-T7] Register `enforce-discovery-artifact-gate.ps1` in `.claude/settings.json` by adding `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/enforce-discovery-artifact-gate.ps1"}` to the `hooks` array of the existing `PreToolUse` → `"Write|Edit"` matcher group
  - Acceptance: `.claude/settings.json` remains valid JSON; the new entry is present in that matcher group's array alongside `enforce-evidence-locations.ps1`; no other matcher group is modified.
- [x] [P1-T8] Create `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` with `Describe`/`Context`/`It` scaffolding that dot-sources `.claude/hooks/enforce-discovery-artifact-gate.ps1`
  - Acceptance: file exists at that path; running Pester against it (with no `It` blocks yet, or a placeholder skipped block) produces `EXIT_CODE: 0` with zero failures.
- [x] [P1-T9] Add Pester test: allow decision when the recognized discovery artifact is present and conforming (`Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }`)
  - Acceptance: `It` block asserts `permissionDecision -eq 'allow'` and asserts `Invoke-DiscoveryValidatorExe` was called exactly once.
- [x] [P1-T10] Add Pester test: deny decision when the recognized discovery artifact is non-conforming (`Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }`)
  - Acceptance: `It` block asserts `permissionDecision -eq 'deny'` and asserts `permissionDecisionReason` starts with `DISCOVERY_ARTIFACT_GATE_BLOCKED:` and contains the mocked validator text verbatim.
- [x] [P1-T11] Add Pester test: allow without invoking the validator when `file_path` does not resolve to a recognized discovery-artifact type
  - Acceptance: `It` block asserts `permissionDecision -eq 'allow'` and asserts `Invoke-DiscoveryValidatorExe` was never called (`Should -Invoke ... -Times 0`).
- [x] [P1-T12] Add Pester test: fail-open allow when the required-artifact-declaration seam reports the domain profile absent
  - Acceptance: `It` block stubs the seam to report "absent", asserts `permissionDecision -eq 'allow'`, and asserts `Invoke-DiscoveryValidatorExe` was never called.
- [x] [P1-T13] Add Pester test: malformed `CLAUDE_TOOL_INPUT` JSON produces `Write-Error` and a non-zero returned exit code from the entrypoint function
  - Acceptance: `It` block supplies an invalid JSON string and asserts the entrypoint path surfaces an error and does not produce a JSON decision payload.
- [x] [P1-T14] Add Pester test: empty/absent `CLAUDE_TOOL_INPUT` produces a default-allow decision without invoking the validator
  - Acceptance: `It` block supplies `$null` or empty string and asserts `permissionDecision -eq 'allow'` with zero validator invocations.
- [x] [P1-T15] Add Pester test: a validator-not-found-style non-zero exit (mocked `Output` containing `ModuleNotFoundError`) is treated identically to any other non-conforming result
  - Acceptance: `It` block asserts `permissionDecision -eq 'deny'` for this mocked case, confirming the failure is not silently allowed.
- [x] [P1-T16] Add Pester test: an `Edit` tool call (payload containing only `old_string`/`new_string`, no `content`) is allowed unconditionally without invoking the validator
  - Acceptance: `It` block asserts `permissionDecision -eq 'allow'` and asserts `Invoke-DiscoveryValidatorExe` was never called for the `Edit` case.
- [x] [P1-T17] Add Pester test: domain-neutrality grep gate reading `.claude/hooks/enforce-discovery-artifact-gate.ps1`'s own source text and asserting it does not match `TaskMaster|TMW|Outlook|VSTO`
  - Acceptance: `It` block reads the file via `Get-Content -Raw` and asserts `-notmatch` against the forbidden-token pattern; test fails if any token is present.
- [x] [P1-T18] Run the Pester test file `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` via `mcp__drm-copilot__run_poshqc_test` and confirm all `It` blocks pass
  - Acceptance: command exits 0 with zero failed tests reported.

### Phase 2 — `validate-discovery-artifact-gate.ps1` (SubagentStop)

- [x] [P2-T1] Create `.claude/hooks/validate-discovery-artifact-gate.ps1` with a `.SYNOPSIS`/`.DESCRIPTION` comment header, `[CmdletBinding()] param()`, and no domain-specific identifiers
  - Acceptance: file exists at that path; comment header describes a domain-neutral SubagentStop discovery-artifact completion gate; `git diff` shows no other file changed by this task.
- [x] [P2-T2] Implement `Invoke-DiscoveryValidatorExe -ValidatorArgs <string[]>` in `.claude/hooks/validate-discovery-artifact-gate.ps1` (identical shape to P1-T2's copy), calling `python -m scripts.dev_tools.validate_discovery_artifacts @ValidatorArgs 2>&1` and returning `@{ ExitCode = $LASTEXITCODE; Output = ($output | Out-String).Trim() }`
  - Acceptance: function signature matches exactly; parameter name is `ValidatorArgs`; body contains no domain-specific token.
- [x] [P2-T3] Implement `Get-DiscoveryArtifactType -Path <string>` in `.claude/hooks/validate-discovery-artifact-gate.ps1` (identical mapping shape to P1-T3's copy)
  - Acceptance: function body carries an explicit `# TODO(#9002)` comment; returns `$null` for at least one non-matching sample path exercised later in P2-T10.
- [x] [P2-T4] Implement the `RequiredArtifactPathsReader`-shaped seam function in `.claude/hooks/validate-discovery-artifact-gate.ps1` (identical seam shape to P1-T4's copy)
  - Acceptance: function body carries an explicit `# TODO(#9001)` comment; default behavior on absence is documented inline as fail-open (allow/exit 0).
- [x] [P2-T5] Implement `Invoke-DiscoveryArtifactGateValidation` in `.claude/hooks/validate-discovery-artifact-gate.ps1`: parses `$env:CLAUDE_HOOK_INPUT`-shaped JSON (`.output`, the terminating subagent's final text), scans the output text for discovery-artifact path references via `Get-DiscoveryArtifactType`, checks the required-artifact seam, and for each recognized reference invokes `Invoke-DiscoveryValidatorExe`, mapping any non-zero exit or non-empty error output to `Ok = $false` with `Message` prefixed `DISCOVERY_ARTIFACT_GATE_BLOCKED:` followed by the trimmed validator output
  - Acceptance: function returns a `{ Ok; Message }` hashtable; `Ok = $true` and `Message = $null` when no reference fails validation or none is recognized; returns `Ok = $false` with an explicit "CLAUDE_HOOK_INPUT is empty" message when the raw payload is empty/whitespace.
- [x] [P2-T6] Add the thin entrypoint block to `.claude/hooks/validate-discovery-artifact-gate.ps1`: dot-source guard `if ($MyInvocation.InvocationName -eq '.') { return }` followed by a call to the validation function, `Write-Error $result.Message; exit 1` when `Ok -eq $false`, `exit 0` otherwise
  - Acceptance: dot-sourcing the file in a PowerShell session does not invoke `exit` or `Write-Error`.
- [x] [P2-T7] Register `validate-discovery-artifact-gate.ps1` in `.claude/settings.json` by adding `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1"}` to the `hooks` array of the existing broad generic-agent `SubagentStop` matcher group (the group whose `matcher` string is `atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|epic-review|status-updater|python-typed-engineer|powershell-typed-engineer|csharp-typed-engineer|typescript-engineer|orchestrator|epic-orchestrator|epic-planner`)
  - Acceptance: `.claude/settings.json` remains valid JSON; that matcher group's `hooks` array now contains two entries (the existing inline completion-artifact-path check plus the new file-backed hook); the `matcher` string itself is unmodified; no new `SubagentStop` matcher group is added.
- [x] [P2-T8] Create `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` with `Describe`/`Context`/`It` scaffolding that dot-sources `.claude/hooks/validate-discovery-artifact-gate.ps1`
  - Acceptance: file exists at that path; running Pester against it (with no `It` blocks yet, or a placeholder skipped block) produces `EXIT_CODE: 0` with zero failures.
- [x] [P2-T9] Add Pester test: `Ok = $true` when the referenced discovery artifact is present and conforming (`Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }`)
  - Acceptance: `It` block asserts `Ok -eq $true` and `Message -eq $null`, and asserts `Invoke-DiscoveryValidatorExe` was called exactly once.
- [x] [P2-T10] Add Pester test: `Ok = $false` when the referenced discovery artifact is non-conforming (`Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }`)
  - Acceptance: `It` block asserts `Ok -eq $false` and `Message` starts with `DISCOVERY_ARTIFACT_GATE_BLOCKED:` and contains the mocked validator text verbatim.
- [x] [P2-T11] Add Pester test: `Ok = $true` without invoking the validator when the subagent output references no recognized discovery-artifact path
  - Acceptance: `It` block asserts `Ok -eq $true` and asserts `Invoke-DiscoveryValidatorExe` was never called.
- [x] [P2-T12] Add Pester test: fail-open `Ok = $true` when the required-artifact-declaration seam reports the domain profile absent
  - Acceptance: `It` block stubs the seam to report "absent", asserts `Ok -eq $true`, and asserts `Invoke-DiscoveryValidatorExe` was never called.
- [x] [P2-T13] Add Pester test: empty/absent `CLAUDE_HOOK_INPUT` produces `Ok = $false` with the explicit message text `CLAUDE_HOOK_INPUT is empty` (or an equivalent documented malformed-input message)
  - Acceptance: `It` block supplies `$null` or empty string and asserts `Ok -eq $false` and the message contains the documented empty-input text.
- [x] [P2-T14] Add Pester test: malformed `CLAUDE_HOOK_INPUT` JSON produces `Ok = $false` with a message describing the JSON parse failure
  - Acceptance: `It` block supplies an invalid JSON string and asserts `Ok -eq $false` with a non-empty `Message`.
- [x] [P2-T15] Add Pester test: a validator-not-found-style non-zero exit (mocked `Output` containing `ModuleNotFoundError`) is treated identically to any other non-conforming result
  - Acceptance: `It` block asserts `Ok -eq $false` for this mocked case, confirming the failure is not silently allowed.
- [x] [P2-T16] Add Pester test: domain-neutrality grep gate reading `.claude/hooks/validate-discovery-artifact-gate.ps1`'s own source text and asserting it does not match `TaskMaster|TMW|Outlook|VSTO`
  - Acceptance: `It` block reads the file via `Get-Content -Raw` and asserts `-notmatch` against the forbidden-token pattern.
- [x] [P2-T17] Run the Pester test file `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` via `mcp__drm-copilot__run_poshqc_test` and confirm all `It` blocks pass
  - Acceptance: command exits 0 with zero failed tests reported.

### Phase 3 — Acceptance Criteria Verification

- [x] [P3-T1] Verify AC "One or more PowerShell completion-gate hooks enforce discovery-artifact completion gates by invoking the discovery validators" (`spec.md` Acceptance Criteria; `user-story.md` Acceptance Criteria) by confirming both `.claude/hooks/enforce-discovery-artifact-gate.ps1` and `.claude/hooks/validate-discovery-artifact-gate.ps1` call `Invoke-DiscoveryValidatorExe` which invokes `python -m scripts.dev_tools.validate_discovery_artifacts`, and record the confirmation in `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/other/ac-verification.<timestamp>.md`
  - Acceptance: artifact cites the exact function/line evidence in both files for this AC; and the corresponding `- [ ]` item under this AC's text in both `spec.md`'s `## Acceptance Criteria` section and `user-story.md`'s `## Acceptance Criteria` section is changed to `- [x]` once this task's verification passes.
- [x] [P3-T2] Verify AC "Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the dot-source guard" by confirming both files contain the dot-source guard `if ($MyInvocation.InvocationName -eq '.') { return }`, correct env-var reads (`$env:CLAUDE_TOOL_INPUT` / `$env:CLAUDE_HOOK_INPUT`), and `ConvertTo-Json -Compress -Depth 5` for the PreToolUse hook, appending the confirmation to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/other/ac-verification.<timestamp>.md`
  - Acceptance: artifact cites the exact line evidence in both files for this AC; and the corresponding `- [ ]` item under this AC's text in both `spec.md`'s `## Acceptance Criteria` section and `user-story.md`'s `## Acceptance Criteria` section is changed to `- [x]` once this task's verification passes.
- [x] [P3-T3] Verify AC "Hooks are registered in `.claude/settings.json` under the appropriate event with the standard command form" by re-reading `.claude/settings.json` and confirming both new entries use the exact form `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/<name>.ps1"}` in their respective matcher groups, appending the confirmation to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/other/ac-verification.<timestamp>.md`
  - Acceptance: artifact cites the matcher group name and array index/position for each new entry; and the corresponding `- [ ]` item under this AC's text in both `spec.md`'s `## Acceptance Criteria` section and `user-story.md`'s `## Acceptance Criteria` section is changed to `- [x]` once this task's verification passes.
- [x] [P3-T4] Verify AC "Hooks are domain-neutral (no domain-specific identifiers in source, comments, or messages)" by running a standalone `Select-String -Pattern 'TaskMaster|TMW|Outlook|VSTO'` against both new `.ps1` files and confirming zero matches, appending the result to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/other/ac-verification.<timestamp>.md`
  - Acceptance: artifact records the exact command run and its zero-match result, distinct from the Pester grep-gate test in P1-T17/P2-T16; and the corresponding `- [ ]` item under this AC's text in both `spec.md`'s `## Acceptance Criteria` section and `user-story.md`'s `## Acceptance Criteria` section is changed to `- [x]` once this task's verification passes.
- [x] [P3-T5] Verify AC "Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1`" by confirming both `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` and `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` exist and mirror their respective production file names, appending the confirmation to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/other/ac-verification.<timestamp>.md`
  - Acceptance: artifact lists both file paths and confirms the naming mirror; and the corresponding `- [ ]` item under this AC's text in both `spec.md`'s `## Acceptance Criteria` section and `user-story.md`'s `## Acceptance Criteria` section is changed to `- [x]` once this task's verification passes.
- [x] [P3-T6] Produce the AC Status Summary required by `acceptance-criteria-tracking` covering both `spec.md` and `user-story.md` (Source, Total AC items, Checked off, Remaining, with unchecked-item text listed if any), appended to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/other/ac-verification.<timestamp>.md`
  - Acceptance: artifact contains the four required summary fields for each of `spec.md` and `user-story.md` independently, and the reported "Checked off" count equals 5/5 for both files if P3-T1..P3-T5 passed.

### Phase 4 — Final QA Loop (PowerShell)

- [x] [P4-T1] Run `mcp__drm-copilot__run_poshqc_format` scoped to `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `.claude/hooks/validate-discovery-artifact-gate.ps1`, `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`, and `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`, and write the result to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/poshqc-format-final.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; if any file was reformatted, restart the loop from this task per the mandatory toolchain-loop rule.
- [x] [P4-T2] Run `mcp__drm-copilot__run_poshqc_analyze` scoped to the same four files, and write the result to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/poshqc-analyze-final.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` reporting zero lint errors; if any error is reported, fix and restart from P4-T1.
- [x] [P4-T3] Run `mcp__drm-copilot__run_poshqc_test` for the full Pester suite including both new test files, with coverage enabled via `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and write the result to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/pester-final.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with numeric post-change line-coverage percent (>= 85%) and branch-coverage percent (>= 75%) headline values for the two new hook files; if any test fails, fix and restart from P4-T1.
- [x] [P4-T4] Compare the P0-T9 baseline coverage against the P4-T3 final coverage and confirm no regression on any changed line, writing the delta to `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/qa-gates/coverage-delta.<timestamp>.md`
  - Acceptance: artifact records baseline line/branch coverage, post-change line/branch coverage, and the new-code line/branch coverage for the two new hook files; verdict is BLOCKED (not PASS) if any required numeric value is unavailable or if coverage falls below the 85%/75% thresholds.
