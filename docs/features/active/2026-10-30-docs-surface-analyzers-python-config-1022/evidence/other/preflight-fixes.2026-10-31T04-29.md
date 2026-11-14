# Preflight Fixes

Timestamp: 2026-10-31T04-29
Plan: docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/plan.2026-10-30T16-46.md
Round: 1 (re-derivation of the lost round-1 return; new planning cycle under owner decision D1)

## Fixes

1. `## Execution Context` design-source line (preamble) | stale heading anchor | The epic heading cited as `### 900011 - docs-surface-analyzer-python-native (wave 2, C3)` is now `### 1031 - docs-surface-analyzer-python-native (wave 2, C3)` in `docs/features/epics/documentation-estate-tooling/epic.md`; the citation is corrected and the binding section `### Native-analyzer contracts from the preparation of 1031 (binding)` is added to the list the [P0-T1] read covers. Reason: the heading was renamed when 1031 was promoted; the intent is unambiguous.
2. [P0-T3] | validator-blind class: hyphen-leading search pattern | The search token `-Help` is annotated as a hyphen-leading token passed through `-e`. Reason: a bare `-Help` pattern is read as an option by the search tool and returns no match; the asserted token is unchanged.
3. [P4-T2] | ambiguous anchor label whose intent is unambiguous | "the 900004 and 900011 anchors are untouched" now reads "the other two anchors (labelled `900004` or `1033`, and `900011` or `1031`, as the executed 1020 carries them) are untouched". Reason: the 1020 spec text carries the placeholder labels and the epic back-filled both children to 1033 and 1031; the assertion (no change to either anchor) is unchanged.
4. [P4-T1] | wording alignment that keeps the assertion's meaning | The comparison target is now the `config-files` subset of `config-surface-corpus.json` (entries whose `analyzer_id` is `config-files`), with a note that the `env-file-not-captured` entries carry `analyzer_id` `docs-inventory` and are asserted by [P4-T3]. Reason: [P2-T2] requires `env-file-not-captured` entries in that corpus, and `Invoke-DocsAnalyzerConfigFiles` never emits them (the inventory selection withholds env files before any analyzer runs), so a whole-corpus comparison could not pass; the plan already uses the subset wording for the python corpus.
