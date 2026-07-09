# Fail-Before Exception Dossier

Timestamp: 2026-07-04T09-48

## WhyFailingRunImpossible

The regression test file `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` and the corresponding fix files (`.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1`) were introduced together in the working tree prior to this plan's execution. A genuine fail-before Pester run is not obtainable without reverting the already-applied fix, which this plan does not authorize. This dossier substitutes committed-baseline proof (`git show`/`git ls-tree` against HEAD `97514a6`) for a live failing run.

## Alternative Proof Section 1 — `git show` Against Committed Baseline (P2-T3)

Command:
```
git show HEAD:extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1
```

Verification performed: the full committed file content (HEAD `97514a6`) was captured and searched for the line `. $script:CompletionHelpersPath` using:
```
grep -n 'CompletionHelpersPath' <captured-committed-content>
```

Output: no match (grep exit code 1).

Conclusion: the committed baseline copy of `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1` does NOT contain the line `. $script:CompletionHelpersPath`. This confirms the bundled Codex hook at the committed baseline lacked the helper-backed dot-source wiring that the working-tree fix adds, which is precisely the defect the new regression test (`enforce-completion-consistency-codex.Tests.ps1`) targets. Had the test been run against this committed baseline, it would have failed because the dot-source/helper wiring it asserts did not exist.

## Alternative Proof Section 2 — `git ls-tree` Against Committed Baseline (P2-T4)

Command:
```
git ls-tree HEAD -- .codex/hooks/enforce-completion-helpers.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1 tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
```

Output: (empty — no entries returned)

EXIT_CODE: 0

Conclusion: none of the three paths (`.codex/hooks/enforce-completion-helpers.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1`, `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`) existed at the committed baseline (HEAD `97514a6`). This proves the helper file did not exist and the targeted regression test itself did not exist prior to this plan's working-tree changes, confirming a genuine "run the new test against the unfixed code" execution is structurally impossible without first reverting the working tree to the committed baseline and reconstructing a test file that did not yet exist there.

## Combined Conclusion

Both proof sections corroborate that: (1) the committed baseline bundled Codex hook lacked the dot-sourced helper wiring the fix adds, and (2) the helper file and the new regression test did not exist at the committed baseline. Together these substitute for a live fail-before Pester run per the fail-before exception dossier convention.
