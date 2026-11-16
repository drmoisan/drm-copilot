# Process-Reduction Ledger Regions (P0-T8)

Timestamp: 2026-11-10T03-45
Command: sh SCRATCH/issue-1158-ledger-inventory.sh (pwsh 7; for each file of the P4-T3, P5-T1 to P5-T4, and P6-T2 to P6-T8 edit lists, collect every entry of docs/engineering/process-reductions/ whose `## Files Changed` section names it in backticks, whose `### Revert Block:` heading names it (region located by the first line of its `Current` fence), or whose stored patch has a `diff --git` header for it (region located by the first line after each `@@` hunk header); classify copies by Get-FileHash against the README `## Revert Order` source mapping); then focused debugging runs of the two ledger test files
EXIT_CODE: 0
Output Summary: 118 files inventoried, 103 named by at least one entry; next free entry number 0011 (entries 0001-0010 exist); ProcessReductionChain.Ledger.Tests.ps1 5 passed, 0 failed; ProcessReductionLedger.Index.Tests.ps1 15 passed, 0 failed (debugging runs on the merged tree before any edit).

## Next Free Entry Number

`0011` (no sibling has merged an entry; the README `## Index` ends at 0010).

## Ledger Test Debugging Runs (pre-edit, merged tree)

- `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`: PASSED=5 FAILED=0
- `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`: PASSED=15 FAILED=0

## Copy Classification Rule

A bundle path maps to the repository path below its bundle folder; an `.agents` or `.github` skill copy maps to the `.claude` skill of the same name; a bundle copy whose repository path exists is compared with that path first. "source" means the file is its own source (canonical file, Codex base, or a file with no source mapping). The two `core.json` files are bundle-only sources.

## Inventory

### `.claude/settings.json`

- Exists: True; classification: source
- none

### `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`

- Exists: True; classification: byte-identical to .claude/settings.json
- none

### `.codex/config.toml`

- Exists: True; classification: source
- none

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`

- Exists: True; classification: byte-identical to .codex/config.toml
- none

### `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

