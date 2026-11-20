# Brief Fact Check [P3-T10]

Timestamp: 2026-11-20T15-39
Command: grep of MAPPING_PREFIXES occurrences in .agents/skills/execution-environment/SKILL.md; comparison of each bullet's literals with its cited production file and git diff --stat of those files from the pre-apply commit to HEAD; sh SCRATCH/issue-1016-p3t10.sh (Invoke-HarnessGeneration.ps1 -Surface all, python -m scripts.dev_tools.generate_codex_agent_variants, then Invoke-HarnessGeneration.ps1 -Surface all -Check, generate_codex_agent_variants --check, build_discovery_runtime --check); sh SCRATCH/issue-1016-tc-p3t10.sh
EXIT_CODE: 0
Output Summary: Two brief bullets name MAPPING_PREFIXES paths; both are UNCHANGED, because the cited production files are excluded from the rewrite and unchanged since the pre-apply commit, and both already state the `.dev` forms added by child 2. The brief is not edited. Harness write and check print "harness-generation: no drift" (exit 0); Codex variant write exits 0 and --check exits 0; build_discovery_runtime --check exits 0. The regeneration changed no file (git status --porcelain empty after the write runs). test_brief_copies_are_byte_identical, test_brief_ci_section_names_jobs_and_required_contexts (27 passed in test_execution_environment_brief_contracts.py), documentation-workflow.CommitStage.Tests.ps1 and HarnessGeneration.RepoGate.Tests.ps1 (31 Pester tests, 0 failures) pass.

## Bullets

| Bullet (section) | Cited file | Result |
| --- | --- | --- |
| Post-fan-in allowance (#1136) and merged-feature follow-up allowance (#1141), `## Hook Execution Context`: `docs/features/epics/<epic_feature_folder>/epic-status.md` with its `.dev/epics/` form, `docs/features/active/<basename>/`, `docs/features/completed/<basename>/` with the `.dev/<area>/` judging rule | `.claude/hooks/hook-epic-fan-in.ps1` (child 2 file, excluded; text still names these roots and the `.dev` forms) | UNCHANGED |
| Change-scope decision (#962), `## CI Shape and Required Checks`: the allowlist prefixes `docs/features/...`, `docs/research/` and their `.dev` forms, and the excluded `docs/features/templates/`, `docs/features/potential/template.md`, `.dev/potential/template.md` | `config/ci-docs-only-paths.json` (excluded; `include_prefixes` and `exclude_prefixes` equal the brief's lists) | UNCHANGED |

## Files changed by regeneration

None. No `.claude` `BRIEF_COPIES` copy and no path attributed to this task by the [P2-T4] gate changed, so no path falls outside the allowed set.
