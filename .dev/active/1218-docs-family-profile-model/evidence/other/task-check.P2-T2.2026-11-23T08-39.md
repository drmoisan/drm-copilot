# Task Check P2-T2 (Issue #1218)

Timestamp: 2026-11-23T08-39
Changed files: tests/scripts/claude-lib/docs/DocsProfileFamilies.Tests.ps1 (new)
Selection rule: the mirrored test file of .claude/lib/docs/DocsProfileFamilies.psm1.
Command: sh SCRATCH/issue-1218-qc.sh format-check <file> (0 changes); sh SCRATCH/issue-1218-qc.sh analyze <file> (first run 2 PSUseShouldProcessForStateChangingFunctions warnings on the two New-* fixture factories, fixed with the suppression attribute the existing docs test files use; re-run 0 findings); sh SCRATCH/issue-1218-check.sh check-p2t2 tests/scripts/claude-lib/docs/DocsProfileFamilies.Tests.ps1 (attempt 1 exit 75 queue timeout; attempt 2 ran)
EXIT_CODE: 0
Output Summary:
- Pester selection: 27 tests, 27 passed, 0 failed. Not gate evidence.
- Named cases per rule with exact code and pointer: F1 `/required_families/1/id`, F2 `/required_families/1/directory`, F3 `/required_families/0/audience/1`, F4 `/required_families/1/diataxis_mode`, F5 `/required_families/0/directory` for `docs/guidebook/security`, `docs/security`, and `Docs/guide/security`, L1 `/legacy_exclusions/1/path`; acceptance of `docs/guide`, `docs/guide/security`, nested family directories, case-differing ids, a legacy path outside every root, and an exclusion on a required family; severity, message field name, next action, and artifact path for each of the six finding kinds.
- Default set: values and order of all ten records, element-wise ordinal key order, `handbook/user` prefix, empty root throws, fresh set per call.
- Selection coverage of .claude/lib/docs/DocsProfileFamilies.psm1: 100.00% line (65/65) (informational; gate coverage comes from P2-T6 and P4-T2).