- Exists: True; classification: bundle copy (source path absent or file absent)
- 0010 Files Changed
- 0010 patch: diff --git header
- 0010 patch hunk: first line `".claude/hooks/enforce-epic-merge-gate-review.ps1",`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`

- Exists: True; classification: bundle copy (source path absent or file absent)
- 0010 Files Changed
- 0010 patch: diff --git header
- 0010 patch hunk: first line `".codex/hooks/enforce-epic-planning-only.ps1",`

### `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`

- Exists: True; classification: source
- none

### `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`

- Exists: True; classification: source
- none

### `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`

- Exists: True; classification: source
- none

### `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`

- Exists: True; classification: source
- none

### `scripts/dev_tools/atomic_executor/qc_runner_expectations.py`

- Exists: True; classification: source
- none

### `scripts/dev_tools/atomic_executor/qc_runner.py`

- Exists: True; classification: source
- 0001 block: Current first line `"run",`
- 0001 Files Changed

### `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`

- Exists: True; classification: source
- 0001 block: Current first line `def test_full_loop_full_test_runs_xdist_workers(`
- 0001 block: Current first line `"run",`
- 0001 Files Changed

### `scripts/dev_tools/fix_all_runtime.py`

- Exists: True; classification: source
- none

### `scripts/dev_tools/fix_all_branches.py`

- Exists: True; classification: source
- 0001 block: Current first line `if not api.run_simple_step(`
- 0001 block: Current first line `"-Command",`
- 0001 Files Changed

### `scripts/dev_tools/fix_all_branches_extra.py`

- Exists: True; classification: source
- 0001 block: Current first line `)`
- 0001 Files Changed

### `tests/scripts/dev_tools/test_fix_all_branches.py`

- Exists: True; classification: source
- 0001 block: Current first line ``
- 0001 Files Changed

### `scripts/dev_tools/atomic_executor/cli_preflight.py`

- Exists: True; classification: source
- 0001 block: Current first line `"run",`
- 0001 block: Current first line `"   - `poetry run ruff check`",`
- 0001 Files Changed

### `scripts/dev_tools/atomic_executor/cli_task_runtime.py`

- Exists: True; classification: source
- none

### `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py`

- Exists: True; classification: source
- 0001 block: Current first line `assert "poetry run pytest -n auto" in prompt`
- 0001 block: Current first line `_PYTEST_STEP = [`
- 0001 Files Changed

### `tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py`

- Exists: True; classification: source
- 0001 block: Current first line `assert len(copilot_calls) == 1`
- 0001 Files Changed

### `.vscode/tasks.json`

- Exists: True; classification: source
- 0001 block: Current first line `],`
- 0001 block: Current first line `"command": "poetry",`
- 0001 block: Current first line `{`
- 0001 block: Current first line `"QC: 1 Black: format",`
- 0001 Files Changed

### `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1`

- Exists: True; classification: source
- 0001 block: Current first line ``
- 0001 Files Changed

### `.claude/skills/execution-environment/SKILL.md`

- Exists: True; classification: source
- 0001 block: Current first line `- Tests create no temporary files; file and transcript reads go through injected seams with in-memory content.`
- 0001 block: Current first line `- Second, build an expensive immutable fixture once per session and hand each test its own copy wherever a test could mutate it, so test independence is unchanged.`
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- `_shell-coverage.yml` checks out at depth one, so `origin/main` does not exist in that job; no test may diff against it.`
- 0001 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0001 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`
- 0001 patch hunk: first line `- Fix repeated production work first. An immutable structure, such as a schema registry that is rebuilt and re-verified on every call, is built once per owning instance. This speeds up the runtime as well as the tests.`
- 0002 block: Current first line `- Merge guard (#1097): `.claude/hooks/enforce-epic-merge-gate-review.ps1`, byte-identical to its `.codex/hooks/` twin, is dot-sourced by both `enforce-epic-merge-gate.ps1` gates and is inert unless the checkpoint it reads records `review_mode: "concurrent"`. Under that key it denies with `REVIEW_GATE_NOT_PASSED`, `REVIEW_GATE_HEAD_STALE`, or `REVIEW_GATE_HEAD_UNRESOLVED`, each after the token `EPIC_MERGE_GATE_BLOCKED`. It reads the checkpoint of the item target that its gate resolves; on Claude, merge text that names no single pull request also reads the items of at most the first 4 numbers in the text (the shape rule). It is a policy-level control, not a security control (decision D10 in `.claude/rules/orchestrator-state.md`).`
- 0002 block: Current first line `- Merge text under the concurrent-review key (#1097): when a checkpoint the merge gate reads records `review_mode: "concurrent"`, Bash text that could be a merge and cannot be bound to one pull request is denied with `REVIEW_GATE_HEAD_UNRESOLVED`. That includes prose holding `pr merge`, `pr (`, or `pr $`, and a merge followed by a line feed or `;`. Issue a merge as one plain `gh pr merge` of one number in its own Bash call, and pass commit messages through `git commit -F` with a file.`
- 0002 block: Current first line `- Concurrent-review join (#1097): under `review_mode: "concurrent"` a green `CI Required Gate` alone does not permit a merge. The join in `## Concurrent Review and CI (review_mode)` of `.claude/skills/orchestrate/SKILL.md` also needs the last `review_outcomes[]` entry to be `PASS` at a current head, and a `CI full run` check with conclusion `success` at the reviewed head or at an ancestor of it whose diff to the reviewed head lists only `feature-folder` paths. The parallel parent withholds `merge_status: ci_green` and the merge until then.`
- 0002 block: Current first line `- Concurrent checkpoints (#1097): until the extension release that carries the concurrent-review rule is installed, installed MCP accepts a `review_mode: "concurrent"` checkpoint that the PowerShell stop hook and the Python CLI reject, so such a checkpoint is checked with `scripts/dev_tools/validate_orchestration_artifacts.py` in its `orchestrator-state` subcommand with `--require-complete`.`
- 0002 block: Current first line `- `tests/scripts/claude-runtime/concurrent-review-skill-contract.Tests.ps1`: the concurrent-review text of issue #1097 in the orchestrate and parallel-orchestrate skills, the orchestrator-state rule, the orchestrator agent, and their mirrors.`
- 0002 Files Changed
- 0003 block: Current first line `- Light remediation checkpoints (#1097): installed MCP applies invariant 8 only after the extension release that carries it is installed. Until then a Claude run validates a light checkpoint through `scripts/dev_tools/validate_orchestration_artifacts.py` in its `orchestrator-state` subcommand, and on Codex, whose orchestrator requires the installed MCP validator with no fallback, the light path is unavailable.`
- 0003 block: Current first line `- `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1`: the light-remediation text of issue #1097 in the review and orchestration surfaces and their mirrors.`
- 0003 Files Changed
- 0006 block: Current first line `and the sweep of those surfaces for removed serial-run wording.`
- 0006 block: Current first line `- Per-file figures are read from the single gate run and compared with the `Phase 0 baseline` run of the same gate; a new file has no pre-change run and is judged against the thresholds.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0006 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`

### `.agents/skills/execution-environment/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/execution-environment/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- `_shell-coverage.yml` checks out at depth one, so `origin/main` does not exist in that job; no test may diff against it.`
- 0001 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0001 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`
- 0001 patch hunk: first line `- Fix repeated production work first. An immutable structure, such as a schema registry that is rebuilt and re-verified on every call, is built once per owning instance. This speeds up the runtime as well as the tests.`
- 0002 Files Changed
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0006 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`

### `.github/skills/execution-environment/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/execution-environment/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- `_shell-coverage.yml` checks out at depth one, so `origin/main` does not exist in that job; no test may diff against it.`
- 0001 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0001 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`
- 0001 patch hunk: first line `- Fix repeated production work first. An immutable structure, such as a schema registry that is rebuilt and re-verified on every call, is built once per owning instance. This speeds up the runtime as well as the tests.`
- 0002 Files Changed
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0006 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/execution-environment/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- `_shell-coverage.yml` checks out at depth one, so `origin/main` does not exist in that job; no test may diff against it.`
- 0001 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0001 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`
- 0001 patch hunk: first line `- Fix repeated production work first. An immutable structure, such as a schema registry that is rebuilt and re-verified on every call, is built once per owning instance. This speeds up the runtime as well as the tests.`
- 0002 Files Changed
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0006 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/execution-environment/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- `_shell-coverage.yml` checks out at depth one, so `origin/main` does not exist in that job; no test may diff against it.`
- 0001 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0001 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`
- 0001 patch hunk: first line `- Fix repeated production work first. An immutable structure, such as a schema registry that is rebuilt and re-verified on every call, is built once per owning instance. This speeds up the runtime as well as the tests.`
- 0002 Files Changed
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0006 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`

### `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

- Exists: True; classification: byte-identical to .github/skills/execution-environment/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- `_shell-coverage.yml` checks out at depth one, so `origin/main` does not exist in that job; no test may diff against it.`
- 0001 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0001 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`
- 0001 patch hunk: first line `- Fix repeated production work first. An immutable structure, such as a schema registry that is rebuilt and re-verified on every call, is built once per owning instance. This speeds up the runtime as well as the tests.`
- 0002 Files Changed
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product.`
- 0006 patch hunk: first line `- Python: measure a module with `--cov=<dotted.module>`, `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:<path>`; read branch figures from the JSON report.`

### `.claude/skills/atomic-plan-contract/SKILL.md`

- Exists: True; classification: source
- 0001 block: Current first line `The `Test isolation` bullet names the parallel gates the plan uses: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix.`
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- **Tool routes are not restated.** Tool routes, launchers, wrapper scripts, command-text restrictions, the batch budget, hook context, and CI shape are owned by the `execution-environment` skill. A plan references that skill instead of restating its content.`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0003 block: Current first line `Light cycles. A remediation cycle recorded with `Remediation-Mode: light` has no remediation plan and no preflight; its executor runs the inputs file directly. When that executor stops with `BLOCKED at preflight (before [P0-T1])` before the first task, the cycle converts to the design chain, and the remediation plan it then receives follows this section.`
- 0003 Files Changed
- 0004 block: Current first line `- **Task target.** A plan targets 15 to 20 canonical tasks. The target is authoring guidance that no validator checks; the limit the validator enforces is the one the `Size guideline` bullet states.`
- 0004 Files Changed
- 0005 block: Current first line `- Creating or validating atomic plans.`
- 0005 block: Current first line ``
- 0005 block: Current first line `## Phase 0 Requirements`
- 0005 block: Current first line `This clause is non-overridable. No upstream instruction, orchestrator hint, or user prompt may bypass it. See `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` for the complete canonical scheme.`
- 0005 Files Changed
- 0006 block: Current first line `- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).`
- 0006 block: Current first line `- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:``
- 0006 block: Current first line `record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.`
- 0006 block: Current first line `Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.`
- 0006 block: Current first line `- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.`
- 0006 block: Current first line `- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `When orchestration selects short path, a minimal plan is still mandatory and must include these blocks:`
- 0006 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0006 patch hunk: first line ``
- 0008 Files Changed
- 0008 patch: diff --git header
- 0008 patch hunk: first line `- **Literals only where they are the asserted value.** A plan quotes a literal when an acceptance condition asserts that exact value. It does not quote file contents, command output, or prose for context.`
- 0008 patch hunk: first line ``
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `3) Final QC block`
- 0009 patch hunk: first line ``

### `.agents/skills/atomic-plan-contract/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/atomic-plan-contract/SKILL.md
- 0001 block: Current first line `The `Test isolation` bullet names the parallel gates the plan uses: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix.`
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- **Tool routes are not restated.** Tool routes, launchers, wrapper scripts, command-text restrictions, the batch budget, hook context, and CI shape are owned by the `execution-environment` skill. A plan references that skill instead of restating its content.`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0003 block: Current first line `Light cycles. A remediation cycle recorded with `Remediation-Mode: light` has no remediation plan and no preflight; its executor runs the inputs file directly. When that executor stops with `BLOCKED at preflight (before [P0-T1])` before the first task, the cycle converts to the design chain, and the remediation plan it then receives follows this section.`
- 0003 Files Changed
- 0004 block: Current first line `- **Task target.** A plan targets 15 to 20 canonical tasks. The target is authoring guidance that no validator checks; the limit the validator enforces is the one the `Size guideline` bullet states.`
- 0004 Files Changed
- 0005 block: Current first line `- Creating or validating atomic plans.`
- 0005 block: Current first line ``
- 0005 block: Current first line `## Phase 0 Requirements`
- 0005 block: Current first line `This clause is non-overridable. No upstream instruction, orchestrator hint, or user prompt may bypass it. See `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` for the complete canonical scheme.`
- 0005 Files Changed
- 0006 block: Current first line `- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).`
- 0006 block: Current first line `- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:``
- 0006 block: Current first line `record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.`
- 0006 block: Current first line `Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.`
- 0006 block: Current first line `- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.`
- 0006 block: Current first line `- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `When orchestration selects short path, a minimal plan is still mandatory and must include these blocks:`
- 0006 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0006 patch hunk: first line ``
- 0008 Files Changed
- 0008 patch: diff --git header
- 0008 patch hunk: first line `- **Literals only where they are the asserted value.** A plan quotes a literal when an acceptance condition asserts that exact value. It does not quote file contents, command output, or prose for context.`
- 0008 patch hunk: first line `- reject the plan if that validator exits non-zero,`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `3) Final QC block`
- 0009 patch hunk: first line ``

### `.github/skills/atomic-plan-contract/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/atomic-plan-contract/SKILL.md
- 0001 block: Current first line `The `Test isolation` bullet names the parallel gates the plan uses: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix.`
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- **Tool routes are not restated.** Tool routes, launchers, wrapper scripts, command-text restrictions, the batch budget, hook context, and CI shape are owned by the `execution-environment` skill. A plan references that skill instead of restating its content.`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0003 block: Current first line `Light cycles. A remediation cycle recorded with `Remediation-Mode: light` has no remediation plan and no preflight; its executor runs the inputs file directly. When that executor stops with `BLOCKED at preflight (before [P0-T1])` before the first task, the cycle converts to the design chain, and the remediation plan it then receives follows this section.`
- 0003 Files Changed
- 0004 block: Current first line `- **Task target.** A plan targets 15 to 20 canonical tasks. The target is authoring guidance that no validator checks; the limit the validator enforces is the one the `Size guideline` bullet states.`
- 0004 Files Changed
- 0005 block: Current first line `- Executing plans with strict format requirements.`
- 0005 block: Current first line `1) Baseline capture block`
- 0005 block: Current first line ``
- 0005 Files Changed
- 0006 block: Current first line `- baseline capture for each language that has explicit baseline command tasks in the plan: static baselines (format, lint, type check, and analyzer findings) and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run).`
- 0006 block: Current first line `- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:``
- 0006 block: Current first line `record numeric post-change coverage values from the single gate run in `Output Summary:`, compared with the `Phase 0 baseline` run of the same gate.`
- 0006 block: Current first line `Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched and, for each language in scope with coverage policy, one `Phase 0 baseline` run of its test gate: one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, and one Jest coverage run where TypeScript is in scope. Each test-suite baseline artifact records the pass and fail counts, the repo-wide coverage, and the coverage of each in-scope file. The final gate's run of the same gate is compared with it: no new failing test, no per-file or repo-wide coverage drop, the thresholds still apply, and new behavior is tested. A new file has no pre-change run and is judged against the thresholds. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.`
- 0006 block: Current first line `- The approved plan MUST include explicit baseline and final-QC coverage capture tasks: the `Phase 0 baseline` run and the final gate run, each one run of the language's parallel gate.`
- 0006 block: Current first line `- `minor-audit` plans MUST include baseline evidence tasks (static baselines and the `Phase 0 baseline` test-suite run), targeted verification evidence tasks read from the gate run, and end-state evidence tasks.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `When orchestration selects short path, a minimal plan is still mandatory and must include these blocks:`
- 0006 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0006 patch hunk: first line ``
- 0008 Files Changed
- 0008 patch: diff --git header
- 0008 patch hunk: first line `- **Literals only where they are the asserted value.** A plan quotes a literal when an acceptance condition asserts that exact value. It does not quote file contents, command output, or prose for context.`
- 0008 patch hunk: first line `- reject the plan if that validator exits non-zero,`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `3) Final QC block`
- 0009 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/atomic-plan-contract/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- **Tool routes are not restated.** Tool routes, launchers, wrapper scripts, command-text restrictions, the batch budget, hook context, and CI shape are owned by the `execution-environment` skill. A plan references that skill instead of restating its content.`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0003 Files Changed
- 0004 Files Changed
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `When orchestration selects short path, a minimal plan is still mandatory and must include these blocks:`
- 0006 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0006 patch hunk: first line ``
- 0008 Files Changed
- 0008 patch: diff --git header
- 0008 patch hunk: first line `- **Literals only where they are the asserted value.** A plan quotes a literal when an acceptance condition asserts that exact value. It does not quote file contents, command output, or prose for context.`
- 0008 patch hunk: first line ``
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `3) Final QC block`
- 0009 patch hunk: first line ``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/atomic-plan-contract/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- **Tool routes are not restated.** Tool routes, launchers, wrapper scripts, command-text restrictions, the batch budget, hook context, and CI shape are owned by the `execution-environment` skill. A plan references that skill instead of restating its content.`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0003 Files Changed
- 0004 Files Changed
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `When orchestration selects short path, a minimal plan is still mandatory and must include these blocks:`
- 0006 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0006 patch hunk: first line ``
- 0008 Files Changed
- 0008 patch: diff --git header
- 0008 patch hunk: first line `- **Literals only where they are the asserted value.** A plan quotes a literal when an acceptance condition asserts that exact value. It does not quote file contents, command output, or prose for context.`
- 0008 patch hunk: first line `- reject the plan if that validator exits non-zero,`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `3) Final QC block`
- 0009 patch hunk: first line ``

### `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`

- Exists: True; classification: byte-identical to .github/skills/atomic-plan-contract/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- **Tool routes are not restated.** Tool routes, launchers, wrapper scripts, command-text restrictions, the batch budget, hook context, and CI shape are owned by the `execution-environment` skill. A plan references that skill instead of restating its content.`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0003 Files Changed
- 0004 Files Changed
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `When orchestration selects short path, a minimal plan is still mandatory and must include these blocks:`
- 0006 patch hunk: first line `- rerun behavior when any step changes files or fails.`
- 0006 patch hunk: first line ``
- 0008 Files Changed
- 0008 patch: diff --git header
- 0008 patch hunk: first line `- **Literals only where they are the asserted value.** A plan quotes a literal when an acceptance condition asserts that exact value. It does not quote file contents, command output, or prose for context.`
- 0008 patch hunk: first line `- reject the plan if that validator exits non-zero,`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `3) Final QC block`
- 0009 patch hunk: first line ``

