<!-- markdownlint-disable-file -->

# Task Research Notes: harden-feature-promotion-lifecycle-mcp-only

## Research Executed

### File Analysis

- `c:\Users\DanMoisan\repos\drm-copilot\.github\prompts\research-issue.prompt.md`
  - Requires one research artifact under `artifacts/research/` using the Task Researcher template, a single final recommendation, brief rejected alternatives, explicit implementation hooks, risks, and verification guidance.
- `c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168\issue.md`
  - Defines the feature scope: make the Claude-side `feature-promotion-lifecycle` skill MCP-only for agent sessions, add a Bash pre-tool guard for promotion-script bypass attempts, and document/validate `delegation_receipts.promotion.{potential_entry,issue,feature_folder}` without changing the MCP server or underlying promotion modules.
- `c:\Users\DanMoisan\repos\drm-copilot\.claude\skills\feature-promotion-lifecycle\SKILL.md`
  - Current Claude-side skill still documents fallback script sequences (`scripts/dev_tools`, `scripts/dev-tools`, `poetry run python -m scripts.dev_tools...`) and therefore does not yet enforce MCP-only guidance for agent sessions.
- `c:\Users\DanMoisan\repos\drm-copilot\.claude\settings.json`
  - Current project settings already register a `PreToolUse` Bash hook via `pwsh -NoProfile -File .claude/hooks/validate-bash.ps1`, allow broad `Bash(poetry run *)` and `Bash(pwsh *)`, and list the promotion MCP tools in `permissions.allow`.
- `c:\Users\DanMoisan\repos\drm-copilot\.claude\hooks\validate-bash.ps1`
  - Existing Bash hook is a simple pattern scanner for destructive commands. It reads `CLAUDE_TOOL_INPUT`, emits `Write-Error`, and exits `1`; it does not follow the richer ordered-dictionary/JSON decision pattern used by the newer `.claude/hooks/*.ps1` files.
- `c:\Users\DanMoisan\repos\drm-copilot\.claude\hooks\enforce-evidence-locations.ps1`
  - Establishes the current repo hook convention for policy gates: parse `CLAUDE_TOOL_INPUT`, expose reusable helper functions, support dot-sourcing in tests, emit JSON `{"decision":"block"|"allow"}` on stdout, and reserve exit `1` for hard failures.
- `c:\Users\DanMoisan\repos\drm-copilot\.claude\hooks\enforce-python-batch-budget.ps1`
  - Confirms the same reusable-hook pattern for more complex logic: helper functions, JSON allow/block response, optional state persistence, and an explicit entrypoint that can be exercised independently in tests.
- `c:\Users\DanMoisan\repos\drm-copilot\.claude\skills\csharp-orchestration-state-machine\SKILL.md`
  - Documents checkpoint field conventions for language-specific orchestration states, but only for `csharp-orchestrator-state.json`; it does not cover the main `artifacts/orchestration/orchestrator-state.json` file used by the Claude main-thread orchestrator.
- `c:\Users\DanMoisan\repos\drm-copilot\.claude\skills\powershell-orchestration-state-machine\SKILL.md`
  - Matches the C# state-machine pattern and likewise does not define nested receipt namespaces for the main orchestrator checkpoint.
