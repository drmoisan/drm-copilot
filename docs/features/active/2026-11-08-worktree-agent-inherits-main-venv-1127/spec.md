# worktree-agent-inherits-main-venv (Spec)

- **Issue:** #1127
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T13-30
- **Status:** Draft
- **Version:** 0.2

## Context
An agent running a mutating Poetry command in a sibling worktree changes the packages in the main checkout's `.venv`. The session shell exports `VIRTUAL_ENV` naming the main checkout's environment, and Poetry honors an inherited `VIRTUAL_ENV` over the tracked in-project configuration. Agent worktrees must use their own virtual environment.

Environment:
- OS/version: Windows 11 Pro, PowerShell 7, Claude Code
- Python version: 3.13 through Poetry (2.5.1 observed)
- Command/flags used: `poetry install` in an agent worktree under `.claude/worktrees/`
- Data source or fixture: observed in iar-migration (2026-11-07/08) and repeatedly in this repository (editable-install `.pth` files repointed at a worktree during Epic #1019)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence
Steps to Reproduce:
1. Start a session whose `VIRTUAL_ENV` names the main checkout's `.venv`; create an agent worktree.
2. Run `poetry install` in the worktree.
3. Observe that the main checkout's `.venv` packages and editable-install `.pth` files now point at the worktree.

Expected: each agent worktree uses its own virtual environment; installs in a worktree never change the main checkout's environment.

Actual: the main checkout's `.venv` is modified and must be restored by hand. The `env -u VIRTUAL_ENV` workaround used ad hoc by agents creates a nearly empty `.venv` when followed by a bare `poetry run` without a prior install.

Evidence: `evidence/regression-testing/defect-reproduction.2026-11-08T13-11.md` (baseline reproduction; hooks cannot be exercised live by an isolated subagent before merge, so acceptance rests on Pester evidence plus this baseline). Design research: `research/research.md`.

## Scope & Non-Goals
- In scope: a PreToolUse guard that denies mutating Poetry commands that would write into a virtual environment outside the target project; the `## Worktree Python Environment` skill section in all six `execution-environment` copies; Claude and Codex registration, bundle copies, and core-pack manifest entries; Pester regression tests.
- Out of scope / non-goals: changing how worktrees are created; session-level environment injection through `CLAUDE_ENV_FILE` (observed not to take effect); rewriting commands in the hook (PreToolUse is allow/deny only); `POETRY_VIRTUALENVS_*` environment variables; blocking `poetry run` (it does not write into a foreign environment); treating the hook as a security control.
- Explicitly excluded systems: pytest/Python test code, MCP server, extension TypeScript.

## Root Cause Analysis
`VIRTUAL_ENV` comes from the user's shell before Claude Code starts and is inherited by every agent process. Poetry resolves the active environment from `VIRTUAL_ENV` ahead of the tracked `poetry.toml` (`in-project = true`), so a worktree install targets the main checkout's environment. No skill, agent, or script instructs agents how to bootstrap Python in a worktree, and no mechanism prevents the mutating call.

## Proposed Fix

### Design summary (what changes where):
A new PowerShell PreToolUse hook on the Bash matcher denies the foot-gun deterministically before any write occurs, and a new skill section tells agents the legitimate path. Pure decision logic lives in a dot-sourced sibling helper so Pester tests it with injected inputs.

### Boundaries and invariants to preserve:
- The main checkout's own `poetry install` (VIRTUAL_ENV inside the target) remains allowed.
- Quoted prose naming Poetry commands (for example a commit message) is never matched.
- Existing hooks, gates, and thresholds are not weakened.
- Enforcement hooks do not invoke Python.

### Dependencies or blocked work:
Shared command scanner (`hook-command-scanner.ps1`, `hook-command-invocation.ps1`) and `HookPayload.psm1`. Destination repositories receive the change only after the release carrying it.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New `.claude/hooks/enforce-worktree-poetry-venv.ps1` and a dot-sourced pure helper (command analysis, target-directory resolution, path comparison).
- Codex twin `.codex/hooks/enforce-worktree-poetry-venv.ps1` (byte-identical or function-equivalent) and its helper.
- `.claude/settings.json` (Bash matcher group) and `.codex/config.toml` (`^Bash$` group) registration.
- Bundle copies under `extensions/drm-copilot/resources/` and `core.json` manifest entries for the Claude and Codex packs, including the helper.
- If required by the scanner, a `poetry` entry in the shared command-option table and its mirrors (`-C`, `--directory`, `-P`, `--project` take an argument).
- Six byte-identical copies of `execution-environment/SKILL.md` (repo `.claude`, `.agents`, `.github`, and three bundle copies); the required-headings list in the brief contract test if headings are pinned.
- Hook-dependency-failure tables (Claude and Codex) if research confirms they are exhaustive.

#### Functions/classes/CLI commands impacted:
New hook decision function and helper functions only. `poetry install|sync|add|remove|update` invocations are evaluated; all other commands pass through.

#### Data flow and validation changes:
Payload (`tool_input.command`, `cwd`) is parsed; the command is scanned structurally for a Poetry command word with a mutating subcommand; the hook process `VIRTUAL_ENV` is read through an injectable seam; neutralization (`env -u VIRTUAL_ENV` prefix, or `unset VIRTUAL_ENV` before the Poetry word) is checked; the target directory is resolved; the decision is emitted.

#### Error handling and logging updates:
A deny writes hook JSON to stdout (`permissionDecision = deny`, reason prefixed `WORKTREE_VENV_BLOCKED:`) and exits 0. The reason states the legitimate path: run `env -u VIRTUAL_ENV poetry install` from the worktree root, which creates the worktree's own in-project `.venv`; never repoint the main checkout's environment. An unparseable payload fails open with exit 0. This hook is a guard against a known foot-gun, not a security control, so fail-open is deliberate. The standard hook-dependency guard shape applies for dependency load failures.

#### Rollback/feature-flag considerations (if applicable):
Remove the registration entry from `settings.json` / `config.toml`; no data or schema is affected.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: PreToolUse JSON envelope (`tool_name`, `tool_input.command`, `cwd`); `VIRTUAL_ENV` via seam.
- Output: deny JSON plus exit 0, or no output and exit 0.

Deny conditions (all must hold):
1. The command invokes Poetry as a command word (structural scan) with subcommand install, sync, add, remove, or update.
2. Hook process `VIRTUAL_ENV` is non-empty.
3. The command does not neutralize `VIRTUAL_ENV` before the Poetry word.
4. The `VIRTUAL_ENV` path is not equal to or under the target project directory.

Target directory: payload `cwd`, overridden by Poetry's `-C`/`--directory`/`-P`/`--project` value (relative values resolved against `cwd`) or a leading `cd <dir>` segment. If the target cannot be derived, the payload `cwd` is used.

Path comparison normalizes separators, trailing separators, and Git Bash `/c/...` drive forms, is case-insensitive, requires a separator boundary (a sibling such as `.venv-old` is not "under" the target's `.venv`), and is not selected from `$IsWindows`, so the Linux hook-suite job exercises Windows forms as strings.

#### Required configuration keys and defaults:
None. Registration entries only.

#### Backward-compatibility expectations:
All non-matching commands behave as before. Existing Poetry usage that sets `VIRTUAL_ENV` inside the target project is unaffected.

#### Performance constraints (latency/throughput/memory):
One additional pwsh hook invocation per Bash call; the early exit when `poetry` does not appear as a command word keeps the added work to one structural scan.

## Assumptions, Constraints, Dependencies
- Assumptions: the tracked `poetry.toml` sets in-project true; the hook process inherits the same `VIRTUAL_ENV` as the Bash tool; Codex envelopes carry a `cwd` field (confirm during implementation; otherwise the Codex twin falls back to the hook process working directory).
- Constraints: PowerShell or bash only for new tooling; no Python in enforcement hooks; no temp files or environment mutation in tests; files stay under the size limits.
- External dependencies: Poetry behavior as observed on 2.5.1; the extension release pipeline for destination delivery.

## Data / API / Config Impact
- User-facing or API changes: a new deny message prefix `WORKTREE_VENV_BLOCKED:`.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none beyond the deny reason.
- Compatibility notes: a new hook registration in `settings.json` and `config.toml`; the shared command-option table gains a `poetry` entry only if the scanner requires it, and existing `git`/`gh` behavior must not change.

## Test Strategy
- Regression tests to add or update: `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1` and a Codex counterpart under `tests/scripts/codex-hooks/`, plus a registration test asserting `settings.json` and `config.toml` register the hook.
- Unit tests (Pester) covering: the reproduction case (deny); neutralized `env -u VIRTUAL_ENV` form (allow); `unset VIRTUAL_ENV;` form (allow); main checkout's own venv (allow); unset or empty `VIRTUAL_ENV` (allow); quoted prose naming `poetry install` (allow); `-C` and `--directory` override (target changes the decision, relative value resolved against `cwd`); `cd <dir>` override; Git Bash `/c/...`, backslash, trailing-separator, and case variants; sibling-prefix path (deny); non-mutating subcommands such as `run`, `env info`, `show`, `check` (allow); non-Poetry commands (allow); malformed payload (allow, exit 0).
- Edge cases and negative scenarios: empty command, missing `cwd`, missing `tool_input`, compound commands (`cd x && poetry install`).
- Error handling and logging verification: deny JSON shape, reason prefix, and legitimate-path text asserted.
- Coverage impact and targets: line coverage of each new PowerShell file >= 85% (per-file figure read from the Pester coverage report).
- Toolchain commands to run: the repository PowerShell gate (`Invoke-PoshQCParallelTest` covering format, lint, and Pester) and `pytest -n auto`, both against the Phase 0 baseline.
- Manual validation steps: `env -u VIRTUAL_ENV poetry install` in the fresh worktree with before/after comparison of the main checkout's `.venv` `.pth` files and installed package list.

## Acceptance Criteria
- [ ] AC1: Given `VIRTUAL_ENV` naming a directory outside the target project, `poetry install`, `sync`, `add`, `remove`, and `update` are each denied with a reason prefixed `WORKTREE_VENV_BLOCKED:`, deny JSON on stdout, and exit 0 (reproduction case covered by a Pester test).
- [ ] AC2: The deny reason names the legitimate path (`env -u VIRTUAL_ENV poetry install` from the worktree root, creating the worktree's own in-project `.venv`) and states that the main checkout's environment must not be repointed (asserted in a Pester test).
- [ ] AC3: Commands that neutralize `VIRTUAL_ENV` (`env -u VIRTUAL_ENV` prefix, or `unset VIRTUAL_ENV` before the Poetry word) are allowed.
- [ ] AC4: Commands are allowed when `VIRTUAL_ENV` is unset or empty, and when it is equal to or under the target project directory (the main checkout's own `.venv`).
- [ ] AC5: Quoted prose that names a Poetry command (for example a commit message or `echo` argument) is allowed because only structural command-word invocations are matched.
- [ ] AC6: Non-mutating Poetry subcommands (`run`, `env info`, `show`, `check`) and non-Poetry commands are allowed.
- [ ] AC7: The target directory honors payload `cwd`, a Poetry `-C`/`--directory`/`-P`/`--project` override (relative values resolved against `cwd`), and a leading `cd <dir>` segment; each has a Pester test in which the override changes the decision.
- [ ] AC8: Path comparison handles backslash, forward-slash, trailing-separator, Git Bash `/c/...`, and case variants as pure strings, rejects a sibling-prefix path such as `.venv-old` as "under", and does not depend on `$IsWindows`, so the same tests pass on the Linux hook-suite job.
- [ ] AC9: An unparseable or malformed payload fails open with exit 0, and the spec's statement that the hook is a guard against a known foot-gun rather than a security control is recorded in the hook's header comment.
- [ ] AC10: The hook passes the repository's hook-dependency guard completeness checks in the repo root and bundle roots, and contains no Python invocation (enforcement-hooks-no-Python test passes).
- [ ] AC11: Pure decision logic lives in a dot-sourced sibling helper; tests inject command text, `VIRTUAL_ENV`, and `cwd` without environment mutation or temp files, and the leak scan reports no new finding.
- [ ] AC12: The hook is registered in `.claude/settings.json` (Bash matcher) and `.codex/config.toml` (`^Bash$`), with a Pester registration test asserting both, and the Codex twin is byte-identical or function-equivalent to the Claude hook.
- [ ] AC13: Bundle copies under `extensions/drm-copilot/resources/` and the Claude and Codex core-pack manifest entries exist for the hook, helper, and registrations; the push-down mirror, manifest completeness, and dependency-closure contract tests pass.
- [ ] AC14: Rows for the new hook are added to the Claude and Codex hook-dependency-failure tables if those tables are exhaustive, or the spec's implementation notes record that they are sample-only.
- [ ] AC15: `## Worktree Python Environment` exists in the `execution-environment` skill and states: Poetry honors an inherited `VIRTUAL_ENV` over in-project config; in an agent worktree run `env -u VIRTUAL_ENV poetry install` once from the worktree root before any Poetry command, then `env -u VIRTUAL_ENV poetry run ...`; a bare `poetry run` without install creates an empty `.venv`; the hook denies the mutating form; the worktree's own `.venv` points editable installs at the worktree, so no `PYTHONPATH` override is needed for coverage.
- [ ] AC16: All six `execution-environment/SKILL.md` copies are byte-identical, and `test_execution_environment_brief_contracts.py` passes (with the new heading added to the required list if headings are pinned).
- [ ] AC17: The new regression Pester tests pass in the single `Invoke-PoshQCParallelTest` gate, with no new failures against the Phase 0 baseline of `Invoke-PoshQCParallelTest` and `pytest -n auto`.
- [ ] AC18: Line coverage of each new PowerShell file is >= 85%, read from the per-file Pester coverage report, with no coverage exclusion added for production paths.
- [ ] AC19: If the shared command-option table is changed for Poetry, the existing `git`/`gh` parser acceptance, Issue824 regression, and TriggerScoping suites pass unchanged.
- [ ] AC20: Integration evidence is recorded under the feature's `evidence/` folder: `env -u VIRTUAL_ENV poetry install` in the fresh worktree leaves the main checkout's `.venv` `.pth` files and installed package list unchanged (before/after comparison).
- [ ] AC21: Full toolchain pass completed (format, lint, type-check where applicable, test) with no gate weakened and no threshold lowered.
- [ ] AC22: Rollout notes record that destination repositories need a push-down refresh after the release carrying the hook and skill text.

## Risks & Mitigations
- Technical or operational risks: shared-scanner edits regress `git`/`gh` parsing; mirror drift across Claude, Codex, and three skill families; `Invoke-PoshQCLeakScan` failure if tests set `VIRTUAL_ENV`; Linux CI differs from Windows in path semantics; false deny on an unusual but legitimate target form; Codex `cwd` field unverified.
- Mitigations and rollbacks: structural scanner reuse plus the existing parser suites; per-file mirror task list with contract tests; injected seams instead of environment mutation; string-only path tests; fail-open on underivable input; rollback by removing the registration entries.

## Rollout & Follow-up
- Release/rollout steps: merge, release through the normal extension pipeline; destination repositories receive the hook, helper, settings registration, and skill text through the Claude and Codex core packs and need a push-down refresh after the release that carries them. A repository-side edit does not change pushed payloads until rebuild and reinstall.
- Post-fix monitoring or clean-up tasks: watch for `WORKTREE_VENV_BLOCKED:` denials that block a legitimate flow; repoint any `.pth` files left over from earlier incidents with `poetry install` from the main checkout.
- Links: issue #1127; `issue.md`; `research/research.md`; `evidence/regression-testing/defect-reproduction.2026-11-08T13-11.md`.
