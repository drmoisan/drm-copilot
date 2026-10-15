# 2026-09-29-validate-orchestrator-state-cli-entry-point (Spec)

- **Issue:** #464
- **Parent (optional):** Epic #771 (`orchestrator-state-contract-correctness`; manifest `docs/features/epics/orchestrator-state-contract-correctness/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T15-00
- **Status:** Draft
- **Version:** 0.2

## Context
`scripts/dev_tools/validate_orchestrator_state.py` has no `__main__` guard, no `argparse`, and no `main()`. The command `python -m scripts.dev_tools.validate_orchestrator_state <path> [flags]` therefore does nothing and exits 0, which is a false green for any caller that treats exit 0 as a passed validation gate.

Environment:
- OS/version: any (reproduced without `poetry run`)
- Python version: repository Poetry environment
- Command/flags used: `python -m scripts.dev_tools.validate_orchestrator_state /nonexistent/path.json --require-complete`
- Data source or fixture: none; the path does not exist

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An orchestrator that runs the documented preflight and reads exit 0 believes a validation gate passed that never executed. The failure is silent and indistinguishable from success.


## Repro & Evidence
Steps to Reproduce:
1. Run `python -m scripts.dev_tools.validate_orchestrator_state /nonexistent/path.json --require-complete`.
2. Run `echo $?`.
3. Run `grep -c "__main__\|argparse\|def main" scripts/dev_tools/validate_orchestrator_state.py`.

Expected:
The command reads the checkpoint, applies the requested gate flags, prints each validation error, and exits non-zero when errors exist or when the path does not exist.

Actual:
No output and exit code 0 even though the path does not exist. The grep count is 0.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: exit code 0 with empty output for a nonexistent path; observed during orchestration of #462 (PR #463).

Research basis: `research/2026-09-29T14-35-cli-entry-point-research.md`. That research was performed without a shell; the reproduction was derived from code and from the issue record, not executed. The implementation evidence must include an executed before/after reproduction.


## Scope & Non-Goals
- In scope:
  - A new sibling module `scripts/dev_tools/validate_orchestrator_state_cli.py` providing an argparse-based `build_parser()` and `main(argv=None, *, validate=...)`.
  - A minimal `if __name__ == "__main__":` guard in `scripts/dev_tools/validate_orchestrator_state.py` that reaches the CLI.
  - A behavior-preserving extraction of the remediation-loop validation block from `validate_orchestrator_state.py` into a private sibling module `scripts/dev_tools/_orchestrator_state_remediation_loop.py`, to keep the validator under the 500-line cap and to leave headroom for downstream child #523.
  - Documentation edits that name both the dispatcher CLI and the bare-module CLI (see Data / API / Config Impact), including byte-identical bundle mirrors.
  - New unit tests for the CLI module.
