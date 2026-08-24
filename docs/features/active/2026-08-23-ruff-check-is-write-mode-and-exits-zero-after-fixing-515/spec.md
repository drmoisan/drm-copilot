# 2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing (Spec)

- **Issue:** #515
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23
- **Status:** Ready for Planning
- **Version:** 1.0

## Context

`pyproject.toml` sets `fix = true` under `[tool.ruff]` (`pyproject.toml:91`), so `poetry run ruff check` rewrites fixable violations in place and still exits 0. Every agent and workflow that reads "ruff exited 0" as "the lint stage found nothing and changed nothing" is wrong, and the mandatory-toolchain rule in `.claude/rules/general-code-change.md` requires a restart from stage 1 whenever a stage auto-fixes a file — an obligation nothing in the repository currently observes.

The research artifact (`research/2026-08-23T21-05-ruff-write-mode-research.md`) confirmed the configuration state (section 1), inventoried 31 bare call sites plus published mirrors (sections 2.1 and 2.2), identified two call sites whose control flow is already miscomputing under fix mode (section 2.4), and confirmed CI exposure in `.github/workflows/_quality-checks.yml` (section 3).

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: ruff 0.15.12 under Poetry; Python 3.13
- Command/flags used: bare `poetry run ruff check` against a scratch file, and the same command with `--no-fix`
- Data source or fixture: `pyproject.toml` lines 88-92 (`fix = true` at line 91, `show-fixes = true` at line 92) at commit `bee15c06`, re-confirmed unchanged during research

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. It is repository-wide and silent, and it defeats a rule rather than a single gate. Three consequences, in decreasing order of severity:

1. **The restart-on-auto-fix rule is unenforceable.** `.claude/rules/general-code-change.md` requires restarting the seven-stage loop from step 1 if any stage "auto-fixes any files". No agent can comply, because the auto-fix produces no signal.
2. **An agent can lose its own edit and be told it succeeded.** If an agent writes an import that turns out to be unused, the lint stage deletes the line and reports success. The agent proceeds believing its code is intact. This was found in exactly that form: an atomic plan for issue #502 anticipated an `F401` on a specific task and gated it with the bare command, so the gate would have silently repaired the defect it was written to catch (`issue.md` line 79).
3. **Any acceptance gate stating "ruff exits 0" is satisfiable by a run that rewrote production files.** That is the same unfalsifiable-gate class the repository already recorded for plan acceptance gates.

It is not a Blocker because it fails toward a *formatted* tree rather than a broken one; the damage is to observability and to agent reasoning, not directly to correctness.

## Repro & Evidence

Steps to Reproduce:
1. Confirm the configuration: `[tool.ruff]` in `pyproject.toml` sets `fix = true` (line 91) and `show-fixes = true` (line 92).
2. Create a scratch file outside the repository containing an unused import followed by any statement, for example `import os` then `x = 1`.
3. Record the file's content or hash.
4. Run the bare `poetry run ruff check` against that scratch file and record both the exit code and the file's content afterwards.
5. Recreate the same file and run the same command with `--no-fix` appended, again recording exit code and content.
6. Compare.

Expected:
A command named `check` should not modify its input. Whatever the configured default, a stage that rewrites source must be observable as having done so: either it exits non-zero, or the repository provides a gate that detects the rewrite. The toolchain rule's restart-on-auto-fix requirement presupposes that an auto-fix is detectable.

Actual:
Step 4 deletes the import and exits 0. Step 5 leaves the file untouched and exits 1. Verbatim record from `issue.md` lines 42-58:

```text
$ poetry run ruff check <file>
Fixed 1 error:
- <file>:
    1 × F401 (unused-import)
Found 1 error (1 fixed, 0 remaining).
(exit 0)
--- file after: the `import os` line has been deleted ---

$ poetry run ruff check --no-fix <file>
F401 [*] `os` imported but unused
I001 [*] Import block is un-sorted or un-formatted
Found 2 errors.
[*] 2 fixable with the `--fix` option.
(exit 1)
--- file after: unchanged ---
```

The rewrite was confirmed by comparing file content before and after, not inferred from the output text (`issue.md` line 60). The research artifact cites this as reported evidence and did not re-execute it; the research agent had no command-execution tool (research section "Evidence Method and Its Limits").

