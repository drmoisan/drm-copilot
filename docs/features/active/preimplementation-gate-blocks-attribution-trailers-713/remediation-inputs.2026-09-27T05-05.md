# Remediation Inputs — Cycle 1 (issue #713, PR #719)

Timestamp: 2026-09-27T05-05
Source: coordinator ruling (parallel-orchestrator, followups-2026-09-27) on PR #719, relayed to the item orchestrator; findings CR-1 and CR-3 of `code-review.2026-09-27T04-30.md`.
Branch: `bug/preimplementation-gate-blocks-attribution-trailers-713`, head `0ccba6b3edc38128abc567ab9ab92963cb2857ad`.
Base for diffs: `2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d` (merge-base with `origin/main`).

## In scope

### F1 — CR-1 (Major, introduced by this PR): curly single quotes and the single-quote `$`/backtick allowance

`Test-OrchestrationCommandTextUnresolvable` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (line 140 at head: `if ($openQuote -ne "'" -and $script:InterpolationCommandCharacters -contains $character) {`) skips the interpolation check inside a straight single-quoted span. PowerShell also ends a single-quoted string at U+2018, U+2019, U+201A, and U+201B, and treats U+201C, U+201D, and U+201E as double quotes. If the Codex surface runs commands through PowerShell (unverified), a command such as `git commit -m 'a` + U+2019 + ` $(x) ` + U+2018 + `b' -- docs/features/active/x/plan.md` is admitted by the scanner while PowerShell evaluates `$(x)`. The base commit denied every `$`, so this exposure is new with #713.

Required behavior (coordinator ruling):
- The seven characters U+2018, U+2019, U+201A, U+201B, U+201C, U+201D, and U+201E are treated as NON-quoting for the purpose of the single-quote allowance: a `$` or backtick whose admission would depend on a single-quoted span that is affected by any of these characters stays denied exactly as on the base commit. The fail-closed reading is acceptable and preferred: when the command text contains any of the seven characters, the single-quote allowance for `$` and backtick does not apply (every `$` and backtick is unresolvable, as before #713). A curly-quote character on its own, with no `$` or backtick, need not be denied.
- A `$` or backtick inside a straight single-quoted span, in command text containing none of the seven characters, remains admitted (the feature's intent, AC3).
- New Pester cases in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`, run on both the Claude and Codex gates:
  - DENY (predicate level, as the existing deny rows): a curly-quoted `$(...)` — for example the command above built with `[char]0x2019` and `[char]0x2018` so the test file stays ASCII — plus at least one row using a double curly quote (U+201C/U+201D) around `$`.
  - ALLOW (predicate then decision seam, as the existing admit rows): a straight-single-quoted `$` is still admitted (an existing row may be cited if it already covers this; add one if the plan finds none that stays in the same form).
- Build the characters with `[char]0x....` so no non-ASCII byte enters the test file or the helpers file.

### F2 — CR-3 (Minor): stale comment

The comment in `Test-ExemptOrchestrationStagingCommand` at helpers lines 467-468 at head reads: `# Row 12: interpolation anywhere, redirection outside quotes, and unmodelled backslash` / `# escapes are not statically resolvable, so the operand list cannot be trusted.` It still states `$` is unresolvable anywhere. Correct it to describe the current rule (interpolation outside quotes, inside double quotes, or wherever a typographic quote could end the span; redirection and `#` outside quotes; unmodelled backslash escapes).

## Constraints

- Keep all four helpers copies byte-identical: `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. Mirrors are byte copies (`Copy-Item`), as in the original plan's R-MIRROR.
- Each file at or under 500 lines. The canonical helpers file is at 497 lines at head, so the change may add at most 3 net lines; prefer a net-zero or near-zero edit (for example, extend an existing constant array and one condition). The test file is at 99 lines.
- `Split-OrchestrationCommandLine` and both gate files stay unmodified. The #710 changes stay intact.
- If the skill documents (`.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`, and their bundle mirrors) state the single-quote rule, add the typographic-quote exception there too only if it fits in one sentence; keep each pair byte-identical.
- The PowerShell toolchain must pass in one pass: PoshQC format, analyzer (0 findings), scoped Pester with coverage on both helpers copies (no regression, changed lines covered), full Pester, Parity and legacy-codex suites, push-down contract pytest (the #510 local-only failure is expected locally).
- Tests: no temporary files, no child process, no `origin/main`, no gitignored state, no Windows-only paths.
- Commit and push after each phase; commit messages end with the two attribution lines used on this branch.

## Out of scope (coordinator files these as issues)

- CR-2 (brace-expansion exempt-path bypass, pre-existing), CR-4 (`--trailer --` test), `.agents/skills/epic-plan/SKILL.md` trailer forms, heredoc support (D5), and the `enforce-parallel-worktree-removal-gate.ps1` false positive on `git --version`.

## Exit gate

Reaudit (code-review, feature-audit, policy-audit) with `blocking_count == 0`, and CR-1 and CR-3 recorded as resolved. AC3, AC4, AC6, AC7, AC10 re-verified against the new head.
