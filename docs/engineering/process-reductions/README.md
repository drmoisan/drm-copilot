# Process Reductions

This ledger records every reduction of evidence, plan tasks, gates, or review process, so that each one can be reverted months later. An agent that makes a reduction writes its entry here, in the same commit, in the format below.

## Index

| ID | Title | Date | Issue | Status |
| --- | --- | --- | --- | --- |
| [0001](0001-parallel-only-test-gates.md) | Parallel-only test gates | 2026-11-07 | #1094 | Partially reverted by 0006 |
| [0002](0002-concurrent-review.md) | Concurrent review | 2026-11-07 | #1097 | Active |
| [0003](0003-light-remediation.md) | Light remediation | 2026-11-07 | #1097 | Active |
| [0004](0004-smaller-plans.md) | Smaller plans | 2026-11-07 | #1097 | Active |
| [0005](0005-policy-read-removal.md) | Policy-read removal | 2026-11-07 | #1097 | Active |
| [0006](0006-test-suite-baseline-restored.md) | Test-suite baseline restored | 2026-11-07 | #1097 | Active |
| [0007](0007-epic-main-sync-plain-merge.md) | Epic main-sync as a plain merge | 2026-11-07 | #1117 | Active |
| [0008](0008-g13-guideline-cutoff.md) | G13 guideline cutoff | 2026-11-07 | #1097 | Active |
| [0009](0009-less-evidence.md) | Less evidence and the CI cross-check | 2026-11-08 | #1097 | Active |
| [0010](0010-early-dependent-starts.md) | Early dependent starts | 2026-11-08 | #1097 | Active |

A data row's ID cell is a link such as `[0001](0001-short-name.md)`, and its label equals the number of the linked file. Every entry file has one row, and every row has one entry file.

## Entry Format

An entry is a file named `NNNN-<short-name>.md`, where `NNNN` is the next free four-digit number. It holds these level-two sections, each non-blank:

- `## Summary`: what was reduced, with four lines of their own: `reduction: NNNN`, which is also the token in the subject of the reduction's commit, `Date: yyyy-MM-dd` (UTC), `Issue: #N` for the issue that made the reduction, and `Merge commit: pending (PR #N)`, where `N` is the pull request number. The checker requires only the `reduction:` and `Merge commit:` lines; the `Date:` and `Issue:` lines are format guidance and are not enforced. A commit cannot name itself or its later merge, so the next stage or a final records commit back-fills this line with the 7-to-40-character lowercase hexadecimal identifier of the merge commit, in the form `Merge commit: <identifier>`.
- `## Reason and Evidence`: why the reduction was made and what it was measured against.
- `## Files Changed`: every file the reduction changed, including mirrors, bundled copies, pinned hashes, and contract tests.
- `## Prior Text` or `## Stored Patch`: what a revert restores. An entry carries at least one of the two.
- `## Revert Steps`: the ordered steps of the revert.
- `## Revert Signals`: what the owner watches for, such as more remediation cycles after the reduction, that would justify a revert.

`## Prior Text` holds one `### Revert Block: <repository-relative path>` subsection per canonical file and one per non-identical copy. The path has no leading `/` or `\`, no drive prefix, and no `..` segment. A byte-identical mirror takes no block, because it is re-copied from its canonical file instead. When wording for an entry lands after a higher-numbered entry, the blocks of that later landing go at the end of `## Prior Text` under a heading `### Later Landing: #N`, where `#N` names the issue of the later landing.

Each block holds a `Current` fence, with the text as it stands after the reduction, and a `Prior` fence, with the text it replaces. The fence info string is the label. Each fence uses more backticks than any backtick run in its text, so verbatim Markdown stays inside it. `Current` must be non-empty and must occur exactly once in the target file. `Prior` may be empty, because a reduction may add text.

`## Stored Patch` names `patches/NNNN-<short-name>.patch`, a file in the `patches/` folder of this ledger with the same stem as the entry. Write the path in backticks, or end a sentence with at most one period after it. The patch check, `git apply -R --check` of the patch, runs on the tree after every later entry that touches the patch's paths is reverted and then the entry's own later landings, as `## Revert Order` states, not on the live tree.

`## Revert Steps` names these six labels, in this order:

1. `Apply the blocks`
2. `Re-copy mirrors and bundles`
3. `Regenerate Codex variants`, which includes running the generator `--check`
4. `Restore pinned hashes`
5. `Restore contract-test literals`
6. `Run the contract tests`

A label that does not apply stays in the list and states "not applicable".

