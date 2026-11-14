# Scope and Acceptance Criteria ([P2-T5])

Timestamp: 2026-11-12T04-23
Command: MB=$(git merge-base origin/main HEAD); git diff --name-only $MB; git status --porcelain; git status --porcelain --untracked-files=all; each output searched for the forbidden paths and for added .py files (run with git -C <item worktree>)
EXIT_CODE: 0
Output Summary:
- git diff --name-only <merge base of origin/main and HEAD>: 126 paths; git status --porcelain: 134 entries (the working change plus the new evidence, test, and ledger files).
- Forbidden-path matches across both lists: 0 for scripts/dev_tools/atomic_executor/, scripts/dev_tools/validate_orchestration_artifacts.py, scripts/dev_tools/plan_gate_*, extensions/drm-copilot/src/lib/validate/, .claude/hooks/validate-planner-output.ps1, and tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 (AC2, AC13).
- Added .py files: 0 in the merge-base diff with --diff-filter=A, 0 untracked .py files (AC13).
- The only untracked non-evidence files are tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 and docs/engineering/process-reductions/0011-task-check-cadence.md.

Acceptance criteria checked off in spec.md (AC source for full-bug), with evidence:
- AC1: section placed before ## Final QA Loop in all six copies, bundles byte-identical: TCW-CANONICAL-* rows (NextHeading check) and test_atomic_plan_contract_matches_bundled_mirror in qa-gates/pester.2026-11-12T04-19.md and qa-gates/pytest.2026-11-12T04-23.md.
- AC2: no #1094 sweep token or "Targeted runs are allowed" in the canonical section or the referring surfaces (TCW-CANONICAL-* and file-wide forbidden lists of every TCW row); parallel-gate-wording.Tests.ps1 unchanged against HEAD and its 56 PGW- rows pass (qa-gates/pester.2026-11-12T04-19.md; other/task-check.P1-T9.2026-11-12T03-48.md).
- AC3: every referring surface carries the anchor (TCW-POLICY, TCW-REMEDIATION, TCW-DELEGATION, TCW-EXECUTOR, TCW-PLANNER, TCW-RULE, TCW-QAGATE, TCW-PROMPT, TCW-BRIEF rows) and TCW-SWEEP-SURFACES finds no per-task full-suite token (qa-gates/pester.2026-11-12T04-19.md).
- AC4: TCW-POLICY-* rows (eight copies) pass.
- AC5: TCW-REMEDIATION-* and TCW-DELEGATION-* rows (four copies each) pass; TCW-SWEEP-SURFACES finds no "Each task's toolchain loop".
- AC6: TCW-PLANNER-* rows (Claude agent, Codex base and five variants, .agents skill, four Copilot planners, with bundles) and TCW-TEMPLATE-* rows (three templates and bundles) pass.
- AC7: TCW-EXECUTOR-* rows (Claude agent, Codex base and five variants, .agents skill, four Copilot executors, with bundles, including the 7.1 "Phase-gate and final-QA toolchain" label) and TCW-PROMPT-* rows pass.
- AC8: test_brief_copies_are_byte_identical and the TCW-BRIEF-* rows pass; the pinned sentence "A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence" is retained (test_brief_test_isolation_states_parallel_gates).
- AC9: generator --check exit 0 (qa-gates/python-static.2026-11-12T04-09.md; other/task-check.P1-T7.2026-11-12T03-41.md).
- AC10: test-cadence-wording.Tests.ps1 exists with the canonical, reference, sweep (TCW-SWEEP-HELPER pins 7 tokens), and byte-identity (TCW-BUNDLE-*) groups; it passed in the phase-gate run (qa-gates/phase-gate.P1.2026-11-12T04-07.md) and the final run (135 TCW- cases, 0 failed).
- AC11: push-down Claude and Codex-and-agents resource contracts, planning-contract-wording (114 PCW- cases), parallel-gate-wording, brief contracts, single-pass preflight contracts, test_typescript_toolchain_instruction_contracts.py, and test_plan_templates_carry_premortem_skeleton all pass in the final gates (0 failures in either gate).
- AC12: docs/engineering/process-reductions/0011-task-check-cadence.md and its README index row exist, with 74 revert blocks over 49 non-identical sources; the ledger chain suites pass (58 PRC- cases, 0 failed). The single commit that carries both files is made by the orchestrator before review, with the subject token "reduction: 0011".
- AC13: Pester line coverage 95.80% (Phase 0: 95.80%); pytest line 97.11% and branch 94.37% (Phase 0: 97.11% and 94.37%); no forbidden path modified and no Python file added.
- AC14 (CI-dependent): left unchecked; pending CI on the PR head.
