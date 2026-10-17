# Research: validate_orchestrator_state CLI entry point (issue #464)

- Date: 2026-09-29
- Feature folder: `docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464`
- Scope: research only; no production code, tests, or documents were modified.
- Method note: this research session had file-read and search tools only (no shell). Commands that need a shell (`poetry run python -m ...`, `diff -q`) were not executed. Where a shell result was requested, the substitute evidence is stated explicitly in the relevant section.

## 1. Current state

### 1.1 Target module

- `scripts/dev_tools/validate_orchestrator_state.py` is 492 lines (line-count match on `^`, verified).
- A search for `__main__|argparse|def main` in that file returns 0 matches (verified), consistent with the issue's `grep -c` count of 0.
- Public entry point: `validate_orchestrator_state_text(text, *, require_complete, strict_route_membership, require_pr_creation_ready, require_model_routing, require_codex_model_routing, require_codex_topology) -> list[str]` at lines 368-492. It is pure (no I/O) and returns an error list.
- `VALID_BLOCKED_REASONS` is at lines 83-91; the blocked_reason checks are at lines 411-413 (membership) and 463-466 (completion gate). The remediation-loop block (constants at 110-117, `_validate_remediation_cycle` at 120-152, `_validate_remediation_loop` at 155-177) does not overlap those regions, so extracting it does not touch the region that #523 will edit.
- Reproduction (`poetry run python -m scripts.dev_tools.validate_orchestrator_state /nonexistent/path.json --require-complete; echo $?`) was NOT executed (no shell available). The expected result follows from the code: with no guard, `python -m` imports the module, defines names, and exits 0 with no output. The issue's own record states exit code 0 and empty output.

### 1.2 Question 1: the dispatcher already exposes an equivalent route

`scripts/dev_tools/validate_orchestration_artifacts.py` (495 lines) registers subparser `orchestrator-state` at lines 241-282 and routes it at lines 411-421.

| Aspect | Dispatcher `orchestrator-state` | Behaviour required for #464 |
|---|---|---|
| Invocation | `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> [flags]` (guard at 494-495) | `python -m scripts.dev_tools.validate_orchestrator_state <path> [flags]` |
| Flags in scope | `--require-complete` (243-247), `--require-pr-creation-ready` (248-256), `--require-model-routing` (257-266); each passed as `bool(args.<flag>)` (414-416) | same three, passed unchanged |
| Flags beyond scope | `--require-codex-model-routing` (267-274), `--require-codex-topology` (275-282), passed via `getattr(..., False)` (417-420) | not in the three-flag AC |
| Not exposed by either | `strict_route_membership` (a keyword of `validate_orchestrator_state_text`) | not exposed |
| Success exit / output | `main` returns 0 and prints `orchestrator-state validation passed: <path>` on stdout (lines 488-491) | exit 0, nothing on stderr |
| Error exit / output | returns 1; each error printed to stderr, one per line (483-484, 488-489) | non-zero; each error printed |
| Argparse usage errors | argparse default, exit 2 (test evidence: `test_validate_orchestration_artifacts_plan_gates.py:287` asserts code 2 for an unknown option) | n/a |
| Missing path | `_validate_from_args` calls `_read_text(path)` (line 363), which is `path.read_text(encoding="utf-8")` (line 72). `main` (457-491) has no `try/except`, so `FileNotFoundError` propagates as an uncaught traceback; the interpreter exit status is 1 (derived from code, not executed). | non-zero exit plus a diagnostic; a clean error is preferable to a traceback |
| Unreadable / non-UTF-8 path | `PermissionError`, `IsADirectoryError` (both `OSError`) and `UnicodeDecodeError` (a `ValueError`) also propagate as tracebacks | handle as a clean error |

Conclusions:

- The equivalent route exists, so the MCP tool and the dispatcher are the working gate today. The gap is only the bare module.
- The dispatcher's missing-path behaviour is a traceback with exit 1, not a designed diagnostic. No dispatcher test covers a missing path (searched `FileNotFoundError|OSError` in `tests/scripts/dev_tools/test_validate_orchestration_artifacts*.py`: no matches).
- The dispatcher's traceback exit of 1 is not distinguishable from "validation errors found" (also 1). The new CLI should improve on this without changing the dispatcher (out of scope).

