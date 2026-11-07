# Process Reductions

This ledger records every reduction of evidence, plan tasks, gates, or review process, so that each one can be reverted months later. An agent that makes a reduction writes its entry here, in the same commit, in the format below.

## Index

| ID | Title | Date | Issue | Status |
| --- | --- | --- | --- | --- |

A data row's ID cell is a link such as `[0001](0001-short-name.md)`, and its label equals the number of the linked file. Every entry file has one row, and every row has one entry file.

## Entry Format

An entry is a file named `NNNN-<short-name>.md`, where `NNNN` is the next free four-digit number. It holds these level-two sections, each non-blank:

- `## Summary`: what was reduced, with two lines of their own: `reduction: NNNN`, which is also the token in the subject of the reduction's commit, and `Merge commit: pending (PR #N)`, where `N` is the pull request number. A commit cannot name itself or its later merge, so the next stage or a final records commit back-fills this line with the 7-to-40-character lowercase hexadecimal identifier of the merge commit, in the form `Merge commit: <identifier>`.
- `## Reason and Evidence`: why the reduction was made and what it was measured against.
- `## Files Changed`: every file the reduction changed, including mirrors, bundled copies, pinned hashes, and contract tests.
- `## Prior Text` or `## Stored Patch`: what a revert restores. An entry carries at least one of the two.
- `## Revert Steps`: the ordered steps of the revert.
- `## Revert Signals`: what the owner watches for, such as more remediation cycles after the reduction, that would justify a revert.

`## Prior Text` holds one `### Revert Block: <repository-relative path>` subsection per canonical file and one per non-identical copy. A byte-identical mirror takes no block, because it is re-copied from its canonical file instead.

Each block holds a `Current` fence, with the text as it stands after the reduction, and a `Prior` fence, with the text it replaces. The fence info string is the label. Each fence uses more backticks than any backtick run in its text, so verbatim Markdown stays inside it. `Current` must be non-empty and must occur exactly once in the target file. `Prior` may be empty, because a reduction may add text.

`## Stored Patch` names `patches/NNNN-<short-name>.patch`, a file in the `patches/` folder of this ledger with the same stem as the entry.

`## Revert Steps` names these six labels, in this order:

1. `Apply the blocks`
2. `Re-copy mirrors and bundles`
3. `Regenerate Codex variants`, which includes running the generator `--check`
4. `Restore pinned hashes`
5. `Restore contract-test literals`
6. `Run the contract tests`

A label that does not apply stays in the list and states "not applicable".

Three further rules apply:

- When wording for a reduction lands in a later commit, that commit also updates the reduction's entry, so the entry stays complete.
- One-off waivers for a single item are not entries.
- A revert does not depend on `git revert`. The entry alone restores the prior behavior, because the commit may be months old and the surrounding text may have moved.

## Worked Example

This sample shows a complete entry for a hypothetical `0000-example-reduction.md`. It is a sample, not an entry, and no such file exists.

`````markdown
# 0000: Example reduction

## Summary

reduction: 0000
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
