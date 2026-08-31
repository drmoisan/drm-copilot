# Baseline — TypeScript Test and Coverage (`npm run test:coverage`)

Timestamp: 2026-08-30T06-22
Task: [P0-T12]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `npm run test:coverage` (run from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary:

- **Jest `Tests:` line, verbatim:** `Tests:       2734 passed, 2734 total`
- **Test Suites:** 203 passed, 203 total. Snapshots: 0 total. Time: 8.64 s. Ran all test suites.
- **The four `text-summary` percentages:**

| Metric | Percent | Covered / Total |
| --- | --- | --- |
| Statements | **96.72%** | 44234/45730 |
| Branches | **90.17%** | 6297/6983 |
| Functions | **89.93%** | 1295/1440 |
| Lines | **96.72%** | 44234/45730 |

The `text-summary` reporter block, verbatim:

```
=============================== Coverage summary ===============================
Statements   : 96.72% ( 44234/45730 )
Branches     : 90.17% ( 6297/6983 )
Functions    : 89.93% ( 1295/1440 )
Lines        : 96.72% ( 44234/45730 )
================================================================================
```

Both uniform coverage gates from `.claude/rules/quality-tiers.md` are met at baseline: line
coverage 96.72% against the >= 85% floor, and branch coverage 90.17% against the >= 75% floor.

The wrapped command is
`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`.

## Why the Whole Suite Was Run

`extensions/drm-copilot/jest.config.cjs:17` sets `collectCoverageFrom` to
`["src/**/*.ts", "!src/**/*.d.ts"]`, and the `coverageThreshold` key at line 25 opens a per-file
threshold map. A subset run therefore reports 0% for every production file the subset does not
exercise and fails thresholds for reasons unrelated to this feature. Running the whole suite is
what makes the four percentages above a usable baseline.

## Citation Correction — the plan's `jest.config.cjs` extent is wrong by seven lines

The plan's task text for [P0-T12], and its "Corrected in the version 0.4 pass" section, both state
that the `coverageThreshold` map's closing brace is at **line 259** in a file of **260** lines.
Re-derived directly against the tree this pass, both values are incorrect:

- `extensions/drm-copilot/jest.config.cjs` is **267** lines, not 260.
- The `coverageThreshold` map's closing brace is at **line 266**, not 259.
- Line 259 is `branches: 75,`, part of the threshold entry for
  `./src/lib/potential-to-issue/potential-to-issue-service-call.ts`.

Verified correct in the same check: `collectCoverageFrom` is at line 17, and the
`coverageThreshold: {` key is at line 25.

**Impact: none on this task's acceptance.** The acceptance for [P0-T12] is the exit code, the
`Tests:` line, and the four percentages, all recorded above. The incorrect line numbers appear only
in the task's *rationale* for running the whole suite rather than a subset, and that rationale holds
regardless of the map's exact extent: a per-file threshold map keyed over `src/**/*.ts` still makes
a subset run fail for unrelated reasons.

No acceptance condition elsewhere in the plan was found to depend on the 259 or 260 values. The
correction is recorded here so a later reader does not treat the plan's figure as authoritative.
