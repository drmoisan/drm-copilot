# subagentstop-envelope-artifact-gates (Spec)

- **Issue:** #897
- **Parent (optional):** epic subagentstop-envelope (epic issue #904), child E3
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T12-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; `user-story.md` is intentionally absent)
- **Complexity:** C3
- **Branch:** `bug/subagentstop-envelope-artifact-gates-897` (based on `origin/epic/subagentstop-envelope-integration`)
- **Authoritative research:** `docs/features/active/subagentstop-envelope-artifact-gates-897/research/2026-10-11T12-05-subagentstop-envelope-artifact-gates-research.md` (cited below as "research §N")

## Context
- Summary of the bug and its impact: the SubagentStop validators `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1` and `validate-task-researcher-output.ps1` under `.claude/hooks/` read `$env:CLAUDE_HOOK_INPUT`, take an `output` property off the parsed root, and block with exit code 1 (`issue.md:44-51`; line citations re-derived and confirmed in research §2). The documented SubagentStop envelope arrives as JSON on stdin and carries `last_assistant_message`, not `output`; `CLAUDE_HOOK_INPUT` is not set; and for SubagentStop only exit code 2 blocks. The validators therefore fail open: they receive no input and their block exit code is ignored by the runtime.
- Observed environment(s): Windows 11 Pro, PowerShell 7.x, Claude Code 2.1.296 (E1 live differential, research §1.2).
- Customer impact and severity: High. These are completion gates for the pr-author, prd-feature, task-researcher and discovery agents. While inert, an agent can report completion without the artifact that proves it (PR reference, `spec-path`, `research-path`, or a valid `discovery/<type>` artifact).
- First observed date and version(s) impacted: recorded in the potential entry `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md` (2026-08-21); re-confirmed against main at `2ef8d361` in the issue #897 update dated 2026-10-11. All versions of these four hooks to date are affected.

## Repro & Evidence
- Steps to reproduce (`issue.md:31-36`):
  1. Pick one of the four E3 validators.
  2. Invoke it with the documented SubagentStop envelope on stdin, whose root carries `hook_event_name` set to the SubagentStop event and `last_assistant_message` set to text lacking the required completion artifact.
  3. Invoke it again with `CLAUDE_HOOK_INPUT` set to a root object carrying `output`.
  4. Compare the two decisions and exit codes.
- Expected vs actual behavior:
  - Expected: step 2 blocks with exit code 2 and writes the block reason to stderr. After the fix only the documented stdin envelope is read; step 3 input is ignored.
  - Actual: each validator ignores stdin, reads `.output` from `CLAUDE_HOOK_INPUT`, and blocks with `exit 1` (or, under `$ErrorActionPreference = 'Stop'`, through a terminating `Write-Error` that also yields exit 1). Exit 1 does not block a SubagentStop event.
- Logs/screenshots/error snippets (E1 live differential, `evidence/other/subagentstop-live-differential.2026-10-11T12-01.md` in the E1 worktree, summarized in research §1.2):
  - Payload arrived as JSON on stdin; `CLAUDE_HOOK_INPUT` was not set in any invocation.
  - Root carried `last_assistant_message`; no `output` key.
  - Exit 1 did not block; exit 2 blocked and the subagent was re-invoked with `stop_hook_active: true`.
- Current per-file sites (research §2):

  | File | Reads `.output` | Passes `$env:CLAUDE_HOOK_INPUT` | Validation block tail |
  |---|---|---|---|
  | `validate-discovery-artifact-gate.ps1` | `:223-224` | `:258` | `Write-Error` `:260`, `exit 1` `:261` |
  | `validate-pr-author-output.ps1` | `:109` | `:135` | `Write-Error` `:138`, `exit 1` `:139` |
  | `validate-prd-feature-output.ps1` | `:80` | `:95` | `Write-Error; exit 1` `:96` (terminating under `:11`) |
  | `validate-task-researcher-output.ps1` | `:245-246` | `:288` | `Write-Error` `:290` (terminating under `:24`), `exit 1` `:291` |

- Frequency / determinism: always. The defect is in the transport and exit code, not data-dependent.

