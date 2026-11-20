# Remediation Inputs — cycle R4 confirming pre-push full-diff review (issue #935)

Review-Verdict: PASS

Timestamp: 2026-10-17T04-42
Branch: `bug/hook-test-isolation-737-remainder-935-r4` (no PR yet)
Head reviewed: `ae0d3a03b8c26879bb7ab67be37a149930f7669a` (local, not pushed; merge-base `7516050be`) plus the uncommitted P6-T30 check-off in `remediation-plan.2026-10-16T20-56.md`
Review artifacts:
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-17T04-42.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-17T04-42.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-17T04-42.md`
Prior inputs: `remediation-inputs.2026-10-17T02-00.md`. All 15 findings (AC-CHK-2, CR-G1, CR-G2, CR-G3, TEST-2, TEST-3, TEST-4, DOC-5, DOC-6, CR-G4, CR-G5, CR-G6, CR-G7, PLAN-2, EV-4) are verified fixed at HEAD; DOC-2 stays with the orchestrator after S9.

Blocking findings: 0. Non-blocking findings: 8.

Operator ruling for this pass: every finding, including the non-blocking ones below, is fixed before the single push. Under orchestrator note (5) of `remediation-plan.2026-10-16T20-56.md`, these 8 findings return to the planner, whose revision adds their fix tasks before P7-T1; the verdict line above reflects only that no finding is of blocking severity.

Local context: repository-scope run (report `Pester (10/17/2026 04:22:37)`) 11149 testcases, 0 failures; root line coverage 89.61% (17017/18990). No CI exists for this head.

## Non-blocking findings (fix in this pass)

### TEST-5: Memo suite copies the Discovery suite fixtures

Severity: Low (non-blocking)
- File and location: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1` BeforeAll lines 26-56; copies of `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` lines 51-60 (`Get-FixtureReader`) and 71-92 (`$script:HookFile`, `$script:HookText`, `$script:ProbeHookText`, `$script:LoadHookSuite` and their line-ending normalization).
- Problem: about 30 lines duplicated verbatim across two suites (`.claude/rules/general-code-change.md` Reusability); a fixture change must be made twice.
- Fix: create `tests/scripts/claude-hooks/EpicStateIsolation.Fixture.Helpers.ps1` with `Get-FixtureReader` and the four fixture assignments (LF-normalized), a header naming both consumer suites and stating that it reads no file; dot-source it from both suites' file-level BeforeAll after the three existing helpers; delete the copies. Add the file to spec `## Write Set` (Create) and to the plan's code set, D-LC, scope and determinism checks. Its name does not end in `.Tests.ps1`, so the Discovery guard does not enumerate it.

### TEST-6: scanned probe finding text not pinned

Severity: Info (non-blocking)
- File and location: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1`, row `PERF probe finding with supplied seams`, line 201.
- Problem: only `$scanned.Count` is asserted, so the `$supplied` comparison proves equality with an unspecified finding.
- Fix: after line 201 insert `        $scanned[0] | Should -BeLike '*never calls Invoke-EpicStateInterceptionProbe*'` (+1 line).

### CR-H1: memo-writing functions still described as pure

Severity: Info (non-blocking)
- File and location: `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` lines 31-32 (header), 108 (`Get-EpicStateParsedSource`), 150 (`Get-EpicStateHookLiteral`), 223 (`Get-EpicStateLoadedSourceClosure`), 258 (`Get-EpicStateSeamCensus`).
- Problem: `Get-EpicStateParsedSource` writes `$script:EpicStateParseCache` directly and three functions write memos through callees, yet each reads "Pure"; the header omits the ordinal comparison that CR-G3 introduced.
- Fix: line 108 `    # Deterministic: the parsed AST and the non-bareword string-literal values of one source text, recorded in $script:EpicStateParseCache by text (ordinal keys).`; line 150 `# Pure:` to `# Deterministic (records parse-memo entries):`; line 223 `Pure over the injected reader:` to `Deterministic over the injected reader (records memo entries through its callees):`; line 258 `Pure:` to `Deterministic (records census-memo entries through Get-EpicStateFileSeamCensus):`; line 32 `keyed by source text,` to `keyed by source text with ordinal comparison,`.

