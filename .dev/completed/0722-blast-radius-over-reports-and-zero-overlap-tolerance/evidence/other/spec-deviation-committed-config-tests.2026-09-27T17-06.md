# Scoped Test Update for the Committed Config (P9-T10)

Timestamp: 2026-09-27T17-06
Output Summary: Two committed-config test helpers were changed so that they also remove the write_intent_extraction and path_roots keys when present. The change is authorized by the spec's Backward-compatibility expectations, exception 2 (and spec decision 10), and is limited to the three tests inventoried by P0-T33. No test body or assertion was changed.

## 1. Edited test paths

- `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py` (helper committed_config; P9-T8)
- `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` (helper load_config; P9-T9)

## 2. Affected test names

- test_derive_without_the_mandate_reads_key_includes_the_citations (mandate-reads module)
- test_derive_blast_radius_keeps_a_cited_csproj_in_paths (mergeable-paths module)
- test_validate_blast_radius_findings_are_identical_with_and_without_the_key (mergeable-paths module)

## 3. Helper change

Each helper parses the committed config exactly as before and then calls
`parsed.pop("write_intent_extraction", None)` and `parsed.pop("path_roots", None)` before returning
it. Its docstring now states that the helper pins current extraction and that write-intent behavior
is covered by the write-intent test module. Every other key of the committed config (including the
amended mandate_reads list and conflict_tolerance) is returned unchanged, so the tests continue to
exercise current extraction against the committed values. The diff over the two files is 19
insertions and 4 deletions, confined to the two helper functions.

## 4. Authorization

Spec, Technical specifications, Backward-compatibility expectations, exception 2: "Tests whose
committed-config helpers pin current-extraction semantics are updated so that those helpers also
remove the two new write-intent keys, write_intent_extraction and path_roots, from the committed
config." The spec's files-to-change list names both test modules for this purpose, and spec
decision 10 records the orchestrator decision. The plan's Preamble section "Scoped test update for
the committed config" restates the authorization.

## 5. Inventory checked against

evidence/baseline/committed-config-consumers.2026-09-27T15-25.md (P0-T33). That artifact classifies
exactly the three tests above as "requires helper update" and every other committed-config consumer
as "unchanged pass". P9-T11 runs the three node IDs of block B44 and P9-T12 runs the full suite; any
failure outside that inventory stops the plan.
