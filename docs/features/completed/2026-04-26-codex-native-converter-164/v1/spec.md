# codex-native-converter — Spec

- **Issue:** #164
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-26T18-01
- **Status:** Superceded by 2.0
- **Version:** 1.0

## Overview

This feature defines a deterministic converter that ingests supported agent assets from other ecosystems and emits only Codex-native outputs for this repository. The v1 target is a full-feature conversion surface for supported GitHub Copilot and Claude inputs, with review-first reporting, explicit unsupported classifications, and fail-closed enforcement handling.

The Python CLI is the authoritative converter surface; the TypeScript layer is a thin bundled command and MCP wrapper over the same Python engine.

The provided issue and research are sufficient to define the v1 requirements. The feature is scoped around verified Codex-native mechanisms such as `AGENTS.md`, `.agents/skills`, `.codex/agents`, `.codex/config.toml`, native hooks, native `.rules` files, and required MCP configuration, with repository-specific `.codex/prompts` support treated as an opt-in convention rather than a universal Codex product claim.

## Behavior

The converter accepts a supported source root or an explicit subset of supported source files, determines the source ecosystem, classifies each source artifact, and maps it into a Codex-native target surface or a blocking unsupported result.

### Main user flow (happy path)

1. The user runs the converter in review mode against a supported GitHub Copilot or Claude source tree.
2. The converter enumerates supported input artifacts in deterministic order and classifies each item by source kind, conversion class, target role, and target surface.
3. The converter applies mapping rules and rewrite rules, including semantic MCP rewrites to `drmCopilotExtension` when a verified mapping exists.
4. The converter validates the proposed outputs for unresolved hard gates, unresolved handoff semantics, unsupported mappings, duplicate content placement, and lingering source-runtime references.
5. The converter writes a review artifact set under an artifact root without writing Codex-native runtime files into a destination root.
6. After approval, the user reruns the converter in apply mode with an explicit destination root.
7. The converter writes the approved Codex-native outputs and the same report artifacts, or stops without partial success when a blocking validation failure is present.

### Alternate and edge flows

- If the source ecosystem is unsupported, the run stops before target generation and records a blocking validation result.
- If an individual source artifact is unsupported inside an otherwise supported ecosystem, review mode records the unsupported mapping; apply mode fails if that artifact is required for a complete conversion or if it participates in hard-gate behavior.
- If prompt-launcher output is requested, the converter may target `.codex/prompts/**` only when the caller explicitly enables repository-convention prompts for this repository.
- If a source file mixes multiple concerns, the converter may decompose it across multiple Codex-native outputs instead of mirroring the file shape.
- If two source artifacts would emit conflicting target content, the converter fails validation rather than picking a winner implicitly.

### Error handling and recovery behavior

- Validation is fail-closed for unresolved hard-gate mappings, unresolved handoff mappings that lack a verified native equivalent, unresolved MCP rewrites, malformed source manifests, and duplicate target-path collisions.
- Review mode remains non-mutating even when validation fails; the failure is captured in the report artifacts.
- Apply mode must not write partial runtime output after a blocking validation failure is detected.
- All blocking failures include the source path, target intent, failure code, and a human-readable remediation note in the report artifacts.

## Inputs / Outputs

### Inputs

- Source root: path to a supported GitHub Copilot or Claude tree.
- Optional selected paths: one or more source files or folders under the source root.
- Source ecosystem: `github-copilot` or `claude`.
- Mode: `review` or `apply`.
- Destination root: required for `apply`; optional for `review`.
- Artifact root: optional; defaults to `artifacts/codex-native-converter/<run-id>/`.
- Repository prompt mode: optional boolean or explicit enum that enables repository-specific `.codex/prompts/**` output.
- Strictness options: optional flags for blocking on warnings versus recording warnings only, but hard-gate and unresolved-native-equivalent failures are always blocking.

### Supported v1 source scope

Supported GitHub Copilot source surfaces in v1:

- `.github/copilot-instructions.md`
- `.github/instructions/*.instructions.md`
- `.github/skills/**`
- `.github/agents/**`
- GitHub prompt-launcher assets when explicitly selected as source input

