# P4-T5 COM harness preservation supplement

Timestamp: 2026-10-19T07-30
Command: python SCRATCH/issue-980-p4t5-com-harness-binding.py
EXIT_CODE: 0
Output Summary: Exact executed harness bytes are preserved; no behavioral work was repeated.

The paired JSON adds only the new harness snapshots and this supplement to the existing 41-path freeze manifest. It binds raw SHA-256, published SHA-256, SCRATCH-relative identifiers and newline relationships. Identical committed text snapshots were checked before adding new copies. No snapshot contains a host path, so the raw bytes required no sanitization. The focused-run wrapper, original test-split operation, combined coverage/structure/freeze operation, and this preservation operation are included. The freeze manifest, source/test bytes and all passing receipts remain unchanged.
