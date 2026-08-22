Timestamp: 2026-08-21T21-49

TypeScript is not re-baselined in this remediation cycle. No file under
extensions/drm-copilot/src/** or extensions/drm-copilot/test/** is touched by R1 through R6 in
this cycle. The original branch's TypeScript delivery (PAYLOAD_MODULES, the two Jest cases) is
unaffected by this remediation cycle, so a TypeScript baseline recapture would measure a state
this cycle does not change. C# and shell are likewise untouched, matching the original branch.

Note: see `evidence/other/timestamp-clock-convention.2026-08-22T03-37.md` for why this artifact's local-time stamp sorts before the UTC-stamped Phase 0 baselines it postdates.
