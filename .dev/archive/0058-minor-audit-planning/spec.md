# 2026-02-23-minor-audit-planning — Spec

- **Issue:** #58
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-23T13-54
- **Status:** Draft
- **Version:** 0.1

## Overview

Current planning/execution tooling does not consistently model the selected work mode (`minor-audit` vs `full`) across agent prompts, generated atomic plans, and resume/hard-lock prompt resolution. This creates drift between feature intent and execution behavior, especially when users need a lighter audit path for small changes but strict full-process handling for larger scope work. We need deterministic, mode-aware routing so planning, prompt resolution, and execution all use the same source of truth and fail closed safely.

This feature standardizes a single mode contract across prompt templates, resolver scripts, and task wiring so `generate-atomic-plan`, execute hard-lock, and resume hard-lock all consume identical mode decisions. The contract must support explicit `minor-audit` behavior when eligible, and deterministic fallback to `full` with an explicit reason when mode markers are missing, malformed, or ineligible.


## Behavior

Implement minor-audit-aware behavior across the relevant `.github` agents, skills, and planning/prompt tooling, including atomic planning/execution variants. `generate-atomic-plan` and hard-lock/resume prompt resolution must explicitly choose and carry forward `minor-audit` or `full` mode, with clear fallback to `full` when eligibility is not met. Add/adjust prompt-resolver tasks for resume-hard-lock flow so resumed execution uses the same resolved mode and expected task set. Ensure all Python changes meet repo policy for typing, linting, and intent-level docstrings/comments.

End-to-end expected flow:
- A user invokes planning from a feature folder and provides/uses existing mode intent.
- Resolver logic reads authoritative feature context (`issue.md` mode marker) and applies canonical precedence: persisted marker first, reconciled override only when allowed, otherwise fail-closed to `full`.
- Resolved mode is injected into generated planning prompts so downstream execution agents receive the same contract.
- Execute hard-lock prompt and resume hard-lock prompt both resolve from a dynamic plan path and the same mode contract.
- If mode cannot safely remain `minor-audit`, output must include the fallback reason and proceed under `full` expectations.

Notable alternatives and branches:
- Missing `user-story.md` or `research.md` should continue to be handled by existing optional-path behavior in prompt resolution; this is not an automatic blocker for mode resolution.
- Missing/malformed mode marker in `issue.md` must not produce ambiguous output; contract requires deterministic `full` selection.
- Existing full-only usage remains valid: when no explicit minor-audit eligibility is proven, behavior defaults to current full-process posture.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Feature context files: `docs/features/active/2026-02-23-minor-audit-planning-58/issue.md`, `spec.md`, `user-story.md`.
	- Prompt templates: `.github/prompts/generate-atomic-plan.prompt.md`, `.github/codex/execute-hard-lock.prompt.md`, `.github/codex/resume-hard-lock.prompt.md`.
	- Resolver scripts (current contract surfaces):
		- `scripts/dev_tools/resolve_file_prompt.py` (`--template`, `--target`)
		- `scripts/dev_tools/resolve_hard_lock_prompt.py` (`--target`, optional `--workspace`)
		- `scripts/dev_tools/resolve_execute_plan_prompt.py` (`--feature`, optional `--workspace`, `--prompt-path`, `--agent`, `--no-copy`)
	- No new environment variables are required for mode resolution.
- Outputs (artifacts, logs, telemetry)
	- Resolved prompt text printed to stdout and optionally copied to clipboard (existing resolver behavior).
	- Prompt content containing resolved plan path and resolved mode context.
	- Deterministic fallback reason text when `minor-audit` cannot be honored.
	- No external telemetry sink is introduced; evidence remains in repo artifacts/docs.
- Config keys and defaults:
	- Authoritative mode marker in `issue.md`: `- Work Mode: minor-audit` or `- Work Mode: full`.
	- Default/fail-closed behavior: unresolved or malformed marker resolves to `full`.
	- Override behavior (if used) must be reconciled against `issue.md` and policy constraints before taking effect.
- Versioning or backward-compatibility constraints:
	- Existing resolver script command signatures must remain usable for current tasks.
	- Full-mode workflows are backward compatible and remain the safe default path.
	- Resume hard-lock must stop using hardcoded plan paths and support the same dynamic resolution as execute hard-lock.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
	- `poetry run python scripts/dev_tools/resolve_hard_lock_prompt.py --target <plan.md> --workspace <repo-root>`
		- Expected: prompt text contains resolved `${plan-path}` as workspace-relative forward-slashed path; output is printed and clipboard copy is attempted.
	- `poetry run python scripts/dev_tools/resolve_file_prompt.py --template .github/prompts/generate-atomic-plan.prompt.md --target <spec.md|plan.md>`
		- Expected: `${file}`, `${folderpath}`, `${spec}`, `${user-story}` and optional `${research}` are resolved; unresolved placeholders are rejected.
	- `poetry run python scripts/dev_tools/resolve_execute_plan_prompt.py --feature <plan.md> --workspace <repo-root>`
		- Expected: execute-plan template variables resolve from feature folder conventions; missing optional docs are annotated/removed per current behavior.
