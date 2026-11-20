# Phase 0 — Remediation Documents Read ([P0-T2])

Timestamp: 2026-09-07T19-30
Task: [P0-T2]
Command: `cat` / `sed -n` / `Read` over each document and line range listed below
EXIT_CODE: 0

## Documents read, with the line ranges read

| # | Document (feature-folder relative) | Range read | Lines in file |
|---|---|---|---|
| 1 | `remediation-inputs.2026-09-07T17-44.md` | 1-266 (full) | 266 |
| 2 | `policy-audit.2026-09-07T17-44.md` §8 "Gaps and Exceptions" | 422-581 | 801 |
| 3 | `policy-audit.2026-09-07T17-44.md` §10 "Compliance Verdict" | 627-686 | 801 |
| 4 | `code-review.2026-09-07T17-44.md` findings table | 66-90 | 286 |
| 5 | `feature-audit.2026-09-07T17-44.md` AC inventory and AC evaluation, incl. both adjudications | 30-154 | 243 |
| 6 | `spec.md` | 1476-1495 | 1745 |
| 7 | `spec.md` | 1550-1560 (covers the required 1554-1557) | 1745 |

## Transcription — the criterion at `spec.md` line 1480 (AC-07), current unchecked text

Lines 1480-1483 verbatim:

```
- [ ] The five trigger pattern strings in the preimplementation gate are **byte-unchanged**, and
      the promotion hook's four forbidden-token literals, its two `gh` expressions, and the
      pr-author hook's `gh pr create` / `gh pr edit` expressions are likewise byte-unchanged;
      verified by diff inspection recorded in the scope-and-size evidence artifact.
```

First line begins `- [ ]`: CONFIRMED — the criterion is currently unchecked.

## Transcription — the criterion at `spec.md` line 1488 (AC-09), current unchecked text

Lines 1488-1493 verbatim (em dashes rendered as the source characters):

```
- [ ] **No existing denial is weakened.** Both existing decision suites pass with no assertion
      modified except the single reversed heredoc `It` on each side; the existing Claude gate suite
      denials (lines 112–149), the Codex `Test-ImplementationCommand` classification table
      (lines 348–358, including `git commit -m "wip"` returning `$true`), the #539 D4 rows 14a–14d
      chained relocating denials, the absolute-path suites, and the existing pr-author suites all
      pass unmodified.
```

First line begins `- [ ]`: CONFIRMED — the criterion is currently unchecked.

## Both currently begin `- [ ]`

Recorded explicitly as required by the task: the criterion at `spec.md` line 1480 and the criterion
at `spec.md` line 1488 both currently begin with the unchecked checkbox token `- [ ]`.

For completeness, the third criterion this plan touches only by leaving it alone, at `spec.md`
line 1554, also currently begins `- [ ]`:

```
- [ ] **Issue #591 is recorded as superseded by issue #545 and closed on merge.** No separate
```

## Findings this execution carries forward

- **R-1 (blocking, policy-audit G-1 / code-review CR-1 / feature-audit AC-09 headline).**
  `Get-BlockedPatternMatch` leg 1 compares the six denylist literals against `$segment.Tokens` and
  never `$segment.ScanText`. `ConvertTo-CommandLineToken` collapses a balanced quoted span into one
  token, so a multi-token literal cannot form a contiguous token run inside a wrapper's quoted
  argument. `bash -c "rm -rf /tmp/x"` returns `$null` and ALLOWS where the pre-change
  `String.Contains` returned `rm -rf` and DENIED. The remediation plan extends the inputs' suggested
  two-disjunct shape to three disjuncts, adding `$segment.Unbalanced`, so that the leg-1 raw-scan
  condition matches the scanner's own three-clause `ScanText` selection at
  `hook-command-scanner.ps1` line 151 exactly.
- **R-2 (non-blocking, documentation only, policy-audit G-2 / code-review CR-2).** AC-07's pr-author
  clause is superseded by the D12 call-site rewrite table and by the epic-base-branch criterion at
  `spec.md` line 1620. Amend the criterion; change no code.
- **R-3 (out of scope here).** AC-22 is a gate condition on `pr-author`; the criterion at line 1554
  stays unchecked.
- **Do-not-do list carried into execution:** do not weaken any denial; do not change the six
  `Get-BlockedBashPattern` literals or `$script:CdChainedReadCommandPattern`; do not modify policy
  documents; do not add a tenth hook; do not fix `enforce-pr-author-skill.Tests.ps1` or
  `codex-pretooluse-integration.Tests.ps1`; do not fix EA-3; do not add a coverage `exclude` entry or
  remove a `CodeCoverage.Path` entry; do not break canonical/bundle parity; do not exceed 500 lines;
  do not use the MCP test runner for any coverage figure; do not write evidence outside
  `<FEATURE>/evidence/<kind>/`.
- **Two tolerated pre-existing failures** (policy-audit G-7), both ambient-state failures in
  unmodified suites and green on a clean CI checkout:
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` case
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, and
  `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` case
  `allows every registered handler for every tool name its own matcher admits`.

Output Summary: All five required documents read at the stated ranges, plus both required `spec.md`
ranges. The AC-07 criterion at line 1480 and the AC-09 criterion at line 1488 are transcribed
verbatim above and both currently begin `- [ ]`. EXIT_CODE 0. No document modified by this task.
