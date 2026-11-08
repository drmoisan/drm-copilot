# epic-plan-cites-unshipped-wave-computation-script (Spec)

- **Issue:** #1129
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T08-08
- **Status:** Draft
- **Version:** 0.1

## Context
The `epic-plan` skill cites `scripts/dev_tools/epic_wave_computation.py` as the reference implementation for wave layering, but the push-down does not ship that script to destination repositories. In iar-migration the planner computed the waves by hand.

Environment:
- OS/version: Windows 11 Pro, Claude Code
- Python version: n/a
- Command/flags used: `/epic-plan` in a pushed-down destination repository
- Data source or fixture: iar-migration E1/E2 planning, 2026-11-07/08

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Push down the Claude customizations to a destination repository.
2. Run `/epic-plan` there.
3. Observe that the skill points to `scripts/dev_tools/epic_wave_computation.py`, which does not exist in the destination.

Expected:
The wave-layering reference the skill names exists in every repository the skill is pushed to, or the skill names a script that is shipped.

Actual:
The cited script is missing in destination repositories, so the planner computes waves by hand, without the reference implementation's cycle and unresolved-reference checks.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `epic-plan` SKILL.md `## Decomposition and Wave Design`, step 4.


## Scope & Non-Goals
- In scope: a pushed-down PowerShell wave-layering implementation and CLI for Claude and Codex; citation text in the epic skills and agents; Python reference parity; a shared corpus; a citation-shipping regression test.
- Out of scope / non-goals: the epic merge-gate CI step (#1130) and nesting depth; the TypeScript validators; removal of the Python module `scripts/dev_tools/epic_wave_computation.py`.
- Explicitly excluded systems, integrations, or datasets: none beyond the above.

## Root Cause Analysis
`scripts/dev_tools/epic_wave_computation.py` lives outside every bundled tree, so the push-down never ships it. The Claude and Codex `epic-plan` and `epic-orchestrate` skills and the `epic-orchestrator` agent cite it as the wave-layering reference, so a destination planner computes waves by hand without the cycle and unresolved-reference checks. A survey of other cited scripts found one further unshipped citation, `scripts/dev_tools/validate_epic_orchestrator_state.py`, which the citing sentences already route through the MCP tool `validate_orchestration_artifacts`.

## Proposed Fix

### Design summary (what changes where):
Ship the wave computation as PowerShell under `.claude/lib/epic-wave/`, mirror it to the bundle and to Codex as `.codex/lib/epic-wave/`, cite the shipped CLI in the epic surfaces, and add a test that fails when an epic surface cites a path the push-down does not ship.

### Boundaries and invariants to preserve:
- `wave(f) = 0` with no dependencies, otherwise `1 + max(wave(d))`.
- The Python module stays as this repository's parity reference; destinations do not run it.
- Edits to the shared epic skill and agent files stay confined to the wave-layering sentences because other issues edit them concurrently.

### Dependencies or blocked work:
None blocking. #1130 edits other parts of the same files.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `.claude/lib/epic-wave/EpicWave.psm1`, `.claude/lib/epic-wave/Invoke-EpicWave.ps1`, mirrored under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/`, and listed in the Claude `core.json` under `extensions/drm-copilot/resources/claude-customizations/pack-manifests/`.
- Codex: `VIRTUAL_RESOURCE_DIRECTORIES` in `scripts/dev_tools/push_down_codex_and_agents_customizations.py`, the stored copy under `extensions/drm-copilot/resources/lib/epic-wave/`, and the Codex `core.json` entries for `.codex/lib/epic-wave/*`.
- Hook: `.codex/hooks/enforce-epic-planning-only.ps1` and its bundled twin gain one allowlist pattern for the CLI; the `epic_wave_computation` Python pattern is kept.
- Agents: `.claude/agents/epic-planner.md` and `.claude/agents/epic-orchestrator.md` gain `Bash(pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1*)`; bundled copies and generated `.codex/agents/*.toml` variants are regenerated.
- Text: `epic-plan` and `epic-orchestrate` SKILL.md (`.claude/skills`, `.agents/skills`, bundled mirrors) and `.claude/agents/epic-orchestrator.md` (`## Wave Scheduling`).
- Python reference: `scripts/dev_tools/epic_wave_computation.py`.
- Pins: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.

#### Functions/classes/CLI commands impacted:
`Get-EpicWaveNumber` (new, in `EpicWave.psm1`), `Invoke-EpicWave.ps1` (new CLI), `compute_wave_numbers` and a new `EpicWaveUnresolvedReferenceError` in the Python reference, `Test-EpicPlanningBashAllowed` in the Codex hook.

#### Data flow and validation changes:
The CLI reads a manifest, calls the module, and writes the wave map. Unresolved `depends_on` references are now rejected in both implementations instead of yielding wave 0.

#### Error handling and logging updates:
The module rejects cycles, self-loops, and unresolved references with three distinct, stable error messages. The CLI writes the message to stderr and sets the exit code.

#### Rollback/feature-flag considerations (if applicable):
None. Reverting the change restores the prior citations; no data migration exists.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Input: path to a JSON file holding `{ "<feature>": ["<dep>", ...] }`. Output: JSON object mapping each feature to its wave number on stdout. Exit codes: 0 success, 1 invalid manifest (cycle, self-loop, or unresolved reference), 2 usage error or unreadable input.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
Existing Python callers keep working; `validate_epic_planner_state.py` already rejects unresolved references before computing waves.

#### Performance constraints (latency/throughput/memory):
Not applicable; manifests are tens of nodes.

## Assumptions, Constraints, Dependencies
- Assumptions: destinations have `pwsh` available, as the existing `ci-gate` CLIs already require.
- Constraints: new pushed-down tooling is PowerShell, not Python; no temporary files in tests; line coverage at least 85%.
- External dependencies: an extension rebuild and reinstall before a push-down carries the fix.

## Data / API / Config Impact
- User-facing or API changes: new CLI `Invoke-EpicWave.ps1`; new Python exception `EpicWaveUnresolvedReferenceError`.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): pack manifests gain entries; the frozen-surface digests are re-pinned.

