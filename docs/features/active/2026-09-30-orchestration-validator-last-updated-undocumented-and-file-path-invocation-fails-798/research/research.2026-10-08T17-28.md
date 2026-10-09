# Research: orchestration validator `last_updated` undocumented and file-path invocation fails (Issue #798)

- Issue: #798
- Branch: `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`
- Work mode: full-bug
- Requirements source: `issue.md` in this feature folder
- Researched: 2026-10-08T17-28
- All line numbers below were verified against the current worktree tree, not the issue text. The issue text cites `validate_orchestrator_state.py:63` and loop lines `401-403`; those are stale. The current locations are line 68 and lines 329-331.

## 1. Current State Analysis

### 1.1 REQUIRED_STATE_KEYS (Python authority)

`scripts/dev_tools/validate_orchestrator_state.py` lines 54-77 declare `REQUIRED_STATE_KEYS` (members on lines 55-76, 22 members, in this order):

`objective`, `change_budget_estimate`, `path_selected`, `promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`, `work-mode`, `plan-path`, `completed_steps`, `next_step`, `last_updated` (line 68), `step5_status`, `step6_status`, `step7_status`, `step8_status`, `step9_status`, `step10_status`, `delegation_receipts`, `blocked_reason`.

Enforcement: lines 327-331 of `validate_orchestrator_state_text` run `for key in REQUIRED_STATE_KEYS: if key not in state_map: errors.append(f"Checkpoint missing required key: {key}")`. The check is unconditional (it runs before, and independent of, `require_complete`, `require_pr_creation_ready`, `require_model_routing`, and the two Codex flags at lines 388-421). It is skipped only for a portable envelope (`kind == "portable_orchestration_handoff"`, line 322-323).

Value semantics: presence-only. `key not in state_map` accepts any JSON value, including `null`. No Python module parses, formats, or compares `last_updated`; a grep of `scripts/` for `last_updated` finds only the tuple member at line 68 and unrelated `extract_last_updated` (potential-to-issue). The step-status keys have additional vocabulary validation when present (`collect_step_status_errors`, lines 333-337); `blocked_reason` has vocabulary validation (lines 339-344).

### 1.2 TypeScript and PowerShell ports

| Runtime | Location | `last_updated` | Enforcement |
|---|---|---|---|
| TypeScript | `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` lines 60-83 (`REQUIRED_STATE_KEYS`, same 22 members, same order) | line 74 | lines 346-351, `if (!(key in stateMap))`, presence-only, identical message |
| PowerShell | `.claude/lib/orchestrator-state/OrchestratorState.psm1` lines 38-61 (`$script:REQUIRED_STATE_KEYS`, same 22 members, same order; comment line 37 "Pinned to REQUIRED_STATE_KEYS") | line 52 | lines 261-267, `$names -notcontains $key`, presence-only, identical message |
| PowerShell completion hook | `.claude/hooks/validate-orchestrator-output.ps1` line 359 | required with `objective`, `completed_steps`, `next_step` | presence-only |

`OrchestratorState.psm1` lines 138-145 state that every current validation of the ISO-8601 key family (`last_updated`, `started_at`, `completed_at`, `verified_at`) is presence-only and that `ConvertFrom-Json` coerces such values to `DateTime`. No test pins the TypeScript or PowerShell key list to the Python tuple; the "Pinned to" relationship is a comment only (grep of `tests/` and `extensions/drm-copilot/test/` for `REQUIRED_STATE_KEYS` finds no cross-runtime comparison).

Existing `last_updated` values in committed fixtures are mixed: `2026-09-17T12:00:00Z` (`tests/fixtures/worktree-resolution/pr-author/*/artifacts/orchestration/orchestrator-state.json`), `2026-04-07T10:00:00-04:00` (`tests/fixtures/orchestrator_state_remediation_loop_backcompat/*.json`), `2026-09-29T00-00` (`tests/fixtures/epic_wave_barrier/start-guard-matrix.json`), and `"t"` (`tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1` line 50). Introducing format validation would therefore change behavior for existing checkpoints in three runtimes.

### 1.3 Documentation coverage of the 22 keys