Note the asymmetry that makes this easy to miss. The repository already guards three write-mode stages: `black .` is guarded by asserting no output line begins with `reformatted `, and both `run_poshqc_format` and `npm run format` are guarded by before/after `git status` snapshot pairs. All three are formatters. The linter has the identical write-mode property and no guard at all, because reviewers checking "which stages write" have consistently read that as "which formatters write".

CI exposure, confirmed at `.github/workflows/_quality-checks.yml` lines 59-62 (research section 3): the step `Lint with Ruff` runs the bare form with `continue-on-error: false` on every matrix leg. A fixable finding therefore never fails that step, and the in-runner rewrite is discarded with the ephemeral checkout. The immediately preceding step at line 56 runs `poetry run black --check .`, the explicitly read-only form of the formatter, which makes the asymmetry visible in adjacent lines of the same file.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet is inlined under **Actual** above.

## Scope & Non-Goals

### In scope

Adopt research direction (a) (research section 4(a) and the recommendation in section 4): remove the fix-mode default from the shared Ruff configuration and add a configuration-alignment regression test.

The diff this spec authorizes writes exactly two repository files:

- `pyproject.toml` — delete the `fix = true` line from the `[tool.ruff]` table (currently `pyproject.toml:91`). No other line in that file changes. `show-fixes = true` at `pyproject.toml:92` is retained.
- `tests/scripts/dev_tools/test_ruff_config_alignment.py` — new file carrying the research section 6.3 assertions.

In addition, the change writes this feature's own documents and evidence under `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/` (this spec, the atomic plan, and evidence artifacts under that folder's `evidence` subtree). No other repository file is written.

The write-target inventory is taken from research section 7, which also records why nothing else needs to change: no bundled `pyproject.toml` exists under `extensions/drm-copilot/resources/`, and the two push-down byte-parity tests scope only to `.claude/**`, `.agents/**`, and `.codex/**`, so neither write target is in their scope.

### Out of scope / non-goals

1. **Research direction (b), requiring `--no-fix` at every agent-facing call site — rejected.** The decisive reason is that it requires editing `.claude/rules/python.md:14` and `.github/instructions/python-code-change.instructions.md:47`, both of which are inside the modification prohibition: `CLAUDE.md` states the `.github/instructions/**` files "are the canonical policy source. Do not modify them", and `.claude/skills/policy-compliance-order/SKILL.md:32` states "Do NOT modify policy documents under `.claude/rules/` or `.github/instructions/`." The mechanical reasons stand alongside it (research section 4(b)): the direction touches at least 18 agent-facing call sites plus 9 published mirrors, a new call site added later defaults back to write mode so the guarantee decays by discipline rather than by construction, and it does not fix CI because the workflow step is not an agent-facing document. **No policy exception is requested and none is needed**; direction (a) is confined entirely to non-policy surfaces (research section 5 table).

2. **Research direction (c), a dedicated Poetry script or task target for the agent path — rejected.** Same decisive reason: agents must be told to prefer the new target, which means editing the same two prohibited policy documents. Mechanically it also leaves the bare form write-mode for anyone who does not use the new target, adding a surface without closing the default. `.vscode/tasks.json` already defines both `QC: 2 Ruff: lint` (line 338) and `QC: 2 Ruff: fix` (line 360); the problem is not a missing target but that the two behave identically under `fix = true`.

3. **Research direction (d), a lint-step diff snapshot in `scripts/dev_tools/atomic_executor/qc_runner_loop.py` — deferred, not implemented here.** Recorded as a follow-up recommendation under **Rollout & Follow-up**. No task authorized by this spec may write that file.

4. **The stdin differential integration test (research section 6.4) — out of scope.** Three reasons: the stdin fix-output mechanism was explicitly not verified in the research environment (research section 6.4, closing paragraph); it would be the repository's first test spawning a real toolchain process, with no precedent found under `tests/` where every `subprocess.run` occurrence is a mock (research section 6.1); and `.claude/rules/general-unit-test.md` prohibits unit-test dependence on external processes. The differential survives as manual QA-gate evidence per research section 6.5 item 3, not as a committed test.

5. **Filing follow-up GitHub issues — out of scope.** The two follow-up recommendations are recorded as prose under **Rollout & Follow-up**. No file is created under `docs/features/potential/`.

