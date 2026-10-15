# Spec Change Log Amendment ([P1-T1])

Timestamp: 2026-10-09T22-28
Command: git rev-parse HEAD (PRE_AMEND_SHA); edits of spec.md lines 238 and 239 and the appended Change Log block (section 2.7, verbatim); git diff -U0 HEAD -- docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md; git status --porcelain -- docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md; Select-String observations (<SCRATCHPAD>/p1t1.ps1)
EXIT_CODE: 0
Output Summary: the diff holds exactly two hunks (@@ -238,2 +238,2 @@ and @@ -270,0 +271,10 @@); one `## Change Log` heading; one operator-decision line; the only match of HookImportFailureExemptions.Helpers.ps1 is on line 238; PrdFeatureFolderResolutionImportFailure matches on line 239 (and line 276 inside the Change Log); 27 AC lines at 228 to 254; line 244 (AC-17) equals line 244 at PRE_AMEND_SHA.

PRE_AMEND_SHA: 1b3877edb6dc3b3bbb9a442305f5db2343337224

Output:

```text
PRE_AMEND_SHA: 1b3877edb6dc3b3bbb9a442305f5db2343337224
## git diff -U0 HEAD -- spec.md
diff --git a/docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md b/docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
index 4da583804..108620bae 100644
--- a/docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
+++ b/docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
@@ -238,2 +238,2 @@ try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookD
-- [ ] AC-11: A structural completeness test discovers hooks from `.claude/settings.json` and `.codex/config.toml` (no fixed hook list), walks the transitive closure with the AST on repository and mirror roots, and fails when an edge is unguarded and uncovered, when a runtime edge is not pre-loaded under a guard, or when a hook lacks the bootstrap or tail check; the only exemptions are named in the test with their justification (D2, D3 absence path); here-string fixtures prove each failure condition is reported.
-- [ ] AC-12: No `$script:<Name>ImportFailure` variable and no `Import guard (issue #690)` comment remains under `.claude/hooks` or its bundle mirror; the updated `*.WorktreeResolution.Tests.ps1` suites pass; the `enforce-epic-merge-gate-resolution.ps1` dependency-failure path calls no function from `enforce-epic-merge-gate-authorization.ps1`, verified by a test that fails the authorization dot-source and still receives a deny.
+- [ ] AC-11: A structural completeness test discovers hooks from `.claude/settings.json` and `.codex/config.toml` (no fixed hook list), walks the transitive closure with the AST on repository and mirror roots, and fails when an edge is unguarded and uncovered, when a runtime edge is not pre-loaded under a guard, or when a hook lacks the bootstrap or tail check; the only exemptions are named, each with its justification, in the exemption list the test consumes (`tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`): D2, the D3 absence path, and the named handler exemptions of the 2026-10-09 Change Log entry that passed their fail-closed proof; here-string fixtures prove each failure condition is reported.
+- [ ] AC-12: No `$script:<Name>ImportFailure` variable and no `Import guard (issue #690)` comment remains under `.claude/hooks` or its bundle mirror, except the scoped failure variables of the named handler exemptions in the 2026-10-09 Change Log entry (`$script:FeatureFolderOrderResolutionImportFailure`, `$script:OrchestrationFeatureFolderResolutionImportFailure`, `$script:PrdFeatureFolderResolutionImportFailure`, `$script:EpicWaveBarrierResolutionImportFailure`, `$script:ParallelDriftGateResolutionImportFailure`, `$script:ParallelCohortBarrierResolutionImportFailure`, `$script:OrchestratorOutputResolverImportFailure`, `$script:OrchestratorOutputWaveBarrierImportFailure`), each permitted only while its handler is a named exemption with a recorded fail-closed proof; the updated `*.WorktreeResolution.Tests.ps1` suites pass; the `enforce-epic-merge-gate-resolution.ps1` dependency-failure path calls no function from `enforce-epic-merge-gate-authorization.ps1`, verified by a test that fails the authorization dot-source and still receives a deny.
@@ -270,0 +271,10 @@ try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookD
+
+## Change Log
+
+- 2026-10-09 — operator decision (option 1, named exemptions)
+  - Decision: the scoped import-failure handlers that issues #565, #787, #840, and #850 added are kept, with their deny codes, as named exemptions in addition to D2 and the D3 absence path, subject to the fail-closed condition below. Issue #850 added no separately scoped handler: its `WorktreeItemResolution.psm1` guard in `enforce-epic-merge-gate-resolution.ps1` records into the #690 variable `$script:EpicMergeGateResolutionImportFailure` and denies through the #690 decision function, so it is migrated with that #690 copy.
+  - Named handler exemption candidates: H1 `$script:FeatureFolderOrderResolutionImportFailure` (#565, `FEATURE_FOLDER_ORDER_BLOCKED:`); H2 `$script:OrchestrationFeatureFolderResolutionImportFailure` (#565, readiness failure `feature-folder-resolution-import`, Claude and Codex surfaces); H3 `$script:PrdFeatureFolderResolutionImportFailure` (#565, `PRD_FEATURE_BLOCKED:`); H4 `$script:EpicWaveBarrierResolutionImportFailure` (#565, `EPIC_WAVE_BARRIER_BLOCKED:`); H5 `$script:ParallelDriftGateResolutionImportFailure` (#565, `PARALLEL_DRIFT_GATE_BLOCKED:`); H6 `$script:ParallelCohortBarrierResolutionImportFailure` (#565, `PARALLEL_COHORT_BARRIER_BLOCKED:`); H7 `$script:OrchestratorOutputResolverImportFailure` (#787, `RESOLVER_IMPORT_FAILED`); H8 `$script:OrchestratorOutputWaveBarrierImportFailure` (#840, `EPIC_WAVE_BARRIER_UNEVALUABLE:`).
+  - Fail-closed condition: a handler is exempted only after a recorded proof (a Pester test that forces its import or dot-source to fail, or a cited code path) shows that when its dependency fails to load it denies or blocks and never allows. For a PreToolUse hook, blocking is a deny decision; for a SubagentStop hook, blocking is exit code 2 (D1), and a block that reaches the process only through `Write-Error` followed by `exit 1` is not blocking.
+  - Conversion rule: a handler whose proof shows fail-open behaviour is converted to the uniform helper-based deny of this specification; the affected test assertions are updated, and each changed assertion is recorded with its reason for the pull request body and the feature audit. For such a handler only, this decision takes precedence over AC-17.
+  - Feature-folder-order rule (BF-1): if the resolver failure causes `enforce-feature-folder-order.ps1` to skip a check that it performs for a write when the resolver loads, the hook fails open for that write and is converted, with the assertion of test F18 changed and the reason recorded; if non-plan writes are never subject to a resolver-dependent check, the allow of a non-plan write while the resolver cannot load is not an allow on import failure, and the handler is exempted with that reasoning recorded.
+  - Acceptance-criteria edits: AC-11 and AC-12 are amended to admit the named handler exemptions and their scoped failure variables. AC-17 is unchanged.
## git status --porcelain -- spec.md
 M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
## Observations
HUNKS: 2 | @@ -238,2 +238,2 @@ try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookD ; @@ -270,0 +271,10 @@ try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookD
CHANGE_LOG_HEADINGS: 1
OPERATOR_DECISION_LINES: 1
EXEMPTION_HELPER_MATCH_LINES: 238
PRD_VAR_MATCH_LINES: 239,276
AC_MATCHES: 27 | first line 228 | last line 254
AC17_EQUAL: True
```