`.claude/rules/orchestrator-state.md` (276 lines) contains no enumeration of the required top-level keys. Of the 22 keys, only five appear anywhere in the file, and none of them is documented as a required key:

- `blocked_reason` (lines 68-129, vocabulary section), `next_step` and `delegation_receipts` (lines 177, 179, model-routing gate), `issue-num` (lines 239, 251, issue_adoption), `promotion-type` (line 257, prose "promotion-type resolution").
- Not mentioned at all (17): `objective`, `change_budget_estimate`, `path_selected`, `short-name`, `relativeFile`, `long-name`, `feature-folder`, `work-mode`, `plan-path`, `completed_steps`, `last_updated`, `step5_status`, `step6_status`, `step7_status`, `step8_status`, `step9_status`, `step10_status`.
- Line 119 says "Plain validation still reports an absent key through the required-key check", and line 229 says `issue_adoption` "is not a member of `REQUIRED_STATE_KEYS`", but the set itself is never stated.

`.claude/skills/orchestrate/SKILL.md` (446 lines) also has no required-key enumeration. Token mentions found: `objective` (prose only, e.g. line 34 "matching objective"), `next_step`, `issue-num` (line 36), `feature-folder` (lines 129, 276), `completed_steps` (lines 139, 323), `blocked_reason`, `plan-path` (line 141), `delegation_receipts` (lines 177, 390-399), `step6_status` (lines 257, 266), `step9_status` (lines 294-348), `work-mode` (line 379, prose "per work-mode"). Never mentioned (11): `change_budget_estimate`, `path_selected`, `promotion-type`, `short-name`, `relativeFile`, `long-name`, `last_updated`, `step5_status`, `step7_status`, `step8_status`, `step10_status`.

Adjacent contradiction in the same skill: line 270 instructs "Record as `issue_num` in the checkpoint", while the validator requires the hyphenated key `issue-num`. `issue_num` is not a required key. The same sentence appears in `.agents/skills/orchestrate/SKILL.md` line 444.

`.claude/agents/orchestrator.md` lines 171-184 (`## Checkpoint Persistence`) is the closest existing enumeration. It lists 18 of the 22 keys: it omits `relativeFile`, `long-name`, `work-mode`, and `plan-path`, and it writes the step statuses as "`step5_status` through `step10_status`" (lines 178), so `step6_status`-`step8_status` are not literally named. A checkpoint authored from this file also fails validation.

Surfaces that already document `last_updated` (for comparison only): `.claude/skills/csharp-orchestration-state-machine/SKILL.md` line 36, `.claude/skills/powershell-orchestration-state-machine/SKILL.md` line 36 (both list the first 14 keys under `## Required Checkpoint Fields`, lines 21-36), `.agents/skills/orchestrator-workflow/SKILL.md` line 100 (Codex; lists all 22 plus extras), and the epic/parallel skills for their own checkpoints. None defines a format or refresh rule.

### 1.4 Dispatcher CLI and the file-path failure

`scripts/dev_tools/validate_orchestration_artifacts.py` is 495 lines (500-line limit; headroom 5 lines).

- Lines 11-14: stdlib imports (`argparse`, `re`, `sys`, `pathlib.Path`).
- Lines 16-43: first-party imports, all `from scripts.dev_tools.<module> import ...`. Line 16 is the first failure point under file-path invocation.
- Lines 457-491: `main(argv)`; line 494-495: `if __name__ == "__main__": raise SystemExit(main())`.

Cause: under `python scripts/dev_tools/validate_orchestration_artifacts.py`, `sys.path[0]` is `scripts/dev_tools`, not the repository root, so the absolute package `scripts` is not importable unless the root is on the path by another route (for example a Poetry editable install of the root package; `pyproject.toml` lines 12-14 declare `packages = [{ include = "scripts" }]`). Whether the repository Poetry environment carries the editable root was not verified here (no shell tool was available to this research run); the issue reports the failure as reproduced on `main` at `ae7c7779`. `scripts/__init__.py` exists, so `-m scripts.dev_tools.validate_orchestration_artifacts` resolves from the repository root.

