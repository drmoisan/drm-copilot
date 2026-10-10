# orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails (Spec)

- **Issue:** #798
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T17-40
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Branch:** `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`
- **Requirements source:** `issue.md` (this folder)
- **Research:** `research/research.2026-10-08T17-28.md` (this folder)
- **user-story.md:** NONE (full-bug default). This spec is the sole acceptance-criteria source.

## Context

This issue covers two usability defects in the orchestration artifact validator.

1. **Undocumented required checkpoint keys.** The orchestrator-state check rejects any checkpoint that lacks a top-level `last_updated` key. Neither `.claude/skills/orchestrate/SKILL.md` nor `.claude/rules/orchestrator-state.md` documents that key, so a checkpoint written from those documents fails validation. The research shows the defect is broader than `last_updated`: neither document lists the required-key set at all.
2. **File-path invocation fails.** `python scripts/dev_tools/validate_orchestration_artifacts.py --help` fails with `ModuleNotFoundError: No module named 'scripts'`. Only the `python -m scripts.dev_tools.validate_orchestration_artifacts` form works.

Environment (from issue): Windows 11 Pro 10.0.26200, repository Poetry environment.

Impact / Severity: Medium. Each defect costs an agent one failed round before it finds the workaround. The agent hits the missing-key error at the point where PR creation is gated.

## Problem Statement (current-tree citations)

All line numbers below come from the research record, which checked them against the current tree. The issue text cites `validate_orchestrator_state.py:63` and loop lines `401-403`. Those numbers are stale and are superseded here.

### Defect 1: required keys undocumented

- `scripts/dev_tools/validate_orchestrator_state.py` lines 54-77 declare `REQUIRED_STATE_KEYS` with 22 members (research N1, cross-checked against the TypeScript and PowerShell ports). `last_updated` is at line 68.
- Lines 329-331 (`validate_orchestrator_state_text`) run `for key in REQUIRED_STATE_KEYS: if key not in state_map: errors.append(f"Checkpoint missing required key: {key}")`. The check runs regardless of `--require-complete`, `--require-pr-creation-ready`, `--require-model-routing`, and the two Codex flags. It is skipped only for a `portable_orchestration_handoff` envelope (lines 322-323). It checks presence only: any JSON value, including `null`, passes.
- The TypeScript port (`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` lines 60-83, `last_updated` at line 74, enforcement at lines 346-351) and the PowerShell port (`.claude/lib/orchestrator-state/OrchestratorState.psm1` lines 38-61, `last_updated` at line 52, enforcement at lines 261-267) carry the same keys in the same order and also check presence only.
- `.claude/rules/orchestrator-state.md` (276 lines) does not list the required top-level keys. 17 of the 22 keys, including `last_updated`, do not appear anywhere in the file (research N2). Line 119 refers to "the required-key check", and line 229 refers to `REQUIRED_STATE_KEYS`, but neither states the set.
- `.claude/skills/orchestrate/SKILL.md` (446 lines) does not list the required keys either. 11 of the 22 keys, including `last_updated`, never appear (research N3). Line 270 in `## Issue Number Consistency` says "Record as `issue_num` in the checkpoint", but the validator requires the hyphenated key `issue-num`.
- `.claude/agents/orchestrator.md` lines 171-184 (`## Checkpoint Persistence`) list 18 of the 22 keys. The list omits `relativeFile`, `long-name`, `work-mode`, and `plan-path`, and names the step statuses only as a range (line 178: "`step5_status` through `step10_status`"). A checkpoint written from this file also fails validation.

### Defect 2: file-path invocation

- `scripts/dev_tools/validate_orchestration_artifacts.py` is 495 lines long, against a 500-line limit. Lines 11-14 hold the stdlib imports (`argparse`, `re`, `sys`, `pathlib.Path`). Lines 16-43 hold first-party `from scripts.dev_tools.<module> import ...` statements, and line 16 is where execution first fails. `main(argv)` spans lines 457-491, and the `__main__` guard is at lines 494-495.
- Under `python <file>`, `sys.path[0]` is `scripts/dev_tools`, not the repository root, so the package `scripts` cannot be imported. No file under `scripts/` changes `sys.path`. The only precedent is `tests/conftest.py` lines 39-64.

## Scope & Non-Goals

### In scope

