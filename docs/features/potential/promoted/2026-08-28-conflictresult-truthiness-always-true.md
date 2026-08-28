# conflictresult-truthiness-always-true (Issue #576)

- Date captured: 2026-08-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/conflictresult-truthiness-always-true/ (Issue #576)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #576
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/576
- Last Updated: 2026-08-28
## Summary

The blast-radius conflict relation's result object evaluates truthy unconditionally: `bool(ConflictResult)` is `True` whether or not a conflict was found. A caller writing the natural `if conflicts(a, b, config):` therefore treats every item pair as conflicting. This happened in production during the critical-bug-fixes parallel run: item #559 appeared to conflict with every other item until the caller was corrected to test the result's explicit field.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry toolchain
- Command/flags used: `conflicts(a, b, config)` from `scripts/dev_tools/compute_blast_radius.py` (relation defined in `scripts/dev_tools/_blast_radius_conflicts.py`) used in a boolean context
- Data source or fixture: item #559 admission during the critical-bug-fixes parallel run (2026-08-26)

## Steps to Reproduce

1. Call `conflicts(a, b, config)` for two items with provably disjoint blast radii.
2. Evaluate the returned object in a boolean context: `if conflicts(a, b, config): ...`.
3. The branch is taken: the result object has no `__bool__`/`__len__`, so Python's default object truthiness makes every result truthy.

## Expected Behavior

Either `bool(result)` equals whether a conflict exists (define `__bool__` on the result type), or the result type refuses boolean coercion entirely (raise in `__bool__`) so a caller is forced to test the explicit field. Whichever is chosen must be mirrored in the PowerShell port (`.claude/lib/blast-radius/BlastRadius.psm1` `Test-BlastRadiusConflict`) and the TypeScript parity surface so all three runtimes agree.

## Actual Behavior

Default object truthiness: every result is truthy. During #559's admission the orchestrator's edge computation used the boolean form and derived a conflict edge to every other item, which would have serialized the entire run behind #559. The error was caught by re-deriving edges from the result's explicit field; the incident is recorded in the run checkpoint receipts.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: recorded in `artifacts/orchestration/parallel-orchestrator-state.json` receipts (the #559 conflict-edge correction).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Miscomputed conflict edges do not corrupt state — the recolor is a pure function and the checkpoint validator accepts any well-formed edge set — but they silently destroy concurrency (every admission defers) and misrepresent the contention graph the operator reads.

## Suspected Cause / Notes

The result dataclass carries the conflict verdict as a field and was never given boolean semantics. The API invites the natural-but-wrong call form; this is an API-design defect, not a caller-only error. Check whether any in-repo caller besides the corrected orchestrator path uses the boolean form.

## Proposed Fix / Validation Ideas

- [ ] Unit test: `bool(result)` for a disjoint pair is `False` (or raises, per the chosen design) and for an overlapping pair is `True`.
- [ ] Property test over generated radii: boolean form agrees with the explicit field.
- [ ] Grep-based check or lint note for boolean-context use of the relation in-repo.
- [ ] Parity: PowerShell and TypeScript surfaces return/behave equivalently.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
