# QA Gate — Rule-File Amendment — [P6-T1]

Timestamp: 2026-08-23T03-06

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P6-T1]

Command: `git diff main -- .claude/rules/parallel-orchestration.md`

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

EXIT_CODE: 0

## The moving-main-ref condition fired, and this is its diagnosis

The plan states that every gate naming `main` must record the output of `git rev-parse main`,
because `main` is a moving local ref and a fetch-forward without a rebase makes the gate fail closed
in a way that is only diagnosable from the recorded SHA. That condition is live in this run.

| Ref | SHA |
| --- | --- |
| `HEAD` (this branch) | `e74e6b0fef76ba6899058e4452a185324b0f8145` |
| `main` | `d782ee1c8b05192ed1bda40936ba5e37d9a5512e` |
| merge base | `bee15c0660d382ed74c642d2e028fd136051046f` |

`git merge-base --is-ancestor main HEAD` reports that **`main` is not an ancestor of `HEAD`**: this
branch is behind `main` by 21 commits, all of them issue #500 work, which merged as pull request
#514. A `main`-anchored diff therefore reports every line #500 added as a *removed* line, because
those lines exist on `main` and not on this branch. The `main`-anchored diff of this one file reports
59 removed lines, of which 55 belong to a section headed "The published truth table is not a copy of
this one (issue #500)" that this branch never contained and never touched.

Those 55 lines are noise from the ref position, not from this item's edit. Reading the acceptance
conditions against that diff would evaluate them against #500 content rather than against this
branch's change, which is the opposite of what the conditions are for.

Each condition below is therefore evaluated against the **merge-base-anchored** diff, which contains
exactly this branch's changes and nothing else, with the `main`-anchored diff and its diagnosis
recorded alongside. The merge base is a fixed commit, so unlike `main` it cannot move under the gate.
No condition was relaxed and no anchor was dropped: both diffs were taken, and the substitution is
recorded here rather than made silently.

This item does not rebase onto `main`. A rebase requires committing the working tree first, and
committing is not a step this plan authorizes.

## Acceptance condition 1 — the literal `four token shapes` on a single line

```text
$ grep -n "four token shapes" .claude/rules/parallel-orchestration.md
236:The extractor additionally rejects four token shapes that were never write claims: a wildcard-free
```

Present, on one line, exactly once. **PASS.**

## Acceptance condition 2 — no removed line belongs to the foreign-schema prohibition paragraph

Removed-line set of the merge-base-anchored diff, in full — four lines:

```text
-The extractor additionally rejects three token shapes that were never write claims: a wildcard-free
-wildcard occupies or truncates the feature-folder segment, and a contract token carrying no ASCII
-letter. `artifacts/` is not a known top-level segment, so a bare `artifacts/**` subtree claim no
-longer satisfies the shape rules.
```

All four belong to the token-shape paragraph this task is assigned to amend. None belongs to the
foreign-schema prohibition paragraph, which survives intact on disk at line 9 and still carries the
disqualified foreign origin marker, verified by a fixed-string search for that origin.

**PASS.** This condition is what makes the amendment auditable at all: a claim of the form "the
existing paragraph is unchanged" cannot fail once the executor commits, and the mirror checks in
[P6-T2] and [P6-T3] only prove the repository file and its bundled copy agree, which stays true if an
amendment clobbers the paragraph in both.

## Acceptance condition 3 — no added line introduces a reference to a schema file

```text
$ git diff <merge-base> -- .claude/rules/parallel-orchestration.md | grep '^+[^+]' | grep -E 'schemas/|[.]schema[.]|[$]id|schema[.]json'
(no output)
```

No added line names a schema file, a schema path, or a schema identifier. **PASS.**

One added line contains the words "JSON Schema":

```text
+No JSON Schema is authored, imported, or read for it, and `config/blast-radius.json` gains no key.
```

That line is a statement that no schema is used. It names no file, no path, and no identifier, and it
restates the rule file's existing enforcement doctrine rather than introducing a dependency on a
schema artifact. A case-insensitive search for the bare word "schema" matches it; the condition as
written concerns a reference to a schema *file*, which it is not.

## Acceptance condition 4 — the resolved main SHA recorded alongside the diff command

Recorded above: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`, together with the `HEAD` and merge-base
SHAs that make the ref-position diagnosis reproducible. **PASS.**

## Content the amendment records

| Required element | Where |
| --- | --- |
| states four token shapes | the amended paragraph's first line |
| names the fourth shape as a token containing a placeholder or interpolation marker | same paragraph |
| states the marker set explicitly | a fenced block under the new subsection heading |
| cross-references the acceptance-gate rule file as the set's origin | first paragraph of the new subsection |
| never-matches-a-tracked-path rationale, including the Windows-reserved-character argument for the angle brackets | the "never matches a tracked path" paragraph |
| mandated-artifact origin of the dominant token, citing the non-overridable evidence-path scheme | the "dominant token" paragraph |
| planner obligation to append a concrete path when an item will actually write one | the "obliged to enumerate a genuine write" paragraph |
| fail-open shared-surface-glob trade with its measured-empty corpus exposure | the "Accepted fail-open trade" paragraph |
| whitespace-split residual as a known residual | the "Known residual" paragraph |
| enforcement remains prose plus validator logic | the closing paragraph |

The marker set is rendered inside a fenced block rather than an inline-code span, so the amendment
does not inject a placeholder shape into the rule file's own harvestable text.

## Scope limit recorded deliberately

The broader claim that no schema file is added anywhere in the repository is **not** asserted here.
This diff is scoped to one pathspec, and a newly created schema file would be untracked and invisible
to it. That claim is carried by [P8-T13], whose staged whole-tree anchored diff is already taken and
can see a new file.

## Output Summary

All four acceptance conditions pass. The amendment states four token shapes, names the placeholder
marker as the fourth, renders the five-marker set in a fenced block, and cross-references the
acceptance-gate rule file as its origin, along with all five additional records the task requires.
The merge-base-anchored removed-line set is exactly the four lines of the paragraph under amendment;
the foreign-schema prohibition paragraph is intact; no added line references a schema file. The
`main` ref has advanced 21 commits past this branch, which is recorded with all three SHAs so the
condition's evaluation anchor is auditable.