Supported Claude source surfaces in v1:

- `CLAUDE.md`
- `.claude/skills/**`
- `.claude/agents/**`
- `.claude/hooks/**`
- `.claude/settings.json`
- `.claude/rules/**`

Any other ecosystem is out of scope for v1 and must be classified as unsupported.

### Outputs

- Codex-native runtime outputs written only in apply mode:
  - `AGENTS.md`
  - `.agents/skills/**`
  - `.codex/agents/**`
  - `.codex/config.toml`
  - `.codex/hooks/**` and native hook registration
  - `.codex/rules/**`
  - `.codex/prompts/**` only when repository prompt mode is explicitly enabled
- Review and apply report artifacts:
  - `conversion-report.md`
  - `mapping-catalog.json`
  - `validation-results.json`
  - `proposed-tree/**`
- Logs:
  - structured console output for the CLI
  - machine-readable status embedded in `validation-results.json`

### Config keys and defaults

- Default mode: `review`.
- Default prompt handling: disabled unless repository prompt mode is explicitly enabled.
- Default failure policy: unresolved hard gates, unresolved handoffs without a verified native equivalent, and unresolved MCP rewrites are always blocking.
- Default duplication policy: if reusable guidance can be shared through a skill, the converter must prefer the shared skill over duplicating the content into multiple agents or prompts.

### Versioning and backward-compatibility constraints

- v1 is limited to supported GitHub Copilot and Claude source surfaces.
- v1 does not promise lossless one-file mirroring for mixed-concern source files.
- v1 must not present `.codex/prompts/**` as a portable Codex-wide runtime contract.
- v1 must not emit `.github`, `.claude`, or `CLAUDE.md` artifacts as targets.

## API / CLI Surface

The authoritative v1 surface is a deterministic Python CLI. The Python CLI is the authoritative converter surface; the TypeScript layer is a thin bundled command and MCP wrapper over the same Python engine. The CLI contract remains the source of truth for mapping, validation, and report generation.

### Likely CLI commands

- Review mode
  - `poetry run python -m scripts.dev_tools.codex_native_converter review --source-root <path> --source-ecosystem <github-copilot|claude> [--selected-path <path> ...] [--artifact-root <path>] [--enable-repo-prompts]`
- Apply mode
  - `poetry run python -m scripts.dev_tools.codex_native_converter apply --source-root <path> --source-ecosystem <github-copilot|claude> --destination-root <path> [--selected-path <path> ...] [--artifact-root <path>] [--enable-repo-prompts]`

### Likely JSON request shape for future automation exposure

```json
{
  "source_root": "C:/work/source-runtime",
  "source_ecosystem": "github-copilot",
  "mode": "review",
  "selected_paths": [".github/skills/feature-review-workflow"],
  "destination_root": "C:/work/target-runtime",
  "artifact_root": "artifacts/codex-native-converter/2026-04-26T18-01",
  "enable_repo_prompts": false
}
```

### Contracts and validation rules

- `source_root` must exist and contain at least one supported source artifact for the declared ecosystem.
- `source_ecosystem` must be explicit in v1; auto-detection may be advisory but cannot override an explicit user declaration.
- `destination_root` is mandatory for `apply` and must not be written in `review` mode.
- `enable_repo_prompts` is the only condition under which `.codex/prompts/**` may be emitted.
- Every emitted target file must be derivable from one or more cataloged source artifacts.
- No emitted target may retain raw `.github`, `.claude`, `CLAUDE.md`, raw host command IDs, or repository-local script references when a verified native Codex or MCP target exists.

## Data & State

### Target taxonomy

The converter must use the following target taxonomy:

- Persistent standing guidance
  - `AGENTS.md`
- Reusable workflow skill
  - `.agents/skills/<skill-name>/SKILL.md`
  - optional `.agents/skills/<skill-name>/agents/openai.yaml`
- Custom subagent
  - `.codex/agents/<agent-name>.toml`
- Runtime configuration and MCP bindings
  - `.codex/config.toml`
- Native hook configuration and hook scripts
  - `.codex/config.toml` hook sections and/or `.codex/hooks/**`
