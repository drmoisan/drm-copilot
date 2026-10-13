# Feature Audit: concurrent-children-share-scratchpad-file-names (Issue #900)

- Timestamp: 2026-10-12T17-38

## Scope and Baseline

- Branch: bug/concurrent-children-share-scratchpad-file-names-900, head eb365f9f4 (pushed).
- Resolved base branch: origin/main (supplied by the caller; `origin/main` at dc8a0fca is merged into the branch). Diff reviewed: `origin/main...HEAD`, 45 files, 1733 insertions, 0 deletions.
- Work mode: `minor-audit` (marker `- Work Mode: minor-audit` in `issue.md`). The sole acceptance-criteria source is the `## Acceptance Criteria` section of `issue.md`. `spec.md` and `user-story.md` are absent from the feature folder, as expected for this mode.
- Feature folder: `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`.
- Plan: `plan.2026-10-11T10-38.md`; all tasks are checked.
- Evidence read: `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`.
- Independent verification at head: `cmp` on the four bundled pairs, `git diff --name-only origin/main...HEAD`, `git diff origin/main...HEAD -- .claude/agents .agents`, `git ls-files --eol`, `poetry run pytest` (new module: 15 passed; five neighbouring modules: 49 passed), `black --check`, `ruff check`, `pyright` on the new module, and `validate_evidence_locations.py --root .` (exit 0).

## Acceptance Criteria Inventory

Source: `issue.md`, `## Acceptance Criteria` (11 items; 10 checked, 1 unchecked on entry).

