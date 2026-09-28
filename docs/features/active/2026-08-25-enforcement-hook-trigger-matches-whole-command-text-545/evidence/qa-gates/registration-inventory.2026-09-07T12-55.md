# Registration inventory — the fourteen parser entries across five registry files

Timestamp: 2026-09-07T12-55

Task: [P4-T12]

Command: `python <scratchpad>/manifest_check.py` for the two pack manifests and
`python <scratchpad>/coverage_list.py <path>` for each `pester.runsettings.psd1` copy, plus
`grep -n 'SharedModuleNames' tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: the entry counts below are derived by parsing each registry file rather than
by a PowerShell one-liner, because `pwsh` is not invocable in this session. The two pack manifests are
parsed with `json.load`, which is a full parse and therefore also establishes the "parses as valid
JSON" half of the [P4-T7] and [P4-T8] acceptance conditions. The two `.psd1` copies are parsed by a
purpose-written scanner that tracks single-quoted spans, double-quoted spans, and line comments, and
extracts one entry per single-quoted literal inside the `CodeCoverage.Path` array; the same scanner
reports the file's final brace and paren depth, which is the structural half of the "parses as a
PowerShell data file" condition. The limits of that substitution are stated in the psd1 section below.

## The fourteen parser registration entries

Two parser files exist in four locations each, and each sibling carries seven registration entries, so
the pair totals fourteen entries across exactly five registry files.

### Registry file 1 of 5 — `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (2 entries)

Added inside the existing `.claude/hooks/**` block, in the block's alphabetical position between
`".claude/hooks/enforce-promotion-mcp-only.ps1"` and `".claude/hooks/persist-session-id.ps1"`:

| # | Entry | Occurrences |
| --- | --- | --- |
| 1 | `".claude/hooks/hook-command-invocation.ps1"` | 1 |
| 2 | `".claude/hooks/hook-command-scanner.ps1"` | 1 |

File parses as valid JSON. Total `paths` entries after the edit: **165**.

### Registry file 2 of 5 — `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (2 entries)

Added inside the existing `.codex/hooks/**` block, between
`".codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1"` and
`".codex/hooks/record-subagent-routing-attestation.ps1"`:

| # | Entry | Occurrences |
| --- | --- | --- |
| 3 | `".codex/hooks/hook-command-invocation.ps1"` | 1 |
| 4 | `".codex/hooks/hook-command-scanner.ps1"` | 1 |

File parses as valid JSON. Total `paths` entries after the edit: **94**.

### Registry file 3 of 5 — `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (2 array members)

The `$script:SharedModuleNames` array on line 30, edited on that single line with no new line added:

| # | Array member | Occurrences |
| --- | --- | --- |
| 5 | `'hook-command-scanner.ps1'` | 1 |
| 6 | `'hook-command-invocation.ps1'` | 1 |

The array now holds **four** members: `codex-pretooluse-file-mapping.ps1`,
`enforce-orchestration-preimplementation-gate-helpers.ps1`, `hook-command-scanner.ps1`, and
`hook-command-invocation.ps1`. Membership routes both new files into `$script:StaticCheckNames`, which
is the list the suite's parse, 500-line-cap, and root-versus-bundle byte-identity legs iterate, while
deliberately keeping them out of the stdin-read assertion and the process-level invocation loops —
correct, because both files define functions only and are never executed as a hook process.

The file measures **494** lines before and after the edit, and
`git diff --stat origin/epic/cleanup-merged-worktrees-hardening-integration -- <that path>` reports
`1 insertion(+), 1 deletion(-)`, confirming a single-line replacement.

### Registry file 4 of 5 — `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (4 entries)

| # | Entry | Occurrences |
| --- | --- | --- |
| 7 | `'.claude/hooks/hook-command-scanner.ps1'` | 1 |
| 8 | `'.claude/hooks/hook-command-invocation.ps1'` | 1 |
| 9 | `'.codex/hooks/hook-command-scanner.ps1'` | 1 |
| 10 | `'.codex/hooks/hook-command-invocation.ps1'` | 1 |

### Registry file 5 of 5 — `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (4 entries)

| # | Entry | Occurrences |
| --- | --- | --- |
| 11 | `'.claude/hooks/hook-command-scanner.ps1'` | 1 |
| 12 | `'.claude/hooks/hook-command-invocation.ps1'` | 1 |
| 13 | `'.codex/hooks/hook-command-scanner.ps1'` | 1 |
| 14 | `'.codex/hooks/hook-command-invocation.ps1'` | 1 |

