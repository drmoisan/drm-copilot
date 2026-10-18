# P2-T5 final independent semantic probes

Timestamp: 2026-10-18T09-11
Command: poetry run python SCRATCH/issue-980-probe-p2t5.py
EXIT_CODE: 0
Output Summary: 36/36 independent semantic and Python 3.10 grammar probes passed against unchanged final source bytes.

Production SHA-256 before and after: `618289a9f28eaad58a86148e9a3dba2a9513701fb319900657021c9a71a00c65`. The [checks record](p2t5-executor-checks.2026-10-18T09-11.json) contains every expected and observed result. Structural validation uses the authoritative catalog and caches only byte-identical documents within this probe process. No implementation or test file is changed.

The initial historical-conflict counterexample now passes. The target-resolution interaction follows the coordinator-confirmed contract: still-unknown legacy behavior requires an open legacy question; a separate resolved target-policy question does not supply a legacy observation. The explicitly linked split-question positive passes both rule boundaries and preserves its snapshot digest.
