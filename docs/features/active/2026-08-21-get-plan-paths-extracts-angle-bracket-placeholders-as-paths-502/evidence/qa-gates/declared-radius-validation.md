# QA Gate — Declared Blast Radius and Validation — [P8-T15]

Timestamp: 2026-08-23T05-40

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T15]
Run: revision-6 re-run.

Command: `poetry run python <declare-and-validate script>` — derives the radius from this item's plan
and spec with the confidence source set to declared, appends the two concrete rule-file paths and the
shared-surface entry after normalization, and runs blast-radius validation over the result against the
same plan text.

EXIT_CODE: 0

Tracked-file count supplied to validation: read from `git ls-files` at execution time.

## Validation result

```text
findings: 0
BLOCKING count: 0
```

**Validation reports no finding of any severity, and therefore no Blocking finding.** **PASS.**

That the derived radius validates clean against its own plan is the symmetry invariant the fix had to
preserve: derivation and validation rules V1 and V2 apply the identical shape rejection, so a
placeholder-citing plan produces a radius that passes V1 against that same plan. Had the guard been
placed in derivation only, every plan in the corpus would now emit V1 Blocking findings for its own
mandated evidence-path citations.

## Change since the previous run, and a correction to an expectation

The revision-6 delta expected the declared radius to **lose** a path, on the reasoning that [P5-T3] no
longer creates the conflict fixture. **That is not what happened, and the reason is worth recording.**

| Quantity | Previous run | This run |
| --- | --- | --- |
| declared path entries | 84 | **85** |
| paths dropped | — | **none** |
| paths added | — | 1 |
| findings | 0 | **0** |

- **The fixture path did not leave the radius.** Revision 6's own explanatory sub-bullet under [P5-T3]
  names that filename inside an inline-code span while explaining why the fixture was replaced.
  Derivation harvests inline-code tokens from plan text, so the citation is still harvested even though
  the file is no longer created.
- **One path was added:** the blocker artifact under `evidence/other/`, which revision 6's same
  sub-bullet cites in an inline-code span.

Neither movement produces a finding. V1 checks that the plan's citations are *covered by* the radius,
not that every radius entry exists on disk, so a declared entry for a file the plan discusses but does
not create is an over-declaration rather than a violation. It widens the radius, which is the
fail-closed direction.

This is a small instance of the very defect class this item repairs, in its marker-free form: a citation
that is evidence of discussion rather than of a write. The extractor accepts it by design because the
derivation heuristic errs wide, and the plan's token-hygiene contract anticipated exactly this trade for
read-references. It is recorded rather than corrected, because correcting it would mean editing the plan
of record's explanatory prose mid-execution to tidy a radius.

## Declared radius

85 path entries in total, of which 45 are this item's own evidence artifacts under its feature folder.

### Modules

`config`, `poshqc`

### Shared surfaces

| Entry | Origin |
| --- | --- |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | **enumerated by this task**, per [P8-T15]. This item genuinely writes it ([P4-T4]). |
| `config/blast-radius.json` | spec-sourced over-declaration |
| `extensions/drm-copilot/package-lock.json` | prose-sourced over-declaration |

### Contracts

`normalize_declared_radius`, `paths`

### The two concrete paths appended after normalization

Per mandate-read constraint 1, a planner must append a concrete path explicitly when an item genuinely
writes a path the rule tree otherwise excludes as a mandate read. The rule tree is a configured
mandate-read path, so a mere citation is removed from the harvest; this item **writes** it, so both
concrete paths are appended after normalization:

