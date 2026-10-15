# AC-17 Line Counts ([P6-T9])

Timestamp: 2026-10-12T04-09
Command: git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD ; git status --porcelain ; sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/line-counts.ps1 <the 32 listed paths that do not end in .md>
EXIT_CODE: 0
Output Summary: LINECOUNT-SUMMARY OverLimitCount=0. The diff listing contains every S-PROD-6, S-MIRROR-6, S-TEST-MOD-11, and S-TEST-NEW-8 path; git status --porcelain lists only paths under docs/features/active/subagentstop-envelope-orchestrator-family-903/.

Diff listing (non-.md paths; the remaining listed paths are .md files: .claude/agents/prd-feature.md, its mirror, and feature-folder documents and evidence):
.claude/hooks/validate-executor-output.ps1
.claude/hooks/validate-orchestrator-output-resolution.ps1
.claude/hooks/validate-orchestrator-output-routing.ps1
.claude/hooks/validate-orchestrator-output.ps1
.claude/hooks/validate-planner-output.ps1
.claude/hooks/validate-required-artifact-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-executor-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-resolution.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-routing.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-required-artifact-output.ps1
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1
tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1
tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1
tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output.Reentry.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1
tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1
tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1
tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1
tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1
tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1

git status --porcelain (all under the feature folder):
 M docs/features/active/subagentstop-envelope-orchestrator-family-903/plan.2026-10-11T07-59.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/other/commit-push-phase5-agent.2026-10-12T04-07.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac13-cr7-comment.2026-10-12T04-08.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac14-double-import.2026-10-12T04-08.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac16-split.2026-10-12T04-08.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac21-no-python.2026-10-12T04-08.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac22-stop-hook-active.2026-10-12T04-08.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac7-claude-hook-input.2026-10-12T04-08.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac8-output-reads.2026-10-12T04-08.md
?? docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/ac9-exit1-write-error.2026-10-12T04-08.md

A4 output:
.claude/hooks/validate-executor-output.ps1 LineCount=322
.claude/hooks/validate-orchestrator-output-resolution.ps1 LineCount=311
.claude/hooks/validate-orchestrator-output-routing.ps1 LineCount=170
.claude/hooks/validate-orchestrator-output.ps1 LineCount=344
.claude/hooks/validate-planner-output.ps1 LineCount=440
.claude/hooks/validate-required-artifact-output.ps1 LineCount=199
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-executor-output.ps1 LineCount=322
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-resolution.ps1 LineCount=311
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-routing.ps1 LineCount=170
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1 LineCount=344
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1 LineCount=440
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-required-artifact-output.ps1 LineCount=199
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json LineCount=224
tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 LineCount=461
tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 LineCount=157
tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1 LineCount=176
tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1 LineCount=162
tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 LineCount=319
tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 LineCount=254
tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1 LineCount=201
tests/scripts/claude-hooks/validate-orchestrator-output.Reentry.Tests.ps1 LineCount=210
tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 LineCount=454
tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 LineCount=250
tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 LineCount=366
tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 LineCount=330
tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 LineCount=161
tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 LineCount=204
tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1 LineCount=127
tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 LineCount=400
tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1 LineCount=217
tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1 LineCount=139
tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 LineCount=119
LINECOUNT-SUMMARY OverLimitCount=0
