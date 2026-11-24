# Task Check P2-T1 (issue #1231)

Timestamp: 2026-11-24T00-17
Changed files:
- .claude/hooks/enforce-pr-author-skill.release.ps1 (new, 177 lines)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.release.ps1 (new bundle copy, byte-identical by cmp)
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json (entry added)
- tests/scripts/claude-hooks/enforce-pr-author-skill.Release.Tests.ps1 (new; unit rows)
Selection rule: the mirrored test file of the changed production file.

Command: sh SCRATCH/issue-1231-taskcheck.sh (formatter check mode and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the hook and the suite)
EXIT_CODE: 0
Output Summary: formatter-changed-files=0, analyzer-findings=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-pr-author-skill.Release.Tests.ps1
EXIT_CODE: 0
Output Summary: Tests Passed: 23, Failed: 0. Rows: allow (the diff call asserted with `$GitArgs` joined as `diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <commit>...HEAD`, where <commit> is the 40-digit value the mocked rev-parse returns); absent file and blank root (zero Invoke-PrAuthorDocsOnlyGitExe and Get-PrAuthorReleasePublishedHead calls); every one of the ten RELEASE_EXEMPTION_* codes, including gh pr edit, a repeated --head, a missing --base, --head=<b>, --head owner:branch, --repo, -R, -H, a --head with no value, and a value containing '..'; zero git-seam calls on the CHECKPOINT_PRESENT and BRANCH_NOT_MATCHED rows; the caught error (Write-Debug invoked, $null reason, Exempt false); and the Get-PrAuthorReleasePublishedHead seam body.