The bare-module validator `scripts/dev_tools/validate_orchestrator_state.py` has the same defect class (top-level `scripts.dev_tools` imports at lines 8-52; `__main__` guard at lines 426-429). The issue names only the dispatcher; the rule documents the bare module only in `-m` form (line 173).

### 1.5 Precedent for a sys.path bootstrap

- No file under `scripts/` modifies `sys.path`. The only precedent is `tests/conftest.py` lines 39-64 (`_ensure_repo_root_on_sys_path`, `Path(__file__).resolve().parents[1]`, guarded against duplicate insertion).
- No script in `scripts/dev_tools/` uses `__package__`, `__spec__`, or `runpy`. Every documented invocation in the repository uses `python -m scripts.dev_tools.<module>` (for example `scripts/dev_tools/skill_bundle_contract_cli.py` line 11).

### 1.6 Toolchain constraints on a bootstrap before imports

- Ruff: `pyproject.toml` lines 93-103 select `E` (includes E402), `F`, `I`, `B`, `UP`, `S`, `TID`, `TCH`; no per-file ignore exists for this module (lines 105-112).
- Ruff E402 exempts `sys.path` modifications between imports. Verified from the Ruff rule documentation ("This rule makes an exception for both `sys.path` modifications (allowing for `sys.path.insert`, `sys.path.append`, etc.) and `os.environ` modifications between imports") and from the Ruff source (`crates/ruff_python_semantic/src/analyze/imports.rs`, `is_sys_path_modification`), which accepts only an expression statement that calls a `sys.path` method or an augmented assignment to `sys.path`. An `if` statement wrapping `sys.path.insert(...)` is not exempt and would raise E402 on each of the following 10 import statements. This was verified by reading the source, not by running Ruff; the toolchain loop must confirm it.
- Pyright: strict mode (`pyproject.toml` line 143), `include` covers `scripts` and `tests`. Module-level `__package__` is typed `str | None`; no pyright constraint was identified for `sys.path += [...]`.
- Black: line length 88.
- Coverage: `pyproject.toml` lines 129-140 exclude `if __name__ == .__main__.:` blocks, so code placed inside the bottom guard is not measured, and code placed there cannot run before the failing top-level imports anyway.

### 1.7 Bundled mirrors and the tests that pin them

