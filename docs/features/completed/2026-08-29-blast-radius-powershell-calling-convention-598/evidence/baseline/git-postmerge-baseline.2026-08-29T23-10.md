# Post-merge git baseline — issue #598

Timestamp: 2026-08-29T23-10
Task: [P0-T11]

Command:
1. `git log --merges -n 1 --format="%H %P" HEAD`
2. `git diff --name-only 6942dee8e10720693d55ccb5f121b2446862d6f8 f4d4f958808a5a420f11189f6fa02ee007a66525`
3. `git rev-parse --verify main`

EXIT_CODE: 0

`EXIT_CODE:` holds the highest exit code observed across the three commands. All three exited 0.

Output Summary:

BaseRef: main
MergeRef: f4d4f958808a5a420f11189f6fa02ee007a66525
PreMergeRef: 6942dee8e10720693d55ccb5f121b2446862d6f8
MergedBranchRef: 6df3766490977346cf839658f483742856a5e448
MergeAttributableFileCount: 152

Command 1 printed the single line
`f4d4f958808a5a420f11189f6fa02ee007a66525 6942dee8e10720693d55ccb5f121b2446862d6f8 6df3766490977346cf839658f483742856a5e448`.
The first whitespace-separated field is `MergeRef:`, the second is `PreMergeRef:`, the third is
`MergedBranchRef:`.

Command 3 printed `6c425f34d665cd62e8b7a17dcabf662ee461f682`, which is the SHA `main` resolves to.
`BaseRef:` restates the value `main` recorded by `[P0-T2]`.

## Identification check

The command 2 path list contains the line `.claude/lib/requirements/GeneratedDocumentCounters.psm1`
at position 7 of the sorted list. An exact-line search
(`grep -n -x` against the captured list) returned that one line. The recorded `MergeRef` is
therefore the commit that brought the 28th module onto this branch, and the stop-and-report branch
of this task does not fire.

The same list also carries the module's bundle mirror at position 131
(`extensions/drm-copilot/resources/claude-customizations/.claude/lib/requirements/GeneratedDocumentCounters.psm1`)
and its test file at position 147
(`tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1`).

## Acceptance evaluation

- `MergeRef:`, `PreMergeRef:`, and `MergedBranchRef:` each hold a 40-character SHA and the three
  values are distinct. Verified by inspection: each field is 40 hexadecimal characters, and no two
  fields share a value.
- `BaseRef:` is the single word `main`.
- `MergeAttributableFileCount:` is `152`, an integer greater than `0`.
- The command 2 path list contains the line `.claude/lib/requirements/GeneratedDocumentCounters.psm1`.

All four acceptance conditions hold.

## MAS — the full command 2 path list (152 paths)

