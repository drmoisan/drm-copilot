# Remediation Inputs — #1139 (cycle 1)

Timestamp: 2026-11-08T20-10
Remediation-Mode: proportionate
Opened-By: orchestrator, from the non-blocking Minor finding of code-review.2026-11-08T20-04.md (review verdict PASS). Related findings are fixed inside the item before merge rather than filed as follow-up issues.
Head: 7a8a9732d

## Finding F1 (Minor, non-blocking in review; remediated in-item)

- Source: code-review.2026-11-08T20-04.md, Minor finding on `ConvertFrom-OwnerDirectiveDateText`.
- Location: `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`, function `ConvertFrom-OwnerDirectiveDateText` (bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/`).
- Defect: `[datetime]::TryParse` with the invariant culture accepts values that are not ISO 8601 date-times (observed at head 21eee3f40: `11/08/2026`, `Monday, 09 November 2026`, `8 Nov 2026 3pm` produce no B7/R9 error). spec.md, the `owner-directives` skill and the `.claude/rules/orchestrator-state.md` section describe `recorded_at`, `expires_at` and `decided_at` as ISO 8601 date-times.
- Remediability: autonomous
- Finding-Scope: contained
- Required change: accept only an ISO 8601 extended date-time shape (date `yyyy-MM-dd`, `T`, `HH:mm` with optional seconds and fraction, optional `Z` or `+HH:mm`/`-HH:mm` offset; a zone-less value keeps the existing assume-UTC rule) before parsing, keeping invariant culture with AssumeUniversal and AdjustToUniversal; a value outside that shape is treated as unparseable, so B7 and R9 report it with their existing strings. Keep the bundle copy byte-identical.
- Tests: add B7 rows (recorded_at or expires_at non-ISO) and R9 rows (decided_at non-ISO) for the three observed values, built from JSON text through `-CheckpointText`; keep every existing date case passing, including the zone-offset, zone-less and de-DE culture cases.
- Docs: no wording change required unless a document states a broader accepted format.
- Gates: one `Invoke-PoshQCParallelTest` run, compared with evidence/qa-gates/pester.2026-11-08T19-51.md: 0 failures, new module stays at or above 90% lines (currently 100%), no per-file drop. No Python change, so no pytest gate is required beyond what CI runs.