## Scope & Non-Goals
- In scope:
  - Convert `.claude/hooks/validate-discovery-artifact-gate.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/validate-prd-feature-output.ps1` (registered at `.claude/agents/prd-feature.md:20`) and `.claude/hooks/validate-task-researcher-output.ps1` to the E1 helper: read the stdin envelope via `Read-SubagentStopEnvelope`, inspect `last_assistant_message` instead of `.output`, and block via `Exit-SubagentStopBlock` (stderr plus exit 2) on every block path.
  - Remove every `CLAUDE_HOOK_INPUT` read and literal (code, help text, messages) from these four files.
  - Move test seams to parameters on each validator's pure entry function; no environment-variable seams.
  - Add the #786 dependency-guard pattern (bootstrap, guarded edge, three-statement tail, leading dependency-decision statement) to `validate-task-researcher-output.ps1`, which lacks it (research §2.4, §6.2 item 4), so that a helper load failure blocks with exit 2.
  - Update every Pester suite for these four hooks: `validate-discovery-artifact-gate.Tests.ps1`, `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1`, `validate-pr-author-output.Tests.ps1`, `validate-pr-author-output.Coverage.Tests.ps1`, `validate-prd-feature-output.Tests.ps1`, `validate-prd-feature-output.Coverage.Tests.ps1`, `validate-task-researcher-output.Tests.ps1`, all under `tests/scripts/claude-hooks/`; and add `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` for the task-researcher entry point (research §3, §6.3).
  - Copy each changed hook byte-for-byte into its bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. No test mirrors exist under `extensions/drm-copilot/resources/` (research §3), so none are created.
  - Check the agent frontmatter registrations (`.claude/agents/pr-author.md:23-27`, `.claude/agents/prd-feature.md:13-20`, `.claude/agents/task-researcher.md:14-19`). No change is expected because `pwsh -NoProfile -File <path>` passes stdin to the script (research §4.1).
