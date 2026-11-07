# QA Gate: Branch Scope — Issue #1093

Timestamp: 2026-11-07T00-59
Command: sh SCRATCH/issue-1093-scope.sh (`git status --porcelain`; `git diff --find-renames --name-status origin/main...HEAD` after `git fetch -q origin main`; a forbidden-path count over that listing; `git ls-files` and an on-disk check for `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`; `git grep -n -F -e scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 -- . ":(exclude)docs/features"`)
EXIT_CODE: 0
Output Summary: `git status --porcelain` empty; 52 changed paths; 0 paths under `.claude/skills/epic-run/`, `.claude/skills/epic-plan/`, `.claude/skills/epic-orchestrate/`, `.agents/`, `.github/skills/`, `.claude/agents/`, `.claude/settings.json`, or with a `.py` suffix; `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` absent from the index and the disk; the `git grep` outside `docs/features/` returned 0 matches.

## Checks

| Check | Result |
|---|---|
| `git status --porcelain` | empty |
| Paths under the forbidden set or ending in `.py` | 0 |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` tracked | no (0 entries from `git ls-files`) |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` on disk | absent |
| `git grep` for the fixed string outside `docs/features/` | 0 matches |

## AC-09 rename proof

The range diff reports the canonical entry and Logic files as added (`A`) and the merged Logic file as deleted (`D`): the forwarder recreated in P4-T1 keeps the old entry path, and the Logic hub was trimmed by the split, so range-level rename detection does not pair them. The rename proof for AC-09 is `evidence/other/relocation-renames.2026-11-06T23-58.md`, recorded immediately after the P1-T1 relocation commit: four `R` entries, both production files `R100`.

## Range diff (`git diff --find-renames --name-status origin/main...HEAD`)

```text
A	.claude/skills/epic-progress-report/SKILL.md
A	.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1
A	.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1
A	.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1
A	.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1
A	.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1
M	config/poshqc-coverage.json
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/file-size.2026-11-06T23-57.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/full-golden-legacy-state.2026-11-06T23-50.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/it-name-inventory.2026-11-06T23-51.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/pester-coverage.2026-11-06T23-56.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/phase0-instructions-read.2026-11-06T23-49.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/powershell-analyze.2026-11-06T23-52.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/powershell-format.2026-11-06T23-52.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/baseline/python-contract-tests.2026-11-06T23-56.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/other/bundle-hashes.2026-11-07T00-19.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/other/preflight-fixes.2026-11-06T23-47.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/other/relocation-renames.2026-11-06T23-58.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/qa-gates/coverage-delta.2026-11-07T00-25.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/qa-gates/file-size.2026-11-07T00-58.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/qa-gates/pester-coverage.2026-11-07T00-25.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/qa-gates/powershell-analyze.2026-11-07T00-23.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/qa-gates/powershell-format.2026-11-07T00-22.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/qa-gates/python-contract-tests.2026-11-07T00-57.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/regression-testing/pester-parallel-shards.2026-11-07T00-57.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/regression-testing/pester-shuffled-order.2026-11-07T00-26.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/evidence/regression-testing/pester-single-process.2026-11-07T00-50.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/issue.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/plan.2026-11-06T17-53.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/research/research.2026-11-06.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/spec.md
A	docs/features/active/2026-11-06-epic-progress-report-skill-1093/user-story.md
A	docs/features/potential/promoted/2026-11-06-epic-progress-report-skill.md
M	extensions/drm-copilot/CHANGELOG.md
A	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/SKILL.md
A	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1
A	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1
A	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1
A	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1
A	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1
M	extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
D	scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
M	scripts/dev-tools/Get-EpicProgressReport.ps1
A	tests/fixtures/dev-tools/Get-EpicProgressReport.ForwarderTarget.Fixture.ps1
A	tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1
A	tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1
A	tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1
A	tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1
A	tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1
A	tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1
D	tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
M	tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
```
