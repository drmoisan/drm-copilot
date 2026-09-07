# epic-merge-gate-parses-pr-number-from-whole-command-line (Spec)

- **Issue:** #591
- **Parent (optional):** epic `cleanup-merged-worktrees-hardening` (child I, wave 1, band C3, `depends_on: [545]`)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug — this spec is the **sole acceptance-criteria source**. `user-story.md` exists in this folder only to satisfy the epic-planner readiness check and carries no acceptance criteria.

Authoritative research:
`docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/research/2026-09-07T00-45-epic-merge-gate-command-text-matching-research.md`.
This spec adopts that artifact's section 9 (recommended fix shape, test matrix, delivery
obligations) and section 11 (recommendations) as the normative basis, except where a decision
recorded in "Proposed Fix" below overrides it. Section references of the form "research section N"
refer to that artifact.

Upstream contract: issue #545,
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`,
sections "Scope & Non-Goals", D1, D2, D7, D9, and D10.

---

## Context

`.claude/hooks/enforce-epic-merge-gate.ps1` classifies and authorizes `gh pr merge` invocations by
running regular expressions against the raw text of `tool_input.command`. It has no notion of where
one command in a command line ends and the next begins, and no notion of which spans of that text
are quoted data rather than executed instructions.

**Two defects, one root cause, one change.** Both defects recorded here are consequences of that
single design property. Neither is an independent coding slip: each is what raw-text matching
produces when it is asked a question that requires structure. They are fixed together because the
same structural read of the command line answers both questions, because fixing one and leaving the
other would ship a hook that is half structural and half textual, and because the shared helper this
feature consumes — `hook-command-scanner.ps1`, delivered by issue #545 — supplies the structure both
need in one dot-source.

- **Defect 1 — whole-line pull-request-number extraction.** `Get-EpicMergeGateCommandPrNumber`
  (defined at line 127 on the pre-fix tree) has two branches. The anchored branch at line 146 binds
  its capture group inside the `gh pr merge` pattern and is correct. The broadened branch at line
  154, added for the parallel command form, evaluates two independent `-match` operations joined by
  `-and`: the first confirms a `gh pr merge` invocation is present somewhere in the text, and the
  second rescans **the entire command text** for a standalone digit run. Because each successful
  `-match` overwrites `$Matches`, the value read at line 155 is the capture group of the second,
  free-floating expression. Any digit run earlier in the line — most often inside a `cd` path prefix
  — is taken as the pull-request number. This is the defect issue #591's title and body record.

- **Defect 2 — the trigger over-matches quoted text.** The top-level guard in
  `Invoke-EpicMergeGateDecision` (line 377) arms the gate when `(?i)\bgh\s+pr\s+merge\b` matches
  anywhere in the raw command text **and** `--merge\b` matches anywhere in the raw command text.
  The two matches need not be in the same command, the same pipeline segment, or outside quotes. A
  `printf`, an `echo`, a commit message, or a heredoc whose literal text merely mentions the gated
  subcommand therefore arms the gate and is denied. This is gap 8 of the epic's 2026-09-06
  `/cleanup-merged-worktrees` run, recorded in the epic manifest at
  `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md` and named in its leading
  indicators as "a gated command word quoted inside `printf` text no longer produces a hook denial".

### The scope of this feature is deliberately wider than the issue title

Issue #591's title and body name only Defect 1. This feature also closes Defect 2. The reasons are
recorded here so the widening is a decision on the record rather than scope creep discovered at
review:

1. The epic `cleanup-merged-worktrees-hardening` assigns gap 8 to two children under a corrected
   decomposition recorded on the integration branch at commit `12970ba2`. The manifest's section
   "Gap 8 is two children, not one — a corrected decomposition" states: "Child I (#591) is the
   merge-gate half of #545's own follow-up AC. It consumes the helper and fixes both defects in
   `Get-EpicMergeGateCommandPrNumber`: the trigger over-match that gap 8 observed, and the
   whole-line PR-number extraction that #591 records." Child D (#903) is the removal-gate half.
2. Issue #545's committed acceptance criterion reads: "A single follow-up candidate is filed
   covering the out-of-scope family members and `gh`/`git` global-option relocation in the merge and
   removal gates." This feature is the merge-gate half of that follow-up.
3. Both defects live in the same 452-line file and both are consequences of the same property. A
   change that fixed one would have to be re-opened to fix the other.

`issue.md` is amended in the same change to record the widened scope and the corrected severity
rationale. The exact amendment text is supplied verbatim below under "Amendment to `issue.md`".

### Relationship to issue #545

Issue #545 introduces the shared, dot-sourced, entrypoint-free PowerShell helper
`hook-command-scanner.ps1` (its D7) and applies it to three hooks: the orchestration
preimplementation gate, `enforce-promotion-mcp-only.ps1`, and
`enforce-pr-author-skill-helpers.ps1`. Its "Scope & Non-Goals" section lists
`enforce-epic-merge-gate.ps1` under "Out of scope / non-goals", and it carries an acceptance
criterion requiring this file to carry **no diff** in that change.

This feature therefore **consumes** #545's helper as a contract and specifies no scanner of its own.
Building a second quote-, heredoc-, and segment-aware scanner inside this hook would create exactly
the drift that #545's D7 single-helper decision exists to prevent, and research section 9.1 records
that the merge gate has 48 lines of headroom against the 500-line cap while #545 budgets its scanner
at up to roughly 450 lines on its own — a private copy does not fit.

The dependency is a contract edge, not a file-collision edge: #545's own acceptance criteria require
this file to carry no diff in that change, so there is no overlapping edit to serialize.

### What this gate is, and what it is not

`main` in this repository is protected by repository ruleset id `15241672`, enforcing eleven
required status checks with `strict_required_status_checks_policy: true`. That fact was verified
against the GitHub API by a sibling child of this epic and is taken as given here; it was not
re-queried during this feature's research.

Consequently **this hook is a procedure deterrent, not the control that keeps failing work out of
`main`.** The server-side ruleset applies to every actor, so a red pull request cannot merge
irrespective of what this hook decides. The hook's job is to enforce the *orchestration procedure* —
that a merge is attempted only from a checkpoint state that records the run's own CI gate as green
and pins the intended target — not to be a last line of defence against merging broken code. This
matches the posture #545's D4.2 records for the same hook family ("a policy deterrent, not a
security boundary"). No claim of tamper-resistance is made or implied by this fix, and no summary of
this change may assert that this gate is what keeps failing work out of `main`.

---

## Repro & Evidence

### Defect 1 — extraction

Steps to reproduce (from `issue.md`, and confirmed by research section 2 row 4):

1. Use a worktree whose absolute path contains a standalone digit run, for example a path ending
   `TaskMaster-wt\2026-08-29T00-11`.
2. Issue a merge command prefixed with a `cd` into that path:
   `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688`.
3. The gate parses the pull-request number as `2026` rather than `688`.
4. The gate denies the command with `EPIC_MERGE_GATE_BLOCKED`, because `2026` does not match the
   checkpoint's pinned `pr_number`.

Reported verbatim by the parallel-orchestrator for run `bugs-635-440` in `drmoisan/TaskMaster`: "The
merge gate has a real defect. It parses the PR number by scanning the entire command text for the
first standalone digit run, so my `cd .../2026-08-29T00-11 && gh pr merge --merge 688` was read as
PR `2026` and denied. The checkpoint was correct throughout. Bare commands work."

The defective expression as it stands at line 154:

```powershell
if ($CommandText -match '(?i)\bgh\s+pr\s+merge\b' -and $CommandText -match '(?<![-\w])(\d+)\b') {
```

For contrast, the correct anchored form at line 146:

```powershell
if ($CommandText -match '(?i)\bgh\s+pr\s+merge\s+(\d+)\b') {
```

**The defect is NOT deny-only.** The `issue.md` severity rationale reasons only about the
fail-closed direction. Research section 3.3 established a false-ALLOW vector from the same
mechanism, and this spec corrects the record:

- **Vector A — a digit run in the `cd` prefix collides with an authorized item.** Given a parallel
  checkpoint carrying items `pr_number 501` with `merge_status ci_green` and `pr_number 777` with
  `merge_status pr_open`, the command `cd /wt/501 && gh pr merge --merge 777` extracts `501`,
  matches the authorized item, and the gate allows. The shell then merges pull request 777, which
  the checkpoint records as not ready. The gate authorized a merge it was written to deny.
- **Vector B — chained invocations.** `gh pr merge --merge 501 && gh pr merge --merge 777` under
  the same checkpoint extracts `501`, is allowed, and executes **both** merges. Only the first is
  validated. This is a structural consequence of extracting one number from a command line that can
  carry several invocations, and it survives any fix that only re-anchors the regular expression.

Under the posture recorded above, these are **procedure violations** — an item merging out of
checkpoint order, or before its `merge_status` was durably recorded — not "merges broken code into
`main`" incidents. The fail-closed direction remains the higher-frequency, higher-cost one and the
existing High severity is defensible on that basis; the record is corrected because the fix must
close both directions.

Additional mis-handled shapes verified in research section 2, each a consequence of the same scan:

| Command shape | Extracted today | Correct |
| --- | --- | --- |
| `cd /repos/2026-wt && gh pr merge --merge 688` | `2026` | `688` |
| `gh pr merge https://gh.example.com/8/o/r/pull/688 --merge` | `8` | `688` |
| `gh pr merge --merge --body "closes 123" 688` | `123` | `688` |
| `gh pr merge --merge 2026-fix` (branch operand) | `2026` | `$null` |

The second row of that table is the reason the lookbehind must not simply be widened to exclude the
backslash: `/2026-wt` still mis-parses, so widening suppresses one reproduction and leaves the class
intact. `issue.md` already records this constraint.

### Defect 2 — trigger

Steps to reproduce:

1. With any checkpoint state, issue a Bash command whose text merely quotes the gated invocation,
   for example a `printf` that appends a note naming `gh pr merge --merge` to a Markdown file.
2. The gate arms, because both trigger expressions match somewhere in the raw command text.
3. The command is denied with `EPIC_MERGE_GATE_BLOCKED` even though nothing on the line executes a
   merge.

Instance observed 2026-09-06 during the epic's `/cleanup-merged-worktrees` run: a `printf` writing a
memory note was denied. Further shapes verified in research section 4.2: a heredoc body naming the
invocation; `echo` with the invocation inside double quotes; a `git commit -m` message documenting
the gate; a `gh api` form or JSON payload value; two separate read-only `grep` commands joined by
`&&` where the conjunction bridges them.

The sharpest instance is `gh pr merge --squash 410 && echo "--merge"`. The existing suite pins at
`tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` line 27
(`It 'allows gh pr merge without --merge (e.g., --squash)'`) that a squash merge is out of scope. A
`--merge` token anywhere else on the line defeats that documented allow.

The hook is registered only on the `Bash` matcher (`.claude/settings.json` line 111, inside the
matcher group opened at line 91), so `Write` and `Edit` are unaffected. That is the practical
workaround in use today and is not a fix.

Defect 2 also has an under-match direction, verified in research section 4.3. Because
`\bgh\s+pr\s+merge\b` requires `pr` to be adjacent to `gh`, the global-option relocations
`gh --repo o/r pr merge --merge 688` and `gh -R o/r pr merge --merge 688` never arm the gate at all
and pass ungated. These are the `gh` relocation bypasses named in #545's follow-up acceptance
criterion.

---

## Root Cause Analysis

The root cause is one property: **classification and extraction are performed by matching regular
expressions against raw command text, with no model of segment boundaries, quoting, or command
structure.** Three consequences follow directly.

1. **Over-match on the trigger.** `\b` is a word boundary, so a preceding `'`, `"`, `(`, backtick,
   `>`, or `=` all satisfy it. This anchor is strictly **weaker** than the `(^|\s)` anchor used by
   the preimplementation gate that #545 analyzed. Command text that #545 measured as *already
   ungated* in that hook is therefore **gated here**. Two independent whole-text matches joined by
   `-and` additionally bridge segment boundaries, so two unrelated commands on one line can arm the
   gate between them.
2. **Under-match on the trigger.** Adjacency between `gh` and `pr merge` is required, and `gh`
   accepts global options in between.
3. **Positional blindness on extraction.** A whole-text digit scan has no way to distinguish a path
   component, a flag argument, a URL host segment, or a branch name from the invocation's operand.

The comment at lines 149 to 153 of the hook records the intent behind the broadened branch — capture
the first standalone digit run not preceded by `-` or a word character, so a flag token is not read
as a number and a bare `gh pr merge --merge` still yields `$null`. That reasoning is sound **for the
argument region of one invocation** and is applied to the whole command line, which is what the
expression actually scans. In the reported reproduction `2026` is preceded by a backslash, which is
neither `-` nor a word character, so the lookbehind is satisfied and `2026` matches first.

The remedy for all three consequences is the same: read the command line structurally, per segment,
with quoting resolved, and evaluate both the trigger and the operand against that structure. That
structure is what #545's `hook-command-scanner.ps1` produces.

---

## Proposed Fix

The decisions below are settled. They are the normative contract; the atomic planner decides
sequencing, batching, and final function boundaries within these constraints.

### D1 — Defect 2, the trigger: per-segment masked evaluation plus structural relocation classification

Replace the whole-text conjunction at line 377 with, for each segment produced by the scanner:

1. **Select the segment's scan text** by #545's D2 Piece 2 three ordered clauses, first match
   winning: if the segment is `Unbalanced` **or** `HasLiveSubstitution`, use `RawText`; otherwise if
   the segment's leading command word — determined after skipping any `VAR=value` env-assignment
   prefixes — is a member of the wrapper carve-out set, use `RawText`; otherwise use `MaskedText`.
2. **Evaluate the two trigger expressions against that one segment's scan text**, requiring **both
   matches within the same segment**. Requiring both within one segment is what ends the
   cross-segment bridge, including the `--squash` case above. Both expressions stay byte-unchanged,
   per #545's rule R2, subject to D5 below.
3. **Additionally, run the structural `gh` relocation classifier** over the segment's `Tokens`:
   skip leading `VAR=value` prefixes, skip the transparent wrappers, require the leading token `gh`,
   absorb the modeled `gh` global options, then require the subcommand path `pr merge`. A match arms
   the gate. This closes the relocation bypasses of research section 4.3.

Per #545's rule R1, masking never denies; it only removes matches. Per rule R3, any segment whose
execution content cannot be resolved statically scans raw, which is today's behavior.

### D2 — Defect 1, the extraction: a token walk of the armed segment

Rewrite `Get-EpicMergeGateCommandPrNumber` to operate on the tokens of the **same segment that armed
the gate**, adopting research section 9.2:

1. Locate the `gh` … `pr merge` token run, after global-option absorption.
2. Walk the remaining tokens. For each token beginning with `-`, skip it; when it is a modeled
   argument-taking option and is not written in the attached `--option=value` form, skip its
   argument as well. The argument-taking option table to model is `-b` / `--body`, `-F` /
   `--body-file`, `-t` / `--subject`, `-A` / `--author-email`, and `--match-head-commit`, subject to
   the verification required by D5.
3. The first remaining non-option token is the operand.
4. Return an integer when the operand matches `\A\d+\z`; return the captured group when the operand
   matches a pull-request URL of the shape `.*/pull/(\d+)(?:[/?#].*)?\z`; return `$null` otherwise —
   a branch operand or an absent operand.

The option table, like #545's wrapper set and `gh` global-option table, is a named script-scope
constant pinned by test.

This preserves the two invariants `issue.md` requires: a bare `gh pr merge --merge` with no operand
still yields `$null`, because the fail-closed downstream logic depends on it; and the anchored epic
form `gh pr merge 410 --merge` still yields `410`, now as the operand-first case of the same walk
rather than as a separate branch.

### D3 — Multi-invocation handling: every armed segment must be authorized (settled)

A command line can carry more than one gated segment. **The decision function evaluates every armed
segment and returns allow only when every armed segment is authorized; any unauthorized armed
segment denies.**

The alternative research section 9.2 offered — deny outright whenever more than one gated segment is
present — is rejected. Both rules are fail-closed and both close vector B, but the chosen rule
preserves legitimate composition. An orchestrator that issues two authorized merges on one line, or
that pairs a merge with an unrelated command in a segment that also happens to arm the gate, is
performing an authorized action; denying it would reintroduce a fail-closed friction of exactly the
kind Defect 1 produced, in a change whose primary purpose is to remove that friction. The blanket
rule also degrades explanation quality: the operator would be told the command was denied for having
two segments rather than for the specific segment that is not authorized. The per-segment rule is no
weaker, because a line containing any unauthorized armed segment still denies.

This decision is settled and is not to be reopened at planning, execution, or review.

### D4 — Sequencing: the primary path is authorized; the fallback is not at executor discretion (settled)

**The primary path is authorized:** both defects fixed in one change, consuming #545's
`hook-command-scanner.ps1` after issue #545 merges. This feature is wave 1 of the epic precisely so
that the helper exists when this work starts.

Research section 9.5 records a fallback: deliver the Defect-1 fix alone using a single anchored
regular expression, with test matrix section A only, deferring Defect 2 to a second pull request.
**That fallback is authorized only on an explicit epic-orchestrator decision recorded in the
orchestrator checkpoint.** It is not available at executor discretion, and an executor who finds the
helper absent must halt and escalate rather than select it. The reason is that the fallback ships
work that is thrown away when #545 lands, splits one root cause across two pull requests, and leaves
the wrapper carve-out and relocation closure unaddressed; that trade is an orchestration-level call
about schedule, not an implementation call.

This decision is settled and is not to be reopened at planning, execution, or review.

### D5 — The `gh` grammar must be verified before the recognition sets are pinned (settled)

`issue.md` describes the number as "the argument following `--merge`". Research section 2 flags that
this conflicts with `gh`'s actual grammar, in which `--merge` is a boolean strategy flag and the
pull request is a positional operand with the documented alternation of a number, a URL, or a
branch. **This grammar claim is unverified.** No shell was available during research, so
`gh pr merge --help` was not run.

The executor **must** verify the grammar against `gh pr merge --help` and record the captured output
as evidence under
`docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/other/`
**before** pinning either the strategy-flag recognition set or the argument-taking-option table of
D2. Test cases that depend on the grammar — an attached `--merge=1` form, a branch operand, and a
branch operand beginning with digits — are authored against the verified output, not against the
issue's wording.

**If `gh` accepts a `-m` short form for `--merge`, a token-based strategy-flag check is
authorized** — recognizing `--merge`, the attached `--merge=` form, and `-m` from the segment's
tokens — **even though it departs from #545's rule R2 requirement that trigger expressions stay
byte-unchanged.** This hook is not one of the three #545 modifies, so R2 binds it only by analogy,
and a strategy-flag test that cannot see the documented short spelling is a bypass. If the departure
is taken it must be recorded explicitly in the change: the pull-request description and the
scope-and-size evidence artifact must both state that the `--merge\b` expression was replaced by a
token-based check and why.

This decision is settled and is not to be reopened at planning, execution, or review.

### D6 — The `.codex` copy is OUT of scope (settled)

`.codex/hooks/enforce-epic-merge-gate.ps1` and its bundle mirror
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
**carry no diff in this change.**

Research section 1.4 verified by reading the whole file that the Codex copy is a separate 140-line
implementation, not a mirror of the Claude copy: it defines its own five functions, it models no
parallel route, its child predicate accepts `step9_status` of `passed` or `verified` where the
Claude predicate accepts only `passed`, and — decisively — **it does not carry Defect 1**. Its
`Get-CodexMergeCommandPrNumber` carries only the anchored form and returns `$null` otherwise; the
broadened whole-text scan was never added there. It **does** carry Defect 2 identically, at its line
98.

Reasons for excluding it:

1. This feature's assigned file scope in the epic manifest is the Claude copy. The manifest states
   the gap-8 split was drawn so that "every hook file has exactly one owner".
2. #545 set the precedent directly applicable here: it declined five out-of-scope family members,
   pinned them with a no-diff acceptance criterion, and filed a single follow-up candidate. That
   discipline is what produced this feature. Applying a different standard to the file this feature
   itself finds out of scope would make the precedent situational.
3. Bringing it in scope would require two new PoshQC coverage registrations. Research section 1.5
   verified that `.codex/hooks/enforce-epic-merge-gate.ps1` appears in **neither**
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` nor its extensions mirror, and the
   Coverage Exclusion Policy forbids a changed production file sitting outside the denominator. Both
   files are edited by child E in the same epic wave sequence, so this feature would be adding
   entries to files another child is concurrently editing.
4. The Codex-side obligation set is larger than the Claude side: byte-identical canonical and bundle
   copies enforced by `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, the
   500-line cap check in the same suite, and a Codex-side Pester suite that does not exist today.

**Counter-argument, recorded rather than omitted.** #545's D6 and D10 both rest on the reasoning
that "closing three of four relocation bypasses while leaving the fourth open — in the very change
that builds the classifier that closes it — would be arbitrary". That reasoning would, read
literally, put the Codex copy in scope here. It does not control, for three reasons. First, #545's
argument was about four call sites of one classifier **inside one change's own file set**, whereas
the Codex copy is a different implementation on a different runtime with a different owner under the
epic manifest. Second, #545's own resolution of the same tension for files outside its set was to
decline and file a follow-up, which is the action taken here. Third, the marginal cost is not "apply
an existing constant table to a third call site": it is a new suite, two coverage registrations in
concurrently-edited files, and a byte-identity pair contract. The asymmetry the counter-argument
objects to is real and is closed by the follow-up candidate this spec requires, not by leaving it
unrecorded.

A follow-up candidate covering the Codex copy's Defect 2 is a delivery obligation of this change.

### D7 — Accept path 1 authorizes any pull request: CONFIRMED, and DEFERRED (settled)

Research section 6 confirmed the property against the source: `Test-ChildCheckpointAllowsEpicMerge`
declares exactly one parameter, `$Checkpoint`; its body references no command text and no
pull-request number; its call site inside `Invoke-EpicMergeGateDecision` passes no PR number even
though one has already been computed; and it is consulted **first**, before both number-aware
branches. A child checkpoint with `epic_mode: true` and `step9_status: "passed"` therefore authorizes
merging any pull request. No existing test pins otherwise.

**This feature does not fix it.** The disposition chosen is deferral, and the reasoning is:

- Correcting extraction does not touch a path that never consults the extracted value. Unlike the
  false-ALLOW vectors of Defect 1, this one is not made unavoidable, or even easier to reach, by
  this change.
- Widening the child predicate to take a pull-request number is a behavior change with a schema
  dependency: the child checkpoint would need a pinned `pr_number` field to compare against, which
  does not exist today. That is a checkpoint-contract change, not a hook fix, and it would be
  decided by the orchestration surface rather than by this bug.
- Bundling it here would make the change's blast radius span the checkpoint schema, which is
  precisely the kind of widening the epic manifest's per-child ownership rule exists to prevent.

The property is recorded as an explicit observation, is pinned by a characterization test so a
future reader cannot mistake it for an accident, and a follow-up candidate is filed. Filing that
candidate is a delivery obligation of this change. The same property holds in the Codex copy's
`Test-CodexChildMergeReady`, which additionally accepts `step9_status: "verified"`; the follow-up
candidate should say so.

### Boundaries and invariants to preserve

- **The three checkpoint accept paths behave identically apart from the corrected extraction and the
  corrected trigger.** The three are guarded by `Test-ChildCheckpointAllowsEpicMerge`,
  `Test-EpicCheckpointAllowsMerge`, and `Test-ParallelCheckpointAllowsMerge`. That this is the
  complete set of checkpoint-based accept paths is established by the two independent derivations in
  research section 10, claim N1.
- A bare `gh pr merge --merge` with no operand still yields `$null` from the extractor.
- The anchored epic form `gh pr merge 410 --merge` still yields `410`.
- On the epic path, a `$null` extracted number remains permissive; on the parallel path it remains
  fail-closed. Neither disposition changes in this feature.
- The wrapper deny pins keep denying. Because this gate's trigger anchor is `\b` rather than
  `(^|\s)`, quote-abutted wrapper forms that #545 measured as *already ungated* in the
  preimplementation gate **do arm this gate today**. A masking fix without the wrapper carve-out is
  therefore fail-open here in a way it was not there. This is the single most important
  non-regression constraint in the change.
- Block-reason texts, reason codes, decision-JSON schemas, and the `.claude/settings.json`
  registration are unchanged.
- No production file leaves the coverage denominator.

### Dependencies and blocked work

- **Hard dependency on issue #545 merging first.** The helper does not exist in the tree today; see
  "Execution-Time Re-derivation Requirements".
- Change budget: `.claude/rules/powershell.md` caps direct mode at 2 production PowerShell files.
  The primary path touches the hook and its bundle mirror, plus a possible dot-sourced sibling and
  its mirror. Route through `powershell-orchestrator` or use explicit approved batching, settled at
  planning time.
- No Python leg anywhere in the change; standing repository policy for enforcement hooks.

---

## Scope & Non-Goals

### In scope

- `.claude/hooks/enforce-epic-merge-gate.ps1` — the trigger fix (D1), the extraction fix (D2), and
  the multi-invocation rule (D3).
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
  — the byte-identical mirror of the above.
- Optionally, if and only if the 500-line cap requires it: a dot-sourced sibling
  `.claude/hooks/enforce-epic-merge-gate-helpers.ps1`, its bundle mirror, its
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` entry, and its
  entries in both PoshQC coverage lists.
- A new sibling Pester suite,
  `tests/scripts/claude-hooks/enforce-epic-merge-gate.CommandScanning.Tests.ps1`.
- This feature folder's documents and evidence artifacts, including the `issue.md` amendment.

### Out of scope, with the reason recorded

- **`.codex/hooks/enforce-epic-merge-gate.ps1` and its bundle mirror** — D6. Both carry no diff. A
  follow-up candidate is filed for the Codex copy's Defect 2.
- **`Test-ChildCheckpointAllowsEpicMerge` taking a pull-request number** — D7. A follow-up candidate
  is filed.
- **`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and
  `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`** — owned by child D (#903) of the same
  epic, which is the removal-gate half of #545's follow-up.
- **`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and its helpers,
  `.claude/hooks/enforce-promotion-mcp-only.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`,
  and `.claude/hooks/hook-command-scanner.ps1` itself** — all four owned by issue #545. This feature
  consumes the helper; it does not modify it. A defect found in the helper is escalated, not patched
  here.
- **`scripts/bash/cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`,
  `cleanup_worktrees_enumerate_lib.sh`, and `cleanup-worktrees.sh`** — owned by children A, B, C,
  and F of the same epic.
- **`.claude/hooks/enforce-parallel-abandon-gate.ps1` and `.claude/hooks/validate-bash.ps1`** —
  remaining members of #545's out-of-scope family, not assigned to this child.
- **Changes to the block-reason texts, reason codes, decision-JSON schema, or hook registration.**
- **Any change to the checkpoint schema**, including adding a `pr_number` field to the child
  checkpoint shape (D7).

### Constrained, not prohibited

`.claude/skills/cleanup-merged-worktrees/SKILL.md` is edited by children B, C, D, and G of this
epic. This feature avoids it. If a change there proves genuinely required — the only foreseeable
case is the gate-contract restatement paragraph — it is confined to a single narrow hunk in the
section that documents the merge gate's command contract, and the section is named in the pull
request description. `.claude/skills/parallel-orchestrate/SKILL.md` and
`.claude/rules/parallel-orchestration.md` also restate the gate contract for operators and are
subject to the same constraint. No file under `.github/instructions/` is modified.

---

## Observations & Deferred Findings

1. **Accept path 1 authorizes any pull request.** Confirmed against the source (research section 6);
   deferred by D7; pinned by a characterization test; follow-up candidate required. Recommendation
   for the candidate: it needs a checkpoint-schema field to compare against, so it is a
   checkpoint-contract change rather than a hook fix, and it should cover the Codex copy's
   `Test-CodexChildMergeReady` in the same candidate.
2. **The `.codex` copy carries Defect 2 but not Defect 1.** Verified in research section 1.4;
   excluded by D6; follow-up candidate required. Recommendation for the candidate: it also needs the
   two missing PoshQC coverage registrations, which is why it is larger than a one-line trigger edit.
3. **The `gh` grammar is unverified.** D5 makes verification a precondition of pinning the
   recognition sets. Until then, this spec asserts nothing about whether `-m` is accepted, whether
   `--merge=1` parses, or whether a branch operand is legal in the positions the tests exercise.
4. **Obfuscated respellings of `gh` remain ungated**, exactly as today and exactly as #545's D4.2
   records for its own family. This model widens nothing there and closes nothing there.
5. **Over-match persists inside wrapper-led segments**, inherited from #545's D4.1: a wrapper
   segment scans raw, so a quoted mention inside `bash -c` still arms the gate. This is rare and
   deny-biased, and narrowing it would require recursively scanning the nested command line, which
   reintroduces the fail-open surface the wrapper carve-out exists to avoid.
6. **The epic manifest's `feature_folder` value for this child is
   `2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line`, while the actual active
   folder basename carries the `-591` suffix.** Recorded so fan-in resolves the folder by the real
   basename.

---

## Amendment to `issue.md`

The following block is appended verbatim to
`docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/issue.md`
by the executor, immediately before the `## Next Step` section. It is authored here so the executor
applies it without re-deriving it. It deliberately contains **no checkbox items**, because under
work mode `full-bug` this `spec.md` is the sole acceptance-criteria source and a checkbox in
`issue.md` would create a competing one.

<!-- BEGIN ISSUE.MD AMENDMENT — APPLY VERBATIM -->

```markdown
## Scope Amendment — 2026-09-07

This record was filed against a single defect. The fix delivered under this issue closes two, and
the scope was widened deliberately. The reasons are recorded here so the widening is visible in the
lifecycle record and not only in the specification.

- **Defect 1, as filed.** `Get-EpicMergeGateCommandPrNumber` rescans the entire command text for a
  standalone digit run, so a digit run in a `cd` path prefix is taken as the pull-request number.
- **Defect 2, added.** The trigger guard in `Invoke-EpicMergeGateDecision` requires a `gh pr merge`
  match and a `--merge` match anywhere in the raw command text, so a `printf`, `echo`, commit
  message, or heredoc whose literal text merely mentions the gated subcommand arms the gate and is
  denied. The same adjacency requirement lets `gh --repo <owner>/<repo> pr merge --merge <n>` pass
  ungated.

Both defects are consequences of one design property: the hook matches regular expressions against
raw command text with no notion of segment or quoting. They are fixed together in one change.

The widening is directed by two records. The epic `cleanup-merged-worktrees-hardening` assigns gap 8
of its 2026-09-06 cleanup run to two children under a corrected decomposition recorded on the
integration branch at commit `12970ba2`; this issue is child I, the merge-gate half, and issue #903
is child D, the removal-gate half. Issue #545's committed acceptance criterion — "A single follow-up
candidate is filed covering the out-of-scope family members and `gh`/`git` global-option relocation
in the merge and removal gates" — names this work as its follow-up.

## Severity Rationale — Correction

The "Impact / Severity" rationale above reasons only about the fail-closed direction. That is
incomplete. The same mechanism admits a **false allow**:

- Given a parallel checkpoint whose items include pull request 501 with `merge_status ci_green` and
  pull request 777 with `merge_status pr_open`, the command
  `cd /wt/501 && gh pr merge --merge 777` extracts `501`, matches the authorized item, and is
  allowed. The shell then merges pull request 777, which the checkpoint records as not ready.
- `gh pr merge --merge 501 && gh pr merge --merge 777` extracts `501`, is allowed, and executes both
  merges. Only the first is validated.

These are procedure violations, not "merges broken code into `main`" incidents: `main` is protected
by a repository ruleset enforcing required status checks with a strict policy, so a red pull request
cannot merge irrespective of this hook's decision. This gate is a procedure deterrent, not the
control that keeps failing work out of `main`.

The High severity is unchanged. The fail-closed direction remains the higher-frequency,
higher-cost one, and it has no compensating control at all.
```

<!-- END ISSUE.MD AMENDMENT — APPLY VERBATIM -->

---

## Test Matrix

All cases drive the pure seams directly with the three checkpoint readers mocked, as the existing
suite does: no temporary files, no child processes, no network, no live executables. New cases land
in `tests/scripts/claude-hooks/enforce-epic-merge-gate.CommandScanning.Tests.ps1`, because the
existing suite has insufficient headroom (see "Delivery & Registration Obligations").

The `It` names below are the required names. Each is free of placeholder characters so it can be
located by an exact-text search.

### Group A — extraction, Defect 1 (drive `Get-EpicMergeGateCommandPrNumber` directly)

| `It` name | Command shape | Expected | Status today |
| --- | --- | --- | --- |
| `returns the operand when it precedes the strategy flag` | `gh pr merge 410 --merge` | `410` | passes |
| `returns the operand when it follows the strategy flag` | `gh pr merge --merge 410` | `410` | passes |
| `returns null for a bare merge invocation with no operand` | `gh pr merge --merge` | `$null` | passes |
| `extracts the operand when a cd prefix path contains a digit run` | the issue's own repro command | `688` | **fails** |
| `extracts the operand when a cd prefix path begins with a digit run` | `cd /repos/2026-wt && gh pr merge --merge 688` | `688` | **fails** |
| `extracts the operand when a cd prefix digit run abuts a word character` | `cd /repos/wt2026/x && gh pr merge --merge 688` | `688` | passes |
| `extracts the operand from a pull request URL` | a `github.com` pull URL operand | `688` | passes |
| `extracts the operand from a pull request URL whose host path contains a digit segment` | a URL with a slash-isolated digit segment before the pull path | `688` | **fails** |
| `skips an argument-taking option and its argument before the operand` | `gh pr merge --merge --body "closes 123" 688` | `688` | **fails** |
| `returns null for a branch operand` | `gh pr merge --merge my-branch-591` | `$null` | passes |
| `returns null for a branch operand beginning with digits` | `gh pr merge --merge 2026-fix` | `$null` | **fails** |
| `returns the operand when the strategy flag uses the attached form` | `gh pr merge 688 --merge=true` | `688` | passes |
| `returns the operand when an attached strategy flag precedes it` | `gh pr merge --merge=1 688` | `688` | **fails** |

The last three rows are conditional on the D5 grammar verification and are authored against the
captured `gh pr merge --help` output.

### Group B — trigger over-match, Defect 2 (drive `Invoke-EpicMergeGateDecision`, all readers mocked to `$null`; expected allow; all fail today)

`allows a printf that writes the gated invocation as text`;
`allows a heredoc body that names the gated invocation`;
`allows an echo whose quoted argument names the gated invocation`;
`allows a commit message that names the gated invocation`;
`allows a gh api payload value that names the gated invocation`;
`allows a squash merge when a later segment mentions the strategy flag`.

### Group C — trigger under-match, Defect 2 (all readers `$null`; expected deny with `EPIC_MERGE_GATE_BLOCKED`; all fail today)

`denies a merge whose repository option precedes the subcommand`;
`denies a merge whose short repository option precedes the subcommand`;
`denies a merge whose attached repository option precedes the subcommand`;
and, conditional on the D5 grammar verification,
`denies a merge that uses the short strategy flag`.

### Group D — wrapper deny pins (all readers `$null`; expected deny; these PASS today and are the fail-open guard)

`denies a merge wrapped in a bash command string`;
`denies a merge wrapped in an sh command string`;
`denies a merge piped into xargs`;
`denies a merge prefixed with env`;
`denies a merge wrapped in a pwsh command string`;
`denies a merge carried in a heredoc fed to bash`;
`denies a merge inside a command substitution in double quotes`.

### Group E — false-allow closure (each currently ALLOWS and must DENY after the fix)

`denies an unauthorized operand when the cd prefix names an authorized item` — the vector A
checkpoint and command from "Repro & Evidence".
`denies when a chained second merge segment is unauthorized` — vector B under the same checkpoint.

### Group F — deny preservation

Every `It` block present in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` at the
merge base with the epic integration branch passes **unmodified**. Research section 7 established
that every existing command fixture is a bare, unwrapped, unquoted, single-segment invocation, so
none of them changes its expected decision under the fix specified here. If a candidate
implementation flips one, that is a signal of over-reach, not a reason to edit the assertion.

### Group G — characterization pins, no behavior change

`records that a qualifying child checkpoint authorizes any operand` — a decision test in which a
child checkpoint with `epic_mode: true` and `step9_status: "passed"` allows a merge naming a
pull-request number the checkpoint does not mention, carrying a comment that names this as the
recorded D7 property and cites the follow-up candidate.

`pins the argument taking option table` and `pins the strategy flag recognition set` — named tests
asserting the membership of the two script-scope constants introduced by D2 and D5.

### Both regression directions, both defects

Fail-before output is captured under
`docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/regression-testing/`
for four named cases, one per direction per defect:

| Defect | Direction | Case |
| --- | --- | --- |
| 1 | over-match, currently denies, must allow | `extracts the operand when a cd prefix path contains a digit run` |
| 1 | under-match, currently allows, must deny | `denies an unauthorized operand when the cd prefix names an authorized item` |
| 2 | over-match, currently denies, must allow | `allows a printf that writes the gated invocation as text` |
| 2 | under-match, currently allows, must deny | `denies a merge whose repository option precedes the subcommand` |

A fix that only closes the false-positive direction leaves the bypass open and does not satisfy this
specification.

---

## Delivery & Registration Obligations

1. **Claude bundle mirror in the same commit.** Every edit to a `.claude/**` file is mirrored
   byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/**`,
   enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
   **Known baseline caveat:** that pytest module fails at baseline for a gitignored `.claude/state/`
   reason unrelated to this change; #545's plan records the same condition. It is therefore judged
   as a **failed-count comparison against a baseline captured before any edit**, not as an absolute
   zero. The baseline is captured under
   `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/baseline/`.
2. **No pack-manifest edit is required for the hook itself.** Research section 1.5 verified the path
   is already listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
   and pinned by `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
   A new dot-sourced sibling would require its own entry.
3. **No PoshQC coverage-list edit is required for the hook itself.** It is already registered in
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and in the extensions mirror. A new
   dot-sourced sibling must be added to **both** lists.
   **Known environment defect:** the MCP PoshQC test runner reads the *installed* extension's
   settings, so a newly added coverage entry can be silently ignored and the file will appear to
   have no coverage obligation. When a new file must enter the coverage denominator, invoke the
   self-hosted PoshQC module directly rather than relying on the MCP runner.
4. **No `.codex` change.** Both Codex copies carry no diff (D6).
5. **No Python anywhere in the change.** Enforced by
   `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, whose scan roots
   include `.claude/hooks`, so this file is automatically in scope.
6. **500-line cap** per `.claude/rules/general-code-change.md`. Re-derived counts on the pre-fix
   tree, by a line count of the pattern `^` cross-checked against a read of the last content line:
   `.claude/hooks/enforce-epic-merge-gate.ps1` is at 452 lines, leaving 48;
   `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` is at 455 lines, leaving 45;
   `.claude/lib/hook-payload/HookPayload.psm1` is at 496 lines and can absorb nothing. New test
   cases go in the sibling suite named in the Test Matrix. If the production fix exceeds the hook's
   headroom, a dot-sourced sibling `.claude/hooks/enforce-epic-merge-gate-helpers.ps1` is
   authorized and carries its own bundle mirror, its own pack-manifest entry, and its own entries in
   both PoshQC coverage lists.
7. **Toolchain** per `.claude/rules/powershell.md`: PoshQC format, then PSScriptAnalyzer, then Pester
   with coverage, restarting from format on any failure or auto-fix until a clean single pass. Line
   coverage of at least 85 percent on every changed or added production PowerShell file. PowerShell
   is exempt from the branch-coverage threshold only because Pester does not measure branch
   coverage; that exemption is not licence to exclude any file from the denominator.
8. **Evidence** is written to
   `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/`
   under the canonical `kind` subdirectories, per
   `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No evidence is written to
   `artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/`.

---

## Execution-Time Re-derivation Requirements

This section is load-bearing. **`hook-command-scanner.ps1` does not exist anywhere in the working
tree today.** Research section 9.5 verified this: a glob for the file name returned nothing, and a
content search for the name returned matches in exactly seven files, every one of them a document
under issue #545's feature folder. No source file, no test, no manifest, and no coverage settings
file references it.

Research section 9.5 further verified that **no concrete PowerShell function name for the helper is
pinned anywhere** in #545's committed spec, plan, or research. #545's spec states that "the
atomic-planner decides sequencing, batching, and final function boundaries within these
constraints", and its plan task for the helper names three capabilities without naming any function.

**This spec therefore describes the dependency by capability, not by API.** The capabilities are:

1. **A per-segment command scanner.** A single left-to-right scan of the raw command text producing
   an ordered list of segments, each recording five properties: `RawText`, `MaskedText`, `Tokens`,
   `HasLiveSubstitution`, and `Unbalanced`. Segment delimiters are recognized only outside quoted
   spans and heredoc bodies, and the subshell, group, and substitution openers and closers are
   themselves delimiters. Heredoc handling is real delimiter tracking.
2. **Scan-text selection by three ordered clauses**, first match winning: `Unbalanced` or
   `HasLiveSubstitution` selects `RawText`; a leading command word in the fourteen-member wrapper
   carve-out set (after skipping `VAR=value` env-assignment prefixes) selects `RawText`; otherwise
   `MaskedText`. The wrapper set is a named script-scope constant pinned by test in #545.
3. **A structural relocation classifier** over a segment's `Tokens`, with the modeled `gh`
   global-option table: skip env-assignment prefixes, skip transparent wrappers, require the leading
   token, absorb modeled global options, then test the subcommand path. An unmodeled dash-leading
   token before the subcommand classifies, which is fail-closed; a non-dash token that is not the
   expected subcommand terminates the scan without classifying.

**The executor must re-derive the following against the post-#545 tree before writing any code**,
recording the results in an evidence artifact under
`docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/other/`:

1. The helper's **actual exported function names, parameter names, and return shapes**, read from
   `.claude/hooks/hook-command-scanner.ps1` as merged. Nothing in this spec may be treated as
   naming them.
2. Whether the five per-segment property names shipped as specified, and whether the segment objects
   are hashtables, `PSCustomObject` instances, or a class.
3. Whether **#545 split the helper into two sibling files**, which its D7 permits past roughly 450
   lines. A split changes the dot-source set and the registration set this hook inherits.
4. Whether the wrapper carve-out set and the `gh` global-option table are exported in a form this
   hook can consume directly, or whether this hook must dot-source the constants separately.
5. The **current line count** of `.claude/hooks/enforce-epic-merge-gate.ps1` on the post-#545 tree.
   It is expected to remain 452, because #545's acceptance criteria require this file to carry no
   diff in that change, but the headroom decision of obligation 6 above depends on the real number.
6. The **PoshQC runsettings line locators**. Research recorded the merge-gate coverage entry at line
   44 of both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its extensions
   mirror; #545 adds entries to both files and may have shifted that numbering.
7. The `gh pr merge --help` output required by D5, captured before the recognition sets are pinned.

If the helper's merged API cannot supply a capability this spec depends on, the executor halts and
escalates to the epic orchestrator. It does not build a private substitute (D4, D6).

---

## Assumptions, Constraints, Dependencies

- **Assumptions.** Issue #545 has merged and its helper is present on the branch point. `gh` is
  available on the execution host for the D5 `--help` capture; if it is not, that capture is an
  explicit blocker rather than an omission. `HookPayload.psm1` remains available and unchanged.
- **Constraints.** PowerShell 7 compatible, advanced functions with `CmdletBinding()`, approved
  verbs, `[OutputType()]` on predicates, no `Invoke-Expression`, no mutable script-scoped state
  beyond the named read-only constant tables. 500-line cap on every production, test, and reusable
  script file. Tests are deterministic with no temporary files, no network, and no child processes.
  No file under `.github/instructions/` or `.claude/rules/` is modified.
- **External dependencies.** None beyond issue #545. Verification is entirely local apart from the
  `gh pr merge --help` capture, which reads local help text and performs no network operation
  against a repository.

---

## Acceptance Criteria

- [ ] The trigger decision in `.claude/hooks/enforce-epic-merge-gate.ps1` evaluates per segment
      using the scanner capability described in "Execution-Time Re-derivation Requirements", with
      scan text selected by the three ordered clauses, and requires **both** trigger expressions to
      match within the **same** segment; the whole-text conjunction that stood at line 154 and the
      whole-text trigger conjunction that stood at line 377 are both gone from the file.
- [ ] `Get-EpicMergeGateCommandPrNumber` determines the operand by walking the tokens of the armed
      segment — skipping option tokens and, for modeled argument-taking options not written in the
      attached form, their arguments — and returns an integer for a numeric operand, the captured
      number for a pull-request URL operand, and `$null` for a branch operand or an absent operand.
- [ ] The decision function evaluates every armed segment and returns allow only when every armed
      segment is authorized; a named case in
      `tests/scripts/claude-hooks/enforce-epic-merge-gate.CommandScanning.Tests.ps1` titled
      `denies when a chained second merge segment is unauthorized` passes.
- [ ] The invariant cases pass: `returns the operand when it precedes the strategy flag`,
      `returns the operand when it follows the strategy flag`, and
      `returns null for a bare merge invocation with no operand`.
- [ ] Every Group A `It` name listed in the Test Matrix exists in
      `tests/scripts/claude-hooks/enforce-epic-merge-gate.CommandScanning.Tests.ps1` and passes,
      with the three grammar-conditional rows authored against the captured `gh pr merge --help`
      output.
- [ ] Every Group B `It` name listed in the Test Matrix exists in the same suite and passes,
      asserting an allow decision with all three checkpoint readers mocked to return nothing.
- [ ] Every Group C `It` name listed in the Test Matrix exists in the same suite and passes,
      asserting a deny decision carrying `EPIC_MERGE_GATE_BLOCKED`.
- [ ] Every Group D wrapper deny pin listed in the Test Matrix exists in the same suite and passes,
      and each is confirmed to pass **before** the fix as well, with the before-state result
      recorded under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/regression-testing/`.
- [ ] Both Group E false-allow closure cases exist and pass:
      `denies an unauthorized operand when the cd prefix names an authorized item` and
      `denies when a chained second merge segment is unauthorized`.
- [ ] Fail-before output is recorded under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/regression-testing/`
      for all four named regression cases in the "Both regression directions, both defects" table,
      and pass-after output is recorded under the same path for the same four names.
- [ ] Every `It` block present in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` at
      the merge base with `origin/epic/cleanup-merged-worktrees-hardening-integration` passes
      unmodified; `git diff origin/epic/cleanup-merged-worktrees-hardening-integration...HEAD --
      tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` is empty.
- [ ] The accept paths guarded by `Test-ChildCheckpointAllowsEpicMerge`,
      `Test-EpicCheckpointAllowsMerge`, and `Test-ParallelCheckpointAllowsMerge` behave identically
      to their pre-fix behavior apart from the corrected extraction and the corrected trigger, with
      the Group F suite green and no edit to any of the three function bodies other than the
      parameter plumbing the corrected extraction requires.
- [ ] The Group G characterization case
      `records that a qualifying child checkpoint authorizes any operand` exists and passes, and
      carries a comment citing the deferred finding and the follow-up candidate.
- [ ] The Group G constant pins `pins the argument taking option table` and
      `pins the strategy flag recognition set` exist and pass against named script-scope constants.
- [ ] The `gh pr merge --help` output is captured and recorded under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/other/`,
      and the evidence artifact states whether a short strategy-flag spelling is accepted and
      whether the recorded argument-taking-option table was confirmed or amended.
- [ ] If a token-based strategy-flag check replaces the byte-unchanged expression under D5, the
      departure is recorded in both the pull-request description and the scope-and-size evidence
      artifact, naming the expression replaced and the reason.
- [ ] The verbatim amendment block from the "Amendment to `issue.md`" section of this spec is
      appended to `issue.md` immediately before its `## Next Step` section, unaltered, and
      introduces no markdown checkbox item.
- [ ] `git diff origin/epic/cleanup-merged-worktrees-hardening-integration...HEAD --name-only`
      lists no path outside the owned set: `.claude/hooks/enforce-epic-merge-gate.ps1`, an optional
      `.claude/hooks/enforce-epic-merge-gate-helpers.ps1`, their two mirrors under
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`,
      `tests/scripts/claude-hooks/enforce-epic-merge-gate.CommandScanning.Tests.ps1`, the two
      registration files required only if the optional sibling is created, and paths under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/`.
- [ ] `git diff origin/epic/cleanup-merged-worktrees-hardening-integration...HEAD --
      .codex/hooks/enforce-epic-merge-gate.ps1
      extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
      is empty.
- [ ] `git diff origin/epic/cleanup-merged-worktrees-hardening-integration...HEAD --
      .claude/hooks/enforce-epic-worktree-removal-gate.ps1
      .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
      .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
      .claude/hooks/enforce-promotion-mcp-only.ps1
      .claude/hooks/enforce-pr-author-skill-helpers.ps1
      .claude/hooks/hook-command-scanner.ps1
      .claude/hooks/enforce-parallel-abandon-gate.ps1 .claude/hooks/validate-bash.ps1` is empty, and
      the same diff restricted to `scripts/bash/` is empty.
- [ ] A follow-up candidate is filed covering the Codex copy's trigger over-match, naming
      `.codex/hooks/enforce-epic-merge-gate.ps1`, its bundle mirror, and the two missing PoshQC
      coverage registrations it would require; the candidate's path is recorded in this feature's
      pull-request description.
- [ ] A follow-up candidate is filed covering the deferred finding that
      `Test-ChildCheckpointAllowsEpicMerge` takes no pull-request number, noting that it requires a
      pinned pull-request field in the child checkpoint schema and that the Codex copy's
      `Test-CodexChildMergeReady` carries the same property; the candidate's path is recorded in the
      pull-request description.
- [ ] The re-derivation evidence artifact required by "Execution-Time Re-derivation Requirements"
      exists under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/other/`
      and records, at minimum: the helper's exported function names with their parameter names and
      return shapes; whether the helper shipped as one file or two; the post-merge line count of
      `.claude/hooks/enforce-epic-merge-gate.ps1`; and the post-merge line locators of the merge-gate
      entry in both PoshQC runsettings files.
- [ ] The Defect-1-only fallback described in D4 was **not** used, or, if it was, the orchestrator
      checkpoint at `artifacts/orchestration/orchestrator-state.json` records an explicit
      epic-orchestrator decision authorizing it, and the pull-request description cites that record.
- [ ] Every file added or modified by this change is at or under 500 lines, verified by an explicit
      line-count artifact under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/qa-gates/`.
- [ ] `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes, and no
      file added or modified by this change invokes a Python interpreter or adds a production file
      with a `.py` extension.
- [ ] Every changed `.claude/**` file is content-equal to its counterpart under
      `extensions/drm-copilot/resources/claude-customizations/.claude/**` in the same commit, and
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` reports a failed count no
      greater than the baseline failed count captured before any edit under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/baseline/`.
- [ ] If a dot-sourced sibling helper is created, it is registered in
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, in
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and in
      `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and the
      coverage measurement that proves it is inside the denominator was produced by invoking the
      self-hosted PoshQC module directly rather than through the MCP runner.
- [ ] Pester line coverage is at least 85 percent on every changed or added production PowerShell
      file, with the coverage report recorded under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/qa-gates/`.
- [ ] The PoshQC toolchain passes clean in a single pass over all changed and added PowerShell
      files, in the order format, then analyze, then test, restarting from format on any failure or
      auto-fix, with final results recorded under
      `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/evidence/qa-gates/`.
- [ ] The pull-request description and any completion summary describe this gate as a procedure
      deterrent that enforces orchestration procedure, and assert nowhere that it is what prevents
      failing work from merging into `main`.

---

## Risks & Mitigations

- **Fail-open regression on a wrapper form.** This gate's `\b` anchor is weaker than the anchor
  #545 studied, so quote-abutted wrapper forms arm this gate today that did not arm that one. A
  masking fix without the wrapper carve-out would newly allow them. Mitigation: Group D is an
  acceptance criterion, each pin is confirmed to pass before the fix as well, and the carve-out is a
  constant pinned by test in #545.
- **The helper's API differs from what this spec assumes.** Mitigation: the dependency is described
  by capability, re-derivation against the merged tree is an acceptance criterion, and the executor
  halts and escalates rather than building a substitute.
- **#545 slips.** Mitigation: D4 makes the fallback an epic-orchestrator decision recorded in the
  checkpoint, so the schedule call is made where the schedule is owned.
- **The `gh` grammar assumption is wrong.** Mitigation: D5 makes verification a precondition of
  pinning the recognition sets, and the three grammar-conditional test rows are authored from the
  captured output.
- **Line-cap exhaustion.** The hook has 48 lines of headroom and the existing suite 45. Mitigation:
  new cases go in a sibling suite, and the dot-sourced sibling path with its full registration set
  is pre-authorized.
- **Coverage registration invisible to the MCP runner.** Mitigation: the self-hosted invocation is
  an acceptance criterion whenever a new file enters the denominator.
- **Scope drift into files another epic child owns.** Mitigation: the no-diff diff criteria are
  anchored to the integration branch and are checkable mechanically.
- **Rollback.** No feature flag. Reverting the hook and its mirror restores the previous posture,
  which is looser in the relocation direction and stricter in the masked direction. Rollback
  restores a known state rather than creating a new one.

---

## Rollout & Follow-up

- **Release steps.** Land the hook change, its bundle mirror, the new sibling Pester suite, the
  `issue.md` amendment, and — only if the cap requires it — the dot-sourced sibling with its three
  registrations, in one feature branch and one pull request onto the epic integration branch. No
  configuration, matcher, or registration change is otherwise required.
- **Post-merge validation.** After push-down, confirm in a destination repository that a `printf`
  writing a note that names the gated invocation proceeds, that a `cd`-prefixed merge of an
  authorized item proceeds, and that a merge naming an unauthorized item denies.
- **Follow-up candidates to file** (both are acceptance criteria of this change): the Codex copy's
  trigger over-match together with its two missing coverage registrations; and the accept-path-1
  property that `Test-ChildCheckpointAllowsEpicMerge` takes no pull-request number, covering both
  runtimes and noting its checkpoint-schema dependency.
- **Known deferrals recorded, not fixed here.** Over-match inside wrapper-led segments; obfuscated
  respellings of `gh`; unlisted wrappers whose quoted argument is a command line. All three are
  inherited from #545's D4 residual risks and are unchanged by this feature.
- **Links.** Issue #591 (https://github.com/drmoisan/drm-copilot/issues/591); research
  `docs/features/active/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line-591/research/2026-09-07T00-45-epic-merge-gate-command-text-matching-research.md`;
  upstream issue #545 with spec
  `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`;
  epic manifest `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`.