### CR-H2: comment paragraphs not reflowed after header edits

Severity: Info (non-blocking)
- File and location: `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` header lines 9-10 and 20-23, `Get-EpicStateClosureSuccessor` help lines 186-187; `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` header lines 6-8.
- Problem: short mid-paragraph lines (`enumerate the hook suites of both surfaces, compute the`; `which read the committed tree`; `Predicate, Discovery, HookReference, Memo). The functions parse a`) and an over-long line 186 left by the CR-F6, CR-G4 and CR-G5 insertions.
- Fix: reflow the four paragraphs to the surrounding header width (about 96 columns) with no word change; re-run format and analyze.

### DOC-7: spec test strategy says AC-5b never fails

Severity: Low (non-blocking)
- File and location: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md` line 178.
- Problem: "`AC-5b` never fails" contradicts D7 (line 226) after CR-G1.
- Fix: replace the line with `- Error handling and logging verification: missing and unparseable suite rows keep passing; `AC-5b` never fails on a report entry and fails only when building the surface report throws (D7).` Do not edit AC-12.

### DOC-8: stale line reference in the spec

Severity: Info (non-blocking)
- File and location: `spec.md` line 124.
- Problem: cites `EpicStateIsolation.Discovery.Helpers.ps1` header "(lines 16-19)"; the paragraph is at lines 26-29.
- Fix: replace "header (lines 16-19)" with "header (the paragraph beginning `The closure is seeded only from hooks/<name>.ps1 string literals`)".

### DOC-9: spec test strategy omits the Memo suite

Severity: Info (non-blocking)
- File and location: `spec.md` lines 170-175 ("Regression tests to add or update").
- Problem: the Memo suite and its ten PERF rows (D7) are not listed; the Discovery bullet does not mention the CR-G1 capture.
- Fix: after line 174 add `  - New `enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1`: the ten PERF memo rows (D7), including `PERF parse memo keeps texts that differ only in letter case apart` with its fail-before record `evidence/regression-testing/r4-rf-cr-g3-fail-before.2026-10-17T03-46.md`.`; change line 174 to `  - `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`: `AC-5b` report row and its per-surface build-error capture (D7).`

### EV-5: validation record names revision 5

Severity: Info (non-blocking)
- File and location: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r4-plan-validation.2026-10-17T03-55.md`, `ORCHESTRATOR-VALIDATION:` line.
- Problem: states that revision 5 is validated before Phase 6; Phase 6 ran on revision 7 (`d48f58cf8`), and the record holds no validator result of its own.
- Fix: leave the record unchanged; write `evidence/qa-gates/r4-plan-validation.<timestamp>.md` recording `mcp__drm-copilot__validate_orchestration_artifacts` (artifact_type `plan`) `ok: true` for revision 7 of `remediation-plan.2026-10-16T20-56.md` (with the P6-T30 check-off) and for `plan.2026-10-15T17-44.md`, run by this review at 2026-10-17T04-42 UTC, plus the orchestrator's revision 7 pass and the validation of the next revision; reference it from the next findings ledger.

## Pending items (no finding)

- PC-1: final-head confirmation on the follow-on PR at S9 of the 18 pending criteria, the 19 new rows and the Memo-suite `AC-4` row, the PERF-5 CI time and the direct timing/shuffle runs (orchestrator notes (1), (2), (4), (6), (7), (8)).
- PC-3: `origin/main` moved from `7516050be` to `87f3d8996` (PR #968; documents of issue #962 and one comment line in `scripts/ci/CiChangeScope.psm1`; no hook or hook-suite path). P7-T2 merges it and repeats the Discovery and repository-scope runs before the push.
- DOC-2: the follow-on PR description, written by pr-author after S9 (orchestrator).
- The uncommitted P6-T30 check-off is committed by P7-T1/P7-T3 per the plan.
