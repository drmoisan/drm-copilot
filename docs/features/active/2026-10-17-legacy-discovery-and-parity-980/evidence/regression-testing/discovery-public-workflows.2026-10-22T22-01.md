# P11-T1 Discovery public workflows

Timestamp: 2026-10-22T22-01
Task: [P11-T1] Prove the complete source and target public workflows in memory.
Command: poetry run pytest tests/discovery_runtime/test_public_target_workflow.py -q -p no:cacheprovider --no-cov; poetry run pytest tests/discovery_runtime/test_public_combined_workflow.py tests/discovery_runtime/test_public_source_workflow.py -q -p no:cacheprovider --no-cov; node extensions/drm-copilot/run-jest.cjs --rootDir extensions/drm-copilot extensions/drm-copilot/test/discovery-public-workflow.test.ts
EXIT_CODE: 0, 0, 0
Output Summary: pytest 7 passed (target), 24 passed (10 combined, 14 source); Jest 1 suite, 8 tests passed. Every scenario runs the real service rules over the real installed catalog in memory; no temporary file, process or network is used.
Result: PASS

## Behavior verified

- Legacy source path (`test_public_source_workflow.py`): a dry-run initialization plans the profile, locator and artifact roots without writing, the written run creates them, a repeat run changes nothing and never overwrites; the draft workspace validates structurally and is refused by `discovery-complete`, `parity-complete` and `planning` with `validation_result` `fail`; inventory publication captures the configured roots and repeats identically; contract, scenario and evidence operations and the coverage and completion reports never claim verification the rules refused; a confirmed in-scope workspace with evidence completes discovery and admits planning with a stable input digest across modes; malformed, unreferenced, stale-profile and stale-payload inputs never produce a passing gate; usage rejections map to exit 2 and runtime unavailability to exit 3.
- Modernization target path (`test_public_target_workflow.py`): an evidence-backed implementation bound by pinned digest to a required source contract completes `parity-complete` with `validation_result` `pass` and the parity report is planned and then published; a failed or blocked verification is a well-formed matrix that the parity gate rejects (`PARITY_INCOMPLETE`, `fail`) while an absent required classification is refused structurally before any gate runs (`PARITY_DIMENSION`, no gate result); a pinned implementation byte changed after capture invalidates the passing matrix; a second required client without a parity row keeps parity incomplete; generated target acceptance stays a preview with no write.
- Combined path (`test_public_combined_workflow.py`): a source export is imported into a target workspace with exact bytes; a tampered transport is refused through the gateway with exit 3, empty stdout and the "no result was emitted" sentence; a profile without runtime capability completes without runtime claims; multiple clients and optional dimensions configure without inventing results; the five committed request fixtures are accepted by the Python authority and the five committed result fixtures follow the installed `service-result` schema, with the `false-pass` fixture rejected.
- Host transport (`discovery-public-workflow.test.ts`): the TypeScript gateway client builds exactly the committed request documents, maps the committed results to exit 0/1/2/3 with the matching `ok`, refuses a forged pass whose `ok` and `exit_code` disagree, treats an envelope that disagrees with the process exit as a transport error, and returns the fixture result from the launched gateway; the same fixtures are the ones the Python suites validate, so both hosts share one authority.

## Proof

- `tests/discovery_runtime/test_public_source_workflow.py` (7 functions, 14 cases), `tests/discovery_runtime/test_public_target_workflow.py` (5 functions, 7 cases), `tests/discovery_runtime/test_public_combined_workflow.py` (6 functions, 10 cases), `extensions/drm-copilot/test/discovery-public-workflow.test.ts` (8 cases).
- Shared support: `tests/discovery_runtime/public_workflow_test_support.py` (workspace configuration, seeding under the profile roots, dry-run validation) and `tests/discovery_runtime/public_parity_test_support.py` (a schema-complete parity graph composed from the committed v2 examples: confirmed scope, inventory, ledger, capture and target-proof evidence, required contract with explicit applicability, implementation record, parity matrix, every reference pinned by digest).
- Fixtures: `tests/fixtures/discovery_workflow/requests/{validate-discovery-complete,validate-parity-complete,inventory,completion-report,generate-acceptance}.json` and `results/{structural-pass,completion-fail,usage-rejection,runtime-unavailable,false-pass}.json`.

## Gates

- Python: `evidence/qa-gates/p11t1-python-gates.2026-10-22T22-01.md` (Black, Ruff, Pyright clean; 31 tests passed).
- TypeScript: `evidence/qa-gates/p11t1-typescript-gates.2026-10-22T22-01.md` (Prettier, ESLint, tsc clean; 8 tests passed).

## Carried notes

- Each validate-all call rebuilds the schema registry, so the three Python suites take 2 to 21 minutes in this environment; they are correct rather than fast, and the P11-T2 full loop runs them with coverage.
- No production file changed; file sizes: parity support 413 lines, workflow support 237, combined 283, source 310, target 162, TypeScript test 228.
