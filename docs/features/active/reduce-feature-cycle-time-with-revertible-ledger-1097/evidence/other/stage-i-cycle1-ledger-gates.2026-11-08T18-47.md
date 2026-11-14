# Stage I Cycle 1 Ledger Gates (after the citation-test fix)

Timestamp: 2026-11-08T18-47
Command: sh SCRATCH/issue-1097-c1i-ledger.sh and sh SCRATCH/issue-1097-c1i-gates-ef.sh (as in stage-i-cycle1-ledger-gates.2026-11-08T18-34.md), re-run on the head after the second reduction: 0010 commit, which added tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py to 0010 `## Files Changed` and regenerated the patch over 38 paths
EXIT_CODE: 0
Output Summary:
  Reason for the re-run: the P5-T5 gate found test_every_epic_surface_citation_is_shipped failing (a #1129 test reporting the module-form citation of scripts.dev_tools.validate_orchestration_artifacts in the 0010 early-start text). The fix added an ALLOWLIST entry with a reason naming the D9 route, recorded the test in 0010 `## Files Changed` and revert step 5, and regenerated the patch (38 sections; the + and - line multiset equals the P0-T2 patch except the two pin-file digest lines and the 11 citation-test lines).
  (a) Test-ProcessReductionLedger: IsValid True, 0 errors, 10 index rows. PASS
  (b) Invoke-ProcessReductionChain over 10 entries: IsValid True, 0 errors; -StopBefore 0001, 0006, 0008, 0009, 0010: each IsValid True, 0 errors. PASS
  (c) End-state errors 0; 0010 created paths 12, present in FinalText 0. PASS
  (d) Get-ProcessReductionLanding for 0010: first only. PASS
  (e) git apply --cached -R on a scratch index of HEAD: exit 0; the result equals the P3-T1 tree on all 38 patch paths (git diff --quiet exit 0); outside them only the 0010 entry, the patch, cycle evidence files, and the plan differ, all written after P3-T1. PASS
  (f) Entries 0001 to 0009 and their patches changed since the merge commit's first parent: 0 files. PASS
  git apply -R --check of the 0010 patch on the live tree: exit 0; 26 modify-section pre-image ids, 0 missing.
