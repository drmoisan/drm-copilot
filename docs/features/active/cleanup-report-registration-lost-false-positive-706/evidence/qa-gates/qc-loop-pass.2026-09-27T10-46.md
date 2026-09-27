# QC Loop Clean Pass (P4-T6)

Timestamp: 2026-09-27T10-46
Pass number: 2 (pass 1 was abandoned after CI run 36325350057 failed; its artifacts are kept)

Artifacts of this pass:

1. `evidence/qa-gates/qc-step1-format.2026-09-27T10-45.md` (P4-T1)
2. `evidence/qa-gates/qc-step2-check.2026-09-27T10-45.md` (P4-T2)
3. `evidence/qa-gates/qc-step2b-shellcheck.2026-09-27T10-45.md` (P4-T3)
4. `evidence/qa-gates/qc-step3-syntax.2026-09-27T10-45.md` (P4-T4)
5. `evidence/qa-gates/qc-step4-bats.2026-09-27T10-45.md` (P4-T5)

Command: sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit
EXIT_CODE: 0
Output Summary: helper fee0479ead8204a294eb3c453ba31e0a653c7976a92e13bd88bbb7d25070274f; bats 4c338dec1a0dc61553811ecd3436e069116e044779ac78dad3ccb71bdaed7490; fixture bd5d1f63ee2b8a29c19640ae9004eeaf63dae284dac9a07f2908446bea882398. The helper hash equals the P4-T1 post-pass hash. All five steps passed in pass 2 without changing a file.
