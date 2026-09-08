# Scope verification — every changed path against the [P8-T15] allow list

Timestamp: 2026-09-07T19-38

Command: `git diff c3ffb080 --name-only`; `git status --porcelain --untracked-files=all`

EXIT_CODE: 0

## Output Summary

The two listings together name 162 distinct paths. Every one of them is a member of the [P8-T15]
allow list with exactly one exception, recorded below as a deviation.

Classification was performed mechanically: each path was tested against the exact-match entries of
the allow list, the mirror form of each `.claude/` entry under
`extensions/drm-copilot/resources/claude-customizations/`, and the directory prefixes the task
enumerates. The check printed one path outside the list.

## Deviation — one path not named by the [P8-T15] allow list

```text
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
```

Why it changed: constraint C3 requires every new PowerShell production file to be appended to
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, whose `CodeCoverage.Path` is an
explicit per-file allow-list, and the [P8-T15] allow list does name that repo-root file. It does not
name its bundled mirror. The two are locked to byte parity by
`tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources`,
which reads `POSHQC_PARITY_PATHS` and maps `scripts/powershell/PoshQC/` to
`extensions/drm-copilot/resources/powershell/PoshQC/`. The repo-root edit therefore put the pair out
of parity and that test failed on the first final-QA pytest run ([P8-T5], loop iteration 1).

What was done: the mirror was refreshed from the repo-root file with the constraint C9 `Copy-Item`
form, which consumes no batch-budget slot:

```text
pwsh -NoProfile -Command "Copy-Item -LiteralPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -Destination extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 -Force"
```

The mirror's content is a byte copy of a file the plan authorises, so the change adds no behaviour
beyond what the allow-listed file already carries. Blocking was not available: the failure surfaced
after [P0-T1], and the plan's own rules require a non-exempt failing test to be fixed in the task
that surfaces it. The deviation is recorded here, in
`evidence/qa-gates/final-python-pytest-coverage.2026-09-07T18-40.md`, and in
`evidence/qa-gates/final-qa-loop-outcome.2026-09-07T19-32.md`.

## Statement

No path other than the one recorded above is listed outside the [P8-T15] allow list. In particular no
listing contains `enforce-parallel-cohort-barrier`, a `cohort_barrier` or `cohort-barrier` path,
`scripts/dev_tools/_blast_radius_glob.py`, `.claude/lib/blast-radius/BlastRadiusGlob.psm1`,
`scripts/dev_tools/_blast_radius_validation.py`, or `.claude/lib/blast-radius/BlastRadiusConfig.psm1`
(the constraint C8 out-of-scope set, re-checked in [P7-T7]).

## `git diff c3ffb080 --name-only`, verbatim