| Source file | Mirror (must be updated identically) | Pinning test |
|---|---|---|
| `.claude/rules/orchestrator-state.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 89-110; every distributable `.claude/**` file must exist in the bundle with equal UTF-8 text) |
| `.claude/skills/orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | same test, plus `test_handoff_runtime_has_bundle_pack_and_effective_install_parity` (lines 126-141; byte equality and `core` pack membership) |
| `.claude/agents/orchestrator.md` (if amended) | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` |

No `.github/` or `.codex/` file mirrors the rule or the Claude orchestrate skill. `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrator-state/SKILL.md` are separate Codex surfaces with their own content (not byte mirrors); `.agents/skills/orchestrate/SKILL.md` has a bundle copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`. Neither needs to change for this issue. No bundled Python copy of the dispatcher exists under `extensions/drm-copilot/resources/` (glob of `resources/{templates,scripts}/**/validate_orchestration_artifacts.py` returns nothing).

### 1.8 Skill-bundle contract constraint on skill text

`scripts/dev_tools/skill_bundle_contract.py` lines 64-68 and 293-299 extract `python <path>.py` and `python -m <dotted.module>` invocations from every `.claude/skills/*/SKILL.md` body. `PUBLISHED_ROOT_FOLDERS` is `(".claude", "config")` (line 38), so a `scripts/...` reference is classified `not-in-bundle` (lines 370-374) and fails `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled` (lines 29-43). Consequence: the orchestrate skill must not spell either invocation form (`python -m scripts.dev_tools.validate_orchestration_artifacts ...` or `python scripts/dev_tools/validate_orchestration_artifacts.py ...`). The skill already defers to "the repository-local validator CLI documented in `.claude/rules/orchestrator-state.md`" (lines 84 and 188); the invocation contract belongs in the rule, which this contract does not scan.

## 2. Candidate Approaches

### Defect 1: undocumented required keys

- **Selected: enumerate the full required-key set once in the rule, reference it from the skill, and pin it with a parity test.** Add a `## Required Top-Level Keys` section to `.claude/rules/orchestrator-state.md` that lists all 22 keys as a bulleted list, names `REQUIRED_STATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py` as the authority with the TypeScript and PowerShell mirrors, states that the check is unconditional and presence-only with the message `Checkpoint missing required key: <key>`, and documents `last_updated`. Add a Checkpoint Handling item to the orchestrate skill that names `last_updated`, states its refresh rule, and points to the rule section. Rationale: a single enumerated source in the rule avoids duplicating the list across documents; the parity test makes future growth of the tuple fail CI until the rule is updated, which addresses the stated root cause ("the key list in the validator grew after the skill and rule text were written").
- Rejected: document only `last_updated`. The parity check requested by the issue would immediately fail on 16 other keys absent from the rule.
- Rejected: add ISO-8601 parsing of `last_updated` to the validators. It would require coordinated Python, TypeScript, and PowerShell changes, would reject committed fixtures that use `YYYY-MM-DDTHH-mm`, `-04:00` offsets, or placeholder values, and is outside the issue's scope.

`last_updated` wording recommended for the rule: an ISO-8601 UTC date-time string (for example `2026-10-08T17:28:00Z`) recording when the checkpoint was last written; rewrite it on every checkpoint persistence (after every completed step and every state transition, including halts); the validators check presence only and do not parse the value.

### Defect 2: file-path invocation

- **Selected: make the file-path form work with a single E402-exempt bootstrap statement.** Insert, between the stdlib imports (line 14) and the first `scripts.dev_tools` import (line 16), one comment line and one statement:

  ```python
  # File-path invocation has no package context; make the repo root importable.
  sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []
  ```

  `__package__` is `None` under `python <file>` (and under `runpy.run_path`) and `"scripts.dev_tools"` under `-m` and normal import, so the path is unchanged for every existing caller. Appending (rather than prepending) avoids shadowing any installed distribution. The augmented assignment to `sys.path` is the form Ruff exempts from E402. The statement is about 81 characters (fits Black's 88). The file grows from 495 to 497 lines (blank-line normalization by Black/isort may add one more), which stays within the 500-line limit. If Ruff nevertheless reports E402 or I001, the fallback is an explicit `if not __package__:` block plus a justified `per-file-ignores` entry for E402 on this file in `pyproject.toml` (precedent: lines 105-112 carry justified per-file entries).
- Rejected: document `-m` as the only supported form and fail with a clear message. It still needs pre-import code (a `try`/`except ModuleNotFoundError` around the imports) of similar size and lint cost, and it leaves the issue's expected behavior ("Both invocation forms run") unmet.
- Rejected: an unconditional `sys.path.insert(0, ...)`. It mutates `sys.path` for every importer of the module, including the test suite and the MCP-adjacent callers.

Scope note: apply the bootstrap to the dispatcher only. The bare-module validator `validate_orchestrator_state.py` has the same defect class but the rule documents it only in `-m` form; record it as a follow-up rather than widening this fix.

## 3. Behavior Semantics

- Plain validation of a checkpoint that lacks any of the 22 keys continues to emit one `Checkpoint missing required key: <key>` per missing key, under every flag combination. No change to validator behavior.
- `python scripts/dev_tools/validate_orchestration_artifacts.py --help` exits 0 and prints the argparse usage from the repository root and from any working directory (the bootstrap derives the root from `__file__`, not the working directory). Relative artifact paths remain resolved against the working directory, as with `-m`.
- `python -m scripts.dev_tools.validate_orchestration_artifacts ...` and `import scripts.dev_tools.validate_orchestration_artifacts` leave `sys.path` unchanged.
- Exit codes, stdout success line, and stderr error lines are identical between the two invocation forms (both reach the same `main()`).
- Edge cases: a checkpoint key present with `null` passes the presence check (document this); the parity test must fail when a key is added to `REQUIRED_STATE_KEYS` without a rule entry and when the rule lists a key that is not in the tuple.

## 4. Requirements Mapping and Required File Changes

| Issue item | Design | Files |
|---|---|---|
| Document `last_updated` (format, refresh) in the rule | New `## Required Top-Level Keys` section (place it directly after `## Foreign Schema Warning`, before `## Scope and Backward Compatibility` at line 35) listing all 22 keys and the `last_updated` semantics | `.claude/rules/orchestrator-state.md` and its bundle mirror |
| Document `last_updated` in the orchestrate skill | New item in `## Checkpoint Handling` (lines 29-36) naming `last_updated`, its refresh rule, and the rule section; no invocation command text (section 1.8). Recommended in the same edit: correct line 270 to name the checkpoint key `issue-num` | `.claude/skills/orchestrate/SKILL.md` and its bundle mirror |
| Parity check between `REQUIRED_STATE_KEYS` and the rule | New pytest module (section 5) | `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` (new) |
| File-path invocation | Bootstrap statement (section 2) | `scripts/dev_tools/validate_orchestration_artifacts.py` |
| Document the invocation contract | Amend `## Bare-Module CLI Contract` (line 173) to state that the dispatcher runs as `python -m scripts.dev_tools.validate_orchestration_artifacts` and as `python scripts/dev_tools/validate_orchestration_artifacts.py`, with identical flags and exit codes; the bare-module validator remains `-m` only | `.claude/rules/orchestrator-state.md` and its bundle mirror |
| Test covering the invocation contract | New pytest module (section 5) | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (new) |
| Same defect class in the agent persona (recommended) | Add `relativeFile`, `long-name`, `work-mode`, `plan-path` to `## Checkpoint Persistence` and list `step5_status`..`step10_status` individually (lines 175-178) | `.claude/agents/orchestrator.md` and its bundle mirror |

Complete list of repository files the fix would write (excluding this feature folder's own spec, plan, evidence, and review artifacts):

1. `scripts/dev_tools/validate_orchestration_artifacts.py`
2. `.claude/rules/orchestrator-state.md`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
4. `.claude/skills/orchestrate/SKILL.md`
5. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
6. `.claude/agents/orchestrator.md` (recommended)
7. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` (recommended, paired with 6)
8. `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` (new)
9. `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (new)
10. `pyproject.toml` (conditional: only if Ruff reports E402 against the selected statement form)

Files not to change: `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, `.claude/lib/orchestrator-state/OrchestratorState.psm1`, and `scripts/dev_tools/validate_orchestrator_state.py` (no behavior change is required).

### Concurrent-run overlap (#849, #841)

`gh` was not available to this run; titles were read from the public GitHub issue pages.

- #841 "Bug: ci-gate-vacuous-on-empty-check-list". Its body names `.claude/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (S9 CI gate prose, current lines 282-300), plus `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`. Shared files with #798: the orchestrate skill and its mirror.
- #849 "Bug: parallel-items-fail-completion-on-promotion-receipts". Its body cites `.claude/rules/orchestrator-state.md` (issue_adoption receipt message area, current lines 227-262) and proposes changes to the parallel planning and execution surfaces. Shared file with #798: likely the rule and its mirror.

Mitigation: confine #798 edits to `## Checkpoint Handling` (skill lines 29-36, plus line 270 if adopted) and to a new rule section near line 35 plus the line-173 paragraph, away from the S9 and issue_adoption sections. Rebase on `main` before PR creation and re-copy both mirrors from their sources after any rebase conflict resolution, because the mirror tests compare whole files.

## 5. Testing Implications

Policy constraints: `.claude/rules/python.md` line 87 prohibits external processes and runtime temp files in unit tests; `.claude/rules/general-unit-test.md` prohibits temporary files. Python tests do not use `subprocess` with `sys.executable` (the only occurrence, `tests/scripts/dev_tools/test_clean_devcontainer.py` line 95, exercises a command runner and is not an invocation-contract precedent). The established in-process precedent is `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` lines 352-371 (`runpy.run_module(..., run_name="__main__")` with a `RuntimeWarning` filter). Recommended approach: `runpy.run_path` in process, not a subprocess.

`runpy.run_path` on a `.py` file sets `__package__` to `None`, `__name__` to `run_name`, and `__file__` to the path (Python documentation, `runpy`), which reproduces the file-path invocation conditions except `sys.path`. Because `tests/conftest.py` line 61 already puts the repository root on `sys.path` and `scripts.*` is already in `sys.modules`, the regression test must isolate import state or it will pass before the fix:

- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (new):
  - Fixture: `monkeypatch.setattr(sys, "path", [entry for entry in sys.path if Path(entry or ".").resolve() != REPO_ROOT])`; `monkeypatch.delitem(sys.modules, name)` for `scripts` and every `scripts.*` key; on teardown remove any `scripts.*` module first imported during the test so later tests keep the original module objects.
  - `test_file_path_invocation_help_exits_zero` (expect-fail before the fix with `ModuleNotFoundError`): `monkeypatch.setattr(sys, "argv", [str(SCRIPT), "--help"])`, `runpy.run_path(str(SCRIPT), run_name="__main__")` raises `SystemExit` with code 0 and `capsys` stdout contains `orchestrator-state`.
  - `test_file_path_invocation_validates_committed_fixture`: same isolation, argv `orchestrator-state tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json` (committed file, not a temp file); assert the exit code equals `dispatcher.main([...])` for the same arguments.
  - `test_module_invocation_leaves_sys_path_unchanged`: snapshot `list(sys.path)`, `runpy.run_module("scripts.dev_tools.validate_orchestration_artifacts", run_name="__main__")` with `--help`, assert exit 0 and `sys.path` unchanged.
  - `test_file_path_bootstrap_appends_repo_root_once`: after the isolated `run_path`, the repository root appears in `sys.path` exactly once.
- `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` (new), modeled on `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py` lines 172-274 (section extraction by heading, parametrized backticked-member assertion) and `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` (read committed documents in place, no temp files, no processes):
  - Parametrized over `REQUIRED_STATE_KEYS`: each key appears as `` `key` `` in the rule's `## Required Top-Level Keys` section (expect-fail before the fix).
  - Reverse direction: the set of keys extracted from the section's bullet lines (`^- `` `([^`]+)` ``) equals `set(REQUIRED_STATE_KEYS)`, so an undeclared extra key also fails.
  - The section names `last_updated` with the words that define its refresh rule, and the orchestrate skill contains `` `last_updated` `` and the section heading reference (expect-fail before the fix).
  - Recommended cross-runtime pin: parse the TypeScript array (`orchestrator-state-core.ts` lines 60-83) and the PowerShell array (`OrchestratorState.psm1` lines 38-61) by regex and assert ordered equality with the Python tuple; this converts the existing "Pinned to" comments into an enforced invariant.
  - If the agent persona is amended: every key appears backticked in `.claude/agents/orchestrator.md` `## Checkpoint Persistence`.
- Coverage: the bootstrap line executes on every import (line coverage); the true branch of the conditional expression is exercised by the `run_path` tests. Changed-line coverage for `validate_orchestration_artifacts.py` should be measured with `--cov=scripts.dev_tools` (a module path, not a `.py` file path).
- Existing tests that must stay green: `test_push_down_claude_resource_contracts.py` (mirrors), `test_skill_bundle_contract_repo.py` (no invocation text in the skill), `test_orchestrator_state_remediation_docs.py`, `test_orchestrator_state_blocked_reason.py`, `test_validate_orchestrator_state_cli.py`, and every `test_validate_orchestration_artifacts*.py` module.
- Toolchain loop: Black, Ruff (confirms the E402 exemption), Pyright strict, pytest with coverage; no TypeScript or PowerShell source changes are proposed.

## Numeric Derivation Evidence

### N1: number of required top-level keys

- Complete Family: members of `REQUIRED_STATE_KEYS` in the Python authority.
- Exhaustive Search Scope: `scripts/dev_tools/validate_orchestrator_state.py` lines 54-77 (the only declaration; grep of `scripts/` for `REQUIRED_STATE_KEYS` finds the declaration at line 54 and the loop at line 329 only).
- Inclusion Rules: every string literal element of the tuple.
- Exclusion Rules: keys validated only conditionally (`ci_gate`, `pr_gate`, `issue_adoption`, optional arrays).
- Primary Search Strategy or Query Expression: read of lines 54-77 of the Python file.
- Primary Member Set: objective, change_budget_estimate, path_selected, promotion-type, short-name, relativeFile, long-name, issue-num, feature-folder, work-mode, plan-path, completed_steps, next_step, last_updated, step5_status, step6_status, step7_status, step8_status, step9_status, step10_status, delegation_receipts, blocked_reason.
- Primary Count: 22.
- Cross-check Search Strategy or Query Expression: read of the independent ports `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` lines 60-83 and `.claude/lib/orchestrator-state/OrchestratorState.psm1` lines 38-61.
- Cross-check Member Set: identical 22 names in identical order in both ports.
- Cross-check Count: 22 (TypeScript), 22 (PowerShell).
- Member-set Comparison: normalized sets are equal; no member is missing or extra in either port.

### N2: required keys not mentioned anywhere in `.claude/rules/orchestrator-state.md`

- Complete Family: the 22 members of N1.
- Exhaustive Search Scope: the full text of `.claude/rules/orchestrator-state.md` (276 lines).
- Inclusion Rules: a key counts as mentioned when its exact string appears as a token anywhere in the file.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: ripgrep `-o` with the unanchored alternation of all 22 keys.
- Primary Member Set (mentioned): blocked_reason, delegation_receipts, next_step, issue-num, promotion-type. Not mentioned: the remaining 17.
- Primary Count: 5 mentioned, 17 not mentioned.
- Cross-check Search Strategy or Query Expression: ripgrep `-o` with the word-boundary form `\b(<alternation>)\b`.
- Cross-check Member Set (mentioned): blocked_reason, delegation_receipts, next_step, issue-num, promotion-type.
- Cross-check Count: 5 mentioned, 17 not mentioned.
- Member-set Comparison: equal. A third, narrower query (backtick-delimited exact match) returns only blocked_reason, next_step, issue-num; it is not used for the count because `delegation_receipts[]` and prose `promotion-type` are mentions under the inclusion rule.

### N3: required keys not mentioned anywhere in `.claude/skills/orchestrate/SKILL.md`

- Complete Family: the 22 members of N1.
- Exhaustive Search Scope: the full text of `.claude/skills/orchestrate/SKILL.md` (446 lines).
- Inclusion Rules: as N2.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: ripgrep `-o` with the unanchored alternation.
- Primary Member Set (mentioned): objective, next_step, issue-num, feature-folder, completed_steps, blocked_reason, plan-path, delegation_receipts, step6_status, step9_status, work-mode. Not mentioned: change_budget_estimate, path_selected, promotion-type, short-name, relativeFile, long-name, last_updated, step5_status, step7_status, step8_status, step10_status.
- Primary Count: 11 mentioned, 11 not mentioned.
- Cross-check Search Strategy or Query Expression: ripgrep `-o` with the word-boundary form.
- Cross-check Member Set (mentioned): the same 11.
- Cross-check Count: 11 mentioned, 11 not mentioned.
- Member-set Comparison: equal. `objective` and `work-mode` occur only as prose words, not as key documentation.

Recommendation for the spec: phrase acceptance criteria against `REQUIRED_STATE_KEYS` itself ("every member of `REQUIRED_STATE_KEYS`") rather than a literal count, so the test iterates the constant and the criterion stays correct if the tuple grows.

## Automation Feasibility

No step requires human interaction. Every change is a repository file edit, and every verification (Black, Ruff, Pyright, pytest including the in-process `runpy` invocation tests and the mirror-parity tests) runs unattended in the existing toolchain and CI. No third-party UI, credential, or portal action is involved. The only item this research could not perform with its tool set was a read-only `gh issue view` for #849 and #841; the public issue pages supplied the titles, and the orchestrator can repeat the `gh` read unattended if required.

## Rejected Alternatives (summary)

- Document only `last_updated`: the requested parity check would fail on 16 further undocumented keys.
- Add `last_updated` format validation: three-runtime behavior change that rejects committed fixtures; out of scope.
- `-m`-only with a clear failure message: same pre-import code cost, leaves the expected behavior unmet.
- Unconditional `sys.path.insert`: mutates `sys.path` for every importer.
- Subprocess-based invocation test: prohibited by the unit-test policy; `runpy.run_path` with import-state isolation covers the same contract in process.