6. **Historical atomic plans are not edited.** Research section 2.6 counts 1363 occurrences of `ruff check` across 786 files, the large majority under `docs/features/archive/**` and `docs/features/active/**`. Plans are point-in-time records, and `.claude/rules/plan-acceptance-gates.md` section "Scope of Invocation" is explicit that no sweep evaluates the committed plan corpus. Making the bare form read-only going forward retroactively gives those gates the meaning their authors intended.

### Explicitly excluded systems, integrations, or datasets

- The published/bundled destination copies under `extensions/drm-copilot/resources/` (research section 2.2). None is written, and none needs to be, because no bundled Ruff configuration exists.
- `.vscode/tasks.json`, `.devcontainer/**`, `README.md`, `.github/agents/**`, `.github/prompts/**`, and `.claude/skills/python-qa-gate/SKILL.md`. All name the bare command; all become read-only without edit once the default is removed.
- `.github/workflows/_quality-checks.yml`. The lint step is fixed by the configuration change and its text is unchanged; the regression test asserts the step continues to exist.
- Explicit `--fix` call sites (`scripts/dev_tools/fix_all.py:473`, `.vscode/tasks.json:349-353`, `.devcontainer/QUICKSTART.md:35`). An explicit `--fix` is a visible, intentional request to write and is the behavior the issue wants preserved (research section 4, residual 3).

## Root Cause Analysis

`pyproject.toml:91` sets `fix = true` under `[tool.ruff]`. This was a deliberate developer convenience for interactive use. The defect is not the setting in isolation but that agent-facing policy, executor logic, and acceptance gates were all written as though it were absent.

Three facts establish that removing the default costs no capability:

1. **Every path in the repository that intends to auto-fix already passes `--fix` explicitly** (research section 2.3): `scripts/dev_tools/fix_all.py:473`, `.vscode/tasks.json:349-353`, and `.devcontainer/QUICKSTART.md:35`. A content search for `--no-fix` or `--fix` outside `docs/**` returned exactly those three hits. Nothing depends on `fix = true` to obtain auto-fix behavior.
2. **`.vscode/tasks.json` is decisive on intent.** It defines `QC: 2 Ruff: lint` (bare, label at line 338) and `QC: 2 Ruff: fix` (`--fix`, label at line 360) as two separate tasks. Under `fix = true` they are behaviorally identical, so the file was authored on the assumption that the bare form does not write.
3. **`pyproject.toml` is the only Ruff configuration source** (research section 1). A glob for `**/ruff.toml` returned no files, a glob for `extensions/drm-copilot/resources/**/pyproject.toml` returned no files, and `.vscode/settings.json` does not exist, so no committed `codeActionsOnSave` or `source.fixAll.ruff` setting is affected.

Two call sites are already miscomputing in code, and both are repaired incidentally by removing the default (research section 2.4):

- `scripts/dev_tools/fix_all_branches_extra.py:75-127`. The function comment at lines 75-76 states that "a Ruff auto-fix can change formatting, so the loop restarts Black and Ruff until Ruff passes without applying fixes." The loop runs the bare form at line 97 and branches on the return code at line 101; `returncode == 0` breaks out at line 127. Under `fix = true`, a run that fixes everything it found returns 0, so the loop breaks, the files were rewritten, and Black is never re-run. Removing the default makes the loop take its non-zero branch on a fixable finding, which is the behavior its own comment describes.
- `scripts/dev_tools/atomic_executor/qc_runner_loop.py:199-250`. The full QC loop takes a `diff_signature_fn` snapshot before the format step (lines 204-208) and after it (lines 227-231) and restarts when they differ (lines 232-233). No such snapshot pair brackets the lint step at lines 235-240, so a write performed by the linter is structurally invisible and the loop returns `QCLoopResult(success=True, ...)` at line 287. Removing the default makes this moot for the configured toolchain; making it *detectable* is direction (d), deferred.

The write-mode versus read-only command inventory produced during investigation is retained here as durable record:

- **Write-mode:** `black .`, `ruff check` (this defect), `run_poshqc_format`, `npm run format`, `npm ci`, `git add -A`.
- **Read-only, verified:** `black --check`, `ruff check --no-fix`, `pyright`, all `pytest` invocations, `run_poshqc_analyze`, `run_poshqc_test`, `npm run lint` (eslint with no `--fix`, and no fix setting in `eslint.config.mjs`), `npm run typecheck`.

