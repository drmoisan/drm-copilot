# P12-T9 Discovery host workflow

Timestamp: 2026-10-28T13-07
Task: [P12-T9] Prove the host workflow end to end in memory.
Command: poetry run pytest tests/discovery_runtime/test_public_host_workflow.py -x -q --no-cov -p no:randomly; poetry run pytest tests/discovery_runtime/test_public_host_workflow.py tests/discovery_runtime/test_gateway_host.py tests/discovery_runtime/test_gateway_host_main.py tests/discovery_runtime/test_gateway_host_refusals.py tests/discovery_runtime/test_gateway_host_baseline.py -v --no-cov -p no:randomly; node extensions/drm-copilot/run-jest.cjs --rootDir extensions/drm-copilot extensions/drm-copilot/test/discovery-host-workflow.test.ts
EXIT_CODE: 0, 1, 0
Output Summary: pytest 1 passed in 270.30s (end-to-end suite, final run); the combined run of the end-to-end suite with the four gateway-host suites reported 57 passed and 1 failed in 708.48s, the single failure being an assertion of the first draft (`MemoryService.writer_calls == 2`) that the host composition cannot satisfy because `HostServiceIO.writer` issues the guarded writer itself; the assertion was replaced by the observable effect (the new output is in the store and the protected store records zero writes) and the end-to-end suite then passed alone; the four gateway-host suites (57 tests) pass unchanged with the `host_case` extension. Jest 1 suite, 1 test passed in 0.469s. Every scenario runs over memory stores with an injected clock; no file outside the committed tree, process or network is used.
Result: PASS

## Behavior verified

- Python (`tests/discovery_runtime/test_public_host_workflow.py`, one function): a root prepares the baseline through the real `prepare-agent` route over four expected outputs (new contract, question collection, existing contract, stored manifest mirror); a synthetic protected partition holds the started invocation, the start and capability attestations, one consumed one-use authorization per controlled transition and the baseline result; the host principal then performs, through the real service and the real host gateway composition, `read-source` of a selected source (exit 0, one source row), `new-contract` (exit 0, the contract and the question collection published), `update-artifact` of the existing contract from a proposal pinned at preparation (exit 0, exact replacement bytes) and `finalize-agent` (exit 0, `validation_result` pass, null `receipt_ref`, `invocation_ref` equal to the invocation id, `created` rows for the new contract and the manifest mirror, `updated` rows for the question collection and the existing contract); a present but unconsumed authorization is refused with SERVICE_AUTHORITY exit 3; a changed non-output input after preparation is refused with SERVICE_BASELINE exit 3; the protected store records zero writes throughout.
- TypeScript (`extensions/drm-copilot/test/discovery-host-workflow.test.ts`, one case): `prepareDiscoveryInvocation` persists exactly five protected files including `baseline-result.json`; `consumeToolAuthorizationByBinding` consumes the one record bound to the trusted host, session, agent, role, invocation and the raw-input digest, latches it, and refuses the replay with AUTHORIZATION_CONSUMED; `finalizeDiscoveryInvocation` accepts a recorded Python-shaped finalize result (operation, mode, exit code, summary and artifact status taken from the shared vectors) and mints a `validation-receipt` with `validation_result` pass and `output_valid` true that authorizes planning; the second finalization is refused with FINALIZATION_INVOCATION_STATE; `requireCurrentReceipt` accepts the receipt and refuses it with FINALIZATION_RECEIPT_STALE after a source input changes; every write lands inside the invocation partition.
- Shared vectors (`tests/fixtures/discovery_host/host-workflow.json`): identity, skill, authorization references, the ordered Python transitions with exit codes, the Python refusal codes, the host transitions and refusal codes, and the finalize result shape; both suites read the file and assert against it.

## Proof

- `tests/discovery_runtime/test_public_host_workflow.py` (300 lines), `extensions/drm-copilot/test/discovery-host-workflow.test.ts` (294 lines), `tests/fixtures/discovery_host/host-workflow.json` (72 lines).
- `tests/discovery_runtime/gateway_host_test_support.py` (321 lines): `host_case` gains an optional `outputs` parameter; the default rows are unchanged and the P12-T6 suites pass unchanged (57 tests).

## Gates

- Python: black "2 files left unchanged", Ruff "All checks passed!", Pyright "0 errors, 0 warnings, 0 informations" over the two changed test modules after the final edit.
- TypeScript: Prettier (unchanged after the write pass), ESLint clean, `tsc -p tsconfig.jest.json --noEmit` 0 errors over the new suite.

## Carried notes

- Two draft defects were corrected before the clean pass and are recorded here because they shape later work: the snapshot loader recognizes a report-root file by its kind-named stem, so the stored manifest mirror lives at `<reports>/required-output-manifest.json`; and `MemoryService.writer_calls` does not count host publications, so host tests assert store effects rather than the memory service's counter.
- No production file changed in this task. The host end-to-end suite takes about 4.5 minutes without coverage in this environment because each service call rebuilds the capture.