- Shell execution policy
  - `.codex/rules/*.rules`
- Repository-specific launcher prompt
  - `.codex/prompts/*.md` only as a `repo-convention` output class

### Source classification model

Each source artifact must be assigned:

- `source_kind`
  - standing-instruction
  - path-scoped-instruction
  - reusable-skill
  - agent-manifest
  - launcher-prompt
  - hook-definition
  - permissions-or-settings
  - shell-policy-or-rule
  - MCP-dependency-declaration
  - host-adapter-reference
- `conversion_class`
  - `direct`: maps cleanly to one Codex-native surface
  - `decomposed`: must be split across multiple Codex-native surfaces
  - `repo-convention`: maps only to a repository-local Codex convention such as `.codex/prompts/**`
  - `unsupported`: has no safe v1 mapping
- `target_role`
  - standing-guidance
  - shared-skill
  - subagent
  - hook
  - approval-rule
  - MCP-config
  - launcher
  - unsupported

### Mapping rules

- Standing instructions from supported source ecosystems map to `AGENTS.md` when the content is repo-wide and persistent.
- Reusable skills map to `.agents/skills/**` and keep MCP dependencies in `agents/openai.yaml` when such dependencies are part of the source contract.
- Mixed-concern agent manifests are decomposed into thin `.codex/agents/*.toml` manifests plus shared skill or standing-guidance content when that avoids duplication.
- Source hook definitions, permission settings, and stop conditions map to native Codex hooks, approval policy, required MCP configuration, and `.rules` files based on the behavior they enforce.
- Source launcher prompts may map to `.codex/prompts/**` only when repository prompt mode is enabled; otherwise they are reported as unsupported or retained only as report output for manual follow-up.
- Host-specific command or script references map to semantic MCP tool usage on `drmCopilotExtension` when a verified mapping exists; otherwise they produce a blocking validation failure if they are required for behavioral equivalence.

### Data transformations and invariants

- Enumeration order must be deterministic by normalized relative path.
- The same source artifact set must produce the same `mapping-catalog.json` and `proposed-tree/` contents for the same options.
- Reusable guidance must be emitted once and referenced from consuming agents or prompts where the target model supports that separation.
- A target file must not contain duplicated guidance that the converter has already emitted into a shared skill unless the target runtime requires an inline copy for correctness.

### Caching or persistence details

- No long-lived cache is required in v1.
- Persistent state is limited to the report artifact set and apply-mode target outputs.

### Migration or backfill requirements

- No existing runtime assets are migrated in place automatically.
- The converter operates on explicit source inputs and explicit destination roots.

## Constraints & Risks

- Codex does not expose a verified native equivalent for every source concept from GitHub Copilot or Claude. Unsupported mappings must be explicit rather than invented.
- Path-scoped Markdown instruction files from other ecosystems do not map directly to a verified native Codex Markdown instruction surface. They may require decomposition into `AGENTS.md`, shared skills, agent instructions, hooks, or rules.
- `.codex/prompts/**` is a repository convention in this repo, not a verified universal Codex product guarantee.
- Hard gates cannot be rewritten as documentation-only output. If native enforcement is unavailable, the conversion must block.
- Handoff behavior is constrained by verified Codex-native mechanisms. There is no verified first-class native `handoffs:` manifest field in the research baseline, so unsupported handoff semantics must fail closed.
- Conversion breadth can expand quickly. v1 must remain explicit about supported source ecosystems and source surfaces.

### Limits and trade-offs

- Accuracy and determinism take priority over breadth.
- Review artifact completeness takes priority over minimizing artifact volume.
- The converter may require decomposition instead of one-file mirroring to preserve native Codex semantics and anti-duplication rules.

### Security and enforcement considerations

- Hard-gate conversion must use verified Codex-native enforcement surfaces only.
- Required external automation must be modeled with required MCP configuration when that is the enforcing mechanism.
- Shell restrictions must use native `.rules` files and approval policy, not advisory comments.
- Tool-use approval and side-effect approval must use native hook or approval mechanisms when those are the verified enforcing surfaces.

