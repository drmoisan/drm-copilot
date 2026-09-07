# Remediation Plan — enforcement-hook-trigger-matches-whole-command-text (#545)

**Timestamp:** 2026-09-07T17-44
**Authored by:** atomic-planner
**Feature Folder:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545`
**Work Mode:** `full-bug` (resolved from `issue.md` line 12, `- Work Mode: full-bug`)
**Remediation inputs:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-inputs.2026-09-07T17-44.md`
**Working branch:** `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3`
**Diff anchors — there are two, and they are not interchangeable:**

- **Feature-wide anchor:** `6dff80ed4596bec088d548b23013e6077e32c484`, the epic base. Used by the
  frozen-literal removal check in `[P3-T2]` and by the `--stat` summary in `[P0-T3]`, and by
  nothing else. It is the only correct base for the question "was any frozen literal deleted
  anywhere in this feature", because a literal deleted earlier in the #545 work does not appear as
  a removed line against any later base.
- **Cycle-scope anchor:** `783e4b7436498fb9dba5d11df7711bd541ef28ad`, the committed head of
  `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` at the start of this remediation
  cycle. Used by the changed-file scope assertion in `[P4-T5]`, and by nothing else. It is the only
  correct base for the question "what did this cycle change", because the branch already carries
  the entire #545 change.

Every task below that runs `git diff` names which anchor it uses. Neither anchor substitutes for
the other. A scope assertion anchored at the feature-wide commit enumerates the whole feature — the
preflight `git diff --stat` against `6dff80ed4596bec088d548b23013e6077e32c484` recorded by
`atomic-executor` named 172 paths, 63 of them `.ps1` — so a six-file scope condition anchored there
fails on every possible executor action. A frozen-literal check anchored at the cycle-scope commit
cannot see a deletion made earlier in the feature, so it would pass vacuously.

---

## Scope

This plan implements **R-1 and R-2 only**.

- **R-1 (blocking).** `Get-BlockedPatternMatch` leg 1 compares the six denylist literals against
  `$segment.Tokens` and never against `$segment.ScanText`. Because `ConvertTo-CommandLineToken`
  collapses a balanced quoted span into one token, a multi-token literal cannot form a contiguous
  token run inside a wrapper's quoted argument, so `bash -c "rm -rf /tmp/x"` now returns `$null` and
  ALLOWS where the pre-change `String.Contains` returned `rm -rf` and DENIED. The same mechanism
  weakens the denial for a segment whose quoting or heredoc never closes: `echo "rm -rf /tmp/x`
  likewise returns `$null` today. Restore the raw-scan carve-out in leg 1 for all three conditions
  under which the scanner already selects `RawText` as `ScanText` — wrapper-led, live substitution,
  and unbalanced — while preserving the over-match fix, in all four `validate-bash.ps1` copies, with
  five new pinning cases per side.
- **R-2 (non-blocking, documentation only).** Amend the acceptance criterion at `spec.md` line 1480
  so it records that the pr-author `gh pr create` / `gh pr edit` expressions are superseded by the
  D12 call-site rewrite table and by the epic-base-branch criterion. **No code changes for R-2.**

### Explicitly out of scope

- **R-3.** A gate condition on `pr-author`, not remediable by a code change. The orchestrator carries
  it; no task in this plan addresses it and AC-22 stays unchecked.
