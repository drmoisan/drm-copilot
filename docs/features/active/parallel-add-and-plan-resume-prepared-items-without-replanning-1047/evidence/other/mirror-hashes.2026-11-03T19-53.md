# Mirror Hashes (remediation cycle 1)

Timestamp: 2026-11-03T19-53
Task: [P5-T2]
Command: cp of each canonical .claude file to its bundle path under extensions/drm-copilot/resources/claude-customizations/, then sha256sum of both; git ls-files plus untracked listing filtered by the four file names for .agents, .github, and .codex twins; Invoke-PoshQCTest over tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 (counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: all four pairs have equal SHA256; twin search found none (only the .claude canonical files and their claude-customizations bundle copies); ParallelAdmission.Manifest.Tests.ps1 5 tests, 0 failures, 0 errors.

| File | Canonical SHA256 | Bundle SHA256 | Equal |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 06ef4e7a476b96ba0049438ba37ee292e24c260e35a876ffadf27fc5ca3eab84 | 06ef4e7a476b96ba0049438ba37ee292e24c260e35a876ffadf27fc5ca3eab84 | yes |
| .claude/lib/parallel-admission/ParallelAdmissionJson.psm1 | c6ac782780f6058edacf165e30576de11714d7ee06ba2df3684dd8fac282a1e0 | c6ac782780f6058edacf165e30576de11714d7ee06ba2df3684dd8fac282a1e0 | yes |
| .claude/skills/parallel-plan/SKILL.md | 623e9f6797d754369c424475084a3668423e36c3ac7a9bd976c34ec01a24ade9 | 623e9f6797d754369c424475084a3668423e36c3ac7a9bd976c34ec01a24ade9 | yes |
| .claude/rules/parallel-orchestration.md | 350b462438939b1140c536c3112eb0cbc40cda8263f8a8de5e65802647a6ac07 | 350b462438939b1140c536c3112eb0cbc40cda8263f8a8de5e65802647a6ac07 | yes |

Twin search (.agents, .github, .codex): none