### Operational and rollout risks

- Mapping catalogs will need maintenance as supported source ecosystems evolve.
- Some source artifacts will need manual follow-up even in successful review runs.
- If the converter is later exposed through MCP or extension workflows, the implementation must preserve the same validation contract as the CLI.

## Implementation Strategy

### Implementation scope

- Build a classifier-first converter engine in `scripts/dev_tools/`.
- The Python CLI is the authoritative converter surface; the TypeScript layer is a thin bundled command and MCP wrapper over the same Python engine.
- Define a machine-readable mapping catalog schema and validation schema.
- Define deterministic mapping rules for supported GitHub Copilot and Claude source surfaces.
- Emit a review artifact set in both review and apply modes.
- Emit Codex-native outputs only in apply mode.
- Keep `.codex/prompts/**` behind an explicit repository-convention option.

### New classes, functions, or commands to add or update

- Python CLI entry point for review/apply execution
- Source artifact classifier module
- Mapping planner module
- MCP rewrite catalog module
- Validation engine for hard gates, handoffs, and unsupported mappings
- Report writer for Markdown plus JSON artifacts
- Fixture-based tests for GitHub Copilot, Claude, and unsupported scenarios

### Dependency changes and rationale

- Prefer existing Python standard-library and repository tooling where practical.
- Do not add new runtime dependencies unless an existing repository dependency cannot support deterministic parsing or output generation.

### Logging and telemetry additions

- CLI log lines should summarize the run mode, source ecosystem, examined artifact count, blocking failure count, and artifact root.
- `validation-results.json` is the machine-readable source of truth for failure and warning status.
- `conversion-report.md` is the human-readable review summary.

### Rollout plan

- Deliver the Python review/apply converter as the authoritative v1 surface.
- Add automation wrappers only if they preserve the same fail-closed validation behavior and report outputs.

## Enforcement Model

The converter must preserve strict source behavior using verified Codex-native enforcement surfaces and must not downgrade a hard gate into advisory text.

### Hard-gate mapping requirements

- Shell execution restrictions map to `.codex/rules/*.rules` plus approval policy when required.
- Tool-call or side-effect approval requirements map to native `PermissionRequest` hooks and related approval settings when applicable.
- Pre-execution blocking maps to native `PreToolUse` hooks when applicable.
- End-of-run completion blocking or must-not-finish-yet conditions map to native `Stop` hooks when applicable.
- Required external automation or required MCP access maps to `[mcp_servers.<name>].required = true` and related native MCP configuration.

### Handoff behavior requirements

- Supported handoff intent may be represented through thin `.codex/agents/*.toml` manifests plus shared skills and standing guidance.
- If a source handoff requires a native construct that was not verified in the research baseline, the converter must classify that behavior as unsupported and block apply mode.
- Handoff preservation is therefore fail-closed and non-discretionary: no best-effort approximation is allowed for required orchestration behavior.

## Unsupported Mappings

The converter must classify the following as unsupported in v1 unless future research verifies a safe native mapping:

- Source path-scoped instruction behavior that cannot be represented safely through `AGENTS.md`, skills, agent instructions, hooks, or rules.
- Source handoff semantics that depend on a non-verified native Codex manifest capability.
- Prompt-launcher mappings when repository prompt mode is disabled.
- Host-specific automation references without a verified semantic MCP rewrite.
- Mixed-concern source artifacts that cannot be decomposed without changing behavior.

Unsupported mappings must appear in both `mapping-catalog.json` and `validation-results.json`, and blocking unsupported mappings must stop apply mode.

## Validation Failures

`validation-results.json` must record each validation item with at least:

- `code`
- `severity`
- `blocking`
- `source_path`
- `target_path` when applicable
- `message`
- `recommended_action`

Blocking failure categories in v1:

- unsupported-ecosystem
- malformed-source-artifact
- unresolved-hard-gate-mapping
- unresolved-handoff-mapping
- unresolved-mcp-rewrite
- duplicate-target-path
- lingering-source-runtime-reference
- missing-required-input

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [x] Toolchain pass completed (format → lint → type-check → test)