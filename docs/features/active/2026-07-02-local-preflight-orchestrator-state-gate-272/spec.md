# local-preflight-orchestrator-state-gate (Spec)

- **Issue:** #272
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-02T18-07
- **Status:** Draft
- **Version:** 0.1

## Context
The CI-based orchestrator-state validation gate added in PR #201 (`.github/workflows/validate-orchestrator-state.yml` and `_validate-orchestrator-state.yml`) is non-functional and must be replaced with a locally-enforced pre-flight check that runs before `pr-author` creates or edits a PR, hardened by a `PreToolUse` hook so it cannot be bypassed by invoking `gh pr create` directly.

Environment:
- OS/version: Windows (Claude Code CLI runtime), PowerShell (`pwsh`) hooks
- Python version: repository `poetry` environment used by `scripts/dev_tools/validate_orchestration_artifacts`
- Command/flags used: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete`
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` (gitignored, per-worktree checkpoint)

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Note that `artifacts/` is listed in `.gitignore` (line 6), so `artifacts/orchestration/orchestrator-state.json` is never committed and is never present in a CI checkout.
2. Observe that `.github/workflows/validate-orchestrator-state.yml` invokes the validator with `require-checkpoint: false`, so on every CI run it prints "No orchestrator checkpoint found... validation skipped." and exits 0.
3. Run `gh api repos/:owner/:repo/rules/branches/main` and confirm the check name `Validate orchestrator checkpoint` was never added to the `main` branch ruleset's `required_status_checks`.

Expected:
The orchestrator-state checkpoint should be validated against `--require-complete` locally, immediately before any PR-creating action, and that validation should be impossible to bypass by invoking `gh pr create` / `gh pr edit --body*` directly.

Actual:
The CI gate is a no-op: it always skips validation (no checkpoint present in a CI checkout) and, even if it did fail, the check is not registered as a required status check on the `main` branch ruleset, so it could never block a merge.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: CI job log: "No orchestrator checkpoint found... validation skipped." (exit 0) on every run of `validate-orchestrator-state.yml`.


