# File Line Counts — [P4-T8]

Timestamp: 2026-08-26T14-48

Command: `wc -l <each path below>` (issued as two invocations from the worktree root, one for
source and configuration, one for tests)

EXIT_CODE: 0

## Scope

`.claude/rules/general-code-change.md` sets a hard limit: no production code, test code, or
reusable script file may exceed 500 lines. Markdown documentation is explicitly exempt, so the
plan document, the specification, and the evidence artifacts are recorded separately below and
are not subject to the limit. Every count is the `wc -l` value taken after the formatting stage
of both toolchains, so no later format pass can change it.

`extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` is included by explicit
instruction of this task even though it is unmodified by this change: at 437 lines it is the
file closest to the cap, and it is the reason the new rules were given their own module rather
than being appended to it.

## Python source

| File | Lines | Disposition |
| --- | ---: | --- |
| `scripts/dev_tools/plan_gate_observability.py` | 477 | created (Phase 2) |
| `scripts/dev_tools/plan_gate_commands.py` | 365 | modified (Phase 1) |
| `scripts/dev_tools/plan_gate_discrimination.py` | 392 | modified (Phase 2) |

## TypeScript source

| File | Lines | Disposition |
| --- | ---: | --- |
| `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` | 494 | created (Phase 3) |
| `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` | 443 | modified (Phase 1) |
| `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` | 284 | modified (Phase 3) |
| `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` | 437 | unmodified, recorded by instruction |

## Python tests

| File | Lines | Disposition |
| --- | ---: | --- |
| `tests/scripts/dev_tools/test_plan_gate_observability.py` | 427 | created (Phase 1, extended Phase 2) |
| `tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py` | 333 | created (Phase 2) |
| `tests/scripts/dev_tools/test_plan_gate_parity.py` | 493 | modified (Phase 4) |
| `tests/scripts/dev_tools/test_plan_gate_commands.py` | 297 | modified (Phase 1) |
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py` | 449 | modified (Phase 4) |

## TypeScript tests

| File | Lines | Disposition |
| --- | ---: | --- |
| `extensions/drm-copilot/test/lib/validate/plan-gate-observability.test.ts` | 394 | created (Phase 3) |
| `extensions/drm-copilot/test/lib/validate/plan-gate-observability-boundaries.test.ts` | 327 | created (Phase 3) |
| `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts` | 389 | modified (Phase 4) |
| `extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts` | 245 | modified (Phase 1) |
| `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts` | 274 | modified (Phase 3) |

## Configuration

| File | Lines | Disposition |
| --- | ---: | --- |
| `extensions/drm-copilot/jest.config.cjs` | 245 | modified (Phase 3) |

## Two counts that moved during this task, recorded because the limit was live

Two files were reduced during [P4-T8] because the recorded count would otherwise have breached
or sat exactly on the limit. Both reductions removed comment and docstring text only; no
assertion, no finding string, and no predicate changed, and both toolchains were re-run to a
clean pass afterwards.

1. `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` measured **587** lines
   when first counted, which exceeds the 500-line hard limit. The JSDoc blocks on the small
   helpers were condensed to one- and two-line forms and the substantive rationale was retained
   in full. The file now measures **494**. Splitting the module was rejected: the plan fixes the
   file set and states its one authorized split (the twenty-eight test cases across two files)
   explicitly, so adding a second source module would have been an unplanned outcome. After the
   reduction the TypeScript suite reports 2708 passed / 0 failed and the module's coverage row
   reads 98.38 line / 91.91 branch, both above their thresholds.
2. `tests/scripts/dev_tools/test_plan_gate_parity.py` measured **500** lines, which satisfies
   "at most 500" but leaves no headroom for any later edit. One docstring added by [P4-T2] was
   condensed, bringing the file to **493**. The suite still reports 9 passed / 0 failed.

One further count moved after this artifact was first written: the [P4-T9] fixture repair added
seven lines to `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`
(one wrapped acceptance line plus a six-line explanatory comment), taking it from 442 to
**449**. The table above records the post-repair value, which is the value that stands at the
end of Phase 4.

## Markdown documentation (exempt from the 500-line limit)

Recorded for completeness. Counts are as of this task; Phase 5 through Phase 8 append to
several of them.

| File | Lines |
| --- | ---: |
| `docs/features/.../519/plan.2026-08-23T23-22.md` | 306 |
| `docs/features/.../519/spec.md` | 399 |
| `docs/features/.../519/issue.md` | 95 |
| `docs/features/.../519/research/2026-08-23T23-45-...-research.md` | 470 |

Evidence artifacts under the four canonical `evidence/` kind folders are Markdown and are
likewise exempt; each is well under 500 lines.

## Output Summary

Every recorded count for a production, test, or reusable-script file is **at most 500**. The
largest is `tests/scripts/dev_tools/test_plan_gate_parity.py` at 493, followed by
`extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` at 494 and
`scripts/dev_tools/plan_gate_observability.py` at 477. `plan-gate-rules.ts` is unmodified at
437. No file breaches the limit.
