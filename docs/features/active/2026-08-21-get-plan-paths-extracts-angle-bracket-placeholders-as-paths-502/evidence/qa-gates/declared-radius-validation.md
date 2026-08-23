# QA Gate — Declared Blast Radius and Validation — [P8-T15]

Timestamp: 2026-08-23T04-30

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T15]

Command: `poetry run python <declare-and-validate script>` — derives the radius from this item's plan
and spec with `source` set to `declared`, appends the two concrete rule-file paths and the
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
mandated evidence-path citations. The `validation-placeholder-self-consistent.json` fixture pins the
same property in the shared corpus.

## Declared radius

84 path entries in total, of which 44 are this item's own evidence artifacts under its feature folder.
The 40 non-evidence entries are listed below with an on-disk existence check.

### Modules

`config`, `poshqc`

### Shared surfaces

| Entry | Origin |
| --- | --- |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | **enumerated by this task**, per [P8-T15]. This item genuinely writes it ([P4-T4]). |
| `config/blast-radius.json` | spec-sourced over-declaration — see below |
| `extensions/drm-copilot/package-lock.json` | over-declaration — see below |

### Contracts

`normalize_declared_radius`, `paths`

### The two concrete paths appended after normalization

Per mandate-read constraint 1, a planner must append a concrete path explicitly when an item genuinely
writes a path the rule tree otherwise excludes as a mandate read. `.claude/rules/**` is a configured
mandate-read path, so a mere citation of the rule file is removed from the harvest; this item **writes**
it, so both concrete paths are appended after normalization:

- `.claude/rules/parallel-orchestration.md` ([P6-T1])
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` ([P6-T2])

Both are present in the final declared radius and both resolve on disk.

### Non-evidence path entries, with existence

```text
  MISSING .claude/lib/**
  OK      .claude/lib/blast-radius/BlastRadius.psm1
  OK      .claude/lib/blast-radius/BlastRadiusExtraction.psm1
  OK      .claude/lib/blast-radius/BlastRadiusTokenShape.psm1
  OK      .claude/rules/parallel-orchestration.md
  OK      .claude/skills/feature-promotion-lifecycle/SKILL.md
  OK      config/blast-radius.json
  MISSING docs/features/active/<this feature folder>/**
  OK      docs/features/active/<this feature folder>/issue.md
  OK      docs/features/active/<this feature folder>/spec.md
  OK      extensions/drm-copilot/package-lock.json
  OK      extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1
  OK      extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
  OK      extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
  OK      extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
  OK      extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
  MISSING pack-manifests/core.json
  MISSING research/2026-08-22T23-15-placeholder-path-token-rejection-research.md
  OK      scripts/dev_tools/_blast_radius_extraction.py
  OK      scripts/dev_tools/_blast_radius_token_shapes.py
  OK      scripts/dev_tools/compute_blast_radius.py
  OK      scripts/powershell/PoshQC/settings/pester.runsettings.psd1
  OK      tests/fixtures/blast_radius/conflict-path-overlap.json
  MISSING tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json
  OK      tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json
  OK      tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json
  OK      tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json
  OK      tests/fixtures/blast_radius/validation-placeholder-self-consistent.json
  OK      tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1
  OK      tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
  OK      tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
  OK      tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
  OK      tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
  OK      tests/scripts/dev_tools/test_blast_radius_extraction_rules.py
  OK      tests/scripts/dev_tools/test_blast_radius_normalization.py
  OK      tests/scripts/dev_tools/test_blast_radius_parity.py
  OK      tests/scripts/dev_tools/test_blast_radius_token_shapes.py
  OK      tests/scripts/dev_tools/test_blast_radius_validation.py
  OK      tests/scripts/dev_tools/test_poshqc_bundled_parity.py
  OK      tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
```

The two `MISSING` glob entries are globs, not files, so a file-existence check is not the right test
for them; both resolve to populated directories.

## The accepted `path_overlap` edge with issue #500, per the AC-41 decision

**Decision, restated: do not sequence. Declare and accept the single `path_overlap` edge on the rule
file and its bundled mirror.**

The edge arises on this pair of concrete entries:

```text
path_overlap on .claude/rules/parallel-orchestration.md
path_overlap on extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
```

The rationale has three parts and is unchanged:

1. **The edge is unavoidable if both items run, and it is correct.** `.claude/rules/**` is a configured
   mandate-read path, so a mere citation produces no edge. Both items genuinely *write* the file, so
   both are obliged by mandate-read constraint 1 to append the concrete path after normalization. The
   resulting edge is a true contention signal, not a derivation artifact.
2. **Hand-sequencing would duplicate a stronger existing mechanism.** Under the per-edge cohort
   barrier, a conflicting neighbour in a strictly prior current-generation cohort must be merged, or
   its worktree removed, before the other item starts. The two items are therefore already mutually
   excluded by the derived edge, and a textual merge conflict on the rule file is impossible without
   any additional arrangement.
3. **An explicit dependency cannot be expressed.** `depends_on` is a prohibited key at every level of
   the parallel manifest, the planner checkpoint, and the orchestrator checkpoint. Ordering on this
   surface is expressed only as blast-radius overlap, so declaring the edge *is* the sequencing
   decision.

The two amendments are also textually non-adjacent: #500 amends the module-map granularity criterion,
#502 amends the read-by-mandate token-shape paragraph.

**Observed outcome: the sequencing question resolved itself in fact.** Issue #500 merged as pull
request #514 before this execution completed. `git merge-base --is-ancestor main HEAD` reports that
`main` is not an ancestor of `HEAD`, and `git log HEAD..main` lists 21 commits, all of them #500's.
The two items therefore did not run concurrently, and the edge served exactly the purpose the decision
predicted: it never had to be enforced because the ordering happened anyway. The practical consequence
is recorded at [P6-T1] and [P8-T5]: every `main`-anchored gate in this plan had to be diagnosed against
the merge base because this branch is behind `main`.

## Known over-declarations, recorded with their reasons

These entries are in the declared radius but are not files this item writes. Each is recorded so a
reviewer comparing the declared radius against the file-change map does not read the difference as an
error.

### The two spec-sourced over-declarations the plan predicted

| Entry | Reason | Character |
| --- | --- | --- |
| `config/blast-radius.json` | inline-coded in the sibling `spec.md`, which derivation harvests alongside the plan. Because it is a **declared shared surface**, it additionally resolves as a touched shared surface. | accepted read-reference over-inclusion |
| `pack-manifests/core.json` | inline-coded in the sibling `spec.md`. This is the bundled pack manifest referred to by its manifest-relative spelling; the path this item actually writes is the same file under the extension resources tree, which is separately and correctly present. | accepted read-reference over-inclusion |

Both are **read-reference over-inclusion, not the placeholder defect under repair**. No marker is
involved in either token: they are real, marker-free paths that the extractor accepts by design
because the derivation heuristic errs wide, and erring wide fails closed. The plan's token-hygiene
contract predicted both and recorded why they are not corrected by editing the spec: that document is
the acceptance-criteria source of record for this work mode, and rewriting its inline-code spans
mid-execution would amend the AC source to tidy a radius.

### Three further over-declarations observed during execution

| Entry | Reason |
| --- | --- |
| `extensions/drm-copilot/package-lock.json` | Cited in prose about the [P0-T9] install and the [P8-T10] format pathspec. It is a declared shared surface, so it resolves as one. This item does not write it — confirmed by its absence from the [P8-T5] staged diff file list. |
| `research/2026-08-22T23-15-placeholder-path-token-rejection-research.md` | The research document's feature-folder-relative spelling, harvested from prose. The file exists at its full path under the feature folder and is not written by this item's implementation. |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | A read-by-mandate-adjacent skill citation that is not on the configured `mandate_reads` list, so it survives the exclusion. Not written by this item. |

All five over-declarations widen the radius rather than narrow it, which is the fail-closed direction.
None is corrected by narrowing a radius to suppress an edge, which the Blast-Radius Contention
Doctrine prohibits.

### One declared path that does not exist

`tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` is in the declared radius because
[P5-T3] cites it in the plan text, but the file was not created: that task's acceptance condition is
unreachable through the conflict-fixture harness. The analysis is at
`evidence/other/p5-t3-blocker-conflict-fixture-seam.md`. The entry is a declaration of intent that the
blocked task did not fulfil; it produced no validation finding because V1 checks that the plan's
citations are *covered by* the radius, not that every radius entry exists on disk.

## Output Summary

Blast-radius validation over the declared radius reports **0 findings and 0 Blocking findings**. The
declared radius carries 84 path entries, two modules, three shared surfaces including the
enumerated Pester runsettings, and two contracts. The two concrete rule-file paths were appended after
normalization per mandate-read constraint 1. The accepted `path_overlap` edge with issue #500 is
recorded with its three-part rationale, and the sequencing question resolved in fact because #500
merged before this execution completed. Five over-declarations are recorded with their reasons —
including the two spec-sourced ones the plan predicted, with the configuration file additionally
resolving as a touched shared surface — each identified as accepted read-reference over-inclusion
rather than the placeholder defect under repair.
