# Mirror Hashes (remediation cycle 1, loop pass 3)

Timestamp: 2026-11-03T20-31
Task: [P5-T2] re-verification after the loop pass 3 change to Invoke-ParallelAdmissionGit in Invoke-ParallelAdmission.ps1
Command: cp of .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 to its bundle path, then sha256sum of each canonical and bundle file; twin search as in mirror-hashes.2026-11-03T19-53.md
EXIT_CODE: 0
Output Summary: all four pairs have equal SHA256; twin search none. ParallelAdmission.Manifest.Tests.ps1 5/0 in pester-targeted.2026-11-03T20-29.md, which ran after the re-copy.

| File | Canonical SHA256 | Bundle SHA256 | Equal |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 7f0a6920239db6b623a641f075d4ceb7d0776f686caa9af6aa87cacb7a21090a | 7f0a6920239db6b623a641f075d4ceb7d0776f686caa9af6aa87cacb7a21090a | yes |
| .claude/lib/parallel-admission/ParallelAdmissionJson.psm1 | c6ac782780f6058edacf165e30576de11714d7ee06ba2df3684dd8fac282a1e0 | c6ac782780f6058edacf165e30576de11714d7ee06ba2df3684dd8fac282a1e0 | yes |
| .claude/skills/parallel-plan/SKILL.md | 623e9f6797d754369c424475084a3668423e36c3ac7a9bd976c34ec01a24ade9 | 623e9f6797d754369c424475084a3668423e36c3ac7a9bd976c34ec01a24ade9 | yes |
| .claude/rules/parallel-orchestration.md | 350b462438939b1140c536c3112eb0cbc40cda8263f8a8de5e65802647a6ac07 | 350b462438939b1140c536c3112eb0cbc40cda8263f8a8de5e65802647a6ac07 | yes |
