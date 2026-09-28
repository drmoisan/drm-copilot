# Policy-surface and settings exclusion verified against FAS — issue #598

Timestamp: 2026-08-30T02-31
Task: [P10-T9]

Ref values substituted from `evidence/baseline/git-postmerge-baseline.2026-08-29T23-10.md`, written
by `[P0-T11]`: `BaseRef:` `main`, `PreMergeRef:`
`6942dee8e10720693d55ccb5f121b2446862d6f8`, `MergeRef:` `f4d4f958808a5a420f11189f6fa02ee007a66525`.

The pathspec used by the first two commands, four paths:

```
.claude/rules
.github/instructions
scripts/powershell/PoshQC/settings/pssa.settings.psd1
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

Command:
1. `git diff --name-only main...6942dee8e10720693d55ccb5f121b2446862d6f8 -- <that pathspec>`
2. `git diff --name-only f4d4f958808a5a420f11189f6fa02ee007a66525..HEAD -- <that pathspec>`
3. `git status --porcelain`

EXIT_CODE: 0

All three commands exited 0.

Output Summary:

Command 1 (`FAS` span 1) printed no line. Output is empty.

Command 2 (`FAS` span 2) printed no line. Output is empty.

Command 3 (`FAS` span 3) printed the 10 entries reproduced verbatim in
`evidence/qa-gates/final-feature-c-exclusion.2026-08-30T02-30.md`, all of which are this feature's
own plan file and its Phase 9 and Phase 10 evidence artifacts under
`docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/`. Filtering that
output for the four excluded scopes with the pattern
`\.claude/rules/|\.github/instructions/|pssa\.settings\.psd1|pester\.runsettings\.psd1` returned no
line and exit status 1, which is the no-match status. No porcelain entry names a path under
`.claude/rules/` or `.github/instructions/`, and neither settings file appears.

## What this establishes

This is the assertion that keeps `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
unmodified. That file is listed in `spec.md` under "Out of scope / non-goals", and its
`CodeCoverage.Path` list omits `.claude/lib/requirements/GeneratedDocumentCounters.psm1`. Adding the
missing entry would have brought the 28th module into the coverage denominator, but it would also
have modified a file this criterion requires to be untouched. The coverage gap is therefore recorded
by `[P0-T18]`, `[P10-T5]`, and `[P10-T12]` rather than remedied here.

The exclusion also confirms that no policy document under `.claude/rules/` or `.github/instructions/`
was edited by this feature, which those files' own standing prohibition requires.

## Acceptance evaluation

- Both diff outputs are empty.
- The porcelain output names no path under `.claude/rules/` or under `.github/instructions/`, and
  names neither `scripts/powershell/PoshQC/settings/pssa.settings.psd1` nor
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

Both acceptance conditions hold.
