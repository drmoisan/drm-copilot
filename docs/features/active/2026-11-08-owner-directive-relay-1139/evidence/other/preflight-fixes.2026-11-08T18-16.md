# Preflight Fixes (final preflight pass)

Timestamp: 2026-11-08T18-16
Plan: docs/features/active/2026-11-08-owner-directive-relay-1139/plan.2026-11-08T12-32.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-08-owner-directive-relay-1139/plan.2026-11-08T12-32.md
EXIT_CODE: 0
Output Summary: The branch-current Python CLI and the installed MCP validator both passed the plan before and after the fix below. One trivial fix was made in task text. One substantive defect is reported in the preflight return and is not fixed here.

## Fix 1

- Task: [P1-T2]
- Defect class: inaccurate rationale prose (the assertion is unchanged)
- Before: the Ticks assertion carried the parenthetical "(a local-time reading differs on every non-UTC host)".
- After: "(a local reading converted to UTC, `AssumeLocal` with `AdjustToUniversal`, differs on every non-UTC host; a reading that keeps local or unspecified ticks is caught by the AST check that follows)".
- Basis: a SCRATCH probe on an Eastern Standard Time host parsed the zone-less `2026-11-08T10:00:00` with the invariant culture. A plain parse (Kind Unspecified) and an `AssumeLocal` parse (Kind Local) both returned Ticks equal to the UTC reading. Only a reading converted to UTC shifts the ticks. The Ticks assertion and the AST style check are unchanged.

## Substantive defect reported (not fixed)

- Task: [P1-T1], [P1-T2], [P2-T1]
- In the same SCRATCH probe, `ConvertFrom-Json` accepted text containing `NaN` and a single-quoted string. `JsonDocument.Parse` with `CommentHandling` `Skip` and `AllowTrailingCommas` rejected that text. As planned, the module throws `OWNER_DIRECTIVE_UNEVALUABLE:` for such text even when it holds neither owner key, and the hook blocks it for every artifact type. This contradicts the spec rule that a checkpoint without either key validates exactly as before, and the spec AC that requires an empty array for a checkpoint with neither key.
