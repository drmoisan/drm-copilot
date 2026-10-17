# Diff Scope Verification (P8-T19, AC-19)

Timestamp: 2026-09-30T15-12
Task: [P8-T19]
Location: worktree root
Branch actually used: `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509` (orchestrator branch substitution recorded in P0-T3)
Diff ref: `origin/epic/orchestrator-state-contract-correctness-integration` (refreshed with `git fetch origin epic/orchestrator-state-contract-correctness-integration`, exit 0, immediately before the listing)

## 1. Three-dot name listing

Command: git diff --name-only origin/epic/orchestrator-state-contract-correctness-integration...HEAD
EXIT_CODE: 0
Output Summary: 225 paths, classified as follows.

| Group | Count | Scope basis |
| --- | --- | --- |
| `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/**` (plan, spec, evidence including `baseline/poshqc-local/`) | 79 | Scope "Feature documents" |
| `tests/fixtures/orchestrator_state_issue_adoption/*.json` | 29 | Scope "Fixtures" (29 new files) |
| `docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/**` | 69 | P0-T3 pre-existing committed listing |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | 1 | P0-T3 pre-existing committed listing |
| Enumerated source, test, registration, and documentation paths (below) | 47 | Scope enumeration |

Enumerated scope paths present (47):
- Python production (4): `scripts/dev_tools/_orchestrator_state_routing.py`, `scripts/dev_tools/_orchestrator_state_route_gates.py`, `scripts/dev_tools/_orchestrator_state_promotion_tools.py`, `scripts/dev_tools/_orchestrator_state_issue_adoption.py`
- Python tests (4): `tests/scripts/dev_tools/test_orchestrator_state_routing_split.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py`, `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py`, `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`
- PowerShell production and bundle (4): `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`, `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`, and the same two names under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/`
- PowerShell registration (4): `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1`
- Pester tests (2): `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1`
- TypeScript (5): `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`, `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`
- Documentation sources (12): `.claude/rules/orchestrator-state.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.codex/agents/orchestrator.toml`, `.codex/agents/orchestrator-c1.toml`, `.codex/agents/orchestrator-c2.toml`, `.codex/agents/orchestrator-c3.toml`, `.codex/agents/orchestrator-c3-elevated.toml`, `.codex/agents/orchestrator-c4.toml`
- Documentation mirrors (12): the three `.claude/` documents under `extensions/drm-copilot/resources/claude-customizations/`; the three `.agents/skills/` documents and six `.codex/agents/` files under `extensions/drm-copilot/resources/codex-and-agents-customizations/`

Tally: 4 + 4 + 4 + 4 + 2 + 5 + 12 + 12 = 47. Total: 79 + 29 + 69 + 1 + 47 = 225, equal to the listing length.

Pre-existing paths from the P0-T3 listing (named): the 69 `docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/` paths listed verbatim in `evidence/baseline/git-baseline.2026-09-30T13-46.md` section 6, and `tests/scripts/dev_tools/test_blast_radius_config_parity.py`.

Excluded-path check (Grep over the captured listing for `^\.(claude|codex)/hooks/`, the three excluded `scripts/dev_tools` modules, `orchestrator-state-core.ts`, `orchestrator-state-promotion-tools.ts`, `OrchestratorStateCompletion.psm1`, `config/orchestration-routing.json`, the two deferred `feature-promotion-lifecycle` Copilot surfaces, and `orchestrator-state-routing.test.ts`): 0 matches. No path under `.claude/hooks/` or `.codex/hooks/` appears, so no enforcement hook gains a Python leg.

## 2. Porcelain status

Command: git status --porcelain
EXIT_CODE: 0
Output Summary (verbatim):

```
 M docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/file-size-gate.2026-09-30T15-10.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/no-temp-files.2026-09-30T15-11.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/poshqc-local/
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/ps-analyze.2026-09-30T15-02.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/ps-coverage-delta.2026-09-30T15-12.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/ps-test-coverage.2026-09-30T15-08.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/ps-test-mcp.2026-09-30T15-06.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/py-coverage-delta.2026-09-30T15-11.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/ts-coverage-delta.2026-09-30T15-10.md
```

Every entry is inside the #509 feature folder (Scope "Feature documents").

Note: after this listing was taken, the P8-T18 artifact was renamed from `no-temp-files.2026-09-30T15-14.md` to `no-temp-files.2026-09-30T15-11.md` so that its filename timestamp matches the actual UTC run time. The listing above shows the corrected name; the entry is otherwise verbatim.

Result: PASS. The union of the two listings contains only Scope-of-the-diff paths and P0-T3 pre-existing paths, and none of the excluded paths.
