# Preflight Fixes - Issue #1233 (round 2)

Timestamp: 2026-11-24T05-06
Plan: .dev/active/1233-epic-child-ci-opt-out/plan.2026-11-23T22-42.md
Signal: PREFLIGHT: ALL CLEAR

## Round-one defects

1. Phase 3 pin edit inside the 0010 hunk: resolved. Entry 0014 is created in P1-T2, and P3-T2 records the pin span (last line of the `RE-BASELINED by issue #1035` paragraph through the new skill digest line) as a 0014 block. `Invoke-ProcessReductionChain` reverts entries newest-first, so the 0014 block restores the span before the 0010 hunk of `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` is reverted; `PRC-LEDGER-SUBCHAIN-HOLDS` with `-StopBefore` 0010 also reverts 0014 first. The end-state check keeps the oldest touching entry (0010) for that path.
2. Section-scoped skill-contract rows in P3-T5: resolved. The Phase 3 label rule scopes every row to a labeled unit, and P3-T5 lists rows per unit and per copy.
3. Deny rows and call-count assertions in P2-T1, P2-T2, and P2-T4: resolved. Table T, the argument-filtered call counts, the `-GitRoot` rows, and the completion-consistency rows are present.

## Fixes

Classification note: fixes 2 to 4 add rows to behavior that the same task already owns, under the same cited spec section, without changing a task, its file set, or its design. They are classified trivial on the precedent of the issue #1016 round-1 preflight (missing test row for owned behavior fixed in place). The orchestrator may review this classification.

1. `## Targeted Selections` (Set H) | selection citation aligned with the task-check rule | Set H stated "all `enforce-epic-merge-gate.*`" but listed seven of the eighteen claude-hooks suites and omitted tests that name the edited hooks. It now names every `enforce-epic-merge-gate.*` suite in `tests/scripts/claude-hooks/`, every `enforce-epic-merge-gate-*` suite in `tests/scripts/codex-hooks/`, and the tests that name an edited hook file (`hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`).
2. [P1-T1] | design-check row for owned behavior (spec `## Validator Error Strings`) | No corpus case held two strings, so the stated emission order, "string 1 returned alone", and "string 5 evaluated only when string 4 is not emitted" could break with every case passing. The non-object case now also lacks `review_mode`; the string-4 case also carries a mismatched head; two combined cases fix the order (strings 2, 3, 4 and strings 3, 5). The corpus floor of 13 is unchanged.
3. [P2-T1] (table T, repeated by P2-T2) | design-check row for owned behavior (spec `## Merge Gate`, stage L3) | Stage L3 requires the first `EXIT_CODE:` line to have value `0`; no row covered a file with no `EXIT_CODE:` line. Row added.
4. [P2-T1] (table T, repeated by P2-T2) | design-check row for owned behavior (spec `## Merge Gate`, ordinal comparisons) | PowerShell `-eq` and `-ne` compare case-insensitively, so an implementation that used them for the base, `conclusion`, the L2 head binding, or the `Head:` line would pass every row. Rows added: conclusion `Success`, an L2 review head differing only in letter case, a `Head:` value differing only in letter case, and a fallback row for a base that differs from the integration branch only in letter case.

## Validation

- MCP `validate_orchestration_artifacts` (`plan`): ok, before and after the fixes.
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`: `plan validation passed`, exit 0, before and after the fixes.

## Self-check

No fix adds, removes, or reorders a task; no fix changes a task's file set or design; the fix text uses neutral wording.