## Proposed Fix

### Design summary (what changes where)

Delete the fix-mode default from the shared Ruff configuration so the bare command becomes read-only for all 31 inventoried call sites and for CI simultaneously, with no edit to any of them, and add a configuration-alignment regression test that fails if fix mode is reintroduced or if the gate it guards is removed.

- `pyproject.toml`: remove `fix = true` from `[tool.ruff]`. Retain `show-fixes = true`. With fix mode off, `show-fixes` reports which findings are fixable rather than which fixes were applied, which preserves the diagnostic property the issue requires at `issue.md` line 98 while removing the write (research section 4, recommendation).
- `tests/scripts/dev_tools/test_ruff_config_alignment.py`: new test module carrying the research section 6.3 assertions.

### Boundaries and invariants to preserve

- Explicit `--fix` continues to auto-fix. The `QC: 2 Ruff: fix` task, `fix_all.py`'s `_ruff_fix`, and the devcontainer quickstart command are unaffected.
- The Ruff rule selection, line length, target version, and per-file ignores in `pyproject.toml` lines 88-112 are unchanged apart from the single deleted line.
- The CI lint gate remains present and remains `continue-on-error: false`.
- No policy document under `.claude/rules/` or `.github/instructions/` is written.
- Ruff still reports fixable violations rather than hiding them.

### Dependencies or blocked work

None. The change depends on no other issue, no external service, and no unmerged work. Research section "Automation Feasibility" records that every step is automatable and no human interaction is required; the `Bash(poetry run *)` grants already present (for example `.claude/agents/atomic-executor.md:12`) cover the verification commands.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

- `pyproject.toml` — single-line deletion.
- `tests/scripts/dev_tools/test_ruff_config_alignment.py` — new file.

#### Functions/classes/CLI commands impacted

No production function, class, or CLI command is edited. The behavior of the following changes without any edit to them: the CI step `Lint with Ruff`; `PYTHON_TOOLCHAIN_COMMANDS["ruff"]` (`scripts/dev_tools/atomic_executor/qc_toolchain.py:45`); `QCRunner.FULL_LINT` and the scoped task gate (`scripts/dev_tools/atomic_executor/qc_runner.py:79, 141, 367`); the preflight QC step list (`scripts/dev_tools/atomic_executor/cli_preflight.py:119`); and the `fix_all_branches_extra.py` loop described under Root Cause Analysis.

The regex at `scripts/dev_tools/atomic_executor/qc_toolchain.py:31` and the permission grant at `.claude/agents/atomic-executor.md:12` need no change under this direction (research section 2.5).

#### Data flow and validation changes

None. No runtime data path is altered. The only behavioral delta is that the linter no longer writes to the working tree when invoked without `--fix`, and consequently returns a non-zero exit code on a fixable violation.

#### Error handling and logging updates

None in production code. The observable output of the lint stage changes from "Found N errors (N fixed, 0 remaining)" with exit 0 to a per-violation listing with the `[*]` fixable marker and a non-zero exit code, which is the intended diagnostic behavior.

#### Rollback/feature-flag considerations (if applicable)

Rollback is restoring one line in `pyproject.toml`. No feature flag is introduced. Restoring the line would fail the new regression test, which is the intended deterrent rather than an obstacle to a deliberate, reviewed reversal.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

The new test module reads two committed files as text and queries the filesystem for the absence of two root paths. It spawns no process, creates no file, and depends on no external service.

#### Required configuration keys and defaults

- `[tool.ruff] fix` — removed. Ruff's own default for `fix` is false, so the bare command becomes read-only.
- `[tool.ruff] show-fixes` — retained as `true`.
- No configuration key is added.

#### Backward-compatibility expectations

- Human interactive use: the bare command stops writing. This is the intended change and is the behavior `.vscode/tasks.json` already assumes.
- Agent use: all bare call sites become read-only with no edit. Historical acceptance gates phrased as "the lint stage exits 0" recover their intended meaning.
- A pull request that would previously have passed CI while carrying a fixable violation will now fail the `Lint with Ruff` step. This is the correction, not a regression, but it is the one externally visible behavior change and is called out under **Risks & Mitigations**.

#### Performance constraints (latency/throughput/memory)