## Scope & Non-Goals
- In scope:
  1. Delete `.github/workflows/validate-orchestrator-state.yml` and `.github/workflows/_validate-orchestrator-state.yml`, and their bundled mirrors at `extensions/drm-copilot/resources/codex-and-agents-customizations/.github/workflows/validate-orchestrator-state.yml` and `.../_validate-orchestrator-state.yml` (workflow-only removal; no branch-ruleset changes). The bundled `_validate-orchestrator-state.yml` mirror is not byte-identical to the primary (it differs only in `actions/checkout`/`actions/setup-python` version pins — `v7`/`v6` primary vs `v4`/`v5` bundled); both copies must still be deleted together.
  2. Add a local pre-flight step, run by the orchestrator before delegating to `Agent(pr-author)`, that invokes the orchestrator-state validator against `artifacts/orchestration/orchestrator-state.json --require-complete` and records the pass/fail result and evidence in the checkpoint under a new `pr_author_preflight` field (alongside the existing `pr_author_receipt`).
  3. Extend `.claude/hooks/enforce-pr-author-skill.ps1` so the existing `gh pr create` / `gh pr edit --body*` PreToolUse hook also invokes the orchestrator-state validator (via the injectable `[scriptblock] $Invoker` seam already established in `.claude/hooks/validate-orchestrator-output.ps1`) and fails closed (blocks the call, following the hook's existing "always exit 0 / signal via JSON `permissionDecision`" contract) when the checkpoint is missing or fails `--require-complete`. Apply the identical byte-for-byte edit to the `.claude/` bundled mirror (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`), and apply the equivalent edit (preserving the 3-line `# Converted hook` header) to the Codex mirror (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`).
  4. Add documentation of the new local-preflight enforcement mechanism to `.claude/skills/orchestrate/SKILL.md` (`## PR Authoring (pr-author Handoff)`), `.claude/agents/orchestrator.md` (`## PR Creation Delegation`), and `.claude/agents/pr-author.md`. These edits are additive — none of the three documents currently make an incorrect CI-enforcement claim to correct (confirmed by research; see Root Cause Analysis). `CLAUDE.md`'s Architecture section may optionally gain one sentence noting the enforcement mechanism is a local `pwsh` PreToolUse hook.
  5. Negative-path and positive-path tests: extend `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (not a new file) to cover the new preflight check via a mocked `$Invoker` seam, plus an end-to-end `It` in the existing `'script entrypoint (end-to-end)'` context if the check is exercised via a real `pwsh` process.
- Out of scope / non-goals:
  - Branch-protection / ruleset changes (adding, removing, or re-registering any required status check on `main`, including `Validate orchestrator checkpoint`). The branch-ruleset content was independently confirmed via `gh api repos/drmoisan/drm-copilot/rules/branches/main`: `required_status_checks` contains 11 entries (`Code Quality & Tests (3.10/3.11/3.12/3.13)`, `Security Scanning`, `Build Package`, `PowerShell QC`, `Shell Coverage (Bats + kcov)`, `Documentation Validation`, `drm-copilot Extension Tests (ubuntu-latest/windows-latest)`) and none of them are `Validate orchestrator checkpoint` or `Orchestrator State Gate`. This fix does not add either name to that list.
  - `.gitignore` changes (the `artifacts` entry stays; the checkpoint remains intentionally local/per-worktree).
  - Committing `artifacts/orchestration/orchestrator-state.json` (or any checkpoint) to a tracked path.
  - Re-wiring `.codex/config.toml`'s `[[hooks.PreToolUse]]` list to reference `enforce-pr-author-skill.ps1`. The Codex mirror hook is currently an orphaned artifact (not wired into any Codex hook list); its body still receives the contract-parity edit in scope item 3 above, but making it actually execute in the Codex ecosystem is a pre-existing gap, not introduced by this fix, and is not addressed here.
  - Adding `quality-tiers.yml` at the repository root. It does not currently exist and its absence is a pre-existing, orthogonal gap unrelated to this bug.
- Explicitly excluded systems, integrations, or datasets: GitHub branch protection / rulesets API (read-only reference only), any third-party UI (Azure portal, Entra admin center, M365 admin center), Codex agent config wiring (`.codex/config.toml`, `.codex/agents/pr-author.toml`).

## Root Cause Analysis
- Root cause 1: `artifacts/` is gitignored, so the checkpoint the CI gate depends on is never present in a CI checkout by design (the checkpoint is intentionally local/per-worktree to avoid merge conflicts across concurrent `git worktree` orchestration sessions).
- Root cause 2: the check name was never wired into branch protection / ruleset required status checks.
- Related files: `.github/workflows/validate-orchestrator-state.yml`, `.github/workflows/_validate-orchestrator-state.yml`, their bundled mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/.github/workflows/`, `.claude/hooks/enforce-pr-author-skill.ps1` and its bundled mirrors, `.claude/skills/orchestrate/SKILL.md` ("## PR Authoring (pr-author Handoff)"), `.claude/agents/orchestrator.md`, `.claude/agents/pr-author.md`.


## Proposed Fix

### Design summary (what changes where):
Replace the non-functional CI gate with two complementary local enforcement points, both invoking the existing, unmodified Python validator (`scripts/dev_tools/validate_orchestration_artifacts orchestrator-state <path> --require-complete`):

1. **Hook-level hardening** (closes the bypass path): `enforce-pr-author-skill.ps1` gains a new ordered check — evaluated after Case C (context-artifact-present) and before or alongside the five existing receipt checks — that invokes the validator via an injectable `[scriptblock] $Invoker` seam and returns a new block reason (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED`) when the checkpoint is missing or fails `--require-complete`. This is the only change that actually prevents an actor from bypassing the gate by invoking `gh pr create`/`gh pr edit` directly, because it runs inside the same PreToolUse hook that already intercepts those commands.
2. **Orchestrator-recorded checkpoint field** (observability/audit trail): before delegating to `Agent(pr-author)`, the orchestrator itself invokes the same validator (via `mcp__drm-copilot__validate_orchestration_artifacts` or the equivalent CLI) and records the pass/fail result under a new `pr_author_preflight` field in `artifacts/orchestration/orchestrator-state.json`, alongside the existing `pr_author_receipt` field, per the checkpoint-shape convention already documented in `.claude/agents/orchestrator.md`.

The two CI workflow files and their bundled mirrors are deleted outright rather than repaired, because the root cause (the checkpoint file is intentionally gitignored and per-worktree, and therefore structurally cannot exist in a CI checkout) cannot be fixed by any CI-side change — see Root Cause Analysis.

### Boundaries and invariants to preserve:
- **Hook exit-code contract**: `enforce-pr-author-skill.ps1` (and both mirrors) must continue to `exit 0` unconditionally on the success path; allow/deny is signaled exclusively via the JSON payload's `hookSpecificOutput.permissionDecision` field (`allow`/`deny`). `exit 1` remains reserved for "the hook itself errored" (e.g., malformed `CLAUDE_TOOL_INPUT`), never for "policy denied." The new preflight check must follow this exact contract, not introduce a nonzero-exit denial path.
- **Byte-identical `.claude/` mirror invariant**: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) asserts literal string equality between `.claude/hooks/enforce-pr-author-skill.ps1` and its bundled copy at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`. Every edit to the primary hook must land identically, byte-for-byte, in that mirror in the same change.
- **Codex mirror header invariant**: the Codex mirror (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`) must retain its converter-generated 3-line `# Converted hook` / `# Review the generated hook behavior before enabling it.` / blank-line header, followed by a body byte-identical to the root hook's new body. Do not hand-edit this file to drop the header.
- **500-line file-size cap** (`.claude/rules/general-code-change.md`): `enforce-pr-author-skill.ps1` is currently 442 lines; the new check must keep the file under 500 lines. If the addition would exceed the cap, extract the new check's helper logic into a separate function within the same file first, and only split into a new file if that is insufficient (no evidence at this scope that it will be).
- **Existing hook ordering and short-circuit behavior**: Cases A, B, C and the five receipt checks must retain their existing order and reason codes; the new check is additive, not a reordering of existing logic, so existing Pester assertions on reason-code precedence remain valid.
- **`pr-author` agent tool allowlist**: `pr-author.md`'s `tools:` frontmatter grants only `Read`, `Bash(git log *)`, `Bash(git rev-parse *)`, `Bash(gh pr create *)`, `Bash(gh pr edit *)`, `Write(/artifacts/**)` — no general `Bash` grant. The preflight check must not require broadening this allowlist; it belongs entirely inside the PreToolUse hook (which runs as the harness, not as an agent-issued tool call) and/or inside the orchestrator's own tool grants, never inside the `pr-author` agent itself.
- **Injectable-seam pattern for Python subprocess invocation**: reuse the exact `[scriptblock] $Invoker` pattern already proven in `.claude/hooks/validate-orchestrator-output.ps1`'s `Invoke-RoutingContractValidation`, including its plain `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state $Path --require-complete` default invocation (not `poetry run python`) and its `[pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($output | Out-String) }` return shape. Do not invent a new invocation style.
- **No changes to the Python CLI surface**: `scripts/dev_tools/validate_orchestration_artifacts.py` and `scripts/dev_tools/validate_orchestrator_state.py` already fully support `orchestrator-state <path> --require-complete`; this fix consumes that CLI as-is and does not modify it.

### Dependencies or blocked work:
- None. All files in scope are repository-local and already exist; no new external dependency, service, or third-party UI is required (confirmed in research `## Automation Feasibility`).
- The item flagged as needing independent confirmation before this feature closes (branch-ruleset content) has now been independently confirmed via `gh api repos/drmoisan/drm-copilot/rules/branches/main`; no further human/`gh`-access step is required before implementation proceeds.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- Delete: `.github/workflows/validate-orchestrator-state.yml`, `.github/workflows/_validate-orchestrator-state.yml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.github/workflows/validate-orchestrator-state.yml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.github/workflows/_validate-orchestrator-state.yml`.
- Edit: `.claude/hooks/enforce-pr-author-skill.ps1` (add the preflight check, a new `Invoke-OrchestratorStatePreflight`-style helper function following the existing `$Invoker`-seam pattern, and a new block-decision reason).
- Edit (byte-identical): `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`.
- Edit (header-preserving): `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`.
- Edit: `.claude/skills/orchestrate/SKILL.md` (`## PR Authoring (pr-author Handoff)` — add the preflight step to the mandatory sequence and document `pr_author_preflight`).
- Edit: `.claude/agents/orchestrator.md` (`## PR Creation Delegation` — add preflight step and `pr_author_preflight` checkpoint field to the shape documentation).
- Edit: `.claude/agents/pr-author.md` (note the preflight precondition in the mandatory sequence description).
- Edit (optional): `CLAUDE.md` (Architecture section — one sentence noting local `pwsh` PreToolUse hook enforcement).
- Edit: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (extend with new `Context` blocks for the preflight check).

#### Functions/classes/CLI commands impacted:
- New PowerShell function in `enforce-pr-author-skill.ps1`: `Invoke-OrchestratorStatePreflight` (or equivalently named per PSScriptAnalyzer-approved-verb conventions), accepting a `[scriptblock] $Invoker` parameter with the default described above, returning a result object indicating pass/fail and the raw validator output text.
- Extended function: `Get-PrAuthorBypassReason` (or the equivalent top-level decision function) gains a call to the new preflight function and a new early-return branch producing the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` reason.
- No changes to `scripts/dev_tools/validate_orchestration_artifacts.py` or `scripts/dev_tools/validate_orchestrator_state.py` — the CLI is consumed, not modified.
- Orchestrator-side: no new CLI command; reuses `mcp__drm-copilot__validate_orchestration_artifacts` (or an equivalent local invocation of the same Python CLI) ahead of the existing `Agent(pr-author)` delegation step already documented in `orchestrate/SKILL.md`.

#### Data flow and validation changes:
- Hook path: `enforce-pr-author-skill.ps1` reads `CLAUDE_TOOL_INPUT` (unchanged) → matches `gh pr create`/`gh pr edit` (unchanged) → runs Cases A/B/C (unchanged) → **new**: invokes the orchestrator-state validator against `artifacts/orchestration/orchestrator-state.json --require-complete` via the `$Invoker` seam → if the checkpoint is missing or the validator reports errors, returns the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` deny decision before proceeding to the five receipt checks → otherwise continues into the existing receipt-verification flow unchanged.
- Orchestrator path: before invoking `Agent(pr-author)`, the orchestrator runs the same validator against the same checkpoint path and writes the result (pass/fail, timestamp, validator output summary) into `orchestrator-state.json` under `pr_author_preflight`, following the existing pattern used for `pr_author_receipt`.
- Both paths validate against the same file and the same CLI invocation shape; they are independent enforcement points reading the same source of truth, not a shared code path (the hook is `pwsh`; the orchestrator invocation may be MCP-tool-mediated or a direct CLI call).

#### Error handling and logging updates:
- The hook's new check must not throw on a missing checkpoint file; "file missing" is a validation failure (block), not a hook error. Only malformed `CLAUDE_TOOL_INPUT` JSON should propagate to the existing `try/catch` → `Write-Error $_; exit 1` path, unchanged from current behavior.
- The `$Invoker` scriptblock's default implementation must capture the validator's `stderr`/`stdout` (via `2>&1`) and `$LASTEXITCODE`, mirroring `Invoke-RoutingContractValidation`'s existing pattern, so the block reason can include the validator's error text for operator diagnosis.
- The orchestrator-side preflight result recorded in `pr_author_preflight` must include enough detail (pass/fail, timestamp, summarized validator output or error text) to support post-hoc audit without re-running the validator.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag is introduced. Rollback is a straightforward revert of the PR: restoring the two deleted workflow files (and mirrors) and reverting the hook/documentation edits. Because the deleted CI workflows were already fully non-functional (no-op on every run, not wired into required status checks), reverting this change carries no loss of actual enforcement — it only restores the prior, non-functional-but-harmless state.
- If the new hook-level preflight check is found to produce false-positive blocks (e.g., a workflow where `Agent(pr-author)` is legitimately invoked without an orchestrator-managed checkpoint), the immediate mitigation is to fix the check's logic or the checkpoint-population step, not to disable the check, per the issue's Blocker severity and the "cannot be bypassed" requirement in Expected Behavior.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Validator invocation (both enforcement points): `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete`, exit code `0` with stdout `orchestrator-state validation passed: <path>` on success, exit code `1` with error lines on `stderr` on failure (unchanged existing CLI contract, see Technical specifications below for the exact reason-code JSON shape).
- Hook deny-decision JSON shape (new case), matching the existing `Get-PrAuthorSkillBlockDecision` builder shape:
  ```json
  {
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": "ORCHESTRATOR_STATE_PREFLIGHT_FAILED: <summarized validator output or 'checkpoint missing at artifacts/orchestration/orchestrator-state.json'>"
    }
  }
  ```
  Emitted via `ConvertTo-Json -Compress -Depth 5 | Write-Output`, followed by `exit 0` — identical control-flow contract to the five existing receipt-check reason codes.

#### Required configuration keys and defaults:
- `pr_author_preflight` checkpoint field (new, top-level object in `artifacts/orchestration/orchestrator-state.json`, alongside `pr_author_receipt`):
  ```json
  {
    "pr_author_preflight": {
      "status": "pass",
      "checked_at": "<ISO-8601 UTC timestamp>",
      "checkpoint_path": "artifacts/orchestration/orchestrator-state.json",
      "validator_command": "python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete",
      "output_summary": "<validator stdout/stderr text, truncated if necessary>"
    }
  }
  ```
  `status` is `"pass"` or `"fail"`. When `"fail"`, `output_summary` carries the validator's error text and the orchestrator must not proceed to delegate to `Agent(pr-author)`.
- No new environment variables or config files. The checkpoint path default (`artifacts/orchestration/orchestrator-state.json`) matches the existing default already used throughout `orchestrator.md` and `orchestrate/SKILL.md`.

#### Backward-compatibility expectations:
- The hook's existing allow/deny cases (A, B, C, and the five receipt checks) are unaffected; existing Pester assertions for those cases must continue to pass unmodified.
- `pr_author_preflight` is an additive checkpoint field; the `orchestrator-state.md` remediation-cycle and `human_interaction` invariants (`.claude/rules/orchestrator-state.md`) are scoped to `remediation_loop` and `human_interaction` keys respectively and are unaffected by adding an unrelated top-level field.
- No breaking change to the Python CLI's public interface (`orchestrator-state <path> --require-complete`) — it is consumed as-is.

#### Performance constraints (latency/throughput/memory):
- The hook already runs on every `Bash`-matched tool call; the new check only executes the validator subprocess when the command matches `gh pr create`/`gh pr edit` (i.e., inside the existing guarded branch), so no added latency is introduced for the majority of `Bash` calls that do not match. For matching calls, one additional Python subprocess invocation (typically sub-second) is added; no explicit latency budget is defined in existing conventions, so no numeric threshold is imposed here beyond "does not materially slow down PR creation."

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Plain `python` resolves to a Python environment with `scripts/dev_tools` importable, without an explicit `poetry run` prefix, in the shell context where `enforce-pr-author-skill.ps1` runs. This is the same assumption already carried by `.claude/hooks/validate-orchestrator-output.ps1`'s established seam; it is a pre-existing, accepted repository pattern, not a new risk.
  - The orchestrator has (or will be given) sufficient tool access to invoke `mcp__drm-copilot__validate_orchestration_artifacts` (or the equivalent local CLI call) before delegating to `Agent(pr-author)`; this does not require changes to `pr-author.md`'s own tool allowlist since the check runs on the orchestrator side, not inside the `pr-author` agent.
  - `artifacts/orchestration/orchestrator-state.json` remains intentionally gitignored and per-worktree; no change to that convention is assumed or required.
- Constraints (budget, performance, compatibility):
  - `enforce-pr-author-skill.ps1` must stay under the repository's 500-line file-size cap; current size is 442 lines, leaving limited headroom.
  - The hook's `exit 0` / JSON-payload contract must not change for any existing case.
  - The Pester test file to extend (`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, 476 lines) is itself close to the 500-line cap; if the new `Context` blocks would push it over, split by extracting a shared test-data/`BeforeAll` helper first, consistent with `.claude/rules/general-code-change.md`'s 500-line limit (exceptions do not cover this file).
- External dependencies (services, libraries, releases): none. All work is repository-local; no new package, service, or CI provider is introduced (confirmed in research `## Automation Feasibility`).

## Data / API / Config Impact
- User-facing or API changes: none for end users. For repository contributors/agents: `gh pr create`/`gh pr edit --body*` now additionally fails closed with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` when the orchestrator-state checkpoint is missing or invalid, in addition to the existing receipt-based blocks.
- Data or migration considerations: none. No schema migration; the `pr_author_preflight` field is additive to a gitignored, non-persisted, per-worktree checkpoint file with no historical records to migrate.
- Logging/telemetry updates: the hook's deny-decision JSON payload gains a new reason code and summarized validator output text (see Technical specifications). The orchestrator-state checkpoint gains a new `pr_author_preflight` object for audit purposes. No new external telemetry/logging sink is introduced.
- Compatibility notes (CLI flags, config schemas, versioning): the Python CLI's `orchestrator-state <path> --require-complete` flag surface is unchanged. The checkpoint JSON schema gains one additive top-level key (`pr_author_preflight`); this does not affect the `remediation_loop`/`human_interaction` invariants enforced by `scripts/dev_tools/validate_orchestrator_state.py` per `.claude/rules/orchestrator-state.md`, since those invariants are scoped to their own top-level keys and additive unrelated keys are explicitly out of scope for those validators.

## Test Strategy
Seeded from issue:

- [x] Delete the two CI workflow files and their bundled mirrors (workflow-only removal; no ruleset changes).
- [x] Add a local pre-flight step, run before delegating to `Agent(pr-author)`, that invokes the orchestrator-state validator against `artifacts/orchestration/orchestrator-state.json --require-complete` and records the result in the checkpoint (`pr_author_preflight`).
- [x] Extend `.claude/hooks/enforce-pr-author-skill.ps1` (and its bundled mirrors, including the Codex mirror) so the existing `gh pr create` / `gh pr edit --body*` PreToolUse hook also invokes the orchestrator-state validator and fails closed (blocks the call) when the checkpoint is missing or fails `--require-complete`.
- [x] Update `.claude/skills/orchestrate/SKILL.md`, `CLAUDE.md`, `.claude/agents/pr-author.md`, and `.claude/agents/orchestrator.md` so none of them describe CI as the enforcement mechanism for checkpoint validation.
- [x] Negative-path test: verify the hook blocks `gh pr create` when the checkpoint is missing or invalid.
- [x] Run bundled-mirror contract tests (Python + Pester) and the full toolchain loop after edits.

- Regression tests to add or update:
  - `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (extend, do not replace): add a new `Context 'orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED)'` block with a mocked `$Invoker` seam covering: preflight pass → falls through to existing Case A/B/C/receipt logic unchanged; preflight fail (checkpoint missing) → blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`; preflight fail (`--require-complete` errors) → blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` and includes summarized validator output in the reason text.
  - Extend the existing `Context 'allowed commands'` `BeforeEach` to also mock a passing preflight `$Invoker`, so the previously-passing allow assertions (`gh pr create --body-file`, `gh pr edit --body-file`, `gh pr edit --title`, `gh pr edit --add-label`, non-guarded commands) remain valid under the new check.
  - Extend the `Context 'script entrypoint (end-to-end)'` block with one new `It` exercising a real `pwsh` process invocation for the preflight-block case, asserting `$LASTEXITCODE -eq 0` (per the "always exit 0, signal via JSON" contract) and `permissionDecision -eq 'deny'` with `permissionDecisionReason` containing `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`.
  - No new Python test file: `scripts/dev_tools/validate_orchestration_artifacts.py` and `validate_orchestrator_state.py` are consumed unmodified; their existing coverage in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` and `test_validate_orchestrator_state_human_interaction.py` remains sufficient unless the CLI contract changes (not anticipated by this fix).
  - No test changes required for the deleted workflow files beyond confirming (via `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`'s `REQUIRED_BUNDLED_FILES` anchor list) that neither deleted filename is referenced there — confirmed absent in research.
- Unit tests (pytest) for the fixed behavior and boundaries: none anticipated (see above); if the orchestrator-side `pr_author_preflight` recording logic is implemented as a testable Python/PowerShell helper rather than inline orchestrator-agent behavior, add unit coverage for that helper following the same file-location convention (`tests/` mirrors `scripts/`/`.claude/hooks/`).
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Checkpoint file absent entirely.
  - Checkpoint file present but malformed JSON (validator should surface this as a non-zero exit / error text, and the hook must block, not throw).
  - Checkpoint file present and valid JSON but `--require-complete` fails (incomplete tracked statuses).
  - Checkpoint file present and fully valid → preflight passes, hook falls through to existing Case A/B/C/receipt logic unchanged.
  - Non-`gh pr create`/`gh pr edit` commands must not trigger the preflight subprocess at all (performance/no-regression check on the existing allow-fast-path for unrelated `Bash` commands).
- Error handling and logging verification: assert the hook's `try/catch` around `Invoke-PrAuthorSkillDecision` still returns `exit 1` only for malformed `CLAUDE_TOOL_INPUT`, never for a preflight validation failure (which must remain a JSON-signaled `deny`, `exit 0`).
- Coverage impact and targets for changed lines/modules: maintain >= 85% line coverage and >= 75% branch coverage on `enforce-pr-author-skill.ps1` per `.claude/rules/quality-tiers.md`'s uniform thresholds; the new preflight function and its two outcome branches (pass/fail) must be exercised by the new `Context` block to avoid a coverage regression on changed lines.
- Toolchain commands to run (format → lint → type-check → test): PowerShell changes via PoshQC (`mcp__drm-copilot__run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`) per `.claude/rules/powershell.md`; no Python production code changes are anticipated, so the Python toolchain loop is not required unless a helper module is added. Documentation-only edits (`SKILL.md`, `orchestrator.md`, `pr-author.md`, `CLAUDE.md`) require no toolchain run (Markdown is exempt).
- Manual validation steps (if required): after implementation, manually run `gh pr create --body-file artifacts/pr_body_1.md` (or an equivalent dry run) with the checkpoint deliberately deleted/renamed to confirm the hook blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`, then restore a valid checkpoint and confirm the command proceeds to the existing receipt checks.


## Acceptance Criteria
- [x] `.github/workflows/validate-orchestrator-state.yml` and `.github/workflows/_validate-orchestrator-state.yml`, plus their bundled mirrors at `extensions/drm-copilot/resources/codex-and-agents-customizations/.github/workflows/`, are deleted, with no other in-repo workflow file referencing `validate-orchestrator-state`, `_validate-orchestrator-state`, `Validate orchestrator checkpoint`, or `Orchestrator State Gate` (confirm via repository-wide grep after deletion).
- [x] `enforce-pr-author-skill.ps1` blocks `gh pr create`/`gh pr edit --body*` with reason `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` when `artifacts/orchestration/orchestrator-state.json` is missing, verified by a new Pester test in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` using a mocked `$Invoker` seam.
- [x] `enforce-pr-author-skill.ps1` blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` when the checkpoint exists but fails `--require-complete`, verified by a corresponding Pester test.
- [x] `enforce-pr-author-skill.ps1` allows `gh pr create --body-file`/`gh pr edit --body-file` (subject to the existing five receipt checks passing) when the checkpoint exists and passes `--require-complete`, verified by extending the existing `Context 'allowed commands'` tests with a passing preflight mock.
- [x] The identical hook edit lands byte-for-byte in `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`, verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passing.
- [x] The equivalent edit lands in `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` with the 3-line `# Converted hook` header preserved and the body otherwise byte-identical to the root hook's new body. (See `evidence/other/implementation-deviations.md`: the authoritative `codex_native_converter` mechanism intentionally rewrites one `.claude/` path reference to `.codex/` inside the new docstring; the mirror matches that authoritative output exactly, which is a one-line, intentional, tool-governed exception to literal byte-identity.)
- [ ] The orchestrator invokes the orchestrator-state validator before delegating to `Agent(pr-author)` and records the result under a new `pr_author_preflight` field in `artifacts/orchestration/orchestrator-state.json`, matching the field shape in Technical Specifications. (Documentation of this required behavior is complete in `orchestrate/SKILL.md` and `orchestrator.md`; the runtime behavior itself occurs in a future live orchestrator session and is not executed by this implementation delegation — left unchecked pending that live execution.)
- [x] `.claude/skills/orchestrate/SKILL.md` (`## PR Authoring (pr-author Handoff)`), `.claude/agents/orchestrator.md` (`## PR Creation Delegation`), and `.claude/agents/pr-author.md` document the local preflight step and the `pr_author_preflight` checkpoint field; no claim that CI enforces the orchestrator-state gate remains in any of these three files or in `CLAUDE.md`.
- [x] The hook's existing `exit 0` / JSON-`permissionDecision` contract is unchanged for all existing cases (A, B, C, and the five receipt checks); confirmed by all pre-existing Pester tests in `enforce-pr-author-skill.Tests.ps1` continuing to pass unmodified.
- [x] `enforce-pr-author-skill.ps1` remains under the 500-line file-size cap after the change.
- [x] Full PowerShell toolchain pass completed (format → analyze → test via PoshQC) with zero errors and no coverage regression (line >= 85%, branch >= 75%) on the changed file.
- [x] Branch-ruleset non-goal explicitly documented: no change is made to `main`'s `required_status_checks` (confirmed unchanged at 11 entries, none named `Validate orchestrator checkpoint` or `Orchestrator State Gate`).

## Risks & Mitigations
- Technical or operational risks:
  - **Hook subprocess dependency**: `enforce-pr-author-skill.ps1` gains its first dependency on an external `python` process. If `python` is not on `PATH` or the `scripts.dev_tools` package is not importable in the calling shell, the preflight check could fail in an environment-dependent way (either false-blocking valid PR creation or, if unhandled, throwing and exiting 1 for the wrong reason).
    - Mitigation: reuse the already-proven `$Invoker` seam and default invocation from `validate-orchestrator-output.ps1`, which carries the same assumption today without reported issues; ensure the new check's error handling treats a subprocess launch failure as a block (fail closed) with a clear reason, not an uncaught exception.
  - **False-positive blocks disrupting legitimate PR authoring**: if the orchestrator's checkpoint-population step and the hook's preflight timing are not aligned (e.g., checkpoint written after the hook already ran), valid PR creation attempts could be blocked.
    - Mitigation: the orchestrator-recorded `pr_author_preflight` field is written before delegation, and the hook reads the same checkpoint at call time, so as long as the orchestrator populates the checkpoint (including `--require-complete`-satisfying tracked-status entries) before invoking `Agent(pr-author)`, the hook's independent re-check will pass. Document this sequencing explicitly in `orchestrate/SKILL.md`.
  - **File-size and test-file-size pressure**: both `enforce-pr-author-skill.ps1` (442 lines) and its test file (476 lines) are close to the 500-line cap.
    - Mitigation: keep the new check's implementation minimal (reuse the seam pattern rather than duplicating logic); if the test file would exceed the cap, extract shared `BeforeAll` fixtures into a helper before adding new `Context` blocks.
  - **Codex mirror re-wiring gap remains unresolved**: editing the Codex hook body without wiring `.codex/config.toml` means the Codex ecosystem's `gh pr create` calls, if any exist today, are not actually protected by this new check.
    - Mitigation: explicitly out of scope per this spec (pre-existing condition); flagged here so a future issue can track the `.codex/config.toml` wiring separately.
- Mitigations and rollbacks: see also Rollback/feature-flag considerations above. Because the deleted CI workflows were already fully non-functional, reverting this PR restores the prior (non-functional-but-harmless) state without any loss of real enforcement.

## Rollout & Follow-up
- Release/rollout steps:
  1. Land the workflow deletions, hook edits (all three copies), checkpoint-field addition, and documentation updates in a single PR (all changes are tightly coupled around one enforcement mechanism; splitting would leave an intermediate state where the CI gate is deleted but no local replacement exists yet).
  2. Run the full PowerShell toolchain loop and the bundled-mirror contract tests (Python + Pester) before merge.
  3. Manually validate the block/allow behavior per the Manual validation steps in Test Strategy.
- Post-fix monitoring or clean-up tasks:
  - Track the `.codex/config.toml` re-wiring gap (Codex mirror hook currently orphaned) as a candidate follow-up issue, separate from #272.
  - Track the absent `quality-tiers.yml` as a separate, pre-existing gap, not part of this fix.
  - Monitor for any false-positive preflight blocks in the weeks after rollout, since this is the first external-process dependency introduced into this specific hook.
- Links: issue #272 (`docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/issue.md`), research (`docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/research/2026-07-02T18-30-local-preflight-orchestrator-state-gate-272-research.md`), original CI gate PR #201, `pr-author` receipt mechanism precedent from issue #231, related bypass precedent from PR #228.
