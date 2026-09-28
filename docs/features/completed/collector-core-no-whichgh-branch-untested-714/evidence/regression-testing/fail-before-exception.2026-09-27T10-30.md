Timestamp: 2026-09-27T10-30

WhyFailingRunImpossible: This is a coverage-only gap, not a behavioral defect. `collectPrContext`'s existing, unmodified production code already takes the correct branch when `whichGh` is omitted: `GhClient`'s own default resolver `() => undefined` already runs, and `hydrateAvailability()` already reports the "not installed" message. There is no pre-existing incorrect behavior for a new test to fail against, so a fail-before run of the new test would pass on the current, unmodified tree rather than fail.

Alternative proof: `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/baseline/collector-core-coverage-baseline.2026-09-27T10-30.md` records that the anchor line's `BRDA:` entry — `BRDA:136,2,0,0` — has a hit count of `0` in the Phase 0 baseline `extensions/drm-copilot/coverage/lcov.info`. That zero hit count is the substitute evidence that the coverage gap this plan addresses is real: no existing test in the suite exercises the untaken outcome of the `whichGh === undefined ? {} : { whichGh }` conditional, even though the production behavior on that path is already correct.

No fail-before test run is claimed anywhere in this plan.
