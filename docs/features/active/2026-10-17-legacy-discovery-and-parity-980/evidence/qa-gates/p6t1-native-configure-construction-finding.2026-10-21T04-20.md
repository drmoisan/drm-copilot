# P6-T1 configure construction finding

Timestamp: 2026-10-21T04-20

Command: `WORKSPACE/.venv/Scripts/python.exe -I -S -B SCRATCH/issue-980-p6t1-gateway-configure-finding.py`

EXIT_CODE: 0

Output Summary: The installed local factory rejects the derived external registry path at its canonical-state guard. The specific reason resolution changes that path is unproven.

The retained configure-dry invocation returned exit 3 / SERVICE_FAILURE before service execution. One authorized constructor observation reproduced ValueError at activation_store.py:113, reached from gateway_local.py:392. It entered installed_local_io once; no service import, Git call, write-capable port call, blocked effect, timeout or overflow occurred.

The separately authorized final comparison found that the workspace is absolute and resolves equal. The state path is absolute and external but resolves unequal. The registry leaf is absent; its eight inspected lexical ancestors are ordinary directories without reparse flags. These observations do not prove a particular alias, junction, short-name spelling or environmental change.

The five source/installed bindings remained unchanged around both observations. The original failed invocation did not expose its exception details, so the current constructor result is a bound reproduction of that failure boundary rather than a recovered historical traceback. The earlier format failure and NIO1 root-identity failure remain separate. Installed identity, init-dry and init-real successes are retained; configure and the fourteen later invocations are not accepted.

The composition test test_installed_factory_wires_only_trusted_outer_host_values replaces Path.resolve with identity and replaces ActivationStore.local with a memory-store return. It cannot detect this derived-state/canonical-guard interaction. The low-level canonical/external guard has separate tests and must remain unchanged.

Proposed repair, pending independent contract disposition: canonicalize only trusted platform storage inputs at installed_local_io before RegistryLocation.for_host, retain absolute-input and external-location checks, and keep ActivationStore.local's strict guard. No request-selected path, authority, profile, grant, host marker or operation semantics change is proposed. The observation does not prove which path component differs or that normalizing the platform base alone fixes it; that uncertainty must be resolved by the narrow design and deterministic composition tests, not by weakening the guard.

Candidate source scope is gateway_local.py (403 lines). Update the existing installed-factory memory test in test_gateway_local.py (494 lines) without extending it past 500, and add finite composition controls in test_gateway_boundaries.py (425 lines), subject to the same size gate. Required controls cover a canonical trusted base; a trusted noncanonical spelling resolved before derivation; relative/unsupported, resolution-error and workspace-internal rejection; unchanged host-marker rejection; and preservation of an unsafe derived-state guard failure. All tests use in-memory native seams. Existing direct RegistryLocation platform/partition and ActivationStore.local canonical/external controls are the relevant retained subset.

No source/test/package/fixture/harness/Git/checkpoint changes or tests were performed. Black/Ruff/Pyright/Pytest and coverage are not claimed for this evidence-only diagnosis. Any repair requires its own ordered focused gates and independent confirmation before package rebuild or native continuation.

The JSON companion binds the two observations, exact executed helper/output archives, source hashes and finite seven-file evidence delta. No manifest contains its own hash. Readable files use explicit UTF-8/LF; exact raw bytes remain in the recorded gzip-base64 archives.