```
.claude/agents/atomic-planner.md
.claude/agents/prd-feature.md
.claude/agents/task-researcher.md
.claude/hooks/validate-planner-output.ps1
.claude/hooks/validate-prd-feature-output.ps1
.claude/hooks/validate-task-researcher-output.ps1
.claude/lib/requirements/GeneratedDocumentCounters.psm1
.claude/settings.json
.claude/skills/acceptance-criteria-tracking/SKILL.md
.claude/skills/atomic-plan-contract/SKILL.md
.claude/skills/fill-feature-docs/SKILL.md
.claude/skills/parallel-add/SKILL.md
.claude/skills/parallel-plan/SKILL.md
.claude/skills/remediation-handoff-atomic-planner/SKILL.md
.claude/skills/research-issue/SKILL.md
.codex/config.toml
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T13-53/code-review.md
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T13-53/feature-audit.md
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T13-53/policy-audit.md
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T14-41/code-review.md
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T14-41/feature-audit.md
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T14-41/policy-audit.md
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T19-34/code-review.md
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T19-34/feature-audit.md
docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T19-34/policy-audit.md
docs/features/active/2026-08-29-claude-planning-integrity-593/code-review.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/powershell.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/powershell.coverage.2026-08-29T12-07.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/python-coverage-remediation.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/baseline/python-focused.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/other/numeric-provenance-remediation-summary.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/other/prd-feature-registration-remediation-summary.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/acceptance-criteria-checkoff.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/claude-bundle-parity-remediation.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/claude-bundle-parity.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/focused-python-contracts.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-pester-post.2026-08-29T13-15.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-powershell-analyze.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-powershell-format.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-powershell-tests-and-coverage.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-focused.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-format.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-full-coverage.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-lint.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-type.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-remediation-acceptance.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/planner-review-initial-bundle-publication.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/planner-review-pester-post-junit.2026-08-29T14-41.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/planner-review-pester-post.2026-08-29T14-41.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/planner-review-powershell-analyze.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/planner-review-powershell-format.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/planner-review-powershell-mcp-test.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/powershell-coverage.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/powershell-toolchain.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/powershell.coverage.2026-08-29T12-07.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/powershell.coverage.remediation.2026-08-29T12-07.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-acceptance.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-pester-post.2026-08-29T13-53.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-powershell-analyze.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-powershell-format.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-powershell-tests-and-coverage.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-python-focused.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-python-format.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-python-full-coverage.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-python-lint.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-python-type.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-settings-bundle-parity.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/python-toolchain.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/validate-prd-feature-output-coverage-remediation.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/validate-prd-feature-output-coverage-remediation.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/regression-testing/planner-review-codex-ambient-state-green.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/regression-testing/planner-review-codex-ambient-state-red.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/numeric-provenance-pester-baseline.2026-08-29T13-15.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/numeric-provenance-powershell-coverage.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/numeric-provenance-target-inventory.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/phase0-instructions-read.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/phase0-instructions-read.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-pester-baseline-junit.2026-08-29T14-41.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-pester-baseline.2026-08-29T14-41.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-phase0-instructions-read.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-powershell-analyze-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-powershell-format-baseline-restart.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-powershell-format-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-powershell-mcp-test-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-powershell-tests-and-coverage-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-focused-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-format-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-full-coverage-baseline.2026-08-29T14-41.json
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-full-coverage-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-lint-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-type-baseline.2026-08-29T14-41.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-pester-baseline.2026-08-29T13-53.xml
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-powershell-analyze.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-powershell-format.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-powershell-tests-and-coverage.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-python-focused.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-python-format.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-python-full-coverage.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-python-lint.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-python-type.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-settings-registration.2026-08-29T13-53.md
docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/validate-prd-feature-output-coverage.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/feature-audit.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/issue.md
docs/features/active/2026-08-29-claude-planning-integrity-593/plan.2026-08-29T12-07.md
docs/features/active/2026-08-29-claude-planning-integrity-593/policy-audit.2026-08-29T13-15.md
docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T13-15/remediation-inputs.md
docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T13-15/remediation-plan.md
docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T13-53/remediation-inputs.md
docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T13-53/remediation-plan.md
docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T14-41/remediation-inputs.md
docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T14-41/remediation-plan.md
docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T19-34/remediation-inputs.md
docs/features/active/2026-08-29-claude-planning-integrity-593/remediation/2026-08-29T19-34/remediation-plan.md
docs/features/active/2026-08-29-claude-planning-integrity-593/research/2026-08-29T12-12-claude-planning-integrity-research.md
docs/features/active/2026-08-29-claude-planning-integrity-593/spec.md
docs/features/active/2026-08-29-claude-planning-integrity-593/user-story.md
docs/features/epics/claude-runtime-portability/epic-status.md
docs/features/potential/promoted/2026-08-29-claude-planning-integrity.md
docs/features/potential/promoted/2026-08-29-cleanup-worktrees-apply-deletes-local-main.md
docs/features/potential/promoted/2026-08-29-mermaid-skill-python-invocation-uncovered.md
extensions/drm-copilot/package-lock.json
extensions/drm-copilot/package.json
extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/requirements/GeneratedDocumentCounters.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/fill-feature-docs/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml
packages/mcp-server/package-lock.json
packages/mcp-server/package.json
tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1
tests/scripts/claude-runtime/claude-settings.Tests.ps1
tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
```
