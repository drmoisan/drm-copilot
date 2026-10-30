# P2-T2–P2-T4 command receipt normalization

Timestamp: 2026-10-18T09-02
Command: poetry run python SCRATCH/issue-980-normalize-command-receipts-check.py
EXIT_CODE: 0
Output Summary: 62 command blocks verified one-to-one across three unchanged aggregate sources; 51 successful and 11 failed command records preserved; no captured gate was rerun.

The plan requires a separate write-time-stamped artifact for every command step. The earlier aggregate files did not meet that format requirement. Each retained block now has its own receipt, written at 2026-10-18T09-01; its original capture timestamp, Started field, exact command, exit code, output summary and captured output remain explicit. The original aggregate files remain byte-identical.

Verification restored the original Timestamp field and removed only the three added provenance fields, then compared each full block exactly. Inter-block separator blank lines are excluded from this comparison; captured output is preserved exactly. Every output file maps to exactly one source block. This correction changes evidence presentation only. It does not change production code, task status, acceptance criteria or the prior test outcomes.

Machine-readable proof: [normalization checks](p2-command-receipt-normalization-checks.2026-10-18T09-02.json). Extraction index: [source-to-receipt manifest](p2-command-receipt-normalization.2026-10-18T09-01.json). Both include hashes needed to verify the retained source and extracted receipts.

| Task | Source blocks | Individual receipts | Failed records retained |
| --- | ---: | ---: | ---: |
| P2-T2 | 12 | 12 | 1 |
| P2-T3 | 30 | 30 | 6 |
| P2-T4 | 20 | 20 | 4 |

