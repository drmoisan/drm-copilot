# Research — epic merge gate: command-text matching (Issue #591)

- **Timestamp:** 2026-09-07T00-45
- **Issue:** #591
- **Branch:** `bug/epic-merge-gate-parses-pr-number-from-whole-command-line-591`
- **Worktree root:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a34e845411e5cc44b`
- **Scope:** read-only analysis of `.claude/hooks/enforce-epic-merge-gate.ps1` and its
  delivery/test surface. No production or test file was modified in this pass.
- **Tooling note:** the Bash tool is disabled in this session. Every line count in this artifact was
  re-derived by reading the file and/or by a `Grep` line-count over the pattern `^`; no `wc`,
  `sha256sum`, or `Get-FileHash` was executed, so no hash claim is made anywhere below.

---

## 1. Current state — verified facts

### 1.1 File inventory and re-derived sizes

| Path | Lines (re-derived) | Method | Headroom vs 500 |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 452 | `Grep` count of `^` = 452; `Read` last content line 452 | 48 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 140 | `Grep` count of `^` = 140; `Read` last content line 140 | 360 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 452 (tail read at 440–452 matches canonical byte-for-byte as displayed) | `Read` offset 440 | 48 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | not separately counted; regex sites match the Codex canonical at lines 33 and 98 | `Grep` content match | n/a |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 455 (line 455 is the closing `}`; a trailing newline makes `Read` display an empty line 456) | `Grep` count of `^` = 455; `Read` offset 450 | 45 |
| `.claude/lib/hook-payload/HookPayload.psm1` | 496 | `Grep` count of `^` = 496 | **4** |

`HookPayload.psm1` has four lines of headroom. Any fix that needs a new shared helper must not put it
there.

### 1.2 The Claude canonical hook — structure

All function definitions in `.claude/hooks/enforce-epic-merge-gate.ps1`, enumerated by
`Grep '^function '`:

| Line | Function |
| --- | --- |
| 48 | `Get-ChildOrchestratorCheckpointContent` |
| 66 | `Get-EpicOrchestratorCheckpointContent` |
| 84 | `Get-ParallelOrchestratorCheckpointContent` |
| 102 | `ConvertFrom-EpicMergeGateJson` |
| 127 | `Get-EpicMergeGateCommandPrNumber` |
| 160 | `Test-ChildCheckpointAllowsEpicMerge` |
| 189 | `Test-EpicCheckpointAllowsMerge` |
| 247 | `Test-ParallelCheckpointAllowsMerge` |
| 310 | `Get-EpicMergeGateAllowDecision` |
| 323 | `Get-EpicMergeGateBlockDecision` |
| 340 | `Invoke-EpicMergeGateDecision` |
| 401 | `Invoke-EpicMergeGateEntryPoint` |

Decision returns inside `Invoke-EpicMergeGateDecision`: block at 364 and 398; allow at 372, 378,
385, 390, 395.

Correction to the delegation prompt's line references: `Get-EpicMergeGateCommandPrNumber` begins at
**line 127** (the prompt said "near line 130"; 130 is the `.SYNOPSIS` body line). The two extraction
branches (146, 154) and the trigger guard (377) are exactly as the prompt states.

### 1.3 The three regex sites (verbatim, re-derived)

`Grep` over `**/enforce-epic-merge-gate.ps1`:

```
.claude/hooks/enforce-epic-merge-gate.ps1:146:    if ($CommandText -match '(?i)\bgh\s+pr\s+merge\s+(\d+)\b') {
.claude/hooks/enforce-epic-merge-gate.ps1:154:    if ($CommandText -match '(?i)\bgh\s+pr\s+merge\b' -and $CommandText -match '(?<![-\w])(\d+)\b') {
.claude/hooks/enforce-epic-merge-gate.ps1:377:    if ($commandText -notmatch '(?i)\bgh\s+pr\s+merge\b' -or $commandText -notmatch '--merge\b') {
```

`$Matches` semantics at line 154–155: PowerShell evaluates the `-and` operands left to right and
each successful `-match` overwrites `$Matches`. When the body is entered, both operands succeeded,
so `$Matches[1]` at line 155 is the capture group of the **second** expression — the free-floating
digit run — not of the `gh pr merge` anchor. This is the mechanism of Defect 1.

### 1.4 The Codex copy is a different implementation, not a mirror of the Claude copy

`.codex/hooks/enforce-epic-merge-gate.ps1` (140 lines) defines `ConvertFrom-CodexMergeJson` (8),
`Get-CodexMergeCommandPrNumber` (28), `Test-CodexChildMergeReady` (39), `Test-CodexEpicMergeReady`
(57), `Invoke-CodexEpicMergeDecision` (84).

Material differences verified by reading the whole file:

- **Defect 1 is absent on the Codex side.** `Get-CodexMergeCommandPrNumber` (line 33) carries only
  the anchored form `'(?i)\bgh\s+pr\s+merge\s+(\d+)\b'` and returns `$null` otherwise. The
  broadened whole-text scan was never added there.
- The Codex copy has **no parallel branch at all**: only the child path and the epic path
  (lines 103 and 108). `route_id == "parallel"` is not modeled.
- The Codex child predicate accepts `step9_status` of `passed` **or** `verified` (line 53); the
  Claude predicate accepts only `passed` (line 186).
- **Defect 2 is present on the Codex side, identically**: line 98 is the same conjunction of two
  whole-text matches (with an explicit `(?i)` on the `--merge` leg; the Claude line 377 omits it,
  which is immaterial because PowerShell `-match` is case-insensitive by default).

Implication: the Defect-1 fix is Claude-only; the Defect-2 fix would be a four-copy change if the
Codex side is brought in scope. That is a scoping decision for the spec, recorded in §9.

### 1.5 Registration and mirror surface (re-derived)

| Registration | Location (verified) | Present today? |
| --- | --- | --- |
| Claude PreToolUse hook registration | `.claude/settings.json` line 111, inside the `"matcher": "Bash"` group opened at line 91 | yes |
| Claude bundle `settings.json` mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json:111` | yes |
| Codex hook registration | `.codex/config.toml:142` (`command`) and `:143` (`command_windows`) | yes |
| Codex bundle config mirror | `extensions/.../codex-and-agents-customizations/.codex/config.toml:142-143` | yes |
| Claude pack manifest | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:29` | yes |
| Codex pack manifest | `extensions/.../codex-and-agents-customizations/pack-manifests/core.json:35` | yes |
| PoshQC coverage (canonical) | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:44` — entry is `.claude/hooks/enforce-epic-merge-gate.ps1` | yes, Claude path only |
| PoshQC coverage (extensions mirror) | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1:44` | yes, Claude path only |
| PoshQC coverage for the **Codex** copy | not present in either `CodeCoverage.Path` list (full list read: lines 23–245 of the canonical `.psd1`; `.codex/hooks/enforce-epic-merge-gate.ps1` does not appear) | **no** |

Enforcing tests, by name:

| Obligation | Enforcing test | Locator |
| --- | --- | --- |
| Codex canonical ↔ Codex bundle byte identity for this hook | `It 'keeps root and tracked bundle runtime copies byte-identical'` | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:162`, driven from `$script:RuntimePaths` which lists `.codex/hooks/enforce-epic-merge-gate.ps1` at line 29 |
| Codex pack-manifest membership | `It 'includes every epic runtime surface in the core pack manifest'` | same file, line 134; the path is asserted at line 152 |
| Codex 500-line cap over `.codex/hooks/*.ps1` | `It 'keeps hook, config, and agent files within the 500-line limit'` | same file, line 172 |
| Codex hook registration in `config.toml` | `It 'registers root provenance, attestation, planning, wave, merge, worktree, and stop gates'` | same file, line 63; the name is asserted at line 72 |
| Claude canonical ↔ Claude bundle content equality | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:106` — enumerates every non-memory `.claude/**` file and asserts presence plus text equality in the bundle |
| Claude pack-manifest membership | `it.each(...)("issue #279 AC1: %s is present in the union of pack-manifest paths")` | `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:257-273`; the path is listed at line 260 |
| No Python in the hook | `It 'reports no Python invocation beyond the allowlist across the guarded tree'` | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:473`; scan roots are `.claude/hooks` and `.claude/lib` (lines 39–42), so the merge gate is automatically in scope and the bundled mirror is deliberately excluded (line 468) |
| Behavioral suite | `Describe 'enforce-epic-merge-gate.ps1'` | `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:8` |

There is **no** Pester suite that dot-sources the Claude copy's parallel logic on the Codex side;
`tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1:10` dot-sources the Codex copy.

### 1.6 Documented command shapes the orchestrators actually emit

- Parallel per-item merge: `` `gh pr merge --merge <PR>` `` — `.claude/skills/parallel-orchestrate/SKILL.md:322`.
- Epic integration merge: `` `gh pr merge --merge` `` (bare, current branch) — `.claude/skills/epic-orchestrate/SKILL.md:111`.
- Gate contract restated for operators: `.claude/skills/parallel-orchestrate/SKILL.md:327-334` and
  `.claude/rules/parallel-orchestration.md:411`.

Both documented forms place the number (when present) **after** `--merge`, i.e. they exercise the
defective branch at line 154, never the anchored branch at line 146.

---

## 2. Question 1 — Defect 1 mechanics: every command shape, handled and mis-handled

Regex facts used throughout: `\w` is `[A-Za-z0-9_]`; the lookbehind `(?<![-\w])` rejects a digit run
immediately preceded by `-` or by any word character (including another digit); the trailing `\b`
requires the digit run to end at a word boundary, so a digit run immediately followed by a letter
cannot match at that start position.

| # | Command text | Branch A (146) | Branch B (154) | Returned | Correct value | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `gh pr merge 410 --merge` | matches, group = `410` | not reached | `410` | 410 | correct |
| 2 | `gh pr merge --merge 410` | fails (`-` is not `\d`) | cond1 true; first eligible run is `410` (preceded by space) | `410` | 410 | correct **by position accident** |
| 3 | `gh pr merge --merge` | fails | cond1 true, cond2 finds no digit run | `$null` | `$null` | correct; must be preserved |
| 4 | `cd C:\...\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688` | fails | cond1 true; `2026` preceded by `\` (neither `-` nor `\w`), followed by `-` so `\b` holds | **`2026`** | 688 | **the reported defect** |
| 5 | `cd /repos/wt2026/x && gh pr merge --merge 688` | fails | `2026` preceded by `t` → lookbehind fails; every suffix start (`026`,`26`,`6`) is preceded by a digit → fails; scan continues to `688` | `688` | 688 | correct; this is the case the existing lookbehind already excludes |
| 6 | `cd /repos/2026-wt && gh pr merge --merge 688` | fails | `2026` preceded by `/` → eligible | **`2026`** | 688 | **same defect, different separator** — confirms that widening the lookbehind to exclude `\` would not fix the class |
| 7 | `gh pr merge https://github.com/o/r/pull/688 --merge` | fails (`h` of `https` is not `\d`) | cond1 true; `688` preceded by `/` → eligible | `688` | 688 | **correct only by accident**: nothing binds `688` to `/pull/`; it wins because it is the first eligible run |
| 8 | `gh pr merge https://github.com/2org/r/pull/688 --merge` | fails | at `2` of `2org`: preceded by `/` (eligible) but followed by `o`, so the trailing `\b` fails and `\d+` cannot backtrack shorter; the engine advances and finds `688` | `688` | 688 | correct by accident |
| 9 | `gh pr merge https://gh.example.com/8/o/r/pull/688 --merge` (a digit run isolated by slashes anywhere earlier in the URL) | fails | `8` preceded by `/`, followed by `/` → eligible and wins | **`8`** | 688 | **mis-handled**; the prompt's hypothesis about digits in a host or org path is confirmed for any slash-delimited digit segment |
| 10 | `gh pr merge --merge --body "closes 123" 688` | fails | `123` inside the quoted body wins | **`123`** | 688 | **mis-handled**; a message/body operand is scanned as if it were the operand |
| 11 | `gh pr merge --merge=1 688` (pflag boolean `=` form — see caveat below) | fails | `1` preceded by `=` → eligible and wins | **`1`** | 688 | **mis-handled** |
| 12 | `gh pr merge 688 --merge=1` | matches, group = `688` | not reached | `688` | 688 | correct |
| 13 | `gh pr merge --merge 501 && gh pr merge --merge 777` | fails | first eligible run `501` wins | `501` | ambiguous — two targets | **mis-handled; this is the false-ALLOW vector, see §3** |
| 14 | `gh pr merge --merge my-branch-591` | fails | `591` preceded by `-` → lookbehind fails; `91`/`1` preceded by digits → fail; no other run | `$null` | `$null` (a branch operand is not a PR number) | correct by accident |
| 15 | `gh pr merge --merge 2026-fix` (a branch operand beginning with digits) | fails | `2026` preceded by space, followed by `-` → eligible | **`2026`** | `$null` | **mis-handled**: a branch-name operand is read as a PR number |
| 16 | `cd /wt/501 && gh pr merge --merge 777` | fails | `501` wins | **`501`** | 777 | **mis-handled, and the dangerous direction — see §3** |

**Grammar caveat that materially changes the fix shape.** The issue text and the current in-code
comment (lines 149–153) both describe the number as "the argument following `--merge`". That is not
how `gh pr merge` is specified: `--merge` (`-m`) is a boolean strategy flag and the pull request is
a **positional operand** with the documented alternation `<number> | <url> | <branch>`, which may
appear before or after the flag. Row 14/15 above follow from that: a branch-name operand is legal
and is not a number. **This grammar claim was not verified in this pass** (no shell is available to
run `gh pr merge --help`); the spec should require the executing agent to confirm it against
`gh pr merge --help` before pinning tests for rows 11, 14, and 15.

**Under-match on the extractor itself.** `gh --repo o/r pr merge --merge 688` and
`gh -R o/r pr merge --merge 688` fail both branches' `\bgh\s+pr\s+merge` anchor. They also fail the
trigger at line 377, so they never reach extraction at all. See §4.

---

## 3. Question 2 — downstream consumers, and the deny-only determination

### 3.1 `Test-EpicCheckpointAllowsMerge` (lines 189–245)

- `$null` checkpoint → `$false` (line 211–213).
- Missing `epic_merge_pr`, missing/`$null` `ci_gate`, or `ci_gate.conclusion != 'success'` →
  `$false` (lines 215–226).
- **`$CommandPrNumber` is `$null` → the pr_number comparison at lines 231–242 is skipped entirely
  and the function returns `$true`** (line 244). The comment at 228–230 states the intent: a bare
  command "implicitly targets the current branch's PR and is trusted".
- `$CommandPrNumber` non-null and unequal to `epic_merge_pr.pr_number` → `$false` (line 239–241).

So on the epic path: **`$null` is permissive; a wrong number is restrictive unless it happens to
equal the pinned number.**

### 3.2 `Test-ParallelCheckpointAllowsMerge` (lines 247–308)

- `$null` checkpoint → `$false` (270–272).
- `route_id != 'parallel'` → `$false` (274–276).
- **`$CommandPrNumber` is `$null` → `$false`** (279–281), with the comment at 277–278 recording the
  fail-closed intent.
- Otherwise it scans `items[]` for the first entry whose `pr_number` parses and equals
  `$CommandPrNumber`; that entry's `merge_status` must be `ci_green` (286–305); no match → `$false`
  (307).

So on the parallel path: **`$null` denies; a wrong number denies unless it collides with a different
`items[]` entry that is `ci_green`.**

### 3.3 Determination: the defect is **NOT deny-only**

A wrong parse produces a **false ALLOW** whenever the mis-parsed value collides with an authorized
number while the command's real target is a different, unauthorized pull request. Two concrete
shapes, both constructed only from mechanics verified above:

1. **Parallel path, digit run in the `cd` prefix** (row 16 of §2). Checkpoint:
   `{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"},{"pr_number":777,"merge_status":"pr_open"}]}`.
   Command: `cd /wt/501 && gh pr merge --merge 777`. Extraction returns `501`;
   `Test-ParallelCheckpointAllowsMerge` matches item 501, sees `ci_green`, returns `$true`;
   `Invoke-EpicMergeGateDecision` allows at line 395. The shell then merges PR **777**, which the
   checkpoint records as `pr_open`. The gate authorized a merge it was written to deny.
2. **Chained merges in one command** (row 13). `gh pr merge --merge 501 && gh pr merge --merge 777`
   parses to `501`, is allowed, and executes both merges. Only the first is validated. This is a
   structural consequence of the gate extracting **one** number from a command line that can carry
   several invocations; it is not specific to the broadened branch and would survive a
   lookbehind-only fix.
3. **Epic path, `$null` permissiveness.** `gh pr merge --merge 2026-fix` where the real target is a
   branch operand: row 15 makes this return `2026`, which denies. But
   `gh pr merge --merge my-branch-591` returns `$null` (row 14) and the epic path then allows any
   target as long as `ci_gate.conclusion == "success"` — the number is never checked. This is a
   pre-existing design decision (documented at lines 228–230), not a Defect-1 consequence, but it
   means the epic path cannot be strengthened by fixing extraction alone.

**Conclusion for the spec: the defect is bidirectional.** The reported symptom is a false DENY; the
same mechanism admits a false ALLOW on the parallel path whenever an unrelated digit run collides
with a `ci_green` item, and on any path when several `gh pr merge` invocations are chained. The
severity rationale in `spec.md` lines 21–27 currently reasons only about the fail-closed direction
and should be amended.

---

## 4. Question 3 — Defect 2 mechanics and blast radius

### 4.1 Mechanics

The gate arms iff **both** whole-text expressions match the raw `tool_input.command`
(line 377), with no requirement that the two matches be in the same command, the same pipeline
segment, or outside quotes:

- `(?i)\bgh\s+pr\s+merge\b` — `\b` is a word boundary, so a preceding `'`, `"`, `(`, `` ` ``, `>`,
  or `=` all satisfy it. This is **weaker than** the `(^|\s)` anchor used by the preimplementation
  gate that issue #545 analyzed, so quote-abutted text that #545 measured as *already ungated* in
  that hook **is gated here**.
- `--merge\b` — matches `--merge`, `--merge=true`, `--MERGE`, and the phrase "the `--merge` flag"
  in prose.

### 4.2 Over-match shapes that arm the gate today

Every one of these is a harmless command whose text merely mentions the gated invocation:

| Shape | Why it arms |
| --- | --- |
| `printf 'gh pr merge --merge 688\n' >> notes.md` | both patterns present in the single-quoted argument |
| `cat <<'EOF' > doc.md` … `gh pr merge --merge <PR>` … `EOF` | heredoc body is part of `tool_input.command` |
| `echo "run gh pr merge --merge 688"` | double-quoted argument |
| `git commit -m "document the gh pr merge --merge gate"` | commit message |
| `gh api ... -f body='... gh pr merge --merge ...'` | JSON/form payload value |
| `grep -n 'gh pr merge' .claude/hooks/*.ps1 && grep -n -- '--merge' .claude/hooks/*.ps1` | two separate read-only commands; the conjunction bridges them |
| `gh pr merge --squash 410 && echo "--merge"` | cross-segment bridge that converts a **documented allow** into a deny |

The last row is the sharpest: `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:27-31`
(`It 'allows gh pr merge without --merge (e.g., --squash)'`) pins that a squash merge is out of
scope. A `--merge` token anywhere else on the line defeats that pin.

The 2026-09-06 observation quoted in the delegation prompt (a `printf` writing a memory note denied
with `EPIC_MERGE_GATE_BLOCKED`) is row 1 of this table.

**Reachable for harmless commands: yes, broadly.** Any Bash command that documents, greps for,
tests, or writes prose about this gate is denied. Note the hook is registered only on the `"Bash"`
matcher (`.claude/settings.json:91`), so the `Write`/`Edit` tools are unaffected — that is the
practical workaround today, and it is why this very artifact could be written.

### 4.3 Under-match shapes that do **not** arm the gate today

| Shape | Why it escapes | Direction |
| --- | --- | --- |
| `gh --repo o/r pr merge --merge 688` | `\bgh\s+pr\s+merge\b` requires `pr` adjacent to `gh` | **latent bypass** |
| `gh -R o/r pr merge --merge 688` | same | **latent bypass** |
| `gh pr merge -m 688` (short flag for `--merge`, subject to the §2 grammar caveat) | `--merge\b` does not match `-m` | **latent bypass** |
| `git${IFS}…`-style obfuscated respellings of `gh` | no whitespace/word boundary at the expected place | pre-existing, out of scope per #545 D4.2 |

### 4.4 Wrapper shapes that currently **do** arm and must keep arming

Because the anchor is `\b` rather than `(^|\s)`, these are gated today and a naive segment/masking
fix would newly allow them — a fail-open regression:

- `bash -c 'gh pr merge --merge 688'`
- `sh -c "gh pr merge --merge 688"`
- `echo 688 | xargs gh pr merge --merge`
- `env gh pr merge --merge 688`, `nohup gh pr merge --merge 688`
- `pwsh -NoProfile -Command "gh pr merge --merge 688"`
- `bash <<EOF` … `gh pr merge --merge 688` … `EOF`
- `echo "$(gh pr merge --merge 688)"`

Issue #545's D2 Piece 2 clause 2 (wrapper carve-out, fourteen members) and clause 1
(`HasLiveSubstitution` / `Unbalanced` → raw scan) are precisely the mechanisms that preserve these
denials. This is the strongest argument for reusing #545's helper rather than hand-rolling a
narrower fix here.

---

## 5. Question 4 — both regression directions, per defect

### Defect 1 (extraction)

- **Over-match / wrong-value direction (currently denies, fixed hook must allow):**
  `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688` against a
  parallel checkpoint whose item 688 is `ci_green`. Today: parses `2026`, denies. Fixed: parses
  `688`, allows. This is the issue's own repro.
- **Under-match / false-allow direction (currently allows, fixed hook must deny):**
  `cd /wt/501 && gh pr merge --merge 777` against
  `{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"},{"pr_number":777,"merge_status":"pr_open"}]}`.
  Today: parses `501`, **allows**. Fixed: parses `777`, denies. A second case in the same direction:
  `gh pr merge --merge 501 && gh pr merge --merge 777` under the same checkpoint.

### Defect 2 (trigger)

- **Over-match direction (currently denies, fixed hook must allow):**
  `printf 'gh pr merge --merge 688\n' >> notes.md` with **no** checkpoint present. Today: arms and
  denies. Fixed: the quoted span is masked in a non-wrapper segment, the gate never arms, allow.
  Second case: `gh pr merge --squash 410 && echo "--merge"`, which must resolve to allow because
  `--squash` is out of scope and the `--merge` token is in a different segment.
- **Under-match direction (currently allows, fixed hook must deny):**
  `gh --repo o/r pr merge --merge 688` with **no** checkpoint present. Today: no trigger match,
  allow. Fixed: the structural `gh` relocation classifier absorbs `--repo <arg>` and recognizes the
  `pr merge` subcommand path, so the gate arms and denies. Companion cases: `gh -R o/r pr merge
  --merge 688`, and (subject to the grammar caveat) `gh pr merge -m 688`.
- **Wrapper deny pins that must not regress:** the seven shapes listed in §4.4, each asserted to
  still deny.

---

## 6. Question 5 — the three accept paths, and the "any PR" claim

### `Test-ChildCheckpointAllowsEpicMerge` (lines 160–187)

Requires: a non-`$null` parsed checkpoint (176–178); a property named `epic_mode` whose value is
truthy under `[bool]` (180–182); a property named `step9_status` (183–185); and
`[string]$Checkpoint.step9_status -eq 'passed'` (186).

**The claim reported by the sibling child is CONFIRMED.** Evidence:

1. The `param()` block at lines 169–174 declares exactly one parameter, `$Checkpoint`. There is no
   `CommandPrNumber` parameter and no reference to any command text or PR number anywhere in the
   function body (lines 176–186).
2. The call site is `Invoke-EpicMergeGateDecision` line 384:
   `if (Test-ChildCheckpointAllowsEpicMerge -Checkpoint $childCheckpoint) { return Get-EpicMergeGateAllowDecision }` (385).
   `$commandPrNumber` is computed at line 381 and is **not** passed here.
3. This branch is consulted **first**, before both number-aware branches (389, 394). So when the
   child checkpoint qualifies, the parsed number is computed and discarded, and the decision is
   `allow` regardless of which pull request the command names.
4. No test pins otherwise: the two child-path decision tests
   (`tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:41` and `:445`) both use the bare
   `gh pr merge --merge` form, and the four direct-coverage tests at `:316`, `:320`, `:325`, `:330`
   call the predicate with `-Checkpoint` only.

So: a per-feature checkpoint with `epic_mode: true` and `step9_status: "passed"` authorizes
`gh pr merge --merge <any PR number>`. The same property holds in the Codex copy
(`Test-CodexChildMergeReady`, `.codex/hooks/enforce-epic-merge-gate.ps1:39-55`, which additionally
accepts `step9_status: "verified"`).

This is a **pre-existing design property, not a consequence of either defect**, and fixing
extraction does not change it. It should be recorded in the spec as an explicit non-goal or as a
separately-filed candidate, because widening the child predicate to take a PR number is a behavior
change with its own checkpoint-schema dependency (the child checkpoint would need a pinned
`pr_number` field the gate can compare against).

### `Test-EpicCheckpointAllowsMerge` (189–245) and `Test-ParallelCheckpointAllowsMerge` (247–308)

Fully characterized in §3.1 and §3.2.

---

## 7. Question 6 — existing test coverage

`tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, re-derived: **455 lines**, 1
`Describe`, **16** `Context` blocks, **56** `It` blocks (`Grep` counts over `^    Context '` = 16 and
over `^    It '|^        It '` = 56; 1 + 16 + 56 = 73, matching the combined count).

### Blocks that pin `Get-EpicMergeGateCommandPrNumber` directly

`Context 'Get-EpicMergeGateCommandPrNumber extractor (flag-order forms)'` (line 218), three `It`s:

| Line | Assertion | Effect of a positional fix |
| --- | --- | --- |
| 219 | `'gh pr merge 410 --merge'` → `410` | must stay green |
| 223 | `'gh pr merge --merge 410'` → `410` | must stay green |
| 227 | `'gh pr merge --merge'` → `$null` | must stay green |

None of the three carries a `cd` prefix, so **no existing assertion changes value under a correct
positional fix**. The extractor suite is a strict subset of the fixed behavior.

### Blocks that pin the trigger

- `Context 'commands outside scope'` (14): `It` at 21 (`git status` → allow) and `It` at 27
  (`gh pr merge 10 --squash` → allow). Both must stay green. The 27 case is the one a
  cross-segment `--merge` mention defeats today.
- Every `Context` from line 40 onward supplies a command that both arms the trigger and exercises a
  checkpoint branch. All must stay green.
- `Context 'Invoke-EpicMergeGateDecision - command field absent'` (367): allow. Must stay green.

### Blocks that indirectly consume the parsed number

- `:64` epic allow with `gh pr merge 410 --merge` (anchored branch).
- `:74` epic allow with a bare command (the `$null`-is-permissive path).
- `:86` epic deny with `gh pr merge 999 --merge`.
- `:136`, `:149`, `:161`, `:173`, `:185`, `:195`, `:205` parallel branch, all using
  `gh pr merge --merge <n>` (the defective branch) with **no** `cd` prefix — so all remain green.
- `:414` and `:436` entry-point tests using `gh pr merge 999 --merge`.

### Assertions a fix would have to change

**Under the recommended fix shape (§9), none of the 56 existing `It` blocks changes its expected
value.** Every existing command fixture is a bare, unwrapped, unquoted, single-segment invocation.
That is a favorable position: the whole suite is a deny-preservation baseline and the new behavior
is purely additive. The spec should state this as an explicit acceptance criterion
("no existing `It` in `enforce-epic-merge-gate.Tests.ps1` changes its expected decision"), because
if a candidate implementation *does* flip one, that is a signal of over-reach.

### Headroom

455 of 500 lines = **45 lines of headroom**. The test matrix in §9.2 is on the order of 25–35 new
`It` blocks; at roughly 5–7 lines each (mock setup plus assertion) that is 150–250 lines. **New
cases do not fit.** They must go in a sibling file — recommended
`tests/scripts/claude-hooks/enforce-epic-merge-gate.CommandScanning.Tests.ps1`, following the
`enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` naming precedent that #545
establishes.

---

## 8. Question 8 — the protection-ruleset fact and what it implies

Taken as given from the sibling child's verification (not re-queried in this pass): `main` is
protected by repository ruleset id **15241672**, enforcing eleven required status checks with
`strict_required_status_checks_policy: true`.

Implications the spec must carry:

1. **This gate is a procedure deterrent, not the control that keeps failing work out of `main`.**
   The branch ruleset is server-side and applies to every actor including a human with admin rights
   using `--admin`; a red pull request cannot merge irrespective of what this hook decides. The
   hook's job is to enforce *the orchestration procedure* — that a merge is attempted only from a
   checkpoint state that records the run's own CI gate as green and pins the target — not to be the
   last line of defence against merging broken code.
2. **Therefore the false-ALLOW findings in §3.3 are procedure violations, not "merges broken code
   into main" incidents.** They should be described as such: an unauthorized-but-green pull request
   merging out of checkpoint order, an item merging before its `merge_status` was durably recorded,
   or a chained second merge escaping validation. The severity framing should be accurate on this
   point rather than inflated.
3. **Conversely, the false-DENY direction has no compensating control at all.** A blocked merge
   halts a run at the point where the work is complete and green, and presents as a governance
   denial with no parse diagnostic. That remains the higher-frequency, higher-cost direction, and
   the existing High severity in `spec.md` line 23 is defensible on that basis.
4. This posture matches #545 D4.2's stated position for the same hook family ("a policy deterrent,
   not a security boundary") and should be restated verbatim in this feature's spec so a downstream
   summary does not claim tamper-resistance.

---

## 9. Recommended approach

### 9.1 Candidate approaches evaluated

**Selected — reuse issue #545's `hook-command-scanner.ps1` for the trigger, and add a token-level
positional operand extractor for the number.**

The trigger fix is exactly the problem #545 already solved and already built a helper for: per-
segment masked evaluation with the fourteen-member wrapper carve-out (D2 Piece 2) closes §4.2, and
the structural `gh` relocation classifier with the modeled global-option table (D2 Piece 3) closes
§4.3. #545's own follow-up acceptance criterion (`spec.md` line 811) names this feature as the
intended consumer, and its Rollout section (line 874) names `enforce-epic-merge-gate.ps1` first in
the follow-up list. Building a second, narrower scanner here would create the drift #545's D1
rejection of "any Python leg" and D7's single-helper decision exist to prevent.

The extraction fix does **not** exist in #545. #545's classifier answers "is this segment a
governed invocation?"; it does not answer "what is this invocation's first positional operand?".
That is new logic this feature must add, but it can consume the scanner's per-segment `Tokens`
rather than re-parsing raw text.

Advantages: one parsing implementation across the hook family; the wrapper deny pins of §4.4 are
preserved by construction; the relocation bypasses of §4.3 close as a side effect; no new registered
file (the helper is #545's, already registered by that change).

Limitations: **hard dependency on #545 merging first**, and the helper's public API is unpinned
(§9.5).

**Rejected alternatives (brief):**

- *Widen the lookbehind at line 154 to exclude `\` as well.* Rejected for the reason the issue
  itself gives (`issue.md` line 83) and confirmed at §2 row 6: `/2026-wt` still mis-parses. It
  suppresses one reproduction and leaves the class intact, and it does nothing for Defect 2.
- *Single anchored regex, e.g. `gh\s+pr\s+merge\s+(?:--?[\w-]+(?:=\S+)?\s+)*(\d+)\b`.* This fixes
  §2 rows 4, 6, 9, 10, 16 without any dependency on #545, and is a legitimate Defect-1-only
  interim. Rejected as the primary recommendation because it cannot express the URL operand (row 7),
  cannot distinguish a flag that takes an argument from one that does not (row 10 needs
  `--body "closes 123"` skipped as flag+argument), does not help Defect 2 at all, and would be
  thrown away when #545 lands. It is retained in §9.5 as the fallback if #545 slips.
- *Hand-roll a private scanner inside the merge gate.* Rejected: the gate is at 452 of 500 lines
  (48 headroom); #545's scanner is budgeted at up to ~450 lines on its own. It does not fit, and a
  second implementation of quote/heredoc tracking is the drift risk #545 D7 was decided to avoid.

### 9.2 Recommended fix shape

**Defect 2 — trigger.** Replace line 377's whole-text conjunction with, per segment produced by the
scanner:

1. select the segment's scan text by #545 D2 Piece 2's three ordered clauses (unbalanced or live
   substitution → `RawText`; wrapper-led → `RawText`; otherwise `MaskedText`);
2. evaluate the two **byte-unchanged** expressions `(?i)\bgh\s+pr\s+merge\b` and `--merge\b` against
   that one segment's scan text — requiring **both matches within the same segment**, which is what
   ends the cross-segment bridge of §4.2's last two rows;
3. additionally, run the structural `gh` classifier over the segment's `Tokens` — skip `VAR=value`
   prefixes, skip transparent wrappers, require leading token `gh`, absorb the modeled `gh` global
   options, then require the subcommand path `pr merge` — and treat a match as arming the gate.
   This closes §4.3 rows 1 and 2.

Whether the short-flag `-m` spelling is also recognized depends on the grammar verification called
for in §2; if `gh` does accept `-m` as `--merge`, the strategy-flag test should be token-based
(`--merge`, `--merge=<bool>`, or `-m`) rather than a raw `--merge\b` regex, and the spec must then
say so explicitly because it breaks #545's byte-unchanged-expressions rule (R2) for this hook.

**Defect 1 — extraction.** Rewrite `Get-EpicMergeGateCommandPrNumber` to operate on the tokens of
the **same segment that armed the gate**:

1. locate the `gh … pr merge` token run (after global-option absorption);
2. walk the remaining tokens; for each token beginning with `-`, skip it and, when it is a modeled
   argument-taking option (`-b/--body`, `-F/--body-file`, `-t/--subject`, `-A/--author-email`,
   `--match-head-commit`) and is not in `--opt=value` form, skip its argument too;
3. the first remaining non-option token is the operand;
4. return `[int]` when the operand matches `\A\d+\z`; return the captured group when it matches a
   pull-request URL of the shape `.*/pull/(\d+)(?:[/?#].*)?\z`; return `$null` otherwise (branch
   operand or absent operand).

Invariants this preserves, as the issue requires (`issue.md` lines 77–78): the bare
`gh pr merge --merge` form still yields `$null`; the anchored epic form `gh pr merge 410 --merge`
still yields `410` (it is now the operand-first case of the same walk).

**Multi-invocation handling (new, and the fix for §3.3 case 2).** Because a command line can carry
more than one gated segment, the decision function should evaluate **every** armed segment and allow
only if **every** one is authorized; any unauthorized segment denies. The alternative — deny outright
when more than one gated segment is present — is simpler and equally fail-closed; either is
acceptable, but the spec must pick one, because today's behavior (validate the first, execute all)
is a false-allow vector.

### 9.3 Required test matrix

All cases drive the pure seams with mocked checkpoint readers, as the existing suite does (no
temporary files, no child processes). New cases land in a sibling file (§7).

**A — extractor, Defect 1 (drive `Get-EpicMergeGateCommandPrNumber` directly):**

| Case | Expected |
| --- | --- |
| `gh pr merge 410 --merge` | `410` (existing pin, must stay green) |
| `gh pr merge --merge 410` | `410` (existing pin, must stay green) |
| `gh pr merge --merge` | `$null` (existing pin, must stay green) |
| `cd C:\...\2026-08-29T00-11 && gh pr merge --merge 688` | `688` — **fails before the fix** |
| `cd /repos/2026-wt && gh pr merge --merge 688` | `688` — **fails before the fix**; the falsifiability pin against a lookbehind-only patch |
| `cd /repos/wt2026/x && gh pr merge --merge 688` | `688` (passes before and after; the lookbehind-already-excluded contrast case the issue names) |
| `gh pr merge https://github.com/o/r/pull/688 --merge` | `688` |
| `gh pr merge https://gh.example.com/8/o/r/pull/688 --merge` | `688` — **fails before the fix** |
| `gh pr merge --merge --body "closes 123" 688` | `688` — **fails before the fix** |
| `gh pr merge --merge my-branch-591` | `$null` |
| `gh pr merge --merge 2026-fix` | `$null` — **fails before the fix** |
| `gh pr merge 688 --merge=true` | `688` |
| `gh pr merge --merge=1 688` (only if the grammar check confirms the form) | `688` — **fails before the fix** |

**B — trigger over-match, Defect 2 (drive `Invoke-EpicMergeGateDecision` with all three checkpoint
readers mocked to `$null`; expected `allow`, all fail before the fix):**

`printf 'gh pr merge --merge 688\n' >> notes.md`; a `cat <<'EOF' > doc.md` heredoc whose body names
the invocation; `echo "run gh pr merge --merge 688"`;
`git commit -m "document the gh pr merge --merge gate"`; a `gh api … -f body='…'` payload mention;
`gh pr merge --squash 410 && echo "--merge"` (cross-segment bridge over a documented allow).

**C — trigger under-match, Defect 2 (all readers `$null`; expected `deny` with
`EPIC_MERGE_GATE_BLOCKED`, all fail before the fix):**

`gh --repo o/r pr merge --merge 688`; `gh -R o/r pr merge --merge 688`;
`gh --repo=o/r pr merge --merge 688`; and, conditional on the grammar check,
`gh pr merge -m 688`.

**D — wrapper deny pins (all readers `$null`; expected `deny`; these PASS before the fix and are the
fail-open guard):**

`bash -c 'gh pr merge --merge 688'`; `sh -c "gh pr merge --merge 688"`;
`echo 688 | xargs gh pr merge --merge`; `env gh pr merge --merge 688`;
`pwsh -NoProfile -Command "gh pr merge --merge 688"`; a `bash <<EOF` heredoc carrying the
invocation; `echo "$(gh pr merge --merge 688)"`.

**E — false-ALLOW closure (the §3.3 cases; each currently ALLOWS and must DENY after the fix):**

`cd /wt/501 && gh pr merge --merge 777` against a parallel checkpoint with 501 `ci_green` and 777
`pr_open`; `gh pr merge --merge 501 && gh pr merge --merge 777` against the same checkpoint.

**F — deny preservation:** all 56 existing `It` blocks in
`tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` pass unmodified, asserted as an
acceptance criterion.

**G — accept-path characterization (documentation pins, no behavior change):** one `It` asserting
that `Test-ChildCheckpointAllowsEpicMerge` accepts no PR-number parameter, expressed as a decision
test — a qualifying child checkpoint allows `gh pr merge --merge 999` — with a comment naming this
as the recorded §5 property and citing the follow-up candidate.

### 9.4 Delivery, mirror, and registration obligations

For a change **confined to `.claude/hooks/enforce-epic-merge-gate.ps1`**:

1. Mirror the file byte-for-byte to
   `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
   in the same commit. Enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`
   (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:106`). *Known baseline
   caveat:* this pytest fails at baseline for a gitignored-`.claude/state/` reason unrelated to this
   change (#545's plan [P5-T11] records the same condition); record it as a failed-count comparison
   against a captured baseline, not as an absolute zero.
2. **No pack-manifest edit is needed** — the path is already listed
   (`claude-customizations/pack-manifests/core.json:29`) and pinned by
   `claude-pack-manifest-completeness.test.ts:260`.
3. **No PoshQC coverage-list edit is needed for the Claude copy** — it is already registered at
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:44` and in the extensions mirror at
   the same line. Coverage must not regress on the changed file (>= 85% line; there is no PowerShell
   branch gate).
4. **No `.codex/` change is required** *if the fix stays Claude-only*, and Defect 1 genuinely does
   not exist on the Codex side (§1.4). The `.codex/hooks/` file must show **no diff**, mirroring
   #545's own out-of-scope acceptance criterion in the opposite direction.
5. **If the Codex copy is brought in scope for Defect 2** (its line 98 carries the identical
   whole-text conjunction), the obligations grow to: byte-identical `.codex` canonical/bundle pair
   (enforced by `codex-epic-runtime-contracts.Tests.ps1:162`); the 500-line cap check at
   `:172`; a Codex-side Pester suite; **and a new PoshQC coverage registration in both
   `pester.runsettings.psd1` files**, because `.codex/hooks/enforce-epic-merge-gate.ps1` is absent
   from both coverage lists today (§1.5) and the Coverage Exclusion Policy forbids a changed
   production file sitting outside the denominator.
6. `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` covers the file
   automatically via its `.claude/hooks` scan root; the fix must introduce no Python leg.
7. 500-line cap: the gate is at 452 with 48 lines of headroom. The recommended fix removes the
   line-154 branch and adds a token walk. If the operand walk plus the option table exceeds the
   headroom, split into a dot-sourced sibling `enforce-epic-merge-gate-helpers.ps1`, which then
   needs its own Claude bundle mirror, its own `claude-customizations/pack-manifests/core.json`
   entry, and its own entry in **both** `pester.runsettings.psd1` coverage lists.
8. Evidence for all of the above goes to
   `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/<kind>/`
   per the evidence-and-timestamp-conventions skill.

### 9.5 What must be re-derived at execution time because it depends on #545

**Verified in this pass: `hook-command-scanner.ps1` does not exist anywhere in the working tree.**
`Glob '**/hook-command-scanner*'` returned no files. `Grep 'hook-command-scanner'` returned matches
in exactly seven files, all of them documents under
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/` (its
`spec.md`, its research artifact, its `plan.2026-08-25T08-13.md`, and four baseline evidence
artifacts). No source file, no test, no manifest, and no runsettings file references it.

**What #545's committed artifacts DO pin about the helper:**

- The file **name** and its four locations: `.claude/hooks/hook-command-scanner.ps1`,
  `.codex/hooks/hook-command-scanner.ps1`, and both bundle mirrors (`spec.md` D7 at line 446;
  plan tasks [P4-T1], [P4-T2], [P5-T1], [P5-T2] at plan lines 207–208 and 218–219).
- That it is **dot-sourced, entrypoint-free, defines functions only, never reads stdin, contains no
  `$env:CLAUDE_` reference, invokes no Python, and stays at or under 500 lines** (`spec.md` D7
  consequences, lines 459–462; plan [P4-T1]).
- The **data contract**: per-segment `RawText`, `MaskedText`, `Tokens`, `HasLiveSubstitution`,
  `Unbalanced` (`spec.md` D2 Piece 1 table, lines 252–260, and acceptance criterion at line 736).
- The **fourteen-member wrapper carve-out set** by exact membership (`spec.md` lines 292–297) and
  the git/gh global-option tables (lines 316–325), each as a named script-scope constant pinned by
  test (R6, line 347).
- The **three ordered scan-text selection clauses** (lines 281–291) and the **six numbered steps** of
  the structural relocation classifier (lines 311–323).

**What #545's committed artifacts DO NOT pin:** any concrete PowerShell function name. `spec.md`
line 212 states explicitly that "the atomic-planner decides sequencing, batching, and **final
function boundaries** within these constraints." Plan task [P4-T1] (line 207) states only that the
file "exposes the scanner, the scan-text selector, and the structural classifier as advanced
functions" — three capabilities, no names. A `Grep` for approved-verb function-name shapes
(`Get-*Segment`, `Test-*Scan`, `ConvertTo-*Segment`, `Split-*Command`) across #545's research
artifact returned exactly one hit, and it is a reference to the pre-existing #539 helper
`Split-OrchestrationCommandLine`, not a proposed name for the new file.

**Consequence for this feature's plan:** it **cannot name the helper's API**. The plan must be
written against the three capabilities and the five per-segment property names, with an explicit
execution-time task that re-derives the actual exported function names, parameter names, and return
shapes by reading `.claude/hooks/hook-command-scanner.ps1` **after** #545 merges, before any code is
written here. The plan should also re-derive at that point:

1. Whether the helper's wrapper set and gh option table are exported in a form this hook can consume
   directly, or whether the merge gate needs its own dot-source of the same constants.
2. Whether #545's implementation landed a **split** (its D7 at line 464 permits splitting into two
   sibling files past ~450 lines), which would change the dot-source line count and the registration
   set this hook inherits.
3. The **current line count** of `.claude/hooks/enforce-epic-merge-gate.ps1` on the post-#545 tree
   (452 today, but #545's acceptance criterion at `spec.md` line 807 requires this file to carry
   **no diff** in that change, so 452 is expected to hold).
4. Whether #545 changed the two PoshQC runsettings files' line numbering, invalidating the
   "line 44" locator in §1.5.

**Fallback if #545 slips:** deliver the Defect-1 fix alone using the single anchored regex described
in §9.1's rejected-alternatives list, with test matrix A only, and leave Defect 2 for a second pull
request that consumes the helper. This is a real option because Defect 1's fix is independent of the
scanner and is the direction with the confirmed operational cost. The spec should state which of the
two sequencings is authorized rather than leaving it to the executing agent.

---

## 10. Numeric Derivation Evidence

### Claim N1 — "the merge gate has exactly three checkpoint-based accept paths"

- **Complete Family:** every code path in `.claude/hooks/enforce-epic-merge-gate.ps1` by which
  `Invoke-EpicMergeGateDecision` returns an allow decision on the basis of checkpoint state.
- **Exhaustive Search Scope:** the entire file `.claude/hooks/enforce-epic-merge-gate.ps1`
  (452 lines), read in full in this pass; the family is closed because `Invoke-EpicMergeGateDecision`
  (lines 340–399) is the only decision function and its body was read line by line.
- **Inclusion Rules:** a `return Get-EpicMergeGateAllowDecision` statement whose guarding condition
  is a call to a checkpoint predicate.
- **Exclusion Rules:** allow returns guarded by the gate's scope filter (absent command text; the
  command not being an in-scope `gh pr merge --merge` invocation) are excluded, because they are the
  hook's out-of-scope pass-through, not an authorization decision. Block returns are excluded.
- **Primary Search Strategy:** `Grep` over the file for the alternation
  `^function |return Get-EpicMergeGateAllowDecision|return Get-EpicMergeGateBlockDecision`, then
  apply the inclusion/exclusion rules against the surrounding conditions read at lines 362–398.
- **Primary Member Set:** {line 385, guarded by `Test-ChildCheckpointAllowsEpicMerge` (384);
  line 390, guarded by `Test-EpicCheckpointAllowsMerge` (389); line 395, guarded by
  `Test-ParallelCheckpointAllowsMerge` (394)}. The grep returned five allow returns in total
  (372, 378, 385, 390, 395); 372 is guarded by `if (-not $commandText)` (370–371) and 378 by the
  scope filter at 377, so both are excluded by rule.
- **Primary Count:** 3.
- **Cross-check Search Strategy (distinct expression, different family axis):** enumerate the
  `Test-*` predicate functions **defined** in the file — the same `Grep` output's `^function ` leg,
  which lists all twelve function definitions independently of the return statements — and retain
  those declared `[OutputType([bool])]` that take a checkpoint parameter.
- **Cross-check Member Set:** {`Test-ChildCheckpointAllowsEpicMerge` (defined line 160),
  `Test-EpicCheckpointAllowsMerge` (189), `Test-ParallelCheckpointAllowsMerge` (247)}. The other
  nine definitions are three read seams (48, 66, 84), one JSON parser (102), the extractor (127),
  two decision constructors (310, 323), and two orchestration functions (340, 401) — none is a
  checkpoint predicate.
- **Cross-check Count:** 3.
- **Member-set Comparison:** normalizing the primary set by its guarding predicate name yields
  {`Test-ChildCheckpointAllowsEpicMerge`, `Test-EpicCheckpointAllowsMerge`,
  `Test-ParallelCheckpointAllowsMerge`}, which is identical to the cross-check set. Counts agree
  at 3. The assertion is supported.

### Claim N2 — "there are exactly four tracked copies of `enforce-epic-merge-gate.ps1`"

- **Complete Family:** every tracked file in the working tree whose basename is
  `enforce-epic-merge-gate.ps1`.
- **Exhaustive Search Scope:** the entire repository working tree at
  `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a34e845411e5cc44b`, searched from the
  root with no path restriction.
- **Inclusion Rules:** basename equals `enforce-epic-merge-gate.ps1`.
- **Exclusion Rules:** the Pester suite `enforce-epic-merge-gate.Tests.ps1` is excluded — its
  basename differs and it is a test, not a copy of the hook.
- **Primary Search Strategy (filename axis):** `Glob '**/enforce-epic-merge-gate*'`.
- **Primary Member Set:** {`.claude/hooks/enforce-epic-merge-gate.ps1`,
  `.codex/hooks/enforce-epic-merge-gate.ps1`,
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`,
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`}.
  The glob returned five paths; `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` is
  removed by the exclusion rule.
- **Primary Count:** 4.
- **Cross-check Search Strategy (content axis, distinct expression):** `Grep` for the content
  alternation `gh\s+pr\s+merge|--merge\b|\(\?<!\[-\w\]\)` restricted to
  `glob: '**/enforce-epic-merge-gate.ps1'` — a content search that names no directory and cannot
  see the test file, and that would miss any copy not containing the gated expressions.
- **Cross-check Member Set:** {`.claude\hooks\enforce-epic-merge-gate.ps1` (matched at 146, 154,
  377), `.codex\hooks\enforce-epic-merge-gate.ps1` (33, 98),
  `extensions\...\codex-and-agents-customizations\.codex\hooks\enforce-epic-merge-gate.ps1` (33, 98),
  `extensions\...\claude-customizations\.claude\hooks\enforce-epic-merge-gate.ps1` (146, 154, 377)}.
- **Cross-check Count:** 4.
- **Member-set Comparison:** normalizing path separators to `/`, the two member sets are identical.
  Counts agree at 4. The assertion is supported. The comparison additionally establishes the §1.4
  finding that the two Codex copies share the Claude copies' trigger site but not its line-154
  extraction branch.

### Withheld numeric claims

No count is asserted for "the number of `It` blocks a fix must add", "the number of over-matching
command shapes", or "the number of registration obligations", because each of those families is
open-ended (a design choice, not an enumerable property of the tree) and no exhaustive scope can be
declared for them. The `It`/`Context` totals in §7 (56 and 16) are measurements of the existing file
by two consistent `Grep` line counts and are reported as measurements, not proposed as acceptance
criteria.

---

## 11. Recommendations for spec

### 11.1 Fix shape per defect

- **Defect 1:** replace the whole-text digit scan at lines 154–156 with a token-level walk of the
  `gh pr merge` invocation's operand list within the armed segment (§9.2). Return `[int]` for a bare
  numeric operand and for the `(\d+)` of a `/pull/<n>` URL operand; return `$null` for a branch
  operand and for an absent operand. Preserve `gh pr merge 410 --merge` → `410`,
  `gh pr merge --merge 410` → `410`, and `gh pr merge --merge` → `$null`.
- **Defect 2:** replace the whole-text conjunction at line 377 with per-segment masked evaluation
  plus the structural `gh` relocation classifier, both supplied by #545's
  `hook-command-scanner.ps1`. Require both trigger expressions to match **within one segment**.
- **New, from §3.3:** evaluate every armed segment and deny unless all are authorized (or deny
  outright when more than one armed segment is present). Pick one and state it.
- **Explicit non-goal to record:** the §5 property — `Test-ChildCheckpointAllowsEpicMerge` takes no
  PR number, so a qualifying child checkpoint authorizes any pull request. Do not change it in this
  feature; file it as a separate candidate, noting it needs a checkpoint-schema field to compare
  against.
- **Severity amendment:** `spec.md` lines 21–27 currently justify High severity on the fail-closed
  direction only. Amend to record that the same mechanism admits a false ALLOW (§3.3), and pair that
  with the §8 posture statement so the claim stays proportionate.

### 11.2 Test matrix

Sections A through G of §9.3, delivered in a new sibling suite (the existing suite has 45 lines of
headroom and cannot hold them). Both regression directions must be recorded fail-before under
`…-591/evidence/regression-testing/`:

- Defect 1 over-match repro: §9.3 A row 4 (the issue's own `cd`-prefixed command).
- Defect 1 under-match / false-allow repro: §9.3 E row 1.
- Defect 2 over-match repro: §9.3 B row 1 (the `printf` case observed 2026-09-06).
- Defect 2 under-match repro: §9.3 C row 1 (`gh --repo o/r pr merge --merge 688`).

Section D (wrapper deny pins) passes before the fix and is the fail-open guard; section F
(no existing `It` changes its expected decision) is the deny-preservation criterion.

### 11.3 Delivery and mirror obligations

Per §9.4: Claude bundle mirror in the same commit (with the known baseline caveat on the push-down
pytest); no pack-manifest edit; no PoshQC coverage edit for the Claude copy; `.codex/` no-diff if the
fix is Claude-only, or the full five-part obligation set including **two new coverage registrations**
if the Codex copy is brought in scope for Defect 2; no Python; 500-line cap with a named split path.

### 11.4 Must be re-derived at execution time (depends on #545)

`hook-command-scanner.ps1` does not exist in the tree today and **no concrete function name for it is
pinned anywhere in #545's committed spec, plan, or research** (§9.5). This feature's plan must
therefore describe the dependency by capability, not by API, and must carry an explicit
re-derivation task that reads the merged helper before any code is written here — covering exported
function names and signatures, whether the helper split into siblings, the post-merge line count of
the merge gate, and the post-merge line numbers of the two PoshQC runsettings entries. The spec must
also state whether the Defect-1-only fallback (§9.5) is authorized if #545 slips.
