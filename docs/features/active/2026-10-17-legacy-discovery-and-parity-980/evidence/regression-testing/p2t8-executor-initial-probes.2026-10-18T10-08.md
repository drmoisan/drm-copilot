# P2-T8 initial independent parity probes

Timestamp: 2026-10-18T10:08:21Z

Command: `poetry run python SCRATCH/issue-980-probe-p2t8.py`

EXIT_CODE: 1

Output Summary: 42 cases passed and three fixture/setup expectations failed; both production hashes remained stable. Exact results and hashes are retained in `p2t8-executor-initial-probes.2026-10-18T10-08.json`.

The wrong-scope change was correctly rejected by parity but its fixture also selected an unconfigured decision client. Two retirement fixtures removed resulting acceptance criteria, which the approved-decision schema requires. These are operational probe fixture corrections, not established production defects. The corrected probe will preserve an approved decision's criteria and use a configured alternate client for the wrong-scope case. No production source was changed by the executor and no task acceptance is claimed.
