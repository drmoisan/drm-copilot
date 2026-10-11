# duplicated-string-comparators-outside-pr-context (Issue #796)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/duplicated-string-comparators-outside-pr-context/ (Issue #796)
- Related: #740, #716

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #796
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/796
- Last Updated: 2026-09-30
## Summary

The same ordinal string comparator, `left < right ? -1 : left > right ? 1 : 0`, is implemented in many places under `extensions/drm-copilot/src/lib/` outside `pr-context/`. #716 consolidated `compareCodePoint` into `pr-context/models.ts`, and #740 (still open) covers the remaining duplication inside `pr-context/`. #740 mentions the other comparators only by name and does not list them; this entry lists them. Found during #740 preparation.

## Environment

- OS/version: any
- Python version: n/a (TypeScript)
- Command/flags used: `git grep -n 'left < right ? -1' -- extensions/drm-copilot/src`
- Data source or fixture: main at ae7c7779

## Steps to Reproduce

1. Run `git grep -n 'left < right ? -1 : left > right ? 1 : 0' -- extensions/drm-copilot/src`.
2. Compare each hit with `compareCodePoint` in `extensions/drm-copilot/src/lib/pr-context/models.ts:340`.

## Expected Behavior

One shared comparator is used for ordinal string ordering, so its contract and tests exist once.

## Actual Behavior

Named copies of the comparator:

- `extensions/drm-copilot/src/lib/pr-context/models.ts:340` `compareCodePoint` (the consolidated one, in `pr-context/`)
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts:121` `compareOrdinal` (exported)
- `extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:46` `compareStrings`
- `extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:36` `compareStrings`
- `extensions/drm-copilot/src/lib/codex-native-converter/reporting.ts:148` local `compare`
- `extensions/drm-copilot/src/lib/codex-native-converter/validation.ts:359` local `compare`

Inline copies of the same expression inside `sort` callbacks: `codex-native-converter/intermediate-state.ts:53`, `inventory.ts:169,239,294`, `models.ts:259`, `pipeline.ts:93`, `reporting.ts:54,230`, `validation.ts:269`, and `push-down/filesystem-adapter.ts:142`.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: output of the `git grep` in Steps to Reproduce, 12 files in total.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Maintainability only. The copies currently agree. #740 records that `compareCodePoint` is documented as code-point ordering but compares UTF-16 code units; the copies share that behavior, so a contract fix must be applied once, not per copy.

## Suspected Cause / Notes

The converter and push-down modules were written independently of `pr-context/`. A shared location outside `pr-context/` (for example `src/lib/`) is likely needed, because `codex-native-converter/` and `push-down/` importing from `pr-context/models.ts` would couple unrelated modules. The architecture-boundary rules should be checked before choosing it.

## Proposed Fix / Validation Ideas

- [ ] Coordinate with #740 so one shared comparator and one contract statement cover `pr-context/` and the modules above.
- [ ] Replace the named copies and inline expressions with the shared comparator, keeping the existing sort order.
- [ ] Keep converter and push-down output unchanged; existing golden or parity suites must pass without modification.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