- Out of scope / non-goals:
  - Any change to the behavior or error messages of `validate_orchestrator_state_text` (error lists must remain byte-identical).
  - Any change to the dispatcher `scripts/dev_tools/validate_orchestration_artifacts.py`. The dispatcher `orchestrator-state` route remains the MCP-equivalent route. Its uncaught traceback on a missing or unreadable path (research section 1.2) is a separate observation, recorded here as a non-goal and a possible follow-up issue; it is not fixed in this change.
  - Any hook, PowerShell, or TypeScript change. The completion hook `.claude/hooks/validate-orchestrator-output.ps1` uses no Python leg, and no Python leg may be added.
  - Any `blocked_reason` contract change (owned by child #523).
  - Files belonging to issue #769.
  - Adjacent stale text in `.claude/skills/orchestrate/SKILL.md` (the `$Invoker` statement near line 191 and the hook statement near line 221; research section 2.1 D). These are not part of the #464 acceptance criteria and are recorded as a possible follow-up.
  - Exposing `strict_route_membership` as a CLI flag (neither existing surface exposes it).
- Explicitly excluded systems, integrations, or datasets:
  - The MCP `validate_orchestration_artifacts` tool and the TypeScript validators under `extensions/drm-copilot/src/lib/validate/`.
  - The `.claude/lib/orchestrator-state/*.psm1` PowerShell validators.
  - The `.agents/` (Codex) skill copies: they refer to the MCP tool and do not mention a local CLI; they are edited only if verification shows they carry the same ambiguous text.

## Root Cause Analysis
The module was written as an import-only library. `.claude/hooks/validate-orchestrator-output.ps1` performs completion validation through the PowerShell port (`Test-OrchestratorStateCompletionReadiness`, delivered under #475), not through a Python import, so hook-level enforcement works independently of this defect. `scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state <path>` already exposes an equivalent dispatcher route. The gap is confined to the bare module invocation. The module is at the edge of the repository 500-line cap (research measured 492 lines), so the entry point must live in a separate module.


## Proposed Fix

### Design summary (what changes where):
1. `scripts/dev_tools/validate_orchestrator_state_cli.py` (new) defines the CLI. It does not import `validate_orchestrator_state`. The validator callable is injected through the `validate` keyword of `main`, so there is no double import when the validator runs as `__main__` under `python -m`, and no import cycle.
2. `scripts/dev_tools/validate_orchestrator_state.py` gains a minimal guard:
   ```python
   if __name__ == "__main__":
       from scripts.dev_tools.validate_orchestrator_state_cli import main

       raise SystemExit(main(validate=validate_orchestrator_state_text))
   ```
   The import is lazy (inside the guard) so importing the validator as a library does not load the CLI module.
3. `scripts/dev_tools/_orchestrator_state_remediation_loop.py` (new, private) receives `REMEDIATION_LOOP_KEY`, `REMEDIATION_CYCLES_KEY`, `EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT`, `PREFLIGHT_CLEARED_STATUS`, `_validate_remediation_cycle`, and `_validate_remediation_loop`, moved verbatim. `validate_orchestrator_state.py` imports back only the names it still uses (`REMEDIATION_LOOP_KEY`, `_validate_remediation_loop`), in isort order between the `_orchestrator_state_preparation_terminal` and `_orchestrator_state_routing` imports. The new module follows the sibling convention (`_orchestrator_state_<topic>.py`): docstring with Purpose, Usage, Invariants / Constraints, Side Effects; `from __future__ import annotations`.
4. Documentation is updated so that the ambiguous phrase "the local CLI" names concrete surfaces (details under Data / API / Config Impact).

### Boundaries and invariants to preserve:
- `validate_orchestrator_state_text` output is byte-identical for every input; no message text, ordering, or signature changes.
- The remediation extraction is behavior-preserving; moved code is not edited beyond imports.
- `scripts/dev_tools/validate_orchestrator_state.py` and every new or modified production or test file stay within the repository 500-line limit. The post-change line count of the validator must be measured and recorded in the evidence, with a target that leaves headroom for #523; research projected substantial headroom, but that projection is an estimate, not a requirement, and is not asserted here.
- The CLI performs no I/O other than reading the checkpoint path through a single seam and writing to stdout and stderr.
- No `python -m scripts.dev_tools...` command and no `scripts/...` invocation form is added to any `.claude/skills/*/SKILL.md` (skill bundle contract, issue #762, would report `not-in-bundle`). Citation-only mentions are permitted.
- No hook or `.claude/lib` file is edited.

### Dependencies or blocked work:
- Blocks child #523 (extends `blocked_reason` handling in `validate_orchestrator_state.py`); the extraction provides its headroom. Epic wave 0; no dependencies.
- Constraint from tests: `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py` must pass unchanged.

### Implementation strategy (what changes, not sequencing):
The CLI accepts a positional checkpoint path and boolean flags. It reads the text through a small seam function, calls the injected validator with the flags as keyword arguments, and maps the result to an exit code and streams. The remediation extraction and the guard modify the validator only by removal of the moved block, one import addition, and the guard.
	
#### Files/modules to change:
- New: `scripts/dev_tools/validate_orchestrator_state_cli.py`.
- New: `scripts/dev_tools/_orchestrator_state_remediation_loop.py`.
- Modified: `scripts/dev_tools/validate_orchestrator_state.py` (block removal, import, guard).
- New: `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py`.
- Modified documentation: `.claude/skills/orchestrate/SKILL.md` (the two "local CLI" references near lines 84 and 187, and the `--require-model-routing` attribution near line 176 only if it is inconsistent with the new text), `.claude/rules/orchestrator-state.md` (the flag description near line 95 and the CLI contract paragraph), and the byte-identical mirrors `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.
- Conditional: `.agents/skills/orchestrate/SKILL.md` and its bundled mirror only if they carry the same "local CLI" text (research found no local-CLI mention there).
- Optional: `docs/features/epics/parallel-orchestration/epic-status.md` (lines near 298-301, stale statement that the bare module exits 0 silently). Editing it is a planner judgment: append a dated "resolved by #464" note or reword. It is not a bundled mirror.

#### Functions/classes/CLI commands impacted:
- New `build_parser() -> argparse.ArgumentParser`: positional `path`; flags `--require-complete`, `--require-model-routing`, `--require-pr-creation-ready`, `--require-codex-model-routing`, `--require-codex-topology`, each `store_true`, default `False`. The last two provide parity with the dispatcher `orchestrator-state` subcommand. `strict_route_membership` is not exposed.
- New `main(argv: Sequence[str] | None = None, *, validate: Callable[..., list[str]]) -> int`. The read seam (a small function, for example `_read_checkpoint_text(path)`, reading UTF-8 text) is defined in the CLI module so tests can replace it without temporary files.
- `validate_orchestrator_state.py`: module-level `if __name__ == "__main__":` guard added; `_validate_remediation_cycle`, `_validate_remediation_loop`, and their constants relocated.
- Invocation: `python -m scripts.dev_tools.validate_orchestrator_state <path> [--require-complete] [--require-model-routing] [--require-pr-creation-ready] [--require-codex-model-routing] [--require-codex-topology]`.
- Unchanged: the dispatcher `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state ...`.

#### Data flow and validation changes:
1. `main` parses `argv` with `build_parser()`.
2. The path is read through the seam as UTF-8 text.
3. The text is passed to the injected `validate` with `require_complete`, `require_model_routing`, `require_pr_creation_ready`, `require_codex_model_routing`, and `require_codex_topology` forwarded unchanged; `strict_route_membership` is left at the validator default.
4. An empty error list yields the success line on stdout and exit 0. A non-empty list yields each error on its own stderr line, in returned order, and exit 1.
5. Validation logic is not altered; invalid JSON continues to be reported by the validator as an error string (exit 1).

#### Error handling and logging updates:
- Exit codes: 0 pass; 1 validation errors; 2 checkpoint path missing, unreadable, or not decodable as UTF-8; argparse usage errors also exit 2 (argparse default).
- Only `OSError` and `UnicodeDecodeError` are caught, and only around the read. On such an error the CLI writes a single stderr diagnostic naming the path and the cause, no traceback, and returns 2. No broad catch-all is added.
- Success line on stdout is identical to the dispatcher's: `orchestrator-state validation passed: <path>`. Nothing is written to stderr on success.
- No logging framework is introduced; output is limited to stdout and stderr as above.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. The change is additive except for the behavior-preserving extraction. Rollback is a revert of the change set; no data or configuration migration is involved.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

| Outcome | Exit | stdout | stderr |
|---|---|---|---|
| Valid checkpoint | 0 | `orchestrator-state validation passed: <path>` | empty |
| One or more validation errors | 1 | empty | each error on its own line, in validator order |
| Path missing, unreadable, or not UTF-8 | 2 | empty | one diagnostic line naming the path and cause, no traceback |
| Unknown flag or missing positional | 2 | empty | argparse usage message |

Input is a filesystem path to a JSON checkpoint (for example `artifacts/orchestration/orchestrator-state.json`).

#### Required configuration keys and defaults:
None. All flags default to `False`.

#### Backward-compatibility expectations:
- `validate_orchestrator_state_text` signature and results are unchanged. Existing importers, the dispatcher, and `vars(state_validator)[...]` private-name accesses in existing tests (`_validate_list_delegation_receipts`, `_validate_namespaced_delegation_receipts`, `_build_portable_envelope`) continue to resolve because those names are not moved.
- No repository module imports the moved remediation names other than `validate_orchestrator_state.py` (research section 4).
- Exit 0 and 1 semantics match the dispatcher for the same in-memory text.

#### Performance constraints (latency/throughput/memory):
None specified. The CLI reads one file and runs a pure in-memory validation; no performance regression is expected and none needs measurement beyond the normal test run.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Checkpoint files are UTF-8 JSON, as the dispatcher already assumes.
  - The Poetry environment provides Python with `argparse`; no new dependency is needed.
  - Research claims that were derived from code rather than executed (the reproduction, `diff -q` mirror parity) must be re-verified by the implementer with an executed command.
- Constraints (budget, performance, compatibility):
  - 500-line file cap for production and test files.
  - Pyright strict is enabled; type `argparse.Namespace` attributes with `cast(...)` as `scripts/dev_tools/skill_bundle_contract_cli.py` does.
  - No temporary files in tests; no real filesystem, wall-clock, or subprocess use in unit tests.
  - Mirror parity: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` requires the repo `.claude/**` files and the bundled copies to match, so each documentation edit is applied to both copies in the same change.
  - Skill bundle contract (#762): `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` must remain green after any SKILL.md edit.
- External dependencies (services, libraries, releases):
  - None. No release or version bump is required by this fix.

## Data / API / Config Impact
- User-facing or API changes:
  - New CLI surface `python -m scripts.dev_tools.validate_orchestrator_state <path> [flags]` with the exit-code contract above. The dispatcher CLI is unchanged.
  - `.claude/rules/orchestrator-state.md` (and its bundled mirror): state that the flag `--require-model-routing` and its companions are accepted by both the dispatcher `orchestrator-state` subcommand and the bare-module CLI; give the literal `python -m scripts.dev_tools.validate_orchestrator_state` command and the exit-code contract in one short paragraph (rules files are not scanned by the skill bundle guard).
  - `.claude/skills/orchestrate/SKILL.md` (and its bundled mirror): replace "the local CLI" (near lines 84 and 187) with named surfaces in citation form only: the MCP tool `mcp__drm-copilot__validate_orchestration_artifacts` as the portable surface, and the repository-local validator CLIs as documented in `.claude/rules/orchestrator-state.md`. SKILL.md refers to the rules document and contains no `python -m` or `scripts/...` invocation form.
- Data or migration considerations:
  - None. No checkpoint schema or existing checkpoint changes.
- Logging/telemetry updates (if any):
  - None.
- Compatibility notes (CLI flags, config schemas, versioning):
  - Flags mirror the dispatcher `orchestrator-state` subcommand. No schema or version change.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: exit code and stderr for valid checkpoint, invalid checkpoint, missing path, unreadable path, each of the three flags.
- [ ] Integration scenario to retest: `python -m scripts.dev_tools.validate_orchestrator_state` against a missing path and against a valid checkpoint.
- [ ] Manual verification notes: compare exit codes with the `validate_orchestration_artifacts.py orchestrator-state` dispatcher for the same input.

- Regression tests to add or update:
  - Add `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` (mirrors the flat `tests/scripts/dev_tools/` layout; the existing `test_validate_orchestrator_state.py` is not extended).
  - Add tests for `_orchestrator_state_remediation_loop.py` only if the existing `test_validate_orchestrator_state_remediation_loop.py` (exercising the block through `validate_orchestrator_state_text`) does not already cover the moved code after the extraction; that file must pass unchanged.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - Valid checkpoint (built with `build_valid_orchestrator_state()` from `validate_orchestrator_state_test_support.py` or `build_complete_small_state()` for `--require-complete`) returns 0, success line on stdout, empty stderr.
  - Invalid checkpoint returns 1 with each error on its own stderr line, in order.
  - Each flag (`--require-complete`, `--require-model-routing`, `--require-pr-creation-ready`, `--require-codex-model-routing`, `--require-codex-topology`) is forwarded as `True` when present and `False` when absent, proven with an injected recording fake validator (no routing-valid checkpoint needs to be constructed).
  - Missing path (read seam raises `FileNotFoundError`) returns 2 with a single diagnostic naming the path; no traceback.
  - Unreadable path (`PermissionError`, `IsADirectoryError`) returns 2.
  - Non-UTF-8 content (`UnicodeDecodeError`) returns 2.
  - One guard test using `runpy.run_module("scripts.dev_tools.validate_orchestrator_state", run_name="__main__")` inside `pytest.raises(SystemExit)`, with `sys.argv` monkeypatched and the CLI read seam stubbed; marked with a `filterwarnings` ignore for the expected `runpy` "found in sys.modules" RuntimeWarning. The guard line is excluded from coverage by the repository `exclude_lines` entry, so this test protects the guard wiring, not the coverage number.
  - Parity test: the CLI and the dispatcher (`validate_orchestration_artifacts.main(["orchestrator-state", ...])` with its read function stubbed) return the same exit code for the same in-memory valid and invalid text.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Unknown flag and missing positional argument raise `SystemExit(2)`.
  - Empty file text and non-JSON text yield exit 1 through the validator's own error string.
  - Read errors other than `OSError`/`UnicodeDecodeError` are not swallowed (no catch-all).
- Error handling and logging verification:
  - `capsys` assertions on exact `captured.out` and `captured.err` for each outcome; on exit 2 stdout is empty and stderr is a single line.
- Coverage impact and targets for changed lines/modules:
  - Line coverage >= 85% and branch coverage >= 75% for the new modules; no reduction on changed lines. Command form: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py tests/scripts/dev_tools/test_validate_orchestrator_state.py --cov=scripts.dev_tools.validate_orchestrator_state_cli --cov=scripts.dev_tools._orchestrator_state_remediation_loop --cov-branch --cov-report=term-missing` (dotted module names; a `--cov=<path>.py` form measures nothing).
- Toolchain commands to run (format → lint → type-check → test):
  - Run the repository Python toolchain loop per `.claude/rules/python.md` (Black, Ruff, Pyright, pytest with coverage), restarting on any failure or auto-fix, plus `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` after the documentation edits.
- Manual validation steps (if required):
  - Execute the issue reproduction before and after the change and record exit codes: missing path (expect 2 with a diagnostic), a valid checkpoint (expect 0), an invalid checkpoint (expect 1), and compare the pass/fail exit codes with the dispatcher for the same input. Record the measured line count of `validate_orchestrator_state.py` after the change.
  - Verify mirror byte identity for the edited files with an executed comparison command.


## Acceptance Criteria
- [x] `python -m scripts.dev_tools.validate_orchestrator_state <path>` runs an argparse-based `main()` reached through a `__main__` guard; the guard test in `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` passes.
- [x] The CLI accepts `--require-complete`, `--require-model-routing`, and `--require-pr-creation-ready` (and, for dispatcher parity, `--require-codex-model-routing` and `--require-codex-topology`) and forwards each to `validate_orchestrator_state_text` unchanged; tests with a recording validator prove `True` when present and `False` when absent.
- [x] The CLI prints each returned validation error to stderr, one per line in returned order, and exits 1 when the error list is non-empty.
- [x] For a missing, unreadable, or non-UTF-8 checkpoint path the CLI exits 2 and writes a single stderr diagnostic naming the path, with no traceback; only `OSError` and `UnicodeDecodeError` are handled.
- [x] For a valid checkpoint the CLI exits 0, writes `orchestrator-state validation passed: <path>` to stdout, and writes nothing to stderr.
- [x] Executed reproduction evidence: the issue's reproduction command exits non-zero with a diagnostic for a nonexistent path after the change, and the before-change exit 0 is recorded for comparison.
- [x] `scripts/dev_tools/validate_orchestrator_state.py` does not exceed the repository 500-line limit, no new production or test file exceeds that limit, and the measured post-change line count of the validator is recorded in the evidence with headroom for #523.
- [x] The remediation-loop block is moved verbatim to `scripts/dev_tools/_orchestrator_state_remediation_loop.py`; `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py` and the rest of the existing validator test suite pass unchanged.
- [x] Existing validator behavior and existing checkpoints are unchanged (byte-identical error lists); no hook, PowerShell, TypeScript, dispatcher, or #523 `blocked_reason` change is included.
- [x] Line coverage >= 85% and branch coverage >= 75% for `scripts.dev_tools.validate_orchestrator_state_cli` and `scripts.dev_tools._orchestrator_state_remediation_loop`, measured with dotted `--cov=` module names and `--cov-report=term-missing`.
- [x] Documentation in `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md` names both the dispatcher CLI and the bare-module CLI where it previously said only "the local CLI" or described the flags; the same edits are byte-identical in the bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/`; no `.claude/skills/*/SKILL.md` contains a `python -m scripts.dev_tools...` or `scripts/...` invocation form; the `.agents` copies are edited only if they carry the same text.
- [x] `test_skill_bundle_contract_repo.py` and `test_push_down_claude_resource_contracts.py` pass after the documentation edits.
- [x] Full toolchain pass completed (format → lint → type-check → test), with no failing stage in a single pass.

## Risks & Mitigations
- Technical or operational risks:
  - The extraction could alter validator behavior or break a name consumed elsewhere. Research found no importer of the moved names outside the validator.
  - Double execution of the validator under `python -m` if the CLI imported it.
  - A SKILL.md edit that adds an invocation form fails the skill bundle guard (#762).
  - Documentation edits applied to only one of the two copies fail bundle parity tests.
  - The exit-code contract differs from the dispatcher for a missing path (2 versus a traceback with exit 1); a caller that treats any non-zero code alike is unaffected.
  - Research statements not executed in that session (reproduction, mirror `diff -q`) could be wrong.
- Mitigations and rollbacks:
  - Move the block verbatim, keep the existing remediation-loop tests unchanged, and run the full validator test suite.
  - Inject the validator callable so the CLI never imports the validator module.
  - Describe the module CLI only in the rules document; SKILL.md uses citation form and points to it; run the skill bundle guard after editing.
  - Apply each documentation edit to both copies and run the parity tests.
  - Re-execute the reproduction and a mirror comparison during implementation and record the results.
  - Rollback is a revert of the change set.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge to the epic integration branch `epic/orchestrator-state-contract-correctness-integration` (epic #771); no version bump or publish step is specific to this fix.
- Post-fix monitoring or clean-up tasks:
  - Update or annotate the stale note in `docs/features/epics/parallel-orchestration/epic-status.md` (optional, planner judgment).
  - Possible follow-up issues, not part of this change: the dispatcher's uncaught traceback for a missing or unreadable path (exit 1 indistinguishable from validation errors); adjacent stale statements in `.claude/skills/orchestrate/SKILL.md` near lines 191 and 221.
  - Child #523 proceeds after this fix using the headroom created by the extraction.
- Links: issue #464, epic #771 (`docs/features/epics/orchestrator-state-contract-correctness/epic.md`), PR #463 (origin observation), issues #762 (skill bundle contract), #475 (PowerShell completion port), #523 (dependent child), #769 (out of scope), related docs `research/2026-09-29T14-35-cli-entry-point-research.md` and `plan.2026-09-29T14-20.md`.