None. Disabling fix mode does not increase lint duration; it removes a write phase.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - Ruff's built-in default for `fix` is false, so deleting the key restores read-only behavior rather than leaving the setting undefined in an unpredictable state. This is verified at execution time by the manual QA-gate check in the Test Strategy, not assumed silently.
  - The issue author's reproduction (`issue.md` lines 42-58) is accurate; the research agent cited it as reported evidence without re-executing it.
- Constraints (budget, performance, compatibility):
  - `.claude/rules/general-unit-test.md` prohibits creation and use of temporary files in tests, and prohibits dependence on external processes. Restated at `.claude/rules/python.md:87` and `.claude/rules/python.md:99`. The regression test satisfies both by asserting on committed text only.
  - `.claude/rules/general-unit-test.md` requires tests to live in a `tests/` tree mirroring the production structure; colocation is not permitted. The chosen path satisfies this and matches the exact precedent `tests/scripts/dev_tools/test_pyright_config_alignment.py`.
  - The supported Python floor is `>=3.10,<4.0` (`pyproject.toml:17`) and the CI matrix includes 3.10 (`.github/workflows/_quality-checks.yml:13`), so `tomllib` is not available on every supported leg. The test uses text assertions in the style of `test_pyright_config_alignment.py:17-18`, which research section 6.3 identifies as the lower-risk choice.
  - `.claude/rules/general-code-change.md` limits any file to 500 lines. Both write targets remain far below it.
- External dependencies (services, libraries, releases): none. No dependency is added, removed, or version-pinned.

## Data / API / Config Impact

- User-facing or API changes: none beyond the lint stage's exit-code and write behavior described under Backward-compatibility expectations.
- Data or migration considerations: none. No persisted data, schema, or artifact format changes.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag is added or removed at any call site. `pyproject.toml` loses one key from `[tool.ruff]`. No published mirror requires a matching edit; research section 7 confirms neither write target is in scope for the two push-down byte-parity tests at `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:207-220`.

## Test Strategy

Seeded from issue:

- [x] Unit coverage areas — a test asserting the agent-facing lint invocation is read-only. Delivered as a configuration-alignment assertion rather than an execution assertion: a test asserting only the exit code would reproduce the blind spot, and a test that executes the linter would depend on an external process.
- [x] Integration scenario to retest — the differential. Delivered as manual QA-gate evidence rather than as a committed test, for the three reasons under Scope non-goal 4.
- [x] Manual verification notes — after the fix, confirm the lint stage still *fails* on an unfixable violation and still reports fixable violations rather than hiding them. A change that made the stage silent on real findings would be worse than the defect.

Regression tests to add:

`tests/scripts/dev_tools/test_ruff_config_alignment.py`, carrying four named tests (research section 6.3):

1. `test_ruff_config_does_not_enable_fix_mode` — reads `pyproject.toml` and asserts the `[tool.ruff]` table does not enable fix mode. Closes research residual 1.
2. `test_ruff_config_retains_show_fixes` — asserts `show-fixes = true` remains present, so the diagnostic property required by `issue.md` line 98 cannot be silently dropped.
3. `test_no_standalone_ruff_config_at_repository_root` — asserts neither `ruff.toml` nor `.ruff.toml` exists at the repository root. Closes research residual 2.
4. `test_quality_checks_workflow_still_runs_a_ruff_lint_step` — asserts `.github/workflows/_quality-checks.yml` still invokes a Ruff lint step, so a later change cannot satisfy tests 1 through 3 by deleting the gate.

Test module structure follows `tests/scripts/dev_tools/test_pyright_config_alignment.py`: resolve `Path(__file__).resolve().parents[3]` as the repository root, read the target file as UTF-8 text, and assert on its content. Deterministic, no subprocess, no fixture file, no temporary file.

