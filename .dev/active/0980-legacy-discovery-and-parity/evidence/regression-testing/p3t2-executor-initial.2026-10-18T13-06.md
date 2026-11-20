# P3-T2 preliminary executor flow probe

Timestamp: 2026-10-18 13:06:26 UTC
Command: `poetry run python SCRATCH/issue-980-p3t2-probes.py`
EXIT_CODE: 0
Output Summary: The collecting harness exited normally; 0/4 behavioral cases passed. All four stopped at the same draft implementation AttributeError before reaching their assertions.

The current init_flow calls `profile.artifacts.items()`, but the accepted ArtifactRoots value exposes its mapping through `data`. The same unsupported call is present in init_io.bootstrap. The worker was notified before further probes. This is an early runnable-boundary check; it does not represent a final ordered gate or four independent semantic defects.

The four intended cases are nonmutating dry-run, first initialization plus idempotent repeat, the specified default online mode, and honest empty-draft completion failure. Their exact tracebacks and stable source hashes are retained in [the raw probe record](p3t2-executor-initial.2026-10-18T13-06.json). Host-specific paths are replaced by workspace-relative paths and SCRATCH.

Separate source inspection found `required_modes: []` in the new profile template, while the specification's profile contract declares default mode `online`. That discrepancy was reported for correction or an exact contract disposition. No source or policy was changed by the verifier.

Task P3-T2 remains unchecked; 25/84 tasks and 6/66 criteria are accepted. Remaining semantic review will resume after the draft wiring is runnable.