### `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `return _WHITESPACE.sub(" ", text)`
- 0001 patch hunk: first line `assert "vitest" not in _read(_BRIEF).lower()`
- 0001 patch hunk: first line `missing = _missing(`
- 0001 patch hunk: first line `assert missing == [], f"Test Isolation Checks lacks {missing}"`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `),`

### `.claude/skills/python-qa-gate/SKILL.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line `1. `poetry run black .``
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `.agents/skills/python-qa-gate/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/python-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line `1. `poetry run black .``
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/python-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line `1. `poetry run black .``
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/python-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line `1. `poetry run black .``
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `.claude/skills/powershell-qa-gate/SKILL.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `.agents/skills/powershell-qa-gate/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/powershell-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/powershell-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/powershell-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `.claude/skills/csharp-qa-gate/SKILL.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `.agents/skills/csharp-qa-gate/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/csharp-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/csharp-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/csharp-qa-gate/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `.claude/skills/invoke-python-engineer/SKILL.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the `python-qa-gate` reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the `python-qa-gate` reporting block:`

### `.agents/skills/invoke-python-engineer/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/invoke-python-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the `python-qa-gate` reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the `python-qa-gate` reporting block:`

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-python-engineer/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/invoke-python-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the `python-qa-gate` reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the `python-qa-gate` reporting block:`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/invoke-python-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the `python-qa-gate` reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the `python-qa-gate` reporting block:`

### `.claude/skills/invoke-powershell-engineer/SKILL.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the `powershell-qa-gate` reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the `powershell-qa-gate` reporting block:`

### `.agents/skills/invoke-powershell-engineer/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/invoke-powershell-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the `powershell-qa-gate` reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the `powershell-qa-gate` reporting block:`

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-powershell-engineer/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/invoke-powershell-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the `powershell-qa-gate` reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the `powershell-qa-gate` reporting block:`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/invoke-powershell-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the `powershell-qa-gate` reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the `powershell-qa-gate` reporting block:`

### `.claude/skills/invoke-csharp-engineer/SKILL.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the following reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the following reporting block:`

### `.agents/skills/invoke-csharp-engineer/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/invoke-csharp-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the following reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the following reporting block:`

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/invoke-csharp-engineer/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/invoke-csharp-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the following reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the following reporting block:`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/invoke-csharp-engineer/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the following reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the following reporting block:`

### `.claude/skills/feature-review-workflow/SKILL.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- `code-review-template` for `code-review.<timestamp>.md``
- 0001 patch hunk: first line `4. tests`
- 0001 patch hunk: first line `- toolchain checks fail`
- 0003 block: Current first line `- Choose the remediation path. Write one line `Remediation-Path: light` or `Remediation-Path: full` into the remediation inputs, and inside each blocking finding block one line `Finding-Scope: contained` or `Finding-Scope: design`. A missing path line reads as `full`, and a missing scope line reads as `design`. These lines never contain the substrings the orchestrator counts.`
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `code-review-template` for `code-review.<timestamp>.md``
- 0006 patch hunk: first line `- Python: `poetry run pytest -n auto --cov-report=term-missing --cov` → artifact: `artifacts/python/lcov.info``
- 0006 patch hunk: first line `- toolchain checks fail`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `- Use `policy-audit-template-usage` and the MCP `template` asset to drive the artifact structure.`
- 0009 patch hunk: first line `- New code files (added in this feature): line coverage >= 85%, and branch coverage >= 75% for branch-capable languages. Flag as FAIL otherwise.`
- 0009 patch hunk: first line `- the code review contains blockers`
- 0009 patch hunk: first line `- copied from the canonical policy-audit template`