- `c:\Users\DanMoisan\repos\drm-copilot\.claude\agents\orchestrator.md`
  - This is the Claude-side runtime contract for the main orchestrator checkpoint. It names the canonical file `artifacts/orchestration/orchestrator-state.json` and already lists `delegation_receipts` as a required persisted field, but it does not enumerate the nested `promotion` receipt keys.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\prompts\orchestrate-work.prompt.md`
  - Requires persistence in `artifacts/orchestration/orchestrator-state.json` and reporting of promotion lifecycle variables, reinforcing that the main orchestrator checkpoint is a first-class contract surface.
- `c:\Users\DanMoisan\repos\drm-copilot\scripts\dev_tools\validate_orchestration_artifacts.py`
  - This is the only fail-closed schema validator for orchestration artifacts. It currently requires `delegation_receipts` to be a list of agent receipt objects and therefore does not validate or accept the nested `delegation_receipts.promotion.*` structure requested by the issue.
- `c:\Users\DanMoisan\repos\drm-copilot\artifacts\orchestration\orchestrator-state.json`
  - The live checkpoint already stores `delegation_receipts` as an object with a `promotion` namespace containing `potential_entry`, `issue`, and `feature_folder`, so the persisted runtime shape has already diverged from the validator’s list-only expectation.
- `c:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev_tools\test_validate_orchestration_artifacts.py`
  - Current validator tests only cover the legacy list-based `delegation_receipts` shape and therefore need additive coverage if nested promotion receipts become part of the formal contract.
- `c:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev_tools\test_orchestration_guardrail_contracts.py`
  - Existing contract tests show the repository pattern for enforcement-by-wording: test files under `tests/scripts/dev_tools/` assert required fragments in orchestration skills and agents.
- `c:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py`
  - Existing parity tests treat repo `.claude` files as the source for the bundled Claude customization payload. Changes to `.claude/settings.json` or `.claude/skills/...` have downstream bundle parity implications even when the runtime source of truth remains the root `.claude` tree.

### Code Search Results

- `delegation_receipts|promotion|orchestrator-state|validate_orchestration_artifacts`
  - Found the requested receipt fields in the live checkpoint file and issue docs, but found list-only schema enforcement in `scripts/dev_tools/validate_orchestration_artifacts.py` and `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`.
- `CLAUDE_TOOL_INPUT|ConvertFrom-Json|Write-Error|exit 1`
  - Found that most repo hook scripts parse `CLAUDE_TOOL_INPUT` and return structured JSON decisions, while `validate-bash.ps1` remains a simpler exit-code-only validator.
- `feature-promotion-lifecycle`
  - Found the Claude skill, multiple Claude agents/routers that preload or reference it, and bundled mirror copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`, confirming this skill is a shared lifecycle contract rather than an isolated file.
- `Fallback|fallback|dev_tools|dev-tools|poetry run python -m scripts`
  - Found those fallback/script strings in `.claude/skills/feature-promotion-lifecycle/SKILL.md`, matching the issue’s explicit grep-based acceptance criteria.
- `blocked_reason|issue-num|new_active_feature_folder`
  - Found existing wording-contract tests that already enforce orchestration guardrails through file-text assertions, which is the most directly reusable test pattern for skill-content verification.

### External Research

- #githubRepo:"anthropics/claude-code bash command validator example"
  - No direct lexical code-search result was returned. The official hooks reference instead linked the raw example file directly, which was then fetched as the authoritative example source.
- #fetch:https://code.claude.com/docs/en/hooks
  - Official Claude Code hooks documentation confirms that `PreToolUse` is the correct event for Bash blocking, matcher groups can be narrowed further with handler-level `if` rules, command hooks may return `hookSpecificOutput.permissionDecision` (`allow`/`deny`/`ask`/`defer`) on exit `0`, and exit code `2` is the blocking exit code for `PreToolUse` while exit code `1` is only a non-blocking error.
- #fetch:https://code.claude.com/docs/en/settings
  - Official settings documentation confirms `.claude/settings.json` is the committed project-scoped location for team-shared hooks and permissions, hook arrays merge across scopes, and the `hooks` object is the canonical settings surface for project hook registration.
- #fetch:https://github.com/anthropics/claude-code/raw/refs/heads/main/examples/hooks/bash_command_validator_example.py
  - Anthropic’s public example reads hook input as JSON, validates Bash commands, and blocks with stderr + exit `2`, reinforcing that policy-enforcement hooks should use the documented blocking contract rather than a generic exit `1` failure.

### Project Conventions

