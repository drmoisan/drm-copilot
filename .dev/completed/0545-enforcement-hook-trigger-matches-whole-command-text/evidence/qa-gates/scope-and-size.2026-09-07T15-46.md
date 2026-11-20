# [P12-T1] Scope-and-size enumeration

Timestamp: 2026-09-07T15-46

Command:

```
git diff origin/epic/cleanup-merged-worktrees-hardening-integration --name-status
git status --porcelain
```

EXIT_CODE: 0 (both commands)

TOOLCHAIN_SUBSTITUTION: not applicable. This task invokes `git` only; no PowerShell
toolchain stage is required. The classification of the enumerated paths into the six groups
is performed by a Python script rather than a PowerShell one-liner, because `pwsh` is not
invocable in this session; the script consumes the verbatim output of the two `git` commands
above and adds no data of its own.

## Output Summary

The two enumerations are paired deliberately. The anchored name-status diff enumerates
tracked changes against the base ref `origin/epic/cleanup-merged-worktrees-hardening-integration`
and is blind to files created but not yet tracked; `git status --porcelain` reports those
newly created paths and is the companion that makes them visible. Neither alone is
sufficient, so the union of the two is the enumeration this artifact classifies.

| Measure | Value |
| --- | --- |
| Name-status entries | 133 |
| Porcelain entries (one untracked directory expanded to its files) | 6 |
| **Union size** | **137** |
| Group 1 — nine in-scope hooks across their copy sets | 28 |
| Group 2 — two parser files across their eight locations | 8 |
| Group 3 — five registry files | 5 |
| Group 4 — test files under `tests/` | 21 |
| Group 5 — the issue #539 `spec.md` | 1 |
| Group 6 — feature-lifecycle documents | 74 |
| **Unassigned** | **0** |

28 + 8 + 5 + 21 + 1 + 74 = 137, which equals the union size. **Every path in the union falls
into exactly one of the six groups and none is unassigned.**

### Disambiguation rule applied