## 2. Documentation and invocation inventory

Search basis: whole-repo search for `validate_orchestrator_state` not followed by `_text`, excluding `docs/features/completed/**`, `docs/research/**`, and `node_modules`; plus targeted searches for `local CLI`, `--require-*`, and `python -m`.

### 2.1 Findings by category

A. Texts that name only "the local CLI" or an unnamed validator (ambiguous; do not say which module/command):

- `.claude/skills/orchestrate/SKILL.md:84` ("via `mcp__drm-copilot__validate_orchestration_artifacts` or the local CLI") and `:187` ("or the equivalent local CLI call"). Mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md:84,187` (same lines).
- `.claude/skills/orchestrate/SKILL.md:176` and `.claude/rules/orchestrator-state.md:95`: "CLI flag `--require-model-routing`" attributed to `validate_orchestrator_state_text(...)`. Today that flag exists only on the dispatcher; with the new CLI it exists on both.
- Unnamed "orchestrator-state validator" with a flag: `.claude/agents/orchestrator.md:63,93`; `.claude/agents/pr-author.md:32`; `.claude/skills/cleanup-merged-worktrees/SKILL.md:174`; `.agents/skills/orchestrate/SKILL.md:388`. All have byte-parallel bundle mirrors under `extensions/drm-copilot/resources/`.

B. Texts that name the bare module as a library or enforcer (accurate today, remain accurate):

- `.claude/rules/orchestrator-state.md:31,151-155`; `.agents/skills/orchestrator-state/SKILL.md:16,18,87-88`; `.claude/skills/orchestrate/SKILL.md:118,172`; `README.md:41`; `.claude/hooks/validate-orchestrator-output.ps1:73`; `.claude/lib/orchestrator-state/OrchestratorState.psm1:15,37,251`, `OrchestratorStateReceipts.psm1:11,42`, `OrchestratorStateUnconditional.psm1:9`; plus mirrors of each. These are citations of the Python reference, not invocations; no edit is required.

C. The only text that documents the bare-module failure:

- `docs/features/epics/parallel-orchestration/epic-status.md:298-301`: "The bare validator module is not a gate. `python -m scripts.dev_tools.validate_orchestrator_state` exits 0 silently because that module has no CLI. Validate through the `validate_orchestration_artifacts` dispatcher (MCP tool or its CLI)." This becomes stale after the fix. It is a historical epic-status lesson; the plan should either leave it as a dated lesson with an appended "resolved by #464" note or edit the sentence. It is not a bundled mirror.
- No document under `.claude/`, `.agents/`, `.github/`, or the hooks was found that gives the literal `python -m scripts.dev_tools.validate_orchestrator_state` command as a preflight instruction. The issue's phrase "documented preflight command" therefore refers to the ambiguous "local CLI" wording (category A) rather than to a literal command.

D. Adjacent stale text observed (out of scope for #464; recorded so the plan does not widen scope accidentally):

- `.claude/skills/orchestrate/SKILL.md:191` says `enforce-pr-author-skill.ps1` revalidates "via an injectable `$Invoker` subprocess seam". A search for `Invoker` across `.claude/hooks` and `.claude/lib` returns 0 matches; the hook calls `Invoke-OrchestratorStatePreflight` in `enforce-pr-author-skill-helpers.ps1:364`, which is PowerShell.
- `.claude/skills/orchestrate/SKILL.md:221` says `validate-orchestrator-output.ps1` "runs the validator with `--require-model-routing`"; the hook now calls `Test-OrchestratorStateCompletionReadiness` (`validate-orchestrator-output.ps1:258-261`).

### 2.2 Recommended documentation edits (keep docs consistent with implemented behaviour)

1. `.claude/skills/orchestrate/SKILL.md:84` and `:187`: replace "the local CLI" with a named surface, using citation form only (see 2.4): the MCP tool as the portable surface, and the repository-local `validate_orchestration_artifacts` dispatcher / `validate_orchestrator_state_cli` module as the local surface. Apply identically to the bundle mirror.
2. `.claude/rules/orchestrator-state.md:95`: state that the `--require-model-routing` flag is accepted by both the dispatcher `orchestrator-state` subcommand and the bare-module CLI, and give the exit-code contract (section 6) in one short paragraph. Rules files are not scanned by the skill bundle guard (2.4), so the literal `python -m scripts.dev_tools.validate_orchestrator_state` command is safe here. Apply identically to the bundle mirror.
3. `docs/features/epics/parallel-orchestration/epic-status.md:298-301`: append a resolved note or reword; not mirrored.
4. Optional: name the exit-code contract for `.claude/agents/orchestrator.md:63,93` only if the planner wants them unambiguous; the AC lists only `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md` plus mirrors, so the minimum edit set is those two files and their two mirrors.
5. The `.agents/` (Codex) surface refers to the MCP tool and does not mention a local CLI; no edit is needed.

### 2.3 Mirror parity

- `diff -q` was not run (no shell). Substitute evidence, all verified by line-count search: `.claude/rules/orchestrator-state.md` 159 lines vs bundle 159; `.claude/skills/orchestrate/SKILL.md` 423 vs 423; `.agents/skills/orchestrator-state/SKILL.md` 89 vs 89; `.agents/skills/orchestrate/SKILL.md` 474 vs 474. Search hits for identical patterns appear at identical line numbers in each pair. This is consistent with byte identity but does not prove it.
- Enforcement that makes any divergence fail a test:
  - `.claude` tree: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 118-143) compares the text of every non-agent-memory `.claude/**` file with `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
  - `.agents`/`.codex` tree: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (lines 215-228) does the same against `codex-and-agents-customizations`.
  - `scripts/dev_tools/push_down_claude_customizations.py` copies the tree to a destination workspace (the docstring at line 200: "Copy the `.claude` tree into the destination workspace"); it does not synchronize repo root to bundle. The repo-to-bundle copy is manual (or an extension build step), so each documentation edit must be applied to both copies in the same change.
- The hook-Python-invocation guard (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`) scans only `.claude/hooks` and `.claude/lib` `*.ps1`/`*.psm1`; it is unaffected by this feature provided no hook or lib file is edited.

### 2.4 Skill bundle contract (issue #762)

Mechanism (verified in `scripts/dev_tools/skill_bundle_contract.py` and `skill_bundle_contract_cli.py`):

- Only `.claude/skills/*/SKILL.md` texts (and their `allowed-tools` entries) are scanned (`load_repository_inputs`, `skill_bundle_contract_cli.py:123-140`). Files under `.claude/rules/`, `.claude/agents/`, `.agents/`, and `docs/` are not scanned.
- A script reference is an invocation form, not a mention. Invocation forms (lines 50-68): `bash|sh|source <path>`, `pwsh ... -File <path>`, `& <path>`, `. <path>`, `Import-Module <path>`, `python[3] <path>.py`, and `python[3] -m <dotted.module>` (resolved to `<dotted/module>.py`). A backticked path with no invocation form is a citation and is not returned (docstring of `extract_script_references`, lines 312-316).
- A reference whose path root is not in `PUBLISHED_ROOT_FOLDERS = (".claude", "config")` yields reason `not-in-bundle` (lines 379-383). `scripts/dev_tools/*.py` is outside those roots.
- The repository guard test `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled` (lines 29-43) fails on any unregistered violation. The only registered exceptions are two `#763` entries (`parallel_drift_detection_cli.py`, `parallel_mutation_abandon_cli.py`, lines 134-145); a new exception would need its own issue link and would be reported stale if it matched nothing.

Consequences for #464:

- Adding `python -m scripts.dev_tools.validate_orchestrator_state` (with or without `poetry run`) to any `.claude/skills/*/SKILL.md` would be extracted as `scripts/dev_tools/validate_orchestrator_state.py`, exist in the repository, fall outside the published roots, and fail `test_every_skill_script_reference_is_bundled` with `not-in-bundle`. The same applies to `python scripts/dev_tools/validate_orchestrator_state_cli.py` and to `python -m scripts.dev_tools.validate_orchestrator_state_cli`.
- Citation-only mentions are safe in SKILL.md. Existing precedent: `.claude/skills/orchestrate/SKILL.md:172` cites `scripts/dev_tools/validate_orchestrator_state.py` with no invocation form. A backticked `scripts/dev_tools/validate_orchestrator_state_cli.py` used as a citation is therefore safe, but the words `sh`, `bash`, `source`, and a bare `&` or `.` immediately before a path must be avoided.
- The `python -m` phrasing is safe in `.claude/rules/orchestrator-state.md` (not scanned) and in `docs/` (not scanned). In SKILL.md it is not safe.
- Design reason behind the guard: destination workspaces receive the `.claude` bundle but not `scripts/dev_tools`. A skill instructing a destination agent to run `scripts.dev_tools...` would fail there. The portable surface for skills is the MCP tool; the CLI is a repository-local surface.
- After any SKILL.md edit, run `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`.

## 3. How the completion hook validates today (no Python leg)

- `.claude/hooks/validate-orchestrator-output.ps1` imports `../lib/orchestrator-state/OrchestratorState.psm1` (line 41) and, for artifact type `orchestrator-state`, imports `OrchestratorStateCompletion.psm1` and calls `Test-OrchestratorStateCompletionReadiness -CheckpointPath $Path` (lines 254-261).
- `OrchestratorStateCompletion.psm1` (header lines 5-12) documents itself as a complete-parity PowerShell port of the Python validator's `orchestrator-state --require-complete --require-model-routing` call surface, delivered under issue #475, and states it is "no longer a fallback for an importable Python validator: the portable path is the only path".
- A search for `(& |Invoke-Expression |Start-Process )(poetry|python|py)|-m scripts` over `.claude/hooks` and `.claude/lib` returns 0 matches; `Invoker` returns 0 matches.
- The issue text "uses a direct import" is therefore inaccurate: the hook uses no Python at all. The conclusion the issue draws (hook-level enforcement works) still holds, and it means the plan needs no hook or lib change and must not add one. `.claude/rules` policy and the #475 guard test (`enforcement-hooks-no-python-invocation.Tests.ps1`) both forbid a Python leg.

## 4. Layout options for the 500-line cap

Measured facts:

- `validate_orchestrator_state.py`: 492 lines, so 8 lines of headroom.
- Names in the remediation block: `REMEDIATION_LOOP_KEY`, `REMEDIATION_CYCLES_KEY`, `EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT`, `PREFLIGHT_CLEARED_STATUS`, `_validate_remediation_cycle`, `_validate_remediation_loop`. A search over all `*.py` in the repository finds these only in `validate_orchestrator_state.py` itself (definitions at 110-155; uses at 133, 140, 164, 175, 433). No test, script, or other module imports or monkeypatches any of them.
- Tests reach into the module only through: `state_validator.validate_orchestrator_state_text` (the only attribute accessed by attribute syntax), `vars(state_validator)["_validate_list_delegation_receipts"]`, `["_validate_namespaced_delegation_receipts"]` (`test_validate_orchestrator_state.py:20-27`), and `["_build_portable_envelope"]` (`test_orchestration_handoff_adapters.py:40`, `test_orchestration_handoff_contract.py:41`). Direct `from ... import` names are only `validate_orchestrator_state_text`. None of these live in the remediation block.
- Sibling private modules already follow the convention `_orchestrator_state_<topic>.py`: `_orchestrator_state_codex_model_routing`, `_codex_topology`, `_complexity`, `_human_interaction`, `_model_routing`, `_model_routing_gate`, `_pr_creation_readiness`, `_preparation_terminal`, `_routing`, `_step_status`. Header style (verified in `_orchestrator_state_step_status.py:1-31` and `_orchestrator_state_human_interaction.py:1-42`): module docstring with `Purpose`, `Usage`, `Invariants / Constraints`, `Side Effects`; then `from __future__ import annotations`; then an `__all__` block preceded by a comment explaining that listing the names marks them as deliberate re-exports consumed by `validate_orchestrator_state`, so static analysis does not flag them (including underscore-prefixed names).

### Option (a): CLI sibling module plus a small guard only

- New `scripts/dev_tools/validate_orchestrator_state_cli.py` (naming matches the `<module>_cli.py` convention: `skill_bundle_contract_cli.py`, `parallel_drift_detection_cli.py`, `parallel_mutation_abandon_cli.py`).
- In `validate_orchestrator_state.py`: one top-level import of `main` plus a 4-line guard. Estimated size 492 + 1 + 4 = about 497 lines.
- Advantage: minimal diff. Limitation: leaves about 3 lines of headroom, so #523 (which must add to `VALID_BLOCKED_REASONS` and the blocked_reason checks in this same file) would breach the cap or be forced to extract at that time, inside a three-runtime change.

### Option (b): option (a) plus extract the remediation-loop block

- New `scripts/dev_tools/_orchestrator_state_remediation_loop.py` holding the four constants and the two functions (about 8 + 58 lines plus header and `__all__`, roughly 100 lines).
- In `validate_orchestrator_state.py`: remove lines 110-117 and 120-179 (68 lines), add a 4-line parenthesized import (`REMEDIATION_LOOP_KEY`, `_validate_remediation_loop`) placed between the `_orchestrator_state_preparation_terminal` and `_orchestrator_state_routing` imports (isort order), and the option (a) additions. Estimated size 492 - 68 + 4 + 1 + 4 = about 433 lines, roughly 67 lines of headroom.
- Import-name compatibility: only `REMEDIATION_LOOP_KEY` and `_validate_remediation_loop` are used in the remaining module (line 433). The other four names have no consumer anywhere (verified above). Re-importing them purely to keep them resolvable would trigger Ruff `F401` unless listed in `__all__`; the simplest compatible choice is to import only the two used names. If the planner wants all six names to stay resolvable from `validate_orchestrator_state`, the module needs an `__all__`, which it does not currently have.
- Behaviour risk: the moved functions are pure and their messages must stay byte-identical (AC: byte-identical error lists). `test_validate_orchestrator_state_remediation_loop.py` exercises them through `validate_orchestrator_state_text` and would continue to cover the moved code.

### Recommendation: option (b)

The 8-line headroom of the current file is not enough to make the fix and the next epic child (#523) both fit. Option (b) has no known importer impact, follows an established convention, and moves a self-contained block that #523 does not edit. Estimated sizes above must be re-measured after editing; the AC requires only "stays under 500 lines".

### CLI module design (applies to both options)

- Avoid the double-import problem by dependency injection. When `python -m scripts.dev_tools.validate_orchestrator_state` runs, the module executes as `__main__`. If the CLI module imported `validate_orchestrator_state_text` from `scripts.dev_tools.validate_orchestrator_state`, Python would import and execute the module a second time under its real name (two copies of every function; harmless because the module is pure, but wasteful and confusing, and a lazy import inside the guard would also invite a `E402`-style lint question).
- Instead the CLI module should not import the validator. Its `main(argv=None, *, validate, read_text=...)` receives the validator callable, and the guard passes it: `raise SystemExit(main(validate=validate_orchestrator_state_text))`. With this, `validate_orchestrator_state.py` can import `main` at module top level with no cycle (the CLI imports nothing from the validator), and no code executes twice. This is the same seam style as `skill_bundle_contract_cli.main(argv, *, loader=...)` (`skill_bundle_contract_cli.py:168-172`).
- The seam also removes the need to monkeypatch anything in tests (section 5).
- Pyright strict is on (`pyproject.toml:141-142`); type `argparse.Namespace` attributes with `cast(...)` as `skill_bundle_contract_cli.py:197` does.

## 5. Testing approach without temporary files

Configuration facts (`pyproject.toml`):

- `[tool.pytest.ini_options]` (lines 113-116): `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`, `testpaths = ["tests"]`. No `filterwarnings` key exists in `pyproject.toml`, and no `pytest.ini`, `tox.ini`, or `setup.cfg` exists. `tests/conftest.py` and `tests/scripts/dev_tools/conftest.py` exist; a search for `filterwarnings|-W error|PYTHONWARNINGS` across `pyproject.toml`, those conftests, the workflows, and `fix_all*.py` returns 0 matches. Warnings are therefore not errors.
- `[tool.coverage.report].exclude_lines` (lines 129-139) contains `"if __name__ == .__main__.:"`. The guard is thus excluded from coverage measurement by an existing repository-wide exclusion; the 85% line and 75% branch thresholds apply to the rest of the CLI module, which the injected-seam tests cover. Coverage source is `["src", "scripts/dev_tools"]` (line 119).
- Coverage command form required by the task: `--cov=scripts.dev_tools.validate_orchestrator_state_cli --cov=scripts.dev_tools.validate_orchestrator_state [--cov=scripts.dev_tools._orchestrator_state_remediation_loop] --cov-report=term-missing`.

Existing patterns to reuse:

- Read stubbing: `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py:140-146` defines `build_read_text_stub(text)`, used with `monkeypatch.setattr(validator, "_read_text", ...)` (`test_validate_orchestration_artifacts_dispatch.py:40,60,74,112`). The dispatch file (150+ lines) also shows the `vars(validator)["_validate_from_args"]` private-access idiom to satisfy Pyright and Ruff B009.
- Output assertions: `capsys.readouterr()` with exact `captured.out` / `captured.err` comparisons (`test_validate_orchestration_artifacts_plan_gates.py:290-324`).
- Injected seam without monkeypatching: `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py` (imports `main`, injects a `loader`, asserts via `capsys`; it does not test its own `__main__` guard).
- `__main__` coverage precedent: only one test runs a guard, `tests/scripts/dev_tools/codex_native_converter/test_cli_entrypoints.py:283-300`, using `runpy.run_module("scripts.dev_tools.codex_native_converter", run_name="__main__")` with `pytest.raises(SystemExit)`, a monkeypatched `cli.main`, and `exit_info.value.code == 0`. That target is a package `__main__.py`, which does not trigger the runpy warning below.
- Valid-checkpoint builders for reuse (`tests/scripts/dev_tools/validate_orchestrator_state_test_support.py`): `build_valid_orchestrator_state()` (line 11; minimally valid, passes plain validation), `build_complete_small_state()` (line 51; completion-safe for `--require-complete` on the `small` route), `build_portable_envelope()` (123), `build_portable_projection()` (203). A large-route completion-safe builder exists in `test_validate_orchestration_artifacts.py:149` (`build_complete_large_orchestrator_state`). Note `build_valid_orchestrator_state()` carries a delegation receipt and no `model_routing_receipts`, so it would fail `--require-model-routing`; use an injected fake validator that records keyword arguments to prove flag passthrough instead of building a routing-valid checkpoint.
- Size facts: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` is 425 lines (verified). Do not add to it; create a new file `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` (mirrors `scripts/dev_tools/validate_orchestrator_state_cli.py` in the repository's flat `tests/scripts/dev_tools/` layout) and, for option (b), leave `test_validate_orchestrator_state_remediation_loop.py` as is.

Covering the guard deterministically (no subprocess, no temporary file):

- Use `runpy.run_module("scripts.dev_tools.validate_orchestrator_state", run_name="__main__")` inside `pytest.raises(SystemExit)`, with `monkeypatch.setattr(sys, "argv", [...])` (or `alter_sys=True`) and the CLI's file-read seam replaced through `monkeypatch.setattr(cli_module, "<read function>", stub)`. Because the guard's `main` is the cached CLI module object, that patch takes effect; the freshly executed `__main__` copy of the validator is what gets injected.
- Expected RuntimeWarning: `runpy.run_module` emits `RuntimeWarning: 'scripts.dev_tools.validate_orchestrator_state' found in sys.modules after import of package 'scripts.dev_tools', but prior to execution...` when the target module is already imported, which is the case in the test process (other tests import it). This is an expectation from documented `runpy` behaviour, not something verified by running here. It is only a warning under this repository's pytest configuration (no `filterwarnings = error`). Add `@pytest.mark.filterwarnings("ignore:.*found in sys.modules.*:RuntimeWarning")` on that test so a future `filterwarnings = error` does not break it, or accept the warning.
- Because the guard line is excluded from coverage, this test protects the AC1 "reached through a `__main__` guard" wording rather than raising the coverage number; it is recommended as one test, not several.
- Do not use `subprocess`, `Thread.Sleep`-style waits, or temp files (`general-unit-test.md`). Missing/unreadable path tests inject a read seam that raises `FileNotFoundError` / `PermissionError` / `UnicodeDecodeError`; no real path is touched.

Suggested test list (one behaviour each): valid checkpoint returns 0 with empty stderr; invalid checkpoint returns 1 and each error on stderr; missing path returns 2 with a diagnostic naming the path; unreadable path (`PermissionError`) returns 2; undecodable file returns 2; each of the three flags forwarded as `True` and the default `False` when absent (recording fake validator); argparse rejects an unknown flag with `SystemExit(2)`; guard test via `runpy`; a parity test that the CLI and dispatcher (`validator.main(["orchestrator-state", ...])`) return the same code for the same in-memory text; a test that `validate_orchestrator_state.py` stays under 500 lines is optional (the repository has no such test found in this research).

## 6. Recommended CLI contract

Invocation: `python -m scripts.dev_tools.validate_orchestrator_state <path> [--require-complete] [--require-model-routing] [--require-pr-creation-ready]`.

| Outcome | Exit | stdout | stderr |
|---|---|---|---|
| Valid checkpoint | 0 | `orchestrator-state validation passed: <path>` (identical to the dispatcher's success line, `validate_orchestration_artifacts.py:490`) | empty |
| One or more validation errors | 1 | empty | each error on its own line, in the order returned by `validate_orchestrator_state_text` |
| Path missing, unreadable, or not decodable as UTF-8 (`OSError` or `UnicodeDecodeError`) | 2 | empty | one diagnostic line naming the path and the cause, no traceback |
| Unknown flag or missing positional | 2 (argparse default) | empty | argparse usage message |

Rationale and constraints:

- Exit 0 / 1 matches the dispatcher (`main`, lines 488-491), keeping the manual-verification note in the issue ("compare exit codes with the dispatcher") true for pass and fail. Exit 2 for an unreadable path groups it with argparse usage errors ("could not run the validation") and separates it from "ran and found errors", which the dispatcher's traceback (exit 1) cannot do. AC requires only non-zero for a missing path; 2 satisfies it.
- Errors go to stderr (matches dispatcher lines 483-484); the success line stays on stdout so AC5 ("prints nothing to stderr for a valid checkpoint") holds.
- Catch only `OSError` and `UnicodeDecodeError` around the read; do not add a broad catch-all (repository rule: fail fast, no silent handlers). Invalid JSON is already reported by the validator as `Checkpoint is not valid JSON: ...` (validator line 389) and yields exit 1.
- Flags: implement the three in-scope flags. `--require-codex-model-routing` and `--require-codex-topology` exist on the dispatcher and on `validate_orchestrator_state_text`; adding them costs two `add_argument` calls and gives full flag parity with the dispatcher. This is a scope decision for the planner: the AC lists three flags, and adding two more does not conflict with it. Do not add `strict_route_membership` (neither surface exposes it).
- Existing behaviour is unchanged: `validate_orchestrator_state_text` is not modified (AC: byte-identical error lists). No hook, lib, MCP, or TypeScript change is needed.

## 7. Rejected alternatives

- Add argparse and `main` directly to `validate_orchestrator_state.py`: rejected; roughly 60-80 lines of parser and reading logic exceed the 8-line headroom (492 of 500).
- Make the bare module delegate to the dispatcher (`validate_orchestration_artifacts.main(["orchestrator-state", ...])`): rejected; the dispatcher imports `validate_orchestrator_state_text` from this module (line 34), so a top-level import back would be circular, and it would inherit the dispatcher's uncaught-traceback missing-path behaviour.
- Add a shell or PowerShell wrapper: rejected; the requirement is a `python -m` entry point, and hooks must not gain Python legs (a wrapper would also not satisfy AC1).
- Add the literal `python -m` command to SKILL.md files: rejected; it trips the #762 skill bundle guard (section 2.4).

## 8. Open items for the planner

1. Choose option (b) (recommended) or (a); re-measure line counts after editing.
2. Decide whether to include the two Codex flags (recommended: yes, for parity).
3. Decide whether to reword `epic-status.md:298-301` or append a resolution note.
4. Decide whether the adjacent stale statements in SKILL.md lines 191 and 221 (section 2.1 D) are handled in this change or filed separately; they are outside the #464 acceptance criteria.
5. No numeric acceptance criterion is proposed by this research beyond the existing "under 500 lines" criterion; the line-count projections in section 4 are estimates for planning and must be replaced by measurements in the evidence.
