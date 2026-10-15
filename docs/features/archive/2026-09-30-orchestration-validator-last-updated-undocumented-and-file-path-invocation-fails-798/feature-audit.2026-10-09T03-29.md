# Feature Audit: Issue #798 - orchestration validator required keys and dispatcher file-path invocation

- **Review date:** 2026-10-09
- **Reviewer:** feature-review agent
- **Work Mode:** full-bug (from `issue.md` line 12, `- Work Mode: full-bug`)
- **AC source:** `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` `## Acceptance Criteria` (spec states `user-story.md: NONE`)

## Scope and Baseline

- **Resolved base branch:** `origin/main`
- **Merge base:** `e7d3779b398604af919678c16c877c8539a86cc0` (equals the local `origin/main` ref; branch is 0 commits behind)
- **Head:** `ee7d144d96dd7a18acfdc62a2298c6537c7dda74` (committed and pushed; remote branch ref matches; worktree clean)
- **Range audited:** `e7d3779b..ee7d144d`, 9 commits, 63 files, +2889/-10
- **PR context:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-10-09 07:25 UTC at head `ee7d144d` (current; not regenerated)
- **Non-documentation files in scope:** `scripts/dev_tools/validate_orchestration_artifacts.py` (M), `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (A), `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` (A), `.claude/rules/orchestrator-state.md` (M), `.claude/skills/orchestrate/SKILL.md` (M), `.claude/agents/orchestrator.md` (M), and the three bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/` (M)
- **Plan state:** `plan.2026-10-08T17-24.md` Phases 0-7 complete (69 tasks checked). Phase 8 (commit/rebase/push/PR handoff, 4 tasks) is orchestrator-owned and unchecked, as expected at review time.
- **Baseline behavior:** on the merge base, `python scripts/dev_tools/validate_orchestration_artifacts.py --help` fails with `ModuleNotFoundError` (`evidence/regression-testing/file-path-invocation-repro.2026-10-09T02-59.md`), and the rule, skill, and persona do not list the 22 `REQUIRED_STATE_KEYS` (spec Problem Statement; `evidence/regression-testing/expect-fail-required-keys-docs.2026-10-09T03-03.md`).

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Source line |
|---|---|---|
| AC-1 | `test_file_path_invocation_help_exits_zero` passes; fails with `ModuleNotFoundError` pre-fix | spec.md 248 |
| AC-2 | `test_file_path_invocation_validates_committed_fixture` passes (exit code equals `main()`) | 249 |
| AC-3 | `test_module_invocation_leaves_sys_path_unchanged` passes | 250 |
| AC-4 | `test_file_path_bootstrap_appends_repo_root_once` passes | 251 |
| AC-5 | New test modules use no subprocess or temp files; restore `sys.path` and `scripts.*` modules | 252 |
| AC-6 | Single module-level bootstrap after stdlib imports, before first `scripts.dev_tools` import, conditional on `not __package__`; file <= 500 lines | 253 |
| AC-7 | Ruff clean, no `noqa`; `pyproject.toml` change only under D5 fallback | 254 |
| AC-8 | Rule `## Required Top-Level Keys` section placed correctly, lists all keys, names authority and ports, states unconditional/presence-only and the message | 255-258 |
| AC-9 | Section defines `last_updated` semantics; `test_rule_documents_last_updated_semantics` passes | 259 |
| AC-10 | `test_required_key_is_documented_in_rule` and `test_rule_documented_keys_equal_required_state_keys` pass | 260 |
| AC-11 | `test_parity_comparison_detects_undocumented_and_extra_keys` passes | 261 |
| AC-12 | Skill `## Checkpoint Handling` names `last_updated`, refresh rule, rule section; test passes | 262 |
| AC-13 | Skill `## Issue Number Consistency` uses `issue-num`; test passes; S9 unchanged | 263 |
| AC-14 | Skill has no `python -m scripts.`/`python scripts/` text; bundle test passes | 264 |
| AC-15 | Agent `## Checkpoint Persistence` names all keys individually; test passes | 265 |
| AC-16 | Rule `## Bare-Module CLI Contract` documents both dispatcher forms; test passes | 266 |
| AC-17 | Rule issue_adoption sections unchanged | 267 |
| AC-18 | Mirrors byte-identical; two push-down contract tests pass | 268 |
| AC-19 | No validator behavior change (protected files unchanged; named regression modules pass unmodified) | 269-271 |
| AC-20 | Full Python toolchain passes in one loop; dispatcher coverage >= 85% line / >= 75% branch; changed lines covered | 272 |
| AC-21 | Each new test module <= 500 lines | 273 |