A partial revert of an earlier entry is a new entry whose `Current` fences hold the restored text and whose `Prior` fences hold the earlier entry's text, so that reverting the new entry re-applies the reduction. The earlier entry gains a `## Partial Revert` section that names the new entry and lists what it restores, step 1 of its `## Revert Steps` defers to `## Revert Order`, which reverts the new entry first, and its index Status reads `Partially reverted by NNNN`, where `NNNN` is the new entry.

Three further rules apply:

- When wording for a reduction lands in a later commit, that commit also updates the reduction's entry, so the entry stays complete.
- One-off waivers for a single item are not entries.
- A revert does not depend on `git revert`. The entry alone restores the prior behavior, because the commit may be months old and the surrounding text may have moved.

## Revert Order

Entries are reverted newest-first: the highest-numbered entry first, then each lower number in turn. An entry may be reverted alone only when no later entry names any of its paths. To find the later entries that touch a path, search the `## Files Changed` sections of the higher-numbered entries for that path; every entry lists every path it changed. Revert those entries first, newest-first. An entry's `## Revert Steps` does not list the later entries that depend on it, because this rule derives them at revert time.

Newest-first by number is unchanged when an entry has a later landing. Within an entry's turn, its later landings, recorded under `### Later Landing: #N` headings at the end of its `## Prior Text`, are reverted first, the last heading first, and then the entry's own blocks or stored patch. A later landing may not edit a region that a higher-numbered entry records; a change that would do so takes a new entry instead. Number order is therefore landing order wherever regions overlap, and the chain test fails on a violation, because a higher-numbered entry's `Current` is then not found or a hunk does not apply.

To revert an older reduction while keeping the later ones, write a new entry that restores the older entry's stored prior text over the current tree, as entry `0006` did for entry `0001`; this is a route, not a requirement, and the new entry is itself revertible.

A stored patch is read hunk by hunk as a revert block: a hunk's context and `+` lines are its `Current`, and its context and `-` lines are its `Prior`. After the later entries and then the entry's own later landings are reverted, run `git apply -R` of the patch. A hunk that does not apply is applied by hand: replace its `Current` lines with its `Prior` lines, at the occurrence nearest the hunk's recorded line.

A byte-identical mirror or bundle copy, and a generated Codex variant, is derived: revert steps 2 and 3 re-create it from its source, so its patch section is not applied by hand. A bundle path under `claude-customizations/`, `codex-and-agents-customizations/`, or `customizations/` maps to the repository path below that folder, a bundle path under `feature-templates/` or `templates/` maps to the same path under `docs/features/templates/`, and a `.agents` or `.github` skill copy maps to the `.claude` skill of the same name. A copy whose text differs from its source is a source in its own right.

An edit inside a recorded region, which is a block's `Current` or a hunk with its context lines, must update that entry's record in the same commit: the block, or the hunk regenerated so that it carries the edit in both images, with the entry's `reduction:` token in the commit subject. A commit that adds a rule inside a ledgered region with no entry of its own therefore breaks the chain; the chain test catches it on CI, and the fix is to rebase the affected hunk in the same change. An edit outside every region needs no record.

`tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` enforces this order: it reverts every entry newest-first in memory through `scripts/dev-tools/ProcessReductionChain.psm1` and fails when any block or hunk does not apply.

## Worked Example

This sample shows a complete entry for a hypothetical `0000-example-reduction.md`. It is a sample, not an entry, and no such file exists.

`````markdown
# 0000: Example reduction

## Summary

reduction: 0000
Date: 2026-01-15
Issue: #1200
Merge commit: pending (PR #1234)

Removes the routine sample sentence from the example skill.

## Reason and Evidence

The sentence repeated a rule that the example policy already states. Three reviewed items followed the rule without it.

## Files Changed

- `.claude/skills/example/SKILL.md`
- `.agents/skills/example/SKILL.md`, a byte-identical mirror

## Prior Text

### Revert Block: .claude/skills/example/SKILL.md

````Current
Follow the example policy.
````

````Prior
Follow the example policy.
Record the routine sample sentence.
````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file.
2. Re-copy mirrors and bundles: copy the canonical file to `.agents/skills/example/SKILL.md`.
3. Regenerate Codex variants: not applicable.
4. Restore pinned hashes: not applicable.
5. Restore contract-test literals: not applicable.
6. Run the contract tests: run the contract test module of the example skill.

## Revert Signals

- Reviewed items stop recording the sample sentence and a remediation cycle cites it.
`````
