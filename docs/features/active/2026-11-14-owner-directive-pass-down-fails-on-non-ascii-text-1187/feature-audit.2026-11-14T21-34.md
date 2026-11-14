# Feature Audit: Owner-directive pass-down fails on non-ASCII text (#1187)

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187`
**Base Branch:** `main`
**Head Branch:** `bug/owner-directive-pass-down-non-ascii`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `1c652e60a61c71382100e584d5a9bccf584aa0e9`, equal to `origin/main` at review time)
- **Head branch/commit:** `bug/owner-directive-pass-down-non-ascii` (commit `aae55c0652c1110385f4220ce2c7672f80320954`, PR #1189)
- **Merge base:** `1c652e60a61c71382100e584d5a9bccf584aa0e9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 21:25:09 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 1c652e60a..aae55c065`
  - Feature evidence: `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` from the reviewer's Pester gate re-run at the head (`evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md`); two reviewer real-process probes (stdin decode under console code page 437; file-read decode)
- **Feature folder used:** `docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (38 files). CI on the PR was running concurrently (review_mode concurrent); AC-20 depends on it.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187/spec.md` — only source

### Acceptance criteria

1. AC-1: Claude dispatcher defines `Read-PreToolUseDispatchStandardInput` with an `OpenStream` seam; byte-level rows prove U+2014, U+201C/U+201D, U+1F600, BOM stripping, and invalid byte to U+FFFD.
2. AC-2: Claude `ReadPayload` default is `Read-ClaudeHookRawPayload -ReadStandardInput { Read-PreToolUseDispatchStandardInput }`; `HookPayload.psm1` not modified.
3. AC-3: Codex dispatcher defines `Read-CodexPreToolUseDispatchStandardInput` with the same behavior and rows; Codex `ReadPayload` default uses it.
4. AC-4: Parity row asserts equal reader bodies apart from the name.
5. AC-5: Decision write, dependency-guard tail emit, and trace write use `ConvertTo-Json -EscapeHandling EscapeNonAscii` in both dispatchers; rows prove ASCII output and exact round-trip.
6. AC-6: Pass-down relay match rows for each character (allowed verbatim, denied when substituted, digest equality).
7. AC-7: Ledger-append rows (append allowed, edit denied, altered-digest append denied).
8. AC-8: Decision-file rows with non-ASCII reasons; decision files remain existence-checked only.
9. AC-9: Stop-hook coverage check rows; no stop-hook production change.
10. AC-10: Ledger validation in the stop hook (matching hashes validate; mismatched hash rejected).
11. AC-11: B5 rows (U+1F600 digest equals SHA-256 of `F0 9F 98 80`; matching hash passes; hyphen-substituted hash fails); module not modified.
12. AC-12: Fail-before proof (Latin1 versus UTF-8 contrast row; recorded failing run before the production change).
13. AC-13: In-memory seams only; no temp files, no console encoding assignment, no `SetIn`, streams disposed, ASCII-only test sources.
14. AC-14: Bundle copies byte-identical; three push-down contract tests pass.
15. AC-15: Listed existing suites pass unchanged in assertion.
16. AC-16: Per-file PowerShell line coverage at least 85% for each changed production file.
17. AC-17: No changed or new file exceeds 800 lines; each changed or new test and production file stays below 500 lines.
18. AC-18: No copy of the execution-environment brief is modified.
19. AC-19: Comment-based help states the UTF-8 decode, ASCII-escaped output, and the per-process limitation (Claude).
20. AC-20: Full PowerShell toolchain loop passes in one pass, and CI on the PR head is green.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Claude reader | PASS | Reader at `.claude/hooks/invoke-pretooluse-dispatch.ps1` lines 43-71; 7 rows in `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1`; reviewer probe returned `2014 201C 201D D83D DE00` from piped bytes under code page 437 | `git diff 1c652e60a..HEAD -- .claude/hooks/invoke-pretooluse-dispatch.ps1`; real-process probe via `sh` launcher | Fail-before shows the 7 rows failing before the change |
| 2 | AC-2 Claude ReadPayload default | PASS | Default text pinned by AST row; `.claude/lib/` absent from the branch diff | `git diff --name-only 1c652e60a..HEAD` | Redirect probe and fallbacks unchanged because `HookPayload.psm1` is untouched |
| 3 | AC-3 Codex reader and default | PASS | Reader and 7 rows in `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1`; AST pin of default; probe decoded exactly | `git diff 1c652e60a..HEAD -- .codex/hooks/invoke-pretooluse-dispatch.ps1` | |
| 4 | AC-4 Reader parity | PASS | `PreToolUseDispatch.Parity.Tests.ps1` row compares `Body.Extent.Text` ordinally | diff inspection | Reviewer confirmed the bodies are textually equal in the diff |
| 5 | AC-5 ASCII-escaped output | PASS | Three write sites per dispatcher carry `-EscapeHandling EscapeNonAscii`; 3 output rows per dispatcher assert no character above U+007F and exact `ConvertFrom-Json` round-trip | diff inspection; final Pester gate | |
| 6 | AC-6 Relay match | PASS | `enforce-owner-directive-pass-down.NonAscii.Tests.ps1` relay rows (allow 3, deny 3, digest 3) | final Pester gate (0 failures) | Substitutes: hyphen, straight quotes, non-BMP removed |
| 7 | AC-7 Ledger append | PASS | Ledger rows: append allowed (3), edit denied (1), altered digest denied (3) with `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED` | final Pester gate | |
| 8 | AC-8 Decision files | PASS | Pass-down decision-write rows (3) and decision-line parse/accept rows (6) with `Should -BeExactly` on the reason | final Pester gate; diff shows no production change | Decision files remain existence-checked |
| 9 | AC-9 Stop-hook coverage | PASS | Rows in `validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1` over the mocked `Get-CheckpointFileContent` seam: covered item allowed; missing OD-3 reported | final Pester gate; no stop-hook file in the diff | |
| 10 | AC-10 Stop-hook ledger validation | PASS | Matching-hash ledger rows validate; mismatched hash reports `OWNER_DIRECTIVE_LEDGER_INVALID ... text_sha256` | final Pester gate | |
| 11 | AC-11 B5 | PASS | Three B5 row groups in `OrchestratorStateOwnerDirectives.Tests.ps1`; module not in the diff | final Pester gate | |
| 12 | AC-12 Fail-before | PASS | Contrast row in the NonAscii file; `evidence/regression-testing/fail-before.2026-11-14T19-40.md` records EXIT_CODE 1 with 26 expected failures at unchanged production state, before commit `d1665e12e` | `git log` order: `9999abd55` (tests) before `d1665e12e` (fix) | Clock timestamps; no absolute paths (scan of the feature folder found none) |
| 13 | AC-13 In-memory seams | PASS | No added test line uses temp files, console encoding assignment, or `SetIn`; 0 non-ASCII lines across all changed `.ps1` files; disposal row present | pattern search of added test lines; byte scan with a non-ASCII class | The default-seam row opens and disposes the stdin handle without reading (Info in the code review) |
| 14 | AC-14 Bundle identity and contract tests | PASS | `cmp` reported both bundle copies identical to canonical; final pytest gate 16928 passed including the three contract files | `cmp <canonical> <bundle>` | |
| 15 | AC-15 Existing suites | PASS | Final Pester gate 26567 passed, 0 failed over the full tree, and the reviewer's re-run at the head 26830 passed, 0 failed (`evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md`); the script-tail rows keep their assertions and add a `Should -Invoke` check | `evidence/qa-gates/final-qc-pester.2026-11-14T21-17.md` | `codex-pretooluse-integration.Tests.ps1` is CI-only by policy; recorded non-blocking deviation |
| 16 | AC-16 Per-file coverage | PASS | Claude dispatcher 42/42 = 100%; Codex dispatcher 40/40 = 100% | reviewer parse of `artifacts/pester/powershell-coverage.xml` after the reviewer's gate run at the head | Report written 2026-11-14T21:51:34Z at `aae55c065` (`evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md`) |
| 17 | AC-17 File sizes | PASS | Largest changed file 423 logical lines; all below 500 | logical line count per file | |
| 18 | AC-18 Brief unchanged | PASS | No `execution-environment` path in the branch diff | `git diff --name-only 1c652e60a..HEAD` | |
| 19 | AC-19 Help text | PASS | Claude `.DESCRIPTION` states the UTF-8 decode, ASCII-escaped output, and per-process limitation; Codex `.DESCRIPTION` states decode and output | diff inspection | |
| 20 | AC-20 Toolchain and CI | UNVERIFIED | Local part passed (static, Pester, pytest final gates, exit 0); CI on `aae55c065` was in progress at review time | `gh pr checks 1189` | Pending CI; owned by the orchestrator at S9; not a blocking finding of the branch content |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-20, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. AC-20 depends only on CI on the reviewed head.

**Recommended follow-up verification steps:**

1. At S9, confirm CI on PR #1189 is green at the final head and check off AC-20.
2. Optional after merge: one live delegation relaying an em-dash directive.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

AC-1 to AC-19 were already checked off by the executor (P3-T4); the reviewer's PASS evaluations confirm them, so no source-file checkbox change was made. AC-20 stays unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187/spec.md`
- Total AC items: 20
- Checked off (delivered): 19
- Remaining (unchecked): 1
- Items remaining: AC-20: The full PowerShell toolchain loop (Invoke-Formatter, PSScriptAnalyzer, Pester through the test-execution launcher in parallel, and the Python contract tests) passes in a single pass, and CI on the PR head is green.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 20 | 19 | 1 | Checkbox-backed; AC-20 pending CI |