Total: 21 checkbox items.

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | Reviewer pytest run: passes. Fail-before: `evidence/regression-testing/expect-fail-invocation.2026-10-09T03-03.md` (3 failed with `ModuleNotFoundError: No module named 'scripts.dev_tools.epic_planner_readiness'`). Test asserts `SystemExit` code 0 and `orchestrator-state` in stdout. |
| AC-2 | PASS | Reviewer pytest run: passes. Test compares exit code, stdout, and stderr against `dispatcher.main(arguments)`. Reviewer CLI run of the file-path form against the fixture: exit 0. |
| AC-3 | PASS | Reviewer pytest run: passes. Test asserts exit 0 and `sys.path == snapshot`. |
| AC-4 | PASS | Reviewer pytest run: passes. Test asserts 0 root entries before, 1 after, and root is last. |
| AC-5 | PASS | Reviewer read of both modules: no `subprocess`, `tempfile`, `tmp_path`, or write calls; `isolated_import_state` restores `sys.path` and module objects in `finally`; `monkeypatch` restores `sys.argv`. Executor grep: `evidence/qa-gates/size-and-text-checks.2026-10-09T03-13.md`. |
| AC-6 | PASS | Reviewer diff read: one statement at line 17, after `from pathlib import Path` (line 14) and before `from scripts.dev_tools.epic_planner_readiness import ...` (line 19); conditional on `not __package__`. `wc -l` = 498. |
| AC-7 | PASS | Reviewer `poetry run ruff check` on the dispatcher: All checks passed. No `noqa` in the diff. `pyproject.toml` unchanged (`git diff --name-only ... -- pyproject.toml` returns nothing); D5 fallback not used (`evidence/other/p3-t3.2026-10-09T03-04.md`). |
| AC-8 | PASS | Rule diff: section inserted between `## Foreign Schema Warning (do not copy verbatim)` and `## Scope and Backward Compatibility`; 22 backticked bullets; names `REQUIRED_STATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py`, the TypeScript and PowerShell ports; states "unconditional", "presence-only", and `Checkpoint missing required key: <key>`. Tests `test_required_keys_section_sits_between_foreign_schema_and_scope_sections` and `test_rule_section_names_authority_and_check_semantics` pass. |
| AC-9 | PASS | Rule text: "ISO-8601 UTC date-time string ... rewritten on every checkpoint write ... including halts ... do not parse the value". `test_rule_documents_last_updated_semantics` passes. |
| AC-10 | PASS | Reviewer pytest run: 22 parametrized cases and the set-equality test pass. |
| AC-11 | PASS | Reviewer pytest run: passes; covers synthetic missing key, synthetic extra key, and the equal-set control. |
| AC-12 | PASS | Skill diff: item 5 under `## Checkpoint Handling` names `last_updated`, "rewritten on every checkpoint write", and `## Required Top-Level Keys`. Test passes. |
| AC-13 | PASS | Skill diff: line 271 now reads "Record as `issue-num` in the checkpoint". Test passes. Skill hunks are at old lines 36 and 270, before `## Step S9` (`evidence/qa-gates/scope-check.2026-10-09T03-12.md`). |
| AC-14 | PASS | Executor grep for `python3? -m scripts\.|python3? scripts/` on the skill: no match. Reviewer pytest run of `test_skill_bundle_contract_repo.py`: passes. |
| AC-15 | PASS | Persona diff lists all 22 keys, step statuses individually. 22 parametrized cases pass. |
| AC-16 | PASS | Rule diff documents `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state` and `python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state` with the same flags and exit codes; "The bare-module validator is supported in the module form only." Test passes. See code review CR-2 for an environment-specific qualification of the "identical" statement (non-blocking). |
| AC-17 | PASS | Rule hunks end at old lines 34 and 173, before the issue_adoption sections at old line 227 (`evidence/qa-gates/scope-check.2026-10-09T03-12.md`); reviewer diff read confirms no other hunks. |
| AC-18 | PASS | Executor `git diff --no-index --exit-code` for all three pairs: exit 0 (`evidence/qa-gates/mirror-identity.2026-10-09T03-12.md`). Reviewer pytest run of `test_push_down_claude_resource_contracts.py` (includes both named tests): passes. |
| AC-19 | PASS | Reviewer `git diff --name-only e7d3779b HEAD -- scripts/dev_tools/validate_orchestrator_state.py extensions/drm-copilot/src .claude/lib .claude/hooks`: no paths. The named regression modules are not in the branch diff and pass (reviewer subset; executor full set 196 passed). |
| AC-20 | PASS | Reviewer reruns: Black, Ruff, Pyright clean. Executor single-loop evidence (iteration 1): full pytest 6659 passed; dispatcher 97.99% lines / 92.86% branches; changed lines 16-19 have no uncovered lines (`evidence/qa-gates/pytest-full-coverage.2026-10-09T03-10.md`, `evidence/qa-gates/python-coverage-values.2026-10-09T03-12.md`). The criterion's measured values are recorded verbatim. Separately, the canonical artifact `artifacts/python/lcov.info` is absent at review time; that is a policy-audit finding (PA-1), not a shortfall in the measured values this criterion specifies. |
| AC-21 | PASS | Reviewer `wc -l`: 203 and 253. |

## Summary

- 21 of 21 acceptance criteria evaluate PASS. No criterion is PARTIAL, FAIL, or UNVERIFIED.
- Both defects in issue #798 are fixed: the file-path dispatcher form runs, and the required checkpoint keys, including `last_updated`, are documented in the rule, skill, and agent persona, with parity enforced by tests.
- The branch is not yet merge-ready because of one blocking policy item outside the acceptance criteria: the Python coverage artifact `artifacts/python/lcov.info` is absent at review time (policy audit PA-1, remediability `autonomous`). Remediation is a coverage re-run and an evidence record; no code change is expected.
- Non-blocking: the PD8 follow-up for the foreign-`scripts` resolution hazard has not been filed (code review CR-2).

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md`
- Total AC items: 21
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All 21 AC items were already checked (`- [x]`) in `spec.md` by the executor in Phase 7 (`evidence/other/ac-checkoff.2026-10-09T03-13.md`). The reviewer evaluated each as PASS above, so every existing check-off is confirmed. No items were newly checked off and none were unchecked; `spec.md` was not modified by this review.
