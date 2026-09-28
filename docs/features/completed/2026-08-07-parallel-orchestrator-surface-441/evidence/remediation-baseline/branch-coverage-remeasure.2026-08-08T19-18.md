# Branch-Coverage Re-Measurement at HEAD (CR-05 Correction Source)

Timestamp: 2026-08-08T19-18

Command: `poetry run coverage json -o <scratchpad>/cov-remediation-baseline.json --quiet`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

EXIT_CODE: 0

Resolved HEAD commit SHA: `41633ad5e867070853e3e4501c3457b6641d1efc`

Provenance: this extraction ran immediately after the `[P0-T6]` pytest run and reused that run's
`.coverage` data file without re-running the suite. The measurement is therefore taken at the same
HEAD the artifact under correction describes, and before any Phase 1 edit. This artifact is the sole
numeric source for the Phase 5 correction of
`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/coverage-delta.2026-08-08T17-58.md`.

## Verbatim `totals` Block

```json
{
  "covered_lines": 12432,
  "num_statements": 13539,
  "percent_covered": 89.65963644209505,
  "percent_covered_display": "90",
  "missing_lines": 1107,
  "excluded_lines": 387,
  "percent_statements_covered": 91.82362065145136,
  "percent_statements_covered_display": "92",
  "num_branches": 5000,
  "num_partial_branches": 556,
  "covered_branches": 4190,
  "missing_branches": 810,
  "percent_branches_covered": 83.8,
  "percent_branches_covered_display": "84"
}
```

Output Summary:
- `percent_branches_covered`: **83.8**
- `covered_branches`: **4190**
- `num_partial_branches`: **556**
- `num_branches`: **5000**
- `percent_statements_covered`: **91.82362065145136**

Additional figures needed by the Phase 5 correction: `missing_branches` **810**.

These values reproduce the independent re-run recorded in
`code-review.2026-08-08T18-12.md` (`percent_branches_covered` 83.8, `num_partial_branches` 556,
`num_branches` 5000, `percent_statements_covered` 91.82362065145136) and differ from the figures
recorded in `coverage-delta.2026-08-08T17-58.md` (83.82%, `covered_branches` 4191,
`num_partial_branches` 555) by exactly one branch destination. Both values clear the 75% branch floor;
neither is a regression.