## Test Strategy
- Regression tests to add or update: `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` (must fail on the pre-fix tree, recorded as fail-before evidence).
- Unit tests (pytest) for the fixed behavior and boundaries: a pytest corpus lane reading `tests/fixtures/epic_wave/wave-computation-cases.json`; existing `test_epic_wave_computation.py` stays green.
- Unit tests (Pester): module tests and a parity lane over the same corpus under `tests/scripts/claude-lib/epic-wave/`; the CLI is exercised through the module in-process.
- Edge cases and negative scenarios: empty, single, chain, diamond, multiple roots, cycle, self-loop, unresolved reference.
- Error handling and logging verification: distinct error messages and exit codes 0, 1, 2.
- Coverage impact and targets for changed lines/modules: line coverage at least 85%; the CLI wrapper stays thin.
- Toolchain commands to run (format → lint → type-check → test): the repository seven-stage loop for Python and PowerShell.
- Manual validation steps (if required): after rebuild and reinstall, run a push-down to a scratch destination and confirm the CLI exists under `.claude/lib/epic-wave/` and `.codex/lib/epic-wave/`.

## Acceptance Criteria
- [x] `.claude/lib/epic-wave/EpicWave.psm1` and `Invoke-EpicWave.ps1` exist, are byte-equal in `extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/`, and are listed in the Claude `core.json`; proven by `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py`.
- [x] The module returns `0` for no dependencies and `1 + max(wave(d))` otherwise for every non-error corpus case (empty, single, chain, diamond, multiple roots); proven by `EpicWave.Parity.Tests.ps1`.
- [x] The module rejects a cycle, a self-loop, and an unresolved reference with three distinct, stable messages; proven by `EpicWave.Tests.ps1`.
- [x] `Invoke-EpicWave.ps1` exits 0 on success, 1 on cycle or unresolved reference, and 2 on a missing argument or unreadable file; proven by `EpicWave.Tests.ps1`.
- [x] `scripts/dev_tools/epic_wave_computation.py` raises `EpicWaveUnresolvedReferenceError` for an unresolved reference, and a pytest lane and the Pester lane both pass over `tests/fixtures/epic_wave/wave-computation-cases.json`; proven by `test_epic_wave_corpus_parity.py` and `EpicWave.Parity.Tests.ps1`, with `test_epic_wave_computation.py` still passing.
- [x] The Codex push-down publishes `.codex/lib/epic-wave/` through `VIRTUAL_RESOURCE_DIRECTORIES`; proven by `test_push_down_codex_and_agents_virtual_paths.py` and the Codex `core.json` closure test.
- [x] `.codex/hooks/enforce-epic-planning-only.ps1` and its bundled twin allow the CLI command and still allow the `epic_wave_computation` Python pattern; proven by new cases in `tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1`.
- [x] `epic-planner.md` and `epic-orchestrator.md` list `Bash(pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicWave.ps1*)`, with bundled copies and generated Codex variants regenerated; proven by `generate_codex_agent_variants.py --check` and the push-down resource contract tests.
- [x] The wave-layering sentences in `epic-plan` and `epic-orchestrate` SKILL.md (Claude, Codex, bundled copies) and in `.claude/agents/epic-orchestrator.md` cite the shipped CLI (Codex text cites `.codex/lib/epic-wave/`), keep the Python module only as a repository parity reference, and change nothing else; proven by the mirror contract tests and `test_frozen_epic_surface_matches_pinned_baseline_digest` after re-pinning with a `RE-BASELINED by issue #1129` note.
- [x] `test_epic_skill_script_citations_shipped.py` passes after the fix, fails on the pre-fix tree, requires an allowlist reason naming the MCP route for `scripts/dev_tools/validate_epic_orchestrator_state.py`, and fails on a stale allowlist entry.
- [x] The full toolchain (format, lint, type-check, architecture, unit, contract, integration) passes in a single pass, and the PR states that destinations must refresh the push-down after an extension rebuild and reinstall.

## Risks & Mitigations
- Technical or operational risks: a missed mirror copy; frozen-digest drift from concurrent edits; CRLF versus LF differences in digests.
- Mitigations and rollbacks: run the mirror contract tests after each edit; compute digests on LF files; keep edits to the wave-layering sentences; revert the change set if needed.

## Rollout & Follow-up
- Release/rollout steps: merge, rebuild and reinstall the extension, then re-run the Claude and Codex push-downs in each destination.
- Post-fix monitoring or clean-up tasks: none planned; the citation-shipping test guards recurrence.
- Links: issue #1129; related #1130 (out of scope).
