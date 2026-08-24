# Feature Audit: PreToolUse hooks parse flat payload and always allow (#501) — Cycle-2 Re-Audit

**Audit Date:** 2026-08-22
**Work Mode:** `full-bug` (persisted marker in `issue.md`, confirmed by direct read this session)
**AC Source:** `spec.md`, `## Acceptance Criteria` (AC-1 through AC-15; `user-story.md` legitimately absent under `full-bug`)
**Base Branch:** `main @ fb30a9a58b8422e610a09b07361421e97367807a`
**Head Branch:** PR #503 head `bd6e42846a497433b6d4ac288c2054b62b864b23`

## Scope and Baseline

This is a re-audit of the full branch diff (`fb30a9a5..bd6e4284`), not the cycle-2 remediation delta. One commit landed since the cycle-1 re-audit closed: `bd6e4284` (cycle-2 fix — three-line additive JSON registration in `core.json`, converting a CI-only failure into a resolved state). AC-1 through AC-15 were previously evaluated PASS by the cycle-1 re-audit and are re-confirmed here rather than re-derived from scratch, since none of their governing production files (`HookPayload.psm1`, the 24 migrated hooks, the mirror set, `enforce-prd-feature-before-planner.ps1`) changed this cycle. Cycle 2's only production-tree edit is a packaging-manifest registration with no runtime behavioral surface, so this audit's incremental verification focuses on (a) confirming that edit did not regress any prior PASS, and (b) confirming the live CI signal, which no prior cycle's audit had available at write time.

## Acceptance Criteria Inventory

### Acceptance criteria (spec.md, `## Acceptance Criteria`)

AC-1 through AC-15, all in checkbox format `- [x] **AC-N (...).** ...`. All 15 remain checked `[x]` in `spec.md` at the time of this audit (reviewer-confirmed by direct read this session).

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 transport unit suite | PASS | Unchanged this cycle; governing file (`HookPayload.psm1`) untouched (`git diff 0a383439..bd6e4284 -- '*.ps1' '*.psm1'` empty) | cycle-1 evidence, unchanged | Not independently re-executed this cycle; no regression possible given zero PowerShell production lines changed |
| 2 | AC-2 stdin nested differential | PASS | Unchanged this cycle; governing hook (`enforce-epic-merge-gate.ps1`) unchanged since cycle-1 close | cycle-1 evidence, unchanged | Not re-executed this cycle |
| 3 | AC-3 env nested, empty stdin | PASS | Unchanged this cycle | cycle-1 evidence, unchanged | Not re-executed this cycle |
| 4 | AC-4 fail-closed anomalies | PASS | Unchanged this cycle; no hook file touched | cycle-1 evidence, unchanged | Not re-executed this cycle |
| 5 | AC-5 validate-bash exception | PASS | Unchanged this cycle; `git diff 0a383439..bd6e4284 -- .claude/hooks/validate-bash.ps1` returns empty | reviewer re-run this session, empty diff confirmed | Not touched by cycle 2 |
| 6 | AC-6 property-level tolerance | PASS | Unchanged this cycle | cycle-1 evidence, unchanged | Not re-executed this cycle |
| 7 | AC-7 per-hook nested deny tests | PASS | Unchanged this cycle; 24-hook set unchanged, zero test files changed in cycle 2 | cycle-1 evidence, unchanged | `git diff 0a383439..bd6e4284 --stat -- 'tests/**'` empty, reviewer-confirmed this session |
| 8 | AC-8 structural regression guard | PASS | Unchanged this cycle; no hook file touched, no env-var literal reintroduced | cycle-1 evidence, unchanged | Not re-executed this cycle; no code path exists this cycle that could regress it |
| 9 | AC-9 mirror parity | PASS | Reviewer independently re-ran the mirror-parity gate this session against the current head: 1 passed | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts` (this session) | `core.json` is not itself a mirrored `.claude/**` file, so this gate is orthogonal to the cycle-2 fix but is reconfirmed clean regardless |
| 10 | AC-10 live end-to-end probe | PASS | Unchanged this cycle; governing hook untouched | cycle-1 evidence, unchanged | Not re-executed this cycle |
| 11 | AC-11 coverage | PASS | Repo-wide LINE coverage 96.47%, unchanged since cycle-1 close (zero PowerShell production lines changed this cycle); `evidence/qa-gates/2026-08-22T19-05-poshqc-test-final.md` [P3-T3] confirms the figure directly from this cycle's own final-QA run. No new coverage exclusion; `pester.runsettings.psd1` untouched by cycle 2 (`git diff 0a383439..bd6e4284 -- '**/pester.runsettings.psd1'` empty) | reviewer diff check this session; `evidence/qa-gates/2026-08-22T19-05-poshqc-test-final.md` | AC-11's repo-wide and per-file clauses both remain satisfied |
| 12 | AC-12 file-size ceiling | PASS | Reviewer scan of every changed non-Markdown file across the full branch diff this session (`git diff --name-only fb30a9a5..bd6e4284`): zero files exceed 500 lines; `core.json`'s 3-line addition to an already-under-ceiling data file is immaterial to this criterion's intent (production `.ps1`/`.psm1` files) but was checked anyway for completeness | reviewer loop this session | No regression |
| 13 | AC-13 scope boundaries | PASS | Reviewer re-confirmed this session: `git diff --name-only fb30a9a5..bd6e4284` contains zero `.codex/hooks/` paths and no match for any of the eight SubagentStop validator filenames | reviewer grep this session (`grep -c '^\.codex/hooks/'` returns 0; SubagentStop-validator grep returns empty) | Held across the full branch, not just the cycle-2 delta |
| 14 | AC-14 toolchain clean pass | PASS | Cycle-2's own Phase 3 final-QA loop is itself a fresh, unconditional clean-pass run: format (zero files modified), analyze (zero findings), test (3364/0 failures), plus — beyond AC-14's original PowerShell-only scope — the full Python suite (4062 passed, 0 failed) and both full TypeScript suites (198/198 and 195/195 suites passed) all in a single sequential pass with no `SKIPPED` step | `evidence/qa-gates/2026-08-22T19-01/02/05/08/11/13-*-final.md`; reviewer independently re-ran `Invoke-ScriptAnalyzer`/`Invoke-Formatter` against the one recently-touched hook file this session (0 findings, no change) | This cycle's final QA is strictly more thorough than AC-14's original PowerShell-only formulation, per the plan's own full-suite decision |
| 15 | AC-15 prd-feature work-mode-aware prerequisites | PASS | Unchanged this cycle; governing hook (`enforce-prd-feature-before-planner.ps1`) not touched by cycle 2 (only by the pre-cycle-2 docstring commit `0a383439`, already audited and confirmed correct by the cycle-1 re-audit). Reviewer independently re-ran the governing suite this session: 47/47 pass | reviewer re-run this session (`Invoke-Pester` scoped to `enforce-prd-feature-before-planner.Tests.ps1`) | No regression; this criterion's own fail-closed posture (the criterion most exposed to a permissive-failure regression given #501's subject matter) was re-verified by direct test re-execution, not merely by absence of diff |

