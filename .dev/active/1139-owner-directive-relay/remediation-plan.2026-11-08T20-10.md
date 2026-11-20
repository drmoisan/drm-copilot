# owner-directive-relay - Remediation Plan, Cycle 1

- **Issue:** #1139
- **Branch:** feature/owner-directive-relay
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T20-10
- **Status:** Draft
- **Remediation-Mode:** proportionate
- **Input:** `remediation-inputs.2026-11-08T20-10.md` (finding F1 only)

## Required References

- Finding: `remediation-inputs.2026-11-08T20-10.md` (`## Finding F1 (Minor, non-blocking in review; remediated in-item)`), from `code-review.2026-11-08T20-04.md`.
- Requirements: `spec.md`, `.claude/skills/owner-directives/SKILL.md` (`recorded_at` and `expires_at` are ISO 8601 date-times, read as UTC when no offset is given), `.claude/rules/orchestrator-state.md` (rows B7 and R9 of the owner-directive rule table).
- Policies: `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`.
- Tool routes, launchers, command-text restrictions, batch budget, hook context, and CI shape are owned by the `execution-environment` skill (`## Tool Routes by Agent`, `## PowerShell Route and PoshQC MCP Limits`, `## Test Isolation Checks`); this plan does not restate them.

## Conventions

- `FEATURE` is `docs/features/active/2026-11-08-owner-directive-relay-1139`. `SCRATCH` resolves to `<session scratchpad>/issue-1139/`; scratch file names start with `issue-1139-`, and artifacts record the token `SCRATCH`, never a host path.
- Evidence files are `<name>.<timestamp>.md` under `FEATURE/evidence/<kind>/`, stamped with the UTC write time read from the clock; a consumer reads the lexicographically greatest match. Evidence is append-only: no evidence file is edited, renamed, or deleted, and a correction is a new timestamped file.
- Every command artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- `MB` is the merge base of `origin/main` and `HEAD`, re-derived when used.
- Each task ends with one commit and a push to `origin/feature/owner-directive-relay`; no tags, no force push, no history rewrite.
- Scope: two production PowerShell files (the module and its bundle copy) and two existing test files. No Python file, no hook script, no fixture, and no documentation file changes; the skill and rule already state ISO 8601, so no wording change is required.
- Test gate is parallel only: one `Invoke-PoshQCParallelTest` run, re-run only after a fix. A focused single-file run is debugging, never acceptance or evidence.

## Design

`ConvertFrom-OwnerDirectiveDateText` in `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` gains a shape check before its existing `[datetime]::TryParse` call. The check is a case-sensitive, culture-independent match of the whole text against the ISO 8601 extended date-time shape: four-digit year, `-`, two-digit month, `-`, two-digit day, `T`, two-digit hour, `:`, two-digit minute, optional `:` plus two-digit seconds with an optional `.` plus one or more digits, then optional `Z` or a `+`/`-` two-digit hour `:` two-digit minute offset, anchored at both ends with the end-of-string anchor that admits no trailing line feed, and with ASCII digit classes only. The exact pattern asserted is `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]+)?)?(Z|[+-][0-9]{2}:[0-9]{2})?\z`. Text outside the shape returns `$null` without parsing; text inside it is parsed as today (invariant culture, `AssumeUniversal` with `AdjustToUniversal`), so a calendar-invalid value still returns `$null`. The pattern is a local value inside the function, not script-scoped state. The callers in `Get-OrchestratorStateOwnerDirectiveError` are unchanged, so B7 and R9 report a non-ISO value with their existing strings.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Reference

- [x] [P0-T1] Record the `Phase 0 baseline` reference without a new run: write `FEATURE/evidence/remediation-baseline/baseline-reference.<timestamp>.md` citing `FEATURE/evidence/qa-gates/pester.2026-11-08T19-51.md` as the comparison run for this cycle, and copying from it the test counts (20464 tests, 0 failures), repo-wide line coverage (95.68%), and the per-file line coverage of `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` (100.00%) and `.claude/hooks/validate-orchestrator-output.ps1` (99.25%); also record `MB`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:` (the merge-base derivation), `EXIT_CODE: 0`, and an `Output Summary:` carrying the five copied values and the cited artifact path; `git status --porcelain` lists only that artifact before the commit.

### Phase 1 — Strict ISO 8601 Date Shape

- [x] [P1-T1] Add the shape check of `## Design` to `ConvertFrom-OwnerDirectiveDateText` in `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`, update its leading comment to state that only the ISO 8601 extended shape is parsed, and copy the file byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`.
  - Existing tests asserting date parsing, with dispositions (found by searching `tests/` for `ConvertFrom-OwnerDirectiveDateText`, `recorded_at`, `expires_at`, `decided_at`, and the B7 and R9 strings): in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1`, `B7 rejects recorded_at <Recorded> with expires_at <Expires>` is updated in P1-T2 (rows added; every current row keeps its expectation because `not-a-date` and `tomorrow` fail the shape and the other rows match it); `B7 accepts an offset recorded_at that is earlier than expires_at in UTC`, `B7 reads zone-less dates as UTC strings under the de-DE culture`, `B7 every date parse in the module assumes and adjusts to UTC and no local style is named` (the `TryParse` call stays in the same function with both styles, and the regex match is not a `datetime` member call), `S1 the module calls no clock, file, process, or import command`, `S3 returns an empty array for the valid fixture with honored and refused records`, `B2 reports field <Field> of entry #1 when it is <Mode>`, and `B5 accepts a date-looking directive text that carries its correct digest` are unchanged because unaffected; in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1`, `R9 rejects an unparseable decided_at`, `R10 rejects an honored record decided after the directive expires_at`, `R10 accepts a refused record decided after the directive expires_at`, `R10 accepts an honored record decided exactly at the directive expires_at`, and `R10 compares decided_at <Decided> with expires_at 12:00Z in UTC` are unchanged because every value they use matches the shape; `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` and `tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json` are unchanged because every date they hold is in the `Z` form.
  - Acceptance: the SHA-256 digests of the root file and the bundle copy are equal, recorded in `FEATURE/evidence/other/bundle-parity.<timestamp>.md`; `git diff --name-status MB...HEAD` after the commit, together with an empty `git status --porcelain`, shows this cycle adding changes to these two files only (beyond P0-T1 evidence); the module stays under 500 lines.