- Contracts and validation rules:
	- Placeholder resolution must fail if required variables remain unresolved.
	- Mode contract must produce one resolved mode (`minor-audit` or `full`) for every invocation path.
	- Fallback-to-`full` must include explicit reason text when requested `minor-audit` is not eligible.
	- Resume hard-lock contract must use dynamic plan-path input rather than a static path embedded in template content.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Parse mode marker from `issue.md` and normalize to an internal enum-like value: `{minor-audit, full}`.
	- Enforce invariant: every resolved prompt path yields exactly one mode decision.
	- Enforce invariant: when marker is invalid/missing, resolved mode is `full` and fallback reason is present.
	- Transform absolute/OS-native paths to workspace-relative forward-slashed output for prompt portability.
- Caching or persistence details:
	- No new persistence layer is introduced.
	- Existing persistent source of truth remains feature docs (`issue.md`) and plan files.
	- Clipboard behavior remains best-effort and non-authoritative; stdout output remains canonical for automation.
- Migration or backfill requirements (if any):
	- No historical data migration is required.
	- Existing feature folders without explicit mode marker continue under fail-closed `full` behavior.
	- Existing resume-hard-lock template usage requires path tokenization update to remove static plan reference.

## Constraints & Risks

- Scope is cross-cutting (`.github` instructions/skills + Python prompt/planning tooling), so partial rollout can produce inconsistent mode behavior across commands.
- Backward compatibility risk: existing workflows that assume full-only behavior must continue to function without breaking command signatures or expected outputs.
- Policy risk: Python suppression/doc-comment requirements are strict; non-compliant changes may pass local logic checks but fail repo quality gates.
- Operational risk: mode selection ambiguity during resume/hard-lock could cause wrong task routing unless resolution precedence is explicit and shared.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Align prompt templates, resolver scripts, and task wiring on one mode contract for planning + execute/resume hard-lock.
	- Remove hardcoded resume hard-lock plan path and replace with dynamic `${plan-path}` resolution.
	- Ensure agent/skill language references point to canonical precedence from `atomic-plan-contract` to reduce drift.
- New classes/functions/commands to add or update:
	- Update `.github/prompts/generate-atomic-plan.prompt.md` to include explicit mode contract placeholders/expectations.
	- Update `.github/codex/execute-hard-lock.prompt.md` and `.github/codex/resume-hard-lock.prompt.md` for mode-aware parity.
	- Extend `scripts/dev_tools/resolve_file_prompt.py` and `scripts/dev_tools/resolve_hard_lock_prompt.py` for mode extraction/propagation and resume support.
	- Update `.vscode/tasks.json` with resume-hard-lock resolver task parity.
	- Add/extend tests in `tests/scripts/dev_tools/test_resolve_file_prompt.py`, `test_resolve_hard_lock_prompt.py`, and related resolver tests for mode/fallback cases.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime dependency is required; mode parsing can be implemented with existing Python stdlib + current project dependencies.
- Logging/telemetry additions and locations:
	- Add deterministic fallback reason text in resolved prompt output and/or script stderr where resolution downgrades to `full`.
	- Preserve existing script UX (stdout prompt + clipboard attempt) while making mode decisions observable.
- Rollout plan (feature flags, staged deploys, fallback path):
	- No feature flag required; rollout is repository-internal and gated by tests/toolchain.
	- Stage updates as a single coherent change across templates + resolvers + tasks + tests to avoid intermediate contract mismatch.
	- Safety path is intrinsic: fail-closed `full` mode when contract inputs are incomplete/invalid.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos (unit tests for mode parsing/fallback + resolver parity and one end-to-end demo script path).
- [ ] Behavior matches acceptance criteria in all documented environments (Windows path separators and Unix-like forward-slash prompt output both validated).
- [ ] Tests updated/added (unit/integration as applicable) in `tests/scripts/dev_tools/*` for execute/resume parity and fail-closed routing.
- [ ] Edge cases and error handling covered by tests (missing mode marker, malformed marker, missing optional docs, missing/invalid target path).
- [ ] Docs updated (feature `spec.md` + `user-story.md`; prompt contracts documented in relevant template comments if needed).
- [ ] Telemetry/logging added or updated (fallback reason is explicit in resolver output; no external telemetry integration introduced).
- [ ] Toolchain pass completed (format → lint → type-check → test) with final clean pass recorded in implementation PR.

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: mode parsing/validation from `issue.md`, override reconciliation behavior, deterministic fallback reason emission, and resume-hard-lock template variable resolution.
- [ ] Integration scenarios: end-to-end generation -> execute-hard-lock -> resume-hard-lock for both `minor-audit` and `full`, plus malformed marker and marker-missing cases.
- [ ] CLI/API examples: `generate-atomic-plan` and resolver invocations that demonstrate (a) explicit minor-audit path, (b) explicit full path, and (c) fallback-to-full with reason.
