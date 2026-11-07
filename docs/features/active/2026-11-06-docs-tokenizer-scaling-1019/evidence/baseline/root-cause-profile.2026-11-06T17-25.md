# Root-Cause Profile - Issue 1019

Timestamp: 2026-11-06T17-25
Command: sh SCRATCH/issue-1019-callcost.sh (SCRATCH/issue-1019-callcost.ps1 on PowerShell 7.6.9, Windows 10.0.26300, no experimental features enabled); sh SCRATCH/issue-1019-profile.sh (SCRATCH/issue-1019-tokenscale.ps1, one process per module copy); sh SCRATCH/issue-1019-before.sh (SCRATCH/issue-1019-before.ps1)
EXIT_CODE: 0
Output Summary: Verified. A PowerShell call to a .NET method costs time proportional to the length of a string argument (about 45 microseconds per 1,000 characters; 100 ms per call at 1,000,000 characters). The unfixed module is quadratic for all source shapes. The candidate, commit 1332ba34f, is linear for names-only sources and remains quadratic for string-heavy sources, because it keeps one Regex.Match with the whole source after every string token. AMSI attribution is not established by these measurements.

All measurements ran on a copy of the code before any production change on this branch. Host load varied; the ratios between rows carry the evidence, not the absolute values.

## Call Cost Against String Length

Microseconds per call from PowerShell, one warm-up pass discarded. 2,000 iterations through 100,000 characters, 200 iterations at 1,000,000 characters.

| Operation | 1,000 | 10,000 | 100,000 | 1,000,000 |
| --- | --- | --- | --- | --- |
| `[string]::CompareOrdinal($s, i, q, 0, 1)` (string as argument) | 49.53 | 465.84 | 3613.33 | 101578.77 |
| `$regex.Match($s, i)` (string as argument) | 47.06 | 466.87 | 3475.62 | 92135.91 |
| `[string]::CompareOrdinal($slice, q)` (one-character slice as argument) | 2.89 | 2.90 | 1.94 | 4.93 |
| `$s.Substring(i, 1)` (string as invocant) | 3.06 | 2.47 | 2.19 | 1.88 |
| `$s.Length` (property) | 0.75 | 0.59 | 0.16 | 0.17 |
| `$s[i]` (indexer) | 0.50 | 0.54 | 0.13 | 0.16 |
| Advanced function with `[string] $Text`, `-Text $s` (parameter binding) | 11.67 | 18.11 | 4.57 | 7.58 |
| `$match.NextMatch()` (no argument) | 3.08 | 3.09 | 4.07 | 578.25 |
| Control: compiled C# loop calling `string.CompareOrdinal($s, 0, q, 0, 1)` | 0.0136 | 0.0022 | 0.0033 | 0.0025 |

Reading of the table:

- Only a string passed as an argument from PowerShell is proportional to length. Being an invocant, an indexer target, a property target, or a bound parameter is flat.
- The compiled C# control is flat, so the cost lies in the PowerShell method-invocation layer and not in the .NET method.
- The `NextMatch` cell at 1,000,000 characters is an artifact of the measurement: its 200-iteration loop includes the one setup `Match` call, about 100 ms, which adds about 500 microseconds per iteration.
- Hypothesis status: length proportionality is confirmed. The cause within the invocation layer (the AMSI hypothesis) is untested and remains unverified. No measurement here disabled or inspected AMSI.

## Tokenizer Time Against Source Size

Milliseconds for one `Get-DocsPythonToken` call. Every run reported 0 diagnostics.

| Module | Shape | 2,000 units | 4,000 units | 8,000 units | 16,000 units |
| --- | --- | --- | --- | --- | --- |
| Unfixed | names (`a `, 2 chars each) | 645 | 2179 | 9859 | 42443 |
| Unfixed | strings (`'s' `, 4 chars each) | 1825 | 7316 | 33533 | 119291 |
| Unfixed | one long string body (2 chars per unit) | 101 | 406 | 1525 | 5689 |
| Candidate | names | 179 | 176 | 373 | 759 |
| Candidate | strings | 818 | 2919 | 12253 | 35469 |
| Candidate | one long string body | 23 | 45 | 93 | 128 |

Reading of the table:

- Unfixed: each doubling multiplies the time by about four in all three shapes.
- Candidate: names and long string bodies are about linear. The string shape still multiplies by about four per doubling, at about 2.2 ms per string token at 64,000 characters. That is the `Regex.Match($source, $position)` restart, which costs about 45 microseconds per 1,000 characters of source for each string token.
- The projected candidate cost for a 1,048,576-character source of about 262,144 string tokens is more than two hours, so the candidate does not remove the defect for string-heavy sources.

## Other Length-Proportional Calls Checked in the Module

Every member call in `Get-DocsPythonToken` and `Read-DocsPythonStringEnd` was read against the call-cost table:

| Call in the candidate module | Argument or target | Result |
| --- | --- | --- |
| `$script:DocsPythonTokenPattern.Match($source, $position)` in the loop | whole source as argument, once per string token | Length-proportional. Missed by the candidate. |
| `$source.Substring(...)`, `$Text.Substring(...)` | whole source as invocant | Flat. |
| `Read-DocsPythonStringEnd -Text $source` | parameter binding | Flat. |
| `$script:DocsPythonCodingCookiePattern.Match($lines[n])` | first two source lines as argument, outside the token loop | Bounded to two calls per run. A one-line source costs two whole-source calls, which is not per-token. |
| `$token['Text'].LastIndexOf`, `ToCharArray`, `$prefix.IndexOfAny` | one token, not the source | Bounded by token length, so linear in total. |

The same call pattern exists in other modules, for example `$script:CsWhitespace.Match($source, $position)` in `DocsCSharpTokens.psm1`. They are outside this item and were not measured here.

## Token-Limit Test on the Unfixed Module

`tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` holds the test `reports PYTHON_TOKEN_LIMIT above 262,144 tokens`, which tokenizes two sources of about 524,288 characters.

- Measured: 47.236 ms per token at 525,289 source characters (1,000 tokens scanned, ended by an unclassified character at that point).
- Extrapolated: 524,287 tokens x 47.236 ms x 2 calls = about 49,530 s without coverage. This is an extrapolation, not a run.
- The earlier figure of 43,342.74 s on the 1034 branch (`evidence/qa-gates/pester-coverage.2026-11-06T17-02.md` in the 1034 feature folder) is the same order of magnitude. That figure was not reproduced by a full run; the bounded run is recorded in `suite-duration-before.*.md`.