---

## Summary

**Overall Feature Readiness:** READY (PASS)

**Criteria summary:**
- **PASS:** 15 criteria (AC-1 through AC-15)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:** None. Zero Blocking findings remain in this cycle's policy audit or code review. CI is green (19/19 required checks) against the exact branch head, which is new evidence this cycle's audit has that no prior cycle's audit had at write time (the PR had not yet been opened, or had not yet had a green run, when the earlier audits were produced).

**Recommended follow-up verification steps:**

1. None required to merge. The outstanding `issue.md` item "[ ] Open the pull request and land the fix" is now partially superseded by fact: the PR (#503) is open and green; the remaining action is the merge itself, which is outside this review's scope (this agent produces audit artifacts, not merge actions).
2. Optional, informational: after merge, confirm the push-down bundle picks up the three newly-registered files on the next scheduled or triggered push-down run (mechanical follow-through of the packaging fix, not a functional risk — the manifest registration is the complete fix; no further code change is implied).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- All 15 criteria in `spec.md` were already checked `[x]` prior to this audit. This audit independently evaluated every criterion as PASS, so the existing check-off state is correct and no source-file change was made by the reviewer.

### AC Status Summary

- Source: `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md`
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0

## Coverage Verification (this cycle's re-measurement)

Per the mandatory coverage-verification procedure, PowerShell is the only coverage-tracked language with changed files across the full branch diff. Cycle 2 itself introduced zero PowerShell production-file changes; the JSON manifest edit is not a coverage-tracked language.

- New files this cycle: none.
- Modified files this cycle (production): `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (JSON, not coverage-tracked).
- Coverage artifact: `artifacts/pester/powershell-coverage.xml` (this cycle's [P3-T3] run) — present, inspected via `evidence/qa-gates/2026-08-22T19-05-poshqc-test-final.md`. Reviewer additionally re-ran the governing suite for the file most recently touched in this feature's history (`enforce-prd-feature-before-planner.Tests.ps1`, 47/47 pass) rather than relying solely on the on-disk artifact.
- Repo-wide LINE coverage: 96.47%, unchanged since cycle-1 close. >= 80% threshold: PASS. >= 85% uniform-tier threshold: PASS.
- Modified-file coverage: no PowerShell production file was modified this cycle, so no per-file modified-file coverage assessment is applicable this cycle beyond the carried-forward, already-verified figures from cycle 1 (all 27 changed production files >= 85%, reconfirmed unregressed by construction since none of their lines changed).
- No branch-coverage threshold applies to PowerShell (Pester measures line/command coverage only); no FAIL recorded for its absence, per `.claude/rules/powershell.md`.
- TypeScript and Python: zero changed files on the branch; N/A per policy (the only permitted case for N/A).
