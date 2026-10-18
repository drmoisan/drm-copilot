# P2-T8 independent parity probes on frozen production bytes

Timestamp: 2026-10-18T10:18:46Z

Command: `poetry run python SCRATCH/issue-980-probe-p2t8.py`

EXIT_CODE: 0

Output Summary: 53 cases passed, zero failed; both production hashes were unchanged throughout the run. Complete case outcomes, prerequisite counts and hashes are retained in `p2t8-executor-probes.2026-10-18T10-18.json`.

The set verifies immutable source pins/hashes, distinct target implementation/test proof, same-pin source-test reuse rejection, configured client/platform/mode coverage, custom modes, required versus optional parity, approved changes and retirements, both duplicate mode representations, and supported Python syntax. All four consolidated regressions pass. Positive controls preserve divided passing implementations and a separately imported historical source. Every semantic input passes authoritative schema validation; intentional broken-reference or checksum negatives explicitly retain their lower-level findings.

Production SHA-256 values:

- `parity_rules.py`: `bdb0be0ba7c06c437aaa815a6dc8ba39b6826818ca3ecabdcca5486dcb26f257`.
- `parity_target_rules.py`: `311b16b0572fb3d5f8eba4ef77ea716f86f278856d2b8069a475c1689d9244e2`.

Snapshots remain unchanged. The prior 53-case run with changing source bytes is retained as non-final evidence. Task checkoff still depends on the specialist's final coverage, staged-file and compatibility audit.
