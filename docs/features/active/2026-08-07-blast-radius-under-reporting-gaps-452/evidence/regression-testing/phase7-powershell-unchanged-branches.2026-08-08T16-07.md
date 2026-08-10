# [P7-T5] PowerShell branches that must not change

Timestamp: 2026-08-08T16-07
Task: [P7-T5]

Two things in `.claude/lib/blast-radius/BlastRadiusGlob.psm1` must survive the Gap 2 correction
untouched: the glob-by-glob branch of `Test-EntryOverlap` (`spec.md` lines 371 and 645) and
`Test-PathSubsumed`, which already applied the anchored listed-directory rule and is the reference
the correction aligns to (`spec.md` line 648).

Baseline for comparison: `git show HEAD:.claude/lib/blast-radius/BlastRadiusGlob.psm1`.

## Glob-by-glob branch of `Test-EntryOverlap`

Command:

```
sed -n '342,345p' .claude/lib/blast-radius/BlastRadiusGlob.psm1 | md5sum
git show HEAD:.claude/lib/blast-radius/BlastRadiusGlob.psm1 | sed -n '318,321p' | md5sum
```

EXIT_CODE: 0

Pre-change, `HEAD` lines 318-321:

```powershell
    $prefixA = Get-LiteralPrefix -Entry $EntryA
    $prefixB = Get-LiteralPrefix -Entry $EntryB
    return ($prefixA.StartsWith($prefixB, [System.StringComparison]::Ordinal) -or
        $prefixB.StartsWith($prefixA, [System.StringComparison]::Ordinal))
```

Post-change, working-tree lines 342-345:

```powershell
    $prefixA = Get-LiteralPrefix -Entry $EntryA
    $prefixB = Get-LiteralPrefix -Entry $EntryB
    return ($prefixA.StartsWith($prefixB, [System.StringComparison]::Ordinal) -or
        $prefixB.StartsWith($prefixA, [System.StringComparison]::Ordinal))
```

MD5 of the four-line block, both sides: `411be947de57a6425d782bed319f84e3`. The two expressions
are identical. The line offset of 24 is the size of the [P7-T3] and [P7-T4] additions plus the
docstring correction above them; the branch text itself is unchanged.

## `Test-PathSubsumed`

The whole function was extracted by regex from both revisions and hashed.

Command:

```
pwsh -NoProfile -Command "<extract 'function Test-PathSubsumed' through its closing brace, hash MD5>"
```

EXIT_CODE: 0

| Revision | Extracted length (chars) | MD5 |
| --- | --- | --- |
| `HEAD` | 1753 | `A41C238CA0DB5E594D33D5DCBD8B1563` |
| working tree | 1753 | `A41C238CA0DB5E594D33D5DCBD8B1563` |

The bodies are identical. Behavioural confirmation:

```
Import-Module ./.claude/lib/blast-radius/BlastRadiusGlob.psm1 -Force
Test-PathSubsumed -Path 'scripts/dev_tools/x.py' -CoveringPath @('scripts/dev_tools')
True
```

## Test result

`tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1` reports
`Tests Passed: 45, Failed: 0`, including the three pre-existing glob-by-glob `It` blocks
(`'reports overlap for an undecidable pair whose literal prefixes agree'`,
`'reports no overlap when the literal prefixes diverge'`,
`'reports overlap when one literal prefix is a prefix of the other'`), none of which was modified.

Output Summary: the glob-by-glob return expression is identical pre- and post-change with matching
MD5 `411be947de57a6425d782bed319f84e3`, and `Test-PathSubsumed` is identical with matching MD5
`A41C238CA0DB5E594D33D5DCBD8B1563` over 1753 characters. `Test-PathSubsumed` still returns `True`
for `('scripts/dev_tools/x.py', @('scripts/dev_tools'))`. The Gap 2 correction touched only the
concrete-by-concrete branch and the two mixed concrete-by-glob branches.
