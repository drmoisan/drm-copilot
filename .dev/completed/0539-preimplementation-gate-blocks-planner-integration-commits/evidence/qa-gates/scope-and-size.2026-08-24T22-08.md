# Scope and Size Verification [P7-T5]

Timestamp: 2026-08-24T22-08

Merge base with `main`: `cdfd69f6b86f15601241c0ed96e99d322af9fb47`

## (a) File size — 500-line cap

Command: `grep -c '' <file>` for each in-scope file.

`grep -c ''` is used rather than `wc -l` because it counts a final line that carries no
trailing newline. The plan preamble records that the canonical Claude hook had no trailing
newline pre-change, which made `wc -l` under-report by one.

| Lines | Cap | File |
| ---: | :---: | --- |
| 382 | OK | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` |
| 349 | OK | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` |
| 382 | OK | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` |
| 349 | OK | `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` |
| 382 | OK | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` |
| 349 | OK | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` |
| 382 | OK | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` |
| 349 | OK | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` |
| 225 | OK | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| 225 | OK | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` |
| 267 | OK | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` |
| 271 | OK | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` |
| 494 | OK | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` |

All 13 files (eight production PowerShell, two runsettings, three test) are at or under 500
lines. Maximum observed: 494 (`legacy-codex-hook-contracts.Tests.ps1`, unchanged apart from the
one-line `$script:SharedModuleNames` append mandated by P5-T3).

The helper extraction is what keeps the two canonical hooks inside the cap: each hook grew from
340/336 content lines to 382, with the 349-line pathspec classifier living in its own sibling
file rather than inline.

EXIT_CODE: 0

## (b) Diff scope against the merge base

Command: `git diff --name-only cdfd69f6...HEAD`, with targeted counts.

Total changed paths: **47**.

| Prohibited class | Count | Result |
| --- | ---: | --- |
| Paths under `.github/instructions/` | 0 | compliant |
| Paths under `.claude/rules/` | 0 | compliant |
| `.py` files ADDED under `.claude/hooks/` or `.codex/hooks/` | 0 | compliant |

The third check used `--diff-filter=A` so it detects an added Python leg specifically, which is
the prohibition stated in the plan preamble and in spec AC 14.

The 47 changed paths decompose exactly into the declared scope: 4 hook copies, 4 helper copies,
4 skill Markdown files, 2 pack manifests, 2 runsettings files, 3 test files, and 28 files inside
the feature folder `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/`
(issue, spec, plan, research, and the evidence tree). No path outside that set was touched.

EXIT_CODE: 0

## (c) Trigger regex byte-unchanged

Command: `Select-String -Path <hook> -SimpleMatch -Pattern '(^|\s)git\s+(add|commit)\b'`

| Matches | Line | File |
| ---: | ---: | --- |
| 1 | 123 | `.claude\hooks\enforce-orchestration-preimplementation-gate.ps1` |
| 1 | 142 | `.codex\hooks\enforce-orchestration-preimplementation-gate.ps1` |
| 1 | 123 | `extensions\...\claude-customizations\.claude\hooks\enforce-orchestration-preimplementation-gate.ps1` |
| 1 | 142 | `extensions\...\codex-and-agents-customizations\.codex\hooks\enforce-orchestration-preimplementation-gate.ps1` |

Exactly one match per file in all four copies. The trigger regex is present and unmodified; the
whole-command-text over-match was not narrowed, as required by spec AC 14. The two Claude copies
agree on line number (123) and the two Codex copies agree on line number (142), consistent with
the content-equal and byte-identical pair contracts.

EXIT_CODE: 0

## (d) No alternative readiness source

`Test-OrchestrationReady` was extracted from both canonical hooks at the merge base and at HEAD
by a brace-depth scan from the `function Test-OrchestrationReady` declaration to its matching
close, then compared.

| Verdict | Lines old/new | SHA-256 (first 16) old/new | File |
| --- | :---: | --- | --- |
| UNCHANGED | 29 / 29 | `57e3624fd3b427eb` / `57e3624fd3b427eb` | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` |
| UNCHANGED | 29 / 29 | `57e3624fd3b427eb` / `57e3624fd3b427eb` | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` |

The function body is byte-identical before and after the change in both canonical hooks, and the
two hooks carry the identical body as each other. No hunk falls inside it, so no alternative
readiness source was added and the ready-checkpoint path is unmodified.

EXIT_CODE: 0

## Output Summary

PASS on all four parts. (a) All 13 in-scope files are at or under the 500-line cap, maximum 494.
(b) The merge-base diff touches 47 paths, none under `.github/instructions/` or `.claude/rules/`,
and adds no `.py` file under either hook directory. (c) The trigger literal matches exactly once
in each of the four hook copies, so it is present and unmodified. (d) The `Test-OrchestrationReady`
body is byte-identical across the change in both canonical hooks (29 lines, SHA-256 prefix
`57e3624fd3b427eb`), so no alternative readiness source exists. This artifact supports spec
AC 8 (helper extraction and line cap) and AC 14 (no out-of-scope changes).