One path is a member of two group definitions as written:
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` is registry file 3 of 5 (it
carries the `$script:SharedModuleNames` array that registers the two parser siblings) and it
also lives under `tests/`. Because the six groups must partition the union, group 3 is applied
in precedence over group 4 and the path is counted once, in group 3. That is the only path in
the union to which two group definitions both apply.

### Guard observations derived from the same enumeration

| Guard | Observed |
| --- | --- |
| Paths under `.github/instructions/` | 0 |
| Paths under `.claude/rules/` | 0 |
| Paths in a hook directory that are neither one of the nine in-scope hooks nor one of the two parser siblings | 0 |
| `.py` files added or modified | 0 |
| Hook copy-set members expected, and present | 28 of 28 |
| Parser locations expected, and present | 8 of 8 |
| Registry files expected, and present | 5 of 5 |

## Enumeration 1 — `git diff ... --name-status` (133 entries, verbatim)

```
M	.claude/hooks/enforce-epic-merge-gate.ps1
M	.claude/hooks/enforce-epic-worktree-removal-gate.ps1
M	.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
M	.claude/hooks/enforce-parallel-abandon-gate.ps1
M	.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
M	.claude/hooks/enforce-pr-author-skill-helpers.ps1
M	.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
M	.claude/hooks/enforce-promotion-mcp-only.ps1
A	.claude/hooks/hook-command-invocation.ps1
A	.claude/hooks/hook-command-scanner.ps1
M	.claude/hooks/validate-bash.ps1
M	.codex/hooks/enforce-epic-merge-gate.ps1
M	.codex/hooks/enforce-epic-worktree-removal-gate.ps1
M	.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
M	.codex/hooks/enforce-promotion-mcp-only.ps1
A	.codex/hooks/hook-command-invocation.ps1
A	.codex/hooks/hook-command-scanner.ps1
M	.codex/hooks/validate-bash.ps1
M	docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-codex-contract-suite.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-coverage-list-length.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-environment-facts.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-file-inventory.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-git-state.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-poshqc-analyze.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-poshqc-format.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-python-contracts.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-selfhosted-per-file-coverage.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-selfhosted-test.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-targeted-pester.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/phase0-feature-documents-read.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/phase0-instructions-read.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b0a-budget-reset.2026-09-07T11-28.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b0b-budget-reset.2026-09-07T11-45.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b1-budget-reset.2026-09-07T12-12.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b1-toolchain.2026-09-07T12-26.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b10-toolchain.2026-09-07T14-04.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b11-toolchain.2026-09-07T14-10.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b12-toolchain.2026-09-07T14-18.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b13-toolchain.2026-09-07T14-24.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b14-toolchain.2026-09-07T14-31.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b15-toolchain.2026-09-07T14-55.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b16-toolchain.2026-09-07T15-03.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b17-toolchain.2026-09-07T15-17.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b18-toolchain.2026-09-07T15-22.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b19-toolchain.2026-09-07T15-32.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b2-toolchain.2026-09-07T12-45.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b3-toolchain.2026-09-07T12-48.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b4-toolchain.2026-09-07T12-51.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b5-toolchain.2026-09-07T13-01.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b6-toolchain.2026-09-07T13-24.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b7-toolchain.2026-09-07T13-36.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b8-toolchain.2026-09-07T13-52.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b9-toolchain.2026-09-07T14-02.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/codex-merge-gate-no-digit-scan.2026-09-07T14-59.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/invocation-line-count-b2.2026-09-07T12-39.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/legacy-codex-suite-line-count.2026-09-07T12-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/pack-manifest-completeness.2026-09-07T12-56.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/post-b14-call-line-form-correction.2026-09-07T14-38.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/registration-inventory.2026-09-07T12-55.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/scanner-line-count-b1.2026-09-07T12-20.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/test-suite-line-count-b1.2026-09-07T12-20.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/test-suite-line-count-pr-author.2026-09-07T14-11.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/ea2-false-allow-direction.2026-09-07T14-51.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-acceptance-cases.2026-09-07T11-35.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-claude-commandexemption.2026-09-07T11-48.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-claude-triggerscoping.2026-09-07T11-40.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-codex-commandexemption.2026-09-07T11-52.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-codex-triggerscoping.2026-09-07T11-44.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-parallel-abandon.2026-09-07T15-28.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-validate-bash.2026-09-07T15-10.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/intended-assertion-reversal.2026-09-07T11-52.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at1-at7.2026-09-07T14-31.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at2-at4.2026-09-07T15-06.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at3-at5.2026-09-07T14-06.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at6-deny-preservation.2026-09-07T13-41.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-claude-preimplementation.2026-09-07T13-17.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-codex-preimplementation.2026-09-07T13-31.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-base-branch-existing-suite.2026-09-07T14-07.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-merge-existing-suite.2026-09-07T14-51.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-merge-triggerscoping.2026-09-07T14-50.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-worktree-existing-suite.2026-09-07T14-14.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-live-reproduction.2026-09-07T14-10.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-parallel-worktree-existing-suite.2026-09-07T14-28.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-validate-bash.2026-09-07T15-14.md
M	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
M	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1
A	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1
A	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
M	extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1
A	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1
A	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
M	extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
M	scripts/powershell/PoshQC/settings/pester.runsettings.psd1
A	tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
M	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
A	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
A	tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
A	tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
A	tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
A	tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
A	tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
M	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
A	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
A	tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
A	tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
A	tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
M	tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
A	tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
```

## Enumeration 2 — `git status --porcelain` (verbatim)

```
 M docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/issue-updates/
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/539-spec-additive-only.2026-09-07T15-40.md
?? docs/features/potential/2026-09-07-codex-preimplementation-gate-modes-module-unregistered.md
?? docs/features/potential/2026-09-07-parallel-abandon-equals-joined-disposition-runtime-confirmation.md
```

The fourth line is an untracked **directory**. Expanded to its files it contributes exactly one
path, `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/issue-updates/issue-591.2026-09-07T15-41.md`,
which is the [P11-T7] artifact. The porcelain enumeration therefore contributes 6 distinct file
paths, of which 2 (` M` rows) are already present in the name-status enumeration and 4 are new,
giving the union size 133 + 4 = 137.

## The six-group classification, in full

### Group 1 — the nine in-scope hooks across their copy sets — 28 paths

```
M	.claude/hooks/enforce-epic-merge-gate.ps1
M	.claude/hooks/enforce-epic-worktree-removal-gate.ps1
M	.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
M	.claude/hooks/enforce-parallel-abandon-gate.ps1
M	.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
M	.claude/hooks/enforce-pr-author-skill-helpers.ps1
M	.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
M	.claude/hooks/enforce-promotion-mcp-only.ps1
M	.claude/hooks/validate-bash.ps1
M	.codex/hooks/enforce-epic-merge-gate.ps1
M	.codex/hooks/enforce-epic-worktree-removal-gate.ps1
M	.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
M	.codex/hooks/enforce-promotion-mcp-only.ps1
M	.codex/hooks/validate-bash.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
```

### Group 2 — the two parser files across their eight locations — 8 paths

```
A	.claude/hooks/hook-command-invocation.ps1
A	.claude/hooks/hook-command-scanner.ps1
A	.codex/hooks/hook-command-invocation.ps1
A	.codex/hooks/hook-command-scanner.ps1
A	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1
A	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1
A	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1
A	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1
```

### Group 3 — the five registry files — 5 paths

```
M	extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
M	extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
M	extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
M	scripts/powershell/PoshQC/settings/pester.runsettings.psd1
M	tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```

### Group 4 — test files under `tests/` — 21 paths

```
A	tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
M	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
A	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
A	tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
A	tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
A	tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
A	tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
A	tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
A	tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
M	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
A	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
A	tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
A	tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
A	tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
A	tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
```

### Group 5 — the issue #539 `spec.md` annotated by Phase 11 — 1 paths

```
M	docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md
```

### Group 6 — feature-lifecycle documents — 74 paths

```
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-codex-contract-suite.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-coverage-list-length.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-environment-facts.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-file-inventory.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-git-state.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-poshqc-analyze.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-poshqc-format.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-python-contracts.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-selfhosted-per-file-coverage.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-selfhosted-test.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-targeted-pester.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/phase0-feature-documents-read.2026-09-07T10-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/phase0-instructions-read.2026-09-07T10-57.md
?? (expanded from untracked dir docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/issue-updates/)	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/issue-updates/issue-591.2026-09-07T15-41.md
??	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/539-spec-additive-only.2026-09-07T15-40.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b0a-budget-reset.2026-09-07T11-28.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b0b-budget-reset.2026-09-07T11-45.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b1-budget-reset.2026-09-07T12-12.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b1-toolchain.2026-09-07T12-26.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b10-toolchain.2026-09-07T14-04.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b11-toolchain.2026-09-07T14-10.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b12-toolchain.2026-09-07T14-18.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b13-toolchain.2026-09-07T14-24.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b14-toolchain.2026-09-07T14-31.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b15-toolchain.2026-09-07T14-55.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b16-toolchain.2026-09-07T15-03.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b17-toolchain.2026-09-07T15-17.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b18-toolchain.2026-09-07T15-22.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b19-toolchain.2026-09-07T15-32.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b2-toolchain.2026-09-07T12-45.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b3-toolchain.2026-09-07T12-48.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b4-toolchain.2026-09-07T12-51.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b5-toolchain.2026-09-07T13-01.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b6-toolchain.2026-09-07T13-24.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b7-toolchain.2026-09-07T13-36.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b8-toolchain.2026-09-07T13-52.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b9-toolchain.2026-09-07T14-02.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/codex-merge-gate-no-digit-scan.2026-09-07T14-59.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/invocation-line-count-b2.2026-09-07T12-39.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/legacy-codex-suite-line-count.2026-09-07T12-57.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/pack-manifest-completeness.2026-09-07T12-56.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/post-b14-call-line-form-correction.2026-09-07T14-38.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/registration-inventory.2026-09-07T12-55.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/scanner-line-count-b1.2026-09-07T12-20.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/test-suite-line-count-b1.2026-09-07T12-20.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/test-suite-line-count-pr-author.2026-09-07T14-11.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/ea2-false-allow-direction.2026-09-07T14-51.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-acceptance-cases.2026-09-07T11-35.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-claude-commandexemption.2026-09-07T11-48.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-claude-triggerscoping.2026-09-07T11-40.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-codex-commandexemption.2026-09-07T11-52.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-codex-triggerscoping.2026-09-07T11-44.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-parallel-abandon.2026-09-07T15-28.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-validate-bash.2026-09-07T15-10.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/intended-assertion-reversal.2026-09-07T11-52.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at1-at7.2026-09-07T14-31.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at2-at4.2026-09-07T15-06.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at3-at5.2026-09-07T14-06.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at6-deny-preservation.2026-09-07T13-41.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-claude-preimplementation.2026-09-07T13-17.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-codex-preimplementation.2026-09-07T13-31.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-base-branch-existing-suite.2026-09-07T14-07.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-merge-existing-suite.2026-09-07T14-51.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-merge-triggerscoping.2026-09-07T14-50.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-worktree-existing-suite.2026-09-07T14-14.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-live-reproduction.2026-09-07T14-10.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-parallel-worktree-existing-suite.2026-09-07T14-28.md
A	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-validate-bash.2026-09-07T15-14.md
M	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
M	docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
??	docs/features/potential/2026-09-07-codex-preimplementation-gate-modes-module-unregistered.md
??	docs/features/potential/2026-09-07-parallel-abandon-equals-joined-disposition-runtime-confirmation.md
```

Status letters: `A` = added (tracked), `M` = modified (tracked), `??` = untracked, reported by
`git status --porcelain` only.

## Classification summary as emitted by the script

```
NAME-STATUS entries: 133
PORCELAIN entries (dirs expanded to files): 6
UNION size: 137
GROUP 1: 28
GROUP 2: 8
GROUP 3: 5
GROUP 4: 21
GROUP 5: 1
GROUP 6: 74
UNASSIGNED (group 0): 0
HOOK_COPY_SET expected: 28, present in name-status: 28, missing: 0
PARSER_SET expected: 8, present in name-status: 8, missing: 0
REGISTRY expected: 5, missing: 0
POLICY PATHS TOUCHED (.github/instructions/ or .claude/rules/): 0
HOOK-DIRECTORY PATHS OUTSIDE THE NINE AND THE PARSER PAIR: 0
PYTHON FILES IN UNION: 0
```