- Out of scope / non-goals:
  - E1 files: `.claude/hooks/subagentstop-envelope.ps1`, its mirror and tests; `.claude/settings.json` and its bundled copy; pack manifests (research §7).
  - E2 files: `validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`, their suites, and their mirrors.
  - E4 files: `validate-feature-review-coverage.ps1`, `feature-review-coverage-thresholds.ps1`, the feature-review skills, `.codex/agents/feature-review.toml`, and their mirrors.
  - Any new validation rule beyond the transport, shape and exit-code change (epic Non-Goals, `epic.md:72-73`). This includes the task-researcher filename rule (see Risks).
  - PreToolUse hooks (converted by #501).
  - Shared test infrastructure owned by E1: `tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1`, `HookDependencyGraph.Helpers.ps1`, `HookImportFailureExemptions.Helpers.ps1`; any SubagentStop source-scanning guard analogous to #501's (research §7).
  - Deduplicating the double registration of pr-author and prd-feature (settings plus frontmatter); E1 owns settings (research §4.1, §9 item 8).
- Explicitly excluded systems, integrations, or datasets: Codex runtime (`.codex/` holds no equivalents of these four hooks, research §4.1); Python hooks or Python legs in any enforcement hook.

## Root Cause Analysis
- Confirmed root cause: the validators were written against an undocumented envelope. They read `$env:CLAUDE_HOOK_INPUT` (not provided for SubagentStop), parse an `output` field (the documented field is `last_assistant_message`), and block with exit 1 (only exit 2 blocks SubagentStop).
- Signals/evidence supporting it:
  - E1 live differential (research §1.2): stdin JSON, no `CLAUDE_HOOK_INPUT`, `last_assistant_message` present, `output` absent, exit 1 non-blocking, exit 2 blocking.
  - PR #881 (#786) established exit 2 as the SubagentStop block code and left the exit-1 validation paths unchanged (research §5.2).
  - Pester suites pin the defective behavior: `validate-discovery-artifact-gate.Tests.ps1:165` and `validate-pr-author-output.Tests.ps1:110`, `:121` assert `$LASTEXITCODE | Should -Be 1`; `validate-pr-author-output.Coverage.Tests.ps1:43` asserts `ExitCode | Should -Be 1`; `validate-prd-feature-output.Coverage.Tests.ps1:43-44` asserts a thrown `CLAUDE_HOOK_INPUT is empty` error (research §3).
- Affected components/modules: the four hook files and their mirrors; the Pester suites listed in Scope; registration-driven suites B1 (`hook-dependency-failure.Claude.Tests.ps1`), C8 (`hook-dependency-failure.SpecialCases.Tests.ps1`) and S1/S2/S3/S6 (`hook-dependency-guard-completeness.Tests.ps1`), which pick up the new helper edge automatically (research §3).
- Contributing latent defects (research §2.3-§2.5):
  - In `validate-prd-feature-output.ps1` and `validate-task-researcher-output.ps1`, `$ErrorActionPreference = 'Stop'` makes `Write-Error` terminating, so the `exit 1` line is unreachable and any `Get-Content` exception exits non-blocking.
  - The decision functions of the three guarded hooks return the guard's `{ ExitCode; Reason }` object where callers expect `Ok`/`allowed` and `Message`/`reason`; unreachable today because the script tail checks the dependency decision first.

## Proposed Fix

### Design summary (what changes where):
Research §6.1 candidate A. Each of the four hooks dot-sources the E1 helper `.claude/hooks/subagentstop-envelope.ps1` as a guarded dependency edge. Each pure entry function keeps its name and its leading dependency-decision statements, and takes the assistant text (or the parsed envelope, per E1's final contract) as a parameter instead of raw JSON. Each script tail becomes: guard bootstrap check (unchanged), dependency tail (unchanged), `Read-SubagentStopEnvelope`, pure call, then `Exit-SubagentStopBlock -Message <reason>` on block or `exit 0` on allow. Candidates B (inline stdin parsing) and C (reuse `Read-ClaudeHookRawPayload`, which falls back to `CLAUDE_HOOK_INPUT`) are rejected (research §6.1).

### Boundaries and invariants to preserve:
- The #786 guard shape: the bootstrap flag check writes via `[Console]::Error.WriteLine(` and contains a literal `exit 2`; each edge is in its own single-statement `try` whose catch calls `Add-HookDependencyFailure -Name '<leaf>'`; the SubagentStop tail contains `exit $dependencyDecision.ExitCode`; the decision function begins with the dependency-decision assignment and return (S1, S2, S6; research §3).
- Existing reason tokens and prefixes: `PR_AUTHOR_OUTPUT_MISSING`, `PR_AUTHOR_OUTPUT_MALFORMED`, `PR_AUTHOR_OUTPUT_EMPTY`, `PR_AUTHOR_OUTPUT_NO_PR`, `DISCOVERY_ARTIFACT_GATE_BLOCKED:`, and the `validate-<name>:` dependency prefixes in the B1/C8 prefix tables (research §6.2).
- Message strings pinned by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:60-93`: "narrow named-pattern", "repeats the primary search strategy or query expression", "count does not match its independently enumerated member set", "numeric acceptance criterion requires an existing research-path" (research §3).
- Discovery gate allow semantics: blank assistant text, no `discovery/<type>` references, or an absent required-artifact declaration all allow, because the hook runs for every agent under the broad matcher (`.claude/settings.json:214`; research §6.2 item 1, §9 item 7).
- Validation rules themselves (PR detection patterns, `spec-path`/`research-path` checks, numeric derivation evidence, research root and filename regex, Automation Feasibility check, discovery artifact validation) are unchanged.
- Block reasons go to stderr only; hooks write nothing to success or warning streams (#792 guard; research §8).
- No `Write-Error` on any block path (it terminates under `$ErrorActionPreference = 'Stop'` before an exit code is set).

### Dependencies or blocked work:
- **Upstream dependency (E1).** E1 (branch `bug/subagentstop-envelope-core-897`, folder hint `subagentstop-envelope-core-897`) must be merged into `origin/epic/subagentstop-envelope-integration` before execution begins. E1's merged spec is the authoritative contract for the helper: file `.claude/hooks/subagentstop-envelope.ps1`, functions `Read-SubagentStopEnvelope` and `Exit-SubagentStopBlock -Message <text>` (`epic.md:77-90`).
- **Upstream-merge check (first execution step).** Confirm the E1 merge on the integration branch, read E1's merged spec, and compare it with the planned contract in `epic.md:80-87` and research §1.3. If E1's merged spec differs from the epic.md planned contract (helper path, function names, parameters, return shape, anomaly handling, or `stop_hook_active` exposure), E1's spec governs and E3 execution stops at the upstream-merge check until this spec and the plan are reconciled.
- **Open question for E1 (research §9 item 2).** If `Read-SubagentStopEnvelope` gates the stdin read on `[Console]::IsInputRedirected`, as `Read-ClaudeHookRawPayload` does (`.claude/lib/hook-payload/HookPayload.psm1:183`, `:196-209`), then `[Console]::SetIn` does not change that flag and in-process entry-point tests would read nothing, losing coverage of each script tail. E1 must either expose a reader seam or document that `[Console]::SetIn` is honoured. The answer is recorded at the upstream-merge check before test planning is finalized.
- **Open question for E1 (research §9 item 3).** Behavior on re-entry with `stop_hook_active: true`. Default for E3: keep validating on re-entry; follow any loop guard E1 specifies.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `.claude/hooks/validate-discovery-artifact-gate.ps1` and mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1`
- `.claude/hooks/validate-pr-author-output.ps1` and mirror
- `.claude/hooks/validate-prd-feature-output.ps1` and mirror
- `.claude/hooks/validate-task-researcher-output.ps1` and mirror
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` (only if the dispatch seam signature changes; otherwise verified unchanged and passing)
- `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1`
- `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` (new)
- Agent frontmatter (`.claude/agents/pr-author.md`, `.claude/agents/prd-feature.md`, `.claude/agents/task-researcher.md`) and their bundled copies: checked only; edited only if the command form must change, which research §4.1 indicates it does not.

#### Functions/classes/CLI commands impacted:
- `Invoke-DiscoveryArtifactGateValidation`: `-RawPayload` replaced by an assistant-text parameter (for example `-AssistantMessage`); `-RequiredArtifactReader` kept. An injectable reader at the script entry point is permitted as a parameter seam so the end-to-end block case is reachable (research §6.3).
- `Get-PrAuthorOutputDecision`: `-HookInputRaw` replaced by an assistant-text parameter; help text (`:6-17`) updated to document stdin and exit 2.
- `Invoke-PrdFeatureOutputValidation`: `-RawPayload` replaced by an assistant-text parameter; `Get-Content` reads at `:84` and `:88` wrapped so a read exception becomes a block result.
- `Invoke-TaskResearcherOutputValidation`: `-RawPayload` replaced by an assistant-text parameter; gains a leading dependency-decision statement; the `Test-Path`/`Get-Content` re-check at `:274-275` wrapped so a read exception becomes a block result.
- Helper functions with no signature change: `Invoke-DiscoveryValidatorExe`, `Get-DiscoveryArtifactType`, `Get-RequiredDiscoveryArtifactDeclaration`, `Find-DiscoveryArtifactReference`, `Test-PrAuthorOutputReportsPr`, `Get-ArtifactPathFromOutput`, `Test-NumericDerivationEvidence` (both files), `Test-SpecNumericCriterion`, `Test-ResearchFile`, `Get-ResearchPathFromOutput`, `Test-IsUnderResearchRoot`, `Test-IsValidResearchFileName`, `Test-AutomationFeasibilitySection`.
- Consumed from E1: `Read-SubagentStopEnvelope`, `Exit-SubagentStopBlock -Message <text>`.

#### Data flow and validation changes:
- Before: `$env:CLAUDE_HOOK_INPUT` -> `ConvertFrom-Json` -> `.output` -> rules -> `Write-Error` + `exit 1`.
- After: stdin -> `Read-SubagentStopEnvelope` -> `last_assistant_message` -> rules -> `Exit-SubagentStopBlock -Message` (stderr, exit 2) or `exit 0`.
- Envelope-level anomalies (empty, absent or malformed stdin; missing `last_assistant_message`) follow E1's contract. Within each hook, blank or missing assistant text maps to the hook's existing empty-output result: discovery allows; pr-author blocks with `PR_AUTHOR_OUTPUT_EMPTY`; prd-feature blocks with "agent output is empty" wording updated to refer to the last assistant message; task-researcher blocks with its existing empty-output reason (research §6.2).
- An envelope carrying only `output`, or input supplied only through `CLAUDE_HOOK_INPUT`, does not satisfy any gate.

#### Error handling and logging updates:
- Every block path in the four files ends in `Exit-SubagentStopBlock -Message <reason>`; the dependency-guard paths keep their existing `[Console]::Error.WriteLine(...)` plus `exit 2` / `exit $dependencyDecision.ExitCode` form required by S1.
- No `exit 1` and no `Write-Error` on any block path in the four files.
- `validate-task-researcher-output.ps1` gains the guard bootstrap after `param()`, the guarded helper edge before `Set-StrictMode`, and the dependency tail, so a helper load failure exits 2 with the `validate-task-researcher-output:` prefix.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the E3 merge commit on the integration branch; mirrors revert with their sources because both are in the same commit set.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: SubagentStop envelope as JSON on stdin, root fields including `hook_event_name`, `last_assistant_message`, `agent_type`, `stop_hook_active` (E1 evidence). Exact parsed shape per E1's merged spec.
- Output on allow: no stdout or stderr content; exit 0.
- Output on block: reason on stderr; exit 2.

#### Required configuration keys and defaults:
- None added. Registrations remain `pwsh -NoProfile -File .claude/hooks/<hook>.ps1` (pinned by `claude-settings.Tests.ps1:107-154`, `test_claude_planning_integrity_contracts.py:169-262` and `enforce-pr-author-command-allowlist.Tests.ps1:97-120`).

#### Backward-compatibility expectations:
- `CLAUDE_HOOK_INPUT` is no longer read; any caller that relied on it receives no input. This is intended; the runtime never set it for SubagentStop.
- Pure entry functions change parameter names; the only in-repo callers are the hook tails and the Pester suites, all updated in this change.

#### Performance constraints (latency/throughput/memory):
- No new constraint. Reading stdin once replaces reading one environment variable; validation work is unchanged.

## Assumptions, Constraints, Dependencies
- Assumptions:
  - Frontmatter-registered hooks receive the same stdin envelope as settings-registered hooks (from documentation; not observed by E1, research §9 item 6).
  - Relative `spec-path`/`research-path` checks resolve against the hook process working directory; not verified for worktree-isolated subagents (research §9 item 5).
- Constraints:
  - No Python in enforcement hooks (`epic.md:14`; `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`).
  - No production or test file over 500 lines. Current maximum among E3 files is the task-researcher suite at 423 lines (research §8); new entry-point tests for that hook go in the new Coverage suite.
  - Line coverage >= 85% for each changed PowerShell file; Pester measures line coverage only and no exclusions are permitted. Recorded baselines (research §4.3): `validate-discovery-artifact-gate.ps1` 92.65% (63/68), `validate-pr-author-output.ps1` 100.00% (39/39), `validate-prd-feature-output.ps1` 98.15% (53/54), all from the #786 evidence dated 2026-10-10; `validate-task-researcher-output.ps1` 90.00% (90/100) from the #593 evidence dated 2026-08-29 (stale; refresh at Phase 0).
  - Bundled mirrors byte-identical to their sources (`epic.md:17`; `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`). Mirrors are synced by file copy; no sync script exists (research §4.2).
  - No temporary files in tests; stdin is fed with `[Console]::SetIn([System.IO.StringReader]::new($json))` and stderr captured with `[Console]::SetError(...)`, restored in `finally` (precedent `hook-dependency-failure.Claude.Tests.ps1:104-124`).
  - Commit and push at every phase boundary; never force-push.
  - `validate-pr-author-output.ps1` and `agents/pr-author.md` stay out of the pack manifests (pinned exception, research §4.2).
- External dependencies: E1 merged into `origin/epic/subagentstop-envelope-integration`; Claude Code SubagentStop runtime behavior as measured by E1.

## Data / API / Config Impact
- User-facing or API changes: the four completion gates begin blocking. Agents whose final message lacks the required artifact are refused with exit 2 and re-invoked by the runtime.
- Data or migration considerations: none.
- Logging/telemetry updates: block reasons are written to stderr by `Exit-SubagentStopBlock`; no other logging.
- Compatibility notes: registration commands unchanged; no settings, schema or CLI flag changes.

## Test Strategy
- Regression tests to add or update (research §6.3):
  - Pure-function tests: replace `@{ output = ... } | ConvertTo-Json` raw-payload fixtures with direct assistant-text arguments; remove raw-JSON empty/malformed cases from pure-function tests (envelope anomalies belong to E1's helper suite); add a blank-assistant-text case per hook.
  - Entry-point tests via stdin envelope, inverted from exit 1 to exit 2 following the #501 pattern:
    - `validate-discovery-artifact-gate.Tests.ps1:160-169`: stdin envelope whose `last_assistant_message` references an artifact that fails validation under an injected present declaration, asserting exit 2; if the reader cannot be injected at the entry point, assert exit 2 on the anomaly path E1 defines.
    - `validate-pr-author-output.Tests.ps1:105-125`: `Should -Be 2` for an envelope without a PR reference.
    - `validate-pr-author-output.Coverage.Tests.ps1:38-44`: `Should -Be 2`.
    - `validate-prd-feature-output.Coverage.Tests.ps1:38-45`: assert exit code 2 and a stderr reason instead of a thrown error.
    - New `validate-task-researcher-output.Coverage.Tests.ps1`: allow, block, `output`-only negative, and helper-load-failure cases.
  - Each changed suite keeps an exit-0 allow case and adds a negative case in which an envelope carrying only `output` (and no `last_assistant_message`) does not satisfy the gate.
  - Message assertions that pin `CLAUDE_HOOK_INPUT` text are updated: `validate-discovery-artifact-gate.Tests.ps1:80`, `:87`; `validate-prd-feature-output.Coverage.Tests.ps1:44`; `validate-task-researcher-output.Tests.ps1:48`, `:66`.
- Unit tests (Pester, not pytest; these are PowerShell hooks) for the fixed behavior and boundaries: as above. At most one subprocess case per hook (`$json | & $PwshExe -NoProfile -File $hook`) as the end-to-end exit-code check; all other entry-point cases run in process for coverage.
- Edge cases and negative scenarios: blank `last_assistant_message`; absent `last_assistant_message`; envelope carrying only `output`; `CLAUDE_HOOK_INPUT` set with stdin lacking the artifact (must still block); `stop_hook_active: true` re-entry per E1 contract; `Get-Content` read exceptions in prd-feature and task-researcher map to a block result.
- Error handling and logging verification: each block test asserts exit 2 and a non-empty stderr reason containing the hook's existing token or prefix; no test sets or relies on `CLAUDE_HOOK_INPUT` except to prove it is ignored.
- Coverage impact and targets: >= 85% line coverage per changed hook file, measured from the self-hosted PoshQC module (`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest ...`), parsing `artifacts/pester/powershell-coverage.xml` per file; the MCP runner is called for route compliance but returns no figures (research §4.3, §9 item 9). Evidence is written under `docs/features/active/subagentstop-envelope-artifact-gates-897/evidence/<kind>/`.
- Toolchain commands to run (format -> lint -> type-check -> test): PowerShell toolchain via the PoshQC route: `Invoke-Formatter` (format), PSScriptAnalyzer (lint), type check skipped for PowerShell, Pester (tests with coverage). Also run the registration-driven suites (`hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `claude-settings.Tests.ps1`, `enforce-pr-author-command-allowlist.Tests.ps1`) and the content and parity pytest checks (`test_claude_planning_integrity_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`).
- Manual validation steps: after E1 merges, one live smoke run per agent type (pr-author, prd-feature, task-researcher, one discovery agent) is recommended to confirm stdin delivery to frontmatter hooks and the working-directory assumption (research §9 items 5-6). This is recorded as follow-up evidence and is not a merge gate for E3.

## Acceptance Criteria
- [ ] Upstream-merge check passes: E1 is merged into `origin/epic/subagentstop-envelope-integration`, `.claude/hooks/subagentstop-envelope.ps1` defines `Read-SubagentStopEnvelope` and `Exit-SubagentStopBlock`, and E1's merged spec matches the contract this spec assumes (or this spec and the plan are reconciled to it before any hook is edited); the answer to the `[Console]::IsInputRedirected` in-process feeding question is recorded in the plan.
- [ ] `validate-discovery-artifact-gate.ps1` exits 2 with a `DISCOVERY_ARTIFACT_GATE_BLOCKED:` reason on stderr when the stdin envelope's `last_assistant_message` references a discovery artifact that fails validation under a present declaration (Pester: `validate-discovery-artifact-gate.Tests.ps1`, stdin-envelope block case).
- [ ] `validate-discovery-artifact-gate.ps1` exits 0 when `last_assistant_message` carries valid artifact references, carries no references, or the declaration is absent (Pester: `validate-discovery-artifact-gate.Tests.ps1`, stdin-envelope allow cases).
- [ ] `validate-pr-author-output.ps1` exits 2 with `PR_AUTHOR_OUTPUT_NO_PR` on stderr when `last_assistant_message` lacks a PR reference, and exits 0 when it carries one (Pester: `validate-pr-author-output.Tests.ps1` and `validate-pr-author-output.Coverage.Tests.ps1`).
- [ ] `validate-prd-feature-output.ps1` exits 2 with a stderr reason when `last_assistant_message` lacks an existing `spec-path`, and exits 0 when it carries an existing `spec-path` whose spec has no numeric acceptance criterion (Pester: `validate-prd-feature-output.Tests.ps1` and `validate-prd-feature-output.Coverage.Tests.ps1`).
- [ ] `validate-task-researcher-output.ps1` exits 2 with a stderr reason when `last_assistant_message` lacks a valid `research-path`, and exits 0 when it carries a valid one (Pester: new `validate-task-researcher-output.Coverage.Tests.ps1`).
- [ ] For each of the discovery, pr-author, prd-feature and task-researcher hooks, an envelope carrying the required artifact only in an `output` field, or input supplied only through `CLAUDE_HOOK_INPUT`, does not satisfy the gate (Pester: the `output`-only negative case in each hook's entry-point suite).
- [ ] Blank or absent `last_assistant_message` and empty or malformed stdin produce the outcome E1's merged contract defines for each hook (discovery allows on blank text; pr-author, prd-feature and task-researcher block with their existing empty-output reason), verified by a named Pester case per hook.
- [ ] `validate-task-researcher-output.ps1` carries the #786 guard bootstrap, guarded `subagentstop-envelope.ps1` edge, dependency tail and leading dependency-decision statement, and a helper load failure exits 2 with the `validate-task-researcher-output:` prefix (Pester: `validate-task-researcher-output.Coverage.Tests.ps1`, helper-load-failure case).
- [ ] No `CLAUDE_HOOK_INPUT` literal and no `.output` property read remain in the discovery, pr-author, prd-feature or task-researcher hook files or their mirrors (command: `Select-String -Path .claude/hooks/validate-discovery-artifact-gate.ps1,.claude/hooks/validate-pr-author-output.ps1,.claude/hooks/validate-prd-feature-output.ps1,.claude/hooks/validate-task-researcher-output.ps1 -Pattern 'CLAUDE_HOOK_INPUT','\.output\b'` returns no match; same command against the mirror paths).
- [ ] No `exit 1` and no `Write-Error` remain on any block path in those four hook files or their mirrors (command: `Select-String -Pattern '\bexit 1\b','Write-Error'` over the same paths returns no match).
- [ ] Exit-code assertions are inverted: `validate-discovery-artifact-gate.Tests.ps1`, `validate-pr-author-output.Tests.ps1` and `validate-pr-author-output.Coverage.Tests.ps1` contain no `Should -Be 1` exit-code assertion and assert exit 2 on their block cases, and `validate-prd-feature-output.Coverage.Tests.ps1` asserts exit 2 with a stderr reason instead of a thrown error (command: `Select-String -Path tests/scripts/claude-hooks/validate-*.Tests.ps1 -Pattern '(LASTEXITCODE|ExitCode)\s*\|\s*Should\s+-Be\s+1\b'` returns no match for the E3 suites; the suites pass).
- [ ] No E3 test sets `CLAUDE_HOOK_INPUT` except to prove it is ignored, and no E3 test creates a temporary file (code review of the changed suites; `Select-String -Pattern 'New-TemporaryFile','GetTempFileName','TestDrive'` over the changed suites returns no match).
- [ ] Message strings pinned by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` are preserved (command: `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` passes).
- [ ] Bundled hook mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` are byte-identical to their sources (command: `Get-FileHash` of each source and mirror pair matches, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes).
- [ ] Agent frontmatter registrations in `.claude/agents/pr-author.md`, `.claude/agents/prd-feature.md` and `.claude/agents/task-researcher.md` are verified unchanged, or changed in both source and bundled copy if the command form must change (command: `git diff --stat origin/epic/subagentstop-envelope-integration -- .claude/agents extensions/drm-copilot/resources/claude-customizations/.claude/agents`; `enforce-pr-author-command-allowlist.Tests.ps1` and `claude-settings.Tests.ps1` pass).
- [ ] Registration-driven guard suites pass with the new helper edge (Pester: `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`).
- [ ] Line coverage is at or above 85% for each changed hook file, measured per file from the self-hosted PoshQC coverage XML and recorded under `evidence/qa-gates/`.
- [ ] No changed or new production or test file exceeds 500 lines (command: `(Get-Content <file>).Count` for each changed file, recorded in evidence).
- [ ] Full PowerShell toolchain pass completed in a single pass: format (`Invoke-Formatter`), lint (PSScriptAnalyzer, zero findings), and Pester tests (all passing), recorded under `evidence/qa-gates/`.
- [ ] Out-of-scope files are untouched: `git diff --name-only origin/epic/subagentstop-envelope-integration` lists no E1 file (`.claude/settings.json`, its bundled copy, `.claude/hooks/subagentstop-envelope.ps1`, its mirror or tests, pack manifests), no E2 file (`validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1` or their suites and mirrors), no E4 file (`validate-feature-review-coverage.ps1`, `feature-review-coverage-thresholds.ps1`, feature-review skills, `.codex/agents/feature-review.toml` or their mirrors), and no shared helper under `tests/scripts/claude-runtime/`.
- [ ] The child pull request body references the issue with `Refs #897` and contains no closing keyword (`Closes`, `Fixes`, `Resolves`) for #897 (command: `gh pr view <number> --json body`).

## Risks & Mitigations
- Technical or operational risks:
  1. **E1 contract not final** (research §9 item 1). Helper signatures, return shape, anomaly handling and `stop_hook_active` exposure are not fixed at preparation time.
  2. **In-process stdin injection** (research §9 item 2). If the helper gates on `[Console]::IsInputRedirected`, `[Console]::SetIn` does not satisfy it and in-process tail coverage is lost.
  3. **`stop_hook_active` re-entry** (research §9 item 3). A blocked agent is re-invoked; repeated refusals are the enforcement but may loop without a guard.
  4. **Research filename convention versus orchestrator practice** (research §9 item 4). The task-researcher hook accepts only `<YYYY-MM-DDTHH-MM>-<name>-research.md` (`validate-task-researcher-output.ps1:95-98`), which matches the documented convention in `.claude/agents/task-researcher.md:30-33` and `.claude/skills/research-issue/SKILL.md:27-29`. Delegation prompts that supply `research.<timestamp>.md` names will be refused with exit 2 once the gate is live; more than sixty existing research files use that older form.
  5. **Working-directory dependence** of relative `spec-path`/`research-path` checks for worktree-isolated subagents (research §9 item 5).
  6. **Frontmatter hooks not measured** by E1's probe (research §9 item 6).
  7. **Discovery gate blast radius** under the broad matcher (research §9 item 7).
  8. **Double registration** of pr-author and prd-feature may produce duplicate refusals (research §9 item 8).
  9. **Coverage tooling** may not report new rows through the MCP runner (research §9 item 9); task-researcher baseline is stale (research §9 item 10).
  10. **Shared feature key** #897 with E1 (research §9 item 11; `epic.md:139-143`).
- Mitigations and rollbacks:
  1. Upstream-merge check as the first execution step; stop on mismatch until reconciled.
  2. Record E1's answer at the upstream-merge check; if `SetIn` is not honoured, use the reader seam E1 exposes as a parameter on the entry point, and keep one subprocess case per hook for the true exit code.
  3. Follow E1's loop guard; default is to keep validating on re-entry.
  4. Decision: E3 does not change the filename rule (epic non-goal, `epic.md:72-73`). Orchestrators must supply the documented name. This E3 research file was already renamed to the documented form. Recorded as a follow-up for the epic-level report, not E3 work.
  5-6. Recommend one live smoke run per agent type after E1 merges; record as follow-up evidence.
  7. Preserve the discovery gate's nothing-to-inspect allow paths; covered by the allow acceptance criterion.
  8. Leave to E1, which owns settings; record in the epic-level report.
  9. Measure coverage with the self-hosted module and per-file XML parsing; capture a fresh task-researcher baseline at Phase 0.
  10. Outside E3's control; tracked under epic Open Decisions.
  - Rollback: revert the E3 merge commit on the integration branch (sources and mirrors revert together).

## Rollout & Follow-up
- Release/rollout steps:
  - Execute only after the upstream-merge check passes. Commit and push at every phase boundary; never force-push.
  - Open the child pull request against `epic/subagentstop-envelope-integration`. The child PR uses `Refs #897`, not a closing keyword. Closing happens at the epic integration PR (epic issue #904), which closes #897 and #896 (`epic.md:132-137`).
  - CI on epic-child PRs may need a manual `ci.yml` dispatch because the workflow triggers on PRs into `main`/`development` only.
- Post-fix monitoring or clean-up tasks (epic-level report follow-ups, not E3 work):
  - Orchestrator delegation naming for research files must match the documented `<YYYY-MM-DDTHH-MM>-<name>-research.md` form; existing `research.<timestamp>.md` files are not renamed by E3.
  - Live smoke run per agent type for frontmatter-registered hooks and working-directory resolution.
  - Double registration of pr-author and prd-feature (E1 decision).
  - A SubagentStop source-scanning guard against `CLAUDE_HOOK_INPUT`, covering agent-frontmatter registrations, owned by a single child (preferably E1).
  - The latent `{ ExitCode; Reason }` versus `Ok`/`Message` shape mismatch in the decision functions remains unreachable while the tail checks the dependency decision first (research §2.5).
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/897
  - Epic: `docs/features/epics/subagentstop-envelope/epic.md` (epic issue #904)
  - Research: `docs/features/active/subagentstop-envelope-artifact-gates-897/research/2026-10-11T12-05-subagentstop-envelope-artifact-gates-research.md`
  - Upstream: E1 `docs/features/active/subagentstop-envelope-core-897/spec.md` (branch `bug/subagentstop-envelope-core-897`)
  - Precedents: #501 (`docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md`), #786 / PR #881 (`docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md`)
