# Code Review (issue #736)

- Branch: `bug/completion-consistency-codex-copy-and-fail-open-divergence-exec-736`
- Base: `origin/epic/enforcement-hook-precision-integration`
- Reviewed: 2026-10-08
- Scope: `.claude/hooks` and `.codex/hooks` completion-consistency hooks and helpers, four bundled mirrors, ten Pester suites (seven new: three Claude and four Codex; three modified: two Claude and the Codex transport suite).

## Overall Assessment

The change is correct, small in surface, and consistent between the two trees. The reviewer ran the in-scope suites (284 tests, 0 failures) and confirmed byte-identical mirrors. No blocking defect was found.

Blocking findings: 0. Non-blocking observations: 6.

## Production Code

### Helpers (`enforce-completion-helpers.ps1`, both trees, 268 lines each)

- `Get-EditReplaceAllFlag` avoids the `[bool]'false'` trap: a boolean is returned as is, a string is compared as trimmed `-ieq 'true'`, and every other type returns `$false`. This matches FR-1 and the spec's replace_all rule. Correct.
- `Invoke-SingleOccurrenceEdit` is pure (no I/O), normalizes CRLF to LF on all three strings, searches ordinally, and detects ambiguity with a second `IndexOf` that starts after the end of the first match. That gives non-overlapping counting (`aa` in `aaa` is one occurrence). The replace-all branch uses `String.Replace(string, string)`, which is ordinal and literal in .NET, so `$` and regex metacharacters in `new_string` stay literal. The single branch splices by `Substring`. Correct and simple.
- The empty `old_string` guard is evaluated after normalization and returns `no-old_string` before any search. Correct.
- Observation O-1 (non-blocking): the helper parameters are declared `[AllowNull()] [string]`. PowerShell coerces `$null` to `''` for a `[string]` parameter, so a null `Text` yields `old_string-not-found` rather than an error. This fails closed and is consistent with the spec; no change needed.

### Hooks (`enforce-completion-consistency.ps1`)

- `Resolve-EditedCheckpointContent` now has a mandatory `-CheckpointPath` on both surfaces and passes it to the reader unchanged. The Codex relative literal is gone (Defect 1).
- The reader call is wrapped in a narrow `try/catch` that returns `checkpoint-unreadable`. The catch does not swallow silently: it converts to a named cause that the decision function turns into a structured deny. This satisfies the "no broad catch-all without propagation" rule.
- Null reader result maps to `checkpoint-missing`; zero-length maps to `checkpoint-empty`. `Get-CheckpointFileContent` was adjusted so an existing empty file returns `''` rather than `$null`, which keeps the two causes distinguishable. Correct.
- The decision function keeps the gate order (envelope, empty `file_path`, non-checkpoint allow) before any reader call, then distinguishes Write (property `content` present) from Edit. The empty-Write deny uses `-contains 'content'`, which fixes the former `if (-not $content)` ambiguity.
- A single `ConvertTo-CompletionDenyDecision` helper builds the deny object, removing one inline duplicate on the new paths. The reason format preserves the `COMPLETION_CONSISTENCY_BLOCKED:` token and the phrase `replaced through an unresolved patch`, so the transport suite markers still match. Verified by the reviewer's run of `codex-pretooluse-transport.Tests.ps1`.
- The Codex header was corrected (FR-6) and the Claude header was updated to describe fail-closed behaviour.
- Observation O-2 (non-blocking): the deny wording "cannot be deleted, emptied, or replaced through an unresolved patch (old_string-ambiguous)" reads slightly oddly for causes such as `old_string-ambiguous`, since an ambiguous patch is not literally an "unresolved patch" in every sense. The spec mandates this wording to keep existing test markers, so no action is recommended.
- Observation O-3 (non-blocking): both trees keep duplicate copies of the new helpers and `ConvertTo-CompletionDenyDecision`. This follows Decision D3 and the `.claude`/`.codex` runtime-surface separation (NFR-9). Drift risk is covered by SHA-based tests and by the C5b follow-up (#737). Acceptable.
- Observation O-4 (non-blocking): the Claude entrypoint still has no outer `try/catch`; only the reader call is guarded. Other throwing paths (for example in `Resolve-ClaudeHookToolInput`) were not in scope and are not changed by this branch.
- Observation O-5 (non-blocking, documented difference): invalid-JSON patched or written content still allows on Claude and denies on Codex. This is the documented FR-5 / Decision D5 divergence and is recorded as follow-up item 2.

## Test Code

- The seven new suites and three modified suites follow the repository layout and Arrange/Act/Assert structure. Test names state the scenario and expected outcome.
- Determinism and hermeticity: no temp files, `TestDrive`, `Start-Sleep`, or working-directory dependence. Default-reader tests resolve committed fixtures from `$PSScriptRoot` and include a precondition `It` that fails clearly if fixture tokens change.
- Reader seams are injected as script blocks rather than mocking, consistent with existing suites.
- The former relative-path default-reader row in `enforce-completion-consistency.Tests.ps1` was replaced with an injected-reader row; the three allow-on-unresolved rows were flipped to deny; the file stays at 491 lines.
- `codex-pretooluse-transport.Tests.ps1` shrank from 492 to 450 lines; the five rows that pinned the relative literal were removed and re-homed into the new Codex edit-target and edit-semantics suites, so coverage of the behaviour moved rather than disappeared.
- Observation O-6 (non-blocking): AC-8 is verified at decision level (the Claude entrypoint is not run in process). The AC explicitly permits this when the entrypoint cannot be run in process, and the entrypoint calls only `Invoke-CompletionConsistencyDecision`, so the conversion is exercised.
- The `SuppressMessageAttribute` for `PSReviewUnusedParameter` on a bare `param()` follows the pattern of neighbouring suites; PSScriptAnalyzer reports zero findings for all 14 files (`p5-analyze.md`).

## Security and Safety

- No new write path, network call, or process invocation. The hook remains read-only validation.
- Fail-closed on every uncertain checkpoint state. The only new allow paths are unchanged (non-checkpoint target, missing `file_path`, non-completion content). The reader is never called for non-checkpoint targets, so no non-checkpoint target is newly denied.
- Residual risk accepted in the spec: a false deny when the hook's view of a file diverges from the Edit tool's view (for example curly-quote normalization).

## Style and Maintainability

- Functions are small and focused; pure logic is separated from I/O (helpers pure, reader injected).
- Naming follows approved-verb PascalCase for functions and descriptive cause identifiers.
- Comments are factual; tonality grep found no promotional or hyperbolic language.

## Findings Table

| ID | Severity | Summary | Blocking |
|---|---|---|---|
| O-1 | Info | Null `Text` coerces to empty and fails closed | No |
| O-2 | Info | Deny wording is mandated by existing test markers | No |
| O-3 | Info | Duplicated helpers per tree by design (D3) | No |
| O-4 | Low | Claude entrypoint has no outer guard beyond the reader call | No |
| O-5 | Info | Invalid-JSON Claude-allow versus Codex-deny divergence retained | No |
| O-6 | Info | AC-8 proven at decision level | No |

Blocking findings: 0.
