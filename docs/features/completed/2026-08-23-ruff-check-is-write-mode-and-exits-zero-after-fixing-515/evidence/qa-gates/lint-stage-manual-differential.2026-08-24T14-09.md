# QA Gate — Lint Stage Manual Differential on Scratch Inputs (P3-T4)

Timestamp: 2026-08-24T14-09

Task: [P3-T4]
Issue: #515
Tree state: post-change. The Phase 2 deletion has been applied.

ExpectedExitCode: 1

Both invocations recorded below are expected to exit non-zero, because each scratch input
carries a real violation. The declared expectation applies to both.

Command (1, unfixable input): `poetry run ruff check "<scratch>/unfixable_violation.py"`
Command (2, fixable input): `poetry run ruff check "<scratch>/fixable_violation.py"`

EXIT_CODE (1, unfixable input): 1
EXIT_CODE (2, fixable input): 1

Both commands were run with the current working directory set to the repository worktree
root, `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a046a08b20e685723`.

`<scratch>` denotes the scratch directory
`C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-23T20-24/52ac2030-ba56-47de-a115-b912d0d4409c/scratchpad/ruff-differential`,
which is outside the repository working tree. No repository file is written by this task,
so the no-temporary-files-in-tests rule is not engaged: this differential is manual QA-gate
evidence, not a committed test.

## Why the working directory matters

The two scratch files have no ancestor linter configuration, so the linter reaches the
repository's `[tool.ruff]` table only through its working-directory fallback. Run from any
other directory it would resolve its built-in defaults, where fix mode is already off, and
the differential would stop discriminating between the pre-change and post-change
configuration.

That the fallback resolved as intended was confirmed rather than assumed, via
`poetry run ruff check --show-settings` on the fixable input from the same working
directory:

```text
Resolved settings for: ".../scratchpad/ruff-differential/fixable_violation.py"
Settings path: "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a046a08b20e685723\pyproject.toml"

# General Settings
cache_dir = "C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a046a08b20e685723\.ruff_cache"
fix = false
fix_only = false
output_format = full
show_fixes = true
unsafe_fixes = hint
```

`Settings path` is the repository's own `pyproject.toml`, and the resolved settings are
`fix = false` with `show_fixes = true` — precisely the post-change configuration this plan
produces. The differential therefore exercises the repository configuration and is
discriminating. Before the Phase 2 deletion the same resolution would have yielded
`fix = true`.

## Scratch input 1 — UNFIXABLE violation (F821, undefined name)

Content:

```python
"""Scratch input carrying an UNFIXABLE violation (F821, undefined name)."""

value = undefined_name_that_does_not_exist
```

Verbatim linter output:

```text
F821 Undefined name `undefined_name_that_does_not_exist`
 --> .../scratchpad/ruff-differential/unfixable_violation.py:3:9
  |
1 | """Scratch input carrying an UNFIXABLE violation (F821, undefined name)."""
2 |
3 | value = undefined_name_that_does_not_exist
  |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  |

Found 1 error.
```

Exit code: **1**. The finding carries no `[*]` marker, correctly reflecting that F821 is
not auto-fixable. This satisfies the first half of the manual verification required by
`issue.md` line 98: the lint stage still *fails* on an unfixable violation.

## Scratch input 2 — FIXABLE violation (F401, unused import)

Content:

```python
"""Scratch input carrying a FIXABLE violation (F401, unused import)."""

import os

x = 1
```

Verbatim linter output:

```text
F401 [*] `os` imported but unused
 --> .../scratchpad/ruff-differential/fixable_violation.py:3:8
  |
1 | """Scratch input carrying a FIXABLE violation (F401, unused import)."""
2 |
3 | import os
  |        ^^
4 |
5 | x = 1
  |

help: Remove unused import: `os`

Found 1 error.
[*] 1 fixable with the `--fix` option.
```

Exit code: **1**.

Two properties of this output are the point of the gate:

1. **The `[*]` fixable marker is printed on the finding** (`F401 [*] \`os\` imported but
   unused`), and the summary reads `[*] 1 fixable with the \`--fix\` option.` This is a
   *fixable-count* line, not a *fixed-count* line.
2. **There is no `Fixed 1 error:` line and no `(1 fixed, 0 remaining)` summary.** Compare
   the pre-change behaviour recorded verbatim in the spec's **Actual** section, where the
   same input produced `Fixed 1 error:` followed by `Found 1 error (1 fixed, 0 remaining).`
   and exit code 0.

This satisfies the second half of the manual verification required by `issue.md` line 98:
the stage still reports fixable violations rather than hiding them. A change that made the
stage silent on real findings would be worse than the defect, and this output demonstrates
that did not happen — `show-fixes = true` was retained, so the fixability information is
still surfaced, now as a report instead of as a silent rewrite.

## File hashes — before and after

| File | Before (SHA-256) | After (SHA-256) | Identical |
| --- | --- | --- | --- |
| `unfixable_violation.py` | `b192dbe69925f9ca8c01af95ae78f6da7b169331fc806b99e3a8e645fb2adcb2` | `b192dbe69925f9ca8c01af95ae78f6da7b169331fc806b99e3a8e645fb2adcb2` | **yes** |
| `fixable_violation.py` | `081cb2d8a45a0102deaa49d9ce088ceb2531fff060531d5e75a8c8b52427fe2f` | `081cb2d8a45a0102deaa49d9ce088ceb2531fff060531d5e75a8c8b52427fe2f` | **yes** |

All four hashes are recorded above; the before/after pair matches for each file.

Corroborating content read of the fixable input taken after the run, confirming the
`import os` line was not deleted:

```python
"""Scratch input carrying a FIXABLE violation (F401, unused import)."""

import os

x = 1
```

The rewrite was ruled out by comparing file content and hash before and after, not
inferred from the absence of a "Fixed" line in the output — the same method the issue
author used to establish the defect in the first place.

Output Summary: **Both runs exit non-zero (1 and 1), as declared by `ExpectedExitCode: 1`.
The unfixable input (F821) is reported without a `[*]` marker and the stage fails on it.
The fixable input (F401) is reported WITH the `[*]` fixable marker and a
`[*] 1 fixable with the \`--fix\` option.` summary — a fixable-count line, not a fixed-count
line — and no `Fixed 1 error:` line appears. Both before hashes equal both after hashes:
`b192dbe6...adcb2` for `unfixable_violation.py` and `081cb2d8...27fe2f` for
`fixable_violation.py`, so neither input was modified.** Settings resolution was confirmed
to come from the repository `pyproject.toml` with `fix = false` and `show_fixes = true`,
establishing that the differential exercised the post-change repository configuration
rather than the linter's built-in defaults. This satisfies spec acceptance criterion 9.