### `.agents/skills/feature-review-workflow/SKILL.md`

- Exists: True; classification: non-identical to .claude/skills/feature-review-workflow/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- `code-review-template` for `code-review.<timestamp>.md``
- 0001 patch hunk: first line `4. tests`
- 0001 patch hunk: first line `- toolchain checks fail`
- 0003 block: Current first line `- Choose the remediation path. Write one line `Remediation-Path: light` or `Remediation-Path: full` into the remediation inputs, and inside each blocking finding block one line `Finding-Scope: contained` or `Finding-Scope: design`. A missing path line reads as `full`, and a missing scope line reads as `design`. These lines never contain the substrings the orchestrator counts.`
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `code-review-template` for `code-review.<timestamp>.md``
- 0006 patch hunk: first line `- Python: `poetry run pytest -n auto --cov-report=term-missing --cov` → artifact: `artifacts/python/lcov.info``
- 0006 patch hunk: first line `- toolchain checks fail`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `- Use `policy-audit-template-usage` and the MCP `template` asset to drive the artifact structure.`
- 0009 patch hunk: first line `- PowerShell: one `Invoke-PoshQCParallelTest` run → artifact: `artifacts/pester/powershell-coverage.xml``
- 0009 patch hunk: first line `- the code review contains blockers`
- 0009 patch hunk: first line `- copied from the canonical policy-audit template`

