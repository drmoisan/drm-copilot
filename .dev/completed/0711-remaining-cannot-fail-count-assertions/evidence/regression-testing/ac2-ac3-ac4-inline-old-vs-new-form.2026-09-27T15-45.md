Timestamp: 2026-09-27T15-45
Command: sh <scratchpad>/run-ps.sh <scratchpad>/old-vs-new-form.ps1
EXIT_CODE: 0
Output Summary: Two printed lines, exact match to expected:
  input=null oldForm=True newForm=False
  input=emptyArray oldForm=False newForm=False

This is the AC-8 evidence for AC-2, AC-3, and AC-4. The first line documents the vacuous shape (`oldForm=True` for `$null`) that the same textual shape `@($x).Count -gt 0` would exhibit if the guarded value at AC-2/AC-3/AC-4 could ever be a raw `$null` — a state proven (spec Root Cause Analysis, research AC-2/AC-3/AC-4 sections) never to be reachable through those three producers' `return , $collection.ToArray()` contract. The second line confirms both the old and new forms already agree (both `False`) on the reachable empty-array case, so hardening these three sites to the filtered form is defense-in-depth (spec D1, Option B), not a correctness fix for a reachable defect.

Deviation note: per the plan's D3, the intended mechanism was an inline `pwsh -NoProfile -Command` expression. Consistent with this plan's mandatory shell-execution route (the worktree guard denies any Bash-tool command text containing the substring `pwsh`), the equivalent logic was written to the committed-route helper script `<scratchpad>/old-vs-new-form.ps1` and invoked via `sh <scratchpad>/run-ps.sh`, per P0-T13. The command content and observed output are unchanged from what an inline `pwsh -Command` invocation would produce.