- Document every member of `REQUIRED_STATE_KEYS` in a new `## Required Top-Level Keys` section of `.claude/rules/orchestrator-state.md`, including the meaning of `last_updated`.
- Reference `last_updated` and the new rule section from `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling`, and correct the `issue_num` checkpoint-key instruction at skill line 270.
- Complete the checkpoint key list in `.claude/agents/orchestrator.md` `## Checkpoint Persistence`.
- Update the byte-identical bundled mirror of each amended `.claude/` file.
- Make file-path invocation of `scripts/dev_tools/validate_orchestration_artifacts.py` work, and document both invocation forms in the rule's `## Bare-Module CLI Contract`.
- Add a documentation-parity test module and an invocation-contract test module.

### Out of scope / non-goals

- Any change to validator behavior in Python (`scripts/dev_tools/validate_orchestrator_state.py`), TypeScript (`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`), or PowerShell (`.claude/lib/orchestrator-state/OrchestratorState.psm1`, `.claude/hooks/validate-orchestrator-output.ps1`). This includes ISO-8601 parsing or format validation of `last_updated`.
- File-path invocation support for the bare-module validator `scripts/dev_tools/validate_orchestrator_state.py`. It has the same class of defect, but it is documented only in `-m` form, so it is recorded as a follow-up.
- Codex surfaces: `.agents/skills/orchestrate/SKILL.md` (which has the same `issue_num` sentence at line 444), `.agents/skills/orchestrator-state/SKILL.md`, and their bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- The `## Step S9 — CI Green Gate` section of the orchestrate skill (concurrent issue #841) and the `## Issue-Adoption Scope and Backward Compatibility` / `## Invariants (issue_adoption object)` sections of the rule (concurrent issue #849).
- Optional follow-up, not required here: cross-runtime key-list parity tests that parse the TypeScript array and the PowerShell array and assert ordered equality with the Python tuple.
- Optional follow-up, not required here: required-key documentation for the C#/PowerShell orchestration-state-machine skills, which list only a subset of the keys.

### Explicitly excluded systems

- MCP tool registration and the VS Code extension runtime. No source changes are made there.

## Root Cause Analysis

- Defect 1: the required-key tuple grew after the skill, rule, and agent-persona text were written, and nothing ties the tuple to the documentation. The rule describes the required-key check without stating the set it checks.
- Defect 2: the dispatcher imports first-party modules through the absolute package `scripts` and depends on the repository root being on `sys.path`. Running it by file path does not put the root there, and the script does not add it.

## Decisions and Assumptions

The operator was not available for questions. Each decision below is recorded as an explicit assumption that an implementer must follow.

- **D1 (assumption): required-key documentation lives in the rule.**
  - Add a `## Required Top-Level Keys` section to `.claude/rules/orchestrator-state.md`, placed directly after `## Foreign Schema Warning (do not copy verbatim)` and before `## Scope and Backward Compatibility`.
  - The section lists every member of `REQUIRED_STATE_KEYS` as a bullet in the form `` - `<key>` ``.
  - It names `REQUIRED_STATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py` as the authority and names the TypeScript and PowerShell mirrors.
  - It states that the check is unconditional and presence-only, and that it reports `Checkpoint missing required key: <key>`.
  - It defines `last_updated` as an ISO-8601 UTC date-time string (example `2026-10-08T17:28:00Z`) recording when the checkpoint was last written. The value is rewritten on every checkpoint write: after every completed step and every state transition, including halts.
  - It states that the validators check presence only and do not parse the value, so `null` passes the presence check.
  - No validator behavior changes in any runtime.
- **D2 (assumption): the skill references the rule and does not spell any invocation.**
  - `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling` gains one item. That item names `last_updated`, states its refresh rule, and points to the rule's `## Required Top-Level Keys` section.
  - The skill text must not contain `python -m scripts...` or `python scripts/...py`. `scripts/dev_tools/skill_bundle_contract.py` classifies such references as `not-in-bundle`, and `test_every_skill_script_reference_is_bundled` would then fail.
  - The research confirms that line 270 (`## Issue Number Consistency`, "Record as `issue_num` in the checkpoint") is a checkpoint-key instruction. It is corrected to name `issue-num`.
  - The `<issue_num>` placeholder in the delegation-prompt template at line 274 is not a checkpoint key and is left unchanged.
  - No edit is made inside `## Step S9 — CI Green Gate`.
- **D3 (assumption): the agent persona's key list is completed.**
  - `.claude/agents/orchestrator.md` `## Checkpoint Persistence` adds `relativeFile`, `long-name`, `work-mode`, and `plan-path`, and names `step5_status`, `step6_status`, `step7_status`, `step8_status`, `step9_status`, and `step10_status` individually.
  - The persona list does not have to be exhaustive beyond `REQUIRED_STATE_KEYS`. Its existing promotion-receipt bullets are retained.
- **D4 (assumption): mirrors move with their sources.** Each amended `.claude/` file has its bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/...` updated to be byte-identical in the same change. After any rebase conflict resolution, re-copy the mirrors from their sources.
- **D5 (assumption): a minimal bootstrap enables file-path invocation.**
  - In `scripts/dev_tools/validate_orchestration_artifacts.py`, insert one comment line and one statement between the stdlib imports and the first `scripts.dev_tools` import:
    ```python
    # File-path invocation has no package context; make the repo root importable.
    sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []
    ```
  - `__package__` is falsy under `python <file>` and under `runpy.run_path`. It is `"scripts.dev_tools"` under `-m` and under normal import. As a result, `sys.path` is unchanged for every existing caller.
  - The statement appends rather than prepends, so it does not shadow an installed distribution.
  - Ruff exempts an augmented assignment to `sys.path` from E402. This was verified from the Ruff source and documentation, not by running Ruff, so the toolchain loop must confirm it.
  - Fallback, if Ruff reports E402 or I001 against this form: use an `if not __package__:` block plus a per-file `E402` ignore for this file in `pyproject.toml` `[tool.ruff.lint.per-file-ignores]`, with a comment that justifies it (bootstrap required before first-party imports for file-path invocation).
  - The file must stay at or under 500 lines.
  - The rule's `## Bare-Module CLI Contract` paragraph documents both supported dispatcher forms with identical flags and exit codes: `python -m scripts.dev_tools.validate_orchestration_artifacts` and `python scripts/dev_tools/validate_orchestration_artifacts.py`. The bare-module validator remains documented in `-m` form only.
- **D6 (assumption): the new tests are in-process and isolated.**
  - A documentation-parity test module asserts, in both directions, that the keys listed in the rule's `## Required Top-Level Keys` section equal `REQUIRED_STATE_KEYS`.
  - An invocation-contract test module uses `runpy.run_path` in process. For the file-path tests, it first removes the repository root from `sys.path` and evicts `scripts` and every `scripts.*` entry from `sys.modules`, so the tests fail with `ModuleNotFoundError` before the fix. It restores `sys.path` and the original module objects afterward.
  - Neither module starts a subprocess or creates a temporary file.

## Proposed Fix

### Design summary (what changes where)

| Change | File(s) |
|---|---|
| New `## Required Top-Level Keys` section (D1) | `.claude/rules/orchestrator-state.md` + mirror |
| Dispatcher invocation forms in `## Bare-Module CLI Contract` (D5) | `.claude/rules/orchestrator-state.md` + mirror |
| `last_updated` item in `## Checkpoint Handling`; line 270 `issue_num` -> `issue-num` (D2) | `.claude/skills/orchestrate/SKILL.md` + mirror |
| Complete `## Checkpoint Persistence` key list (D3) | `.claude/agents/orchestrator.md` + mirror |
| `sys.path` bootstrap (D5) | `scripts/dev_tools/validate_orchestration_artifacts.py` |
| Documentation-parity tests (D6) | `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` (new) |
| Invocation-contract tests (D6) | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (new) |
| Conditional E402 per-file ignore (D5 fallback only) | `pyproject.toml` |

### Boundaries and invariants to preserve

- Validators in all three runtimes keep identical behavior: same required-key set, same presence-only semantics, same messages, same exit codes.
- `python -m scripts.dev_tools.validate_orchestration_artifacts ...` and `import scripts.dev_tools.validate_orchestration_artifacts` leave `sys.path` unchanged.
- Both invocation forms reach the same `main()`. Exit codes, the stdout success line, and the stderr error lines are identical. Relative artifact paths still resolve against the working directory.
- The orchestrate skill contains no `python -m scripts...` or `python scripts/...py` text.
- No edits are made inside the orchestrate skill's `## Step S9 — CI Green Gate` section or the rule's issue_adoption sections.

### Dependencies or blocked work

- Concurrent issues #841 (orchestrate skill S9 section and its mirror) and #849 (rule issue_adoption area and its mirror) touch the same files. Rebase on `main` before PR creation. After resolving any conflict, regenerate each mirror from its source.

### Implementation strategy

#### Files/modules to change

See "Files to Write" below.

#### Functions/classes/CLI commands impacted

- Module import path of `scripts.dev_tools.validate_orchestration_artifacts`: one module-level statement is added. `main()` and the subcommands are unchanged.
- CLI: `python scripts/dev_tools/validate_orchestration_artifacts.py <subcommand> ...` becomes a supported entry point.

#### Data flow and validation changes

None. Validation logic is unchanged.

#### Error handling and logging updates

None. Existing argparse and validator diagnostics are unchanged.

#### Rollback considerations

Revert the change. No data, schema, or configuration migration is involved.

### Technical specifications

#### Inputs/outputs and formats

- `last_updated` (documented contract only): an ISO-8601 UTC date-time string, for example `2026-10-08T17:28:00Z`. Only presence is enforced.
- Dispatcher CLI: the arguments, stdout, stderr, and exit codes are unchanged in both invocation forms.

#### Required configuration keys and defaults

No new configuration. A `pyproject.toml` per-file ignore is added only under the D5 fallback.

#### Backward-compatibility expectations

Existing checkpoints keep their current validation result, including those with non-UTC or placeholder `last_updated` values. Existing `-m` callers and importers see no change.

#### Performance constraints

Negligible. The bootstrap is one module-level statement executed once per import.

## Files to Write

These are all the repository files this fix writes, excluding this feature folder's own spec, plan, evidence, and review artifacts. The list matches research item 7. Items 6 and 7 are required under D3, and item 10 is conditional under the D5 fallback.

1. `scripts/dev_tools/validate_orchestration_artifacts.py`
2. `.claude/rules/orchestrator-state.md`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
4. `.claude/skills/orchestrate/SKILL.md`
5. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
6. `.claude/agents/orchestrator.md`
7. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`
8. `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` (new)
9. `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (new)
10. `pyproject.toml` (conditional: only if Ruff reports E402 or I001 against the selected statement form)

Files that must not change: `scripts/dev_tools/validate_orchestrator_state.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, `.claude/lib/orchestrator-state/OrchestratorState.psm1`, `.claude/hooks/validate-orchestrator-output.ps1`.

## Assumptions, Constraints, Dependencies

- Assumptions: D1-D6 above. The research could not confirm whether the Poetry environment installs the repository root as an editable package (no shell was available). The issue reports the failure as reproduced on `main` at `ae7c7779`. The invocation-contract test isolates import state, so its outcome does not depend on that environment detail.
- Constraints:
  - 500-line limit per production and test file.
  - Unit tests may not use subprocesses or temporary files.
  - Pyright strict.
  - Black line length 88.
  - Ruff rule set includes `E402`.
  - Coverage excludes `if __name__ == "__main__":` blocks, so the bootstrap must sit at module level.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: a second supported CLI invocation form for the dispatcher. Documentation now lists the required checkpoint keys.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: no flag, schema, or exit-code change.

## Test Strategy

- Regression tests (new):
  - `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`
    - Fixture: removes every `sys.path` entry that resolves to the repository root (via `monkeypatch.setattr(sys, "path", ...)`). Removes `scripts` and every `scripts.*` key from `sys.modules` via `monkeypatch.delitem`. On teardown, it discards any `scripts.*` module first imported during the test.
    - `test_file_path_invocation_help_exits_zero`: `runpy.run_path(<script>, run_name="__main__")` with argv `[<script>, "--help"]` raises `SystemExit(0)`, and stdout contains `orchestrator-state`. This test fails before the fix with `ModuleNotFoundError`.
    - `test_file_path_invocation_validates_committed_fixture`: argv `orchestrator-state tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json` (a committed file). The exit code equals `main([...])` for the same arguments.
    - `test_module_invocation_leaves_sys_path_unchanged`: `runpy.run_module("scripts.dev_tools.validate_orchestration_artifacts", run_name="__main__")` with `--help` exits 0 and leaves `sys.path` equal to its pre-call snapshot.
    - `test_file_path_bootstrap_appends_repo_root_once`: after the isolated `run_path`, the repository root appears in `sys.path` exactly once.
  - `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` (reads committed documents in place)
    - `test_required_key_is_documented_in_rule`, parametrized over `REQUIRED_STATE_KEYS`: each key appears as a backticked bullet in the rule's `## Required Top-Level Keys` section.
    - `test_rule_documented_keys_equal_required_state_keys`: the set of keys extracted from that section's bullet lines equals `set(REQUIRED_STATE_KEYS)`.
    - `test_parity_comparison_detects_undocumented_and_extra_keys`: a negative control. It calls the module's comparison helper on in-memory inputs, once with `REQUIRED_STATE_KEYS` plus a synthetic key absent from the documented set and once with a documented set that has an extra key. It asserts that each mismatch is reported.
    - `test_rule_documents_last_updated_semantics`: the section names `last_updated`, ISO-8601, UTC, and the rewrite-on-every-checkpoint-write rule.
    - `test_orchestrate_skill_references_last_updated_and_rule_section`: the skill's `## Checkpoint Handling` section contains `` `last_updated` `` and the text `Required Top-Level Keys`.
    - `test_orchestrate_skill_records_hyphenated_issue_num_key`: the `## Issue Number Consistency` section does not contain "Record as `issue_num`" and does contain "Record as `issue-num`".
    - `test_orchestrator_agent_checkpoint_persistence_lists_required_keys`, parametrized over `REQUIRED_STATE_KEYS`: each key appears backticked in `.claude/agents/orchestrator.md` `## Checkpoint Persistence`.
    - `test_rule_documents_both_dispatcher_invocation_forms`: `## Bare-Module CLI Contract` contains `python -m scripts.dev_tools.validate_orchestration_artifacts` and `python scripts/dev_tools/validate_orchestration_artifacts.py`.
- Existing tests that must stay green:
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  - `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`
  - `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`
  - `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py`
  - `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py`
  - every `tests/scripts/dev_tools/test_validate_orchestration_artifacts*.py` module
- Coverage: measure with `--cov=scripts.dev_tools`, a module path. A `.py` file path does not work here: it measures nothing.
- Toolchain: Black -> Ruff -> Pyright -> pytest with coverage. No TypeScript or PowerShell sources change.
- Manual validation: none required.

## Acceptance Criteria

- [x] `test_file_path_invocation_help_exits_zero` in `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` passes. It shows that `scripts/dev_tools/validate_orchestration_artifacts.py`, run via `runpy.run_path(..., run_name="__main__")` with `--help`, after the repository root is removed from `sys.path` and `scripts`/`scripts.*` are evicted from `sys.modules`, raises `SystemExit` with code 0 and prints usage containing `orchestrator-state`. The same test fails with `ModuleNotFoundError` on the pre-fix file.
- [x] `test_file_path_invocation_validates_committed_fixture` passes. It shows that file-path invocation with `orchestrator-state tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json` returns the same exit code as `main()` with the same arguments.
- [x] `test_module_invocation_leaves_sys_path_unchanged` passes. It shows that `-m` invocation (`runpy.run_module("scripts.dev_tools.validate_orchestration_artifacts", run_name="__main__")` with `--help`) exits 0 and leaves `sys.path` equal to its pre-call snapshot.
- [x] `test_file_path_bootstrap_appends_repo_root_once` passes. It shows that after file-path invocation the repository root appears in `sys.path` exactly once.
- [x] Neither new test module uses `subprocess` or creates temporary files. Each module restores `sys.path` and the original `scripts.*` module objects after each test.
- [x] `scripts/dev_tools/validate_orchestration_artifacts.py` contains a single module-level `sys.path` bootstrap, placed after the stdlib imports and before the first `scripts.dev_tools` import. The bootstrap is conditional on `not __package__`, and the file is at or under 500 lines.
- [x] `ruff check scripts/dev_tools/validate_orchestration_artifacts.py` reports no findings, and the file adds no `noqa` comment. If the D5 fallback is used, the only `pyproject.toml` change is an `E402` per-file ignore for this file, with a justification comment.
- [x] `.claude/rules/orchestrator-state.md` contains a `## Required Top-Level Keys` section between `## Foreign Schema Warning (do not copy verbatim)` and `## Scope and Backward Compatibility`. The section:
  - lists every member of `REQUIRED_STATE_KEYS` as a backticked bullet
  - names `scripts/dev_tools/validate_orchestrator_state.py` as the authority and names the TypeScript and PowerShell mirrors
  - states that the check is unconditional and presence-only, with the message `Checkpoint missing required key: <key>`
- [x] The `## Required Top-Level Keys` section defines `last_updated`. It must be an ISO-8601 UTC date-time string, rewritten on every checkpoint write, including halts. The section also states that the validators check presence only and do not parse the value. `test_rule_documents_last_updated_semantics` passes.
- [x] `test_required_key_is_documented_in_rule` (parametrized over `REQUIRED_STATE_KEYS`) and `test_rule_documented_keys_equal_required_state_keys` in `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` pass.
- [x] `test_parity_comparison_detects_undocumented_and_extra_keys` passes. It shows that the parity comparison reports a mismatch when `REQUIRED_STATE_KEYS` contains a key absent from the rule section, and when the rule section lists a key absent from `REQUIRED_STATE_KEYS`.
- [x] `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling` names `last_updated`, states its refresh rule, and references the rule's `## Required Top-Level Keys` section. `test_orchestrate_skill_references_last_updated_and_rule_section` passes.
- [x] `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency` instructs recording the checkpoint key as `issue-num`, not `issue_num`. `test_orchestrate_skill_records_hyphenated_issue_num_key` passes, and the `## Step S9 — CI Green Gate` section is unchanged relative to the merge base.
- [x] `.claude/skills/orchestrate/SKILL.md` contains no `python -m scripts.` or `python scripts/` invocation text, and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled` passes.
- [x] `.claude/agents/orchestrator.md` `## Checkpoint Persistence` names every member of `REQUIRED_STATE_KEYS` in backticks, with each step-status key written out individually. `test_orchestrator_agent_checkpoint_persistence_lists_required_keys` passes.
- [x] `.claude/rules/orchestrator-state.md` `## Bare-Module CLI Contract` documents both `python -m scripts.dev_tools.validate_orchestration_artifacts` and `python scripts/dev_tools/validate_orchestration_artifacts.py` with identical flags and exit codes, and keeps the bare-module validator in `-m` form only. `test_rule_documents_both_dispatcher_invocation_forms` passes.
- [x] The rule's `## Issue-Adoption Scope and Backward Compatibility` and `## Invariants (issue_adoption object)` sections are unchanged relative to the merge base.
- [x] Each amended `.claude/` file is byte-identical to its mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` and `::test_handoff_runtime_has_bundle_pack_and_effective_install_parity` pass.
- [x] No validator behavior change:
  - The branch diff does not modify `scripts/dev_tools/validate_orchestrator_state.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, `.claude/lib/orchestrator-state/OrchestratorState.psm1`, or `.claude/hooks/validate-orchestrator-output.ps1`.
  - `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py`, every `tests/scripts/dev_tools/test_validate_orchestration_artifacts*.py` module, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, and `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py` pass without modification.
- [x] The full Python toolchain passes in a single loop: `black --check`, `ruff check`, `pyright` (strict), and `pytest`. Coverage measured with `--cov=scripts.dev_tools` reports line coverage >= 85% and branch coverage >= 75% for `scripts/dev_tools/validate_orchestration_artifacts.py`, and every changed line in that file is covered.
- [x] Each new test module is at or under 500 lines.

## Risks & Mitigations

- Risk: Ruff flags the bootstrap under E402 or I001. Mitigation: the D5 fallback, a justified per-file ignore.
- Risk: the invocation test passes before the fix because `tests/conftest.py` already puts the repository root on `sys.path` and `scripts.*` is cached. Mitigation: the D6 isolation fixture, plus confirmation that the test fails against the pre-fix file.
- Risk: test-order coupling from evicted modules. Mitigation: teardown restores the original module objects and discards modules first imported during the test.
- Risk: merge conflicts with #841 and #849 on shared files. Mitigation: confine edits to the named sections, rebase before PR creation, and regenerate the mirrors from their sources.
- Rollback: revert the commit. No state migration is involved.

## Rollout & Follow-up

- Release/rollout: normal PR into `main`. The bundled mirrors ship with the next extension package.
- Follow-up candidates (not required here):
  - file-path bootstrap for `scripts/dev_tools/validate_orchestrator_state.py`
  - cross-runtime key-list parity tests for the TypeScript and PowerShell ports
  - the `issue_num` wording in `.agents/skills/orchestrate/SKILL.md` line 444
  - required-key coverage in the orchestration-state-machine skills
- Links: issue https://github.com/drmoisan/drm-copilot/issues/798; research `research/research.2026-10-08T17-28.md`.
