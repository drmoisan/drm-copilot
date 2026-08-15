# blast-radius-module-map-forces-serial-runs (Issue #472)

- Date captured: 2026-08-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/blast-radius-module-map-forces-serial-runs/ (Issue #472)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #472
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/472
- Last Updated: 2026-08-15
- Work Mode: full-bug

## Summary

The blast-radius module level makes every parallel run fully serial, and the module map published to a destination repository describes drm-copilot's own governance payload rather than the destination's layout. A parallel orchestrator pushed down to a destination repository therefore cannot schedule any two items concurrently.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `derive_blast_radius` and `conflicts` from `scripts/dev_tools/compute_blast_radius.py`, read against `config/blast-radius.json`
- Data source or fixture: `config/blast-radius.json` and the published copy at `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`

## Steps to Reproduce

1. Derive a blast radius for two thematically unrelated items that share no production file. Item A cites `scripts/benchmarks/run.py`; item B cites `extensions/drm-copilot/src/lib/foo.ts`.
2. Call `conflicts(a, b, config)` with the parsed `config/blast-radius.json`.
3. Observe the verdict and reasons.
4. Separately, push the Claude customizations down into a destination repository whose source tree is not organized like drm-copilot (for example a C# solution) and inspect the destination's `config/blast-radius.json`.

## Expected Behavior

Two items that share no production file, no shared surface, and no contract identifier are non-contending and belong in the same cohort. A destination repository receives a module map that describes its own source layout, so the module level carries real contention signal there.

## Actual Behavior

Two items sharing zero production files conflict:

```
A paths   : ['docs/features/active/.../**', 'scripts/benchmarks/run.py', 'tests/benchmarks/test_run.py']
B paths   : ['docs/features/active/.../**', 'extensions/drm-copilot/src/lib/foo.ts']
CONFLICT  : True
  reason  : module_overlap -> docs
```

Because every pair conflicts, the conflict graph is complete, greedy coloring assigns one item per cohort, and the run is fully serial. A destination-repository parallel planner correctly refuses to emit a plan, reporting that `config/blast-radius.json` forces a fully serial run.

In a destination repository the published module map lists `.claude/**`, `config/**`, `docs/**`, and `tests/**`. Those are drm-copilot's governance-payload directories. None of the destination's own source directories appear, so every real source path there resolves to no module at all.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see the reproduction output under Actual Behavior.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The parallel orchestration surface cannot deliver concurrency in any repository, which is its entire purpose.

## Suspected Cause / Notes

Two distinct defects compose.

**Defect A — universal conflict from location buckets.** `derive_blast_radius` unconditionally injects each item's own feature folder into its paths (`compute_blast_radius.py:265`), because every item writes its own spec, plan, research, and evidence. The module map buckets all of `docs/**` into one module named `docs`. Every item therefore resolves module `docs`, and module overlap is a conflict disjunct (`_blast_radius_conflicts.py:167-177`). The `tests` bucket repeats the defect: repository policy requires every item's tests to live under `tests/**`.

The path level already handles this correctly — `docs/features/active/A/**` and `docs/features/active/B/**` are disjoint globs and produce no path overlap. The module level is a coarser abstraction layered on top, and for location buckets such as `docs` and `tests` it is not a coherent unit of contention; it is a directory that every module's files pass through.

**Defect B — the published default describes the wrong repository.** The module map shipped to a destination is drm-copilot's own layout with entries removed, not a generic or destination-derived map. The two defects compose badly: the module level is fail-closed on the paths carrying no signal (coupling every item into a serial run) and fail-open on the paths carrying all the signal (the destination's real source directories, which resolve to nothing).

The push-down test named `issue #462 AC8: the published blast-radius default is generic` (`extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:375`) asserts genericity and was satisfied by a non-generic document. It is the test that should have caught Defect B.

Related but distinct: issue #452 tracks blast-radius under-reporting. This entry is the over-reporting direction at the module level, plus the destination-map defect.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: remove the `docs` and `tests` location buckets from the module map in both config copies; derive the destination module map from the destination repository's actual layout at push-down time, in both the Python and TypeScript push-down surfaces.
- [x] Integration scenario to retest: two disjoint items produce zero conflict edges; two items sharing a production file, a test file, or a shared surface still conflict.
- [x] Manual verification notes: the following was verified against the proposed module map with `docs` and `tests` removed.

```
disjoint items           conflict=False reasons=none
same production file     conflict=True  reasons=path_overlap->..., module_overlap->python-dev-tools
same test file only      conflict=True  reasons=path_overlap->tests/scripts/dev_tools/test_shared.py
shared surface           conflict=True  reasons=path_overlap->..., module_overlap->config, shared_surface_overlap->...
```

A regression gate is required: a test asserting that two items with disjoint production paths produce zero conflict edges. That assertion would have caught Defect A before push-down.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch

## Restoration Note

This lifecycle record was reconstructed by the orchestrator on 2026-08-15. The `potential_to_issue` MCP call reported `destination_path` `docs/features/potential/promoted/2026-08-15-blast-radius-module-map-forces-serial-runs.md`, but that file was never written and the pre-promotion source `docs/features/potential/2026-08-15-blast-radius-module-map-forces-serial-runs.md` was deleted. Both were confirmed absent immediately after the call, with both directory mtimes current. Content was recovered from the active feature folder's `issue.md`, which is byte-identical to the authored original apart from the promotion header. GitHub issue #472 carries the authoritative body. No content was lost. The anomaly is recorded separately at `docs/features/potential/2026-08-15-potential-to-issue-loses-promoted-record.md`.
