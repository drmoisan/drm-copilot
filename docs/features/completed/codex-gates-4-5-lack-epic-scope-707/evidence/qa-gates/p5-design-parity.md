# Phase 5 Design-Parity Inspection ([P5-T8], AC-17)

Timestamp: 2026-09-27T07-22
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p5-collect (fresh PowerShell 7 process, section `T8 DESIGN PARITY`: `Select-String -SimpleMatch` over docs/features/active/codex-gates-4-5-lack-epic-scope-707/spec.md for five decision literals, and the exact heading lines `## Design Decisions` and `## Proposed Fix`)
EXIT_CODE: 0
Output Summary: Each of the five decision literals matches exactly once, at lines 66, 76, 124, 129, and 134, all between `## Design Decisions` (line 62) and `## Proposed Fix` (line 149).

| Literal | Count | Line |
| --- | --- | --- |
| `**D1 — Resolver placement.**` | 1 | 66 |
| `**D3 — Resolver scope.**` | 1 | 76 |
| `**D13 — apply_patch leg.**` | 1 | 124 |
| `**D14 — Retained pre-existing divergences.**` | 1 | 129 |
| `**D15 — PowerShell authority and no Python.**` | 1 | 134 |

| Heading | Line |
| --- | --- |
| `## Design Decisions` | 62 |
| `## Proposed Fix` | 149 |

Note: the console rendered the em dash as a hyphen when the collector output passed through the shell; the match itself was made against the em-dash literal, and a separate `grep -n -F` over the spec confirmed the same five line numbers and the two heading lines. The heading literal `## Design Decisions` also occurs inside the prose of AC-17 at line 282; the heading row above records only the line whose full text equals the heading.
