# RC2 contract and scope check (P1-T12)

Timestamp: 2026-11-24T19-03
Command: sh SCRATCH/issue-1233-rc2-contract.sh (pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check ; env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check ; git diff --name-only 502309bcd2de1b549fec6c154c3eee33dd9e402e HEAD ; git diff --name-only <merge base of origin/main and HEAD> HEAD ; git diff --name-only --diff-filter=A <merge base> HEAD -- '*.py' ; git status --porcelain)
EXIT_CODE: 0
Output Summary:
- Harness -Check: exit 0; "harness-generation: no drift".
- Codex generator --check: exit 0; no output (no variant drift).
- Merge base of origin/main and HEAD: c030729de4703f961ff27489d4890919f6e0587e.
- Cycle paths (reviewed head 502309bcd to HEAD, 27 paths): 18 under .dev/active/1233-epic-child-ci-opt-out/ (the 2026-11-24T17-50 review artifacts, remediation inputs, spec.md and user-story.md reversals committed before this cycle, the remediation plan, and this cycle's evidence); the other 9 are files named in P1-T1 to P1-T6: .claude/rules/orchestrator-state.md, .dev/engineering/process-reductions/0015-epic-child-ci-opt-out.md, extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md, extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts, extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts, scripts/harness-generation/sources/rules/orchestrator-state.md, tests/fixtures/orchestrator_state_child_ci/local-qc-gate-null-fields.json, tests/fixtures/orchestrator_state_child_ci/local-qc-gate-null-heads.json, tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1.
- git status --porcelain at the check: only this cycle's uncommitted evidence files and the plan check-offs under .dev/active/1233-epic-child-ci-opt-out/ (committed with P1-T14).
- extensions/drm-copilot/jest.config.cjs is not among the cycle paths.
- Branch paths (merge base to HEAD): 190; none under .github/workflows/, .claude/lib/docs/, a docs skill, .claude/agents/, .codex/agents/, scripts/harness-generation/sources/agents/, or an atomic-plan-contract copy.
- Added .py files on the branch: none.
