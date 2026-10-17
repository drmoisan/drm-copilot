# Fail-Before: TypeScript start-guard matrix

Timestamp: 2026-09-30T10-33

Plan task: [P1-T6] [expect-fail]

Command: npm test --prefix extensions/drm-copilot -- test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary: Run against the unchanged production code (before [P1-T9]). 16 tests declared; 14 failed, 2 passed. Passing titles: `has fourteen uniquely named cases` and `start-guard matrix case dependencies-merged-before-start` (the two titles absent from the failure list of the 16). Matches the [P1-T6] acceptance.

## Tests line (verbatim)

```text
Test Suites: 1 failed, 1 total
Tests:       14 failed, 2 passed, 16 total
```

## Failing test titles

```text
epic wave-barrier start guard › start-guard matrix case unstarted-dependent-unmerged-dependency
epic wave-barrier start guard › start-guard matrix case unstarted-dependent-null-timestamp
epic wave-barrier start guard › start-guard matrix case started-by-status-unmerged-dependency
epic wave-barrier start guard › start-guard matrix case merge-status-absent-treated-as-started
epic wave-barrier start guard › start-guard matrix case merge-status-null-treated-as-started
epic wave-barrier start guard › start-guard matrix case not-started-with-timestamp-treated-as-started
epic wave-barrier start guard › start-guard matrix case dependency-merge-status-absent
epic wave-barrier start guard › start-guard matrix case two-unmerged-dependencies-in-order
epic wave-barrier start guard › start-guard matrix case merged-dependency-confirmed-after-start
epic wave-barrier start guard › start-guard matrix case status-and-timing-on-one-edge
epic wave-barrier start guard › start-guard matrix case integer-issue-number-reference
epic wave-barrier start guard › start-guard matrix case epic-678-checkpoint-shape
epic wave-barrier start guard › start-guard matrix case kickoff-all-not-started
epic wave-barrier start guard › reports a list-valued dependency merge_status as not merged
```

## Passing test titles (derived: the 16 declared titles minus the 14 failing titles)

- `has fourteen uniquely named cases`
- `start-guard matrix case dependencies-merged-before-start`

## Acceptance evaluation

| Condition | Observed | Met |
|---|---|---|
| EXIT_CODE 1 | 1 | yes |
| `Tests:` contains `14 failed, 2 passed, 16 total` | `14 failed, 2 passed, 16 total` | yes |
| Failing titles include `start-guard matrix case unstarted-dependent-unmerged-dependency` and `start-guard matrix case kickoff-all-not-started` | both present | yes |
| Passing titles are `has fourteen uniquely named cases` and `start-guard matrix case dependencies-merged-before-start` | yes | yes |