### `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`

- Exists: True; classification: byte-identical to .claude/skills/feature-review-workflow/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- `code-review-template` for `code-review.<timestamp>.md``
- 0001 patch hunk: first line `4. tests`
- 0001 patch hunk: first line `- toolchain checks fail`
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `code-review-template` for `code-review.<timestamp>.md``
- 0006 patch hunk: first line `- Python: `poetry run pytest -n auto --cov-report=term-missing --cov` → artifact: `artifacts/python/lcov.info``
- 0006 patch hunk: first line `- toolchain checks fail`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `- Use `policy-audit-template-usage` and the MCP `template` asset to drive the artifact structure.`
- 0009 patch hunk: first line `- New code files (added in this feature): line coverage >= 85%, and branch coverage >= 75% for branch-capable languages. Flag as FAIL otherwise.`
- 0009 patch hunk: first line `- the code review contains blockers`
- 0009 patch hunk: first line `- copied from the canonical policy-audit template`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`

- Exists: True; classification: byte-identical to .agents/skills/feature-review-workflow/SKILL.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- `code-review-template` for `code-review.<timestamp>.md``
- 0001 patch hunk: first line `4. tests`
- 0001 patch hunk: first line `- toolchain checks fail`
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- `code-review-template` for `code-review.<timestamp>.md``
- 0006 patch hunk: first line `- Python: `poetry run pytest -n auto --cov-report=term-missing --cov` → artifact: `artifacts/python/lcov.info``
- 0006 patch hunk: first line `- toolchain checks fail`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `- Use `policy-audit-template-usage` and the MCP `template` asset to drive the artifact structure.`
- 0009 patch hunk: first line `- PowerShell: one `Invoke-PoshQCParallelTest` run → artifact: `artifacts/pester/powershell-coverage.xml``
- 0009 patch hunk: first line `- the code review contains blockers`
- 0009 patch hunk: first line `- copied from the canonical policy-audit template`

### `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`

- Exists: True; classification: bundle copy (source path absent or file absent)
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`

- Exists: True; classification: bundle copy (source path absent or file absent)
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the following reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the following reporting block:`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`

