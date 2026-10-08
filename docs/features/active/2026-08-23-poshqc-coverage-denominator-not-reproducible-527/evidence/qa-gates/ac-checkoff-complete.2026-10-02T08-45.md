# AC Check-Off Status (P6-T48 record; P6-T48 not satisfied)

Timestamp: 2026-10-02T08-45
Command: git/static-equivalent deviation DEV-P6-T48 (replaces the `Get-Content`/`IndexOf` unchecked count and `Get-NamedSectionCheckboxCount` from `.claude/lib/requirements/GeneratedDocumentCounters.psm1`, both `pwsh` expressions). `git -C <ROOT> grep --untracked -n -E '^- \[( |x)\] ' -- docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md`, restricted by line number to the `## Acceptance Criteria` section (heading at line 264, next heading `## Risks & Mitigations` at line 285; section items at lines 266-283). Per-criterion check: `git -C <ROOT> grep --untracked -c -F -e '- [x] <prefix>' ...` over the fourteen checked prefixes.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: AC section counter total 18 (checked and unchecked; no criterion removed). Checked 14, unchecked 4. The plan's P6-T48 condition "unchecked count returns 0" is not met, so P6-T48 stays unchecked; AC-18 itself is checked (its gating task P6-T28 passed). EXIT_CODE 1 records the unmet zero-unchecked condition; it is the expected outcome under the classification, which leaves four criteria pending operator runs.
- Fourteen-prefix `git grep -c -F` count: 14.

## Section items

| Line | ID | State | Gating tasks | Note |
| --- | --- | --- | --- | --- |
| 266 | AC-01 Deterministic derivation | `- [ ]` | P6-T11 | run C pending (operator); A == B recorded |
| 267 | AC-02 Route independence | `- [x]` | P2-T4, P4-T1, P6-T6 | |
| 268 | AC-03 Derived population contents | `- [x]` | P4-T1 | |
| 269 | AC-04 Precedence order | `- [x]` | P4-T1 | |
| 270 | AC-05 Observability | `- [x]` | P4-T1, P6-T12 | P6-T12 run A leg met; run C leg pending (DEV-AC-05-10) |
| 271 | AC-06 Config validation | `- [x]` | P4-T1 | |
| 272 | AC-07 Absolute root | `- [x]` | P4-T1 | |
| 273 | AC-08 Allow-list removed | `- [x]` | P6-T24 | |
| 274 | AC-09 Parity preserved | `- [x]` | P5-T8, P6-T2, P6-T23 | |
| 275 | AC-10 `config/poshqc-coverage.json` | `- [x]` | P6-T12, P6-T25 | P6-T12 run A leg met; run C leg pending (DEV-AC-05-10) |
| 276 | AC-11 Consumer fixture coverage | `- [ ]` | P6-T16, P6-T17, P6-T41 | post-fix fixture run pending (operator) |
| 277 | AC-12 Consumer isolation | `- [ ]` | P6-T18, P6-T42 | post-fix fixture run pending (operator) |
| 278 | AC-13 Fixture output hygiene | `- [ ]` | P6-T19, P6-T43 | post-fix fixture run pending (operator) |
| 279 | AC-14 New code coverage | `- [x]` | P6-T13, P6-T14 | |
| 280 | AC-15 Existing suite | `- [x]` | P6-T1, P6-T3, P6-T4; no ESCALATION in P0-T4/P4-T2 | Grep for `ESCALATION:` under `evidence/` matched only `other/preflight-round-1.2026-09-29T16-50.md` |
| 281 | AC-16 Documentation | `- [x]` | P6-T26 | |
| 282 | AC-17 No temporary files in tests | `- [x]` | P6-T27 | |
| 283 | AC-18 Line limits | `- [x]` | P6-T28 | P6-T48 itself unchecked (zero-unchecked condition) |

## Open items

1. AC-01 — requires run C (P6-T9, P6-T10) and the three-way comparison (P6-T11).
2. AC-11 — requires the post-fix consumer fixture run (P6-T15 to P6-T17) and the commit-readiness record (P6-T41).
3. AC-12 — requires P6-T18 on the post-fix fixture output.
4. AC-13 — requires the P6-T15/P6-T19 before/after hygiene snapshots.

Operator commands: `evidence/other/plan-deviations.2026-10-02T07-45.md`, entries DEV-P6-T9-T10 and DEV-P6-T15-T19.