| Original command block | Original capture time | Exit code | Individual receipt |
| --- | --- | ---: | --- |
| p2t2-format-pass2 | 2026-10-18T08-12 | 0 | [receipt](p2t2-format-pass2.2026-10-18T09-01.md) |
| p2t2-lint-pass2 | 2026-10-18T08-12 | 0 | [receipt](p2t2-lint-pass2.2026-10-18T09-01.md) |
| p2t2-types-pass2 | 2026-10-18T08-12 | 1 | [receipt](p2t2-types-pass2.2026-10-18T09-01.md) |
| p2t2-format-pass3 | 2026-10-18T08-13 | 0 | [receipt](p2t2-format-pass3.2026-10-18T09-01.md) |
| p2t2-lint-pass3 | 2026-10-18T08-13 | 0 | [receipt](p2t2-lint-pass3.2026-10-18T09-01.md) |
| p2t2-types-pass3 | 2026-10-18T08-13 | 0 | [receipt](p2t2-types-pass3.2026-10-18T09-01.md) |
| p2t2-tests-pass3 | 2026-10-18T08-13 | 0 | [receipt](p2t2-tests-pass3.2026-10-18T09-01.md) |
| p2t2-isolation-pass3 | 2026-10-18T08-14 | 0 | [receipt](p2t2-isolation-pass3.2026-10-18T09-01.md) |
| p2t2-quality-tiers | 2026-10-18T08-14 | 0 | [receipt](p2t2-quality-tiers.2026-10-18T09-01.md) |
| p2t2-resource-contract | 2026-10-18T08-14 | 0 | [receipt](p2t2-resource-contract.2026-10-18T09-01.md) |
| p2t2-static-audit | 2026-10-18T08-15 | 0 | [receipt](p2t2-static-audit.2026-10-18T09-01.md) |
| p2t2-task-audit | 2026-10-18T08-15 | 0 | [receipt](p2t2-task-audit.2026-10-18T09-01.md) |
| p2t3-format-pass1 | 2026-10-18T08-27 | 0 | [receipt](p2t3-format-pass1.2026-10-18T09-01.md) |
| p2t3-lint-pass1 | 2026-10-18T08-27 | 1 | [receipt](p2t3-lint-pass1.2026-10-18T09-01.md) |
| p2t3-format-pass2 | 2026-10-18T08-28 | 0 | [receipt](p2t3-format-pass2.2026-10-18T09-01.md) |
| p2t3-format-pass3 | 2026-10-18T08-28 | 0 | [receipt](p2t3-format-pass3.2026-10-18T09-01.md) |
| p2t3-lint-pass3 | 2026-10-18T08-28 | 1 | [receipt](p2t3-lint-pass3.2026-10-18T09-01.md) |
| p2t3-format-pass4 | 2026-10-18T08-29 | 0 | [receipt](p2t3-format-pass4.2026-10-18T09-01.md) |
| p2t3-lint-pass4 | 2026-10-18T08-29 | 0 | [receipt](p2t3-lint-pass4.2026-10-18T09-01.md) |
| p2t3-types-pass4 | 2026-10-18T08-29 | 1 | [receipt](p2t3-types-pass4.2026-10-18T09-01.md) |
| p2t3-format-pass5 | 2026-10-18T08-29 | 0 | [receipt](p2t3-format-pass5.2026-10-18T09-01.md) |
| p2t3-lint-pass5 | 2026-10-18T08-29 | 0 | [receipt](p2t3-lint-pass5.2026-10-18T09-01.md) |
| p2t3-types-pass5 | 2026-10-18T08-29 | 0 | [receipt](p2t3-types-pass5.2026-10-18T09-01.md) |
| p2t3-tests-pass5 | 2026-10-18T08-30 | 1 | [receipt](p2t3-tests-pass5.2026-10-18T09-01.md) |
| p2t3-format-pass6 | 2026-10-18T08-30 | 0 | [receipt](p2t3-format-pass6.2026-10-18T09-01.md) |
| p2t3-lint-pass6 | 2026-10-18T08-30 | 0 | [receipt](p2t3-lint-pass6.2026-10-18T09-01.md) |
| p2t3-types-pass6 | 2026-10-18T08-31 | 0 | [receipt](p2t3-types-pass6.2026-10-18T09-01.md) |
| p2t3-tests-pass6 | 2026-10-18T08-31 | 0 | [receipt](p2t3-tests-pass6.2026-10-18T09-01.md) |
| p2t3-static-pass6 | 2026-10-18T08-31 | 0 | [receipt](p2t3-static-pass6.2026-10-18T09-01.md) |
| p2t3-isolation-pass6 | 2026-10-18T08-31 | 0 | [receipt](p2t3-isolation-pass6.2026-10-18T09-01.md) |
| p2t3-quality-tiers-pass6 | 2026-10-18T08-32 | 0 | [receipt](p2t3-quality-tiers-pass6.2026-10-18T09-01.md) |
| p2t3-package-contract-pass6 | 2026-10-18T08-32 | 0 | [receipt](p2t3-package-contract-pass6.2026-10-18T09-01.md) |
| p2t3-audit-pass6 | 2026-10-18T08-32 | 1 | [receipt](p2t3-audit-pass6.2026-10-18T09-01.md) |
| p2t3-format-pass7 | 2026-10-18T08-33 | 1 | [receipt](p2t3-format-pass7.2026-10-18T09-01.md) |
| p2t3-format-correction7 | 2026-10-18T08-34 | 0 | [receipt](p2t3-format-correction7.2026-10-18T09-01.md) |
| p2t3-format-pass8 | 2026-10-18T08-34 | 0 | [receipt](p2t3-format-pass8.2026-10-18T09-01.md) |
| p2t3-lint-pass8 | 2026-10-18T08-34 | 0 | [receipt](p2t3-lint-pass8.2026-10-18T09-01.md) |
| p2t3-types-pass8 | 2026-10-18T08-34 | 0 | [receipt](p2t3-types-pass8.2026-10-18T09-01.md) |
| p2t3-tests-pass8 | 2026-10-18T08-34 | 0 | [receipt](p2t3-tests-pass8.2026-10-18T09-01.md) |
| p2t3-static-pass8 | 2026-10-18T08-35 | 0 | [receipt](p2t3-static-pass8.2026-10-18T09-01.md) |
| p2t3-isolation-pass8 | 2026-10-18T08-35 | 0 | [receipt](p2t3-isolation-pass8.2026-10-18T09-01.md) |
| p2t3-audit-pass8 | 2026-10-18T08-35 | 0 | [receipt](p2t3-audit-pass8.2026-10-18T09-01.md) |
| p2t4-format-pass1 | 2026-10-18T08-44 | 0 | [receipt](p2t4-format-pass1.2026-10-18T09-01.md) |
| p2t4-lint-pass1 | 2026-10-18T08-44 | 0 | [receipt](p2t4-lint-pass1.2026-10-18T09-01.md) |
| p2t4-types-pass1 | 2026-10-18T08-44 | 1 | [receipt](p2t4-types-pass1.2026-10-18T09-01.md) |
| p2t4-format-pass2 | 2026-10-18T08-49 | 0 | [receipt](p2t4-format-pass2.2026-10-18T09-01.md) |
| p2t4-lint-pass2 | 2026-10-18T08-49 | 1 | [receipt](p2t4-lint-pass2.2026-10-18T09-01.md) |
| p2t4-format-pass3 | 2026-10-18T08-49 | 0 | [receipt](p2t4-format-pass3.2026-10-18T09-01.md) |
| p2t4-lint-pass3 | 2026-10-18T08-49 | 0 | [receipt](p2t4-lint-pass3.2026-10-18T09-01.md) |
| p2t4-types-pass3 | 2026-10-18T08-49 | 1 | [receipt](p2t4-types-pass3.2026-10-18T09-01.md) |
| p2t4-format-pass4 | 2026-10-18T08-49 | 0 | [receipt](p2t4-format-pass4.2026-10-18T09-01.md) |
| p2t4-lint-pass4 | 2026-10-18T08-50 | 0 | [receipt](p2t4-lint-pass4.2026-10-18T09-01.md) |
| p2t4-types-pass4 | 2026-10-18T08-50 | 1 | [receipt](p2t4-types-pass4.2026-10-18T09-01.md) |
| p2t4-format-pass5 | 2026-10-18T08-50 | 0 | [receipt](p2t4-format-pass5.2026-10-18T09-01.md) |
| p2t4-lint-pass5 | 2026-10-18T08-50 | 0 | [receipt](p2t4-lint-pass5.2026-10-18T09-01.md) |
| p2t4-types-pass5 | 2026-10-18T08-50 | 0 | [receipt](p2t4-types-pass5.2026-10-18T09-01.md) |
| p2t4-tests-pass5 | 2026-10-18T08-50 | 0 | [receipt](p2t4-tests-pass5.2026-10-18T09-01.md) |
| p2t4-static-pass5 | 2026-10-18T08-54 | 0 | [receipt](p2t4-static-pass5.2026-10-18T09-01.md) |
| p2t4-isolation-pass5 | 2026-10-18T08-54 | 0 | [receipt](p2t4-isolation-pass5.2026-10-18T09-01.md) |
| p2t4-quality-tiers-pass5 | 2026-10-18T08-54 | 0 | [receipt](p2t4-quality-tiers-pass5.2026-10-18T09-01.md) |
| p2t4-packaging-pass5 | 2026-10-18T08-54 | 0 | [receipt](p2t4-packaging-pass5.2026-10-18T09-01.md) |
| p2t4-audit-pass5 | 2026-10-18T08-54 | 0 | [receipt](p2t4-audit-pass5.2026-10-18T09-01.md) |
