# Phase 0 — `CodeCoverage.Path` Allow-List Re-measurement

Timestamp: 2026-09-07T10-57

Task: [P0-T8]

Command: `python scratchpad/compare_coverage_list.py` — parses the `CodeCoverage.Path = @( ... )` block of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` by matching the enclosing parenthesis, discarding blank and comment-only lines, and extracting each single-quoted entry

EXIT_CODE: 0

## Measurement-method note

The plan does not mandate a PowerShell command for this task, so no route deviation applies. The
parser reads the same literal text `Import-PowerShellDataFile` would read; each surviving line in the
block matches `^'([^']+)'\s*(?:#.*)?$`, and the parser reports any line that does not match as
`UNPARSED::`. **Zero lines were reported as unparsed**, so the extraction covered the whole block and
no entry was silently dropped.

## Results

| Figure | Value |
| --- | --- |
| Total entry count | **89** |
| Distinct entry count | **88** |
| Entries appearing more than once | **1** |

### Duplicate list

| Entry | Occurrences |
| --- | --- |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 2 |

The duplicate list is therefore **not empty**. This is the pre-existing duplicate the spec's
"Measurement conflict" note predicted; it is not introduced by this change and is not removed by it.

## Consequence for later arithmetic

Any statement of the form "the list length increases by exactly N" is unsafe against this list on two
independent grounds, both now measured rather than assumed:

1. The total (89) and the distinct count (88) differ, so "length" is ambiguous unless it names which
   count it means.
2. The prior `83`-entry figure recorded in earlier documents is **stale** and is contradicted by this
   measurement. It is not cited.

D11.2 requires four new entries in this list — the `.claude/hooks/` and `.codex/hooks/` paths of each
of `hook-command-scanner.ps1` and `hook-command-invocation.ps1`. Applying that to the measured
baseline gives an expected post-change total of **93** and an expected distinct count of **92**,
provided none of the four is already present. None of the four is present at baseline: the
[P0-T4] inventory records all eight parser paths as `ABSENT` from the filesystem, and the parsed list
above contains no entry matching either filename.

## Mirror-copy parity at baseline

`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` was parsed by
the same routine:

- Bundle total entry count: **89**
- Repo file text equals bundle file text, character for character: **True**
- Repo parsed entry list equals bundle parsed entry list: **True**

The two copies are textually identical at baseline, which is the condition
`tests/scripts/dev_tools/test_poshqc_bundled_parity.py` enforces. The two Phase 4 edits must
therefore also be textually identical to each other.

## Cross-check against the emitted coverage report

The 88 distinct entries produced exactly 88 `sourcefile` elements in
`artifacts/pester/powershell-coverage.xml`, with 0 entries missing from the report and 0 report
elements absent from the list. This confirms that every declared entry resolves to a real file under
the repository root and that the duplicate collapses to a single measured file rather than producing
a second row.

Output Summary: `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
holds **89 total entries, 88 distinct**. The duplicate list is not empty: it contains exactly
`.claude/hooks/enforce-pr-author-skill.ps1`, appearing twice. The bundle mirror is textually
identical (89 entries, same list). The stale `83`-entry figure is contradicted and is not cited.
