# blast-radius-config-has-no-merge-decorator (Issue #508)

- Date captured: 2026-08-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/blast-radius-config-has-no-merge-decorator/ (Issue #508)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

- Issue: #508
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/508
- Last Updated: 2026-08-23
## Summary

The push-down merges exactly one destination-relative path, the orchestration-routing file, and plainly overwrites every other published file. `config/blast-radius.json` is therefore overwritten on every push, so any shared surface, glob, or module a destination added locally is destroyed the next time the payload ships.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable; the carriage logic is TypeScript
- Command/flags used: source inspection
- Data source or fixture: `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` and `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`

## Steps to Reproduce

1. Read `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` around lines 53 to 64.
2. Observe that one path is documented as merged and that every other published file is a plain overwrite.
3. Read the carriage test that pins the overwrite behaviour for the blast-radius file.

## Expected Behavior

A destination can record its own contention surfaces without losing them on the next push. Either the blast-radius file is merged the way the routing file is, or the payload provides a documented destination-local extension point that survives a push.

## Actual Behavior

`config/blast-radius.json` is overwritten wholesale. A destination that adds, for example, its own root build files to `shared_surfaces`, or its own subsystem modules, loses those entries silently at the next push-down and reverts to the shipped defaults.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet, from the carriage implementation:

  ```text
  claude-customizations.ts:53  Destination-relative path whose write is merged rather than overwritten.
  claude-customizations.ts:64  Every other published file is a plain overwrite.
  ```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. This is the structural reason the shipped defaults have to be right upstream, which is what issue #500 addressed. It is not itself a correctness defect in the derivation, but it means a destination has no supported way to describe its own layout durably. Observed in practice: a destination had hand-added eighteen project modules locally, and those additions are exactly what a push would erase.

## Suspected Cause / Notes

The merge decorator was introduced for the routing file because destination-local routes must survive a push. The same argument applies to blast-radius entries, and the asymmetry looks like an omission rather than a decision. Related to issue #500, which corrected the shipped defaults on the assumption that a destination cannot durably override them.

## Proposed Fix / Validation Ideas

- [ ] Decide between merging the blast-radius file, adding a sibling destination-local overlay the payload never writes, or documenting the overwrite as intended and telling destinations not to edit the file.
- [ ] If merging, define the semantics per key: `shared_surfaces` and `mandate_reads` are additive sets where union is safe; `modules` is where an over-broad destination entry costs concurrency, so union may not be.
- [ ] Unit coverage areas: carriage behaviour for the blast-radius path under each chosen semantic.
- [ ] Integration scenario to retest: a destination-local addition survives two consecutive pushes.
- [ ] Manual verification notes: confirm no existing destination depends on the current overwrite to clear stale local entries.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
