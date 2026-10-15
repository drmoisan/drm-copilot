# Fail-before exception: #737 F-3, F-4, F-5, F-6, N-1, N-2 and #846 CR-2, CR-3, CR-4

Timestamp: 2026-10-13T12-49
Scope: issue #903 Phase 11 test-support and comment notes. No production file is changed by any note below.

The alternative proof for every note is the P12-T23 per-row CI pass: each edited row (or every row of the edited suite) is read from the final CI JUnit artifacts and must show a `testcase` element with no `failure` or `skipped` child.

## #737 F-3 (comment only)

WhyFailingRunImpossible: The change adds a header paragraph to `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` that documents the discovery population boundary (`hooks/<name>.ps1` literals only). A comment has no runtime behavior, so no assertion can fail before it and pass after it.
Alternative proof: every row of `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` passes in P12-T23 (subject to the P12-T27 F-1/F-2 withhold decision), showing the header edit did not alter the helper's executable lines.

## #737 F-6 (comment only)

WhyFailingRunImpossible: The change adds two header lines naming `$script:EpicStateParseCache` as a deliberate, deterministic, test-session-only memo exception. No executable line changes, so no assertion can observe the edit.
Alternative proof: the same Discovery suite rows pass in P12-T23.

## #737 N-1 (comment only)

WhyFailingRunImpossible: The change removes a stale parenthetical about a scan-root rows file from the header of `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` and rewraps the comment. A comment edit has no runtime behavior.
Alternative proof: every row of `enforcement-hooks-no-python-invocation.Tests.ps1` passes in P12-T23.

## #737 N-2 (comment only)

WhyFailingRunImpossible: The change extends the `Register-EpicStateBaselineMock` doc comment in `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` with the `-Surface 'Codex'` semantics. A comment edit has no runtime behavior.
Alternative proof: the suites that call `Register-EpicStateBaselineMock` pass in P12-T23.

## #737 F-4 (test-structure hardening over unchanged production code)

WhyFailingRunImpossible: The `DEV-2` row of `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` now iterates every candidate tool name admitted by the `enforce-epic-wave-barrier.ps1` registration matchers instead of only `Bash`. The production hook already allows those benign payloads, so the strengthened row passes both before and after; there is no defect to observe as a failure. The added non-empty assertion on the admitted-name list guards against a vacuous pass.
Alternative proof: the `DEV-2` row passes in P12-T23.

## #737 F-5 (test-structure hardening over unchanged production code)

WhyFailingRunImpossible: `Assert-FamilySetEqual` in `tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1` replaces direct `Should -BeExactly` comparisons with a throwing assertion helper used in the two equality rows and the divergent row. The three family sets are already equal, so the equality rows pass before and after, and the divergent fixture differs before and after.
Alternative proof: every `AC-19` row of the CodexDeployment parity suite passes in P12-T23.

## #846 CR-2 (assertion hardening over an unchanged workflow)

WhyFailingRunImpossible: `Get-BraceBlockText` replaces the `[^}]*` regex block assertions with an indentation-matched block extractor plus `Should -Not -BeNullOrEmpty` and a multiline `::error::` then `exit 1` match. The workflow is unchanged and already satisfies the property, so the assertions pass before and after.
Alternative proof: the rows `asserts tag and manifest version equality in a ref-guarded step ordered before the publish step` and `polls the exact published version after publishing and fails the job on budget expiry` pass in P12-T23.

## #846 CR-3 (assertion hardening over an unchanged workflow)

WhyFailingRunImpossible: The duplicated failing-exit count and block assertions are removed from `keeps the exit-code reset, explicit exits, and exact-version operand in the poll step`; the budget-expiry row keeps them. Removing a duplicate assertion cannot produce a failing run.
Alternative proof: both rows pass in P12-T23.

## #846 CR-4 (assertion hardening over an unchanged workflow)

WhyFailingRunImpossible: The row `runs the registry poll step only after a successful publish step` gains `$pollConditions[0] | Should -Match '^\s+if:\s*[^\s>|]'`. The workflow's poll condition is already inline (`if: startsWith(...)`), so the assertion passes before and after.
Alternative proof: the row passes in P12-T23.