**Parser total: 14 entries, grouped under exactly 5 registry file paths.** No sixth registry file was
touched, and no third parser file exists, so no third registration set is owed.

## Separately counted: coverage entries added for pre-existing files

These are NOT parser registrations. They are the in-scope canonical production files that the [P0-T9]
baseline recorded with the literal entry `absent from CodeCoverage.Path at baseline`, added by
[P4-T10] in the same edit so that every file this change modifies sits inside the coverage denominator.
The set was re-derived from the [P0-T9] artifact by searching it for that literal, which returned four
rows, rather than taken from the plan's illustrative sentence.

| # | Entry | In each runsettings copy |
| --- | --- | --- |
| 1 | `'.codex/hooks/enforce-promotion-mcp-only.ps1'` | 1 |
| 2 | `'.codex/hooks/enforce-epic-merge-gate.ps1'` | 1 |
| 3 | `'.codex/hooks/enforce-epic-worktree-removal-gate.ps1'` | 1 |
| 4 | `'.codex/hooks/validate-bash.ps1'` | 1 |

**Pre-existing-file coverage total: 4 entries per runsettings copy, 8 across the two copies.**

## CodeCoverage.Path arithmetic, both copies

| Measure | `scripts/...` | `extensions/.../resources/...` |
| --- | --- | --- |
| Total entries after the edit | **97** | **97** |
| Distinct entries after the edit | **96** | **96** |
| Duplicate list | `.claude/hooks/enforce-pr-author-skill.ps1` | `.claude/hooks/enforce-pr-author-skill.ps1` |
| Entries under `extensions/drm-copilot/resources/` | **0** | **0** |
| Final brace depth / paren depth | 0 / 0 | 0 / 0 |

The [P0-T8] baseline recorded **89 total, 88 distinct**, with that same single pre-existing duplicate.
89 + 8 = 97 and 88 + 8 = 96, so exactly eight entries were added to each copy — four parser and four
pre-existing-file — and none was added twice. The pre-existing duplicate is carried unchanged; this
change neither introduces nor repairs it.

The zero count under `extensions/drm-copilot/resources/` is asserted rather than assumed, because it
is the premise of the standing rule that every bundle mirror is outside the coverage denominator and
is guarded by content or hash parity instead of by a coverage row.

### What the psd1 substitution does and does not establish

It establishes that both files are structurally balanced — every quoted span closes, and brace and
paren depth both return to zero exactly at end of file — and that each asserted literal is present
exactly once inside the `CodeCoverage.Path` array. It does **not** execute
`Import-PowerShellDataFile`, so it does not establish that the restricted-language subset accepts every
construct in the file. The residual risk is small and bounded: the [P4-T10] and [P4-T11] edits added
only comment lines and single-quoted string elements inside an array literal that already contained
89 elements of exactly that shape, so no new construct was introduced. The stronger check available in
this session is the text-parity assertion below, which pins the two copies to each other.

## Both runsettings copies are pinned text-identical

Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

Result: **1 passed, 0 failed** in 0.05s. `POSHQC_PARITY_PATHS` includes
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and
`test_poshqc_bundled_module_files_match_repo_root_sources` compares the repo-root and bundled texts
read as UTF-8, so a zero-failure result is the assertion that pins the two copies to exact text
equality. This is the [P4-T11] acceptance condition and it is met.

Independently, both copies carry SHA-256 `bcaebfb014f569ecf116b21ad936296eb024c209e304c188e2bc89d7244ddf91`,
which is stronger than text equality since it also fixes the byte encoding and line endings. Each
measures **274** lines.

Output Summary: **14** parser registration entries are in place across exactly **5** registry files —
2 in the Claude pack manifest, 2 in the Codex pack manifest, 2 array members in
`$script:SharedModuleNames`, 4 in the repository runsettings, and 4 in the bundled runsettings — each
entry appearing exactly once. Separately, **4** coverage entries per runsettings copy (**8** total)
were added for the pre-existing Codex canonical files the [P0-T9] baseline recorded as absent.
`CodeCoverage.Path` moves from 89 total / 88 distinct at baseline to **97 total / 96 distinct** in both
copies, an addition of exactly 8 with no new duplicate. Both pack manifests parse as valid JSON, both
psd1 copies are structurally balanced at depth 0/0, and
`tests/scripts/dev_tools/test_poshqc_bundled_parity.py` reports **1 passed, 0 failed**.
