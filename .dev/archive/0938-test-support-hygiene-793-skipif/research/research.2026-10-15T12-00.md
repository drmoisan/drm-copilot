# Research: test-support hygiene and stale skipif (Issue #938)

- Date: 2026-10-15 (file-name time component is nominal; the research agent has no clock tool)
- Work Mode: minor-audit
- Origin: #903 Operator Follow-ups 9 and 12 (`docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md:232` and `:235`); #793 code review finding L22.
- Tooling limit: this research session had no shell tool. `git ls-files`, `gh issue view`, and `pytest` were NOT run. Claims that would need them are marked "inferred" and the plan must run the listed commands to confirm.

## Item 1: move `build_valid_epic_state` and `build_read_text_stub`

### Definitions (verified by reading)

| Builder | File | Lines |
|---|---|---|
| `build_valid_epic_state() -> dict[str, object]` | `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` | 12-51 (def + docstring + dict literal; no imports needed beyond builtins) |
| `build_read_text_stub(text: str) -> Callable[[Path], str]` | `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` | 140-146 (needs `Callable`, `Path` under `TYPE_CHECKING`) |

### Callers and importers (grep over the whole repo, `*.py` and all text)

`build_valid_epic_state`:
- Defined and used inside `test_validate_epic_orchestrator_state.py` (about 25 uses, last at line 493).
- Imported by `test_validate_epic_orchestrator_state_merge_status.py:20-22`; used at line 80.
- No other Python importer. The four other epic test files (`..._launch_binding`, `..._wave_barrier`, `..._codex_topology`, `..._codex_routing`) do not import it.
- Non-importing reference: `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts:8-9` (JSDoc comment "Mirrors the Python test fixture `build_valid_epic_state()` in `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`").

`build_read_text_stub` (imported from `test_validate_orchestration_artifacts`):
- `test_validate_epic_orchestrator_state_merge_status.py:23-25` (used at 150)
- `test_validate_orchestration_artifacts_dispatch.py:18-23` (also imports `build_complete_large_orchestrator_state`, `build_valid_orchestrator_state`, `build_valid_policy_audit_text`, which stay)
- `test_validate_orchestration_artifacts_plan_gates.py:19-21`
- `test_validate_orchestration_artifacts_parallel_dispatch.py:33-35`
- The definition module itself does not call it (only the def at 140; `Callable` and `Path` at lines 13-14 are used only by this def).

Private duplicates (not importers, optional): `test_validate_orchestration_artifacts_pr_creation_readiness.py:28` defines `_build_read_text_stub`; `test_validate_discovery_artifacts_dispatch.py:28-38` defines `_stub_read_text` and its docstring at `:31-32` cites "`build_read_text_stub` pattern in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`".

Mirrored copies: no copy of these test modules or builders exists under `extensions/`, `.codex/`, `.agents/`, or `extensions/drm-copilot/resources/` (the only `extensions/` hit is the TS comment above). Remaining hits are historical records under `docs/features/**` (plans, research, reviews) and must not be edited.

### Repository conventions for `*_test_support.py` (verified)

