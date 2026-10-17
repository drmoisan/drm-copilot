# skill-referenced-scripts-not-bundled (Plan)

- **Issue:** #762
- **Parent (optional):** none
- **Owner:** Dan Moisan
- **Last Updated:** 2026-09-28T19-20
- **Status:** In Progress
- **Version:** 1.0

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

Paths below are relative to the worktree root `C:/Users/DanMoisan/repos/drm-copilot-wt-skill-bundled-scripts`. `<F>` is `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762`. `<B>` is `extensions/drm-copilot/resources/claude-customizations`.

**Phase 0 — Context & Inputs**
- [ ] [P0-T1] Link approved spec: `<F>/spec.md`; research: `<F>/research/2026-09-28T19-15-skill-bundle-audit-research.md`
- [ ] [P0-T2] Record branch/commit baseline: branch `fix/skill-bundled-scripts` from `origin/main` @ `5d0b93a0`
- [ ] [P0-T3] Environment: WSL `Ubuntu` (shfmt 3.12.0, shellcheck 0.11.0, bats 1.13.0, kcov), pwsh 7.6.6 + Pester 5.6.1, Poetry 2.3.2

**Phase 1 — Preparation (baselines)**
- [ ] [P1-T1] Shell baseline: `wsl -d Ubuntu -e bash -lc "bash scripts/bash/shell-qc.sh check; bash scripts/bash/shell-qc.sh test --coverage"` -> `<F>/evidence/baseline/shell-qc.2026-09-28T19-10.txt`
- [ ] [P1-T2] Python baseline: `poetry run pytest tests/scripts/dev_tools -q` -> `<F>/evidence/baseline/pytest-dev-tools.2026-09-28T19-10.txt`
- [ ] [P1-T3] PowerShell baseline: Pester for `tests/scripts/orchestration` -> `<F>/evidence/baseline/pester-ci-gate.2026-09-28T19-10.txt`

**Phase 2 — Regression Test (must fail first)**
- [ ] [P2-T1] [expect-fail] Add `scripts/dev_tools/skill_bundle_contract.py` and `tests/scripts/dev_tools/test_skill_bundle_contract.py` (unit) and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` (repository guard)
- [ ] [P2-T2] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`; confirm it reports the cleanup-worktrees and CI gate parser violations -> `<F>/evidence/regression/guard-before-fix.2026-09-28T19-30.txt`

**Phase 3 — Minimal Fix**
- [ ] [P3-T1] `git mv` the 10 cleanup-worktrees scripts from `scripts/bash/` to `.claude/skills/cleanup-merged-worktrees/scripts/`; update shellcheck `source=` directives and path comments
- [ ] [P3-T2] Update `.claude/skills/cleanup-merged-worktrees/SKILL.md` (allowed-tools and prose) to the bundled paths
- [ ] [P3-T3] Update the bats suites and fixture stubs under `tests/shell/` and `tests/fixtures/cleanup_worktrees/` that name the old paths
- [ ] [P3-T4] Add `.claude/skills` to the discovery roots and kcov include in `scripts/bash/shell_qc_lib.sh`; add a discovery bats case and fixture; update `.claude/rules/shell.md`
- [ ] [P3-T5] `git mv scripts/orchestration/Invoke-CiGateParser.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1`; move its suite to `tests/scripts/claude-lib/ci-gate/`; add `CiGate.Manifest.Tests.ps1`; add the file to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` coverage paths; update `orchestrate` and `epic-orchestrate`
- [ ] [P3-T6] Mirror all changed `.claude/**` files into `<B>/.claude/**`, remove moved-away mirror paths, and add the new paths to `<B>/pack-manifests/core.json`
- [ ] [P3-T7] Register the #763 exceptions in `KNOWN_UNBUNDLED_REFERENCES`

**Phase 4 — Verification Loop**
- [ ] [P4-T1] Re-run the guard; confirm pass -> `<F>/evidence/regression/guard-after-fix.2026-09-28T20-30.txt`
- [ ] [P4-T2] Shell: `shell-qc.sh format`, `check`, `test --coverage` -> `<F>/evidence/qa-gates/shell-qc.<ts>.txt`
- [ ] [P4-T3] PowerShell: PoshQC format -> analyze -> test on changed files -> `<F>/evidence/qa-gates/powershell.<ts>.txt`
- [ ] [P4-T4] Python: black -> ruff -> pyright -> pytest with coverage -> `<F>/evidence/qa-gates/python.<ts>.txt`
- [ ] [P4-T5] Coverage comparison against baselines (bash line %, new Python module >= 90%, CI gate parser line %) -> `<F>/evidence/qa-gates/coverage-comparison.<ts>.md`
- [ ] [P4-T6] Old-path sweep: `git grep` for `scripts/bash/cleanup`, `scripts/orchestration/Invoke-CiGateParser` outside `docs/features/**` returns nothing -> `<F>/evidence/qa-gates/old-path-sweep.<ts>.txt`

**Phase 5 — Documentation & Status**
- [ ] [P5-T1] Update spec/issue AC check-off and record decisions

**Phase 6 — PR & Handoff**
- [ ] [P6-T1] Feature review, PR context, pr-author body + receipt, `gh pr create`

**Phase 7 — Rollout / Follow-up**
- [ ] [P7-T1] Record follow-ups #763 and #764
- [ ] [P7-T2] Record links (issue, PR) for traceability
