# Pre-push review: Phase 2

Timestamp: 2026-11-24T09-03
Scope: the working-tree diff of Phase 2 against HEAD (child-CI helper in four copies, both merge gates and their bundle copies, completion helpers in four copies, both completion-consistency hooks and their bundle copies, the two new merge-gate suites, the extended completion suites, the ledger entry, plan check-offs, AC check-offs, and evidence).

Pre-mortem walk:

- Review checklists: PASS. The helper header, both gate headers, and the ledger entry state that `child_ci` is self-declared by the item checkpoint and bounded by the live base, the concurrent review, and the evidence file; the rule section follows in P3-T4.
- Coverage: PASS. Every stage, variant, and default row of table T is covered in both suites; in the gate selection the Claude child-CI helper measured 100% and the Codex copy 98.73%; the completion helpers 100% (Codex copy) and the completion-consistency hooks 96.27% (Claude) and 85.98% (Codex) on the selection alone; the full-run figures are compared in P5-T7.
- Mirror parity: PASS. cross-tree-helper-identity.Tests.ps1 and the push-down resource, pack-manifest, and dependency-closure contracts passed; every bundle copy was produced by cp and verified by cmp.
- File size: PASS. Child-CI helper 581 lines, Claude gate 501, Codex gate 450, completion helpers 344, Claude completion hook 509, Codex completion hook 500 (the legacy 500-line pin holds); FileSizePolicy.RepoGate passed.
- Test isolation: PASS. The new suites mock Invoke-DocsOnlyGhExe, Invoke-DocsOnlyGitExe, and the checkpoint read seams by name, read per-row values through script-scope variables, create no file, and the leak scan reports 0 failures.
- CI-only behavior: PASS. The merge-gate and completion suites live under tests/scripts/claude-hooks and tests/scripts/codex-hooks, which the Linux hook job runs: their roots are synthetic forward-slash paths built with Join-Path, the checkpoint texts use forward-slash relative paths, and no drive letter or backslash path literal is used (the backslash rows are evidence_path values the helper must reject).
- Evidence: PASS. Every evidence file is new and clock-stamped; the 32/31 deny-row count error of an earlier task-check is corrected in later files rather than by editing it.

Self-review notes: no new dot-source in any hook; the Codex gate call is unchanged; the pre-change deny texts are asserted byte-for-byte in the default rows; the commit subject carries `reduction: 0014`.
