# Phase 0 Instructions Read — Remediation Cycle 1 (Issue #441)

Timestamp: 2026-08-08T19-11

Policy Order: the reading order prescribed by `[P0-T1]` of `remediation-plan.2026-08-08T18-20.md`, which follows `.claude/skills/policy-compliance-order/SKILL.md`:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/self-explanatory-code-commenting.md`
7. `.claude/rules/tonality.md`
8. `.claude/rules/quality-tiers.md`
9. `.claude/rules/parallel-orchestration.md`

## Files Read

| # | Path | Read | Method |
| --- | --- | --- | --- |
| 1 | `CLAUDE.md` | yes | preloaded standing instructions (session context) |
| 2 | `.claude/rules/general-code-change.md` | yes | preloaded path-scoped rule (session context) |
| 3 | `.claude/rules/general-unit-test.md` | yes | preloaded path-scoped rule (session context) |
| 4 | `.claude/rules/python.md` | yes | `Read` tool, this session |
| 5 | `.claude/rules/python-suppressions.md` | yes | `Read` tool, this session |
| 6 | `.claude/rules/self-explanatory-code-commenting.md` | yes | `Read` tool, this session |
| 7 | `.claude/rules/tonality.md` | yes | preloaded path-scoped rule (session context) |
| 8 | `.claude/rules/quality-tiers.md` | yes | preloaded path-scoped rule (session context) |
| 9 | `.claude/rules/parallel-orchestration.md` | yes | preloaded path-scoped rule (session context) |

All nine files were read before any edit in this remediation cycle.

## Constraints Extracted That Bind This Cycle

- Python toolchain order is Black -> Ruff -> Pyright -> Pytest, restarting from step 1 on any failure or file change (`.claude/rules/python.md`).
- Coverage floors are uniform: line >= 85%, branch >= 75%; changed-line regression is Blocking (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`).
- No file may exceed 500 lines, test code included (`.claude/rules/general-code-change.md`). This forces the R-03 module split recorded in `[P0-T12]`.
- No new `# noqa` and no new `# type: ignore` without a pre-authorized pattern; none of the pre-authorized patterns applies to this cycle's work (`.claude/rules/python-suppressions.md`).
- Every function requires a Google-style docstring; every loop and comprehension requires an intent comment; every non-trivial branch requires a decision-logic comment (`.claude/rules/self-explanatory-code-commenting.md`).
- Test files live under `tests/` mirroring the source tree; temporary files in tests are prohibited (`.claude/rules/general-unit-test.md`).
- The nine parallel-surface enums are F3-owned and must not be extended; no JSON Schema file may be authored or read for the parallel artifacts (`.claude/rules/parallel-orchestration.md`).
- Tone is professional, factual, neutral; no hyperbole, humor, or metaphor (`.claude/rules/tonality.md`, `CLAUDE.md`).
