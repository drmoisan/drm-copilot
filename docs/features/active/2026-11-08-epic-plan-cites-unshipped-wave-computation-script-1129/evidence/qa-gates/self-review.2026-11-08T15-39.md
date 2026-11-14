# self-review

Timestamp: 2026-11-08T15-39
Command: walk of docs/features/templates/policy_audit templates against git diff --name-status from the merge base of origin/main and HEAD
EXIT_CODE: 0
Output Summary:
0 FAIL rows; remediation cycle 1 (F1 and F2) verified against the Phase 0 baselines (see qa-gates/rem1-coverage-delta).

Premise correction recorded: of the newly scanned epic surfaces, only epic-progress-report cited an unshipped script (the repository-only forwarder scripts/dev-tools/Get-EpicProgressReport.ps1); the sentence now describes the wrapper without a path, the extractor is not narrowed, and the allowlist is unchanged.

| Item | Result | Evidence |
| --- | --- | --- |
| Policy 1.1 Core principles | PASS | New tests are in-memory or read committed files; Pester files keep AfterAll module removal |
| Policy 1.2 Scenarios and coverage | PASS | case-variant-keys covered by pytest corpus lane, Pester parity lane, in-memory Pester command test, and CLI fixture test; module-form and ./ prefix covered by two new pytest cases |
| Policy 1.2.1 Coverage vs Phase 0 baseline | PASS | qa-gates/rem1-coverage-delta |
| Policy 1.3 AAA and diagnostics | PASS | New tests follow arrange/act/assert with message-bearing assertions |
| Policy 1.4 No temp files or external deps | PASS | No temp file created |
| Policy 2.1 Baselines | PASS | evidence/baseline remains authoritative and was not re-captured |
| Policy 2.2 Design | PASS | Parse step and shape check only; Get-EpicWaveNumber unchanged |
| Policy 2.3 File size | PASS | All edited files below 500 lines |
| Policy 2.4 Naming, docs, comments | PASS | Help text states case-sensitive parsing; Python docstring and intent comments updated |
| Policy 2.5 Toolchain single pass | PASS | rem1 static artifacts, then Pester and pytest gates, all EXIT_CODE 0 |
| Policy 3A Python | PASS | rem1-py-black, rem1-py-ruff, rem1-py-pyright |
| Policy 3B PowerShell | PASS | rem1-ps-format, rem1-ps-pssa, rem1-ps-leak-scan |
| Policy 3C Bash | N/A | No bash file changed |
| Policy 3D JSON | PASS | Corpus and CLI fixture parsed by both lanes; LF endings |
| Policy 4A/4B Tests | PASS | rem1-py-pytest, rem1-ps-pester |
| Policy 5 Per-unit coverage | PASS | EpicWave.psm1 100.00% line; Python figures unchanged |
| Policy 6 Execution metrics | PASS | Pester 19708 tests 0 failures; pytest 16559 passed 0 failed |
| Policy 7 Quality checks | PASS | Leak scan 0 failures; no TypeScript or agent file changed so Jest and generator gates are unaffected |
| Policy 8 Gaps and exceptions | PASS | No suppression, no exclusion, no weakened assertion |
| Policy 9 Mirror parity | PASS | EpicWave.psm1 and epic-progress-report SKILL.md byte-equal to bundled copies (git diff --no-index --quiet exit 0); Pester contract suite and pytest mirror tests green |
| Code review: correctness of F1 | PASS | IDictionary check retains per-value array and string checks; exit 2 cases unchanged |
| Code review: correctness of F2 | PASS | Lookbehind retained so ../ links stay unmatched; surface-set equality test pins both runtimes |
| Code review: security and error handling | PASS | No new I/O; failures still exit 2 with EPIC_WAVE_USAGE |
| Feature audit: F1 acceptance | PASS | CLI returns {"A":1,"a":0} for {"a":[],"A":["a"]}, equal to the Python reference |
| Feature audit: F2 acceptance | PASS | Extractor reaches module form and ./ prefix; all eight Claude and seven Codex epic surfaces scanned |
| Verdict | PASS | Fully compliant |
