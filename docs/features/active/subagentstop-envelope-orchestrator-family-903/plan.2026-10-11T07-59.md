# subagentstop-envelope-orchestrator-family (Plan)

- **Issue:** #903 (canonical key); delivers part of #897
- **Parent:** epic subagentstop-envelope (#904), child E2
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T16-45
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug (acceptance criteria source: `spec.md` only)
- **Branch:** `bug/subagentstop-envelope-orchestrator-family-903`, targeting `epic/subagentstop-envelope-integration`
- **Upstream dependency:** E1 (#897, branch `bug/subagentstop-envelope-core-897`)
- **Executor:** `atomic-executor` (may route PowerShell implementation work to `powershell-typed-engineer`). Execution is launched later by `epic-orchestrator`.

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Summary

Convert the five E2 SubagentStop validator files to the E1 helper (`.claude/hooks/subagentstop-envelope.ps1`): read the envelope from stdin through `Read-SubagentStopEnvelope`, take the assistant text from `last_assistant_message`, and block through `Exit-SubagentStopBlock` (stderr plus exit 2) on every block path. Split `validate-orchestrator-output.ps1` into the main file and a new routing sibling. Resolve the same-file #903 notes (#787 CR-1, CR-3, CR-7; #786 double import and stale FailClosed `finally` resets). Update the Pester suites, add envelope and registration suites, raise executor and required-artifact coverage to at least 85%, and keep the bundled mirrors byte-identical.

## Inputs and Authority

- Requirements: `docs/features/active/subagentstop-envelope-orchestrator-family-903/spec.md` (24 acceptance criteria at lines 234-257, numbered AC-1 to AC-24 in source order by this plan).
- Context: `docs/features/active/subagentstop-envelope-orchestrator-family-903/issue.md`, `docs/features/active/subagentstop-envelope-orchestrator-family-903/research/research.2026-10-11T15-15.md`, `docs/features/epics/subagentstop-envelope/epic.md` (section "Shared Design", lines 75-95).
- Authoritative helper contract: E1's `spec.md` as present on `origin/epic/subagentstop-envelope-integration` after E1 merges. It is located and recorded by [P0-T1] and reconciled by [P0-T5]. Where it differs from the epic Shared Design, E1's spec governs. If it conflicts with this plan, execution halts for plan revision.
- Planning-time state (observed 2026-10-11 from on-disk refs, without a fetch): `origin/epic/subagentstop-envelope-integration` was at `ac525c4efafd7aebaa6cf6bfd658e16a8c2af395`; `origin/bug/subagentstop-envelope-core-897` was at `1e6b759c983a9dbdf4fe18a9c827f1db1f40cc8b`; `.claude/hooks/subagentstop-envelope.ps1` did not exist on this branch. E1 is therefore assumed unmerged until [P0-T1] proves otherwise.

## Planned File Split

Production (all under `.claude/hooks/`; current line counts re-derived 2026-10-11):

| File | Lines now | Change | Estimated after |
|---|---|---|---|
| `validate-orchestrator-output.ps1` | 466 | Remove `Test-OrchestratorCheckpointStructure` (171-215) and `Invoke-RoutingContractValidation` (217-323); guarded routing-sibling load; delete duplicate import at line 51; CR-3; CR-7; guarded E1 helper load; `-AssistantText` pure entry; envelope tail | about 320 |
| `validate-orchestrator-output-routing.ps1` (new) | 0 | Receives the two functions verbatim plus a header | about 175 |
| `validate-orchestrator-output-resolution.ps1` | 309 | CR-1 at lines 158-159 | 309 |
| `validate-executor-output.ps1` | 296 | Guard plus E1 helper loads; `-AssistantText`; envelope tail; regex literal at line 265 | about 300 |
| `validate-planner-output.ps1` | 416 | E1 helper load before line 36; `-AssistantText`; envelope tail | about 410 |
| `validate-required-artifact-output.ps1` | 171 | Guard plus E1 helper loads; `-AssistantText`; both block paths to exit 2 | about 175 |

Tests (all under `tests/scripts/claude-hooks/`):

| File | Lines now | Change |
|---|---|---|
| `validate-orchestrator-output.Tests.ps1` | 454 | `-AssistantText` conversion; no net new rows (cap headroom) |
| `validate-orchestrator-output.model-routing.Tests.ps1` | 161 | `-AssistantText` conversion |
| `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` | 330 | `-AssistantText` conversion |
| `validate-orchestrator-output.WaveBarrier.Tests.ps1` | 250 | `-AssistantText` conversion |
| `validate-orchestrator-output.WorktreeResolution.Tests.ps1` | 366 | `-AssistantText` conversion |
| `validate-orchestrator-output-resolution.Tests.ps1` | 235 | New rows S2-13 (CR-1) and S2-14 (CR-3); `-AssistantText` conversion; remove `ConvertTo-ResolutionPayload` (lines 45-48) |
| `validate-executor-output.Tests.ps1` | 193 | `-AssistantText` conversion; coverage rows X1-X11 |
| `validate-planner-output.Tests.ps1` | 382 | `-AssistantText` conversion; keep the six fixture test names pinned by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:146-155` |
| `validate-planner-output.Coverage.Tests.ps1` | 46 | Rewritten: stdin driver, rows E-PLN-1 to E-PLN-5 |
| `validate-required-artifact-output.Tests.ps1` | 43 | `-AssistantText` conversion; coverage rows R1-R6 |
| `hook-import-failure-exemptions.FailClosed.Tests.ps1` | 474 | H7/H8 driver to stdin envelope; remove stale `finally` resets (453, 468). Net change is negative |
| `validate-orchestrator-output.Envelope.Tests.ps1` (new) | 0 | Rows E-ORC-1 to E-ORC-6 |
| `validate-executor-output.Envelope.Tests.ps1` (new) | 0 | Rows E-EXE-1 to E-EXE-6 |
| `validate-required-artifact-output.Envelope.Tests.ps1` (new) | 0 | Rows E-RA-1 to E-RA-8 |
| `subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` (new) | 0 | Rows REG-1 and REG-2 |

`validate-orchestrator-output.human-interaction.Tests.ps1` is unchanged, because it calls `Test-HumanInteractionShape` directly.

Mirrors and manifest:

- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` byte-identical copies of all six production files (five updated, one new).
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert `.claude/hooks/validate-orchestrator-output-routing.ps1` between the `validate-orchestrator-output-resolution.ps1` entry (line 72 at planning time) and the `validate-orchestrator-output.ps1` entry (line 73 at planning time). The position is decided by entry content, not line number, because E1's merge may shift the lines.

## File Sets

These names are used in task text. Each set is closed: a task that names a set operates on exactly these paths.

- **S-PROD-6:** `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/validate-orchestrator-output-routing.ps1`, `.claude/hooks/validate-orchestrator-output-resolution.ps1`, `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-required-artifact-output.ps1`.
- **S-PROD-5:** S-PROD-6 without `.claude/hooks/validate-orchestrator-output-routing.ps1`.
- **S-MIRROR-6:** each S-PROD-6 path prefixed with `extensions/drm-copilot/resources/claude-customizations/`.
- **S-TEST-MOD-11:** the eleven modified test files in the Tests table above.
- **S-TEST-NEW-4:** `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1`.
- **S-PS-BASE-16:** S-PROD-5 plus S-TEST-MOD-11.
- **S-PS-QC-21:** S-PROD-6 plus S-TEST-MOD-11 plus S-TEST-NEW-4 (6 + 11 + 4 = 21).
- **S-COV-SUITES-BASE-12:** S-TEST-MOD-11 plus `tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1`.
- **S-COV-SUITES-16:** S-COV-SUITES-BASE-12 plus S-TEST-NEW-4.
- **S-DEP-SUITES-2:** `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` (run as regression, never edited).
- **S-PY-REG-4:** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`, `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
- **S-ALLOW:** S-PROD-6, S-MIRROR-6, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, S-TEST-MOD-11, S-TEST-NEW-4, and any path beginning `docs/features/active/subagentstop-envelope-orchestrator-family-903/`.

## Execution Rules

1. **Evidence location.** Every artifact is written under `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/<kind>/` with kind `baseline`, `regression-testing`, `qa-gates`, or `other`. Paths under `artifacts/` are never used for evidence.
2. **Timestamps.** `<ts>` in an artifact name is the execution time of that task in `yyyy-MM-ddTHH-mm` form. Each command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an artifact whose expected exit code is non-zero also carries `ExpectedExitCode: <int>`.
3. **Scratch scripts.** `<SCRATCHPAD>` is the executing session's scratchpad directory. Appendix A scripts are saved there verbatim with the Write tool (UTF-8 without BOM, LF line endings) and are never committed. No artifact records an absolute host path; host-specific path prefixes are replaced with `<SCRATCHPAD>` or `<REPO>`.
4. **PowerShell route.** PowerShell scripts are launched as `sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/<script>.ps1 <arguments>` (route `sh`). If that route is refused, the PowerShell tool runs `& <SCRATCHPAD>/<script>.ps1 <arguments>` from the repository root (route `powershell-tool`). [P0-T7] records the selected route; every later PowerShell command uses it.
5. **No MCP PoshQC numbers.** The MCP PoshQC runners are not used for any acceptance value. Their results carry no output text, and the test runner reads installed-extension settings that can omit new files. Format, analyzer, and Pester results come only from the Appendix A scripts, which print their result lines unconditionally on every run.
6. **Observe before asserting.** Before checking off any task whose acceptance reads a printed value, confirm the value appears in that run's output. The first run of each Appendix A script is in Phase 0; if a required line is absent there, halt and report rather than proceeding.
7. **Search tool.** Shell commands in this plan are POSIX-shell syntax for the Bash tool: a pattern containing `$` is single-quoted, and a pattern that begins with `-` is passed with `-e`. Static searches use `rg` from the shell. If `rg` is not on PATH (exit 127), use the Grep tool with the identical pattern and file list and record `TOOL: Grep` in the artifact. `rg` exits 1 when nothing matches; a "no match" acceptance therefore records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and empty match output. Exit code 2 (missing file or bad pattern) is a failure.
8. **Halt rule.** A task that reaches a stated halt condition stops execution, records `BLOCKED: <reason>` in its artifact, and returns to the caller. The executor does not improvise around a halt, and never creates, copies, or stubs the E1 helper.
9. **Commit and push.** Each phase ends with a commit-and-push task: write the commit message to `<SCRATCHPAD>/commit-msg.txt` (subject names the phase and `#903`; body line `Refs #903` and `Refs #897`; no closing keyword; the executing session's attribution trailers), stage only S-ALLOW paths with explicit `git add -- <paths>`, run `git commit -F <SCRATCHPAD>/commit-msg.txt`, then `git push origin bug/subagentstop-envelope-orchestrator-family-903`. Force pushes and history rewrites are prohibited. The push artifact is appended after the push and committed with the next phase.
10. **Hook denials.** If a PreToolUse hook denies a command, record the denial text in the current artifact and halt. Do not bypass or disable the hook.
11. **Batch budget.** The PowerShell batch-budget hook (`.claude/hooks/enforce-powershell-batch-budget.ps1:10-23`) caps direct-mode sessions at three distinct production PowerShell paths, and this plan edits six. [P0-T8] confirms the large-path exemption is active before any production edit. Mirror files are copied with `Copy-Item` (Appendix A6), not with Write or Edit.
12. **No temporary files in tests.** New and edited rows use `[System.IO.StringReader]`/`[System.IO.StringWriter]` for stdin and stderr, Pester mocks for filesystem seams, and committed files (such as `$PSCommandPath`) for real-read rows. No row writes, renames, or deletes a file, reads the wall clock, or sleeps.
13. **Tone.** Artifacts and commit messages follow `.claude/rules/tonality.md`.

## Target Code Shapes (quoted literals)

These literals are the executor's instructions. Later searches assert against them.

- **L1, routing-sibling load** (main file, immediately after the resolution-sibling load at line 53):
  `try { . (Join-Path $PSScriptRoot 'validate-orchestrator-output-routing.ps1') } catch { Add-HookDependencyFailure -Name 'validate-orchestrator-output-routing.ps1' -ErrorRecord $_ }`
- **L2, E1 helper load** (every converted validator, on the line immediately before its `$ErrorActionPreference = 'Stop'` line, so it is the last guarded load and runs before `Stop` is set; the C8 rows in `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1:27-33,228-235` depend on that placement). The `Join-Path $PSScriptRoot '<leaf>'` form is required so the B1 suite and the explicit helper-failure rows can fail the edge through `Mock Join-Path`:
  `try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }`
- **L3, guard line** (executor and required-artifact, first statement after `param()`, identical to `validate-planner-output.ps1:33`):
  `$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }`
- **L4, CR-3 catch body** (around the `Resolve-OrchestratorOutputCheckpointPath` call, currently line 370):
  `return @{ Ok = $false; Message = ('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: {0}: NoTarget (RESOLVER_FAILED): {1}' -f $ArtifactType, $_.Exception.Message) }`
- **L5, CR-7 comment token.** The replacement comment (currently lines 431-435) contains, on one single line, the token in-process validation (issue #475) and states that it covers both the completion and the model-routing checks. Quoted token: `in-process validation (issue #475)`.
- **L6, executor command-evidence regex** (currently line 265). Replace the substring `poetry run ` with `poetry[ ]run `, which matches the same text; the result is:
  `$hasCommandEvidence = $agentOutput -match '(?i)(Commands Run|Command[s]?:|poetry[ ]run |npx |pwsh |git |mcp__drm-copilot__)'`
- **L7, manifest entry:** `    ".claude/hooks/validate-orchestrator-output-routing.ps1",`
- **Dependency reason prefixes:** orchestrator `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and planner `validate-planner-output:` (both unchanged); executor `validate-executor-output:` (new); required-artifact `validate-required-artifact-output:` (new).
- **Pure-entry seam.** `Invoke-OrchestratorOutputValidation`, `Invoke-ExecutorOutputValidation`, `Invoke-PlannerOutputValidation`, and `Invoke-RequiredArtifactOutputValidation` replace `[string] $RawPayload` with `[AllowNull()] [AllowEmptyString()] [string] $AssistantText`. Each removes its empty-payload check, its `ConvertFrom-Json` block, and its `output` property read, and sets `$agentOutput = $AssistantText`. The existing "agent output is empty" block is kept, so empty, whitespace, and null text still block. JSON parsing of the envelope belongs to the E1 helper by contract. No other validation rule changes.
- **Tail shape** (orchestrator shown; the others differ only in prefix, parameters, and the extra required-artifact argument check):

```text
if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('<PREFIX> hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix '<PREFIX>'
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
$envelope = Read-SubagentStopEnvelope
$assistantText = if ($null -eq $envelope) { '' } else { <ASSISTANT_TEXT_ACCESSOR recorded by [P0-T5]> }
$result = Invoke-OrchestratorOutputValidation -AssistantText $assistantText -CheckpointPath $CheckpointPath -ArtifactType $ArtifactType
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

The dependency checks run before `Read-SubagentStopEnvelope`, so a failed helper load never calls an undefined function. The required-artifact tail adds, after the dependency check and before the envelope read: `if ([string]::IsNullOrWhiteSpace($AgentName) -or $null -eq $RequiredArtifact -or $RequiredArtifact.Count -eq 0) { Exit-SubagentStopBlock -Message 'validate-required-artifact-output hook: AgentName and at least one RequiredArtifact spec are required.' }`. No E2 file branches on `stop_hook_active`.

## Acceptance Criteria Map

| AC | spec.md line | Implementation tasks | Test and verification tasks | Evidence |
|---|---|---|---|---|
| AC-1 upstream gate | 234 | P0-T1 | P0-T1 | `evidence/other/upstream-gate.<ts>.md` |
| AC-2 orchestrator envelope | 235 | P3-T1..P3-T4 | P1-T1, P3-T11 | `evidence/regression-testing/orchestrator-pass-after.<ts>.md` |
| AC-3 executor envelope | 236 | P4-T1..P4-T5 | P1-T2, P4-T17 | `evidence/regression-testing/family-pass-after.<ts>.md` |
| AC-4 planner envelope | 237 | P4-T6..P4-T9 | P1-T4, P4-T17 | `evidence/regression-testing/family-pass-after.<ts>.md` |
| AC-5 required-artifact envelope | 238 | P4-T10..P4-T13 | P1-T3, P4-T17 | `evidence/regression-testing/family-pass-after.<ts>.md` |
| AC-6 legacy sources ignored | 239 | P3-T2, P3-T3, P4-T2, P4-T3, P4-T7, P4-T8, P4-T11, P4-T12 | E-ORC-4/5, E-EXE-3/4, E-PLN-4/5, E-RA-5/6 in P3-T11 and P4-T17 | same two pass-after artifacts |
| AC-7 no `CLAUDE_HOOK_INPUT` | 240 | Phases 3-4 | P6-T1 | `evidence/qa-gates/ac7-claude-hook-input.<ts>.md` |
| AC-8 no `output` reads | 241 | Phases 3-4 | P6-T2 | `evidence/qa-gates/ac8-output-reads.<ts>.md` |
| AC-9 no exit 1 or `Write-Error` | 242 | Phases 3-4 | P6-T3 | `evidence/qa-gates/ac9-exit1-write-error.<ts>.md` |
| AC-10 helper load failure exits 2 | 243 | P3-T1, P4-T1, P4-T6, P4-T10 | E-EXE-5, E-RA-7, B1 rows in P7-T5 | `evidence/qa-gates/named-rows.<ts>.md` |
| AC-11 CR-1 | 244 | P2-T6 | P1-T5, P2-T8 | `evidence/regression-testing/phase2-pass-after.<ts>.md` |
| AC-12 CR-3 | 245 | P2-T4 | P1-T6, E-ORC-6, P2-T8, P3-T11 | phase2 and orchestrator pass-after artifacts |
| AC-13 CR-7 | 246 | P2-T5 | P6-T4 | `evidence/qa-gates/ac13-cr7-comment.<ts>.md` |
| AC-14 double import | 247 | P2-T3 | P6-T5, P7-T5 | `evidence/qa-gates/ac14-double-import.<ts>.md` |
| AC-15 FailClosed nit | 248 | P2-T7 | P2-T8, P7-T5 | `evidence/qa-gates/named-rows.<ts>.md` |
| AC-16 split | 249 | P2-T1, P2-T2 | P2-T2, P6-T8, P7-T5 | `evidence/qa-gates/ac16-split.<ts>.md` |
| AC-17 500-line cap | 250 | all phases | P6-T9 | `evidence/qa-gates/line-counts.<ts>.md` |
| AC-18 coverage >= 85% | 251 | P4-T14, P4-T16, Phase 1 suites | P7-T3, P7-T7 | `evidence/qa-gates/pester-coverage.<ts>.md`, `evidence/qa-gates/coverage-delta.<ts>.md` |
| AC-19 mirrors and manifest | 252 | P5-T1, P5-T2 | P5-T3, P5-T4, P5-T5 | `evidence/qa-gates/mirror-hashes.<ts>.md`, `evidence/qa-gates/pytest-regression.<ts>.md`, `evidence/qa-gates/jest-manifest.<ts>.md` |
| AC-20 registrations | 253 | none (no agent edit) | P1-T7, P1-T9, P6-T10 | `evidence/qa-gates/scope-boundary.<ts>.md`, `evidence/regression-testing/registration-before.<ts>.md` |
| AC-21 no Python | 254 | P4-T5 | P6-T6, P7-T5 | `evidence/qa-gates/ac21-no-python.<ts>.md` |
| AC-22 no `stop_hook_active` | 255 | Phases 3-4 | P6-T7 | `evidence/qa-gates/ac22-stop-hook-active.<ts>.md` |
| AC-23 out-of-scope untouched | 256 | all phases | P6-T10 | `evidence/qa-gates/scope-boundary.<ts>.md` |
| AC-24 full toolchain | 257 | all phases | P7-T1..P7-T6 | `evidence/qa-gates/format-check.<ts>.md`, `evidence/qa-gates/pssa.<ts>.md`, `evidence/qa-gates/pester-full.<ts>.md`, `evidence/qa-gates/final-qc-loop.<ts>.md` |

### Phase 0 — Upstream Gate, Integration Merge, Policy Reads, Contract Reconciliation, and Baseline Capture

- [ ] [P0-T1] UPSTREAM-MERGE CHECK (first task; no other task runs before it). Run `git fetch origin epic/subagentstop-envelope-integration bug/subagentstop-envelope-core-897` and record `FETCH_EXIT_CODE:`. Record `INTEGRATION_SHA:` from `git rev-parse origin/epic/subagentstop-envelope-integration`. E1 merged check: (i) run `git log --first-parent --merges --format=%H%x09%s origin/epic/subagentstop-envelope-integration` and record `E1_MERGE_SUBJECTS:` as the count of subjects ending in `bug/subagentstop-envelope-core-897`; (ii) record `E1_ANCESTOR_EXIT_CODE:` from `git merge-base --is-ancestor origin/bug/subagentstop-envelope-core-897 origin/epic/subagentstop-envelope-integration` and `E1_COMMITS_PAST_BASE:` from `git rev-list --count ac525c4efafd7aebaa6cf6bfd658e16a8c2af395..origin/bug/subagentstop-envelope-core-897`; `E1_MERGED: YES` when `E1_MERGE_SUBJECTS` is at least 1, or when `E1_ANCESTOR_EXIT_CODE` is 0 and `E1_COMMITS_PAST_BASE` is at least 1; otherwise `NO`. Helper checks: record `HELPER_EXISTS_EXIT_CODE:` from `git cat-file -e origin/epic/subagentstop-envelope-integration:.claude/hooks/subagentstop-envelope.ps1`; record `READ_FN_COUNT:` from `git show origin/epic/subagentstop-envelope-integration:.claude/hooks/subagentstop-envelope.ps1 | rg -c "^\s*function\s+Read-SubagentStopEnvelope\b"` and `EXIT_FN_COUNT:` from the same command with `Exit-SubagentStopBlock`. E1 spec: run `git ls-tree -r --name-only origin/epic/subagentstop-envelope-integration -- docs/features`, record `E1_SPEC_PATH:` as the single path ending in `subagentstop-envelope-core-897/spec.md` (zero or several matches fail the check), and record `E1_SPEC_NAMES_BOTH: YES` when `git show origin/epic/subagentstop-envelope-integration:<E1_SPEC_PATH>` contains both function names (a template spec fails). Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/upstream-gate.<ts>.md` with all fields above and `UPSTREAM_GATE: PASS` or `UPSTREAM_GATE: FAIL` plus `FAILED_CHECK:`. Acceptance: `FETCH_EXIT_CODE: 0`, `E1_MERGED: YES`, `HELPER_EXISTS_EXIT_CODE: 0`, `READ_FN_COUNT: 1`, `EXIT_FN_COUNT: 1`, exactly one `E1_SPEC_PATH`, `E1_SPEC_NAMES_BOTH: YES`, and `UPSTREAM_GATE: PASS`. On any failure: halt (rule 8) with blocked state `UPSTREAM NOT MERGED`; no merge, edit, or helper creation is performed.
- [ ] [P0-T2] Merge the integration branch into the feature branch. Record `PRE_MERGE_HEAD:` from `git rev-parse HEAD` and the `git status --porcelain` output; halt if any porcelain path lies outside `docs/features/active/subagentstop-envelope-orchestrator-family-903/`. Write the merge message to `<SCRATCHPAD>/p0-merge-msg.txt` (subject `Merge epic/subagentstop-envelope-integration into bug/subagentstop-envelope-orchestrator-family-903 (#903)`, body `Refs #903` and `Refs #897`), then run `git merge --no-ff -F <SCRATCHPAD>/p0-merge-msg.txt origin/epic/subagentstop-envelope-integration`. On conflict run `git merge --abort` and halt. Then record `ANCESTOR_EXIT_CODE:` from `git merge-base --is-ancestor origin/epic/subagentstop-envelope-integration HEAD`, `HELPER_ON_HEAD_EXIT_CODE:` from `git cat-file -e HEAD:.claude/hooks/subagentstop-envelope.ps1`, and `POST_MERGE_HEAD:` from `git rev-parse HEAD`. No force push and no rebase is used. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/p0-merge.<ts>.md` (four schema fields plus the values above). Acceptance: `MERGE_EXIT_CODE: 0`, `ANCESTOR_EXIT_CODE: 0`, `HELPER_ON_HEAD_EXIT_CODE: 0`.
- [ ] [P0-T3] Read policy files in the order given by the policy-compliance-order skill: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`; then the supplementary files `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:` (the first four paths, in order), and `Files Read:` (all seven paths). Acceptance: the three labels are present, `Policy Order:` lists the four paths in the stated order, and `Files Read:` lists exactly seven paths.
- [ ] [P0-T4] Read `docs/features/active/subagentstop-envelope-orchestrator-family-903/spec.md`, `docs/features/active/subagentstop-envelope-orchestrator-family-903/issue.md`, `docs/features/active/subagentstop-envelope-orchestrator-family-903/research/research.2026-10-11T15-15.md`, `docs/features/epics/subagentstop-envelope/epic.md`, E1's spec at `E1_SPEC_PATH` (from HEAD after the merge), and this plan. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/p0-feature-documents-read.md` with `Timestamp:`, `Files Read:` (six paths), and `AC Inventory:` listing, for every line under `## Acceptance Criteria` in `spec.md` that begins with an unchecked checkbox, the identifier AC-n (n = 1-based source order), its line number, and its first twelve words. Acceptance: exactly 24 entries, AC-1 to AC-24, at spec lines 234 to 257.
- [ ] [P0-T5] Reconcile the E1 contract. Read `.claude/hooks/subagentstop-envelope.ps1` and E1's spec at `E1_SPEC_PATH` on HEAD. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/e1-contract-reconciliation.<ts>.md` with: `E1_SPEC_PATH:`; `HELPER_BLOB:` from `git rev-parse HEAD:.claude/hooks/subagentstop-envelope.ps1`; `STDIN_SOURCE:` (the expression the helper uses to read stdin, quoted from the helper source with its line number); `RETURN_SHAPE:` (the type and property names of the value `Read-SubagentStopEnvelope` returns, quoted from E1's spec); `ASSISTANT_TEXT_ACCESSOR:` (the exact PowerShell expression that yields the assistant text from that value, taken from E1's spec, for example `$envelope.last_assistant_message`); `EMPTY_STDIN_BEHAVIOR:` and `MALFORMED_STDIN_BEHAVIOR:` (quoted from E1's spec); `STOP_HOOK_ACTIVE_BEHAVIOR:` (quoted); `BLOCK_PARAMETER:` (the parameter name of `Exit-SubagentStopBlock` that carries the reason); `HELPER_READS_CLAUDE_HOOK_INPUT:` (YES when `rg -n "CLAUDE_HOOK_INPUT" .claude/hooks/subagentstop-envelope.ps1` matches, else NO); `HELPER_DEPENDENCIES:` (files the helper dot-sources or imports); and `CONFLICTS_WITH_E2_SPEC:` (each point where E1's spec contradicts `spec.md` Proposed Fix or this plan's Target Code Shapes, or `NONE`). Acceptance: every field is present and nonblank; `STDIN_SOURCE` reads through `[Console]::In` (so `[System.Console]::SetIn` redirects it in-process); `BLOCK_PARAMETER: Message`; `HELPER_READS_CLAUDE_HOOK_INPUT: NO`; `CONFLICTS_WITH_E2_SPEC: NONE`. Any other value halts (rule 8) with blocked state `E1 CONTRACT RECONCILIATION REQUIRED` for plan revision.
- [ ] [P0-T6] Confirm the planning-time line anchors survived the merge. Run `git diff --name-only <PRE_MERGE_HEAD> HEAD -- .claude/hooks tests/scripts/claude-hooks extensions/drm-copilot/resources/claude-customizations .claude/agents` and `git status --porcelain`, and run Appendix A4 (`line-counts.ps1`) over S-PS-BASE-16. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/p0-anchor-drift.<ts>.md` (four schema fields) with both listings and the line counts. Acceptance: no S-PS-BASE-16 path appears in the diff listing; the line counts read 466, 309, 296, 416, 171 for S-PROD-5 (in S-PROD-5 order) and 454, 161, 330, 250, 366, 235, 193, 382, 46, 43, 474 for S-TEST-MOD-11 (in the Tests-table order). A mismatch halts (rule 8) with blocked state `PLAN ANCHORS STALE`.
- [ ] [P0-T7] Save Appendix A scripts A0 to A9 under `<SCRATCHPAD>/` with the Write tool, then establish the route: run Appendix A1 (`pester-run.ps1`) with `-TestPath tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1` by route `sh` first, then route `powershell-tool` only if `sh` is refused. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/p0-execution-route.<ts>.md` (four schema fields) with one `ROUTE-ATTEMPT: <route> | ran` or `ROUTE-ATTEMPT: <route> | refused` line per attempt, the refusal text of any refused attempt, exactly one `ROUTE_SELECTED:` line, and the probe output. Acceptance: `ROUTE_SELECTED:` is `sh` or `powershell-tool`; the output contains the printed lines `TotalCount=`, `PassedCount=3`, `FailedCount=0`, and `FailedContainersCount=0`. If both routes are refused, record `ROUTE_SELECTED: none` and halt.
- [ ] [P0-T8] Confirm the batch-budget large-path exemption. Read `artifacts/orchestration/orchestrator-state.json` at the worktree root. Record `CHECKPOINT_PRESENT:`, `SELECTED_ROUTE:` (the `route_id` value when present and nonblank, otherwise `path_selected`), `NEXT_STEP:`, `HAS_S12_COMPLETE:`, and `BATCH_BUDGET_MODE:` (`large-path-exempt` when `SELECTED_ROUTE` is `large`, `remediation`, or `preparation` and the checkpoint is not terminal, meaning `NEXT_STEP` is not `complete` and `HAS_S12_COMPLETE` is false; otherwise `direct`), following `.claude/hooks/enforce-powershell-batch-budget.ps1:16-23`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/p0-batch-budget-route.<ts>.md`. Acceptance: `BATCH_BUDGET_MODE: large-path-exempt`. `direct` halts (rule 8) with blocked state `BATCH_BUDGET_DIRECT_MODE`, reported to `epic-orchestrator`; no state file is deleted.
- [ ] [P0-T9] Baseline format check: run Appendix A2 (`ps-format-check.ps1`) over S-PS-BASE-16. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/format-check.<ts>.md` (four schema fields; `Output Summary:` carries the printed `FORMAT-SUMMARY ChangedCount=<n>` line and every `Changed=True` file). Acceptance: the artifact exists with the four fields and the printed `FORMAT-SUMMARY ChangedCount=` line. A non-zero baseline count is recorded, not repaired; A2 is read-only.
- [ ] [P0-T10] Baseline analyzer: run Appendix A3 (`pssa-count.ps1`) over S-PS-BASE-16. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/pssa.<ts>.md` (four schema fields; `Output Summary:` carries the printed `PSSA-SUMMARY DiagnosticCount=<n>` line and every `PSSA` finding line). Acceptance: the artifact exists with the four fields and the printed `PSSA-SUMMARY DiagnosticCount=` line.
- [ ] [P0-T11] Baseline Pester with coverage: run Appendix A1 with `-TestPath` set to S-COV-SUITES-BASE-12, `-CoveragePath` set to S-PROD-5, `-CoverageOutputPath <SCRATCHPAD>/baseline-coverage.xml`, and `-ReportPath <SCRATCHPAD>/baseline-coverage-report.txt`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/pester-coverage.<ts>.md` (four schema fields; `Output Summary:` carries the four count lines, every `FAILED:` line, and the five `COVERAGE file=... LinePercent=...` lines; `Baseline Coverage:` lists the numeric LinePercent of each S-PROD-5 file; the full report text is appended). Acceptance: five `COVERAGE` lines, each with a numeric `LinePercent` (not `NA`).
- [ ] [P0-T12] Baseline full Pester: run Appendix A1 with `-TestPath tests/scripts/claude-hooks,tests/scripts/claude-runtime` (no coverage). Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/pester-full.<ts>.md` (four schema fields; `Output Summary:` carries the four count lines; `Baseline Failed Set:` lists every `FAILED:` and `FAILED-CONTAINER:` line verbatim, or `none`). Acceptance: the artifact exists with the four printed count lines and the `Baseline Failed Set:` section.
- [ ] [P0-T13] Baseline Python regression: run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/pytest-regression.<ts>.md` (four schema fields; `Output Summary:` carries pytest's final summary line and every `FAILED` node ID as `Baseline Failed Set:`, or `none`). Acceptance: the artifact exists and records pytest's final summary line.
- [ ] [P0-T14] Baseline TypeScript manifest test: if `extensions/drm-copilot/node_modules/jest/package.json` is absent, first run `npm --prefix extensions/drm-copilot ci` and record its exit code. Then run `npm --prefix extensions/drm-copilot test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/jest-manifest.<ts>.md` (four schema fields; `Output Summary:` carries Jest's `Tests:` line). Acceptance: the artifact exists and records Jest's `Tests:` line.
- [ ] [P0-T15] Baseline static searches over S-PROD-5 (the routing sibling does not exist yet). Run the seven searches of [P6-T1] to [P6-T7] with S-PROD-5 in place of S-PROD-6 and record, per search, `MATCHES-AC-7:`, `MATCHES-AC-8:`, `MATCHES-AC-9:`, `MATCHES-AC-13:`, `MATCHES-AC-14:`, `MATCHES-AC-21:`, `MATCHES-AC-22:` (match counts) with the matching lines. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/static-searches.<ts>.md`. Acceptance: all seven count lines are present. At planning time the expected baseline counts are non-zero for AC-7, AC-8, AC-9, AC-13, and AC-21 (the AC-21 match is the regex literal at `.claude/hooks/validate-executor-output.ps1:265`), two lines for AC-14 (lines 51 and 59), and zero for AC-22.
- [ ] [P0-T16] Baseline line counts: run Appendix A4 over S-PS-BASE-16 and write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/line-counts.<ts>.md` (four schema fields; `Output Summary:` carries the printed `LINECOUNT-SUMMARY` line). Acceptance: sixteen `LineCount=` lines and the printed summary line `LINECOUNT-SUMMARY OverLimitCount=0`.
- [ ] [P0-T17] Commit and push Phase 0 (rule 9): stage `docs/features/active/subagentstop-envelope-orchestrator-family-903/` only (the merge commit from [P0-T2] is already on HEAD), commit, and push. Append `COMMIT_SHA:`, `PUSH_EXIT_CODE:`, and `AHEAD_AFTER_PUSH:` (from `git rev-list --count origin/bug/subagentstop-envelope-orchestrator-family-903..HEAD`) to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase0.<ts>.md`. Acceptance: `PUSH_EXIT_CODE: 0` and `AHEAD_AFTER_PUSH: 0`.

### Phase 1 — Fail-Before Regression Tests

All envelope rows drive the hook through the `&` route in-process. Each suite's `BeforeAll` dot-sources its hook (and, for the orchestrator suite, imports the modules the existing orchestrator suites import plus any module listed in `HELPER_DEPENDENCIES` from [P0-T5]) so that every mocked command resolves when `Mock` is called; Pester mocks then intercept the same commands inside the `&` invocation, as `Mock Import-Module` does in H7. Each suite defines one driver function that saves `[System.Console]::In`, `[System.Console]::Error`, and `$env:CLAUDE_HOOK_INPUT`, sets stdin with `[System.Console]::SetIn([System.IO.StringReader]::new(<text>))`, captures stderr with a `StringWriter`, sets `$env:CLAUDE_HOOK_INPUT` to the row's legacy value or removes it, sets `$global:LASTEXITCODE = 0`, runs the hook inside `try`/`catch` to capture `Thrown`, and restores all three in `finally`. Each row asserts `Thrown` is empty, the exit code, and a stderr token. The orchestrator suite registers the `EpicStateIsolation.Baseline.Helpers.ps1` mocks exactly as `hook-import-failure-exemptions.FailClosed.Tests.ps1:400-416` does.

- [ ] [P1-T1] [expect-fail] Create `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1` with these rows. `E-ORC-1 blocks with exit 2 when last_assistant_message is empty` (stdin `{"hook_event_name":"SubagentStop","last_assistant_message":""}`; exit 2; stderr contains `agent output is empty`). `E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved` (`Resolve-OrchestratorOutputCheckpointPath` mocked to return `Resolved = $false`, `Status = 'NoTarget'`, `ReasonCode = 'NO_TARGET'`, `Detail = 'synthetic'`; stderr starts with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:`). `E-ORC-3 exits 0 for a completion summary and a valid checkpoint fixture` (resolver mocked resolved to `/synthetic-worktrees/e2/artifacts/orchestration/orchestrator-state.json`; `Get-CheckpointFileContent` mocked to return `Exists = $true` and JSON with nonblank `objective`, `completed_steps`, `next_step`, `last_updated`; `Invoke-RoutingContractValidation` mocked to return `HasErrors = $false`; exit 0; stderr empty). `E-ORC-4 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails` (E-ORC-3 mocks; legacy value `{"output":"Final summary."}`; stdin as E-ORC-1). `E-ORC-5 blocks with exit 2 when the envelope carries only an output key` (E-ORC-3 mocks; stdin `{"output":"Final summary."}`). `E-ORC-6 exits 2 with ORCHESTRATOR_CHECKPOINT_UNRESOLVED: when the resolver throws` (resolver mocked to throw `simulated resolver failure (CR-3)`; stderr starts with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and contains `RESOLVER_FAILED`). Every row mocks `Import-Module` as a no-op, as H7 does. Acceptance: the file exists, defines the six named rows, and is at most 500 lines (Appendix A4).
- [ ] [P1-T2] [expect-fail] Create `tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1` with rows: `E-EXE-1 blocks with exit 2 when last_assistant_message lacks a plan-path line` (text `Done. All phases complete.`; stderr contains `does not advertise a plan-path`). `E-EXE-2 exits 0 when the advertised plan satisfies the executor checks` (`Get-PlanFileContent` mocked to return `Exists = $true` and lines with one checked task naming `scripts/powershell/Foo.ps1`; text carries `plan-path: docs/features/active/foo/plan.md`, `AC Status Summary`, `Commands Run:`, and `PowerShell: PASS`; exit 0). `E-EXE-3 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails` (E-EXE-2 mock; legacy value is the E-EXE-2 text under an `output` key; stdin as E-EXE-1). `E-EXE-4 blocks with exit 2 when the envelope carries only an output key` (E-EXE-2 mock; stdin carries the E-EXE-2 text under `output` only). `E-EXE-5 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load` (`Mock Join-Path { throw 'simulated load failure: subagentstop-envelope.ps1' } -ParameterFilter { $ChildPath -eq 'subagentstop-envelope.ps1' }`; stderr starts with `validate-executor-output:` and contains `subagentstop-envelope.ps1`). `E-EXE-6 exits 2 when hook-dependency-guard.ps1 fails to load` (`Join-Path` throws for `hook-dependency-guard.ps1`; stderr starts with `validate-executor-output: hook-dependency-guard.ps1 failed to load`). Acceptance: the file exists, defines the six named rows, and is at most 500 lines.
- [ ] [P1-T3] [expect-fail] Create `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1` using spec `spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact` and `-AgentName prd-feature` unless a row says otherwise. Rows: `E-RA-1 blocks with exit 2 when the required artifact is missing` (text `No artifact path reported.`; stderr contains `missing spec-path`). `E-RA-2 blocks with exit 2 when -AgentName is missing` and `E-RA-3 blocks with exit 2 when -RequiredArtifact is missing` (stderr contains `AgentName and at least one RequiredArtifact spec are required`). `E-RA-4 exits 0 when the artifact is present` (`Test-ArtifactFile` mocked `$true`; text `spec-path: docs/features/active/foo/spec.md`). `E-RA-5 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails` (E-RA-4 mock; legacy value carries the E-RA-4 text under `output`; stdin as E-RA-1). `E-RA-6 blocks with exit 2 when the envelope carries only an output key`. `E-RA-7 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load` (stderr starts with `validate-required-artifact-output:`). `E-RA-8 exits 2 when hook-dependency-guard.ps1 fails to load` (stderr starts with `validate-required-artifact-output: hook-dependency-guard.ps1 failed to load`). Acceptance: the file exists, defines the eight named rows, and is at most 500 lines.
- [ ] [P1-T4] [expect-fail] Rewrite `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1`: replace the `CLAUDE_HOOK_INPUT` driver (lines 16-35) with the stdin driver and replace the single row (lines 38-45) with: `E-PLN-1 blocks with exit 2 when last_assistant_message lacks the PREFLIGHT: signal` (stderr contains `agent output must include`). `E-PLN-2 blocks with exit 2 when last_assistant_message lacks the plan-path line` (text carries `PREFLIGHT: ALL CLEAR` only; stderr contains `does not advertise a plan-path`). `E-PLN-3 exits 0 when both are present with a contract-valid plan fixture` (`Get-PlanFileContent` mocked with the contract-valid plan lines used by the row `allows termination when the plan satisfies the structural contract` in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`; text carries `plan-path:`, a valid planner internal review record, and `PREFLIGHT: ALL CLEAR`). `E-PLN-4 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails`. `E-PLN-5 blocks with exit 2 when the envelope carries only an output key`. Update the `.DESCRIPTION` so it no longer names the environment variable. Acceptance: the five named rows exist; `rg -n "CLAUDE_HOOK_INPUT is empty" tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1` returns no match; the file is at most 500 lines.
- [ ] [P1-T5] [expect-fail] Add row `S2-13 keeps a checkpoint whose route and field keys differ only in case (CR-1)` to `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1`, after S2-12. Arrange `Set-ResolutionRunTopology -Live @('/synthetic-worktrees/r-case') -Epic @{ '/synthetic-worktrees/r-case' = '{"Route_Id":"epic","Integration_Branch":"epic/case"}' }`; act `Find-OrchestratorOutputRunSignalValue -Kind 'epic' -SessionRoot $script:Session`; assert the joined values are exactly `epic/case`. Acceptance: the row exists and the file is at most 500 lines.
- [ ] [P1-T6] [expect-fail] Add row `S2-14 returns ORCHESTRATOR_CHECKPOINT_UNRESOLVED: when the resolver throws (CR-3)` to `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1`. Arrange `Mock Resolve-OrchestratorOutputCheckpointPath { throw 'simulated resolver failure (CR-3)' }`; act with the current signature, `Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-ResolutionPayload -Output 'Final summary.') -CheckpointPath 'artifacts/orchestration/epic-orchestrator-state.json' -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session` (converted to `-AssistantText` in [P3-T10]); assert `Ok` is false, `Message` starts with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` (ordinal), and `Message` contains `RESOLVER_FAILED`. Acceptance: the row exists and the file is at most 500 lines.
- [ ] [P1-T7] Create `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1`. It reads `.claude/agents/*.md` as text and selects lines matching `^\s*command:\s*pwsh\b.*\.claude/hooks/(validate-orchestrator-output|validate-executor-output|validate-planner-output|validate-required-artifact-output)\.ps1`. Row `REG-1 discovers exactly nine SubagentStop registrations of E2 hooks` asserts the selected count is 9 (at planning time: `.claude/agents/orchestrator.md:42`, `epic-orchestrator.md:29`, `parallel-orchestrator.md:42`, `atomic-planner.md:23`, `atomic-executor.md:36`, `epic-review.md:18`, `prd-feature.md:18`, `staged-review.md:19`, `status-updater.md:19`). Row `REG-2 every argument name passed by a registration exists in the target script param block` extracts each `-Name` token after the script path and asserts it is in the parameter names parsed from the target script with `[System.Management.Automation.Language.Parser]::ParseFile` (`ParamBlock.Parameters`). The suite edits no agent file and writes no file. Acceptance: both rows exist and the file is at most 500 lines.
- [ ] [P1-T8] [expect-fail] Run the fail-before suite set with Appendix A1: `-TestPath` set to `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/regression-testing/fail-before.<ts>.md` (four schema fields plus `ExpectedExitCode: 1`; `Output Summary:` carries the four count lines and every `FAILED:` line). Acceptance: `EXIT_CODE: 1`; `FailedContainersCount=0`; `FailedCount=27`; the `FAILED:` lines are exactly the 27 rows E-ORC-1..6, E-EXE-1..6, E-RA-1..8, E-PLN-1..5, S2-13, and S2-14, so every pre-existing resolution row passes. A row that passes before the fix is not a valid regression test; correct it and re-run this task.
- [ ] [P1-T9] Run Appendix A1 with `-TestPath tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/regression-testing/registration-before.<ts>.md` (four schema fields). Acceptance: `EXIT_CODE: 0`, `PassedCount=2`, `FailedCount=0`, `FailedContainersCount=0`.
- [ ] [P1-T10] Commit and push Phase 1 (rule 9): the four new or rewritten test files from [P1-T1] to [P1-T4], `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1`, `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1`, and the feature-folder evidence. Append the push fields to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase1.<ts>.md`. Acceptance: `PUSH_EXIT_CODE: 0` and `AHEAD_AFTER_PUSH: 0`.

### Phase 2 — Orchestrator Split and Same-File Review Notes

The orchestrator pure entry keeps `-RawPayload` in this phase so the CR-3 row has a clean pass-after. The Phase 1 envelope suites still fail until Phases 3 and 4, so no Phase 2 gate runs them.

- [ ] [P2-T1] Save `git show HEAD:.claude/hooks/validate-orchestrator-output.ps1` to `<SCRATCHPAD>/orchestrator-before-split.ps1`. Create `.claude/hooks/validate-orchestrator-output-routing.ps1` with a comment-based help header in the style of `.claude/hooks/validate-orchestrator-output-resolution.ps1` (SYNOPSIS: routing-contract dispatch for the orchestrator SubagentStop hook; DESCRIPTION: dot-sourced by `validate-orchestrator-output.ps1` through a guarded load; the default `Invoker` resolves `../lib/orchestrator-state/OrchestratorStateCompletion.psm1` from `$PSScriptRoot`; starts no process and invokes no Python), followed by `Test-OrchestratorCheckpointStructure` and `Invoke-RoutingContractValidation` copied verbatim from current lines 171-323. The file has no `param()`, no `exit`, and no top-level statement other than the two function definitions. Acceptance: Appendix A7 (`function-text-compare.ps1 -OldPath <SCRATCHPAD>/orchestrator-before-split.ps1 -NewPath .claude/hooks/validate-orchestrator-output-routing.ps1 -Name Test-OrchestratorCheckpointStructure,Invoke-RoutingContractValidation`) prints `FUNCTION-TEXT-SUMMARY MismatchCount=0` with two `Match=True` lines; record the output in `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/split-function-text.<ts>.md`.
- [ ] [P2-T2] In `.claude/hooks/validate-orchestrator-output.ps1`, delete the two function definitions (lines 171-323) and insert literal L1 on the line immediately after the resolution-sibling load (line 53). Acceptance: `rg -n "^function (Test-OrchestratorCheckpointStructure|Invoke-RoutingContractValidation)\b" .claude/hooks/validate-orchestrator-output.ps1` returns no match; `rg -c -F "validate-orchestrator-output-routing.ps1') } catch { Add-HookDependencyFailure" .claude/hooks/validate-orchestrator-output.ps1` prints `1`; the L1 line precedes the `$ErrorActionPreference = 'Stop'` line. Append both search outputs to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/split-function-text.<ts>.md`.
- [ ] [P2-T3] In `.claude/hooks/validate-orchestrator-output.ps1`, delete the non-`-Global` `OrchestratorState.psm1` import (line 51), keeping the `-Global` import (line 59) last in the import sequence. Acceptance: `rg -n "OrchestratorState\.psm1'\)" .claude/hooks/validate-orchestrator-output.ps1` prints exactly one line, and it contains `-Global`.
- [ ] [P2-T4] CR-3: in `.claude/hooks/validate-orchestrator-output.ps1`, wrap the `$resolution = Resolve-OrchestratorOutputCheckpointPath ...` call (line 370) in `try { ... } catch { <L4> }`, leaving the `if (-not $resolution.Resolved)` block after it unchanged. Acceptance: `rg -c -F "NoTarget (RESOLVER_FAILED)" .claude/hooks/validate-orchestrator-output.ps1` prints `1`.
- [ ] [P2-T5] CR-7: in `.claude/hooks/validate-orchestrator-output.ps1`, replace the comment at lines 431-435 with a comment that contains the single-line token `in-process validation (issue #475)` (literal L5) and keeps the explanation of the `MODEL_ROUTING_BLOCKED` and `ROUTING_CONTRACT_BLOCKED` fallback. Comment-only change. Acceptance: `rg -n "One subprocess call" .claude/hooks/validate-orchestrator-output.ps1` returns no match and `rg -c -F "in-process validation (issue #475)" .claude/hooks/validate-orchestrator-output.ps1` prints `1`.
- [ ] [P2-T6] CR-1: in `.claude/hooks/validate-orchestrator-output-resolution.ps1`, `Find-OrchestratorOutputRunSignalValue`, change `$names -ccontains 'route_id'` (line 158) and `$names -ccontains $field` (line 159) to `-contains`, keeping `-cne $route`. Acceptance: `rg -n "ccontains" .claude/hooks/validate-orchestrator-output-resolution.ps1` returns no match and `rg -c -F -e '-cne $route' .claude/hooks/validate-orchestrator-output-resolution.ps1` prints `1`.
- [ ] [P2-T7] In `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`: (a) in H7 and H8, remove the `try`/`finally` wrappers whose `finally` bodies reset `$script:OrchestratorOutputResolverImportFailure` (line 453) and `$script:OrchestratorOutputWaveBarrierImportFailure` (line 468), keeping the `$result = Invoke-OrchestratorOutputHookProcess ...` statements; (b) in `Invoke-OrchestratorOutputHookProcess` (lines 418-441), remove the `$priorInput` save and restore (lines 424 and 438) and the environment-variable assignment (line 430), supply the stdin envelope `{"hook_event_name":"SubagentStop","last_assistant_message":"Final summary."}` through `SetIn` in place of the empty string at line 428, and reword the driver comment (lines 419-420) so it names the stdin envelope. Acceptance: `rg -n "OrchestratorOutputResolverImportFailure|OrchestratorOutputWaveBarrierImportFailure|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` returns no match, and Appendix A4 reports at most 474 lines for the file.
- [ ] [P2-T8] Phase 2 gate: run Appendix A1 with `-TestPath` set to `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, and S-DEP-SUITES-2. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/regression-testing/phase2-pass-after.<ts>.md` (four schema fields; `Output Summary:` carries the count lines and the passed-row lines quoted below). Acceptance: `EXIT_CODE: 0`, `FailedCount=0`, `FailedContainersCount=0`; the Detailed output has passed (`[+]`) lines for `S2-13`, `S2-14`, `H7`, `H8`, the AST row `invokes no python, python3, py, or poetry command anywhere in the default invoker`, and a B1 row containing `blocks naming validate-orchestrator-output-routing.ps1`.
- [ ] [P2-T9] Run Appendix A4 over `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/validate-orchestrator-output-routing.ps1`, `.claude/hooks/validate-orchestrator-output-resolution.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1`, and `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/line-counts-phase2.<ts>.md`. Acceptance: the printed line `LINECOUNT-SUMMARY OverLimitCount=0`.
- [ ] [P2-T10] Commit and push Phase 2 (rule 9): `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/validate-orchestrator-output-routing.ps1`, `.claude/hooks/validate-orchestrator-output-resolution.ps1`, `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, and the feature-folder evidence. Append the push fields to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase2.<ts>.md`. Acceptance: `PUSH_EXIT_CODE: 0` and `AHEAD_AFTER_PUSH: 0`.

### Phase 3 — Orchestrator Envelope Conversion

- [ ] [P3-T1] In `.claude/hooks/validate-orchestrator-output.ps1`, insert literal L2 on the line immediately before the `$ErrorActionPreference = 'Stop'` line (after the `OrchestratorState.psm1` `-Global` import). Acceptance: `rg -c -F "'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1'" .claude/hooks/validate-orchestrator-output.ps1` prints `1`, and that line number is lower than the line number of `$ErrorActionPreference = 'Stop'`.
- [ ] [P3-T2] In `.claude/hooks/validate-orchestrator-output.ps1`, apply the pure-entry seam change to `Invoke-OrchestratorOutputValidation`: replace `[string] $RawPayload` with `[AllowNull()] [AllowEmptyString()] [string] $AssistantText`; delete the empty-payload block (lines 350-352), the `ConvertFrom-Json` block (lines 354-358), and the `output` read (lines 360-363); set `$agentOutput = $AssistantText`; keep the "agent output is empty" block; keep the dependency-decision check first; update `.SYNOPSIS` to "Validates the assistant text and returns an ok-or-block decision." Acceptance: `rg -n "RawPayload" .claude/hooks/validate-orchestrator-output.ps1` returns no match, and `rg -c "ConvertFrom-Json" .claude/hooks/validate-orchestrator-output.ps1` prints `1` (the remaining match is the checkpoint parse, currently line 386).
- [ ] [P3-T3] Replace the entry tail of `.claude/hooks/validate-orchestrator-output.ps1` (lines 456-466) with the Tail shape, using prefix `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:`, the `ASSISTANT_TEXT_ACCESSOR` recorded by [P0-T5], and `-CheckpointPath $CheckpointPath -ArtifactType $ArtifactType`. Acceptance: `rg -c "Read-SubagentStopEnvelope|Exit-SubagentStopBlock" .claude/hooks/validate-orchestrator-output.ps1` prints `2` and `rg -n "\bexit 1\b|Write-Error" .claude/hooks/validate-orchestrator-output.ps1` returns no match.
- [ ] [P3-T4] Update the help block of `.claude/hooks/validate-orchestrator-output.ps1`: the `.DESCRIPTION` bullet "the hook payload is well-formed JSON" (line 14) becomes "the SubagentStop envelope is read from stdin through Read-SubagentStopEnvelope"; `.NOTES` (lines 30-36) states that the envelope is read from stdin, the assistant text comes from `last_assistant_message`, a block is written to stderr with exit 2 through `Exit-SubagentStopBlock`, and the routing sibling, resolution sibling, E1 helper, and modules are guarded loads. Acceptance: `rg -n "CLAUDE_HOOK_INPUT|exits 1" .claude/hooks/validate-orchestrator-output.ps1` returns no match.
- [ ] [P3-T5] Convert `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`: replace every `-RawPayload <json>` argument with `-AssistantText <text>`, where text is the former `output` value. Replace the four payload-validation rows (lines 35-81) with three rows: `blocks when the assistant text is empty` (`''`), `blocks when the assistant text is whitespace` (`'   '`), and `blocks when the assistant text is null` (`$null`), each asserting `agent output is empty`. Add no other row. Acceptance: `rg -n "RawPayload|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` returns no match and Appendix A4 reports at most 454 lines.
- [ ] [P3-T6] Convert `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` to `-AssistantText` in the same way. Acceptance: `rg -n "RawPayload|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` returns no match.
- [ ] [P3-T7] Convert `tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` to `-AssistantText`. Acceptance: `rg -n "RawPayload|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` returns no match.
- [ ] [P3-T8] Convert `tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1` to `-AssistantText`, keeping row H12's `ExitCode = 2` and `Reason` assertions. Acceptance: `rg -n "RawPayload|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1` returns no match.
- [ ] [P3-T9] Convert `tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1` to `-AssistantText`. Acceptance: `rg -n "RawPayload|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1` returns no match.
- [ ] [P3-T10] Convert `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1`: delete `ConvertTo-ResolutionPayload` (lines 45-48) and call `Invoke-OrchestratorOutputValidation -AssistantText 'Final summary.'` in S2-12, S2-14, and every other caller, keeping S2-12's `ExitCode = 2` and `Reason` assertions. Acceptance: `rg -n "RawPayload|ConvertTo-ResolutionPayload" tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1` returns no match.
- [ ] [P3-T11] Orchestrator gate: run Appendix A1 with `-TestPath` set to the eight test files of [P2-T8] plus `tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1` and S-DEP-SUITES-2. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/regression-testing/orchestrator-pass-after.<ts>.md` (four schema fields; count lines and the passed-row lines quoted below). Acceptance: `EXIT_CODE: 0`, `FailedCount=0`, `FailedContainersCount=0`; six passed (`[+]`) lines beginning `E-ORC-`; passed lines for `S2-13`, `S2-14`, `H7`, `H8`; and a passed B1 row containing `validate-orchestrator-output.ps1` and `blocks naming subagentstop-envelope.ps1`.
- [ ] [P3-T12] Run Appendix A4 over `.claude/hooks/validate-orchestrator-output.ps1` and the six orchestrator-family test files edited in [P3-T5] to [P3-T10]. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/line-counts-phase3.<ts>.md`. Acceptance: the printed line `LINECOUNT-SUMMARY OverLimitCount=0`.
- [ ] [P3-T13] Commit and push Phase 3 (rule 9): `.claude/hooks/validate-orchestrator-output.ps1`, the six test files of [P3-T5] to [P3-T10], and the feature-folder evidence. Append the push fields to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase3.<ts>.md`. Acceptance: `PUSH_EXIT_CODE: 0` and `AHEAD_AFTER_PUSH: 0`.

### Phase 4 — Executor, Planner, and Required-Artifact Envelope Conversion

- [ ] [P4-T1] In `.claude/hooks/validate-executor-output.ps1` (line numbers are the pre-edit values), insert literal L3 immediately after `param()` (line 30), and insert literal L2 after `Set-StrictMode -Version Latest` (line 32) and immediately before `$ErrorActionPreference = 'Stop'` (line 33). Acceptance: `rg -c -F "hook-dependency-guard.ps1') } catch" .claude/hooks/validate-executor-output.ps1` prints `1`, `rg -c -F "'subagentstop-envelope.ps1') } catch" .claude/hooks/validate-executor-output.ps1` prints `1`, and both lines precede `$ErrorActionPreference = 'Stop'`.
- [ ] [P4-T2] In `.claude/hooks/validate-executor-output.ps1`, apply the pure-entry seam change to `Invoke-ExecutorOutputValidation` (delete lines 185-199 and set `$agentOutput = $AssistantText`, keeping the "agent output is empty" block at lines 200-202). Acceptance: `rg -n "RawPayload|ConvertFrom-Json" .claude/hooks/validate-executor-output.ps1` returns no match.
- [ ] [P4-T3] Replace the tail of `.claude/hooks/validate-executor-output.ps1` (lines 290-296) with the Tail shape, using prefix `validate-executor-output:` and `Invoke-ExecutorOutputValidation -AssistantText $assistantText`. Acceptance: `rg -c "Read-SubagentStopEnvelope|Exit-SubagentStopBlock" .claude/hooks/validate-executor-output.ps1` prints `2` and `rg -n "\bexit 1\b|Write-Error" .claude/hooks/validate-executor-output.ps1` returns no match.
- [ ] [P4-T4] Update the help block of `.claude/hooks/validate-executor-output.ps1`: the `.DESCRIPTION` bullet "hook payload is valid JSON and contains non-empty output" (line 10) becomes "the SubagentStop envelope read from stdin carries a non-empty last_assistant_message"; `.NOTES` (lines 22-26) describes stdin, exit 2 through `Exit-SubagentStopBlock`, and the guarded loads. Acceptance: `rg -n "CLAUDE_HOOK_INPUT|exits 1" .claude/hooks/validate-executor-output.ps1` returns no match.
- [ ] [P4-T5] In `.claude/hooks/validate-executor-output.ps1`, replace the command-evidence line (line 265) with literal L6. Acceptance: `rg -n "poetry run" .claude/hooks/validate-executor-output.ps1` returns no match and `rg -c -F "poetry[ ]run " .claude/hooks/validate-executor-output.ps1` prints `1`.
- [ ] [P4-T6] In `.claude/hooks/validate-planner-output.ps1`, insert literal L2 after `Set-StrictMode -Version Latest` (line 35) and before `$ErrorActionPreference = 'Stop'` (line 36). Acceptance: `rg -c -F "'subagentstop-envelope.ps1') } catch" .claude/hooks/validate-planner-output.ps1` prints `1` and that line precedes `$ErrorActionPreference = 'Stop'`.
- [ ] [P4-T7] In `.claude/hooks/validate-planner-output.ps1`, apply the pure-entry seam change to `Invoke-PlannerOutputValidation` (delete lines 356-370, keep the dependency-decision check at lines 353-354 first, set `$agentOutput = $AssistantText`, keep the "agent output is empty" block). Do not change `Get-PlannerInternalReviewValidation` or any token that `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:96-144` asserts. Acceptance: `rg -n "RawPayload|ConvertFrom-Json" .claude/hooks/validate-planner-output.ps1` returns no match.
- [ ] [P4-T8] Replace the tail of `.claude/hooks/validate-planner-output.ps1` (lines 406-416) with the Tail shape, using prefix `validate-planner-output:` and `Invoke-PlannerOutputValidation -AssistantText $assistantText`. Acceptance: `rg -c "Read-SubagentStopEnvelope|Exit-SubagentStopBlock" .claude/hooks/validate-planner-output.ps1` prints `2` and `rg -n "\bexit 1\b|Write-Error" .claude/hooks/validate-planner-output.ps1` returns no match.
- [ ] [P4-T9] Update the help block of `.claude/hooks/validate-planner-output.ps1` (`.DESCRIPTION` line 12 and `.NOTES` lines 24-28) as in [P4-T4]. Acceptance: `rg -n "CLAUDE_HOOK_INPUT|exits 1" .claude/hooks/validate-planner-output.ps1` returns no match.
- [ ] [P4-T10] In `.claude/hooks/validate-required-artifact-output.ps1`, insert literal L3 immediately after the `param(...)` block (line 29), and literal L2 after `Set-StrictMode -Version Latest` (line 31) and before `$ErrorActionPreference = 'Stop'` (line 32). Acceptance: `rg -c -F "hook-dependency-guard.ps1') } catch" .claude/hooks/validate-required-artifact-output.ps1` prints `1`, `rg -c -F "'subagentstop-envelope.ps1') } catch" .claude/hooks/validate-required-artifact-output.ps1` prints `1`, and both precede `$ErrorActionPreference = 'Stop'`.
- [ ] [P4-T11] In `.claude/hooks/validate-required-artifact-output.ps1`, apply the pure-entry seam change to `Invoke-RequiredArtifactOutputValidation` (delete lines 101-115, set `$agentOutput = $AssistantText`, keep the "agent output is empty" block and the `-AgentName`/`-RequiredArtifact` parameters). Acceptance: `rg -n "RawPayload|ConvertFrom-Json" .claude/hooks/validate-required-artifact-output.ps1` returns no match.
- [ ] [P4-T12] Replace the tail of `.claude/hooks/validate-required-artifact-output.ps1` (lines 157-171) with the Tail shape, using prefix `validate-required-artifact-output:`, the missing-argument check through `Exit-SubagentStopBlock` (both former exit-1 paths now block with exit 2), and `Invoke-RequiredArtifactOutputValidation -AssistantText $assistantText -AgentName $AgentName -RequiredArtifact $RequiredArtifact`. Acceptance: `rg -c "Exit-SubagentStopBlock" .claude/hooks/validate-required-artifact-output.ps1` prints `2`, `rg -c "Read-SubagentStopEnvelope" .claude/hooks/validate-required-artifact-output.ps1` prints `1`, and `rg -n "\bexit 1\b|Write-Error" .claude/hooks/validate-required-artifact-output.ps1` returns no match.
- [ ] [P4-T13] Update the help block of `.claude/hooks/validate-required-artifact-output.ps1` (`.DESCRIPTION` lines 6-9 and `.NOTES` lines 17-21) as in [P4-T4]. Acceptance: `rg -n "CLAUDE_HOOK_INPUT|exits 1" .claude/hooks/validate-required-artifact-output.ps1` returns no match.
- [ ] [P4-T14] Convert `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1` to `-AssistantText` (the row at lines 14-19 becomes `X9 blocks when the assistant text is empty`, asserting `agent output is empty`) and add coverage rows: `X1 Get-PlanFileContent reports Exists = $false for a path that does not exist` (`Join-Path $PSScriptRoot 'no-such-plan-903.md'`); `X2 Get-PlanFileContent reports Exists = $true and lines for an existing file` (`$PSCommandPath`); `X3 Get-PlanFileContent normalizes null and scalar content to line arrays` (mock `Test-Path` true and `Get-Content` returning `$null`, then a scalar); `X4 blocks when the advertised plan does not exist`; `X5 blocks when the plan contains no task checkboxes`; `X6 reports only the first five unchecked lines when more than five remain` (asserts `(showing first 5)`); `X7 allows a preflight stop that carries the canonical blocked text and a plan delta`; `X8 blocks canonical preflight blocked text that carries no plan delta or task identifier`; `X10 Get-TouchedLanguagesFromPlan detects TypeScript, Python, and C# paths`; `X11 accepts poetry run command evidence` (a passing completion whose only command evidence is the text `poetry run pytest`). Acceptance: `rg -n "RawPayload|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/validate-executor-output.Tests.ps1` returns no match; the rows X1 to X11 exist; the file is at most 500 lines.
- [ ] [P4-T15] Convert `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` to `-AssistantText`: the rows at lines 31, 48, and 55 become `blocks when the assistant text is empty`, `blocks when the assistant text is whitespace`, and `blocks when the assistant text is null`, each asserting `agent output is empty`; every other `-RawPayload` argument carries its former `output` text. Keep the six fixture names pinned by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:146-153` unchanged. Acceptance: `rg -n "RawPayload|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` returns no match and `rg -c -F "duplicate inventory-ID fixture" tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` prints a count of at least 1.
- [ ] [P4-T16] Convert `tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1` to `-AssistantText` and add coverage rows: `R1 blocks when the assistant text is empty`; `R2 blocks with the spec error when a RequiredArtifact spec is malformed` (spec `no-pipes`; asserts `Expected format: token|regex|description`); `R3 blocks when the advertised artifact does not exist` (`Test-ArtifactFile` mocked `$false`; asserts `no file exists at that location`); `R4 accepts the markdown-link artifact form` (`[spec-path](docs/features/active/foo/spec.md)`); `R5 Test-ArtifactFile reports true for an existing file and false for a missing file` (`$PSCommandPath` and `Join-Path $PSScriptRoot 'no-such-artifact-903.md'`); `R6 reports every failing spec when several are required` (two specs, both missing; message lists both tokens). Acceptance: `rg -n "RawPayload|CLAUDE_HOOK_INPUT" tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1` returns no match; rows R1 to R6 exist; the file is at most 500 lines.
- [ ] [P4-T17] Family gate: run Appendix A1 with `-TestPath` set to `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1`, `tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1`, `tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1`, `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1`, and S-DEP-SUITES-2. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/regression-testing/family-pass-after.<ts>.md` (four schema fields; count lines and the passed-row lines quoted below). Acceptance: `EXIT_CODE: 0`, `FailedCount=0`, `FailedContainersCount=0`; passed (`[+]`) lines: six beginning `E-EXE-`, eight beginning `E-RA-`, five beginning `E-PLN-`, two beginning `REG-`; a passed B1 row containing `validate-planner-output.ps1` and `blocks naming subagentstop-envelope.ps1`; and a passed C8 row containing `validate-planner-output.ps1` (the planner gains its first non-guard edge, so C8 now generates a row for it).
- [ ] [P4-T18] Run Appendix A4 over `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-required-artifact-output.ps1`, and the three test files of [P4-T14] to [P4-T16]. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/line-counts-phase4.<ts>.md`. Acceptance: the printed line `LINECOUNT-SUMMARY OverLimitCount=0`.
- [ ] [P4-T19] Commit and push Phase 4 (rule 9): the three production files, the three test files of [P4-T14] to [P4-T16], and the feature-folder evidence. Append the push fields to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase4.<ts>.md`. Acceptance: `PUSH_EXIT_CODE: 0` and `AHEAD_AFTER_PUSH: 0`.

### Phase 5 — Bundled Mirrors and Pack Manifest

- [ ] [P5-T1] Copy S-PROD-6 to S-MIRROR-6 with Appendix A6 (`mirror-copy.ps1`, which uses `Copy-Item`), creating `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-routing.ps1`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/mirror-copy.<ts>.md` (four schema fields). Acceptance: the printed line `COPY-SUMMARY Count=6`.
- [ ] [P5-T2] Insert literal L7 into `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` on the line after the `".claude/hooks/validate-orchestrator-output-resolution.ps1",` entry and before the `".claude/hooks/validate-orchestrator-output.ps1",` entry. Acceptance: `rg -n "validate-orchestrator-output" extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` prints exactly three lines with consecutive line numbers, in the order `-resolution.ps1`, `-routing.ps1`, `.ps1`. JSON validity of the manifest is confirmed by [P5-T4] and [P5-T5], both of which parse it.
- [ ] [P5-T3] Mirror byte identity: run Appendix A5 (`mirror-hash-compare.ps1`) over S-PROD-6. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/mirror-hashes.<ts>.md` (four schema fields; six `HASH` lines). Acceptance: `EXIT_CODE: 0` and the printed line `HASH-SUMMARY PairCount=6 MismatchCount=0`.
- [ ] [P5-T4] Python regression: run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/pytest-regression.<ts>.md` (four schema fields; pytest's final summary line and every `FAILED` node ID). Acceptance: `EXIT_CODE: 0` with a final summary that reports passed tests and no failures. If the run fails and every failing node ID is in the [P0-T13] `Baseline Failed Set:` and is attributed to gitignored local state (issue #510), record `PRE_EXISTING_FAILURES:` with the node IDs, leave AC-19 unchecked, and report it to the caller for CI confirmation; any other failure is fixed and this task is re-run.
- [ ] [P5-T5] TypeScript manifest test: run `npm --prefix extensions/drm-copilot test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/jest-manifest.<ts>.md` (four schema fields; Jest's `Tests:` line). Acceptance: `EXIT_CODE: 0` and a `Tests:` line that reports passed tests and no failed tests.
- [ ] [P5-T6] Commit and push Phase 5 (rule 9): S-MIRROR-6, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and the feature-folder evidence. Append the push fields to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase5.<ts>.md`. Acceptance: `PUSH_EXIT_CODE: 0` and `AHEAD_AFTER_PUSH: 0`.

### Phase 6 — Static Acceptance Checks and Scope Boundary

Each search in this phase runs over S-PROD-6 written out in full as `.claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1 .claude/hooks/validate-orchestrator-output-resolution.ps1 .claude/hooks/validate-executor-output.ps1 .claude/hooks/validate-planner-output.ps1 .claude/hooks/validate-required-artifact-output.ps1` (written below as `<S-PROD-6>`; the executor substitutes the six paths verbatim). Each artifact records the exact command, `EXIT_CODE:`, `ExpectedExitCode:` where non-zero, and the match lines.

- [ ] [P6-T1] AC-7: run `rg -n "CLAUDE_HOOK_INPUT" <S-PROD-6>`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac7-claude-hook-input.<ts>.md`. Acceptance: `EXIT_CODE: 1`, `ExpectedExitCode: 1`, no match lines.
- [ ] [P6-T2] AC-8: run `rg -n -e '\$payload\.output' -e "Properties\.Name -contains 'output'" -e "Properties\['output'\]" <S-PROD-6>` (the first pattern is single-quoted so `rg` receives the escaped `\$`; under double quotes the shell would reduce it to an end-of-line anchor and the search could never match). Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac8-output-reads.<ts>.md`. Acceptance: `EXIT_CODE: 1`, `ExpectedExitCode: 1`, no match lines.
- [ ] [P6-T3] AC-9: run `rg -n "\bexit 1\b|Write-Error" <S-PROD-6>`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac9-exit1-write-error.<ts>.md`. Acceptance: `EXIT_CODE: 1`, `ExpectedExitCode: 1`, no match lines.
- [ ] [P6-T4] AC-13: run `rg -n "One subprocess call" .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1` and `rg -n -F "in-process validation (issue #475)" .claude/hooks/validate-orchestrator-output.ps1`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac13-cr7-comment.<ts>.md`. Acceptance: the first search has `EXIT_CODE: 1` with no match lines; the second has `EXIT_CODE: 0` with exactly one match line inside a comment that also names the completion and model-routing checks.
- [ ] [P6-T5] AC-14: run `rg -n "OrchestratorState\.psm1'\)" .claude/hooks/validate-orchestrator-output.ps1`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac14-double-import.<ts>.md`. Acceptance: `EXIT_CODE: 0` and exactly one match line, which contains `-Global`.
- [ ] [P6-T6] AC-21: run `rg -n "(&\s*(python|py|poetry)\b|poetry run|Start-Process|ProcessStartInfo)" <S-PROD-6>`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac21-no-python.<ts>.md`. Acceptance: `EXIT_CODE: 1`, `ExpectedExitCode: 1`, no match lines.
- [ ] [P6-T7] AC-22: run `rg -n "stop_hook_active" <S-PROD-6>`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac22-stop-hook-active.<ts>.md`. Acceptance: `EXIT_CODE: 1`, `ExpectedExitCode: 1`, no match lines.
- [ ] [P6-T8] AC-16: run `rg -n "^function (Test-OrchestratorCheckpointStructure|Invoke-RoutingContractValidation)\b" .claude/hooks/validate-orchestrator-output-routing.ps1 .claude/hooks/validate-orchestrator-output.ps1` and `rg -n -F "Add-HookDependencyFailure -Name 'validate-orchestrator-output-routing.ps1'" .claude/hooks/validate-orchestrator-output.ps1`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac16-split.<ts>.md`. Acceptance: the first search prints exactly two lines, both in `.claude/hooks/validate-orchestrator-output-routing.ps1`; the second prints exactly one line.
- [ ] [P6-T9] AC-17: run `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` and `git status --porcelain`, then run Appendix A4 over every listed path that does not end in `.md`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/line-counts.<ts>.md` (four schema fields; both listings and every `LineCount=` line). Acceptance: `git status --porcelain` lists no path outside `docs/features/active/subagentstop-envelope-orchestrator-family-903/`; the diff listing contains every S-PROD-6, S-MIRROR-6, S-TEST-MOD-11, and S-TEST-NEW-4 path; and A4 prints `LINECOUNT-SUMMARY OverLimitCount=0`.
- [ ] [P6-T10] AC-20 and AC-23 scope boundary: run `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD`, `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .claude/agents`, and `git status --porcelain`. Classify every listed path as in S-ALLOW or out of S-ALLOW. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/scope-boundary.<ts>.md` with all three outputs, `OUT_OF_ALLOWLIST_COUNT:`, `AGENTS_DIFF_COUNT:`, and an explicit `FORBIDDEN_PATHS_FOUND:` line that checks for `.claude/settings.json`, `.claude/hooks/subagentstop-envelope.ps1`, `.claude/agents/prd-feature.md`, `.claude/hooks/validate-discovery-artifact-gate.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, any `.claude/hooks/enforce-*.ps1`, any path under `tests/scripts/codex-hooks/` or `.codex/`, and S-DEP-SUITES-2. Acceptance: `OUT_OF_ALLOWLIST_COUNT: 0`, `AGENTS_DIFF_COUNT: 0`, `FORBIDDEN_PATHS_FOUND: none`, and the porcelain output lists no path outside `docs/features/active/subagentstop-envelope-orchestrator-family-903/`.
- [ ] [P6-T11] Commit and push Phase 6 (rule 9): the feature-folder evidence only. Append the push fields to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase6.<ts>.md`. Acceptance: `PUSH_EXIT_CODE: 0` and `AHEAD_AFTER_PUSH: 0`.

### Phase 7 — Final QC Loop, Coverage Delta, and AC Check-Off

Loop rule: [P7-T1] to [P7-T5] form one pass. If any of them fails, or if a remediation changes any file, apply the fix (for format drift, Appendix A2b `ps-format-apply.ps1` over the drifting files; for findings or test failures, a targeted edit), record the reason in the loop record, and restart at [P7-T1]. A pass counts only when all five tasks succeed without any file changing during the pass. The per-command artifacts of the final clean pass are the ones checked off. If a remediation touches an S-PROD-6 file, re-run [P5-T1] and [P5-T3] before restarting, so the mirrors stay byte-identical.

- [ ] [P7-T1] Format check: run Appendix A2 over S-PS-QC-21. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/format-check.<ts>.md` (four schema fields; 21 `FORMAT file=` lines). Acceptance: `EXIT_CODE: 0` and the printed line `FORMAT-SUMMARY ChangedCount=0`. A2 is read-only, so a zero count is an observation of the tree, not of a rewrite.
- [ ] [P7-T2] Analyzer: run Appendix A3 over S-PS-QC-21. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/pssa.<ts>.md` (four schema fields). Acceptance: `EXIT_CODE: 0` and the printed line `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P7-T3] Pester with coverage (direct self-hosted run, not MCP): run Appendix A1 with `-TestPath` set to S-COV-SUITES-16, `-CoveragePath` set to S-PROD-6, `-CoverageOutputPath <SCRATCHPAD>/final-coverage.xml`, and `-ReportPath <SCRATCHPAD>/final-coverage-report.txt`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/pester-coverage.<ts>.md` (four schema fields; `Output Summary:` carries the four count lines and the six `COVERAGE file=... LinePercent=...` lines; `Post-Change Coverage:` lists the numeric LinePercent of each S-PROD-6 file; the full report is appended). Acceptance: `EXIT_CODE: 0`, `FailedCount=0`, `FailedContainersCount=0`, six `COVERAGE` lines, and every `LinePercent` is numeric and at least 85.
- [ ] [P7-T4] Full Pester: run Appendix A1 with `-TestPath tests/scripts/claude-hooks,tests/scripts/claude-runtime`. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/pester-full.<ts>.md` (four schema fields; count lines and every `FAILED:` line). Acceptance: `EXIT_CODE: 0`, `FailedCount=0`, `FailedContainersCount=0`. If failures remain, every failing row is in the [P0-T12] `Baseline Failed Set:`, and no failing row is in an S-TEST-MOD-11, S-TEST-NEW-4, or S-DEP-SUITES-2 file, record `PRE_EXISTING_FAILURES:` with the rows, leave AC-24 unchecked, and report it to the caller; otherwise fix and restart the loop.
- [ ] [P7-T5] Named-row confirmation: run Appendix A1 with `-TestPath` set to `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`, `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1`, `tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1`, `tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1`, and S-DEP-SUITES-2. Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/named-rows.<ts>.md` (four schema fields; the passed-row lines quoted below). Acceptance: `EXIT_CODE: 0`, `FailedCount=0`, `FailedContainersCount=0`; passed (`[+]`) lines for the AST row `invokes no python, python3, py, or poetry command anywhere in the default invoker`, `H7`, `H8`, `E-EXE-5`, and `E-RA-7`; two passed B1 rows containing `blocks naming subagentstop-envelope.ps1` (one naming `validate-orchestrator-output.ps1`, one naming `validate-planner-output.ps1`); and one passed B1 row containing `blocks naming validate-orchestrator-output-routing.ps1`.
- [ ] [P7-T6] Write the loop record `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/final-qc-loop.<ts>.md` with `Timestamp:`, `PASS_COUNT:`, one `PASS <n>:` line per pass naming each of [P7-T1] to [P7-T5] with its exit code and any remediation and restart reason, and `FINAL_CLEAN_PASS: <n>` naming the five artifacts of that pass. Acceptance: the final pass lists five successful tasks and records no file change during that pass.
- [ ] [P7-T7] Coverage delta: run Appendix A9 (`changed-line-coverage.ps1 -ReportPath <SCRATCHPAD>/final-coverage-report.txt -BaseRef origin/epic/subagentstop-envelope-integration -Path <S-PROD-6>`). Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/coverage-delta.<ts>.md` with one row per S-PROD-6 file: baseline LinePercent from [P0-T11] (`NEW FILE` for the routing sibling), post-change LinePercent from [P7-T3], the threshold 85, `ChangedLinePercent` from A9, and `Result: PASS` or `FAIL`. Acceptance: six rows; each post-change LinePercent is numeric and at least 85; each `ChangedLinePercent` is numeric and at least 85, or is `NA` recorded as `NA (no executable changed lines)`; and `Result: PASS` on every row.
- [ ] [P7-T8] AC check-off in `docs/features/active/subagentstop-envelope-orchestrator-family-903/spec.md`: for each of AC-1 to AC-24, change its checkbox to checked only when every evidence artifact in the Acceptance Criteria Map exists and meets its acceptance. An AC with a recorded `PRE_EXISTING_FAILURES:` exception stays unchecked. Record the outcome in `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/ac-checkoff.<ts>.md` with `CHECKED:` and `UNCHECKED:` ID lists and, for each unchecked ID, its reason. Acceptance: counting the lines under `## Acceptance Criteria` in `spec.md`, the checked count equals the `CHECKED:` list length, the unchecked count equals the `UNCHECKED:` list length, and the two total 24.
- [ ] [P7-T9] Write `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/pr-linkage-notes.<ts>.md` for `epic-orchestrator`: the PR base is `epic/subagentstop-envelope-integration`; the PR body uses `Refs #903` and `Refs #897` and no closing keyword (spec Rollout, epic Issue Closure); pull-request authoring and CI monitoring are executed by `epic-orchestrator`, not by this plan's executor; and the open follow-ups recorded in spec Rollout (frontmatter `SubagentStop` firing question, the duplicate `-RequiredArtifact` at `.claude/agents/prd-feature.md:18`, the #786 PreToolUse conditional, and the Codex `SilentlyContinue` nit). Acceptance: the file contains `Refs #903` and `Refs #897` and contains no `Closes`, `Fixes`, or `Resolves` token.
- [ ] [P7-T10] Final commit and push (rule 9): `docs/features/active/subagentstop-envelope-orchestrator-family-903/spec.md`, the feature-folder evidence, and any file changed by a loop remediation (each must be in S-ALLOW). Append the push fields to `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase7.<ts>.md`, then commit and push that appended artifact in one follow-up docs-only commit and report the second push's exit code in the executor's return message. Acceptance: both pushes report exit 0 and `git rev-list --count origin/bug/subagentstop-envelope-orchestrator-family-903..HEAD` prints `0` after the second push.

## Appendix A — Scratch Scripts

Saved verbatim under `<SCRATCHPAD>/` by [P0-T7]. They are throwaway session scripts and are never committed. Every result line is printed by an unconditional `Write-Output`, so it appears on a successful run.

A0 `run-ps.sh`:

```sh
#!/bin/sh
exec pwsh -NoProfile -NonInteractive -File "$@"
```

A1 `pester-run.ps1`:

```powershell
param(
    [Parameter(Mandatory)][string[]] $TestPath,
    [string[]] $CoveragePath = @(),
    [string] $CoverageOutputPath = '',
    [string] $ReportPath = ''
)
$TestPath = @($TestPath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$CoveragePath = @($CoveragePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
if ($CoveragePath.Count -gt 0 -and -not $CoverageOutputPath) { throw 'CoverageOutputPath is required when CoveragePath is supplied.' }
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
if ($CoveragePath.Count -gt 0) {
    $configuration.CodeCoverage.Enabled = $true
    $configuration.CodeCoverage.Path = $CoveragePath
    $configuration.CodeCoverage.OutputPath = $CoverageOutputPath
}
$result = Invoke-Pester -Configuration $configuration
$report = [System.Collections.Generic.List[string]]::new()
$report.Add("TotalCount=$($result.TotalCount)")
$report.Add("PassedCount=$($result.PassedCount)")
$report.Add("FailedCount=$($result.FailedCount)")
$report.Add("FailedContainersCount=$($result.FailedContainersCount)")
foreach ($failedTest in $result.Failed) { $report.Add("FAILED: $($failedTest.ExpandedPath)") }
foreach ($failedContainer in $result.FailedContainers) { $report.Add("FAILED-CONTAINER: $($failedContainer.Item)") }
if ($CoveragePath.Count -gt 0) {
    $executed = @($result.CodeCoverage.CommandsExecuted)
    $missed = @($result.CodeCoverage.CommandsMissed)
    foreach ($file in $CoveragePath) {
        $fullPath = (Resolve-Path -LiteralPath $file).Path
        $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
        $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique | Where-Object { $hitLines -notcontains $_ })
        $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
        $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
        $report.Add("COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent")
        $report.Add("HIT file=$file Lines=$($hitLines -join ',')")
        $report.Add("MISSED file=$file Lines=$($missLines -join ',')")
    }
}
$report | Write-Output
if ($ReportPath) { $report | Set-Content -LiteralPath $ReportPath -Encoding UTF8 }
if ($result.FailedCount -gt 0 -or $result.FailedContainersCount -gt 0) { exit 1 }
exit 0
```

A2 `ps-format-check.ps1` (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    Write-Output "FORMAT file=$file Changed=$changed"
}
Write-Output "FORMAT-SUMMARY ChangedCount=$changedCount"
if ($changedCount -gt 0) { exit 1 }
exit 0
```

A2b `ps-format-apply.ps1` (write mode; used only by the Phase 7 loop rule):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$encoding = [System.Text.UTF8Encoding]::new($false)
$appliedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    if ($formatted -cne $original) {
        [System.IO.File]::WriteAllText((Resolve-Path -LiteralPath $file).Path, $formatted, $encoding)
        $appliedCount++
        Write-Output "FORMAT-APPLIED file=$file"
    }
}
Write-Output "FORMAT-APPLY-SUMMARY AppliedCount=$appliedCount"
```

A3 `pssa-count.ps1`:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$records = @(foreach ($file in $Path) { Invoke-ScriptAnalyzer -Path $file -Settings $settings })
foreach ($record in $records) { Write-Output "PSSA $($record.ScriptName):$($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "PSSA-SUMMARY DiagnosticCount=$($records.Count)"
if ($records.Count -gt 0) { exit 1 }
exit 0
```

A4 `line-counts.ps1`:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$overLimit = 0
foreach ($file in $Path) {
    $count = (Get-Content -LiteralPath $file).Count
    if ($count -gt 500) { $overLimit++ }
    Write-Output "$file LineCount=$count"
}
Write-Output "LINECOUNT-SUMMARY OverLimitCount=$overLimit"
if ($overLimit -gt 0) { exit 1 }
exit 0
```

A5 `mirror-hash-compare.ps1`:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $SourcePath)
$SourcePath = @($SourcePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$mirrorRoot = 'extensions/drm-copilot/resources/claude-customizations'
$mismatch = 0
foreach ($source in $SourcePath) {
    $mirror = Join-Path $mirrorRoot $source
    $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $mirrorHash = if (Test-Path -LiteralPath $mirror -PathType Leaf) { (Get-FileHash -LiteralPath $mirror -Algorithm SHA256).Hash } else { 'MISSING' }
    $match = $sourceHash -eq $mirrorHash
    if (-not $match) { $mismatch++ }
    Write-Output "HASH source=$source SourceHash=$sourceHash MirrorHash=$mirrorHash Match=$match"
}
Write-Output "HASH-SUMMARY PairCount=$($SourcePath.Count) MismatchCount=$mismatch"
if ($mismatch -gt 0) { exit 1 }
exit 0
```

A6 `mirror-copy.ps1`:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $SourcePath)
$SourcePath = @($SourcePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$mirrorRoot = 'extensions/drm-copilot/resources/claude-customizations'
foreach ($source in $SourcePath) {
    $mirror = Join-Path $mirrorRoot $source
    Copy-Item -LiteralPath $source -Destination $mirror -Force
    Write-Output "COPIED source=$source mirror=$mirror"
}
Write-Output "COPY-SUMMARY Count=$($SourcePath.Count)"
```

A7 `function-text-compare.ps1`:

```powershell
param([Parameter(Mandatory)][string] $OldPath, [Parameter(Mandatory)][string] $NewPath, [Parameter(Mandatory)][string[]] $Name)
$Name = @($Name | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
function Get-FunctionText([string] $Path, [string] $FunctionName) {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $Path).Path, [ref]$null, [ref]$null)
    $found = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $FunctionName }, $true))
    if ($found.Count -ne 1) { return $null }
    return $found[0].Extent.Text
}
$mismatch = 0
foreach ($functionName in $Name) {
    $old = Get-FunctionText -Path $OldPath -FunctionName $functionName
    $new = Get-FunctionText -Path $NewPath -FunctionName $functionName
    $match = ($null -ne $old) -and ($old -ceq $new)
    if (-not $match) { $mismatch++ }
    Write-Output "FUNCTION-TEXT name=$functionName Match=$match"
}
Write-Output "FUNCTION-TEXT-SUMMARY MismatchCount=$mismatch"
if ($mismatch -gt 0) { exit 1 }
exit 0
```

A8 is intentionally unused (the batch-budget observation in [P0-T8] is a direct file read).

A9 `changed-line-coverage.ps1`:

```powershell
param([Parameter(Mandatory)][string] $ReportPath, [Parameter(Mandatory)][string] $BaseRef, [Parameter(Mandatory)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$report = @(Get-Content -LiteralPath $ReportPath)
foreach ($file in $Path) {
    $added = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($line in @(git diff -U0 "$BaseRef...HEAD" -- $file)) {
        if ($line -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@') {
            $start = [int]$Matches[1]
            $length = if ($Matches[2]) { [int]$Matches[2] } else { 1 }
            for ($offset = 0; $offset -lt $length; $offset++) { [void]$added.Add($start + $offset) }
        }
    }
    $hitText = (($report | Where-Object { $_ -like "HIT file=$file Lines=*" }) -replace '^HIT file=\S+ Lines=', '')
    $missText = (($report | Where-Object { $_ -like "MISSED file=$file Lines=*" }) -replace '^MISSED file=\S+ Lines=', '')
    $hit = @(([string]$hitText -split ',') | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $miss = @(([string]$missText -split ',') | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $changedHit = @($hit | Where-Object { $added.Contains($_) }).Count
    $changedMiss = @($miss | Where-Object { $added.Contains($_) }).Count
    $changedExecutable = $changedHit + $changedMiss
    $percent = if ($changedExecutable -eq 0) { 'NA' } else { [math]::Round(100 * $changedHit / $changedExecutable, 2) }
    Write-Output "CHANGED-COVERAGE file=$file AddedLines=$($added.Count) ChangedExecutable=$changedExecutable ChangedHit=$changedHit ChangedLinePercent=$percent"
}
```

A `ChangedLinePercent=NA` (a file whose changed lines are all non-executable, such as comment-only changes) counts as meeting the changed-line threshold in [P7-T7] and is recorded as `NA (no executable changed lines)`.
