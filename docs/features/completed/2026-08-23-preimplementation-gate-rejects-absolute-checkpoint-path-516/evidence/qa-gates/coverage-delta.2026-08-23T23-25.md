# Final QA Gate 8 — Coverage Delta and Changed-Line Coverage (issue #516)

Timestamp: 2026-08-24T16-39
Command: comparison of the [P0-T11] baseline counters with the [P4-T7] post-change counters, plus a per-line read of `artifacts/pester/powershell-coverage.xml` for every line number the diff changed in either canonical copy
EXIT_CODE: 0

## Per-File Coverage Delta

| File | Baseline ([P0-T11]) | Post-change ([P4-T7]) | Delta | Decreased |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 90.00% (99/110) | **90.09%** (100/111) | **+0.09 pp** | **No** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 99.18% (121/122) | **99.19%** (122/123) | **+0.01 pp** | **No** |
| Aggregate | 96.17% (6407/6662) | **96.17%** (6409/6664) | **0.00 pp** | **No** |

Neither per-file percentage decreased against baseline. Both rose slightly: each file gained exactly one instrumented line and that line is covered, so the covered count and the total count each rose by one and the ratio improved marginally. The missed-line count is unchanged in both files — 11 in the Claude copy and 1 in the Codex copy — confirming the change introduced no new uncovered line.

**Acceptance condition — neither per-file percentage decreased against baseline: satisfied.**

## Changed Lines and Their Covered Status

Changed line ranges, taken from `git diff -U0` against the substituted baseline `fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24`:

```text
.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
  @@ -62   +62,7   function Test-FeatureDocumentationOrEvidencePath   -> new lines 62-68
  @@ -73,2 +79,23  function Test-ImplementationPath                  -> new lines 79-101

.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
  @@ -65   +65,7   function Test-FeatureDocumentationOrEvidencePath   -> new lines 65-71
  @@ -76,2 +82,27  function Test-ImplementationPath                  -> new lines 82-108
```

Per-line coverage status for every line in those ranges, read from the `<line nr=... ci=.../>` elements of the JaCoCo output. A line is covered when its covered-instruction count `ci` is greater than zero:

```text
=== .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
  line  68 : COVERED   (ci=1)
  line  98 : COVERED   (ci=1)
  line  99 : COVERED   (ci=2)
  line 100 : COVERED   (ci=1)
  changed lines in range    : 30
  instrumented (executable) : 4
  covered                   : 4
  uncovered                 : 0

=== .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
  line  71 : COVERED   (ci=1)
  line 105 : COVERED   (ci=1)
  line 106 : COVERED   (ci=2)
  line 107 : COVERED   (ci=1)
  changed lines in range    : 34
  instrumented (executable) : 4
  covered                   : 4
  uncovered                 : 0
```

**Acceptance condition — no changed line is reported uncovered: satisfied. Zero uncovered changed lines in either canonical copy.**

## Why Only Four of the Changed Lines Are Instrumented

Of the 30 changed lines in the Claude copy and the 34 in the Codex copy, only 4 in each are executable and therefore appear in the coverage report. The remainder are comment lines recording the case-sensitivity choice, the accepted segment-anchored widening, and the deliberate `..`-hop miss, plus the closing braces of the new `foreach` block. Comments and structural braces are not instructions and are not instrumented by Pester, so their absence from the coverage report is expected and is not an uncovered line.

The four instrumented lines per file are exactly the four executable statements this change introduces:

| Line (Claude / Codex) | Statement | Covered by |
| --- | --- | --- |
| 68 / 71 | `return $NormalizedPath -cmatch '(^\|/)docs/features/active/'` | the documentation-exemption allow cases and the case-varied documentation deny case |
| 98 / 105 | `foreach ($checkpoint in $script:CheckpointPaths) {` | every case that reaches the checkpoint loop |
| 99 / 106 | `if ($NormalizedPath -match ('(^\|/)' + [regex]::Escape($checkpoint) + '$')) {` | every checkpoint spelling case, `ci=2` reflecting both the match and non-match outcomes |
| 100 / 107 | `return $false` | every checkpoint allow case |

Every executable line the change introduces is exercised by the new suites. There is no coverage regression on changed lines, which `.claude/rules/powershell.md` designates a blocking finding when present.

Output Summary: Neither canonical hook copy lost coverage. The Claude copy moved from 90.00% to 90.09% and the Codex copy from 99.18% to 99.19%, with the aggregate steady at 96.17% and the missed-line count unchanged in both files. Of the 30 and 34 changed lines respectively, 4 in each are executable; all 4 are reported COVERED in `artifacts/pester/powershell-coverage.xml`, giving zero uncovered changed lines. Both acceptance conditions are satisfied.