- [x] [P1-T2] Add the test rows: in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1`, extend the `-ForEach` of `B7 rejects recorded_at <Recorded> with expires_at <Expires>` with eight rows built through `Edit-OwnerDirectiveFixture`: recorded_at set to each of `11/08/2026`, `Monday, 09 November 2026`, and `8 Nov 2026 3pm` with expires_at `2026-11-30T10:00:00Z`; expires_at set to each of the same three values with recorded_at `2026-11-01T10:00:00Z`; and recorded_at `2026-11-08 10:00:00Z` and `2026-11-08` with expires_at `2026-11-30T10:00:00Z` (every row parses under the pre-change code to an order that produces no error, so each row fails before P1-T1 and passes after it); and add `B7 accepts the ISO 8601 shape <Recorded>` with rows `2026-11-08T10:00Z`, `2026-11-08T10:00:00.5Z`, and `2026-11-08T10:00` for recorded_at and expires_at `2026-11-30T10:00:00Z`, asserting zero errors. In `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1`, add `R9 rejects the non-ISO decided_at <Decided>` with the three observed values on record #1 through `Edit-OwnerDirectiveRecordFixture`, asserting exactly `@($script:R9)` through `Assert-OwnerDirectiveRecordError`.
  - Acceptance: both files stay under 500 lines; no test creates a file, reads a clock, or changes culture outside the existing de-DE case; the new and extended tests pass in the P2-T2 gate (14 B7 reject rows, the six existing and eight new, 3 B7 accept rows, and 3 R9 rows in the merged JUnit).

### Phase 2 — Final QA

- [x] [P2-T1] Run the final PowerShell static loop over the two module files and the two test files: check-only formatter comparison, `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, and `Invoke-PoshQCLeakScan -Root` of the branch-current module; on any finding or formatter difference, fix, commit, and restart the loop.
  - Acceptance: `FEATURE/evidence/qa-gates/powershell-static.<timestamp>.md` records per step the command, exit code, and finding count, with the formatter reporting 0 files it would change, 0 analyzer findings, and a leak scan exit code of 0.
- [x] [P2-T2] Run the final Pester gate: one `Invoke-PoshQCParallelTest` run of the branch-current PoshQC module; on a failure fix the cause and re-run the gate once per fix.
  - Acceptance: `FEATURE/evidence/qa-gates/pester.<timestamp>.md` records the returned `ExitCode` 0, test counts from `artifacts/pester/pester-junit.xml` with 0 failures and no failing test, repo-wide line coverage and the per-file line coverage of `OrchestratorStateOwnerDirectives.psm1` and `validate-orchestrator-output.ps1` from `artifacts/pester/powershell-coverage.xml`, and a comparison table against `pester.2026-11-08T19-51.md`: the module at or above 90%, no per-file drop for either file, no repo-wide drop, and the P1-T2 row counts present.
- [x] [P2-T3] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against `git diff MB...HEAD` restricted to this cycle's changes, confirm with `git diff --name-status MB...HEAD` and an empty `git status --porcelain` that no Python file, hook script, fixture, or documentation file (other than this plan's check-offs and this cycle's evidence under `FEATURE/evidence/`) changed in this cycle, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md`.
  - Acceptance: the artifact has one PASS, FAIL, or N/A row per checklist item, cites the P1-T1, P2-T1, and P2-T2 artifacts for parity, static, test, and coverage rows, records F1 as closed, and holds no FAIL row; a FAIL is fixed, P2-T1 and P2-T2 re-run, and a new self-review written.

## Pre-Mortem

- Review checklists: P2-T3 walks all three audit templates against the merge-base diff and blocks completion on a FAIL; P1-T1 names every existing date-parsing test with its disposition, so no assertion is orphaned.
- Coverage: the new shape check is one branch in an existing function exercised by the P1-T2 reject and accept rows, so the module stays at or above 90% (100% at baseline); figures come only from the single P2-T2 run and are compared with `pester.2026-11-08T19-51.md` through P0-T1.
- Mirror parity: P1-T1 copies the module to its bundle copy in the same task and records equal SHA-256 digests; the plan changes no fact the execution-environment brief states, so no brief update is required.
- File size: the module grows by a few lines from its current size below 400; the two test files grow by under 30 lines each and stay below 500; Markdown is exempt.
- Test isolation: every row is built from the fixture text in memory through `-CheckpointText`; no file, clock, or global state is touched; the gate is one `Invoke-PoshQCParallelTest` run, re-run only after a fix, and `Invoke-PoshQCLeakScan` runs in P2-T1.
- CI-only behavior: the shape check uses ASCII digit classes and a case-sensitive match, and parsing keeps the invariant culture, so results do not depend on host culture or OS; the suites run in the Windows shard jobs of `poshqc / PowerShell QC`, and no test reads gitignored `artifacts/` state.
- Evidence: every artifact is a new file under `FEATURE/evidence/<kind>/` with a clock-read UTC stamp and the four required fields; no earlier evidence file is edited, and P0-T1 cites the existing baseline rather than re-running it.