- `.claude/rules/parallel-orchestration.md` ([P6-T1])
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` ([P6-T2])

Both are present in the final declared radius and both resolve on disk.

## The accepted path-overlap edge with issue #500, per the AC-41 decision

**Decision, restated: do not sequence. Declare and accept the single path-overlap edge on the rule file
and its bundled mirror.** The rationale has three parts and is unchanged:

1. **The edge is unavoidable if both items run, and it is correct.** The rule tree is a configured
   mandate-read path, so a mere citation produces no edge. Both items genuinely *write* the file, so both
   are obliged by mandate-read constraint 1 to append the concrete path after normalization. The
   resulting edge is a true contention signal, not a derivation artifact.
2. **Hand-sequencing would duplicate a stronger existing mechanism.** Under the per-edge cohort barrier,
   a conflicting neighbour in a strictly prior current-generation cohort must be merged, or its worktree
   removed, before the other item starts. The two items are already mutually excluded by the derived
   edge, so a textual merge conflict on the rule file is impossible without any additional arrangement.
3. **An explicit dependency cannot be expressed.** A dependency key is prohibited at every level of the
   parallel manifest, the planner checkpoint, and the orchestrator checkpoint. Ordering on this surface
   is expressed only as blast-radius overlap, so declaring the edge *is* the sequencing decision.

**Observed outcome: the sequencing question resolved itself in fact.** Issue #500 merged as pull request
#514 before this execution completed. `origin/main` is 27 commits ahead of the merge base and `HEAD` is
9 ahead, so `main` is not an ancestor of `HEAD`. The two items did not run concurrently, and the edge
served exactly the purpose the decision predicted: it never had to be enforced because the ordering
happened anyway. The practical consequence is recorded at [P6-T1], [P8-T5], [P8-T9], [P8-T12],
[P8-T13], and [P8-T14]: every anchored gate is evaluated against the merge base with all three SHAs on
record.

## Known over-declarations, recorded with their reasons

Each is in the declared radius but is not a file this item writes, so a reviewer comparing the declared
radius against the file-change map does not read the difference as an error.

### The two spec-sourced over-declarations the plan predicted

| Entry | Reason | Character |
| --- | --- | --- |
| `config/blast-radius.json` | inline-coded in the sibling spec, which derivation harvests alongside the plan. Because it is a **declared shared surface**, it additionally resolves as a touched shared surface. | accepted read-reference over-inclusion |
| `pack-manifests/core.json` | inline-coded in the sibling spec. This is the bundled pack manifest under its manifest-relative spelling; the path this item actually writes is the same file under the extension resources tree, which is separately and correctly present. | accepted read-reference over-inclusion |

Both are **read-reference over-inclusion, not the placeholder defect under repair**. No marker is
involved in either token: they are real, marker-free paths that the extractor accepts by design. The
plan's token-hygiene contract predicted both and recorded why they are not corrected by editing the
spec: that document is the acceptance-criteria source of record for this work mode, and rewriting its
inline-code spans mid-execution would amend the AC source to tidy a radius.

### Four further over-declarations observed

| Entry | Reason |
| --- | --- |
| `tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` | cited by revision 6's own [P5-T3] sub-bullet while explaining why the fixture was replaced. The file does not exist. See the correction section above. |
| `extensions/drm-copilot/package-lock.json` | cited in prose about the [P0-T9] install and the [P8-T10] format pathspec. It is a declared shared surface, so it resolves as one. Not written by this item, confirmed by its absence from the [P8-T5] staged diff file list. |
| `research/2026-08-22T23-15-placeholder-path-token-rejection-research.md` | the research document's feature-folder-relative spelling, harvested from prose. The file exists at its full path under the feature folder. |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | a skill citation that is not on the configured mandate-read list, so it survives the exclusion. Not written by this item. |

All six over-declarations widen the radius rather than narrow it, which is the fail-closed direction.
None is corrected by narrowing a radius to suppress an edge, which the Blast-Radius Contention Doctrine
prohibits.

## Output Summary

Blast-radius validation over the declared radius reports **0 findings and 0 Blocking findings**. The
declared radius carries 85 path entries, two modules, three shared surfaces including the enumerated
Pester runsettings, and two contracts. The two concrete rule-file paths were appended after
normalization per mandate-read constraint 1. Contrary to the revision-6 expectation the radius did not
lose a path: the replaced fixture's filename is still cited in the revised task's own explanatory prose,
so it remains an over-declaration for a file that does not exist, which produces no finding because V1
checks citation coverage rather than entry existence. The accepted path-overlap edge with issue #500 is
recorded with its three-part rationale, and the sequencing question resolved in fact because #500 merged
before this execution completed.