- Edge cases and negative scenarios: test 1 must reject whitespace and comment variants of the setting, not only the exact byte sequence currently present. Test 3 must check both the dotted and undotted root filenames. Test 4 must assert on the invocation rather than on the step name alone, so renaming the step does not fail the test while deleting the command does.
- Error handling and logging verification: not applicable; no error path is added.
- Coverage impact and targets: `pyproject.toml` is configuration, not measured production source (`[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, `pyproject.toml:120`), so this change adds no uncovered production lines and the >= 85% line and >= 75% branch thresholds in `.claude/rules/quality-tiers.md` are unaffected (research section 6.6).
- Fail-before evidence: run the new test module against the unmodified `pyproject.toml` and record the failure of `test_ruff_config_does_not_enable_fix_mode`, then record the pass after the deletion. Store under this feature's `evidence/regression-testing/` folder using the `yyyy-MM-ddTHH-mm` timestamp convention.
- Toolchain commands to run: the seven-stage loop in `.claude/rules/general-code-change.md`, in order, restarting from stage 1 if any stage fails or changes a file. For the Python legs this is `poetry run black --check .`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
- Manual validation steps: capture the two verifications required by `issue.md` line 98 as QA-gate evidence — the lint stage still fails on an unfixable violation, and it still reports fixable violations with the `[*]` marker rather than hiding them, with the target content byte-identical afterwards. Record the working-tree state before and after the lint stage to demonstrate the stage performed no write. Artifacts go under this feature's `evidence/qa-gates/` folder. Because the expected exit code for a violation check is non-zero, the artifact must declare `ExpectedExitCode` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

## Acceptance Criteria

- [x] The `[tool.ruff]` table in `pyproject.toml` no longer enables fix mode, and `tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode` passes against the post-change tree.
- [x] `show-fixes = true` remains present in the `[tool.ruff]` table, and `tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_retains_show_fixes` passes.
- [x] Neither `ruff.toml` nor `.ruff.toml` exists at the repository root, and `tests/scripts/dev_tools/test_ruff_config_alignment.py::test_no_standalone_ruff_config_at_repository_root` passes (research residual 2).
- [x] The Ruff lint step in `.github/workflows/_quality-checks.yml` still exists and still invokes the linter, and `tests/scripts/dev_tools/test_ruff_config_alignment.py::test_quality_checks_workflow_still_runs_a_ruff_lint_step` passes, so the preceding three criteria cannot be satisfied by deleting the gate.
- [x] `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py -v` collects exactly the four named tests above and reports 4 passed with 0 failed and 0 errors; the run output is recorded as evidence under this feature's `evidence/regression-testing/` folder with `Timestamp`, `Command`, and `EXIT_CODE` fields.
- [x] Fail-before evidence is recorded: a run of `test_ruff_config_does_not_enable_fix_mode` against the pre-change `pyproject.toml` fails, and the same test passes after the deletion. Both runs are recorded in a single artifact under this feature's `evidence/regression-testing/` folder, with the failing run declaring its expected non-zero exit code per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- [x] `git diff --name-only` against the merge base lists exactly `pyproject.toml`, `tests/scripts/dev_tools/test_ruff_config_alignment.py`, and paths under `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/`. In particular the list contains neither `.claude/rules/python.md`, nor `.github/instructions/python-code-change.instructions.md`, nor `scripts/dev_tools/atomic_executor/qc_runner_loop.py`.
- [x] The lint stage performs no write: a working-tree status snapshot taken immediately before `poetry run ruff check` and another taken immediately after are byte-identical, and the pair is recorded as QA-gate evidence under this feature's `evidence/qa-gates/` folder. A criterion stating only that the lint stage exits 0 is explicitly insufficient and is not accepted in its place, because that formulation is satisfiable by a run that rewrote production files.
- [x] The manual verification required by `issue.md` line 98 is recorded as QA-gate evidence under this feature's `evidence/qa-gates/` folder: against a scratch input outside the repository containing an unfixable violation the lint stage exits non-zero, and against a scratch input containing a fixable violation it exits non-zero, reports the violation with the `[*]` fixable marker, and leaves the input byte-identical. The artifact declares `ExpectedExitCode` for each non-zero expectation.
- [x] The seven-stage toolchain in `.claude/rules/general-code-change.md` completes with all applicable stages passing in a single pass with no stage having changed a file, and the stage outputs are recorded as QA-gate evidence under this feature's `evidence/qa-gates/` folder.

## Risks & Mitigations

- **Technical or operational risks:**
  1. *Previously passing pull requests begin failing the CI lint step.* Any branch carrying a fixable violation now fails `Lint with Ruff` instead of passing after a discarded in-runner rewrite. This is the correction the issue asks for, but it is a real change in observed CI outcomes and may surface pre-existing violations on open branches.
  2. *Interactive human behavior changes.* A developer who relied on the bare command auto-fixing must use `QC: 2 Ruff: fix` or pass `--fix`.
  3. *The default can be reinstated* by re-adding the key to `pyproject.toml` (research residual 1), or by adding a root `ruff.toml` (residual 2), or by a caller passing `--fix` or `--config` (residual 3).
  4. *The fix removes the default, not the capability.* If a future change reintroduces a writing linter step by a route the configuration test does not observe, `qc_runner_loop.py` still has no snapshot bracketing the lint step, so the write would again be undetectable (research section 4, fourth residual).
  5. *A brittle text assertion could fail on an unrelated reformatting of `pyproject.toml`.* Text assertions were chosen over a TOML parse because `tomllib` is unavailable on the Python 3.10 CI leg.

- **Mitigations and rollbacks:**
  1. Failures are visible, actionable, and fixable with the existing explicit `--fix` path. No mitigation beyond normal branch remediation is required.
  2. Both explicit-fix paths already exist and are unchanged; `.vscode/tasks.json` already exposes a fix task by name.
  3. Residual 1 is closed by `test_ruff_config_does_not_enable_fix_mode`; residual 2 is closed by `test_no_standalone_ruff_config_at_repository_root`; residual 3 is accepted deliberately, because an explicit `--fix` is a visible, intentional request to write and only the silent form is the defect.
  4. Accepted for this item and recorded as follow-up recommendation 1 under **Rollout & Follow-up**. This is the reason direction (d) is deferred rather than dropped.
  5. The assertions are written to tolerate whitespace and comment variation rather than to match an exact byte sequence, and `test_quality_checks_workflow_still_runs_a_ruff_lint_step` ensures the module cannot be trivially satisfied. Rollback for the whole change is restoring one line in `pyproject.toml`.

## Rollout & Follow-up

- **Release/rollout steps:** ordinary pull-request flow against `main`. No migration, no feature flag, no coordinated release, no protected-surface merge beyond the normal flow.
- **Post-fix monitoring or clean-up tasks:** on the first CI run after merge, confirm the `Lint with Ruff` step still passes on `main`; a failure would indicate a pre-existing fixable violation that the write-mode step had been hiding, which should be fixed with an explicit `--fix` run rather than by reverting this change.

- **Follow-up recommendation 1 — direction (d), a lint-step diff snapshot in the executor QC loop.** `scripts/dev_tools/atomic_executor/qc_runner_loop.py:199-250` could bracket the lint step with the same `diff_signature_fn` pair it already applies to the format step at lines 204-233, making an auto-fix by *any* linter detectable and the restart-on-auto-fix requirement in `.claude/rules/general-code-change.md` genuinely enforceable rather than merely moot. It is deferred from this item because it changes execution-control logic in the atomic executor, which is a materially larger and riskier diff than a one-line configuration deletion, and because it would require its own test coverage for the restart path (research section 4(d)). The `fix_all_branches_extra.py:75-127` break-branch behavior is repaired incidentally by this fix and needs no separate work, but is worth noting in any such follow-up as the second instance of the same detection gap. Filing this as an issue is out of scope for the present item.

- **Follow-up recommendation 2 — unenforced `.github/**` published-mirror drift.** Research section 2.2 records that `.claude/**`, `.agents/**`, and `.codex/**` bundled copies are byte-parity enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:207-220`, but the `.github/**` Copilot surface is not: the only mirror assertion (`test_thinking_beast_mode_bundle_mirror_matches_root_agent` at `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py:625-638`) covers exactly one file. The bundled copies of five `.github/**` documents can therefore drift from their repo-root originals silently. This is the same stale-published-copy failure class already recorded for the blast-radius truth table in `.claude/rules/parallel-orchestration.md` under "The published truth table is not a copy of this one (issue #500)". It is not caused by this defect and is not fixed by it; it was surfaced by this investigation and is recorded here for a future item. Filing it is out of scope for the present item.

- **Links:**
  - Issue: https://github.com/drmoisan/drm-copilot/issues/515
  - Research: `research/2026-08-23T21-05-ruff-write-mode-research.md`
  - Bug report: `issue.md`
  - Related prior art on unfalsifiable gates: `.claude/rules/plan-acceptance-gates.md`
