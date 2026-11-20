# enforcement-hook-trigger-matches-whole-command-text (Issue #545)

- Date captured: 2026-08-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/enforcement-hook-trigger-matches-whole-command-text/ (Issue #545)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #545
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/545
- Last Updated: 2026-08-25
- Work Mode: full-bug

## Summary

`Test-ImplementationCommand` in the orchestration preimplementation gate classifies a Bash
invocation by matching regexes against the entire raw command string, with no notion of where a
command begins and no awareness of quoting. The single design choice produces two opposite
defects: the gate blocks command text that merely *mentions* a governed token (false positive),
and it fails to classify a genuine governed command whose subcommand is not adjacent to the
command name (false negative, a latent bypass).

This is the follow-up recorded as "R2" during issue #539, deliberately left unfiled by that PR's
scope. It is filed now because the over-match direction was hit five times in a single working
session on 2026-08-24.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (the hook is PowerShell; no Python leg by standing policy)
- Command/flags used: any Bash invocation whose text contains a governed token; see Steps below
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
  (canonical Claude copy), and the three mirrored copies under `.codex/hooks/` and
  `extensions/drm-copilot/resources/`

## Steps to Reproduce

**Direction 1 — over-match (fires on text that is not a command):**

1. With any orchestrator checkpoint state, issue a Bash command whose text merely quotes a
   governed token inside a string, a heredoc body, or a JSON value — for example a receipt
   payload whose value is a promotion tool name, or a document write whose prose quotes the
   two-word staging invocation.
2. Observe the gate classify the invocation as an implementation command.
3. The command is denied with the `PREIMPLEMENTATION_GATE_BLOCKED:` prefix even though no
   governed command is being executed.

**Direction 2 — under-match (never fires on a command that is real):**

1. Ensure the checkpoint is NOT ready, so a governed staging command would normally be denied.
2. Issue a relocating spelling that separates the command name from the subcommand, such as
   `git -C ../some-other-worktree add .` with no other trigger-matching text on the line.
3. Observe that the trigger regex `(^|\s)git\s+(add|commit)\b` does not match, so the classifier
   never runs and the command is not evaluated at all.

## Expected Behavior

The gate should classify based on what the command line *executes*, not on what its text
*contains*. Specifically:

- Quoted prose, heredoc bodies, and string literals that mention a governed token should not be
  classified as invocations of that token.
- A governed command should be classified regardless of options appearing between the command
  name and its subcommand.

## Actual Behavior

The five trigger patterns are matched against `$normalizedCommand`, the whole command text:

```
(^|\s)git\s+(add|commit)\b
(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b
(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b
(^|\s)npx\s+(prettier|eslint|tsc|jest)\b
(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)
```

`(^|\s)` anchors only to a whitespace boundary, which any quoted string satisfies. `git\s+(add|commit)`
requires adjacency, which git does not.

Observed consequences, both directions, in one session:

- A JSON receipt string containing `--body-file` was classified as a PR-body invocation by the
  sibling hook `enforce-pr-author-skill.ps1`, which shares the same whole-command-text design.
  Blocked with `PR_BODY_PATH_NONCANONICAL`.
- Promotion tool names supplied as required receipt *values* were classified as promotion
  invocations. Blocked.
- Writing a memory file documenting this very defect was blocked, because the file necessarily
  quotes the token it warns about.
- A heredoc whose JSON body merely mentions a Python tool name is classified as a lint
  invocation by the second pattern.
- Conversely, `git -C <dir> add ...` passes ungated by non-match. `.claude/rules/` D4 row 14
  records this explicitly: such a line "never reaches this classifier and passes by non-match — a
  pre-existing trigger limitation."

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

From `spec.md` of issue #539, design decision D8, recorded as out of scope for that fix:

> The trigger regex is not narrowed in this fix because trigger scoping to a segment-leading
> command name is a fail-open change (wrapper bypasses via `xargs`, nested shells). D3 bounds the
> practical interaction. The same trigger property produces an under-match in the opposite
> direction: a relocating spelling that separates the command name from the subcommand is never
> classified at all and passes by non-match; this direction is part of the same follow-up
> candidate. Follow-up candidate for a separate issue; not filed here.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Rationale for Medium rather than High, stated so it can be revised deliberately:

- The **over-match** direction is confirmed and recurrent — five instances in one session — but
  its cost is friction, not incorrectness. A documented workaround exists (reword the prose), and
  applying it is disclosed, not a bypass. It never causes an unsafe action to succeed.
- The **under-match** direction is the more serious of the two in principle, because it is a
  latent bypass of an enforcement control rather than an annoyance. It is rated Medium only
  because no agent has been observed using a relocating spelling in practice, and the failure is
  fail-open by *omission* rather than by an incorrect allow decision.

Raise to High if the under-match is ever observed in a real session, or if an agent is found to
emit relocating spellings routinely.

## Suspected Cause / Notes

Root cause is a single property shared by the whole hook family: classification is regex over raw
command text rather than a parse of the command line.

Files to inspect:

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — `Test-ImplementationCommand`,
  the `$implementationCommandPatterns` array
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and the two bundle mirrors under
  `extensions/drm-copilot/resources/` — any fix must land on all four copies and preserve the pair
  contracts (Codex pair byte-identical, Claude pair content-equal)
- `.claude/hooks/enforce-pr-author-skill.ps1` — same design, independently confirmed
- `.claude/hooks/enforce-promotion-mcp-only.ps1` — same family; the promotion-token instance above

Note that the parsing machinery this needs already exists in-repo:
`Test-ExemptOrchestrationStagingCommand` in
`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, added by issue #539,
already performs quote-aware segment splitting outside quotes and carries a modeled option table
with deny-on-unmodeled-token semantics. It is currently confined to the allow side.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
- [x] Integration scenario to retest
- [x] Manual verification notes

Design constraint that must be honored, from D8: narrowing the trigger naively to a
segment-leading command name is a **fail-open** change, because wrapper forms (`xargs`, nested
shells) legitimately place the command name elsewhere. A fix that only removes false positives
while opening a wrapper bypass is worse than the current state. Both directions must be addressed
together, which is why they belong in one issue.

Candidate approach: promote the existing quote-aware segment parser to be the classifier itself,
so a token inside a quoted region is never a match, and so the command name and its options are
identified structurally rather than by adjacency. Every unparseable or unmodeled form must
continue to deny, preserving the fail-closed default.

Validation:

- Unit: per-direction Pester cases on both canonical sides — quoted-token non-match cases for the
  over-match direction; relocating-spelling classification cases for the under-match direction.
  Add the wrapper forms (`xargs`, nested shell) as explicit deny cases so the fail-open risk is
  pinned by test rather than by prose.
- Integration: the existing decision suites must pass unmodified where they assert current deny
  behavior, since this issue must not weaken any existing denial.
- Manual: re-run the five observed over-match instances above and confirm each proceeds; confirm
  `git -C <dir> add ...` is now classified and denied against a not-ready checkpoint.

Also worth deciding as part of this work: whether the fix applies to all five trigger patterns or
only the git pattern. The Python-tool pattern exhibits the same over-match, so a git-only fix
leaves most of the friction in place.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

Related: issue #539 (which recorded this as R2 and deliberately did not file it), PR #544, spec
design decision D8, and D4 rule-table row 14.

## Scope Amendment — 2026-09-06 (cleanup-merged-worktrees-hardening epic, child E)

This issue is widened to cover the **gate-hook instances of the same defect class**. No second
issue is opened for them.

### Why the scope widened

This issue is child E of the `cleanup-merged-worktrees-hardening` epic
(`docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`), where it is recorded as gap 8.
The 2026-09-06 cleanup run observed the same defect in a second hook family. Recorded verbatim from
that run's observations:

> ### 8. Hook text-matching false positives
>
> The gate hooks match on the Bash command string, so a `printf` whose literal text mentioned the
> gated gh subcommand was denied (`EPIC_MERGE_GATE_BLOCKED`) while writing a memory note. Match the
> command word position (first token of a pipeline segment, after `gh`), not any substring.

The defect is a single design property shared across the hook family — classification by regex over
raw command text rather than by a parse of the command line — so fixing it once in a shared,
tested command-word parser is cheaper and safer than fixing each hook separately. Splitting the
family across two issues would leave two hooks asserting against two different matchers.

### What this reverses

The `spec.md` "Scope & Non-Goals" section previously listed these as out of scope, deferred to "a
single follow-up candidate". That deferral is **withdrawn**; all five move into scope, joining the
three hooks already in scope by decisions D5, D6, and D10:

| Hook | Lines (2026-09-06) | Previous status |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 489 | in scope (originally filed) |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 274 | in scope (D5, D10) |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 228 | in scope (D6) |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 451 | **out of scope -> in scope** |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 418 | **out of scope -> in scope** |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 280 | **out of scope -> in scope** |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 256 | **out of scope -> in scope** |
| `.claude/hooks/validate-bash.ps1` | 230 | **out of scope -> in scope** |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 104 | **newly discovered -> in scope** |

The last row is a ninth defect site discovered during the 2026-09-06 re-derivation research. It
appears in no prior scope list: `Test-EpicBaseBranchOverride` at line 67, deny code
`EPIC_BASE_BRANCH_MISMATCH`. It is the same defect class and sits in the pr-author family already in
scope by D6, so it is included here rather than deferred.

Consequently the acceptance criterion "No out-of-scope hook is modified" and the criterion
requiring "A single follow-up candidate is filed covering the out-of-scope family members" are both
superseded by this amendment and are replaced in `spec.md`.

### Issue #591 is superseded by this issue

The merge-gate instance was separately captured on 2026-08-29 and promoted to **GitHub issue #591**
("Bug: epic-merge-gate-parses-pr-number-from-whole-command-line",
<https://github.com/drmoisan/drm-copilot/issues/591>). Its potential entry is at
`docs/features/potential/promoted/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md`.

Issue #591 is **OPEN**, has no active or completed feature folder, and no work has been done on it.
Its content is folded into this issue and its fix is delivered here. #591 should be closed as
superseded by #545 when this work merges.

Correction to the epic manifest: `epic.md` describes that entry as an "unpromoted potential entry"
located at `docs/features/potential/2026-08-29-...md`. Both details are inaccurate — the entry was
already promoted to #591 and already sits under `docs/features/potential/promoted/`. The epic's
instruction not to open a *second* issue for the merge-gate instance remains correct; only the
recorded disposition changes, from "do not promote" to "record #591 as superseded".

### The latent-bypass direction is a required deliverable, not an optional half

A fix that only removes false positives leaves the more dangerous half of the defect open. This
amendment records it as binding: acceptance requires at least one case per affected hook that the
**current** hooks fail to classify and the **fixed** hooks do classify. The `git -C <dir> add .`
case already recorded above is the canonical example; the gate hooks add
`git -C <dir> worktree remove <path>` and the relocating `gh` spellings.

### The shared parser is a contract two other epic children consume

Children D and G of the same epic edit two of these hooks immediately after this work: child D adds
cleanup-manifest acceptance to `enforce-epic-worktree-removal-gate.ps1`, and child G adds a
consolidation-PR checkpoint shape to `enforce-epic-merge-gate.ps1`. Both depend on this child.

Edits to those two hooks must therefore stay confined to the command-detection call site and its
immediate helpers, and the shared parser's public function signatures must be documented explicitly
in `spec.md` as the contract those children consume.

### Fresh reproduction on the current tree

The over-match direction reproduced again during this preparation run on 2026-09-06, at
`be722eba`: writing the orchestrator checkpoint through a Bash heredoc was denied with
`PROMOTION_MCP_ONLY_BLOCKED` because the JSON body named promotion tools as receipt *values*.
Recorded at
`evidence/other/live-reproduction-promotion-hook-overmatch.2026-09-06T23-35.md`.
This confirms the defect is still live twelve days after the original filing and is not confined to
the originally-filed hook.
