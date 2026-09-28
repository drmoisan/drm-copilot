# TypeScript Producer/Consumer Seam Test Run

Timestamp: 2026-08-08T15-25

Task: [P4-T9]
Working directory: repository root

Command: `node run-jest.cjs --runTestsByPath extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts`

EXIT_CODE: 0

Output Summary: PASS. 1 test suite passed of 1 total; 8 tests passed of 8 total; 0 snapshots; runtime 0.396s. The new module binds the PRODUCER (`.claude/skills/parallel-plan/SKILL.md`, resolved from `__dirname` five levels up to the repository root) to the CONSUMER (`extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts`). The two seam tests required by [P4-T5] and [P4-T6] are:

- `validates the rendered template with the ## Integrity section` — the with-`## Integrity` seam test
- `validates the rendered template without the ## Integrity section` — the without-`## Integrity` seam test

## Raw Output

```
Test Suites: 1 passed, 1 total
Tests:       8 passed, 8 total
Snapshots:   0 total
Time:        0.396 s, estimated 1 s
Ran all test suites within paths "extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts".
```

## Full Test Inventory

All eight tests live under the describe block `parallel kickoff template seam (real canonical skill file)`.

| Test | Plan task |
|---|---|
| `extracts the documented kickoff block rather than another fenced block` | [P4-T4] extraction guard |
| `validates the rendered template with the ## Integrity section` | [P4-T5] with-`## Integrity` seam |
| `validates the rendered template without the ## Integrity section` | [P4-T6] without-`## Integrity` seam |
| `captures planningCommit from the rendered integrity section` | [P4-T7] provenance capture (pins B2) |
| `accepts the documented resume-boundary alternant Every item` | [P4-T8] alternant 1 |
| `accepts the documented resume-boundary alternant Each item` | [P4-T8] alternant 2 |
| `accepts the documented resume-boundary alternant items` | [P4-T8] alternant 3, plural verb form |
| `rejects an undocumented resume-boundary subject` | [P4-T8] negative case (`Each entry`) |

## No External Process

The module imports only `@jest/globals`, `node:fs`, `node:path`, and the production module under test. It imports no child-process API and spawns no external process; the Python runtime is never invoked. The negative resume-boundary spelling `Each entry` is byte-identical to the one used in the Python seam module's `test_resume_boundary_rejects_an_undocumented_subject`, so both runtimes exercise the same non-matching input, and the transcribed error literal is asserted character-for-character against the Python literal.
