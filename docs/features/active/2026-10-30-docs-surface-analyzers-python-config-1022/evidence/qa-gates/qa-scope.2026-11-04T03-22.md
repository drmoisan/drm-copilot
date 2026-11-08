# [P6-T8] Scope verification (issue #1022)

Timestamp: 2026-11-04T03-22
Command: MERGE_BASE=$(git merge-base origin/epic/documentation-estate-tooling-integration HEAD); git diff --name-only MERGE_BASE; git status --porcelain --untracked-files=all (union of both, sorted unique, saved to SCRATCH/issue-1022-p6t8-union.txt); git diff --numstat MERGE_BASE -- .claude/lib/docs/DocsAnalyzerRegistry.psm1 .claude/lib/docs/Invoke-DocsCommand.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerRegistry.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1
EXIT_CODE: 0
Output Summary: MERGE_BASE derivation: `git merge-base origin/epic/documentation-estate-tooling-integration HEAD` = the 1020 merge commit on the integration branch (the commit recorded in the [P0-T2] dependency artifact). The union lists 107 paths and every path matches a row of `## Artifact Classification`; 0 paths end in `.py` or `.ts` or lie under `.claude/hooks/`, `.claude/skills/`, `.claude/agents/` or `extensions/drm-copilot/src/`; no 1020 file appears except the two anchored edits, their mirror copies and the `core.json` append. Numstat: 5 added / 0 deleted for both registry copies, 1 added / 0 deleted for both entry-script copies.

## Union by classification row

| Classification row | Paths |
|---|---|
| `LIB/` eighteen new modules plus the two edited files (`DocsAnalyzerRegistry.psm1`, `Invoke-DocsCommand.ps1`) | 20 |
| `MIRROR/` byte-identical copies of the twenty files above | 20 |
| `CORE` (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, edit) | 1 |
| `TESTS/<Module>.Tests.ps1` for the eighteen new modules plus `TESTS/DocsInventoryProperties.Tests.ps1` | 19 |
| `TESTS/fixtures/python-surface-corpus.json`, `TESTS/fixtures/config-surface-corpus.json` | 2 |
| `FEATURE/**` (plan, spec and user story check-offs and version revisions, evidence) | 45 |
| Total | 107 |

Paths outside these rows: 0. Evidence files written after this listing (this artifact and the later Phase 6 artifacts) are under `FEATURE/evidence/` and fall in the same `FEATURE/**` row. The count of new modules, mirror pairs and `CORE` entries is one higher than the plan text (eighteen, twenty, 18) because of the [P1-T3] split of `DocsPythonSyntax.psm1` into `DocsPythonSyntax.psm1` and `DocsPythonBindings.psm1`, recorded as its own row in `## Artifact Classification`.

## Numstat

```
5	0	.claude/lib/docs/DocsAnalyzerRegistry.psm1
1	0	.claude/lib/docs/Invoke-DocsCommand.ps1
5	0	extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerRegistry.psm1
1	0	extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1
```

For reference, `git diff --numstat MERGE_BASE -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` reports 19 added and 1 deleted on this branch's own diff: `CORE_TAIL` is `last`, so the previous final entry is rewritten with a trailing comma (1 deleted, 1 added) and 18 entries are appended (18 added), which is the [P5-T2] rule with the split module added.

## Forbidden-class check

`grep -cE '\.(py|ts)$|^\.claude/(hooks|skills|agents)/|^extensions/drm-copilot/src/'` over the union: 0.