- Exists: True; classification: bundle copy (source path absent or file absent)
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `Use this skill when:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `Use this skill when:`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md`

- Exists: True; classification: bundle copy (source path absent or file absent)
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `## Output Paths`
- 0001 patch hunk: first line `The worker must return the following reporting block:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `## Output Paths`
- 0006 patch hunk: first line `The worker must return the following reporting block:`

### `.claude/agents/atomic-executor.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0003 block: Current first line `Blocking is permitted only during preflight validation (before `[P0-T1]`). This includes a combined preflight-and-execute run of a proportionate remediation cycle: the run first performs single-pass preflight, fixes trivial defects in place, and stops before `[P0-T1]` only when a substantive defect remains. A light remediation run has no preflight, and stops the same way before `[P0-T1]` only when a fix task cannot be done at its named location. When preflight-blocked:`
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`

- Exists: True; classification: byte-identical to .claude/agents/atomic-executor.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line ``

### `.claude/agents/atomic-planner.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- Phase headings: `### Phase N — <Title>``
- 0001 patch hunk: first line ``
- 0005 block: Current first line `- Sequential task numbering within each phase`
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- Phase headings: `### Phase N — <Title>``
- 0006 patch hunk: first line ``
- 0008 Files Changed
- 0008 patch: diff --git header
- 0008 patch hunk: first line `- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `- Task IDs: `- [ ] [P#-T#] <description>``

### `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`

- Exists: True; classification: byte-identical to .claude/agents/atomic-planner.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- Phase headings: `### Phase N — <Title>``
- 0001 patch hunk: first line ``
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- Phase headings: `### Phase N — <Title>``
- 0006 patch hunk: first line ``
- 0008 Files Changed
- 0008 patch: diff --git header
- 0008 patch hunk: first line `- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)`
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `- Task IDs: `- [ ] [P#-T#] <description>``

### `.claude/agents/python-typed-engineer.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`

- Exists: True; classification: byte-identical to .claude/agents/python-typed-engineer.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``

### `.claude/agents/powershell-typed-engineer.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`

- Exists: True; classification: byte-identical to .claude/agents/powershell-typed-engineer.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``

### `.claude/agents/csharp-typed-engineer.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md`

- Exists: True; classification: byte-identical to .claude/agents/csharp-typed-engineer.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``

### `.claude/agents/typescript-engineer.md`

- Exists: True; classification: source
- none

### `extensions/drm-copilot/resources/claude-customizations/.claude/agents/typescript-engineer.md`

- Exists: True; classification: byte-identical to .claude/agents/typescript-engineer.md
- none

### `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/agents/csharp-typed-engineer.md`

- Exists: True; classification: bundle copy (source path absent or file absent)
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``

### `.codex/agents/atomic-executor.toml`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0003 block: Current first line `Blocking is permitted only during preflight validation (before `[P0-T1]`), including the preflight that opens a combined preflight-and-execute run of a proportionate remediation cycle. A light remediation run has no preflight, and stops the same way before `[P0-T1]` only when a fix task cannot be done at its named location. When preflight-blocked:`
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line ``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml`

- Exists: True; classification: byte-identical to .codex/agents/atomic-executor.toml
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0003 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line ``

### `.codex/agents/atomic-planner.toml`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- Phase headings: `### Phase N — <Title>``
- 0005 block: Current first line `- Sequential task numbering within each phase`
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- Phase headings: `### Phase N — <Title>``
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `- Task IDs: `- [ ] [P#-T#] <description>``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml`