- Standards referenced: `.github/prompts/research-issue.prompt.md`, `.github/skills/feature-promotion-lifecycle/SKILL.md`, `.github/skills/policy-compliance-order/SKILL.md`, `.claude/agents/orchestrator.md`, `.claude/hooks/*.ps1` conventions, `tests/scripts/dev_tools/` contract-test patterns.
- Instructions followed: research-only mode restrictions, repository research prompt contract, project tone policy, and the requirement to keep implementation guidance grounded in existing repo surfaces rather than inventing new runtime entry points.

## Key Discoveries

### Project Structure

The Claude runtime source of truth for this feature is the root `.claude` tree, not the extension or Copilot mirrors. The enforcement and documentation surfaces split cleanly into three layers:

1. **Claude runtime guidance** lives in `.claude/skills/feature-promotion-lifecycle/SKILL.md` and the main-thread contract in `.claude/agents/orchestrator.md`.
2. **Claude runtime guardrails** are registered in `.claude/settings.json` and implemented in `.claude/hooks/*.ps1`.
3. **Fail-closed checkpoint schema validation** lives in `scripts/dev_tools/validate_orchestration_artifacts.py` and is covered by `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`.

The current repository already persists `delegation_receipts` as a nested object in `artifacts/orchestration/orchestrator-state.json`, with `delegation_receipts.promotion.{potential_entry,issue,feature_folder}` present today. The validator and its tests are the stale layer: they still assume `delegation_receipts` must be a list of generic agent receipts. That mismatch means the validation/documentation work is not speculative; it is needed to reconcile the current live checkpoint with the repository’s only schema gate.

### Implementation Patterns

The strongest current repo pattern for new Claude hooks is **dedicated PowerShell script + JSON decision helper**, not a monolithic shell gate:

- `enforce-evidence-locations.ps1` and `enforce-python-batch-budget.ps1` both:
  - parse `$env:CLAUDE_TOOL_INPUT`,
  - expose reusable helper functions for direct test invocation,
  - support dot-sourcing without executing the entrypoint,
  - emit compact JSON allow/block responses to stdout on exit `0`, and
  - reserve non-zero exit codes for hard failures.
- `.claude/settings.json` registers these hooks centrally at the project level.
- Contract verification is usually done with **Pytest text/shape assertions** under `tests/scripts/dev_tools/`, while PowerShell behavior-specific logic remains a good fit for **Pester** because the hooks are PowerShell files with callable functions.

By contrast, `validate-bash.ps1` is older and simpler: it scans command text and exits `1` on a blocked pattern. The official Claude Code hooks docs say exit `1` is non-blocking for `PreToolUse`, while exit `2` or a structured JSON deny is the documented blocking path. Because the issue is specifically about consistent Bash guardrails, the safer repo-aligned implementation is to add a **new dedicated promotion-bypass hook** using the newer JSON decision pattern instead of extending the older exit-code-only script.

For checkpoint documentation, `.claude/agents/orchestrator.md` is the main Claude-side place that already enumerates persisted checkpoint fields for `artifacts/orchestration/orchestrator-state.json`. The language-specific orchestration state-machine skills document different checkpoint files. Therefore the main orchestrator agent file is the canonical documentation surface for `delegation_receipts.promotion.*`, while `scripts/dev_tools/validate_orchestration_artifacts.py` is the canonical validation surface.

### Complete Examples

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-rm.sh"
          }
        ]
      }
    ]
  }
}
```

Source: official Claude Code hooks reference at `https://code.claude.com/docs/en/hooks`.

This example matters because it shows the two mechanisms that fit this repository’s need: keep the hook registered in project settings, and use handler-level `if` filtering to avoid running a heavy Bash validator on every Bash command.

### API and Schema Documentation

- **Official PreToolUse blocking contract** (`https://code.claude.com/docs/en/hooks`):
  - `PreToolUse` matches on tool name such as `Bash`.
  - Handler-level `if` rules use permission-rule syntax and can narrow specific Bash subcommands.
  - Structured decision output for `PreToolUse` must be returned inside `hookSpecificOutput` with `hookEventName: "PreToolUse"` and `permissionDecision: "deny"` (or other supported values).
  - Exit code `2` blocks the tool call. Exit code `1` is a non-blocking error.