- 13 modules exist, all flat in `tests/scripts/dev_tools/`: `blast_radius_parity_`, `claude_payload_scope_`, `epic_planner_launch_evidence_`, `npm_token_guard_`, `orchestration_handoff_taskmaster_469_`, `orchestrator_state_issue_adoption_`, `parallel_drift_`, `parallel_orchestrator_surface_`, `potential_to_issue_`, `push_down_customizations_`, `push_down_handoff_`, `quality_tiers_contract_`, and `validate_orchestrator_state_test_support.py` (the last name suffixes `_test_support.py`; the others use the same suffix).
- Name pattern: `<topic>_test_support.py`, no `test_` prefix, so pytest's default `test_*.py` / `*_test.py` collection does not pick them up (pyproject `[tool.pytest.ini_options]` sets only `testpaths = ["tests"]`, no `python_files` override).
- Imported by absolute dotted path, for example `from tests.scripts.dev_tools.validate_orchestrator_state_test_support import (...)` (`test_orchestration_handoff_adapters.py:31`). `tests/`, `tests/scripts/`, and `tests/scripts/dev_tools/` have no `__init__.py` (only the subdirectories `atomic_executor`, `discovery`, `discovery/analyzer`, `pr_context` do); namespace-package imports already work for the 13 existing modules and for the current sibling-test imports.
- Existing support module `validate_orchestrator_state_test_support.py` already holds a different `build_valid_orchestrator_state` (line 11) and imports `scripts.dev_tools.orchestration_handoff_contract`; do not merge into it, to avoid a name clash with the same-named builder in `test_validate_orchestration_artifacts.py`.
- Coverage: `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, `omit` contains `tests/*`. Test-support modules are outside the denominator; no production coverage changes.

### File sizes (500-line limit)

- `test_validate_epic_orchestrator_state.py`: 496 lines (last line 496). Removing the builder (40 lines) leaves about 456, plus a 3-line import block.
- `test_validate_orchestration_artifacts.py`: 338 lines. Removing 140-146 and the `TYPE_CHECKING` block reduces it.
- `test_validate_epic_orchestrator_state_merge_status.py`: 157 lines (grep occurrence count; import swap is size-neutral).
- New support module: about 60 lines.

### Candidate approaches

A. One new module `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py` holding both builders. Satisfies the issue wording ("a test-support module"), follows the `<topic>_test_support.py` pattern, minimal file count.
B. Two modules (`epic_orchestrator_state_test_support.py` for the epic dict, `validate_orchestration_artifacts_test_support.py` for the stub). More granular, one extra file; the stub has four consumers across the artifacts family while the epic builder has two.
C. Leave the definitions and re-export from the new module. Rejected: keeps the coupling the review finding objected to and leaves unused-import lint risk.

### Recommendation (item 1)

Approach A. Target path: `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py` (docstring: shared builders for the orchestration-artifact and epic-checkpoint validator tests). Move both definitions verbatim (keep `from __future__ import annotations`, `TYPE_CHECKING` block for `Callable`/`Path`). Do not move the other three builders in `test_validate_orchestration_artifacts.py` (out of #938 scope).

Required edits for the move (no re-export, per the "update all callers in-repo" rule):
1. Create the support module.
2. `test_validate_epic_orchestrator_state.py`: delete lines 12-51 (and one blank separator); add `from tests.scripts.dev_tools.validate_orchestration_artifacts_test_support import build_valid_epic_state`.
3. `test_validate_orchestration_artifacts.py`: delete the def at 140-146 plus separator; remove the now-unused `if TYPE_CHECKING:` block (lines 12-14) and change line 5 to `from typing import cast` (ruff F401 otherwise).
4. `test_validate_epic_orchestrator_state_merge_status.py`: replace both imports (lines 20-25) with one import from the support module.
5. `test_validate_orchestration_artifacts_dispatch.py`: drop `build_read_text_stub` from the import at 18-23; add import from the support module.
6. `test_validate_orchestration_artifacts_plan_gates.py` (19-21) and `test_validate_orchestration_artifacts_parallel_dispatch.py` (33-35): repoint the import.
7. Doc-comment references: update `test_validate_discovery_artifacts_dispatch.py:31-32` and `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts:8-9` to cite the new module. The TS edit is comment-only but touches the TypeScript toolchain (Prettier, ESLint, tsc, jest on the extension); the plan may defer it as optional, with the trade-off that the comment then cites a stale location.

Optional, not recommended in this minor-audit: replace the private duplicates (`_build_read_text_stub`, `_stub_read_text`) with the shared builder.

## Item 2: stale `_requires_codex_runtime` skipif

### Verified facts
- `test_codex_handoff_contract_parity.py:11-15` defines `_requires_codex_runtime = pytest.mark.skipif(not (REPO_ROOT/".codex"/"agents").exists() or not (REPO_ROOT/".agents"/"skills").exists(), reason=".codex and .agents directories are gitignored and unavailable in CI")`. It is applied to exactly two tests: `test_shared_codex_skills_match_repo_agent_skill_sources` (line 55; 15 skills in `SHARED_SKILL_NAMES`, includes `atomic-plan-contract`) and `test_codex_orchestration_chain_agents_match_repo_sources` (line 64; 11 agents). The other three tests are unguarded and read only the bundle. `_requires_codex_runtime` appears nowhere else in the repo.
- `.gitignore` lines 64-71 ("Local Tooling") contain only negations for the bundled `extensions/.../codex-and-agents-customizations/.agents|.codex` plus ignores for `.claude/agent-memory`, `.claude/state/`, `.codex/state/`. There is no ignore rule for `.codex/agents` or `.agents/skills`. (Matches the #903 P7 research, `p7-evidence-timestamps-903.2026-10-11T15-05.md:47`.)
- Tracked state (inferred, not run): this worktree is a fresh checkout and contains `.codex/agents/orchestrator.toml` and `.agents/skills/atomic-plan-contract/SKILL.md`; a fresh worktree holds tracked files only, so the directories are tracked. Plan must confirm with `git ls-files .codex/agents .agents/skills | head`.
- CI: `.github/workflows/_quality-checks.yml:17` uses `actions/checkout@v7` (no sparse checkout found in the workflows grep) and `:81` runs `poetry run pytest --cov --cov-branch ...`. Tracked directories are therefore present on Linux CI, so the skip condition is false there (inferred from workflow text; not confirmed by a CI log).
- Prior runs: #903 evidence `evidence/qa-gates/py-contract-suites.2026-10-13T13-48.md` ran this file with five others, `-q -rA`: "79 passed in 0.45s", zero skips reported. #484 evidence `contract-suites-after.md:37` shows `test_codex_handoff_contract_parity.py .....` (five dots, no `s`). Both indicate the two guarded tests execute and pass unskipped.
- #903 P7 mirror test: `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py:196-212`, `test_atomic_plan_contract_matches_bundled_mirror`, parametrized over `PLAN_CONTRACT_MIRROR_PAIRS` (lines 45-57; claude, agents, github), asserts byte equality unconditionally. It covers only the `atomic-plan-contract` agents pair; the other 14 shared skills and the 11 agents remain covered only by the guarded tests.

### Candidate approaches
A. Remove the skip (delete lines 11-15 and both decorators; remove the then-unused `import pytest` at line 7). The skip protects nothing: directories are tracked, CI has them, and the tests pass. Leaving a conditional skip risks silently dropping the parity checks if the directories vanish; with the skip removed, a missing directory fails loudly (`FileNotFoundError`), which is the desired fail-fast behavior per `general-code-change.md`.
B. Keep the skip and correct the reason (for example "skipped when .codex/.agents are absent from the checkout"). Rejected: retains a silent-skip path with no known scenario that needs it.
C. Keep unchanged. Rejected: the reason is false per `.gitignore`.

### Recommendation (item 2)
Approach A. The file drops to about 168 lines. Do not touch the P7 mirror test. Confirm before editing that the tests pass unskipped locally (command below); if either fails for a reason other than the skip, fix is out of scope and approach B becomes the fallback.

## #793 and #903 records (verified by reading)
- #793 folder: `docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/` (code review `code-review.2026-10-09T01-30.md:22`: Low finding, "Consider moving shared builders to a test-support module when a third consumer appears"; sibling file was 496 lines per spec D-3).
- #903 folder: `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/`. Operator Follow-up 9 (`issue.md:232`): "#793 L22. An optional refactor that moves `build_valid_epic_state` and `build_read_text_stub` into a `*_test_support.py` module." Follow-up 12 (`issue.md:235`): "Stale `skipif` reason in `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py:11-15` ... which `.gitignore` no longer supports. The new P7 mirror test covers the `atomic-plan-contract` `.agents` pair unconditionally; the skip itself is unchanged."
- #903 P8a research (`research/p8a-review-nits-793-797-845-846-903.2026-10-11T11-00.md:38-40`) records the same consumer facts and advised the decoupling as a separate item moving both builders into a `*_test_support.py` module.
- `gh issue view 903` / `793` were not run (no shell tool).

## Baseline and verification commands (test-only change)

Baseline, before edits (record output under the feature `evidence/baseline/`):
- `poetry run pytest tests/scripts/dev_tools/test_codex_handoff_contract_parity.py -q -rs` (expect 5 passed, no skip lines; this is the unskipped confirmation)
- `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py -q -rs`
- `git ls-files .codex/agents .agents/skills | head`

After edits: rerun the same commands (pass counts must equal baseline; collection must not drop tests), then `poetry run black`, `poetry run ruff check`, `poetry run pyright` on the touched files, then the full `poetry run pytest` loop. Coverage-mode form (CI style): `poetry run pytest <same file list> --cov=scripts/dev_tools --cov-branch -q`; use the directory form, not a `.py` path (a `.py` path measures nothing). No production module changes, and `tests/*` is omitted from coverage, so production coverage is unaffected; no coverage regression is possible from this change. Property/mutation/golden tiers do not apply (no `quality-tiers.yml` check was needed; test-only).

If the optional TS comment edit is included: run the extension's Prettier, ESLint, tsc, and jest for `epic-orchestrator-state-core.test.ts`.

## Complete file list for the fix

Create:
- `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py`

Edit:
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py`
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py`
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py`
- `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py` (docstring only)
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py` (remove skipif and `import pytest`)
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (comment only; optional)

Delete: none.

Numeric derivation: no numeric acceptance criterion is proposed in this research, so no Numeric Derivation Evidence section is required. (Counts such as "13 support modules" and "4 importers" are descriptive; the plan should phrase acceptance criteria as behavior, for example "no test module imports a builder from another `test_*.py` module".)