- Exists: True; classification: byte-identical to .codex/agents/atomic-planner.toml
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- Phase headings: `### Phase N — <Title>``
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- Phase headings: `### Phase N — <Title>``
- 0009 Files Changed
- 0009 patch: diff --git header
- 0009 patch hunk: first line `- Task IDs: `- [ ] [P#-T#] <description>``

### `.codex/agents/python-typed-engineer.toml`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `send: false`
- 0006 patch hunk: first line `- Do NOT introduce new frameworks, generic runners, or broad abstractions.`
- 0006 patch hunk: first line `## 5) Toolchain must be executed (no unverified work)`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-typed-engineer.toml`

- Exists: True; classification: byte-identical to .codex/agents/python-typed-engineer.toml
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `send: false`
- 0006 patch hunk: first line `- Do NOT introduce new frameworks, generic runners, or broad abstractions.`
- 0006 patch hunk: first line `## 5) Toolchain must be executed (no unverified work)`

### `.codex/agents/powershell-typed-engineer.toml`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-typed-engineer.toml`

- Exists: True; classification: byte-identical to .codex/agents/powershell-typed-engineer.toml
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``

### `.codex/agents/csharp-typed-engineer.toml`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-typed-engineer.toml`

- Exists: True; classification: byte-identical to .codex/agents/csharp-typed-engineer.toml
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``

### `.codex/agents/typescript-engineer.toml`

- Exists: True; classification: source
- none

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/typescript-engineer.toml`

- Exists: True; classification: byte-identical to .codex/agents/typescript-engineer.toml
- none

### `.codex/agents/python-atomic-executor.toml`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `name = "python-atomic-executor"`
- 0001 patch hunk: first line `- Execute the approved plan exactly as written.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `name = "python-atomic-executor"`
- 0006 patch hunk: first line `- Execute the approved plan exactly as written.`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-atomic-executor.toml`

- Exists: True; classification: byte-identical to .codex/agents/python-atomic-executor.toml
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `name = "python-atomic-executor"`
- 0001 patch hunk: first line `- Execute the approved plan exactly as written.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `name = "python-atomic-executor"`
- 0006 patch hunk: first line `- Execute the approved plan exactly as written.`

### `.codex/agents/powershell-atomic-executor.toml`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `name = "powershell-atomic-executor"`
- 0001 patch hunk: first line `- Execute the approved plan exactly as written.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `name = "powershell-atomic-executor"`
- 0006 patch hunk: first line `- Execute the approved plan exactly as written.`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/powershell-atomic-executor.toml`

- Exists: True; classification: byte-identical to .codex/agents/powershell-atomic-executor.toml
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `name = "powershell-atomic-executor"`
- 0001 patch hunk: first line `- Execute the approved plan exactly as written.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `name = "powershell-atomic-executor"`
- 0006 patch hunk: first line `- Execute the approved plan exactly as written.`

### `.codex/agents/csharp-atomic-executor.toml`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- Execute the approved plan exactly as written.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- Execute the approved plan exactly as written.`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/csharp-atomic-executor.toml`

- Exists: True; classification: byte-identical to .codex/agents/csharp-atomic-executor.toml
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `- Execute the approved plan exactly as written.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `- Execute the approved plan exactly as written.`

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml`

- Exists: True; classification: bundle copy (source path absent or file absent)
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``

### `.github/agents/atomic_executor.agent.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0001 patch hunk: first line `- When completing a task or a plan, report the toolchain status explicitly:`
- 0005 block: Current first line ``
- 0005 block: Current first line `- Task numbers are sequential within each phase.`
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- Phase numbers in IDs match the phase heading.`

### `extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md`

- Exists: True; classification: byte-identical to .github/agents/atomic_executor.agent.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0001 patch hunk: first line `- When completing a task or a plan, report the toolchain status explicitly:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- Phase numbers in IDs match the phase heading.`

### `.github/agents/powershell-atomic-executor.agent.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0001 patch hunk: first line `- Be concise but exact.`
- 0001 patch hunk: first line `Required toolchain for PowerShell tasks:`
- 0001 patch hunk: first line `- Mock signatures must match production named parameters.`
- 0005 block: Current first line ``
- 0005 block: Current first line `- Task numbers are sequential within each phase.`
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0006 patch hunk: first line `- Mock signatures must match production named parameters.`

### `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md`

- Exists: True; classification: byte-identical to .github/agents/powershell-atomic-executor.agent.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0001 patch hunk: first line `- Be concise but exact.`
- 0001 patch hunk: first line `Required toolchain for PowerShell tasks:`
- 0001 patch hunk: first line `- Mock signatures must match production named parameters.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0006 patch hunk: first line `- Mock signatures must match production named parameters.`

### `.github/agents/python-atomic-executor.agent.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0001 patch hunk: first line `1) Format (`poetry run black .` or repo task equivalent)`
- 0001 patch hunk: first line `- Keep tests deterministic and isolated from network, external services, and temp-file usage.`
- 0005 block: Current first line ``
- 0005 block: Current first line `- Task numbers are sequential within each phase.`
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0006 patch hunk: first line `- Keep tests deterministic and isolated from network, external services, and temp-file usage.`

### `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md`

- Exists: True; classification: byte-identical to .github/agents/python-atomic-executor.agent.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0001 patch hunk: first line `1) Format (`poetry run black .` or repo task equivalent)`
- 0001 patch hunk: first line `- Keep tests deterministic and isolated from network, external services, and temp-file usage.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0006 patch hunk: first line `- Keep tests deterministic and isolated from network, external services, and temp-file usage.`

### `.github/agents/csharp-atomic-executor.agent.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0001 patch hunk: first line `- Avoid broad warning suppressions; use the narrowest possible suppression only when unavoidable and documented.`
- 0005 block: Current first line ``
- 0005 block: Current first line `- Task numbers are sequential within each phase.`
- 0005 Files Changed
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0006 patch hunk: first line `- Avoid broad warning suppressions; use the narrowest possible suppression only when unavoidable and documented.`

### `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md`

- Exists: True; classification: byte-identical to .github/agents/csharp-atomic-executor.agent.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0001 patch hunk: first line `- Avoid broad warning suppressions; use the narrowest possible suppression only when unavoidable and documented.`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- Phase numbers in IDs match the phase heading.`
- 0006 patch hunk: first line `- Avoid broad warning suppressions; use the narrowest possible suppression only when unavoidable and documented.`

### `.github/agents/python-typed-engineer.agent.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `send: false`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- runtime filesystem temp files (explicitly prohibited)`
- 0001 patch hunk: first line `## Phase D — Final QA gate`
- 0001 patch hunk: first line `Your response must include:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `send: false`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- runtime filesystem temp files (explicitly prohibited)`
- 0006 patch hunk: first line `## Phase D — Final QA gate`
- 0006 patch hunk: first line `Your response must include:`

### `extensions/drm-copilot/resources/customizations/.github/agents/python-typed-engineer.agent.md`

- Exists: True; classification: byte-identical to .github/agents/python-typed-engineer.agent.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `send: false`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `- runtime filesystem temp files (explicitly prohibited)`
- 0001 patch hunk: first line `## Phase D — Final QA gate`
- 0001 patch hunk: first line `Your response must include:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `send: false`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `- runtime filesystem temp files (explicitly prohibited)`
- 0006 patch hunk: first line `## Phase D — Final QA gate`
- 0006 patch hunk: first line `Your response must include:`

### `.github/agents/powershell-typed-engineer.agent.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `send: true`
- 0001 patch hunk: first line `- **Idiomatic PowerShell design**: small cohesive scripts/modules, clear advanced functions, explicit parameter contracts, minimal surface area`
- 0001 patch hunk: first line `### C) Adapter seams for non-executable boundaries`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `Your response must include:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `send: true`
- 0006 patch hunk: first line `- **Idiomatic PowerShell design**: small cohesive scripts/modules, clear advanced functions, explicit parameter contracts, minimal surface area`
- 0006 patch hunk: first line `### C) Adapter seams for non-executable boundaries`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `**All clarifications/approvals must be resolved before entering Phase C. Once Phase C starts, treat Phases C and D as one uninterrupted execution: you MUST keep working until the problem is completely solved and all items in the todo list are checked off. Do not end your turn until every step is completed and verified. When you say you will do a step, you MUST actually do it. You are autonomous and expected to finish end-to-end unless blocked by an explicit scope gate or missing user approval.**`
- 0006 patch hunk: first line `Your response must include:`

### `extensions/drm-copilot/resources/customizations/.github/agents/powershell-typed-engineer.agent.md`

- Exists: True; classification: byte-identical to .github/agents/powershell-typed-engineer.agent.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `send: true`
- 0001 patch hunk: first line `- **Idiomatic PowerShell design**: small cohesive scripts/modules, clear advanced functions, explicit parameter contracts, minimal surface area`
- 0001 patch hunk: first line `### C) Adapter seams for non-executable boundaries`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `Your response must include:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `send: true`
- 0006 patch hunk: first line `- **Idiomatic PowerShell design**: small cohesive scripts/modules, clear advanced functions, explicit parameter contracts, minimal surface area`
- 0006 patch hunk: first line `### C) Adapter seams for non-executable boundaries`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `**All clarifications/approvals must be resolved before entering Phase C. Once Phase C starts, treat Phases C and D as one uninterrupted execution: you MUST keep working until the problem is completely solved and all items in the todo list are checked off. Do not end your turn until every step is completed and verified. When you say you will do a step, you MUST actually do it. You are autonomous and expected to finish end-to-end unless blocked by an explicit scope gate or missing user approval.**`
- 0006 patch hunk: first line `Your response must include:`

### `.github/agents/csharp-typed-engineer.agent.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `send: true`
- 0001 patch hunk: first line `- **Idiomatic C# design**: small cohesive classes/modules, clear contracts, explicit APIs, minimal surface area`
- 0001 patch hunk: first line `### C) Adapter seams for third-party/static boundaries`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `Your response must include:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `send: true`
- 0006 patch hunk: first line `- **Idiomatic C# design**: small cohesive classes/modules, clear contracts, explicit APIs, minimal surface area`
- 0006 patch hunk: first line `### C) Adapter seams for third-party/static boundaries`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `**All clarifications/approvals must be resolved before entering Phase C. Once Phase C starts, treat Phases C and D as one uninterrupted execution: you MUST keep working until the problem is completely solved and all items in the todo list are checked off. Do not end your turn until every step is completed and verified. When you say you will do a step, you MUST actually do it. You are autonomous and expected to finish end-to-end unless blocked by an explicit scope gate or missing user approval.**`
- 0006 patch hunk: first line `Your response must include:`

### `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`

- Exists: True; classification: byte-identical to .github/agents/csharp-typed-engineer.agent.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `---`
- 0001 patch hunk: first line `send: true`
- 0001 patch hunk: first line `- **Idiomatic C# design**: small cohesive classes/modules, clear contracts, explicit APIs, minimal surface area`
- 0001 patch hunk: first line `### C) Adapter seams for third-party/static boundaries`
- 0001 patch hunk: first line ``
- 0001 patch hunk: first line `Your response must include:`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `---`
- 0006 patch hunk: first line `send: true`
- 0006 patch hunk: first line `- **Idiomatic C# design**: small cohesive classes/modules, clear contracts, explicit APIs, minimal surface area`
- 0006 patch hunk: first line `### C) Adapter seams for third-party/static boundaries`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `**All clarifications/approvals must be resolved before entering Phase C. Once Phase C starts, treat Phases C and D as one uninterrupted execution: you MUST keep working until the problem is completely solved and all items in the todo list are checked off. Do not end your turn until every step is completed and verified. When you say you will do a step, you MUST actually do it. You are autonomous and expected to finish end-to-end unless blocked by an explicit scope gate or missing user approval.**`
- 0006 patch hunk: first line `Your response must include:`

### `.github/agents/typescript-engineer.agent.md`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `handoffs:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``

### `extensions/drm-copilot/resources/customizations/.github/agents/typescript-engineer.agent.md`

- Exists: True; classification: byte-identical to .github/agents/typescript-engineer.agent.md
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `handoffs:`
- 0001 patch hunk: first line ``
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line ``

### `docs/engineering/process-reductions/README.md`

- Exists: True; classification: source
- 0002 Files Changed
- 0003 Files Changed
- 0004 Files Changed
- 0005 Files Changed
- 0007 Files Changed
- 0008 Files Changed
- 0009 Files Changed
- 0010 Files Changed

### `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`

- Exists: True; classification: source
- 0001 Files Changed
- 0001 patch: diff --git header
- 0001 patch hunk: first line `+Set-StrictMode -Version Latest`
- 0006 Files Changed
- 0006 patch: diff --git header
- 0006 patch hunk: first line `Set-StrictMode -Version Latest`
- 0006 patch hunk: first line `}`
- 0006 patch hunk: first line `@{ Id = 'REVIEW-GITHUB-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md'; Required = $script:ReviewRequired; Forbidden = $script:ReviewForbidden }`
- 0006 patch hunk: first line `@{ Id = 'COPILOT-STAGED-REVIEW-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/agents/staged-review.agent.md'; Required = @('Invoke-PoshQCParallelTest', 'pytest -n auto', 'debugging only'); Forbidden = @() }`
- 0006 patch hunk: first line ``
- 0006 patch hunk: first line `})`