```text
.claude/agents/parallel-orchestrator.md
.claude/agents/parallel-planner.md
.claude/lib/blast-radius/BlastRadius.psm1
.claude/lib/blast-radius/BlastRadiusConflict.psm1
.claude/lib/project-file-merge/ProjectFileMerge.psm1
.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1
.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1
.claude/rules/parallel-orchestration.md
.claude/skills/parallel-add/SKILL.md
.claude/skills/parallel-orchestrate/SKILL.md
.claude/skills/parallel-plan/SKILL.md
.gitattributes
config/blast-radius.json
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/edit-target-line-counts.2026-09-07T15-10.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/npm-ci-extension.2026-09-07T15-09.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/phase0-instructions-read.2026-09-07T15-07.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/powershell-poshqc-analyze.2026-09-07T15-22.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/powershell-poshqc-format.2026-09-07T15-21.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/powershell-poshqc-test.2026-09-07T15-25.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/pre-change-scope.2026-09-07T15-27.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-black.2026-09-07T15-11.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pyright.2026-09-07T15-13.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-ruff.2026-09-07T15-12.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-eslint.2026-09-07T15-17.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-jest-coverage.2026-09-07T15-20.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-prettier.2026-09-07T15-16.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-typecheck.2026-09-07T15-18.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/batch-budget-resets.2026-09-07T16-05.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-1.2026-09-07T13-38.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-2.2026-09-07T14-20.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-3.2026-09-07T14-45.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-4.2026-09-07T15-05.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase1-pester-key-partition.2026-09-07T15-47.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase1-python-parity.2026-09-07T15-45.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase2-python-contention.2026-09-07T16-02.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase2-python-scoped-coverage.2026-09-07T16-04.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase3-line-counts.2026-09-07T16-30.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase3-pester-blast-radius.2026-09-07T16-20.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase3-push-down-parity.2026-09-07T16-28.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase3-python-parity.2026-09-07T16-24.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase4-typescript-lint-typecheck.2026-09-07T17-05.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase4-typescript-scoped-coverage.2026-09-07T17-16.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase4-typescript-unit.2026-09-07T17-12.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase5-line-counts.2026-09-07T17-55.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase5-surface-and-push-down.2026-09-07T17-50.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/issue.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/research/2026-09-07T09-45-mergeable-project-file-overlaps-research.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/user-story.md
docs/features/potential/promoted/2026-09-07-mergeable-project-file-overlaps.md
docs/features/templates/parallel/parallel-status.md
extensions/drm-copilot/jest.config.cjs
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusConflict.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMerge.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts
extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts
extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts
extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts
extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts
scripts/dev_tools/_blast_radius_conflicts.py
scripts/dev_tools/_blast_radius_mergeable.py
scripts/dev_tools/compute_blast_radius.py
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
tests/fixtures/blast_radius/conflict-mergeable-csproj-no-edge.json
tests/fixtures/blast_radius/conflict-mergeable-glob-still-contends.json
tests/fixtures/project_file_merge/analyzer-paired.conflicted.csproj
tests/fixtures/project_file_merge/analyzer-paired.expected.csproj
tests/fixtures/project_file_merge/analyzer-single-line.conflicted.csproj
tests/fixtures/project_file_merge/analyzer-single-line.expected.csproj
tests/fixtures/project_file_merge/appconfig-disjoint.conflicted.config
tests/fixtures/project_file_merge/appconfig-disjoint.expected.config
tests/fixtures/project_file_merge/appconfig-newversion-differs.conflicted.config
tests/fixtures/project_file_merge/appconfig-newversion-differs.expected.config
tests/fixtures/project_file_merge/bom-compile.conflicted.csproj
tests/fixtures/project_file_merge/bom-compile.expected.csproj
tests/fixtures/project_file_merge/compile-paired.conflicted.csproj
tests/fixtures/project_file_merge/compile-paired.expected.csproj
tests/fixtures/project_file_merge/compile-single-line.conflicted.csproj
tests/fixtures/project_file_merge/compile-single-line.expected.csproj
tests/fixtures/project_file_merge/content-paired.conflicted.csproj
tests/fixtures/project_file_merge/content-paired.expected.csproj
tests/fixtures/project_file_merge/content-single-line.conflicted.csproj
tests/fixtures/project_file_merge/content-single-line.expected.csproj
tests/fixtures/project_file_merge/crlf-compile.conflicted.csproj
tests/fixtures/project_file_merge/crlf-compile.expected.csproj
tests/fixtures/project_file_merge/diff3-compile.conflicted.csproj
tests/fixtures/project_file_merge/diff3-compile.expected.csproj
tests/fixtures/project_file_merge/embeddedresource-paired.conflicted.csproj
tests/fixtures/project_file_merge/embeddedresource-paired.expected.csproj
tests/fixtures/project_file_merge/embeddedresource-single-line.conflicted.csproj
tests/fixtures/project_file_merge/embeddedresource-single-line.expected.csproj
tests/fixtures/project_file_merge/non-grammar-line.conflicted.csproj
tests/fixtures/project_file_merge/none-paired.conflicted.csproj
tests/fixtures/project_file_merge/none-paired.expected.csproj
tests/fixtures/project_file_merge/none-single-line.conflicted.csproj
tests/fixtures/project_file_merge/none-single-line.expected.csproj
tests/fixtures/project_file_merge/packages-disjoint.conflicted.config
tests/fixtures/project_file_merge/packages-disjoint.expected.config
tests/fixtures/project_file_merge/packages-unparseable-version.conflicted.config
tests/fixtures/project_file_merge/packages-version-differs.conflicted.config
tests/fixtures/project_file_merge/packages-version-differs.expected.config
tests/fixtures/project_file_merge/same-key-different-attributes.conflicted.csproj
tests/fixtures/project_file_merge/script-never-drop.base.csproj
tests/fixtures/project_file_merge/script-never-drop.ours.csproj
tests/fixtures/project_file_merge/script-never-drop.theirs.csproj
tests/fixtures/project_file_merge/script-resolved.base.csproj
tests/fixtures/project_file_merge/script-resolved.conflicted.csproj
tests/fixtures/project_file_merge/script-resolved.expected.csproj
tests/fixtures/project_file_merge/script-resolved.ours.csproj
tests/fixtures/project_file_merge/script-resolved.theirs.csproj
tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1
tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1
tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1
tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1
tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
tests/scripts/dev_tools/blast_radius_parity_test_support.py
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py
```

## `git status --porcelain --untracked-files=all`, verbatim

```text
 M .claude/agents/parallel-orchestrator.md
 M .claude/agents/parallel-planner.md
 M .claude/lib/blast-radius/BlastRadiusConflict.psm1
 M .claude/lib/project-file-merge/ProjectFileMerge.psm1
 M .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1
 M .claude/rules/parallel-orchestration.md
 M .claude/skills/parallel-add/SKILL.md
 M .claude/skills/parallel-orchestrate/SKILL.md
 M .claude/skills/parallel-plan/SKILL.md
 M docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/batch-budget-resets.2026-09-07T16-05.md
 M docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md
 M docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md
 M docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/user-story.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusConflict.psm1
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/ProjectFileMerge.psm1
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
 M extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
 M extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts
 M tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/coverage-delta.2026-09-07T19-35.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/file-size-compliance.2026-09-07T18-22.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-powershell-poshqc-analyze.2026-09-07T19-22.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-powershell-poshqc-format.2026-09-07T19-20.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-powershell-poshqc-test.2026-09-07T19-25.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-python-black.2026-09-07T18-25.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-python-pyright.2026-09-07T18-29.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-python-pytest-coverage.2026-09-07T18-40.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-python-ruff.2026-09-07T18-27.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-qa-loop-outcome.2026-09-07T19-32.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-typescript-eslint.2026-09-07T18-48.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-typescript-jest-coverage.2026-09-07T18-54.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-typescript-prettier.2026-09-07T18-46.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-typescript-typecheck.2026-09-07T18-50.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase6-documentation-contracts.2026-09-07T18-00.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase7-python-cohort-and-tolerance.2026-09-07T18-08.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase7-typescript-unit.2026-09-07T18-12.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/phase7-unmodified-surfaces.2026-09-07T18-16.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/scope-verification.2026-09-07T19-38.md
?? tests/fixtures/parallel_cohorts/cohorts_mergeable_only_overlaps.json
?? tests/fixtures/project_file_merge/invalid-utf8.conflicted.csproj
?? tests/scripts/dev_tools/test_parallel_mergeable_cohort.py
?? tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py
```
