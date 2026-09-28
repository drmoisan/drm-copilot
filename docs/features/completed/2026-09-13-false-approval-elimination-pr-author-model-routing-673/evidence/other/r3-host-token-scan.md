# Host-Token Scan Over the Change Set: AC-38 (issue #673)

Timestamp: 2026-09-19T19-17

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-host-scan-diff.ps1` (route `a`), driven from a file list built by `git diff --name-only b7c1161655b4b53b0358dc7890a26200207c4b91 HEAD` with the three superseded plans excluded by name; then `git status --porcelain`; then a second run of the same script over the uncommitted set.

EXIT_CODE: 0

## Matchers

The same four the `[P0-T16]` inventory used. Values are computed at run time and never written; no matched text is emitted, per binding rule 6.

- m1: regex `(?<![A-Za-z])[A-Za-z]:[\/]`
- m2: regex `(?<![A-Za-z0-9._-])/[A-Za-z]/[A-Za-z]`
- m3: regex `[\/](Users|home)[\/]`
- m4: case-insensitive simple match of the account name

## Result over the anchored diff

FILES_SCANNED: 123
MATCHER_TOTALS: m1=0 m2=0 m3=0 m4=0

The files-scanned count is greater than 0 and all four match counts are 0, which are the acceptance conditions. The scan is non-vacuous: 123 files were read, which is every path in the anchored diff except the three superseded plans the plan excludes by name.

Those three are excluded because they are superseded and the plan forbids editing them; they retain the host tokens the `[P0-T16]` inventory recorded, and `[P1-T5]` deliberately left them alone. They are the only files in the change set that carry a host token, and AC-38 names them as its stated exception.

## Second scan, over the uncommitted set

The anchored diff cannot see a file that is not yet committed, and ten evidence artifacts written during Phase 10 were uncommitted when this task ran. Scanning the diff alone would therefore have left them unmeasured until after the final commit, when no task remains to check them. They were scanned separately:

FILES_SCANNED: 10
MATCHER_TOTALS: m1=0 m2=0 m3=0 m4=0

All ten are clean. This second scan is not required by the acceptance condition; it is run because the condition's mechanism is blind to exactly the files this phase produces.

## Porcelain

`git status --porcelain` lists ten paths, all under `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/`: eight Phase 10 evidence artifacts, the commit log, and the plan's checklist state. It lists **no path outside the two feature folders**, which is the scoped form binding rule 5 requires.

Output Summary: All three acceptance conditions hold. `git status --porcelain` lists no path outside the two feature folders; the files-scanned count is 123, well above zero; and all four matcher counts are 0. A second scan over the ten uncommitted Phase 10 artifacts, which the anchored diff cannot reach, also returns zero on every matcher. No matched token is reproduced anywhere in this artifact, and the three superseded plans that legitimately retain host tokens are excluded by name as AC-38 provides.
