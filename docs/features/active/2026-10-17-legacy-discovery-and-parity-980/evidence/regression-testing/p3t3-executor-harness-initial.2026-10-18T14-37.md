# P3-T3 initial verifier wiring diagnostic

Timestamp: 2026-10-18 14:37:41 UTC
Command: `poetry run python SCRATCH/issue-980-p3t3-initial-probes.py`
EXIT_CODE: 1
Output Summary: All eight candidate probes failed during fixture construction because the newly persisted ActivationStore API requires an explicit open_directory collaborator. No behavioral assertion ran, and no product defect or task pass is inferred. The three source hashes were stable during this invocation.

The SCRATCH harness was prepared against the earlier draft constructor. Correction supplies the existing memory disk's directory-opening seam; it does not change production, tests or the intended probe cases. Full captured output is in the companion JSON.
