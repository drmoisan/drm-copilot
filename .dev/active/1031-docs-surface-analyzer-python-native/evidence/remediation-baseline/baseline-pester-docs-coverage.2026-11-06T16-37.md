# [P0-T6] Remediation baseline: Pester with coverage over the docs suites (PARTIAL)

Timestamp: 2026-11-06T16-37
Command: branch-current Invoke-PoshQCTest with coverage, launched by `sh SCRATCH/issue-1031-pwsh.sh issue-1031-pester-gate.ps1 -Paths <every tests/scripts/claude-lib/docs/*.Tests.ps1 except DocsPythonTokens.Tests.ps1>`
EXIT_CODE: 0
Output Summary: PARTIAL. artifacts/pester/pester-junit.xml: tests 2071, failures 0, errors 0, skipped 0, suites 101. DocsPythonTokens.Tests.ps1 has NO RESULT in this baseline, so the command the plan states was not completed as written, and [P0-T6] stays unchecked. Overall line coverage over the 329-file population 28.43% (9040/31800), which is low because only the docs suites ran.

## Line coverage (artifacts/pester/powershell-coverage.xml)

| File | Line % (covered/total) |
|---|---|
| `LIB/DocsAnalyzerPythonNative.psm1` | 100.00 (89/89) |
| `LIB/DocsPythonNativeProtocol.psm1` | 100.00 (132/132) |
| `LIB/DocsAnalyzerRegistry.psm1` | 100.00 (135/135) |
| `LIB/DocsInventory.psm1` | 100.00 (121/121) |
| `LIB/Invoke-DocsCommand.ps1` | 87.82 (137/156) |

## Deviation from the plan (executor decision, not plan-authorized)

- The first run, over all of `tests/scripts/claude-lib/docs` with coverage, was stopped by the executor after about 3 hours inside DocsPythonTokens.Tests.ps1 (67 files had completed; JUnit is written only at the end, so that run produced no counts).
- The executor then split the run: the other suites with coverage (above), and DocsPythonTokens.Tests.ps1 alone without coverage. The executor stopped the second run after about 30 minutes, once the cause below showed it would need hours, so it produced no counts either.
- DocsPythonTokens.Tests.ps1 calls only the tokenizer. That the five files above would report the same figures with it included is an inference; it was not measured.

## Cause of the runtime

The time goes to PowerShell's .NET method-call path, not to the regex and not to a hang in the sense of no progress.

| Probe (SCRATCH/issue-1031-token-cause.ps1, -scale, -isolate) | Result |
|---|---|
| `Get-DocsPythonToken`, token count doubling (n = names) | n=1000 289 ms; 2000 771 ms; 4000 3342 ms; 8000 16161 ms; 16000 49985 ms (ratio about 4 per doubling, about 3 at the last step) |
| Same regex and same text, whole scan in a C# loop | n=128000: 255999 matches in 40 ms |
| 8000 PowerShell calls of `$pattern.Match($source, 0)` | n=8000 5635 ms; n=32000 29510 ms; n=128000 119895 ms |
| 8000 PowerShell calls of `[string]::IsNullOrEmpty($source)` | n=8000 6142 ms; n=32000 26872 ms (no regex involved) |
| 8000 PowerShell reads of `$source.Length` | n=8000 10 ms; n=32000 2 ms |

- A PowerShell method call that receives the source string costs time proportional to the string length. `Get-DocsPythonToken` in `.claude/lib/docs/DocsPythonTokens.psm1` makes one `$script:DocsPythonTokenPattern.Match($source, $position)` call per token, so the function is quadratic in input size.
- `It 'reports PYTHON_TOKEN_LIMIT above 262,144 tokens and accepts exactly 262,144 (built in test code, below 1,048,576 bytes)'` tokenizes about 524,000 characters twice. Extrapolated from the probes, that is roughly 9 hours on this host without coverage. This figure is an estimate, not a measurement.
- Likely but unconfirmed mechanism: PowerShell's AMSI method-invocation logging on Windows, which would pass each argument to the scanner. It was not tested in isolation and was not disabled. The file came from 1022 (commit 1c4e46dfe) and is not specific to this branch.
- Host: PowerShell 7.6.9 on Windows 10.0.26300. Whether Linux or CI Windows runners show the same per-call cost was not measured on this host.
