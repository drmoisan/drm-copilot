# QA Gate — Contract-Scope Audit — [P8-T13]

Timestamp: 2026-08-23T04-24

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T13]

Command: `git add -A` (at the repository root)

Command: `git diff main`

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

EXIT_CODE: 0

## Why staging is load-bearing here above all

The two new leaf modules are what add function signatures. An unstaged diff would not contain them,
so the no-new-signature claim would be made against a diff that structurally *cannot* show a
violation. `git add -A` was run at the repository root before the diff was taken.

Ref-position note: `main` is not an ancestor of `HEAD` (this branch is 21 commits behind after issue
#500 merged as pull request #514), so the audit reads the merge-base-anchored diff
`bee15c0660d382ed74c642d2e028fd136051046f`, which contains exactly this branch's changes. Both anchors
were resolved and recorded.

## Diff file-list completeness

The staged name-status list contains 8 of the 9 created paths, the ninth being the [P5-T3] conflict
fixture that was not created (see `evidence/other/p5-t3-blocker-conflict-fixture-seam.md`). All eight
existing created paths appear, including both new leaf modules, so the diff does contain the surface
this audit must inspect. The full table is at [P8-T5].

## Function signatures added and removed

Added, across all production paths (`scripts`, `.claude`, and the bundled resources tree):

```text
+function Test-PlaceholderMarker {
+function Test-MultipleFeatureFolderSpan {
+function Test-PlaceholderMarker {              (bundled mirror)
+function Test-MultipleFeatureFolderSpan {      (bundled mirror)
+def contains_placeholder_marker(token: str) -> bool:
+def spans_multiple_feature_folders(token: str) -> bool:
```

Removed:

```text
-function Test-MultipleFeatureFolderSpan {
-function Test-MultipleFeatureFolderSpan {      (bundled mirror)
-def spans_multiple_feature_folders(token: str) -> bool:
```

### Reconciliation — the intended additions, enumerated

| Signature | Disposition |
| --- | --- |
| `contains_placeholder_marker(token: str) -> bool` | **new**, on the new Python leaf module. Intended addition. |
| `Test-PlaceholderMarker` | **new**, on the new PowerShell leaf module, plus its byte-identical bundled mirror. Intended addition. |
| `spans_multiple_feature_folders(token: str) -> bool` | **relocated**, character-identical signature, moved from `scripts/dev_tools/_blast_radius_extraction.py` to the new leaf module. Not a new signature. |
| `Test-MultipleFeatureFolderSpan` | **relocated**, identical signature and identical parameter block, moved from `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` to the new leaf module, plus the mirror. Not a new signature. |

The two relocations appear on both sides of the diff with identical text, which is what shows they are
moves rather than redefinitions. Both remain resolvable from their original module: the Python
extraction module imports the span predicate, and the PowerShell extraction module re-imports and
re-exports it, following the established precedent for the relocated ordinal-sort helper. A
module-export assertion at [P3-T4] pins that re-export, so the relocation is source-compatible for
every pre-existing call site and test.

**No function signature on any pre-existing public surface was added or changed.** `classify_path_token`
and `Get-PathTokenKind` — the two functions whose bodies gained the guard — keep their exact
signatures, parameter lists, and return vocabularies. **PASS.**

## No return type changed

Neither classifier's return type changed. Both continue to return the same three-valued result: the
concrete kind, the glob kind, or the no-classification value. The guard returns the **same
no-classification value the four sibling rejections already return** — `None` in Python, `$null` in
PowerShell — so the rejection is indistinguishable at the type level from the existing ones. **PASS.**

## No artifact type, CLI flag, or MCP input-schema property changed

A keyword sweep of every changed line under `scripts` and `extensions/drm-copilot` for
`add_argument`, `add_parser`, `artifact_type`, `inputSchema`, and `properties:` returned **no
matches**. No CLI subparser, no CLI flag, no orchestration artifact type, and no MCP input-schema
property key was added, removed, or renamed. **PASS.**

## No finding-rule literal changed

A sweep of every changed line for quoted validation-rule and gate-rule literals returned **no
matches**. No rule identifier was added, removed, or renamed. **PASS.**

This is the direct consequence of the silent-drop design constraint: the guard emits no diagnostic, so
there is no rule for it to be named by.

## No key added to the blast-radius configuration file

`config/blast-radius.json` does not appear in the diff at all (fixed-string file-name match count:
0). The marker set is a module constant in each runtime, not a truth-table key, so no configuration
key was needed and none was added. **PASS.**

This is confirmed independently by the amended rule-file prose, which states that the set is not a
configuration key and is not read from that file.

## No JSON Schema file added anywhere in the repository

This is [P6-T1]'s whole-repository claim, carried here because it cannot be observed from that task's
single-pathspec diff and because a newly created schema file would be untracked and invisible to an
unstaged diff. This diff is staged and whole-tree, so it can see a new file.

Added paths matching a JSON-or-schema pattern:

```text
A  tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json
A  tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json
A  tests/fixtures/blast_radius/validation-placeholder-self-consistent.json
```

All three are **parity-corpus test fixtures**, not schemas. Each carries the corpus fixture shape —
a `description`, an `input` block, and an `expected` block — and none carries a schema keyword, a
`$schema` declaration, or an `$id`. No file was added under `schemas/`, and no added file name carries
a `.schema.` segment.

**No added path in the file list is a schema file.** Enforcement of the new rejection remains prose
plus validator logic, exactly as the amended rule file states. **PASS.**

## Backstop for [P4-T3] and [P4-T4] prior-state conditions

[P4-T3]'s no-reordering condition and [P4-T4]'s no-removal condition are prior-state claims that
cannot be settled against a post-edit file alone. Their hunks are recorded here explicitly.

### Pack manifest hunk, complete

```text
@@ -129,6 +129,7 @@
+    ".claude/lib/blast-radius/BlastRadiusTokenShape.psm1",
```

A single-line insertion at one location. **No existing entry was reordered, duplicated, or removed** —
a reordering would appear as paired removals and additions of existing entries, and there are none.
The hunk header confirms the shape: six context lines in, seven out, one line added.

### Pester allow-list hunk

Recorded in full at [P8-T12]: one added inclusion entry plus comment text, with the only removed line
being the corrected file-count word inside a comment. **No allow-list entry was removed.** The
entry-count comparison at [P4-T6] corroborates it numerically: 80 entries at `HEAD` versus 81 now.

## Expected-findings blocks of the pre-existing fixtures

The name-status output for `tests/fixtures/blast_radius` lists **only the three added fixtures**. No
pre-existing fixture appears with an `M` status, so the `expected` block of all 32 pre-existing
fixtures — findings lists included — is unchanged. [P5-T12] establishes the same conclusion from the
union of a porcelain status and an anchored diff, and [P5-T7] establishes it with a dedicated
`--exit-code` diff for the reused negative control.

## Output Summary

`git add -A` was run at the repository root and the staged, whole-tree anchored diff was audited. The
diff adds or changes **no** function signature on any pre-existing public surface, **no** return type,
**no** artifact type, **no** CLI flag, **no** MCP input-schema property, **no** finding-rule literal,
and **no** key in the blast-radius configuration file. The four added signatures are the two new leaf
modules' own exported predicates plus their two bundled-mirror copies, and the two signatures
appearing on both sides of the diff are character-identical relocations, both still resolvable from
their original module. No added path is a schema file. The pack-manifest hunk is a single-line
insertion with no reordering, and the allow-list hunk removes no entry.
