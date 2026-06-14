# Option B Scope Adjustment — Final Toolchain (Issue #181)

Timestamp: 2026-06-13T11-51

Scope: Physically remove the 9 repo-specific agent memories from the bundle
(move to gitignored root `.claude/agent-memory/`), trim the bundle orchestrator
`MEMORY.md` index to the 7 general memories, and tighten the bundled-memory
parity assertion to require `scope: general` for every non-index bundled memory.
The scope-filter logic, the two push-down scripts, the validator, and all rule
files are unchanged by this adjustment.

## Toolchain (single clean pass, in order)

- Command: `poetry run black .`
  - EXIT_CODE: 0
  - Output Summary: All done. 251 files left unchanged (no reformatting).
- Command: `poetry run ruff check .`
  - EXIT_CODE: 0
  - Output Summary: All checks passed (0 lint errors).
- Command: `poetry run pyright`
  - EXIT_CODE: 0
  - Output Summary: 0 errors, 0 warnings, 0 informations.
- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - EXIT_CODE: 0
  - Output Summary: 1116 passed, 19 skipped. Coverage TOTAL (combined
    line+branch report): 82% (statements 8171, missed 1241; branches 2900,
    partial 424). No regression versus the P0-T5 baseline (baseline was 1096
    passed at 82% combined TOTAL; this run adds 20 passing tests with the same
    82% combined TOTAL). The 19 skips are codex/agents gitignored-directory
    tests unrelated to this feature. The repository CI gate enforces the
    85% line / 75% branch policy via pyproject configuration.

## Byte-identical script confirmation

- Command: `git diff --no-index scripts/dev_tools/push_down_claude_customizations.py extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py`
  - EXIT_CODE: 0 (no differences) — the two main push-down scripts remain
    byte-for-byte identical and were not modified by this adjustment.

## TypeScript

- Command: `git diff --name-only HEAD | grep -E '\\.(ts|tsx)$'`
  - Output Summary: none. No `.ts`/`.tsx` files changed; extension
    Jest/Prettier/ESLint/tsc toolchain remains Not Applicable.

## Tightened test

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_agent_memory_scopes_are_well_formed`
  - Now requires: every non-index bundled agent-memory `*.md` file has exactly
    `scope: general`; every `MEMORY.md` index has exactly `scope: repo`.
  - Result: PASSED.
- The agent-memory exemption from the byte-identical "every repo file in bundle"
  parity assertion (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`)
  is preserved unchanged: PASSED.

## Push-down filter unit tests (unchanged, verified green)

- `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py`: 12 passed
  (general included; repo/absent/malformed excluded).

## Final bundle agent-memory state (path + scope)

- orchestrator/feedback_branch_base_check_unmerged_pr_deps.md — scope: general
- orchestrator/feedback_every_change_through_lifecycle.md — scope: general
- orchestrator/feedback_policy_compliance_not_optional.md — scope: general
- orchestrator/feedback_potential_to_issue_creates_github_issue.md — scope: general
- orchestrator/feedback_remediation_plan_em_dash_required.md — scope: general
- orchestrator/feedback_small_bug_uses_minor_audit.md — scope: general
- orchestrator/feedback_test_files_count_against_500_cap.md — scope: general
- orchestrator/MEMORY.md — scope: repo (index; indexes the 7 general memories only)

The bundle `prd-feature/` and `task-researcher/` agent-memory subdirectories were
removed entirely (no empty directories left in the bundle).

## Root relocation confirmation

The 9 repo-specific memories now exist at the gitignored root
`.claude/agent-memory/` (local-only, byte-identical to their former bundle
content): 5 under orchestrator/, 2 under prd-feature/ (including its MEMORY.md),
2 under task-researcher/ (including its MEMORY.md). `git check-ignore` confirms
the root subtree is gitignored as intended.
