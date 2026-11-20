# P0-T28 Defect Reproduction: quality-tiers.yml Absent (expect-fail)

Timestamp: 2026-10-02T03-18
Command: git ls-files --error-unmatch quality-tiers.yml
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `error: pathspec 'quality-tiers.yml' did not match any file(s) known to git`. The defect reproduces on HEAD 151846c7. Fail-before half of AC-01; P4-T7 is the pass-after half.
