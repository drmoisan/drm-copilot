# Exclusion Integrity [P4-T2]

Timestamp: 2026-11-20T16-09
Command: git fetch origin epic/shared-agent-harness-layer-integration; node SCRATCH/issue-1016-p4t2b.cjs (git diff -M --name-status BASE HEAD, BASE = merge base of INTEGRATION and HEAD; each line tested against the built-in exclusions and the 343 rewrite_exclusions globs of DECISIONS folder-rename-decisions.2026-11-20T12-24.json with the compileGlob translation of extensions/drm-copilot/src/lib/file-system.ts, matched on the pre-move and post-move path; git status --porcelain); git diff --name-status BASE HEAD over the FROZEN_SURFACES and their generator families; git diff --name-status <apply commit> HEAD -- .dev/engineering/process-reductions
EXIT_CODE: 0
Output Summary: Zero excluded files with an unexplained M or inexact R line. Excluded-file diff lines: 29937 R100, 149 A, 20 M, 7 R below 100, 1 D. Every M or inexact R line is a HAND_EDIT_TARGETS member with only its task's named edits (24), a feature record of this item carrying check-offs (3, the spec, user story and stage A plan), or a pre-apply stage A edit unchanged since the pre-apply commit (2). The one D line is the old path of this plan, whose check-offs put it below the rename threshold; its post-move path is an A line. tests/fixtures shows no M line and exactly one A line (the [P3-T8] fixture). FROZEN_SURFACES and their generator families (including bundle copies and the Codex agent) show no change. The ledger folder shows R100 for every file except the four regenerated patches (R098 or R099 against BASE; M against the apply commit).

## Excluded files that are not R100 or A

| Status | Path | Class |
| --- | --- | --- |
| M | `.agents/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/atomic-plan-contract/SKILL.md` and their two bundle copies | HAND_EDIT ([P3-T9], `0008`) |
| R099, R099, R098, R099 | `patches/0001`, `0006`, `0008`, `0009` (moved to `.dev/engineering/process-reductions/patches/`) | HAND_EDIT ([P3-T9]) |
| M | `config/orchestration-routing.json` and its two bundle copies | HAND_EDIT ([P3-T2]) |
| M | `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md` | HAND_EDIT ([P3-T4]) |
| M | `scripts/dev-tools/ProcessReductionChain.psm1`, `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` | HAND_EDIT ([P1-T5]) |
| M | `scripts/dev_tools/build_discovery_runtime.py`, `scripts/dev_tools/discovery/init_models.py` | HAND_EDIT ([P3-T7]) |
| M | `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1`, `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | HAND_EDIT ([P3-T9]) |
| M | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py` | HAND_EDIT ([P3-T6]) |
| M | `tests/scripts/dev_tools/test_plan_progress_report.py` | HAND_EDIT ([P3-T2], the run B FIX-FLIP row) |
| R096, R085, R093 | this feature's stage A plan, `spec.md`, `user-story.md` (moved to `NEW_FEATURE`) | feature record with check-offs (mapping records, member 3) |
| D | `OLD_FEATURE/plan.2026-10-30T23-35.md` | this plan; its post-move path `NEW_FEATURE/plan.2026-10-30T23-35.md` is an A line (similarity below the rename threshold after check-offs) |
| M | `extensions/drm-copilot/src/repo-automation-service.ts`, `packages/mcp-server/README.md` | pre-apply stage A edit (member 12; content at HEAD equals the pre-apply commit; last changed by the stage A Phase 2 commit) |

The other HAND_EDIT_TARGETS files (`config/blast-radius.json`, its test, the epic manifest, `claude-architecture-doc.Tests.ps1`, `test_discovery_documentation_contracts.py`, the [P3-T7] test files) are not REWRITE_EXCLUSIONS members and do not appear in this table. No `.claude` `BRIEF_COPIES` copy changed ([P3-T10] regenerated nothing).

## Other conditions

| Condition | Observation | Result |
| --- | --- | --- |
| `tests/fixtures` | only `A tests/fixtures/orchestrator_state_issue_adoption/waives-feature-folder-path-outside-dev-active.json` | PASS |
| `FROZEN_SURFACES` and generator families | no diff line for `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, the two harness sources, `.codex/agents/epic-orchestrator.toml` or their bundle copies | PASS |
| Ledger folder | 19 lines against BASE; 15 R100, the four regenerated patches R098 or R099; against the apply commit only the four patches are M | PASS |
| Porcelain at run time | the plan check-off of [P4-T1] and the untracked layout-check evidence only | PASS |
