# P6-T34 Commit-Steward Scope, Coverage, Evidence, and Acceptance Gate

Timestamp: `2026-08-11T22-39-04:00`

Command: independent LCOV manifest/fingerprint/numeric comparator; correction-owner size/dependency/suppression scan; P0-T7 `.claude/` SHA-256 comparator; `poetry run python scripts/dev_tools/validate_evidence_locations.py --root docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`; receipt/snapshot/ledger comparators; 58-row acceptance-mapping reconciliation; `git diff --check`

EXIT_CODE: `0`

Output Summary: Scope, coverage, evidence, protected-source, and acceptance gates passed. The complete LCOV set is exact at `206/206`; all `33` correction owners are within the `500`-line limit; dependency, suppression, temporary-path, evidence-location, `.claude/`, state, and diff violations are zero; and the requirements remain exactly `55 PASS / 3 hosted-CI DEFERRED / 0 contradictory`.

## LCOV integrity

- Regenerated path set: `206/206`; set mismatches `0`.
- Text/binary partition: `204 / 2`; overlap or omission `0`.
- Exact binary paths: `lcov-report/favicon.png` and `lcov-report/sort-arrow-sprite.png`.
- Text normalization subset: `198/198`.
- Text non-whitespace fingerprints: `204/204` equal to both recorded values.
- Text byte-size mismatches, trailing whitespace, redundant EOF blank lines, and missing terminal newlines: `0 / 0 / 0 / 0`.
- PNG raw-byte/SHA mismatches: `0/2`.
- LCOV SHA-256: `A991DE4232ABD394A08925E68BB37D6F4FA7A3FA678FCF1FE9EDB59477BA223B`.

## Numeric coverage

| Language | Lines | Branches or supported secondary metric | Changed/new result |
| --- | --- | --- | --- |
| TypeScript | `44,076/45,740` (`96.36%`) | `6,562/7,326` branches (`89.57%`); `1,304/1,434` functions (`90.93%`) | `3,179/3,393` lines (`93.6929%`), no regression |
| Python | `14,290/15,505` (`92.1638%`) | `4,866/5,776` branches (`84.2452%`) | correction owners `98.8889%` and `90.6250%` lines; no changed executable-line regression |
| PowerShell | `4,040/4,260` (`94.84%`) | `336/363` methods (`92.56%`) | `25/27` instrumented changed/new lines (`92.59%`) |

Every measurable repository and new/changed owner value remains above the plan's `85%` line, `75%` branch, and `90%` new-logic floors.

## Scope and policy

- Correction owners from P6-T24 through P6-T33: `33`; missing `0`.
- Largest correction owner: `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` at `497` lines.
- Correction owners above `500` lines: `0`.
- Dependency or lockfile deltas: `0`.
- New source suppression additions: `0`.
- Temporary correction paths: `0`.
- `.codex/state`: absent.
- `testResults.xml`: baseline-clean.
- `git diff --check`: exit `0`.

## Evidence and protected sources

- Canonical evidence-location validator: exit `0`; violations `0`.
- Commit-steward receipts present before this receipt set: `19/19` schema-complete; P6-T34 adds five schema-complete receipts.
- Translation source/snapshot pairs and deterministic diff rows: `25/25`; stale rows `0`.
- Translation ledger: `16 PRESERVED / 2 tested DEGRADED / 0 LOST`.
- `.claude/`: baseline/current/matched `150/150/150`; missing `0`, added `0`, mismatched `0`, status `0`, diff `0`; canonical manifest SHA-256 `34FE91AA14F9622BF4B9BF10E87BE787B95E992FFD69DFE09728937A779AA07C`.

## Acceptance reconciliation

- Mapping rows: `58/58`.
- Results: `55 PASS / 3 DEFERRED / 0 contradictory`.
- Issue: `14/15`; spec: `21/22`; user story: `20/21`.
- The same three exact-current-head hosted-CI criteria remain unchecked and assigned to the post-P6-T36 boundary. Criterion text, order, and checkbox state changed: `0`.

Result: `PASS`.
