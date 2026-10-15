# P2-T7 Structural checks (AC-7, AC-8)

Timestamp: 2026-10-02T04-07
Command: (1) `grep -rn "^cleanup_wt_is_absolute_path() {" .claude/skills/cleanup-merged-worktrees/scripts`; (2) `grep -rn -F "[A-Za-z]:[" .claude/skills/cleanup-merged-worktrees/scripts`; (3) `grep -rl scan_helper_is_absolute_path .claude/skills/cleanup-merged-worktrees extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees tests/shell`; (4) `grep -c -F "cleanup_wt_is_absolute_path" .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh`; (5) `grep -c -F "cleanup_wt_is_absolute_path" .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh`; (6) `grep -rn load_helper tests`; (7) `grep -c -F "set +u" tests/shell/test_cleanup_worktrees_scan_helper.bats`; (8) `grep -c -F "PS4" tests/shell/test_cleanup_worktrees_scan_helper.bats`; supplementary (DEV-6): `grep -c load_helper tests/shell/test_cleanup_worktrees_scan_helper.bats`
EXIT_CODE: 0
Output Summary:
- (1) GREP value=1 line exit=0: `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh:257:cleanup_wt_is_absolute_path() {`. Exactly one, in the enumeration library. PASS.
- (2) GREP value=2 lines exit=0: `cleanup_worktrees_enumerate_lib.sh:270:	[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]` (shared predicate) and `cleanup_worktrees_preserve_lib.sh:471:		$'[A-Za-z]:[\\\\/]+users[\\\\/]+...'` (host-token regex HT1, a content scan, not a path predicate). Planning-time total 3 lines; the scan-helper and preserve line-161 occurrences are gone. PASS.
- (3) GREP value=none exit=1: no file under the canonical skill, its mirror, or tests/shell names `scan_helper_is_absolute_path`. PASS.
- (4) GREP value=1 exit=0 (preserve library calls the shared predicate). PASS.
- (5) GREP value=1 exit=0 (scan helper calls the shared predicate). PASS.
- (6) GREP value=2 lines exit=0, both in `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` (line 4 comment; line 11 the stub's own inline `load_helper` form). Recorded per DEV-6: this fixture entered BRANCH through the DEV-1 merge (commit 10d71c99, issue #743), is outside the write list, and is not edited. The plan acceptance "prints nothing and exits 1" is not met literally for this pre-existing out-of-scope file; the AC-8 evidence is the scoped count below. Deviation recorded as DEV-6 (existing) and DEV-8 (this segment).
- Supplementary scoped AC-8 check: `grep -c load_helper tests/shell/test_cleanup_worktrees_scan_helper.bats` printed 0, exit 1. PASS.
- (7) GREP value=1 exit=0 (`set +u` once, inside `source_helper`). PASS.
- (8) GREP value=1 exit=0 (PS4 once, in the kcov rationale comment). PASS.
- Task-made-only-of-greps rule: top-level EXIT_CODE is the last plan grep (8), exit 0.
