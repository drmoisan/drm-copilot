# Task Check P3-T1

Timestamp: 2026-11-24T16-33
Command: sh SCRATCH/issue-1220-static.sh SCRATCH/issue-1220-p3t1-files.txt write; sh SCRATCH/issue-1220-tc-p3t1.sh (sh SCRATCH/issue-1220-retry.sh SCRATCH/issue-1220-tc-p3t1.log pester -TestPath tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1 tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Properties.Tests.ps1 tests/scripts/claude-lib/docs/DocsReferenceBoundary.Tests.ps1 tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1 tests/scripts/claude-lib/docs/DocsReferenceWriter.Split.Tests.ps1 tests/scripts/claude-lib/docs/DocsReferenceWriter.PathPrefix.Tests.ps1 tests/scripts/claude-lib/docs/DocsReferenceWriter.Errors.Tests.ps1 tests/scripts/claude-lib/docs/DocsReviewCadence.Tests.ps1 tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1 tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1)
EXIT_CODE: 0
Output Summary: static pass: 4 files, 0 would change, 0 analyzer findings. Pester selection: 202 tests, 202 passed, 0 failed (workers=8, wall-clock 248.07s, launcher exit 0). DocsReferenceFrontMatter.psm1 91/91 lines in the selection (100%).

Changed files:
- .claude/lib/docs/DocsReferenceFrontMatter.psm1 and its bundle copy (SHA-256 b5e877a5... both): Resolve-DocsReferenceFrontMatterValue copies an existing review_due; ConvertTo-DocsReferenceFrontMatterText writes owner, last_reviewed, review_due, audience, diataxis_mode, surface_refs, title, extensions; module and function docstrings updated.
- tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Properties.Tests.ps1: $script:FieldOrder gains review_due after last_reviewed (reason: the written key order is the changed contract).
- tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1: two new It cases, `keeps an existing review_due value at the third key position on regeneration (issue #1220)` and `writes a page without review_due without the key (issue #1220)`.

Selection rule: the mirrored tests of the changed module (DocsReferenceFrontMatter.Tests.ps1, DocsReferenceFrontMatter.Properties.Tests.ps1), every test file that names the module (DocsReferenceBoundary.Tests.ps1, DocsReviewCadence.Tests.ps1, whose AST test reads it), the unchanged reference writer tests named in P3-T1, Docs.Manifest.Tests.ps1 (bundle copy), and ClaudeLibModuleConvention.Tests.ps1.

Run history (append-only record):
1. First launch included DocsReferenceIntegration.Tests.ps1 by name: the launcher refused it with exit 2, "TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence (test-execution policy)". The file is in the integration lane and runs in CI only; it was removed from the explicit selection. Non-blocking deviation: DocsReferenceIntegration.Tests.ps1 (named unchanged in P3-T1) is CI-only evidence.
2. Second launch: 40 consecutive attempts ended with exit 75 (queue timeouts; the machine test-suite lock was held by other worktrees), recorded as queue timeouts, not failures.
3. Third launch: first attempt ran, exit 0.
