# RI-2 exemption record (remediation cycle 1, P5-T5)

Timestamp: 2026-10-13T15-54
Command: (P5-T3) poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_rows_rem1_903.py <worktree>/artifacts/scratch-903/ci-rem1-903/pester-junit.xml <worktree>/artifacts/scratch-903/ci-rem1-903/pester-junit-linux-hooks.xml; (P5-T4) poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_line_dump_903.py <worktree>/artifacts/scratch-903/ci-rem1-903/powershell-coverage.xml <file> <first> <last> for Codex targets 353-372, Claude targets 353-372, Codex epic-scope 182-210, and poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_cov_extract_903.py <worktree>/artifacts/scratch-903/ci-rem1-903/powershell-coverage.xml files
EXIT_CODE: 0
Output Summary: ES-D1 (deny) and ES-D2 (allow) pass on Windows in the coverage job, yet Codex epic-scope lines 206 and 207 still record `ci` 0. The replaced baseline statements were also `ci` 0, so this is non-regression. Codex epic-scope per-file coverage is 89.09 (at least 85). Exemption applies.

Disposition: exempt (non-regression; coverage attribution anomaly)

## Evidence

- Baseline values of the replaced statements: `ci` 0 at baseline lines 202-217 (`if ($verdict.Verdict -eq 'deny')` at 202 and the `foreach` block at 206-215; dumped values 202 0, 203 0, 206-217 0), from `evidence/qa-gates/ps-coverage.2026-10-13T14-28.md` (row for `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206`).
- P5-T3 Windows pass state (`evidence/qa-gates/rem1-ps-rows.2026-10-13T15-54.md`): ES-D1 1/0/0 pass; ES-D2 1/0/0 pass; Decision suite 3/0/0 pass. ES-D1 drives `Get-OrchestrationEpicScopeDecision` to `deny`, which executes lines 206 and 207 in the coverage job.
- P5-T4 values (`evidence/qa-gates/rem1-ri-lines.2026-10-13T15-54.md`), Codex epic-scope: 183 0, 190 0, 191 0, 206 0, 207 0, 209 0. Lines 185-189 and 193-204 (the same function) record `ci` greater than 0.
- P1-T5 cause line (`evidence/other/rem1-ri2-investigation.2026-10-13T15-21.md`): `Cause: UNDETERMINED - the evidence rules out a failing or skipped row (every row that must execute 183, 190, 191, 206, 207 passes on Windows), a suite outside the coverage run (the same suite's selector rows are the only callers of lines 88-96, and those lines are covered), a coverage population gap (other lines of the same function are covered and `.codex/hooks` is in the population), a definition loaded from another file (the Codex gate dot-sources only `.codex/hooks` siblings), and a CI-only effect (the local XML is identical row by row); it does not identify why direct and gate-driven `Get-OrchestrationEpicScopeDecision` calls from the Codex epic-scope suite record no hits while the Claude suite's equivalent calls on the Claude copy do.`
- Additional observation from this run: a new suite that dot-sources the Codex epic-scope file directly (the Decision suite) also records no hits on 206, 207, or 209, so the anomaly is not specific to the gate-driven path or to the existing Codex epic-scope suite.
- Codex epic-scope per-file line coverage from the P5-T4 per-file table: 89.09 (49 covered, 6 missed); at least 85, so the exemption is valid.

Operator Follow-up: Pester 5.6.1 coverage in the Windows PoshQC job records `ci` 0 for `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 183, 190, 191, 206, 207, and 209 although passing rows in two suites (including ES-D1 in the new Decision suite, which reaches the `deny` return at 207) must execute them, while earlier lines of the same function record hits; the attribution cause is undetermined and should be recorded by the orchestrator for follow-up investigation (no issue is created here).
