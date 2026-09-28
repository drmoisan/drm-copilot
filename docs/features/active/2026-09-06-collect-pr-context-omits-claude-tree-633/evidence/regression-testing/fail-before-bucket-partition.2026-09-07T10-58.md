Timestamp: 2026-09-07T10-58

Command: cd extensions/drm-copilot && node run-jest.cjs --testPathPatterns=test/lib/pr-context/collector-core.test.ts --testNamePattern="routes previously-dropped paths into bucketDocs"

EXIT_CODE: 1

Output Summary:
FAIL test/lib/pr-context/collector-core.test.ts
  collectPrContext classification and buckets > routes previously-dropped paths into
  bucketDocs (fail-before: current code drops them)

  expect(received).toContain(expected)
  Expected value: ".claude/skills/example/SKILL.md"
  Received array: ["docs/features/active/2025-12-18-docs-v3-upgrade/spec.md"]

Tests: 1 failed, 5 skipped, 6 total.

This confirms the pre-fix bucket-partition loop in collector-core.ts silently drops
`.claude/skills/example/SKILL.md` and `src/example.ts` from bucketDocs (and, by the same
mechanism, from bucketCore and bucketRenames), because neither path matches the rename,
`.py`/`.ps1`, or `docs/`/`.github`/`AGENTS` predicates. This is the fail-before evidence
required by AC2.
