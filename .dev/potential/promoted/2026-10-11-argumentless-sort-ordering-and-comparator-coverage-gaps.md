# argumentless-sort-ordering-and-comparator-coverage-gaps (Issue #889)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/argumentless-sort-ordering-and-comparator-coverage-gaps/ (Issue #889)
- Origin: issue #796 (PR #872), spec follow-up and code-review findings; parallel run bug-burndown-2026-10-08

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #889
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/889
- Last Updated: 2026-10-11
## Summary

Issue #796 consolidated the duplicated string comparators onto `compareCodePoint` (`extensions/drm-copilot/src/lib/string-ordering.ts:53`), but 19 argument-less `.sort()` calls in production TypeScript still use the default UTF-16 code-unit order, so two orderings coexist in `push-down/`, `subagent-tree/`, `validate/` and `resolve/`. A decision is needed on whether those sites should use `compareCodePoint`. The same review left two non-blocking test gaps open.

## Environment

- OS/version: any
- Python version: n/a (TypeScript, `extensions/drm-copilot`)
- Command/flags used: `npx jest --coverage` in `extensions/drm-copilot`
- Data source or fixture: main at 2ef8d361

## Steps to Reproduce

1. Search `extensions/drm-copilot/src/lib/` for `.sort()` with no comparator, excluding tests and build output.
2. Compare with the `compareCodePoint` call sites introduced by #796.
3. Sort two strings that differ only by a supplementary-plane character versus a high BMP character (for example U+FF5E versus U+1F600) with both orderings and compare the results.

## Expected Behavior

One deterministic string ordering is used for every ordering that affects output, or the remaining default-order sites are documented as intentionally different.

## Actual Behavior

Argument-less `.sort()` sites on main (19):
- `push-down/claude-pack-selection.ts`: 117, 299
- `push-down/codex-pack-selection.ts`: 66, 71, 100, 108, 232
- `subagent-tree/tree-assembler.ts`: 181; `subagent-tree/tree-formatter.ts`: 29
- `resolve/file-prompt-transforms.ts`: 184, 191
- `validate/codex-topology-resolver.ts`: 123; `validate/epic-orchestrator-state-core.ts`: 203; `validate/epic-planner-git-integrity.ts`: 284; `validate/orchestrator-state-codex-model-routing.ts`: 457; `validate/orchestrator-state-codex-topology.ts`: 299; `validate/orchestrator-state-core.ts`: 253, 285; `validate/orchestrator-state-model-routing-existence.ts`: 66

The #796 spec counted "seven sites under `validate/` and `resolve/`"; main has 11, and `tree-assembler.ts` moved from line 186 to 181.

Open test gaps:
1. Null-path tie branches (Minor): the `?? ""` null-default arm of the source-path/target-path tiebreak is not exercised at `codex-native-converter/reporting-render.ts` 83, 189; `reporting.ts` 152, 157; `validation.ts` 364, 365, 370.
2. Role-order assertion (Nit): `test/lib/codex-native-converter/engine-pipeline.test.ts:45-64` covers the `targetRole` tiebreak (`engine-pipeline.ts:241`) only by duplicating one record, so a wrong `targetRole` order would not be detected.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/code-review.2026-10-09T21-56.md:29`: "Two orderings coexist in `push-down/` and `subagent-tree/` because argument-less `.sort()` calls (UTF-16 order) remain; recorded as an out-of-scope follow-up in `spec.md`. Inputs are ASCII identifiers in practice."
- Snippet: `spec.md:254`: "Follow-up (no issue filed in this run): decide whether argument-less `.sort()` calls ... should use `compareCodePoint`."
- Test gaps: `code-review.2026-10-09T21-56.md:42` and `:44`; PR #872 Follow-ups and `feature-audit.2026-10-09T21-56.md:87` name these two. The review's closing (line 123) names a different second gap, mocked-classifier coverage of `pipeline-traces.ts` lines 114 and 120 (line 41); it is listed here for completeness.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low. Inputs are ASCII identifiers in practice, so the two orderings agree today. The risk is divergent output if non-ASCII names reach these paths.

## Suspected Cause / Notes

- #796 scoped the change to duplicated comparator functions and deliberately left default-order sorts unchanged.
- Coverage figures for the touched files are in `evidence/qa-gates/coverage-delta.2026-10-09T23-14.md` of the #796 folder; per-gap percentages were not recorded.

## Proposed Fix / Validation Ideas

- [ ] Decide the policy: replace each output-affecting `.sort()` with `.sort(compareCodePoint)`, or document why default order is acceptable at each site.
- [ ] Unit coverage areas: add a tie case with a `null` `targetPath`/`sourcePath` reaching the final key; add a role-order test with distinct `targetRole` values.
- [ ] Integration scenario to retest: push-down and subagent-tree output with non-ASCII names produces the same order as `compareCodePoint`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch