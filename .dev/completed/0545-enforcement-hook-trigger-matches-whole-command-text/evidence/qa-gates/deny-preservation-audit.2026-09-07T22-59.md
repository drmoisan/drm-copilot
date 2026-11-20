# Final QA — Deny-Preservation Audit for AC-09 (cycle 2)

Task: `[P5-T9]`
Timestamp: 2026-09-07T22-59
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

**Result: PASS.** Every row's post-fix decision equals its decision at the feature-wide anchor
`6dff80ed4596bec088d548b23013e6077e32c484`. Every row cites a named `It` that pins it, and every
cited `It` is recorded `Passed` at the current head.

## Commands run

Command: `grep -o 'name="…" … status="…"' artifacts/pester/pester-junit.xml`, over the JUnit report
produced by the `[P5-T1]` final-QA test stage at HEAD `06d166e0f47e4c377618384c8d2904ac0ab1a306`.
EXIT_CODE: 0

Command: `grep -c '<It name literal>' <suite path>` for each of the twenty-two distinct `It` names.
EXIT_CODE: 0

Command:
`grep -rn "CdChainedReadCommandPattern" . --include=*.ps1 --include=*.psm1 --include=*.psd1`
EXIT_CODE: 0

The status column is read from the JUnit report rather than restated from the plan, so each row is a
recorded observation of the head's behaviour rather than a claim carried forward.

## Part 1 — the four regressing commands from the Scope table

| Instance | Regressing command | Decision at `6dff80ed` (feature-wide anchor) | Decision at post-fix head `06d166e0` | Pinning `It` name | Row |
|---|---|---|---|---|---|
| R-2.a | `bash -c "gh pr merge --merge 688"` | deny, reason matches `EPIC_MERGE_GATE_BLOCKED` | deny, reason matches `EPIC_MERGE_GATE_BLOCKED` | `R2a-C1 denies a gh pr merge --merge carried inside a bash -c argument` (Claude); `R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument` (Codex) | **PASS** |
| R-2.b | `bash -c "python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition abandon"` | deny, reason matches `PARALLEL_ABANDON_BLOCKED` | deny, reason matches `PARALLEL_ABANDON_BLOCKED` | `R2b-C1 denies the space-separated disposition carried inside a bash -c argument` | **PASS** |
| R-2.c | `bash -c "gh pr edit 42 --body 'x'"` | deny, reason matches `PR_AUTHOR_SKILL_BLOCKED` (Case A) | deny, reason matches `PR_AUTHOR_SKILL_BLOCKED` | `R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument` | **PASS** |
| R-2.d | `bash -c "cd /x && head f"` | denied by the `cd`-chain pattern (`Get-CdChainedReadCommandMatch` returns `head`) | `Get-CdChainedReadCommandMatch` returns `head` | `R2d-C1 returns head for a cd-chained read inside a bash -c argument` | **PASS** |

Four rows, four PASS. Each anchor decision is the value the Scope table records at column
`At 6dff80ed`; each head decision is the assertion the cited `It` makes, observed `Passed` in the
JUnit report at HEAD.

R-2.a is the only instance with a row on both runtimes, because the merge-gate scope filter exists in
both. R-2.b, R-2.c, and R-2.d are Claude-only, per the Scope table's `Fix location` column.

### The `.codex` runtime contributes no R-2.d row

`.codex/hooks/validate-bash.ps1` carries no `cd`-chain rule, so there is no Codex-side decision for
R-2.d to preserve and no Codex row is possible. The evidence is the Scope-section `grep`, re-run at
the current head:

```
$ grep -rn "CdChainedReadCommandPattern" . --include=*.ps1 --include=*.psm1 --include=*.psd1
.claude/hooks/validate-bash.ps1:222:$script:CdChainedReadCommandPattern = 'cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b'
.claude/hooks/validate-bash.ps1:292:            $segment.ScanText -match $script:CdChainedReadCommandPattern
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1:222:$script:CdChainedReadCommandPattern = '…'
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1:292:            $segment.ScanText -match $script:CdChainedReadCommandPattern
```

Four matches, in the Claude canonical copy and its bundle mirror only. No `.codex` path appears. The
declaration at line 222 is unchanged; line 292 is the new read this cycle added, which un-orphans the
constant and closes code-review finding C-3 incidentally.

## Part 2 — the twenty-seven new pinning cases

Twenty-two distinct `It` names, carried by twenty-seven cases because `[P1-T2]`'s five names are
added to both scanner suites. All twenty-seven observed `Passed`.

| Source task | Suite | `It` name | Status at head |
|---|---|---|---|
| `[P1-T2]` | `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | `R2-P1 reports true for a wrapper-led segment` | Passed |
| `[P1-T2]` | same | `R2-P2 reports true for a segment carrying a live substitution` | Passed |
| `[P1-T2]` | same | `R2-P3 reports true for an unbalanced segment` | Passed |
| `[P1-T2]` | same | `R2-P4 reports false for a masked quoted mention in a non-wrapper segment` | Passed |
| `[P1-T2]` | same | `R2-P5 reports false for a null segment` | Passed |
| `[P1-T2]` | `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | `R2-P1 reports true for a wrapper-led segment` | Passed |
| `[P1-T2]` | same | `R2-P2 reports true for a segment carrying a live substitution` | Passed |
| `[P1-T2]` | same | `R2-P3 reports true for an unbalanced segment` | Passed |
| `[P1-T2]` | same | `R2-P4 reports false for a masked quoted mention in a non-wrapper segment` | Passed |
| `[P1-T2]` | same | `R2-P5 reports false for a null segment` | Passed |
| `[P2-T2]` | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `R2a-C1 denies a gh pr merge --merge carried inside a bash -c argument` | Passed |
| `[P2-T2]` | same | `R2a-N1 still allows a commit message quoting the merge phrase and the merge flag` | Passed |
| `[P2-T2]` | same | `R2a-N2 keeps a gh pr merge --merge relocated through xargs in scope` | Passed |
| `[P2-T3]` | `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | `R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument` | Passed |
| `[P2-T3]` | same | `R2a-X2 still allows a commit message quoting the merge phrase and the merge flag` | Passed |
| `[P3-T2]` | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-C1 denies the space-separated disposition carried inside a bash -c argument` | Passed |
| `[P3-T2]` | same | `R2b-C2 denies the equals-joined disposition carried inside a bash -c argument` | Passed |
| `[P3-T2]` | same | `R2b-C3 allows a wrapper-led abandon carrying the confirmation marker in the same segment` | Passed |
| `[P3-T2]` | same | `R2b-N1 still allows a commit message quoting the disposition token` | Passed |
| `[P3-T3]` | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument` | Passed |
| `[P3-T3]` | same | `R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case` | Passed |
| `[P3-T3]` | same | `R2c-N1 still routes a non-wrapper --body-file edit to the context check` | Passed |
| `[P3-T3]` | same | `R2c-N2 still allows a quoted --body mention inside a JSON receipt value` | Passed |
| `[P4-T2]` | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `R2d-C1 returns head for a cd-chained read inside a bash -c argument` | Passed |
| `[P4-T2]` | same | `R2d-C2 returns grep for a semicolon-chained read inside an sh -c argument` | Passed |
| `[P4-T2]` | same | `R2d-C3 returns cat for a cd-chained read inside a pwsh -Command argument` | Passed |
| `[P4-T2]` | same | `R2d-N1 still returns null for an echo whose quoted text contains a cd-then-read phrase` | Passed |

Count: 27 rows. Distinct names: 22. Both figures agree with the plan.

Presence in the tree was confirmed independently of the test run: `grep -c` returns 5 in each of the
two scanner suites, 3 in the Claude merge-gate trigger-scoping suite, 2 in the Codex one, 4 in the
abandon suite, 4 in the pr-author suite, and 4 in the validate-bash trigger-scoping suite.
5 + 5 + 3 + 2 + 4 + 4 + 4 = 27.

## Part 3 — the paired negatives from `[P2-T8]`

These are the preservation rows the reaudit requires as the AT-4 paired negative. A non-passing row
on any of them would mean an existing allow was turned into a deny.

| Suite / Context | `It` name | Status at head |
|---|---|---|
| Claude merge-gate trigger scoping, `PR-number extraction comes from the matched segment only` | `returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag` | Passed |
| same | `returns null for a bare gh pr merge --merge that names no PR number` | Passed |
| same | `returns 410 for the positional spelling gh pr merge 410 --merge` | Passed |
| same | `returns 410 for the equals-joined spelling gh pr merge --merge=410` | Passed |
| Claude merge-gate trigger scoping, `scope filter separates a mention from an invocation` | `allows a printf whose double-quoted text mentions the gated merge phrase` | Passed |
| Codex merge-gate trigger scoping, `scope filter separates a mention from an invocation` | `allows a quoted mention of the gated merge phrase` | Passed |
| Claude merge-gate trigger scoping, `the false-allow direction of the whole-line PR-number defect` | `takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path` | Passed |
| same | `denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line` | Passed |
| same | `still allows merging the authorized PR 501 when 501 is the merge operand` | Passed |

Nine rows, all Passed. The eighth row is the case execution amendment EA-2 makes binding on this
feature; it passes.

Recorded additionally, though not required by `[P2-T8]`: the acceptance-case suite's
`AT-4 allows a printf whose double-quoted text mentions the gated merge phrase` is also `Passed`, so
the AT-4 negative holds on both the trigger-scoping and the acceptance surface.

## Part 4 — the paired negatives from `[P3-T9]`

### The three pre-existing abandon-suite cases

| `It` name | Status at head |
|---|---|
| `AT-11 takes a grep whose quoted search term is the disposition token out of scope` | Passed |
| `AT-12 brings the equals-joined spelling of the disposition option into scope` | Passed |
| `does not accept a confirmation marker that sits in a different segment from the disposition token` | Passed |

### The eighteen pre-existing pr-author trigger-scoping cases

| Context | `It` name | Status at head |
|---|---|---|
| `over-match removal - a quoted mention is not an invocation` | `allows a quoted --body-file mention inside a JSON receipt value` | Passed |
| `under-match removal - a relocating spelling now classifies` | `classifies gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md` | Passed |
| same | `classifies gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md` | Passed |
| `flag distinction - --body does not match --body-file` | `does not match --body against a --body-file token` | Passed |
| `wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test` | `wrapper deny pin 1: classifies a gh pr create relocated through xargs` | Passed |
| same | `wrapper deny pin 2: classifies a gh pr create nested inside a bash -c argument` | Passed |
| same | `wrapper deny pin 3: classifies a gh pr create nested inside an sh -c argument` | Passed |
| same | `wrapper deny pin 4: classifies a gh pr create behind the env transparent wrapper` | Passed |
| same | `wrapper deny pin 5: classifies a gh pr create behind the pwsh -Command wrapper` | Passed |
| same | `wrapper deny pin 6: classifies a heredoc body piped into bash` | Passed |
| same | `wrapper deny pin 7: classifies a live substitution inside a double-quoted span` | Passed |
| `every PR_* reason code is still produced for its genuine triggering invocation` | `PR_AUTHOR_SKILL_BLOCKED for gh pr create with no body flag` | Passed |
| same | `PR_CONTEXT_MISSING for gh pr create --body-file when the context artifact is absent` | Passed |
| same | `PR_BODY_PATH_NONCANONICAL for a --body-file path outside the canonical pattern` | Passed |
| same | `PR_AUTHOR_RECEIPT_MISSING when the sibling receipt is absent` | Passed |
| same | `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when the receipt number does not equal the path number` | Passed |
| same | `PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body hash does not equal the recorded hash` | Passed |
| same | `PR_AUTHOR_RECEIPT_STALE when created_at is not newer than the context last-write` | Passed |

Eighteen rows: seven wrapper deny pins, seven `PR_*` reason-code cases, and four others including
the JSON-receipt negative. All Passed. Total for `[P3-T9]`: 3 + 18 = 21 preservation rows, matching
the count the task states.

## Part 5 — the paired negatives from `[P4-T6]`

### The eight `cd`-chain cases in `tests/scripts/claude-hooks/validate-bash.Tests.ps1`

Context `Get-CdChainedReadCommandMatch detects cd-chained read commands`. The task enumerates eight
command fixtures; the suite groups them into eight `It` cases, of which the first drives every
read-command family (`grep`, `cat`, `tail`, `head`, `less`, `more`, `awk`, `sed -n`) over the `&&`
and `;` spellings.

| `It` name | Status at head |
|---|---|
| `matches every read-command family chained after cd via '&&' or ';'` | Passed |
| `matches even when the chained command's own path argument is absolute` | Passed |
| `returns $null for a bare read command with no preceding cd` | Passed |
| `returns $null for a cd chained with a non-read-command (no false positive on common toolchain invocations)` | Passed |
| `returns $null for empty or null input` | Passed |
| `produces a deny reason via Get-BashBlockReason naming the matched read command` | Passed |
| `the dangerous-pattern denylist takes precedence when a command matches both` | Passed |
| `denies through Invoke-ValidateBashDecision for a cd-chained read command in the nested tool_input` | Passed |

The eight fixtures the task names (`cd /tmp/x && grep -n test file.txt`, `cd /tmp/x && cat file.txt`,
`cd /tmp/x; tail -f log.txt`, `cd /tmp/x && head -20 file.txt`, `cd /tmp/x && less file.txt`,
`cd /tmp/x && more file.txt`, `cd /tmp/x && awk "{print}" file.txt`, and
`cd /tmp/x && sed -n 1,5p file.txt`) are all driven by the first case's family table, which passes.

### The two pre-existing trigger-scoping `cd`-chain cases

| Context | `It` name | Status at head |
|---|---|---|
| `the cd-chained read-command leg` | `allows a commit message whose quoted text contains a cd-then-read phrase` | Passed |
| same | `still denies a read command that is not adjacent to the cd segment` | Passed |

Ten rows for `[P4-T6]`, all Passed.

## Suite-level counts at the head

Local `[P5-T1]` run, `artifacts/pester/pester-junit.xml`: `tests="2408" errors="0" failures="2"`.
The two failures are the two tolerated ambient-state failures named in the plan's Scope section, in
suites this cycle did not modify. No suite named in this audit carries a failure.

Independent corroboration on a clean checkout: CI run `34181009673` of `.github/workflows/_poshqc.yml`
at this exact head SHA reports **4363 tests, 0 failures, 0 errors, 0 suites with failures**. The two
locally observed failures do not reproduce there, which directly evidences the plan's standing claim
that they are ambient to this workstation. That claim was asserted in every cycle-2 artifact but had
not previously been evidenced by a clean-checkout run.

## Output Summary

Deny preservation confirmed for AC-09. All four regressing commands from the Scope table produce, at
post-fix head `06d166e0`, the same decision they produced at the feature-wide anchor `6dff80ed`:
R-2.a denies `EPIC_MERGE_GATE_BLOCKED` on both runtimes, R-2.b denies `PARALLEL_ABANDON_BLOCKED`,
R-2.c denies `PR_AUTHOR_SKILL_BLOCKED`, and R-2.d returns `head` from
`Get-CdChainedReadCommandMatch`. Every row cites a named `It`, and every cited name is one of the
twenty-two distinct names carried by twenty-seven cases; all twenty-seven are `Passed`. All forty
paired-negative preservation rows named by `[P2-T8]` (9), `[P3-T9]` (21), and `[P4-T6]` (10) are
`Passed`, so no existing allow was turned into a deny. The `.codex` runtime carries no `cd`-chain
rule — the repo-wide `grep` for `CdChainedReadCommandPattern` returns matches only in the Claude
canonical copy and its bundle mirror — so it contributes no R-2.d row. Local run: 2408 tests, 0
errors, 2 tolerated ambient failures. CI run `34181009673` on a clean checkout of the same head:
4363 tests, 0 failures.