- **Official project settings scope** (`https://code.claude.com/docs/en/settings`):
  - `.claude/settings.json` is the project-shared location for hooks and permissions.
  - Hook configuration belongs in `hooks`, not in ad hoc files.
- **Current repository checkpoint validator** (`scripts/dev_tools/validate_orchestration_artifacts.py`):
  - requires `delegation_receipts` as a list,
  - validates list receipt objects with keys such as `step`, `agent_name`, `result_signal`, and `artifact_paths`,
  - does not yet recognize the live nested `delegation_receipts.promotion.*` structure.
- **Current live checkpoint** (`artifacts/orchestration/orchestrator-state.json`):
  - already persists `delegation_receipts` as an object,
  - already contains `promotion.potential_entry`, `promotion.issue`, and `promotion.feature_folder` raw receipt content.

### Configuration Examples

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "pwsh -NoProfile -File .claude/hooks/validate-bash.ps1"
          }
        ]
      }
    ]
  }
}
```

Current repository example from `.claude/settings.json`.

This matters because the repository already centralizes Bash hook registration here and already prefers explicit `pwsh -NoProfile -File ...` command strings over the optional Claude Code `shell: "powershell"` field.

### Technical Requirements

- The chosen design must keep the root `.claude` tree as the only authoritative Claude-side runtime source.
- The skill should become MCP-only for agent sessions and must remove script fallback content instead of merely downgrading its emphasis.
- The skill should require a preflight verification that the promotion MCP tools are available before the lifecycle starts.
- The skill should explicitly require raw receipt capture into `delegation_receipts.promotion.{potential_entry,issue,feature_folder}`.
- The Bash guard should be narrow enough to preserve broad existing `Bash(poetry run *)` and `Bash(pwsh *)` permissions for other workflows.
- The checkpoint validator should gain **additive** support for the nested `delegation_receipts.promotion` object without requiring changes to the promotion modules or MCP server.
- The validator should not attempt to deeply normalize the raw MCP receipt payloads; it should validate presence and container shape, not reinterpret the receipt content.

## Recommended Approach

Use a **four-surface, minimal-disruption hardening change** that keeps the runtime contract where it already lives:

1. **Rewrite `.claude/skills/feature-promotion-lifecycle/SKILL.md` as MCP-only for agent sessions.**
   - Remove the fallback subsections and every direct script reference.
   - Keep one short VS Code command-palette note explicitly marked non-authoritative for agent sessions.
   - Add an explicit preflight requirement that the promotion MCP tools are available before the lifecycle proceeds.
   - Add a receipt-capture requirement that the raw tool outputs are stored under `delegation_receipts.promotion.potential_entry`, `.issue`, and `.feature_folder`.

2. **Document the nested checkpoint receipt contract in `.claude/agents/orchestrator.md`.**
   - This file already documents the canonical main checkpoint path and persisted field set for `artifacts/orchestration/orchestrator-state.json`.
   - Expanding its `Checkpoint Persistence` section is the least disruptive way to make `delegation_receipts.promotion.*` part of the explicit Claude-side runtime contract.
   - Do not create a new generic state-machine skill for this feature; the repository does not currently use one for the main orchestrator, and introducing one would create a second documentation surface instead of strengthening the existing one.

3. **Add a dedicated Bash promotion-bypass hook under `.claude/hooks/` and register it in `.claude/settings.json`.**
   - Implement it in the same style as `enforce-evidence-locations.ps1` and `enforce-python-batch-budget.ps1`: helper functions, dot-sourcing support, parse `CLAUDE_TOOL_INPUT`, emit JSON allow/block decisions, exit `0` on structured decisions, exit `1` only on malformed input or other hard failure.
   - Register it as an additional `PreToolUse` Bash handler in `.claude/settings.json` using the existing `pwsh -NoProfile -File .claude/hooks/...` command style.
   - Use handler-level `if` filters, or equivalent command inspection in the script, to target only the four forbidden promotion bypass tokens named in the issue. Handler-level `if` filters are preferable because the official hooks docs document them as the intended way to narrow Bash hooks without changing broad project permissions.
   - Keep `validate-bash.ps1` focused on destructive-command policy. Do not merge the promotion policy into that older script.

4. **Extend `scripts/dev_tools/validate_orchestration_artifacts.py` additively to accept the live nested receipt shape.**
   - Preserve legacy support for the existing list-based `delegation_receipts` validator path, because the current tests encode that shape.
   - Add support for `delegation_receipts` as an object namespace map, with optional `promotion` object and optional `potential_entry`, `issue`, and `feature_folder` keys.
   - Validate only the container contract and presence of the nested keys when present. Treat the values as raw receipt payloads and avoid imposing a new internal schema on their content.
   - Update `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` accordingly so the validator covers both the legacy list form and the new nested promotion object.

This approach is the best fit because it matches the repository’s current separation of concerns:

- lifecycle instructions stay in the skill,
- checkpoint field documentation stays in the main orchestrator agent,
- runtime enforcement stays in `.claude/settings.json` plus `.claude/hooks/`, and
- fail-closed schema validation stays in `validate_orchestration_artifacts.py`.

It also directly addresses the current evidence mismatch: the live checkpoint already uses `delegation_receipts.promotion.*`, while the validator still expects a list.

Rejected alternatives (brief, non-exhaustive):

- **Extend `validate-bash.ps1` instead of adding a dedicated hook** — rejected because it mixes unrelated policy domains and preserves the older exit-code-only structure instead of the newer repo-standard JSON decision helper pattern.
- **Use only `.claude/settings.json` permission denies for the promotion commands** — rejected because the issue explicitly requires a hook under `.claude/hooks/`, and permission rules alone do not give the same targeted, testable policy message surface.
- **Create a new generic Claude orchestration state-machine skill for the main checkpoint** — rejected because `.claude/agents/orchestrator.md` already owns the main checkpoint contract. Adding a new document would create a second source of truth.

## Implementation Guidance

- **Objectives**: make Claude-side promotion guidance MCP-only for agent sessions; add a narrow Bash guard for promotion-script bypass attempts; formalize `delegation_receipts.promotion.*` in both documentation and validation; preserve existing promotion modules and MCP server behavior.
- **Key Tasks**:
  - update `.claude/skills/feature-promotion-lifecycle/SKILL.md` to remove fallback/script guidance and add MCP preflight + receipt capture rules;
  - update `.claude/agents/orchestrator.md` to enumerate `delegation_receipts.promotion.{potential_entry,issue,feature_folder}` as raw MCP receipt fields for the main checkpoint;
  - add a new `.claude/hooks/` PowerShell hook following the repo’s JSON decision helper pattern and register it in `.claude/settings.json` as a `PreToolUse` Bash guard;
  - extend `scripts/dev_tools/validate_orchestration_artifacts.py` and its tests to accept the current nested promotion receipt object additively;
  - add contract tests for skill wording and banned fallback/script strings.
- **Dependencies**: existing project-scoped Claude settings and hooks; existing `validate_orchestration_artifacts` CLI and MCP wrapper; current root `.claude` runtime files; existing test infrastructure in Pytest and Pester.
- **Success Criteria**:
  - `.claude/skills/feature-promotion-lifecycle/SKILL.md` contains MCP-only agent guidance, explicit MCP preflight, explicit raw receipt capture, and no banned fallback/script strings;
  - `.claude/settings.json` registers the new Bash promotion guard consistently with current repo patterns;
  - the new hook blocks the four forbidden bypass tokens while allowing benign Bash commands;
  - `.claude/agents/orchestrator.md` explicitly documents `delegation_receipts.promotion.*` for `artifacts/orchestration/orchestrator-state.json`;
  - `validate_orchestration_artifacts.py` accepts both legacy and nested receipt shapes and specifically covers `delegation_receipts.promotion.{potential_entry,issue,feature_folder}`;
  - tests cover hook behavior, skill-content verification, and checkpoint validation without modifying the promotion modules or MCP server.