| ID | Criterion (abbreviated) | State on entry |
|---|---|---|
| AC-1 | `atomic-planner.md` carries the `SCRATCH` rule before `## Preflight Validation` | checked |
| AC-2 | `atomic-executor.md` `## Scratch Location` after `## Toolchain Commands`, before `## Evidence Location Invariant`, with directory creation and pre-rule handling | checked |
| AC-3 | Both `.agents` skills carry the rule with the literal `issue-<issue-num>` token | checked |
| AC-4 | New text records the literal `SCRATCH` token; no backticked `npm run`, no `issue number: <digits>`, no `docs/features/active/` | checked |
| AC-5 | Four bundled copies are byte-identical; both push-down parity modules pass (only the #510 signature accepted locally) | checked |
| AC-6 | New contract test exists with the specified assertions | checked |
| AC-7 | Recorded red run and green run under `evidence/` | checked |
| AC-8 | No historical feature folder modified | checked |
| AC-9 | No edit to the listed excluded paths | checked |
| AC-10 | Python toolchain and the six named pytest modules pass; baseline and final coverage recorded | checked |
| AC-11 | PR CI green, including `claude-architecture-doc.Tests.ps1`; CI run cited | unchecked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | `.claude/agents/atomic-planner.md` diff adds `## Scratch Location` at the position between the `## Requirements` list and `## Preflight Validation`. It states `` `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/` `` with `<issue-num>` as the plan's canonical issue number, "Every scratch file, helper script, staged copy, and coverage report a plan names lives under `SCRATCH`", and "A plan never directs a scratch file to the scratchpad root or to a fixed shared name outside `SCRATCH`". Pinned and placement-checked by `test_planner_scratch_location_placement[claude-planner]` (passes at head). |
| AC-2 | PASS | `.claude/agents/atomic-executor.md` diff adds `## Scratch Location` directly after `## Toolchain Commands` and before `## Preflight Validation`; the file's `## Evidence Location Invariant` is later. The section carries the same resolution rule, "Create `SCRATCH` before the first scratch write", and "When a plan written before this rule defines `SCRATCH` as the bare session scratchpad, treat that definition as `<session scratchpad>/issue-<issue-num>/`". Verified by `test_executor_scratch_location_placement[claude-executor]` and `test_executor_scratch_location_handles_pre_rule_plans[claude-executor]`. |
| AC-3 | PASS | `.agents/skills/atomic-planner/SKILL.md` (10-line insertion before `## Mandatory Preflight Loop`) and `.agents/skills/atomic-executor/SKILL.md` (11-line insertion before `## Non-Negotiable Constraints`) each contain the rule with the literal `issue-<issue-num>` token. Verified by `test_scratch_location_section_states_the_rule[agents-planner|agents-executor]` and the placement tests. |
| AC-4 | PASS | All four new sections contain "Plans and evidence artifacts record the literal token `SCRATCH`, never a host path." Reading the four diffs shows no backticked `npm run` token, no `issue number: <digits>` shape, and no `docs/features/active/` path. `test_scratch_location_section_avoids_forbidden_shapes` (four cases) passes at head. |
| AC-5 | PASS | `cmp` reported IDENTICAL for all four bundled/primary pairs during this review. `git ls-files --eol` shows LF index and working tree for the primary sources. Reviewer re-run of `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` together with three other contract modules: 49 passed, 0 failed, including `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (no #510 signature appeared in this environment). Executor evidence: `push-down-claude-parity`, `push-down-codex-agents-parity`, `issue-510-node-after`, `mirror-parity-after`, `line-endings-after`. |
| AC-6 | PASS | `tests/scripts/dev_tools/test_scratch_location_contracts.py` exists (275 lines). It asserts the pinned rule phrase and the `issue-<issue-num>` segment in each of the four primary sources (`test_scratch_location_section_states_the_rule`), and scans `.claude/agents/*.md`, `.claude/skills/**/SKILL.md`, and `.agents/skills/**/SKILL.md` for `SCRATCH/run-ps.sh`, `SCRATCH/changed-line-coverage.ps1`, `SCRATCH/cov-final.txt`, `SCRATCH/cov-final.xml`, `SCRATCH/region-probe.ps1`, and `<scratchpad>/` (`test_normative_surfaces_name_no_bare_fixed_scratch_path`). 15 passed at head. See code-review finding on the denylist breadth (Low, advisory). |
| AC-7 | PASS | `evidence/regression-testing/scratch-contract-red.2026-10-11T10-38.md` records `14 failed, 1 passed` with the 14 positive, forbidden-shape, placement, and pre-rule assertions failing, against the pre-change sources confirmed by `red-run-precondition.2026-10-11T10-38.md`. `scratch-contract-green.2026-10-11T10-38.md` records `15 passed`. Both are under the feature folder's `evidence/` tree. |
| AC-8 | PASS | `git diff --name-only origin/main...HEAD` lists 45 paths: 9 outside the feature folder (four primary sources, four bundled copies, one test module) and 36 inside `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`. No path under `docs/features/` falls outside this feature folder. |
| AC-9 | PASS | The same 45-path list contains no file under `.claude/rules/`, `.github/instructions/`, `.codex/agents/`, no `.claude/skills/atomic-plan-contract/`, `evidence-and-timestamp-conventions/`, `orchestrate/`, `remediation-handoff-atomic-planner/`, or `epic-orchestrate/` path, no `.claude/agents/orchestrator.md`, `.agents/skills/orchestrate/`, or `.agents/skills/orchestrator-workflow/` path, no child-prompt template, and no plan-validator source. `evidence/qa-gates/scope-check.2026-10-11T10-38.md` records the executor's matching check. |
| AC-10 | PASS | Reviewer re-run at head: `black --check` (1 file unchanged), `ruff check` (all checks passed), `pyright` (0 errors, 0 warnings) on the new module; new module 15 passed; the other five named modules passed within the 49-passed run. Executor evidence: `final-black-check`, `final-ruff`, `final-pyright`, `final-pytest-coverage` (63 passed, 1 deselected, #510 node run separately), `final-issue-510-node`, `final-qc-loop-pass` (restart count 0). Baseline and final coverage artifacts: `evidence/baseline/pytest-coverage-baseline.2026-10-11T10-38.md` and `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`, compared in `coverage-comparison.2026-10-11T10-38.md` (totals identical). |
| AC-11 | PENDING-CI (non-blocking) | No PR CI run is cited in the feature folder yet. The executor's PoshQC call for `tests/scripts/claude-runtime` returned `ok: true` but carries no per-test output, so it does not substitute for the Pester result. The diff changes no PowerShell file and only inserts Markdown prose into `atomic-executor.md`, so a regression in `claude-architecture-doc.Tests.ps1` is unlikely, but that is an inference and not verified. Left unchecked. The criterion is satisfied when the CI run is cited. |

## Summary

- Verdict: PASS for AC-1 through AC-10; AC-11 is pending CI and non-blocking at this stage.
- Counts: PASS 10, PARTIAL 0, FAIL 0, UNVERIFIED 0, PENDING-CI 1.
- Blocking findings: 0 (FAIL: 0, blocking-PARTIAL: 0).
- Remediation inputs: not required.
- Go/no-go: go for opening or continuing the PR. Do not close issue #900 or mark AC-11 until the PR CI run is green and cited.
- Out-of-scope follow-ups noted, not findings against this change: a plan-validator check that rejects bare `SCRATCH` definitions (requires a `.claude/rules/plan-acceptance-gates.md` edit and operator approval), and the `.codex/agents` TOML update.

## Acceptance Criteria Check-off

- No source file was edited by this review. AC-1 through AC-10 were already checked in `issue.md`, and this review's independent evidence agrees with each. AC-11 is left unchecked pending CI.
- Newly checked-off items in this review: none.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: PR CI is green, including the Pester suite `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, which reads `.claude/agents/atomic-executor.md`; the CI run is cited as evidence (pending CI, non-blocking).