- **Follow-ups F-1 through F-7.** These are to be *filed*, not fixed. Filing them is orchestrator
  work outside this plan. No task in this plan touches `hook-command-invocation.ps1`,
  `enforce-epic-merge-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, or the 500-line Codex
  preimplementation gate.
- **The two ambient-state failures in unmodified suites.** `enforce-pr-author-skill.Tests.ps1` and
  `codex-pretooluse-integration.Tests.ps1` are not fixed here. They are named in every test-bearing
  acceptance condition below so their presence cannot mask an R-1 regression.
- **No tenth hook.** Only `validate-bash.ps1` changes.
- **No policy edits.** No file under `.claude/rules/` or `.github/instructions/` is read-modified.

---

## Standing constraints carried into every task

1. **Copy-set parity.** Every `.claude/**` edit mirrors byte-identically into
   `extensions/drm-copilot/resources/claude-customizations/.claude/**`; every `.codex/**` edit into
   `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/**`. Re-verify with
   `cmp` after each pair and after any stage that may rewrite a file.
2. **Literal text is frozen.** The six strings returned by `Get-BlockedBashPattern` stay
   byte-unchanged. Rule R2 governs the literal text; only the comparison primitive and its operand
   may change. `$script:CdChainedReadCommandPattern` likewise stays byte-unchanged.
3. **The Codex copy has no `cd`-chain rule. Do not add one.**
4. **Every touched file stays at or under 500 lines.**
5. **Evidence paths are non-overridable.** Every artifact this plan names resolves under
   `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/<kind>/`.
   No `artifacts/` sub-path is a valid evidence destination. If any caller supplies one, reject it,
   substitute the canonical path, and record
   `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
6. **Every task that names an evidence artifact path writes exactly one artifact** carrying
   `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The edit tasks `[P1-T2]`,
   `[P1-T4]`, `[P2-T2]`, `[P2-T4]`, and `[P3-T1]` name no artifact path deliberately: their `grep`
   and `wc -l` conditions are checked inline and are recorded in the batch toolchain artifact of the
   phase that contains them (`[P1-T7]`, `[P2-T7]`) or in `[P3-T2]`. Where a non-zero exit is the
   expected outcome, the artifact additionally carries `ExpectedExitCode: <int>`.
7. **PowerShell batch budget.** The cap is 3 production plus 3 test PowerShell files per batch. The
   resolved session id is `worktree-agent-a478b73e41951af31-e3281c7b`; the state file is
   `.claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`. Each
   batch opens with a reset task that first lists `.claude/state/` and cross-checks the session id
   against the files actually present there. Bundle mirrors are written with `cp`, which does not
   pass through the PreToolUse hook and therefore consumes no slot.
8. **Toolchain reality.** `pwsh`, `powershell`, and `cmd` are NOT invocable in this session from any
   context; the runtime guard refuses them. Format is `mcp__drm-copilot__run_poshqc_format`, lint is
   `mcp__drm-copilot__run_poshqc_analyze`, Pester is `mcp__drm-copilot__run_poshqc_test` with
   `scan_folders`, with per-suite and per-case results read from `artifacts/pester/pester-junit.xml`.
   Every test-bearing evidence artifact carries a `TOOLCHAIN_SUBSTITUTION` note naming the substitute
   route. Do not silently skip a stage.
9. **Coverage route.** The MCP test runner must NOT be used for any coverage figure: it resolves
   runsettings from the installed VS Code extension and cannot see this branch's `CodeCoverage.Path`
   entries. Coverage comes from a `workflow_dispatch` of `.github/workflows/_poshqc.yml`. **The
   executor has no `gh` in its tool allowlist. The dispatch and the figure-reading are ORCHESTRATOR
   work; the executor consumes supplied figures only.**
10. **Observed success-case output of each tool**, established from the recorded runs of this same
    session and used below in place of documentation:
    - `mcp__drm-copilot__run_poshqc_format` exits 0 whether or not it rewrote a file. Its exit code
      alone gates nothing, so every format task additionally records a `git status --porcelain`
      capture before and after plus the SHA-256 of each in-scope file before and after.
    - `mcp__drm-copilot__run_poshqc_analyze` prints `ok: true` on a clean run. It reports no
      diagnostic count, so `ok: true` is the value asserted.
    - `mcp__drm-copilot__run_poshqc_test` exits with the folder-wide failed-test count, which is
      non-zero in both hook test folders because of two pre-existing ambient failures. Acceptance is
      therefore stated on per-suite `<testsuite>` counts and per-case `status` attributes read from
      `artifacts/pester/pester-junit.xml`, never on the tool's exit code.

### The two pre-existing failures that are tolerated and must not grow

Both are recorded in the `[P0-T7]` baseline of the main plan and neither reproduces on a clean CI
checkout. They are named here so that "zero failures other than these two" is a condition that can
actually fail.

| # | Suite file | It name |
|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` |

---

## The R-1 edit, stated once

Both `validate-bash.ps1` copies carry the identical leg-1 inner loop:
`.claude/hooks/validate-bash.ps1` lines 177–184 and `.codex/hooks/validate-bash.ps1` lines 146–153.
Replace that block in each canonical copy with the block below. The only change is the second `if`.

Target text:

```powershell
    foreach ($pattern in (Get-BlockedBashPattern)) {
        $patternTokens = [string[]]@($pattern -split '\s+' | Where-Object { $_ })
        foreach ($segment in $segments) {
            if (Test-BlockedPatternTokenRun -Token @($segment.Tokens) -PatternToken $patternTokens) {
                return $pattern
            }
            if (($segment.IsWrapperLed -or $segment.HasLiveSubstitution -or $segment.Unbalanced) -and
                $segment.ScanText.IndexOf($pattern, [System.StringComparison]::Ordinal) -ge 0) {
                return $pattern
            }
        }
    }
```

Five constraints this shape satisfies, each of which the executor must preserve if it reformats:

- **The three disjuncts are exactly the three clauses of the scanner's `ScanText` selection.**
  `.claude/hooks/hook-command-scanner.ps1` line 151 and `.codex/hooks/hook-command-scanner.ps1`
  line 151 both read
  `if ($Unbalanced -or $HasLiveSubstitution -or $isWrapperLed) { $scanText = $RawText }`. A leg
  that tested only the first two of the three would leave the `Unbalanced` case unscanned, and
  that case is a real weakened denial rather than a hypothetical one: for `echo "rm -rf /tmp/x`
  the unterminated double quote makes `ConvertTo-CommandLineToken` emit the two tokens `echo` and
  `rm -rf /tmp/x`, so no token run matches, the segment is not wrapper-led and carries no live
  substitution, and the current code returns `$null` where the pre-change `String.Contains`
  returned `rm -rf` and denied. Matching the disjunct set to the selection clause is what makes
  "every segment the scanner scans raw is also scanned raw by leg 1" true by construction.
- **Leg 1 stays evaluated in full, over every literal and every segment, before any leg 2
  evaluation.** The new condition sits inside the existing `foreach ($pattern) { foreach ($segment) }`
  and returns the literal, so `git push origin --force` still returns the leg-1 literal
  `git push origin --force` rather than leg 2's `git push --force`. That ordering is asserted by
  `tests/scripts/claude-hooks/validate-bash.Tests.ps1` line 32 and by
  `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1` line 130.
- **The six literals stay byte-unchanged.** Only the comparison primitive and its operand change.
- **The comparison is `Ordinal`,** matching the culture-insensitive `String.Contains` the leg
  replaced.
- **No `cd`-chain rule is added to the Codex copy.**

Additionally insert this paragraph into the `.DESCRIPTION` of `Get-BlockedPatternMatch` in both
canonical copies, immediately after the existing `Leg 1 (literal)` paragraph:

```
        Leg 1 has a second condition, the wrapper carve-out of D2 Piece 2 together with the two
        other clauses under which the scanner selects raw scan text. A wrapper's quoted argument is
        a nested command line rather than inert data, and ConvertTo-CommandLineToken collapses a
        balanced quoted span into ONE token, so a multi-token literal can never form a contiguous
        token run inside it. The same masking hides a literal carried inside a quoted span or a
        heredoc that never closes. For a segment that is wrapper-led, that carries a live
        substitution, or whose quoting or heredoc did not close, the scanner already selects
        RawText as ScanText, and this leg reads that field with an Ordinal IndexOf, matching the
        culture-insensitive String.Contains it replaced. The three disjuncts here are exactly the
        three clauses of that ScanText selection, so no segment the scanner scans raw is left
        unscanned by this leg. That is what keeps both 'bash -c "rm -rf /tmp/x"' and
        'echo "rm -rf /tmp/x' denying. A segment matching none of the three is never scanned this
        way, so 'git commit -m "docs: explain why rm -rf is banned"' still allows.
```

This paragraph deliberately spells neither `IsWrapperLed` nor `StringComparison]::Ordinal` nor
`segment.Unbalanced`. That is load-bearing rather than stylistic: the three grep counts asserted in
`[P1-T4]` and `[P2-T4]` are each `1` precisely because the only occurrence of each token in the file
is the one the code change introduces. Rewording this paragraph to use any of those three spellings
silently turns three passing acceptance conditions into failures.

If `mcp__drm-copilot__run_poshqc_format` rewrites either block, accept the formatter's output,
restart the batch toolchain loop at stage 1, and re-mirror before re-running `cmp`.

## The ten new pinning cases, stated once

Five per side. The executor creates these exact `It` names; they are quoted here verbatim so a
search for any of them is an instruction rather than a claim about the current tree.

**Claude** — append one new `Context` named `R-1 wrapper carve-out inside the denylist leg` to
`tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`, containing these five `It`
blocks in this order:

| It name (verbatim) | Command driven through `Get-BlockedPatternMatch` | Assertion |
|---|---|---|
| `R1-C1 denies rm -rf carried inside a bash -c quoted argument` | `bash -c "rm -rf /tmp/x"` | `Should -Be 'rm -rf'` |
| `R1-C2 denies git reset --hard carried inside an sh -c quoted argument` | `sh -c 'git reset --hard'` | `Should -Be 'git reset --hard'` |
| `R1-C3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument` | `pwsh -NoProfile -Command "Remove-Item -Recurse -Force build"` | `Should -Be 'Remove-Item -Recurse -Force'` |
| `R1-C4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led` | `git commit -m "chore: note that Remove-Item -Recurse -Force is banned"` | `Should -BeNullOrEmpty` |
| `R1-C5 denies rm -rf carried inside an unterminated quoted span` | `echo "rm -rf /tmp/x` | `Should -Be 'rm -rf'` |

**Codex** — append five `It` blocks to the existing `Describe` in
`tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`, matching that file's existing
flat structure (no `Context` wrapper), with these exact names and the same five commands and
assertions in the same order:

- `R1-X1 denies rm -rf carried inside a bash -c quoted argument`
- `R1-X2 denies git reset --hard carried inside an sh -c quoted argument`
- `R1-X3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument`
- `R1-X4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led`
- `R1-X5 denies rm -rf carried inside an unterminated quoted span`

Case 4 on each side is a **new** negative, distinct from the existing AT-10 case
(`git commit -m "docs: explain why rm -rf is banned"`), which also stays green. It exercises a
different literal through the same masking path, so an over-broad fix that scanned `RawText` for
every segment regardless of the carve-out condition would fail it. The distinct over-broad shape
that scans `ScanText` unconditionally is already pinned by the pre-existing AT-8 case, whose
unquoted `MaskedText` (`git push --force-with-lease origin HEAD`) contains the literal
`git push --force`; R1-C4 does not discriminate that shape, because for a balanced, non-wrapper-led
segment `ScanText` is the masked text and the quoted literal is spaces there.

Case 5 on each side is the pin for the third disjunct. `echo "rm -rf /tmp/x` opens a double quote
that never closes, so the scanner sets `Unbalanced` and selects `RawText` as `ScanText`, while
`ConvertTo-CommandLineToken` emits only the two tokens `echo` and `rm -rf /tmp/x` and no token run
matches. `echo` is not a member of `$script:CommandLineWrapperNames`, and the line carries no `$(`
and no backtick, so neither of the other two disjuncts fires. The case therefore fails against a
two-disjunct fix and passes only against the three-disjunct fix, which is what makes the third
disjunct falsifiable rather than asserted. It is also the direct evidence for acceptance criterion 9
("No existing denial is weakened") on this path: the same command is denied by the pre-change
`String.Contains` and allowed by the code as it stands at the cycle-scope anchor.

Each new suite must carry a comment recording why the case is determinate: every case drives a pure
string function with a literal fixture — no disk I/O, no child process, no temporary file, no live
executable, no ambient state.

---

### Phase 0 — Baseline capture

- [x] [P0-T1] Read, in this order, `CLAUDE.md`, `.claude/rules/tonality.md`,
      `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, and
      `.claude/rules/plan-acceptance-gates.md`, and write
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/phase0-instructions-read.<capture-timestamp>.md`.
      **Acceptance:** the artifact exists and carries `Timestamp:`, a `Policy Order:` line, and an
      explicit list naming all seven file paths above. Read-only; modify none of them.

- [x] [P0-T2] Read `remediation-inputs.2026-09-07T17-44.md` in full, plus
      `policy-audit.2026-09-07T17-44.md` §8 and §10, `code-review.2026-09-07T17-44.md` findings
      table, `feature-audit.2026-09-07T17-44.md` AC evaluation, and `spec.md` lines 1476–1495 and
      1554–1557, all under the feature folder. Write
      `evidence/remediation-baseline/phase0-remediation-documents-read.<capture-timestamp>.md`.
      **Acceptance:** the artifact names all five documents with the line ranges read, transcribes
      the current unchecked text of the criterion at `spec.md` line 1480 and of the criterion at
      `spec.md` line 1488, and records that both currently begin `- [ ]`.

- [x] [P0-T3] Capture git state, using the **feature-wide anchor**. Run
      `git status --porcelain` and
      `git diff --stat 6dff80ed4596bec088d548b23013e6077e32c484`
      and write `evidence/remediation-baseline/baseline-git-state.<capture-timestamp>.md`.
      **Acceptance:** the artifact records `Timestamp:`, both `Command:` lines, `EXIT_CODE: 0` for
      each, the exact `git status --porcelain` path count as an integer, and the verbatim
      `git diff --stat` summary line as printed. **No file count is asserted by this task.** The
      `--stat` line is recorded as an observation only, because the feature-wide anchor enumerates
      the entire #545 change and any specific count asserted against it would be a number this plan
      cannot fix in advance. The scope assertion belongs to `[P4-T5]`, which uses the cycle-scope
      anchor instead. The porcelain capture is the companion that makes untracked paths visible to
      this baseline.

- [x] [P0-T4] Capture the formatting baseline. Run `mcp__drm-copilot__run_poshqc_format` with
      `workspace_root` set to the worktree root and no `scan_folders`. Take a `git status --porcelain`
      capture immediately before and immediately after, and record the SHA-256 of
      `.claude/hooks/validate-bash.ps1`, `.codex/hooks/validate-bash.ps1`,
      `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`, and
      `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` before and after. Write
      `evidence/remediation-baseline/baseline-poshqc-format.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0`, the before-set and after-set porcelain path counts are recorded
      as integers, the set-difference count of paths present after and absent before is recorded and
      is `0`, and all four SHA-256 values are identical before and after. The exit code alone is not
      the acceptance: this formatter exits 0 after rewriting, so the tree observation is what
      distinguishes a clean run from a repairing one. If the set-difference count is non-zero or any
      SHA-256 changed, the formatter repaired pre-existing drift: name every changed path in the
      artifact with its before and after SHA-256, mirror each changed canonical hook to its bundle
      copy, and re-run this task until it is a clean pass. Recording the repair explicitly is what
      keeps this baseline from silently absorbing drift that a later gate would then be unable to
      detect.

- [x] [P0-T5] Capture the lint baseline. Run `mcp__drm-copilot__run_poshqc_analyze` with
      `workspace_root` set to the worktree root and no `scan_folders`. Write
      `evidence/remediation-baseline/baseline-poshqc-analyze.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0` and the artifact records the literal result value `ok: true`.
      This tool reports no diagnostic count, so `ok: true` is the only value asserted; do not record
      a fabricated zero-diagnostic figure.

- [x] [P0-T6] Capture the targeted Pester baseline. Run `mcp__drm-copilot__run_poshqc_test` with
      `scan_folders` set to `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]`, then read
      `artifacts/pester/pester-junit.xml`. Write
      `evidence/remediation-baseline/baseline-targeted-pester.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries a `TOOLCHAIN_SUBSTITUTION` note naming the MCP route used
      in place of a `pwsh` `Invoke-Pester` call, records the tool's `EXIT_CODE:` as observed, and
      records a per-suite row with `tests`, `failures`, `errors`, and `skipped` read from the
      `<testsuite>` element of each of these four suites:
      `validate-bash.Tests.ps1` (expected `tests` 26, `failures` 0),
      `validate-bash.TriggerScoping.Tests.ps1` (expected `tests` 7, `failures` 0),
      `validate-bash-decision-surface.Tests.ps1` (expected `tests` 37, `failures` 0), and
      `validate-bash-trigger-scoping.Tests.ps1` (expected `tests` 3, `failures` 0). The artifact also
      records the folder-wide failure count for each folder and names every failing case, and its
      `Output Summary:` carries the numeric coverage headline from `[P0-T7]`: `.claude/hooks/validate-bash.ps1`
      94.3182 percent and `.codex/hooks/validate-bash.ps1` 100.0000 percent line coverage. Any
      failure outside the two tolerated cases named in the preamble table blocks Phase 1.

- [x] [P0-T7] Record the per-file coverage baseline. Transcribe the two figures supplied with this
      plan, both from CI run `34145103168` of `.github/workflows/_poshqc.yml`:
      `.claude/hooks/validate-bash.ps1` = **94.3182** percent line coverage and
      `.codex/hooks/validate-bash.ps1` = **100.0000** percent line coverage. Write
      `evidence/remediation-baseline/baseline-per-file-coverage.<capture-timestamp>.md`.
      **Acceptance:** the artifact records both numeric percentages, the run id `34145103168`, the
      workflow path `.github/workflows/_poshqc.yml`, and a `TOOLCHAIN_SUBSTITUTION` note stating
      that the MCP test runner was deliberately not used for any coverage figure because it resolves
      runsettings from the installed VS Code extension and cannot see this branch's
      `CodeCoverage.Path` entries. `EXIT_CODE: 0` for the transcription. No placeholder value such as
      `UNVERIFIED` may appear in either cell.

- [x] [P0-T8] Capture the copy-set baseline. Run
      `wc -l .claude/hooks/validate-bash.ps1 .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`
      and
      `cmp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
      and
      `cmp .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`.
      Write `evidence/remediation-baseline/baseline-copyset-parity.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0` for all three commands; both `cmp` invocations print nothing,
      which is what a byte-identical pair produces; the artifact records the six line counts as
      integers, each at or under 500, and the recorded values for the two canonical hooks are 402
      and 295 respectively. `cmp` is used without `-s` so that a difference produces a diagnostic
      line rather than a silent non-zero exit.

---

### Phase 1 — Batch A: Claude-side R-1

- [x] [P1-T1] Open batch A with a budget reset. List `.claude/state/` and confirm it holds exactly
      the file `powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`, cross-checking
      that the embedded session id equals `worktree-agent-a478b73e41951af31-e3281c7b`. Record the
      pre-reset JSON contents, then run
      `rm -f .claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.
      Write `evidence/qa-gates/batch-a-budget-reset.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0`; the artifact records the pre-reset listing, the pre-reset
      `prodFiles` and `testFiles` arrays verbatim, the cross-check result, and a post-reset listing
      of `.claude/state/` showing the file is gone. If the listing shows a state file whose session
      id differs from `worktree-agent-a478b73e41951af31-e3281c7b`, stop and report; do not delete a
      foreign session's counter. Batch A's planned delivery is 1 production file and 1 test file,
      under the 3-and-3 cap.

- [x] [P1-T2] Append the new `Context` `R-1 wrapper carve-out inside the denylist leg` with the five
      `It` blocks `R1-C1`, `R1-C2`, `R1-C3`, `R1-C4`, and `R1-C5` — exact names, commands, and
      assertions per the table in "The ten new pinning cases, stated once" — to
      `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`. Modify no existing
      assertion in that file.
      **Acceptance:** `grep -F -c "        It 'R1-C" tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`
      returns `5`; `grep -F -c "        It '" tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`
      returns `12`, which is the 7 pre-existing blocks plus the 5 added here, so a task that replaced
      an existing block instead of appending fails this condition; and
      `wc -l tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` returns a value at or
      under 500.
      The asserted literal is `        It 'R1-C` — the two-word token `It '` preceded by exactly
      eight space characters — and it is quoted here verbatim, including that indentation, because
      this task is what creates it. The eight spaces are part of the literal rather than incidental
      formatting: all seven pre-existing `It` blocks in this file sit inside a `Context`, which sits
      inside the `Describe`, so Pester's conventional four-space-per-level indentation places every
      `It` at eight spaces. The new `Context` must be nested identically, and asserting the indented
      form rather than the bare token is what makes a block pasted at the wrong nesting level fail
      the condition. The same reasoning fixes the second literal at `        It '`.
      A pass count is deliberately **not** the acceptance here. At this point in the plan the R-1
      edit has not been applied, so `R1-C1`, `R1-C2`, `R1-C3`, and `R1-C5` are expected to fail by
      design; a pass-count condition would be unsatisfiable. The named-test route is carried instead
      by `[P1-T3]` and `[P1-T6]`. This count condition checks a complementary property those two
      cannot check — that the five blocks were **appended** rather than substituted for existing
      ones — and it is checkable the moment the file is written.
      Survival of the individual pre-existing assertions is verified behaviourally by `[P1-T6]`
      conditions (b) and (c) rather than by a diff, because this suite does not exist at the
      feature-wide anchor and an anchored diff of it therefore shows no removed lines whatever the
      executor does.

- [x] [P1-T3] [expect-fail] Reproduce R-1 on the Claude side. Run
      `mcp__drm-copilot__run_poshqc_test` with `scan_folders` set to `["tests/scripts/claude-hooks"]`
      and read `artifacts/pester/pester-junit.xml`. Write
      `evidence/regression-testing/fail-before-r1-claude.<capture-timestamp>.md`.
      **Acceptance:** in the `<testsuite>` for `validate-bash.TriggerScoping.Tests.ps1`, `tests` is
      `12` and `failures` is `4`; the four cases carrying `status="Failed"` are exactly `R1-C1`,
      `R1-C2`, `R1-C3`, and `R1-C5`; `R1-C4` carries `status="Passed"`; and all seven pre-existing
      cases in that suite carry `status="Passed"`. The artifact records `ExpectedExitCode:` equal to
      the observed folder-wide failed-test count and a `TOOLCHAIN_SUBSTITUTION` note. If any of
      `R1-C1`, `R1-C2`, `R1-C3`, or `R1-C5` passes here, the corresponding defect is not reproduced
      and the plan is blocked pending re-derivation. `R1-C5` is the reproduction of the `Unbalanced`
      weakening specifically; a pass on `R1-C5` here would mean the third disjunct is already
      present and the D6 correction is unnecessary, which contradicts the current tree.

- [x] [P1-T4] Apply the R-1 edit to `.claude/hooks/validate-bash.ps1`: replace the leg-1 inner loop
      at lines 177–184 with the target text from "The R-1 edit, stated once", and insert the
      `.DESCRIPTION` paragraph after the existing `Leg 1 (literal)` paragraph. Change nothing else in
      the file.
      **Acceptance:** `grep -F -c "IsWrapperLed" .claude/hooks/validate-bash.ps1` returns `1`;
      `grep -F -c "segment.Unbalanced" .claude/hooks/validate-bash.ps1` returns `1`;
      `grep -F -c "StringComparison]::Ordinal" .claude/hooks/validate-bash.ps1` returns `1`;
      `grep -F -c "'rm -rf'," .claude/hooks/validate-bash.ps1` returns `1`, confirming the first
      denylist literal's declaration line survives byte-unchanged;
      `grep -F -c "CdChainedReadCommandPattern = " .claude/hooks/validate-bash.ps1` returns `1`; and
      `wc -l .claude/hooks/validate-bash.ps1` returns a value at or under 500, with the expected value
      recorded against the `[P0-T8]` baseline of 402. The three tokens `IsWrapperLed`,
      `segment.Unbalanced`, and `StringComparison]::Ordinal` are absent from this file today and this
      task is what places them there, so all three counts are falsifiable; they are quoted here
      verbatim for that reason. None of the three appears in the `.DESCRIPTION` paragraph this task
      inserts, which is why each expected count is `1` and not `2`.

- [x] [P1-T5] Mirror and verify the Claude pair. Run
      `cp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
      then
      `cmp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`.
      Write `evidence/qa-gates/batch-a-pair-parity.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0` for both; `cmp` prints nothing; the artifact records the SHA-256
      of both pair members and they are equal, and the line count of both, equal and at or under 500.

- [x] [P1-T6] Confirm the Claude-side fix. Run `mcp__drm-copilot__run_poshqc_test` with
      `scan_folders` set to `["tests/scripts/claude-hooks"]` and read
      `artifacts/pester/pester-junit.xml`. Write
      `evidence/regression-testing/pass-after-r1-claude.<capture-timestamp>.md`.
      **Acceptance, all of which must hold:**
      (a) `validate-bash.TriggerScoping.Tests.ps1` reports `tests` `12`, `failures` `0`, `errors` `0`,
      and `R1-C1`, `R1-C2`, `R1-C3`, `R1-C4`, `R1-C5` each carry `status="Passed"`;
      (b) `validate-bash.Tests.ps1` reports `tests` `26`, `failures` `0`, and the case
      `returns the matched pattern for every repository-dangerous command` carries `status="Passed"`,
      which is the assertion that depends on leg 1 returning `git push origin --force` ahead of leg
      2's `git push --force`;
      (c) the pre-existing cases `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force`,
      `AT-9 denies a relocating git push --force carrying a directory global option`, and
      `AT-10 allows a commit message that quotes a dangerous pattern in prose` each carry
      `status="Passed"`;
      (d) the only case in the whole `tests/scripts/claude-hooks` folder carrying `status="Failed"`
      is row 1 of the tolerated-failures table in the preamble, named in the artifact. Any additional
      failure blocks the phase.

- [x] [P1-T7] Run the batch A toolchain gate. Stage 1 `mcp__drm-copilot__run_poshqc_format`
      (workspace root, no `scan_folders`), stage 2 `mcp__drm-copilot__run_poshqc_analyze`, stage 3
      `mcp__drm-copilot__run_poshqc_test` with `scan_folders` set to `["tests/scripts/claude-hooks"]`.
      Write `evidence/qa-gates/batch-a-toolchain.<capture-timestamp>.md`.
      **Acceptance:** stage 1 `EXIT_CODE: 0` with a `git status --porcelain` capture before and after
      whose set-difference count is `0` and with the SHA-256 of `.claude/hooks/validate-bash.ps1` and
      `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` identical before and after;
      stage 2 `EXIT_CODE: 0` recording the literal `ok: true`; stage 3 reproducing every condition of
      `[P1-T6]`. If stage 1 rewrote either file, re-run `[P1-T5]` to re-mirror and re-`cmp`, then
      restart this task at stage 1; record each restart. The artifact must state explicitly whether a
      restart occurred and, if not, that all three stages passed in a single pass.

---

### Phase 2 — Batch B: Codex-side R-1

- [x] [P2-T1] Open batch B with a budget reset, using the identical procedure and cross-check as
      `[P1-T1]`. Write `evidence/qa-gates/batch-b-budget-reset.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0`; the artifact records the pre-reset listing of `.claude/state/`,
      the cross-check that the session id equals `worktree-agent-a478b73e41951af31-e3281c7b`, the
      pre-reset `prodFiles` and `testFiles` arrays verbatim, and a post-reset listing showing the
      counter file is gone. Batch B's planned delivery is 1 production file and 1 test file.

- [x] [P2-T2] Append the five `It` blocks `R1-X1`, `R1-X2`, `R1-X3`, `R1-X4`, and `R1-X5` — exact
      names, commands, and assertions per the Codex list in "The ten new pinning cases, stated
      once" — to the existing `Describe` in
      `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`, matching that file's flat
      structure. Modify no existing assertion.
      **Acceptance:** `grep -F -c "    It 'R1-X" tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`
      returns `5`; `grep -F -c "    It '" tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`
      returns `8`, which is the 3 pre-existing blocks plus the 5 added here; and
      `grep -F -c "Context " tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`
      returns `0` and exits 1, recorded in the artifact as `ExpectedExitCode: 1`; and
      `wc -l tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` returns a value at or
      under 500.
      The asserted literal is `    It 'R1-X` — the two-word token `It '` preceded by exactly four
      space characters — and it is quoted here verbatim, including that indentation, because this
      task is what creates it. The four spaces are part of the literal rather than incidental
      formatting: this suite has no `Context` layer, so its three pre-existing `It` blocks sit
      directly inside the `Describe` at one indentation level, which is four spaces. The five new
      blocks must sit at the same level.
      The `Context ` condition is the companion that closes the substring gap in the second literal.
      `grep -F` matches a substring anywhere on the line, so a block indented eight spaces inside an
      added `Context` would still contain `    It '` and would satisfy the count of `8` while
      silently changing the file's structure. Asserting that the file contains no `Context ` at all
      is what forces the flat structure. The count of `0` is falsifiable because the executor could
      write a `Context` and this condition is what rejects it.
      A pass count is deliberately **not** the acceptance here. At this point the R-1 edit has not
      been applied, so `R1-X1`, `R1-X2`, `R1-X3`, and `R1-X5` are expected to fail by design and a
      pass-count condition would be unsatisfiable. The named-test route is carried by `[P2-T3]` and
      `[P2-T6]`; these count conditions check the complementary property that the blocks were
      appended rather than substituted, which is checkable the moment the file is written.
      Survival of the three pre-existing AT assertions is verified behaviourally by `[P2-T6]`
      condition (a) rather than by a diff, for the same reason recorded in `[P1-T2]`.

- [x] [P2-T3] [expect-fail] Reproduce R-1 on the Codex side. Run `mcp__drm-copilot__run_poshqc_test`
      with `scan_folders` set to `["tests/scripts/codex-hooks"]` and read
      `artifacts/pester/pester-junit.xml`. Write
      `evidence/regression-testing/fail-before-r1-codex.<capture-timestamp>.md`.
      **Acceptance:** in the `<testsuite>` for `validate-bash-trigger-scoping.Tests.ps1`, `tests` is
      `8` and `failures` is `4`; the four cases carrying `status="Failed"` are exactly `R1-X1`,
      `R1-X2`, `R1-X3`, and `R1-X5`; `R1-X4` carries `status="Passed"`; and all three pre-existing AT
      cases in that suite carry `status="Passed"`. The artifact records `ExpectedExitCode:` equal to
      the observed folder-wide failed-test count and a `TOOLCHAIN_SUBSTITUTION` note. As on the
      Claude side, `R1-X5` is the reproduction of the `Unbalanced` weakening; a pass on it here
      blocks the phase pending re-derivation.

- [x] [P2-T4] Apply the R-1 edit to `.codex/hooks/validate-bash.ps1`: replace the leg-1 inner loop at
      lines 146–153 with the target text from "The R-1 edit, stated once", and insert the
      `.DESCRIPTION` paragraph after the existing `Leg 1 (literal)` paragraph. Change nothing else,
      and **add no `cd`-chain rule**.
      **Acceptance:** `grep -F -c "IsWrapperLed" .codex/hooks/validate-bash.ps1` returns `1`;
      `grep -F -c "segment.Unbalanced" .codex/hooks/validate-bash.ps1` returns `1`;
      `grep -F -c "StringComparison]::Ordinal" .codex/hooks/validate-bash.ps1` returns `1`;
      `grep -F -c "'rm -rf'," .codex/hooks/validate-bash.ps1` returns `1`;
      `grep -F -c "CdChainedReadCommand" .codex/hooks/validate-bash.ps1` returns `0` and exits 1,
      recorded in the artifact as `ExpectedExitCode: 1`, proving no `cd`-chain rule was introduced;
      and `wc -l .codex/hooks/validate-bash.ps1` returns a value at or under 500, with the expected
      value recorded against the `[P0-T8]` baseline of 295. The three tokens `IsWrapperLed`,
      `segment.Unbalanced`, and `StringComparison]::Ordinal` are absent from this file today and this
      task is what places them there, so all three counts are falsifiable. None of the three appears
      in the `.DESCRIPTION` paragraph this task inserts, which is why each expected count is `1` and
      not `2`.

- [x] [P2-T5] Mirror and verify the Codex pair. Run
      `cp .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`
      then
      `cmp .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`.
      Write `evidence/qa-gates/batch-b-pair-parity.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0` for both; `cmp` prints nothing; the artifact records the SHA-256
      of both pair members and they are equal, and the line count of both, equal and at or under 500.

- [x] [P2-T6] Confirm the Codex-side fix. Run `mcp__drm-copilot__run_poshqc_test` with `scan_folders`
      set to `["tests/scripts/codex-hooks"]` and read `artifacts/pester/pester-junit.xml`. Write
      `evidence/regression-testing/pass-after-r1-codex.<capture-timestamp>.md`.
      **Acceptance, all of which must hold:**
      (a) `validate-bash-trigger-scoping.Tests.ps1` reports `tests` `8`, `failures` `0`, `errors` `0`,
      and `R1-X1`, `R1-X2`, `R1-X3`, `R1-X4`, `R1-X5` each carry `status="Passed"`, as do the three
      pre-existing cases `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force`,
      `AT-9 denies a relocating git push --force carrying a directory global option`, and
      `AT-10 allows a commit message that quotes a dangerous pattern in prose`;
      (b) `validate-bash-decision-surface.Tests.ps1` reports `tests` `37`, `failures` `0`, and the
      case `returns the four-token git push origin --force literal ahead of any structural value`
      carries `status="Passed"`, which is the Codex-side assertion on leg ordering;
      (c) the case `matches a literal carried on the second segment of a chained command` carries
      `status="Passed"`;
      (d) the only case in the whole `tests/scripts/codex-hooks` folder carrying `status="Failed"` is
      row 2 of the tolerated-failures table in the preamble, named in the artifact.

- [x] [P2-T7] Run the batch B toolchain gate. Stage 1 `mcp__drm-copilot__run_poshqc_format`
      (workspace root, no `scan_folders`), stage 2 `mcp__drm-copilot__run_poshqc_analyze`, stage 3
      `mcp__drm-copilot__run_poshqc_test` with `scan_folders` set to `["tests/scripts/codex-hooks"]`.
      Write `evidence/qa-gates/batch-b-toolchain.<capture-timestamp>.md`.
      **Acceptance:** stage 1 `EXIT_CODE: 0` with a `git status --porcelain` capture before and after
      whose set-difference count is `0` and with the SHA-256 of `.codex/hooks/validate-bash.ps1` and
      `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` identical before and after;
      stage 2 `EXIT_CODE: 0` recording the literal `ok: true`; stage 3 reproducing every condition of
      `[P2-T6]`. If stage 1 rewrote either file, re-run `[P2-T5]`, then restart this task at stage 1
      and record the restart.
      **Additional acceptance required by `[P3-T2]`:** the post-stage-1 `git status --porcelain`
      capture is recorded in the artifact **verbatim and in full**, one line per path, unabridged and
      unsummarized, under a heading naming it as the `[P3-T2]` comparison baseline. The artifact also
      records explicitly whether that listing contains a line naming
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`.
      This capture is the set that `[P3-T2]` performs its set difference against; an abridged,
      sorted-away, or path-count-only record makes `[P3-T2]` unsatisfiable. If a restart occurs, the
      capture recorded is the one taken after the final stage 1.

---

### Phase 3 — R-2: the documentation amendment

- [x] [P3-T1] Amend the acceptance criterion at `spec.md` line 1480 in
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`.
      Preserve the criterion's first line verbatim — `- [ ] The five trigger pattern strings in the preimplementation gate are **byte-unchanged**, and` —
      and rewrite and extend only the three continuation lines beneath it, so that the criterion
      (a) keeps the byte-unchanged obligation for the five preimplementation-gate
      trigger pattern strings, the promotion hook's four forbidden-token literals, the promotion
      hook's `gh issue create/new` expression string, the promotion hook's `$ghApiIssuesPostPattern`
      declaration line, the six `validate-bash` denylist literals,
      `$script:CdChainedReadCommandPattern`, and the two abandon token constants; (b) states in one
      sentence that the pr-author hook's `gh pr create` and `gh pr edit` expressions are
      **superseded** by the D12 call-site rewrite table, which directs
      `enforce-pr-author-skill-helpers.ps1` lines 170–171 to `Test-CommandLineInvocation` — a
      function taking no pattern operand — and by the acceptance criterion at `spec.md` line 1620
      covering `enforce-pr-author-skill.epic-base-branch.ps1` (indexed AC-33 in the audit artifacts,
      whose numbered index records AC-31 as the `validate-bash.ps1` matching-primitive criterion at
      `spec.md` line 1604), which requires `Test-EpicBaseBranchOverride` to do the same, so those
      three literals are necessarily
      deleted and carry no byte-unchanged obligation; and (c) cites
      `evidence/qa-gates/trigger-literals-byte-unchanged.2026-09-07T15-50.md` §4 as the supporting
      record. Leave the checkbox as `- [ ]` in this task. Use professional, factual, neutral wording
      with no hyperbole, humour, or metaphor.
      **Acceptance:**
      `grep -F -c "trigger-literals-byte-unchanged.2026-09-07T15-50.md" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
      returns `1`, and
      `grep -F -c "ghApiIssuesPostPattern" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
      returns `1`. Both literals return zero matches against `spec.md` as the file stands today, so
      each condition is falsifiable and this task is what places them there; they are quoted verbatim
      here for that reason. The word `superseded` is deliberately **not** used as an acceptance token,
      because `spec.md` already contains eight occurrences of it and a presence check on it could not
      fail. The criterion's checkbox stays `- [ ]` until `[P4-T8]`, so
      `grep -F -c -e "- [ ] The five trigger pattern strings" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
      still returns `1` after this task.
      The `-e` is required rather than stylistic. This pattern's first character is `-`, so without
      `-e` GNU grep parses `- [ ] The five trigger pattern strings` as an option bundle, prints
      `grep: unknown option`, and exits 2. The condition would then return the same non-zero exit
      whatever the executor did to `spec.md`, which is exactly the unfalsifiable shape this plan
      exists to avoid. `-e` marks the following argument as the pattern and restores the intended
      exit semantics: `0` with a printed count of `1` on a match.

- [x] [P3-T2] Prove R-2 changed no code and that no frozen literal was deleted, using the
      **feature-wide anchor**. Run `git status --porcelain`, then run nine piped invocations of the
      form
      `git diff 6dff80ed4596bec088d548b23013e6077e32c484 -- '*.ps1' | grep "^-" | grep -F -c "<literal>"`,
      substituting each of these nine literals in turn for `<literal>` and writing no intermediate
      file:
      `'rm -rf',` / `'git push --force',` / `'git push origin --force',` /
      `'Remove-Item -Recurse -Force',` / `'git reset --hard',` / `'git push -f',` /
      `$script:CdChainedReadCommandPattern = ` / `$script:AbandonDispositionToken = ` /
      `$ghApiIssuesPostPattern = `. Write
      `evidence/qa-gates/r2-no-code-change.<capture-timestamp>.md`.

      **Why literals 7 through 9 are asserted in declaration form, trailing space significant.** The
      last three are quoted as declaration lines — identifier, space, `=`, space — and not as bare
      identifiers. The bare-identifier form cannot pass. Rule R2 governs the literal *text*, and the
      literal text lives on the declaration line; the D12 call-site rewrite deliberately removed the
      *use sites* of all three, so a bare-token search over removed lines in the PowerShell diff
      against the feature-wide anchor returns `2` for `$script:CdChainedReadCommandPattern`, `2` for
      `$script:AbandonDispositionToken`, and `4` for `$ghApiIssuesPostPattern` — non-zero by design
      and unrelated to any deletion of frozen text. The declaration form isolates the line rule R2
      actually protects. The trailing space is part of each quoted literal and must be typed; without
      it the search also matches a comparison or an interpolation.

      **All three declaration lines exist and are checked against a state in which they can be
      removed.** In the current tree they are at `.claude/hooks/validate-bash.ps1` line 204,
      `.claude/hooks/enforce-parallel-abandon-gate.ps1` line 41, and
      `.claude/hooks/enforce-promotion-mcp-only.ps1` line 136 with the Codex sibling at
      `.codex/hooks/enforce-promotion-mcp-only.ps1` line 133, each with its bundle mirror.
      `atomic-executor` confirmed during preflight that all three declaration lines are likewise
      present at the feature-wide anchor, so deleting any of them produces a `-` line and a non-zero
      count. The condition can therefore fail for all nine literals equally, and no literal in this
      set carries weaker evidence than the others.

      **Acceptance:** every one of the nine invocations prints `0`, so no frozen literal appears on a
      removed line anywhere in the PowerShell diff against the feature-wide anchor; the artifact
      records `ExpectedExitCode: 1` for each `grep -F -c` that prints `0`, which is the exit code GNU
      grep returns when it matches nothing; and the `git status --porcelain` capture is recorded in
      full and is compared **as a set difference** against the post-stage-1 porcelain capture recorded
      verbatim in `[P2-T7]`, as follows:
      (i) both listings are reproduced in the artifact;
      (ii) every untracked path under
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/`
      is excluded from both sides and enumerated separately in the artifact, by path;
      (iii) after that exclusion, the set of paths present now and absent in the `[P2-T7]` capture
      contains exactly one entry, and that entry names
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`;
      (iv) the set of paths absent now and present in the `[P2-T7]` capture is empty;
      (v) the `[P2-T7]` capture is confirmed not to list `spec.md`. If it does, that is a blocking
      discrepancy: record it and stop rather than relaxing the condition.
      Porcelain cannot express "modified since". Nothing is committed at any point in this plan, so
      the raw listing at this task still carries the six PowerShell files changed in Phases 1 and 2,
      the untracked plan file, and every untracked evidence artifact written so far. A condition
      reading "porcelain shows `spec.md` as the only file modified since `[P2-T7]`" is therefore
      false on every possible executor action. The set difference against a recorded earlier capture
      is what makes "R-2 changed no code" falsifiable.

      **Operational constraint: nine separate `Bash` tool calls, one per literal.** Do not wrap the
      nine invocations in a shell loop and do not redirect the diff to a file first. The
      worktree-isolation guard refuses a loop whose body spells `git`, and it refuses a form that
      redirects `git diff` output to a file; the single-pipeline form quoted above is the form the
      guard accepts. Each of the nine runs as its own tool call and each result is recorded
      individually in the artifact.

---

### Phase 4 — Final QA loop and closure

- [x] [P4-T1] Open batch C with a budget reset, using the identical procedure and cross-check as
      `[P1-T1]`. Write `evidence/qa-gates/batch-c-budget-reset.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0`; the artifact records the pre-reset listing of `.claude/state/`,
      the session-id cross-check against `worktree-agent-a478b73e41951af31-e3281c7b`, the pre-reset
      counter contents, and a post-reset listing showing the counter file is gone. Batch C exists so
      that any PowerShell file the final format stage forces the executor to hand-correct has budget
      available; if no such correction is needed, batch C delivers zero files.

- [x] [P4-T2] Final formatting stage. Run `mcp__drm-copilot__run_poshqc_format` with `workspace_root`
      set to the worktree root and no `scan_folders`. Capture `git status --porcelain` immediately
      before and after, and the SHA-256 of all four `validate-bash.ps1` copies and both changed test
      suites before and after. Write `evidence/qa-gates/final-poshqc-format.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0`; the before-set and after-set porcelain path counts are recorded
      as integers; the set-difference count of paths present after and absent before is `0`; and all
      six SHA-256 values are identical before and after. The exit code alone is not the acceptance:
      this formatter exits 0 after rewriting. If any SHA-256 changed, re-run the affected mirror
      command from `[P1-T5]` or `[P2-T5]`, re-`cmp`, and restart Phase 4 at this task.

- [x] [P4-T3] Final lint stage. Run `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set
      to the worktree root and no `scan_folders`. Write
      `evidence/qa-gates/final-poshqc-analyze.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0` and the artifact records the literal result value `ok: true`,
      equal to the `[P0-T5]` baseline value. If the exit code is non-zero, fix and restart Phase 4 at
      `[P4-T2]`.

- [x] [P4-T4] Final test stage. Run `mcp__drm-copilot__run_poshqc_test` with `scan_folders` set to
      `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` and read
      `artifacts/pester/pester-junit.xml`. Write
      `evidence/qa-gates/final-poshqc-test.<capture-timestamp>.md`.
      **Acceptance, all of which must hold and each of which is read from a `<testsuite>` element or
      a `status` attribute rather than from the tool's exit code:**
      (a) `validate-bash.Tests.ps1` — `tests` `26`, `failures` `0`, `errors` `0`;
      (b) `validate-bash.TriggerScoping.Tests.ps1` — `tests` `12`, `failures` `0`, `errors` `0`, with
      `R1-C1`, `R1-C2`, `R1-C3`, `R1-C4`, `R1-C5` all `status="Passed"`;
      (c) `validate-bash-decision-surface.Tests.ps1` — `tests` `37`, `failures` `0`, `errors` `0`;
      (d) `validate-bash-trigger-scoping.Tests.ps1` — `tests` `8`, `failures` `0`, `errors` `0`, with
      `R1-X1`, `R1-X2`, `R1-X3`, `R1-X4`, `R1-X5` all `status="Passed"`;
      (e) across both folders the complete set of cases carrying `status="Failed"` is exactly the two
      rows of the tolerated-failures table in this plan's preamble, each named in the artifact by
      suite file and It name;
      (f) the artifact carries a `TOOLCHAIN_SUBSTITUTION` note naming the MCP route, records the
      tool's observed `EXIT_CODE:` together with `ExpectedExitCode:` equal to the same value, and
      states explicitly whether stages 1 through 3 completed in a single pass with no restart. Any
      failure outside the two tolerated cases restarts Phase 4 at `[P4-T2]`.

- [x] [P4-T5] Final parity and line-cap verification. Run `cmp` on both canonical/bundle pairs
      exactly as in `[P1-T5]` and `[P2-T5]`, then run the six-path `wc -l` from `[P0-T8]`, then run
      `git status --porcelain` and
      `git diff --name-only 783e4b7436498fb9dba5d11df7711bd541ef28ad`. Write
      `evidence/qa-gates/final-parity-and-line-cap.<capture-timestamp>.md`.
      **This task uses the cycle-scope anchor `783e4b7436498fb9dba5d11df7711bd541ef28ad`, not the
      feature-wide anchor.** The scope question here is "what did this remediation cycle change",
      and the branch already carries the entire #545 change: the preflight `git diff --stat` against
      `6dff80ed4596bec088d548b23013e6077e32c484` recorded by `atomic-executor` named 172 paths, 63 of
      them `.ps1`, so a six-file scope condition anchored there fails on every possible executor
      action and verifies nothing. The cycle-scope anchor is the committed head of
      `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` at the start of this cycle, so
      a diff against it names exactly the files this plan's tasks touched. It does **not** substitute
      for the feature-wide anchor used by `[P3-T2]`: a frozen literal deleted earlier in the feature
      does not appear as a removed line against the cycle-scope anchor, so that check would pass
      vacuously if it were re-anchored here.
      **Acceptance:** both `cmp` invocations exit 0 and print nothing; the artifact records the
      SHA-256 of all four `validate-bash.ps1` copies, with the two Claude copies equal to each other
      and the two Codex copies equal to each other; all six line counts are at or under 500 and are
      recorded as integers alongside their `[P0-T8]` baseline values; and the `git diff --name-only`
      list against the cycle-scope anchor, read together with the `git status --porcelain` companion
      that makes any untracked path visible, contains no PowerShell path other than the four
      `validate-bash.ps1` copies and the two changed test suites. A PowerShell path outside that
      six-file set blocks closure.

- [ ] [P4-T6] Consume the orchestrator-supplied per-file coverage figures. **The executor runs no
      coverage command.**

      **Precondition, discharged by the orchestrator before this task is dispatched.** No task in
      this plan commits and no task pushes. A coverage run therefore has nothing to measure unless
      the orchestrator first commits the Phase 1 through Phase 3 changes and pushes the branch. The
      required order is: orchestrator commits and pushes → orchestrator dispatches the workflow
      against that pushed head → orchestrator supplies the run id, the measured commit SHA, and the
      two percentages → executor records them here. **The executor does not commit and does not
      push.** Without this precondition the measured head would be `783e4b7436498fb9dba5d11df7711bd541ef28ad`,
      which predates the R-1 edit, so this task would report the pre-fix figures and `[P4-T7]` would
      compare the `[P0-T7]` baseline against itself and pass regardless of what was implemented.

      **Supplied-SHA confirmation, performed by the executor.** Before recording anything, run
      `git show <supplied-sha>:.claude/hooks/validate-bash.ps1 | grep -F -c IsWrapperLed`,
      substituting the orchestrator-supplied SHA. The expected printed value is `1`. If it prints
      `0`, or `git show` fails because the SHA does not name a commit or the path is absent from it,
      the supplied SHA does not carry the fix: this task is `BLOCKED`, not `SKIPPED`. Record the
      blocked state, name the supplied SHA and the observed output, and stop.

      The orchestrator dispatches `.github/workflows/_poshqc.yml` via
      `workflow_dispatch` against the pushed head of this branch, reads the `LINE` counter for
      `.claude/hooks/validate-bash.ps1` and `.codex/hooks/validate-bash.ps1` from the
      `artifacts/pester/powershell-coverage.xml` that run produces, and supplies the run id, the
      measured commit, and the two percentages to the executor. Write
      `evidence/qa-gates/final-per-file-coverage.<capture-timestamp>.md`.
      **Acceptance:** the artifact records both supplied percentages as numeric values, the supplied
      run id, the supplied commit SHA verbatim, the workflow path `.github/workflows/_poshqc.yml`,
      and a `TOOLCHAIN_SUBSTITUTION` note recording that the MCP test runner was deliberately not
      used for any coverage figure. The artifact additionally records the supplied-SHA confirmation:
      the exact `git show … | grep -F -c IsWrapperLed` command as run with the SHA substituted, and
      its observed output `1`. Each recorded percentage must be at or above **85.0000**.
      `EXIT_CODE: 0` for the transcription. If the orchestrator has not supplied both figures, this
      task is `BLOCKED`, not `SKIPPED`: record the blocked state and stop; do not substitute an
      MCP-produced figure and do not record a placeholder.

- [ ] [P4-T7] Record the coverage delta. Using the `[P0-T7]` baseline values (94.3182 and 100.0000)
      and the `[P4-T6]` post-change values, write
      `evidence/qa-gates/final-coverage-delta.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries a two-row table, one row per canonical copy, each with a
      baseline percentage, a post-change percentage, and their arithmetic difference. Both
      post-change values must be at or above 85.0000, and neither may fall below its baseline value.
      Because the R-1 edit adds two statements that the four new positive cases on each side
      (`R1-C1`, `R1-C2`, `R1-C3`, `R1-C5` and their `R1-X` counterparts) all execute, a fall below
      baseline indicates a new statement is unexercised on that side. `EXIT_CODE: 0` for the
      arithmetic. No threshold is asserted against any repository-wide aggregate.
      **Remedy when a post-change value is at or above 85.0000 but below its baseline.** The Codex
      baseline is 100.0000, so on that side any single uncovered new statement fails the
      no-regression condition while still clearing the absolute threshold. In that case: identify
      the uncovered new statement by reading the per-line `LINE` counters for
      `.codex/hooks/validate-bash.ps1` — or `.claude/hooks/validate-bash.ps1` when the Claude row is
      the one below baseline — in the `artifacts/pester/powershell-coverage.xml` produced by the
      `[P4-T6]` run; add one pinning case to that side's suite that exercises the identified line,
      named in the same `R1-C` / `R1-X` series and following the same determinism comment
      requirement; then re-run `[P4-T6]` and this task against a fresh orchestrator-supplied
      dispatch of the recommitted head. Do not lower the 85.0000 threshold, do not waive the
      baseline comparison, and do not record the shortfall as an accepted regression. An added case
      changes the `tests` counts asserted in `[P1-T2]`, `[P1-T6]`, `[P2-T2]`, `[P2-T6]`, and
      `[P4-T4]`. The executor does not amend those asserted values on its own authority: it records
      the identified uncovered line and the proposed case in the artifact, reports the state to the
      orchestrator, and waits for a plan revision that carries the new counts.

- [ ] [P4-T8] Check off the two acceptance criteria that this cycle closes, in
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`:
      change the criterion amended by `[P3-T1]`, whose first line begins
      `- [ ] The five trigger pattern strings`, from `- [ ]` to `- [x]`; and change the criterion at
      line 1488, whose first line begins `- [ ] **No existing denial is weakened.**`, from `- [ ]` to
      `- [x]`. Leave the criterion at line 1554, whose first line begins
      `- [ ] **Issue #591 is recorded as superseded`, unchecked: it closes on `pr-author`, which is
      out of this plan's scope. Write
      `evidence/qa-gates/final-ac-checkoff.<capture-timestamp>.md`.
      **Acceptance:** `grep -F -c -e "- [x] The five trigger pattern strings" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
      returns `1`;
      `grep -F -c -e "- [x] **No existing denial is weakened.**" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
      returns `1`; and
      `grep -F -c -e "- [ ] **Issue #591 is recorded as superseded" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
      returns `1`. The `-e` in all three is required rather than stylistic: each pattern's first
      character is `-`, so without `-e` GNU grep parses the pattern as an option bundle, prints
      `grep: unknown option`, and exits 2 — the same non-zero result whatever the executor does to
      `spec.md`, which would make all three conditions unfalsifiable. `-e` marks the following
      argument as the pattern and restores the intended exit semantics.
      All three checked-state literals are quoted here verbatim; the first two are
      absent from `spec.md` today and this task is what creates them, and the third is present today
      and must survive. The artifact additionally cites, for each checked criterion, the evidence
      that discharges it — `[P4-T4]` for the no-denial-weakened criterion, and `[P3-T1]` plus
      `[P3-T2]` for the byte-unchanged criterion. Do not perform this task before `[P4-T4]`,
      `[P4-T6]`, and `[P4-T7]` have all passed.

- [ ] [P4-T9] Reconcile against the remediation exit condition and close batch C with a budget reset.
      Run `rm -f .claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`
      and list `.claude/state/` afterwards. Write
      `evidence/qa-gates/final-qa-summary.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0` for the reset and the post-reset listing shows no counter file;
      and the artifact carries a six-row reconciliation table, one row per in-scope exit condition
      from the remediation inputs, each row naming the evidence artifact that discharges it and
      carrying a `PASS` or `FAIL` verdict:
      (1) R-1 implemented in all four copies with five new cases per side passing — including the
      `Unbalanced` pin `R1-C5` / `R1-X5` — and the 26 existing `validate-bash.Tests.ps1` cases plus
      the 7 existing `validate-bash.TriggerScoping.Tests.ps1` cases still green — `[P4-T4]`;
      (2) R-2's spec amendment recorded — `[P3-T1]`;
      (3) canonical/bundle byte parity re-verified for both changed pairs — `[P4-T5]`;
      (4) format, analyze, and test completed in a single pass with no restart — `[P4-T2]` through
      `[P4-T4]`;
      (5) per-file coverage re-measured via `_poshqc.yml` dispatch with both copies at or above 85
      percent and neither below its `[P0-T7]` baseline — `[P4-T6]` and `[P4-T7]`. This row is
      discharged only if the `[P4-T6]` precondition was met: the orchestrator committed Phases 1
      through 3 and pushed before dispatch, supplied the measured commit SHA, and the executor
      recorded the confirmation that
      `git show <supplied-sha>:.claude/hooks/validate-bash.ps1 | grep -F -c IsWrapperLed` printed
      `1`. If `[P4-T6]` is `BLOCKED`, this row is `FAIL`, not `PASS`;
      (6) the two criteria checked off and the third left open — `[P4-T8]`.
      The artifact must also state, as an explicit out-of-scope note, that R-3 and follow-ups F-1
      through F-7 are orchestrator filing work that this plan did not perform. Any `FAIL` row blocks
      closure.

---

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: .claude/hooks/validate-bash.ps1 | line 180 `Test-BlockedPatternTokenRun -Token @($segment.Tokens)` — leg 1 reads Tokens and nothing else
CITATION: .claude/hooks/validate-bash.ps1 | lines 177-184 leg-1 inner loop; file length 402 lines
CITATION: .claude/hooks/validate-bash.ps1 | line 204 `$script:CdChainedReadCommandPattern = ` declaration line, trailing space present
CITATION: .claude/hooks/validate-bash.ps1 | lines 53-60 `Get-BlockedBashPattern` six literals; `'rm -rf',` at line 54
CITATION: .claude/hooks/validate-bash.ps1 | zero occurrences of `IsWrapperLed`, of `segment.Unbalanced`, and of `StringComparison]::Ordinal` in all 402 lines
CITATION: .codex/hooks/validate-bash.ps1 | lines 146-153 leg-1 inner loop; file length 295 lines
CITATION: .codex/hooks/validate-bash.ps1 | no `CdChainedReadCommand` occurrence anywhere in file; zero occurrences of `IsWrapperLed`, `segment.Unbalanced`, `StringComparison]::Ordinal`
CITATION: .claude/hooks/hook-command-scanner.ps1 | line 151 `if ($Unbalanced -or $HasLiveSubstitution -or $isWrapperLed) { $scanText = $RawText }` — the three-clause ScanText selection
CITATION: .codex/hooks/hook-command-scanner.ps1 | line 151 the identical three-clause ScanText selection
CITATION: .claude/hooks/hook-command-scanner.ps1 | line 442 `if ($inSingle -or $inDouble -or $pending.Count -gt 0) { $unbalanced = $true }` — an unterminated quote sets Unbalanced
CITATION: .claude/hooks/hook-command-scanner.ps1 | lines 21-24 `$script:CommandLineWrapperNames` — fourteen members, `echo` is not one of them
CITATION: .claude/hooks/hook-command-scanner.ps1 | lines 66-96 `ConvertTo-CommandLineToken`; the open-quote branch at lines 72-74 appends whitespace, so an unterminated quote yields one trailing token
CITATION: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | line 32 asserts `git push origin --force` returns `git push origin --force`
CITATION: tests/scripts/claude-hooks/validate-bash.Tests.ps1 | 26 `It` blocks total
CITATION: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | 7 `It` blocks at lines 37, 43, 49, 59, 63, 69, 75, each indented exactly eight spaces inside a `Context`; 82 lines; AT-10 `It` at line 49
CITATION: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | 3 `It` blocks at lines 34, 38, 42, each indented exactly four spaces directly inside one `Describe`; 45 lines; zero occurrences of `Context `
CITATION: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | line 130 asserts leg-1 precedence; 37 `It` blocks total
CITATION: .claude/hooks/enforce-parallel-abandon-gate.ps1 | line 41 `$script:AbandonDispositionToken = ` declaration line, trailing space present
CITATION: .claude/hooks/enforce-promotion-mcp-only.ps1 | line 136 `$ghApiIssuesPostPattern = ` declaration line; Codex sibling at .codex/hooks/enforce-promotion-mcp-only.ps1 line 133
CITATION: .claude/hooks/enforce-powershell-batch-budget.ps1 | lines 426-427 caps 3 and 3; line 296 reset reason names the state file
CITATION: .claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json | sole file present in .claude/state/; `prodFiles` empty, `testFiles` holds two entries
CITATION: .git/refs/heads/bug/enforcement-hook-trigger-matches-whole-command-text-545-r3 | `783e4b7436498fb9dba5d11df7711bd541ef28ad` — the cycle-scope anchor is the committed head of the working branch
CITATION: .gitignore | line 6 `/artifacts` — the Pester and coverage output directory never appears in `git status --porcelain`
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md | line 1480 unchecked AC-07; line 1488 unchecked AC-09; line 1554 unchecked AC-22
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md | 8 occurrences of `superseded`; zero occurrences of `ghApiIssuesPostPattern` and zero of `trigger-literals-byte-unchanged`
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/issue.md | line 12 `- Work Mode: full-bug`
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/final-selfhosted-test.2026-09-07T17-11.md | the two tolerated failing cases named by suite and It
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/coverage-delta.2026-09-07T17-00.md | rows 16 and 17, 94.3182 and 100.0000, run 34145103168
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/trigger-literals-byte-unchanged.2026-09-07T15-50.md | section 4 covers the pr-author expressions
AC-INVENTORY: AC-R1-IMPL, AC-R1-MIRROR, AC-R1-TESTS, AC-R1-NOREG, AC-R1-LITERALS, AC-R1-COVERAGE, AC-R2-SPEC, AC-R2-NOCODE, AC-SPEC-07, AC-SPEC-09, AC-LINECAP, AC-TOOLCHAIN
AC-MAPPING: AC-R1-IMPL | IMPLEMENTATION: P1-T4, P2-T4 | TESTS: P1-T6, P2-T6 | EVIDENCE: evidence/regression-testing/pass-after-r1-claude, evidence/regression-testing/pass-after-r1-codex
AC-MAPPING: AC-R1-MIRROR | IMPLEMENTATION: P1-T5, P2-T5 | TESTS: P4-T5 | EVIDENCE: evidence/qa-gates/final-parity-and-line-cap
AC-MAPPING: AC-R1-TESTS | IMPLEMENTATION: P1-T2, P2-T2 | TESTS: P1-T3, P2-T3, P4-T4 | EVIDENCE: evidence/regression-testing/fail-before-r1-claude, evidence/regression-testing/fail-before-r1-codex
AC-MAPPING: AC-R1-NOREG | IMPLEMENTATION: P1-T4, P2-T4 | TESTS: P4-T4 | EVIDENCE: evidence/qa-gates/final-poshqc-test
AC-MAPPING: AC-R1-LITERALS | IMPLEMENTATION: P1-T4, P2-T4 | TESTS: P3-T2 | EVIDENCE: evidence/qa-gates/r2-no-code-change
AC-MAPPING: AC-R1-COVERAGE | IMPLEMENTATION: P0-T7 | TESTS: P4-T6, P4-T7 | EVIDENCE: evidence/qa-gates/final-per-file-coverage, evidence/qa-gates/final-coverage-delta
AC-MAPPING: AC-R2-SPEC | IMPLEMENTATION: P3-T1 | TESTS: P3-T1 | EVIDENCE: evidence/qa-gates/final-ac-checkoff
AC-MAPPING: AC-R2-NOCODE | IMPLEMENTATION: P3-T1 | TESTS: P3-T2 | EVIDENCE: evidence/qa-gates/r2-no-code-change
AC-MAPPING: AC-SPEC-07 | IMPLEMENTATION: P3-T1 | TESTS: P4-T8 | EVIDENCE: evidence/qa-gates/final-ac-checkoff
AC-MAPPING: AC-SPEC-09 | IMPLEMENTATION: P1-T4, P2-T4 | TESTS: P4-T4, P4-T8 | EVIDENCE: evidence/qa-gates/final-poshqc-test, evidence/qa-gates/final-ac-checkoff
AC-MAPPING: AC-LINECAP | IMPLEMENTATION: P1-T4, P2-T4 | TESTS: P0-T8, P4-T5 | EVIDENCE: evidence/qa-gates/final-parity-and-line-cap
AC-MAPPING: AC-TOOLCHAIN | IMPLEMENTATION: P1-T7, P2-T7 | TESTS: P4-T2, P4-T3, P4-T4 | EVIDENCE: evidence/qa-gates/final-poshqc-format, evidence/qa-gates/final-poshqc-analyze, evidence/qa-gates/final-poshqc-test
UNRESOLVED-GAPS: NONE
DIRECTIVE: PREFLIGHT VALIDATION ONLY
PREFLIGHT: PENDING EXECUTOR VALIDATION
SELF-REVIEW: RE-DERIVED THIS PASS
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/feature-audit.2026-09-07T17-44.md | line 69 `31. AC-31 (L1604) — validate-bash.ps1 matching-primitive change delivered and pinned` — re-derived for D12
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/feature-audit.2026-09-07T17-44.md | line 71 `33. AC-33 (L1620) — enforce-pr-author-skill.epic-base-branch.ps1 fixed in both Claude copies` — re-derived for D12
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md | line 1604 — criterion text begins "validate-bash.ps1 matching-primitive change is delivered and pinned (D11.3)" — re-derived for D12, confirms AC-31 is the validate-bash.ps1 criterion
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md | line 1620 — criterion text begins "enforce-pr-author-skill.epic-base-branch.ps1 is fixed in both Claude copies" — re-derived for D12, confirms AC-33 is the epic-base-branch criterion
CITATION: .claude/hooks/hook-command-scanner.ps1 | line 150 `$scanText = $MaskedText` and line 151 `if ($Unbalanced -or $HasLiveSubstitution -or $isWrapperLed) { $scanText = $RawText }` — re-derived for D13, confirms ScanText is MaskedText for a balanced, non-wrapper-led, non-substitution segment
CITATION: .claude/hooks/hook-command-scanner.ps1 | lines 341-355 in-double-quote branch appends one space (`[void]$masked.Append(' ')`) per plain character — re-derived for D13, confirms the quoted literal is spaces in MaskedText
CITATION: .claude/hooks/hook-command-scanner.ps1 | R1-C4 command `git commit -m "chore: note that Remove-Item -Recurse -Force is banned"` — re-derived for D13: `git` is not a member of `$script:CommandLineWrapperNames`, the segment carries no `$(` or backtick and its quotes close, so ScanText is MaskedText and the quoted literal is masked to spaces
CITATION: AT-8 case `git push --force-with-lease origin HEAD` (unquoted, so MaskedText equals RawText) — re-derived for D13: the substring `git push --force` is present as the leading prefix of `git push --force-with-lease`
CITATION: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md | tasks `[P1-T2]`, `[P1-T4]`, `[P2-T2]`, `[P2-T4]`, `[P3-T1]` — re-derived for D14, confirmed none of the five contains a `Write evidence/...` artifact-path sentence in its task body
REVISION-ROUND: 2 — deltas D12 through D14 applied; the five citations above were re-derived against
the working tree in this pass. All other `CITATION:` lines and all twelve rippled count values,
the two-anchor split, the `-e` insertions, the `echo "rm -rf /tmp/x` pinning cases, Delta 6c's
`.DESCRIPTION` prose, the `[P2-T7]`-to-`[P3-T2]` porcelain chain, the `[P3-T1]` grep file paths and
its "lines 170–171" citation, the `[P0-T6]` forward reference, the `ExpectedExitCode` bookkeeping,
and the `[P4-T9]` row mapping are unchanged from round 1 and were not re-derived in this pass because
this round's edits did not touch them or their sibling regions.
