# [P0-T2] Dependency on 1020 verification — addendum under plan version 1.2 (issue #1022)

Timestamp: 2026-11-03T22-40
Command: none (documentary addendum; the 43 checks of `dependency-1020.2026-11-03T21-45.md` are not re-run, per the plan's "Resolution in version 1.2" sub-bullet of [P0-T2])
EXIT_CODE: 0
Output Summary: The one MISMATCH item recorded on 2026-11-03T22-00 (diagnostic code grammar) is resolved by decision D-1022-exec-1: plan version 1.2 and spec version 0.4 conform every 1022 diagnostic code to the merged 1020 grammar `^[A-Z][A-Z0-9_]*$`. No 1020 file is edited. PASS=43 MISMATCH=0 RESOLVED=1.

## Relation to the earlier artifact

- `FEATURE/evidence/other/dependency-1020.2026-11-03T21-45.md` records the 43 PASS items, the six recorded values (`ANCHOR_LABEL`, `METHOD_FIELD`, `ENVELOPE_ROUTE`, `CAPTURE_CODES`, `DIGEST_RULE`, `CORE_TAIL`), the `MERGE_BASE` derivation, and the additional MISMATCH item found while verifying `New-DocsDiagnostic`. Its 43 PASS lines stand unchanged (`grep -c '^PASS |'` over that file returns 43; the file has no uncommitted change against `HEAD`).
- This addendum is written as a new `dependency-1020.<timestamp>.md` so that the lexicographically greatest match carries the resolved state; the earlier file is not rewritten.

## Resolution

```
RESOLVED | Diagnostic code grammar consumed by every 1022 diagnostic | Plan version 1.2 (`plan.2026-10-30T16-46.md`, execution-stage design revision under decision D-1022-exec-1) and spec version 0.4 (`spec.md` `## Revision Note`, `## Precision Limit` Common rules, `### Execution-stage decision D-1022-exec-1 (binding)`) rewrite every 1022 diagnostic code to the merged 1020 grammar ^[A-Z][A-Z0-9_]*$ that `New-DocsDiagnostic` ($script:DocsSurfaceCodePattern in LIB/DocsSurface.psm1) and `schemas/docs/v1/common.schema.json` $defs/diagnostic.code enforce. The 32 codes of CORPUS_CODES, the inventory-level codes DECLARATION_INVALID and DUPLICATE_DECLARATION, the config-files codes, PYTHON_TOKEN_LIMIT, ARCHITECTURE_EDGE_LIMIT, CONFIG_KEY_LIMIT and ENV_FILE_NOT_CAPTURED are all uppercase. Analyzer identifiers, analyzer_id values, element kinds, element ids, property names and command names keep the identifier grammar. No 1020 file is edited.
SUMMARY | PASS=43 MISMATCH=0 RESOLVED=1
```

- Plan version: `1.2`
- Spec version: `0.4`
- Decision: `D-1022-exec-1` (spec `### Execution-stage decision D-1022-exec-1 (binding)`; plan `## Execution Context`, "Diagnostic code grammar" bullet)

## Consequence for execution

[P0-T2] is checked. The six recorded values and `## Notes for later tasks` of the earlier artifact remain the values later tasks consume. Spec AC S25 (Phase 0 evidence records the verification of every item of `## Dependency on 1020` before any 1022 production file is created) is satisfied: no file under `LIB` other than the 1020 files exists at this timestamp (`ls .claude/lib/docs` lists the nine 1020 files and `schemas/`).
