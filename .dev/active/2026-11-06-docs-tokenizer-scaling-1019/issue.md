# 2026-11-06-docs-tokenizer-scaling

- Work Mode: minor-audit
- Issue: #1019 (adopted from epic decomposition; no new issue)
- Integration branch: epic/documentation-estate-tooling-integration

## Problem / Why

`Get-DocsPythonToken` and `Read-DocsPythonStringEnd` in `.claude/lib/docs/DocsPythonTokens.psm1` (issue 1022) make `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` impractically slow on the Windows host. Runs on the 1031 and 1034 branches did not finish in about three hours.

Profiling on this branch (`evidence/baseline/root-cause-profile.*.md`) measured the cause: a PowerShell call to a .NET method that receives a string argument costs time proportional to that string's length, about 45 microseconds per 1,000 characters. A property read, an indexer, a method call on the string as invocant, and cmdlet parameter binding are flat in length, and the same .NET call from compiled C# is flat. The module passes the whole source as an argument once per token (`Regex.Match`) and once per string-body character (`[string]::CompareOrdinal`), so tokenizing is quadratic in source length.

The candidate fix, commit 1332ba34f on `origin/feature/docs-enforcement-and-ci-1034-r2`, removes the per-character calls and most per-token calls, but keeps one `Regex.Match` with the whole source after every string token. The same profile shows the candidate linear on a names-only source and still quadratic on a string-heavy source.

## Implementation Intent

Apply the candidate production hunks byte for byte, so that 1034 can merge this change without a conflict in those lines. Then remove the remaining per-string-token cost: the loop lexes a bounded window of the source, so no call in a loop passes the whole source as an argument. Tokens, diagnostics, and every other 1022 tokenizer contract are unchanged. Add a structural regression guard that does not depend on wall-clock time. Mirror the module into the bundle.

## Acceptance Criteria

- [x] Root cause is verified by measurement before any production change, and the measurements (call cost against source length, tokenizer time against source size for the unfixed module and the candidate) are recorded under `evidence/baseline/`.
- [x] The production hunks of commit 1332ba34f are present byte for byte in `.claude/lib/docs/DocsPythonTokens.psm1`, and no loop in the module passes the whole source to a .NET method as an argument.
- [x] Tokenizer time is approximately linear in source length for a names-only source and a string-heavy source: doubling the source no more than about doubles the time, recorded under `evidence/qa-gates/`.
- [x] A structural regression guard in `DocsPythonTokens.Tests.ps1` uses no sleep, timing threshold, or temporary file, and is recorded failing on the unfixed module and on the candidate module and passing on the fixed module (`evidence/regression-testing/`).
- [x] Behavior is unchanged: the existing `DocsPythonTokens.Tests.ps1` cases pass, new window-boundary cases pass, and a differential run over the unfixed and fixed modules reports identical tokens and diagnostics (`evidence/regression-testing/`).
- [x] `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPythonTokens.psm1` is byte-identical to the module, and the push-down resource contract and manifest tests pass.
- [x] The PowerShell toolchain (format, analyze, test) passes on the changed files, `DocsPythonTokens.psm1` line coverage is at least 85%, and the before and after suite durations are recorded under `evidence/qa-gates/`.
- [x] CI is green on the pull request head and the pull request is merged into `epic/documentation-estate-tooling-integration` (CI-dependent).

## Dependencies / Risks

- 1031 and 1034 wait on this change. The 1034 tip has reverted the candidate hunks, and this change carries them; the merge is checked with `git merge-tree` before review.
- Other modules, for example `DocsCSharpTokens.psm1`, also call `Regex.Match` with a whole source inside a loop. Their scaling is outside this item and is recorded in the root-cause evidence.

## Verification Steps

See the acceptance criteria and the plan in this folder.

## Evidence Checklist

- [ ] baseline
- [ ] targeted verification
- [ ] end-state
