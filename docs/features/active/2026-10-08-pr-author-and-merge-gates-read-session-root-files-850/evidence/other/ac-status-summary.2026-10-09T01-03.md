# P8-T21 Acceptance-criteria status summary (issue #850)

Timestamp: 2026-10-09T01-03
Command: sh SCRATCH/run-ps.sh SCRATCH/checkbox-count.ps1 -Path docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md -FromLine 204 -Line 210,211,212,213,214,215,216,217,218,219,220,221,222,223,227,228,229,230,231,232,233,234,235,236,237,241,242,243,244,248,249,253,254,255,259,260,261,262,266,267,268,269,273,274,275,276,277
EXIT_CODE: 0
Output Summary:
  CHECKBOX checked=47 unchecked=0
  47 LINE lines, each state=checked
  Source: FEATURE/spec.md (full-bug; sole AC source). Total 47; checked 47; remaining 0.

Evidence paths are relative to FEATURE.

| AC | Spec line | State | Verifying test (suite) | Evidence |
| --- | --- | --- | --- | --- |
| AC-01 | 210 | checked | allows an OtherWorktree target whose artifacts exist only in the item worktree (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-02 | 211 | checked | ignores session-root PR artifacts when the target is another worktree (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-03 | 212 | checked | reads summary, body, receipt and summary timestamp beneath the resolved item root (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-04 | 213 | checked | compares receipt freshness against the item worktree summary (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-05 | 214 | checked | resolves the target once and reuses it for artifacts, preflight and Check 6 (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-06 | 215 | checked | denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-07 | 216 | checked | denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-08 | 217 | checked | denies a relative body path for an OtherWorktree target and names the absolute path (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-09 | 218 | checked | denies an absolute body path outside the resolved root (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-10 | 219 | checked | applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-11 | 220 | checked | keeps SessionRoot behavior with absolute artifact paths (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-12 | 221 | checked | reads epic-scope PR artifacts beneath the epic checkpoint worktree (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-13 | 222 | checked | performs no resolution for commands without a body file (T-PRA-IAR) | evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md |
| AC-14 | 223 | checked | SET-PRA existing pr-author suites and OrchestratorState.Tests.ps1 | evidence/qa-gates/pester-set-pra-p6.2026-10-09T00-38.md |
| AC-15 | 227 | checked | resolves the worktree whose pr_gate records the pull request number (T-WIR-PR) | evidence/regression-testing/wir-prnumber-pass-after.2026-10-09T00-12.md |
| AC-16 | 228 | checked | resolves the worktree whose standalone authorization records the pull request number (T-WIR-PR) | evidence/regression-testing/wir-prnumber-pass-after.2026-10-09T00-12.md |
| AC-17 | 229 | checked | returns NoTarget when no checkpoint records the number; returns Ambiguous when several checkpoints record the number (T-WIR-PR) | evidence/regression-testing/wir-prnumber-pass-after.2026-10-09T00-12.md |
| AC-18 | 230 | checked | reads only through the checkpoint-text seam; exports the item-by-PR resolver (T-WIR-PR) | evidence/regression-testing/wir-prnumber-pass-after.2026-10-09T00-12.md |
| AC-19 | 231 | checked | authorizes a standalone merge from the item worktree checkpoint (T-MRG-IR) | evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-20 | 232 | checked | does not authorize from a session-root copy of another worktree's checkpoint (T-MRG-IR) | evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-21 | 233 | checked | denies an unresolvable item target with the no-target code (T-MRG-IR) | evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-22 | 234 | checked | denies an ambiguous item target with the ambiguity code (T-MRG-IR) | evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-23 | 235 | checked | observes module-scoped WorktreeItemResolution mocks (T-MRG-IR) | evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-24 | 236 | checked | M6 (merge WorktreeResolution suite); does not resolve an item target for a bare merge command (T-MRG-IR) | evidence/regression-testing/merge-worktree-resolution-p5.2026-10-09T00-22.md; evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-25 | 237 | checked | SET-MRG existing merge-gate suites | evidence/qa-gates/pester-set-mrg-p5.2026-10-09T00-23.md |
| AC-26 | 241 | checked | M5 (merge WorktreeResolution suite); denies a merge when no checkpoint records the pull request number (T-MRG-IR) | evidence/regression-testing/merge-worktree-resolution-p5.2026-10-09T00-22.md; evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-27 | 242 | checked | denies a merge whose pull request number differs from pr_gate (T-MRG-IR) | evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-28 | 243 | checked | context "child checkpoint pull request binding" (T-MRG-IR) | evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-29 | 244 | checked | re-checks the binding on the checkpoint the gate reads (T-MRG-IR) | evidence/regression-testing/merge-item-pass-after.2026-10-09T00-22.md |
| AC-30 | 248 | checked | B14 compares UNC paths case-insensitively (Record suite) | evidence/regression-testing/cr4-pass-after.2026-10-08T23-55.md |
| AC-31 | 249 | checked | B11, B12, X1 (Record suite) | evidence/regression-testing/cr4-pass-after.2026-10-08T23-55.md |
| AC-32 | 253 | checked | Y7 emits a single leading token when both run kinds are unresolved (parallel WorktreeResolution suite) | evidence/regression-testing/cr5-parallel-pass-after.2026-10-08T23-59.md |
| AC-33 | 254 | checked | exact-text row of enforce-parallel-worktree-removal-gate.Tests.ps1 and Y3, both unmodified | evidence/qa-gates/pester-set-rem-p2.2026-10-08T23-59.md; evidence/qa-gates/cr5-parallel-unchanged-rows.2026-10-09T00-00.md |
| AC-34 | 255 | checked | emits a single leading token when both run kinds are unresolved (T-EREM-DX) | evidence/regression-testing/erem-diagnostics-pass-after.2026-10-09T00-06.md |
| AC-35 | 259 | checked | names each run kind's status and checkpoint path (T-EREM-DX) | evidence/regression-testing/erem-diagnostics-pass-after.2026-10-09T00-06.md |
| AC-36 | 260 | checked | names the matched record merge_status; states that no record matched; states that the checkpoint was absent or unparseable (T-EREM-DX) | evidence/regression-testing/erem-diagnostics-pass-after.2026-10-09T00-06.md |
| AC-37 | 261 | checked | context "diagnostics builder and read result" (T-EREM-DX) | evidence/regression-testing/erem-diagnostics-pass-after.2026-10-09T00-06.md |
| AC-38 | 262 | checked | existing removal suites and CleanupWorktreeManifestGateMatrix.Tests.ps1 pass; exact-text row only appended | evidence/qa-gates/pester-set-rem-p3.2026-10-09T00-06.md; evidence/qa-gates/erem-decision-unchanged.2026-10-09T00-07.md |
| AC-39 | 266 | checked | test_bundled_claude_payload_contains_all_repo_runtime_contracts (KL-510) plus A10 MP-ALL | evidence/qa-gates/python-parity.2026-10-09T01-01.md; evidence/qa-gates/mirror-hashes-final.2026-10-09T01-01.md |
| AC-40 | 267 | checked | test_push_down_claude_pack_manifest_completeness.py | evidence/qa-gates/python-parity.2026-10-09T01-01.md |
| AC-41 | 268 | checked | WorktreeResolution.Manifest.Tests.ps1 | evidence/qa-gates/pester-claude-lib.2026-10-09T00-56.md |
| AC-42 | 269 | checked | test_push_down_codex_and_agents_resource_contracts.py plus scope check | evidence/qa-gates/python-parity.2026-10-09T01-01.md; evidence/qa-gates/scope-checks.2026-10-09T01-01.md |
| AC-43 | 273 | checked | enforcement-hooks-no-python-invocation.Tests.ps1 | evidence/qa-gates/pester-claude-runtime.2026-10-09T00-57.md |
| AC-44 | 274 | checked | keeps every changed file within the line cap (T-CONS) | evidence/qa-gates/constraints-850.2026-10-09T00-41.md |
| AC-45 | 275 | checked | uses no temporary files and no host paths (T-CONS) plus the added-lines scan | evidence/qa-gates/constraints-850.2026-10-09T00-41.md; evidence/qa-gates/added-lines-scan.2026-10-09T01-00.md |
| AC-46 | 276 | checked | Pester coverage runs CG-PRA, CG-MRG, CG-EREM, CG-PREM, CG-LIB | evidence/qa-gates/coverage-comparison.2026-10-09T01-02.md |
| AC-47 | 277 | checked | enforce-gate-suites.EpicStateIsolation.Tests.ps1 | evidence/qa-gates/epic-state-isolation-p6.2026-10-09T00-38.md |
