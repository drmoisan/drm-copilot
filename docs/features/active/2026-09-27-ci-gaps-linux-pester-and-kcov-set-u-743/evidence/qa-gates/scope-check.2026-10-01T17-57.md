# Scope Verification (P7-T22, AC-20)

Timestamp: 2026-10-01T17-57

Command: git diff --name-only 41217012d31d35c2ee33a50be50684affd2f5f43
EXIT_CODE: 0
Output Summary: 81 paths. Outside `<FEATURE>/`, the listing contains exactly these 13 paths, each in the plan's `Files written by this plan` list:

```
.claude/skills/atomic-plan-contract/SKILL.md
.github/workflows/_poshqc.yml
extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
scripts/bash/kcov_trace_env.sh
scripts/bash/shell_qc_lib.sh
tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh
tests/fixtures/shell_qc/stub-bin/bats-nounset-source
tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset
tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
tests/shell/test_shell_qc_commands.bats
```

Every other path is under `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/` (evidence artifacts, `plan.2026-09-30T03-15.md`, `spec.md`, and the branch's pre-existing `issue.md` and `research/research.2026-09-30T07-20.md`).

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: only `<FEATURE>/` paths: ` M <FEATURE>/plan.2026-09-30T03-15.md`, ` M <FEATURE>/spec.md`, and untracked evidence files written after P7-T15. No `tools/actionlint/` entry (P0-T7 recorded `ACTIONLINT-ON-PATH: YES`).

Forbidden-path count: `scope-forbidden-paths.2026-10-01T17-57.md` (prints `0`).
