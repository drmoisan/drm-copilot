# Task Check P2-T4

Timestamp: 2026-11-24T07-36
Command: sh SCRATCH/issue-1234-taskcheck.sh ".codex/hooks/enforce-epic-merge-gate.ps1,tests/scripts/codex-hooks/enforce-epic-merge-gate-release.Tests.ps1" "<12 test files>" "" (static; launcher `pester -TestPath` selection)
EXIT_CODE: 0
Output Summary:
- Changed files: `.codex/hooks/enforce-epic-merge-gate.ps1` (header paragraph naming the leg; one guarded dot-source after the regeneration dot-source; one call line after the docs-only block with `-NoRecordingTarget` true only when both checkpoint texts are blank, returning `$null` when allowed; the explicit-number deny now ends `+ $docsOnlySuffix + $release.Suffix`), its byte copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and `tests/scripts/codex-hooks/enforce-epic-merge-gate-release.Tests.ps1` (5 rows added; 186 lines). Codex gate size 456 lines.
- Selection rule: the Codex suite plus the D8 Codex suites: every tests/scripts/codex-hooks/enforce-epic-merge-gate*.Tests.ps1 file (10), hook-dependency-failure.Codex.Tests.ps1, and codex-epic-runtime-contracts.Tests.ps1.
- Static: formatter 0 `Formatted: ` lines; analyzer 0 findings.
- Pester: exit 0 after 1 queue timeout (exit 75, re-run); 577 tests, 0 failures. The D8 Codex suites passed with no edit, and the P2-T3 AC-22 rows passed unchanged against the wired gate.
- New rows: AC-02 allow with AC-25 assertions, AC-05 non-blank child text `{}`, AC-23 release suffix after the docs-only suffix, AC-24 docs-only allow with zero leg pr view calls, AC-24 epic-child allow with zero allowance-seam and zero leg pr view calls.
