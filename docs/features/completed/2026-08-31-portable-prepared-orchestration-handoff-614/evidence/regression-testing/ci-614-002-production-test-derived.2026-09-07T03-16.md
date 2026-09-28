# Production Test Derived Root — Green Run — [P1-T5]

Timestamp: 2026-09-07T11-25
Task: [P1-T5]

Command: `Select-String -LiteralPath extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts -Pattern 'C:/workspace' -SimpleMatch -CaseSensitive`; `npm --prefix extensions/drm-copilot run test:unit -- --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer-production.test.ts`
EXIT_CODE: 0

## Substitutions applied

The seven drive-letter literals recorded by [P0-T8] at pre-change lines 56, 69, 136, 216, 220, 223, and 291 were each replaced with `VIRTUAL_WORKSPACE_ROOT`. Because [P1-T2] inserted an import block and a trailing `describe` block into this file, the sites were located at their current positions 62, 75, 142, 222, 226, 229, and 297 by the identifiers named in the task: `expectedWorkspaceRoot`, the request `workspaceRoot`, the `readPorcelainStatus` argument, the `resolveWorkspaceRoot` argument, the `canonicalRoot` assertion, the `mockStatSync` call assertion, and the `rev-parse --show-toplevel` observation.

Two of those lines exceeded the 80-character print width after substitution, because `VIRTUAL_WORKSPACE_ROOT` is eight characters wider than the quoted literal. Prettier's canonical form for both was applied in this task rather than left for [P2-T1]: the `readPorcelainStatus` call and the `resolveWorkspaceRoot` call were each broken onto three lines with the argument on its own line. `npx prettier --check` on the file then reported "All matched files use Prettier code style!", so [P2-T1] will not rewrite it.

## Why the assertions still hold

The identity `realpath` mock installed in each `beforeEach` and the `isDirectory` stub keep `resolveWorkspaceRoot` returning the derived root unchanged, so the `canonicalRoot` assertion and the `mockStatSync` call assertion name exactly the value the boundary computes, on either platform.

## Results

- `C:/workspace` case-sensitive match count: 0 (required: 0)
- File line count: 423 (pre-[P1-T2] 371; within the 500-line limit)

## Test run (verbatim)

```
Test Suites: 1 passed, 1 total
Tests:       18 passed, 18 total
Snapshots:   0 total
```

Output Summary: All seven recorded literals were replaced with the derived root, bringing the case-sensitive `C:/workspace` count in this file to 0. The suite exits 0 with `Tests: 18 passed, 18 total` and 0 failed, which turns the [P1-T2] red run green: the case `registers only paths under the derived absolute workspace root` now passes because the scenario request root, the envelope binding root, and every registered filesystem key are derived from `path.resolve` rather than written as a drive-letter literal.
