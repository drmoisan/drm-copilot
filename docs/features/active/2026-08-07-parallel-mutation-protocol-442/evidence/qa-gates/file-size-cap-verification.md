# 500-Line File Size Cap Verification ([P7-T9])

Timestamp: 2026-08-09T03-48

Task: [P7-T9] Verify the 500-line cap on every new production and test file.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
Reconciliation base: `c939b5b8`

Command: `wc -l <file>...` (run in two invocations, production/shared then test, plus one invocation for
the bundle mirror and the Markdown skills)

EXIT_CODE: 0

Rule: `.claude/rules/general-code-change.md` — "No production code, test code, or reusable script file
may exceed **500 lines**." Markdown documentation files are an explicit exception; the SKILL.md counts
below are recorded for completeness, not as cap-bearing files. The cap was not relaxed for any file.

## Scope Note — Inventory Larger Than the Plan's List

The plan's P7-T9 file list is incomplete: execution created three additional Python delegate modules and
two additional test modules beyond the planned inventory, specifically in order to keep every file under
the cap. All of them are verified below, so the cap check covers the actual delivered file set rather
than only the planned set.

## New Production Files (Python)

| File | Lines | Cap | Verdict |
| --- | --- | --- | --- |
| `scripts/dev_tools/parallel_mutation_protocol.py` (planned) | 393 | 500 | PASS (107 headroom) |
| `scripts/dev_tools/_parallel_mutation_models.py` (planned) | 450 | 500 | PASS (50 headroom) |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` (planned) | 361 | 500 | PASS (139 headroom) |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` (planned) | 313 | 500 | PASS (187 headroom) |
| `scripts/dev_tools/_parallel_mutation_errors.py` (**beyond plan inventory**) | 229 | 500 | PASS (271 headroom) |
| `scripts/dev_tools/_parallel_mutation_entries.py` (**beyond plan inventory**) | 249 | 500 | PASS (251 headroom) |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` (**beyond plan inventory**) | 289 | 500 | PASS (211 headroom) |

## New Production File (PowerShell)

| File | Lines | Cap | Verdict |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 259 | 500 | PASS (241 headroom) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` (byte-identical bundle mirror) | 259 | 500 | PASS (241 headroom) |

## Shared Pre-Existing File F6 Modified

| File | Lines at reconciliation base | Lines now | Cap | Verdict |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 336 | **338** | 500 | PASS (162 headroom) |

The +2 delta is exactly the one added import line and the one added `errors.extend(...)` call line
required by P3-T2. The file remains well under the cap.

## New Test Files

| File | Lines | Cap | Verdict |
| --- | --- | --- | --- |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` | 498 | 500 | PASS (2 headroom) |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` (**beyond plan inventory**; the P2-T8 split branch) | **500** | 500 | PASS — exactly at the cap, not over it |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` | 499 | 500 | PASS (1 headroom) |
| `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py` | 370 | 500 | PASS (130 headroom) |
| `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` (**beyond plan inventory**) | 330 | 500 | PASS (170 headroom) |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py` | 398 | 500 | PASS (102 headroom) |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutation_modes.py` (**beyond plan inventory**) | 175 | 500 | PASS (325 headroom) |
| `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` | 164 | 500 | PASS (336 headroom) |

Three of the Python test files sit within two lines of the cap (498, 500, 499). They are at the cap
because the plan mandated splitting rather than exceeding it. No file exceeds 500 lines, and no
additional content may be added to those three files without a further split.

## Pre-Existing Test Files F6 Modified (out-of-table edits, see P7-T10)

| File | Lines | Cap | Verdict |
| --- | --- | --- | --- |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 303 | 500 | PASS (197 headroom) |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | 466 | 500 | PASS (34 headroom) |

## Markdown Files (cap-exempt, recorded for completeness)

`.claude/rules/general-code-change.md` exempts Markdown documentation files from the 500-line cap.

| File | Lines | Note |
| --- | --- | --- |
| `.claude/skills/parallel-add/SKILL.md` | 122 | new (P4-T1) |
| `.claude/skills/parallel-remove/SKILL.md` | 168 | new (P4-T2) |
| `.claude/skills/parallel-close/SKILL.md` | 93 | new (P4-T3) |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 588 | pre-existing shared file, in-section append (P4-T4); Markdown, cap-exempt |

Output Summary: All 19 cap-bearing files verified with `wc -l`. **Every file is at or under 500 lines;
none exceeds the cap.** Largest production file: `_parallel_mutation_models.py` at 450. Largest test
file: `test_parallel_mutation_protocol_ops.py` at exactly 500 (at the cap, not over). The shared
`validate_parallel_orchestrator_state.py` is **338** lines (336 at the reconciliation base, +2 for the
one added import and one added call line), 162 lines under the cap. Five files beyond the plan's stated
inventory were created during execution specifically to stay under the cap and are all verified here:
`_parallel_mutation_errors.py` (229), `_parallel_mutation_entries.py` (249),
`_parallel_orchestrator_state_mode_completion.py` (289), `test_parallel_mutation_protocol_ops.py` (500),
`test_validate_parallel_orchestrator_state_mutation_modes.py` (175), plus
`test_parallel_abandon_token_seam.py` (330). The cap was not relaxed for any file and no exception was
claimed for any non-Markdown file.

Verdict: PASS.
