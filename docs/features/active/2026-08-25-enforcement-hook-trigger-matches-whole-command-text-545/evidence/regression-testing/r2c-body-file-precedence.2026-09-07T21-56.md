# R-2.c `--body-file`-before-`--body` routing derivation — [P3-T8]

Timestamp: 2026-09-07T21-56

Task: `[P3-T8]` — record the `--body-file` routing derivation, so the reaudit reads the R-2.c
ordering as an intentional restoration rather than a silent behaviour change.

Command: `sed -n '390,400p' docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-09-06T23-30-command-word-parser-rederivation-research.md`
(re-derivation of the base-commit flag reads against their in-tree source)

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: none required. This task is a derivation recorded from in-tree sources.
No PowerShell process, no test runner, and no external tool is involved.

## The base-commit flag reads, reproduced verbatim

At the feature-wide anchor `6dff80ed4596bec088d548b23013e6077e32c484` the two flag reads in
`.claude/hooks/enforce-pr-author-skill-helpers.ps1` were:

```powershell
$hasBodyFile = $CommandText -match '(?i)--body-file\b'
$hasInlineBody = $CommandText -match '(?i)--body(?!-file)\b'
```

In-tree source: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-09-06T23-30-command-word-parser-rederivation-research.md`,
lines 395–396, under the heading `Lines 177–178 (flag detection)`. The two lines were read back
from that file at the timestamp above and match the text quoted here character for character.

Both reads operate on `$CommandText`, the WHOLE raw command string. Neither is segment-scoped
and neither is token-based, so quoting inside the command is invisible to them.

## What changed between the two anchors, for one concrete input

Input: `bash -c "gh pr create --body-file artifacts/pr_body_545.md"`

**At the feature-wide anchor.** `-match '(?i)--body-file\b'` runs over the whole raw string. The
substring `--body-file` is present inside the wrapper's quoted argument, so the regular
expression matched and `$hasBodyFile` was set to `$true`. `$hasInlineBody` did not set, because
the negative lookahead `(?!-file)` excludes the only `--body` occurrence on the line. With
`$hasBodyFile` true the function routed past Case A and Case B to Case C, the canonical-path
check, and from there to the orchestrator-state preflight and receipt verification.

**At the cycle-scope head `26dba29533ba70f6cd80d14ac3c87ac24ca82aca`.** Both reads are
`Test-CommandLineFlag` calls against the matched segment's tokens.
`ConvertTo-CommandLineToken` collapses the wrapper's balanced quoted span into ONE token, so
neither `--body-file` nor `--body` exists as a token, and both booleans read `$false`. With
neither flag set the function falls through to Case B for `gh pr create`, and to the `gh pr
edit` no-body allow short-circuit for `gh pr edit`. The R-2.c fail-open is that second path: it
allowed `bash -c "gh pr edit 42 --body 'x'"`, which the base denied.

## Why the ordering in Edit 5 is a restoration and not a weakening

Edit 5's fallback tests `--body-file` first and only tests `--body` in the `elseif` branch. The
two states it can produce for the input above are:

- `--body-file` found in a raw-scanned segment → `$hasBodyFile = $true`, `$hasInlineBody` stays
  `$false` → Case C and receipt verification.

That is precisely the routing the feature-wide anchor produced, because a single whole-text
`--body-file` match set `$hasBodyFile` for exactly this input and the lookahead kept
`$hasInlineBody` clear. The ordering therefore restores the base routing rather than
introducing a new one.

The ordering weakens no denial that existed at the feature-wide anchor. At that anchor no input
carrying `--body-file` was ever classified as an inline body, because the `(?!-file)` lookahead
made the two flags mutually exclusive on a `--body-file` occurrence. Edit 5's `if`/`elseif`
reproduces that exclusivity structurally: within one segment, a `--body-file` match short-
circuits the `--body` test, so a `--body-file` carried inside a wrapper can never be misread as
an inline body. The reverse ordering would have been the weakening, because it would route a
wrapper-led `--body-file` into Case A and return `PR_AUTHOR_SKILL_BLOCKED` for a command the
base sent to receipt verification.

The fallback is additionally gated on `-not $hasBodyFile -and -not $hasInlineBody`, so it runs
only when the token reads found nothing at all. It cannot overturn a token-derived result, and
it cannot change the classification of any non-wrapper command.

## The two cases that pin the ordering

- **`R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case`**
  drives `bash -c "gh pr edit 42 --body-file artifacts/pr_body_545.md"` with the context
  artifact mocked absent and asserts the reason matches `PR_CONTEXT_MISSING` and does NOT match
  `PR_AUTHOR_SKILL_BLOCKED`. A reversed ordering fails this case, because it would produce the
  Case A block reason.
- **`R2c-N1 still routes a non-wrapper --body-file edit to the context check`** drives the same
  command without the wrapper and asserts the same two conditions. It pins that the fallback
  changed nothing on the non-wrapper path, where the token reads already succeed and the
  fallback never runs.

Both cases live in
`tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1`, in
`Context 'R-2.c wrapper-led body flags'`.

## Output Summary

The base-commit flag reads are reproduced verbatim from
`research/2026-09-06T23-30-command-word-parser-rederivation-research.md` lines 395–396. For
`bash -c "gh pr create --body-file artifacts/pr_body_545.md"` the feature-wide anchor set
`$hasBodyFile` and routed to Case C and receipt verification, while the cycle-scope head sets
neither flag and routes to Case B. Edit 5's `--body-file`-first ordering restores the base
routing exactly and therefore weakens no denial that existed at the feature-wide anchor.
`R2c-C2` and `R2c-N1` are the two cases that pin the ordering.
