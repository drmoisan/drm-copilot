# Phase 0 Feature Documents Read (Issue #710)

Timestamp: 2026-09-27T02-00

Files Read:

1. docs/features/active/preimplementation-helpers-backslash-chain-operator-710/issue.md
2. docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md
3. docs/features/active/preimplementation-helpers-backslash-chain-operator-710/research/research.2026-09-26T23-05.md
4. docs/features/active/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md

AC Inventory:

- AC-1 | spec line 206 | - [ ] AC-1: `Split-OrchestrationCommandLine` treats an unquoted backslash-escaped `;`, `&` or `|` as a literal character: `find . -exec cmd {} \; -print`, `a\&b c` and `a\|b c` each return exactly one segment whose text equals the input, verified by the `treats a mid-line escaped semicolon as literal`, `treats an escaped ampersand as literal` and `treats an escaped pipe as literal` tests in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, and those tests fail against the base helper file (fail-before evidence recorded under `evidence/regression/`).
- AC-2 | spec line 207 | - [ ] AC-2: `Test-ExemptOrchestrationStagingCommand` returns `$true` for `git commit -m fix\;done -- docs/features/active/x/spec.md`, verified by the `exempts a commit whose message contains an escaped semicolon` test in the same file.
- AC-3 | spec line 208 | - [ ] AC-3: Unescaped chain operators continue to split exactly as before: `a; b`, `a && b`, `a || b`, `a | b` and `a & b` each return two segments, verified by the data-driven `still splits on unescaped <operator>` tests.
- AC-4 | spec line 209 | - [ ] AC-4: The fix introduces no bypass: `a\\; b` returns two segments, `a\&& b` returns two segments, `'a\'; b` returns two segments, and `Test-ExemptOrchestrationStagingCommand` returns `$false` for `git commit -m fix\\; touch src/x -- docs/features/active/x/spec.md`, verified by the `still splits after an escaped backslash`, `splits on the unescaped ampersand after an escaped one`, `keeps backslash literal inside single quotes` and `does not exempt a chained command after an escaped backslash` tests.
- AC-5 | spec line 210 | - [ ] AC-5: Quote-state and boundary cases behave per POSIX: `a\\\; b` returns one segment; `"a\"; b"` returns one segment with `Balanced` true; `a\"` and a trailing `a\` return `Balanced` true; backslash-newline returns one segment, verified by the corresponding tests in the same file.
- AC-6 | spec line 211 | - [ ] AC-6: The fix is applied identically to all four copies: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` have equal SHA256 values recorded under `evidence/qa-gates/`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` pass.
- AC-7 | spec line 212 | - [ ] AC-7: The helper file's post-edit line count equals its line count measured on the current base immediately before editing and is <= 500, with both counts recorded under `evidence/qa-gates/`; the diff of the canonical file touches only `Split-OrchestrationCommandLine`.
- AC-8 | spec line 213 | - [ ] AC-8: The regression suite passes under Pester locally and in the CI PoshQC Pester job (`.github/workflows/_poshqc.yml`, `windows-latest`), and by inspection it depends on no gitignored state, no `origin/main` ref, no gate-decision path, and no Windows-only filesystem path.
- AC-9 | spec line 214 | - [ ] AC-9: Existing suites that reach the helpers stay green: both CommandExemption suites, the EpicScope and TriggerScoping suites, and the Codex trigger-scoping, mode-resolution and mode-routing suites.
- AC-10 | spec line 215 | - [ ] AC-10: Full PowerShell toolchain passes in a single pass (PoshQC format, PoshQC analyze with 0 findings, Pester), and line coverage for both canonical helper copies is >= 85% with no regression on changed lines, recorded under `evidence/coverage/`.
- AC-11 | spec line 216 | - [ ] AC-11: The out-of-scope operand gap (`docs/features/active/.\./.\./.\./src/x.ps1`, D7) is recorded as a follow-up to be filed separately, and no edit is made to `Test-ExemptOrchestrationOperand`.

Entry count: 11 (AC-1 to AC-11, spec lines 206 to 216, document order).
