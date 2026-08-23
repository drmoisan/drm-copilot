# Self-hosted truth-table unchanged-key verification (Issue #500)

Timestamp: 2026-08-21T23:30:00Z
Issue: #500
Tasks: [P3-T2], [P3-T6]

Command:

```
poetry run python <scratchpad script reading both committed copies with json.loads and printing
the cardinality and value of every top-level key>
```

(working directory: worktree root; the script is a throwaway created and deleted within this
session, permitted by the file-size and temporary-script exception in
`.claude/rules/general-code-change.md`. It reads the two committed files and writes nothing.)

EXIT_CODE: 0

## [P3-T6] — `config/blast-radius.json`: only `mandate_reads` changed

Observed cardinality and value of each top-level key:

| Key | Expected | Observed | Status |
| --- | --- | --- | --- |
| `version` | `1` | `1` | unchanged |
| `shared_surfaces` | 10 entries | 10 entries | unchanged |
| `shared_surface_globs` | 3 entries | 3 entries | unchanged |
| `modules` | 7 subsystem modules | 7: `benchmarks`, `codex-runtime`, `config`, `mcp-server`, `poshqc`, `powershell-dev-tools`, `schemas` | unchanged |
| `over_breadth_fraction` | `0.25` | `0.25` | unchanged |
| `mandate_reads` | 6 before, 10 after | 10 entries | CHANGED by [P3-T5], as planned |

The top-level key order is unchanged:
`['version', 'shared_surfaces', 'shared_surface_globs', 'mandate_reads', 'modules', 'over_breadth_fraction']`.

Every stated cardinality matches. `mandate_reads` is the only key this plan modifies in the
self-hosted copy, and it grew by exactly the four entries [P3-T5] appends.

## [P3-T2] — bundled `shared_surface_globs` remains the empty list

Observed: `[]`, and the emptiness probe reports `True`. **No edit was made to this key.**

The verification is recorded rather than the key being populated because all three self-hosted globs
are `scripts/dev_tools/*.py` patterns naming this repository's own Python dev-tooling module
families (`validate_*.py`, `_orchestrator_state_*.py`, `_epic_orchestrator_state_*.py`). None of them
describes any destination workspace. An empty list is acceptable rather than merely tolerable,
because a glob is never a source of root-token acceptance: only a separator-free entry in
`shared_surfaces` opens the root-token branch of the path-token classifier, and [P3-T1] supplies
three such entries.

## Cross-copy relations after Phase 3

| Relation | Result |
| --- | --- |
| `version` equal across copies | `True` |
| `over_breadth_fraction` equal across copies | `True` |
| `mandate_reads` byte-equal across copies | `True` |
| bundled `shared_surfaces` subset of self-hosted | `True` |
| bundled `shared_surface_globs` subset of self-hosted | `True` |

Bundled `shared_surfaces` holds exactly the six planned entries:
`.claude/settings.json`, `config/blast-radius.json`, `config/orchestration-routing.json`,
`package-lock.json`, `poetry.lock`, `quality-tiers.yml`.

Bundled `modules` is exactly `{"config": ["config/**"]}`. The key is retained rather than deleted
because `tests/scripts/dev_tools/test_blast_radius_config.py` calls `load_module_globs` on the
bundled copy, and that helper raises `TypeError` on an absent `modules` key.

These five relations are the conditions the three-class gate added in Phase 6 asserts as tests.
