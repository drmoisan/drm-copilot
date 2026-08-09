# Phase 2 — PowerShell Coverage Registration — Issue #440 (F7)

Timestamp: 2026-08-08T21-46

Task: [P2-T4]

Rationale: `.claude/rules/general-unit-test.md` (`## Coverage Exclusion Policy`) prohibits excluding a production file from coverage measurement. The three PowerShell production files this feature creates or modifies were absent from `CodeCoverage.Path`.

## Files Edited (byte-identical parity pair)

1. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
2. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

## Entries Appended (identical in both copies)

```powershell
            # Issue #440 added the two parallel enforcement hooks (the Layer 1 cohort
            # barrier and the worktree removal gate) and extended the invocation-origin
            # hook with the parallel-agent family; measured here so no new or changed
            # production hook is excluded from coverage.
            '.claude/hooks/enforce-parallel-cohort-barrier.ps1'
            '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1'
            '.claude/hooks/enforce-epic-invocation-origin.ps1'
```

Appended immediately after the final pre-existing entry (`'.claude/lib/blast-radius/BlastRadius.psm1'`) and before the closing `)` of the `Path` array, preceded by an `# Issue #440 ...` comment following the existing per-issue comment convention. No existing entry was modified, reordered, or removed.

## Byte-Identity Proof

Command: `sha256sum scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

EXIT_CODE: 0

```
before edit (both):  156d956971ca57fef4f8b340c2fad65181ec817c2dc186baa8548dc3d186b5e1
after edit (both):   3f48b41771b421e52a51dd8d93c3829016530170d1b58811c48c912b14e8d82c
```

Both copies hashed identically before the edit and hash identically after it, so the two edits are byte-identical.

## Append-Only Proof

Command: `git diff --numstat` and `git diff -U0` on both files

EXIT_CODE: 0

```
7       0       extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
7       0       scripts/powershell/PoshQC/settings/pester.runsettings.psd1
removed-line count (lines matching ^-[^-]): 0
hunk headers: @@ -126,0 +127,7 @@   (both files, identical)
```

Each file shows one pure-insertion hunk of 7 added lines and 0 deleted lines, at the identical position.

## Bundled-Parity Regression

Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

```
.                                                                        [100%]
1 passed in 0.04s
```

## Batch-Budget Outcome

Both `.psd1` writes were accepted. The batch-budget hook issued no denial, so [P2-T3]'s second-reset contingency did not trigger.

## Coverage-Denominator Note

The registration takes effect only for runs made from a republished extension bundle. `mcp__drm-copilot__run_poshqc_test` executes the installed bundle's `resources/templates/run-poshqc-test.ps1`, which imports the installed bundle's `PoshQC` module and its module-root-relative `settings/pester.runsettings.psd1`, so this edit does not change the same-session MCP coverage denominator. Acceptance criterion 15's per-file numbers for these three files therefore come from [P5-T8]'s dedicated repo-local Pester run, not from `artifacts/pester/powershell-coverage.xml`.

Output Summary: PASS. Three production hook paths (`enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-epic-invocation-origin.ps1`) were appended to `CodeCoverage.Path` in both `pester.runsettings.psd1` copies, preceded by an `# Issue #440 ...` comment. The two edits are byte-identical (post-edit sha256 `3f48b417…` for both), each diff is a single pure-insertion hunk of 7 added / 0 removed lines at position `@@ -126,0 +127,7 @@`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes (1 passed). No batch-budget denial occurred, so no second reset was needed.
