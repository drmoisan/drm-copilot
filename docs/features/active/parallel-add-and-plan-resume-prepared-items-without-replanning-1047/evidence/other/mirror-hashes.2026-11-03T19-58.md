# Mirror Hashes (remediation cycle 1, after loop pass 1 fix)

Timestamp: 2026-11-03T19-58
Task: [P5-T2] re-verification after the Phase 6 pass 1 analyzer fix renamed Invoke-ParallelAdmissionReuseEdges to Invoke-ParallelAdmissionEdgeReuse in Invoke-ParallelAdmission.ps1
Command: cp of .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 to its bundle path, then sha256sum of each canonical and bundle file; twin search as in mirror-hashes.2026-11-03T19-53.md
EXIT_CODE: 0
Output Summary: all four pairs have equal SHA256; twin search none. ParallelAdmission.Manifest.Tests.ps1 5/0 in pester-targeted.2026-11-03T19-56.md, which ran after the re-copy.

| File | Canonical SHA256 | Bundle SHA256 | Equal |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 33b00626a5478355e5ee069e7ae5af6cb1c7a246ea8555eac447b7d57ac31194 | 33b00626a5478355e5ee069e7ae5af6cb1c7a246ea8555eac447b7d57ac31194 | yes |
| .claude/lib/parallel-admission/ParallelAdmissionJson.psm1 | c6ac782780f6058edacf165e30576de11714d7ee06ba2df3684dd8fac282a1e0 | c6ac782780f6058edacf165e30576de11714d7ee06ba2df3684dd8fac282a1e0 | yes |
| .claude/skills/parallel-plan/SKILL.md | 623e9f6797d754369c424475084a3668423e36c3ac7a9bd976c34ec01a24ade9 | 623e9f6797d754369c424475084a3668423e36c3ac7a9bd976c34ec01a24ade9 | yes |
| .claude/rules/parallel-orchestration.md | 350b462438939b1140c536c3112eb0cbc40cda8263f8a8de5e65802647a6ac07 | 350b462438939b1140c536c3112eb0cbc40cda8263f8a8de5e65802647a6ac07 | yes |
