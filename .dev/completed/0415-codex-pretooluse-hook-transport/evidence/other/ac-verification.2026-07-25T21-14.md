# Acceptance-Criteria Verification (Issue #415)

Timestamp: 2026-07-25T21-14

AC source (work mode `full-bug`): `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/spec.md`, section `## Acceptance Criteria` (lines 262-273). No `user-story.md` exists, which is correct for `full-bug`.

The 12 criteria are verified below in spec order, matching the plan's traceability table.

---

## AC1 — Config-driven integration: every registered handler × every admitted tool name exits 0

**Verdict: PASS**

The Pester case `allows every registered handler for every tool name its own matcher admits` parses the `[[hooks.PreToolUse]]` registrations and matcher regexes from `.codex/config.toml` at run time, derives admitted tool names by matching a candidate set against each matcher, and spawns every combination. Measured matrix:

```
matcher ^(apply_patch|Edit|Write)$                                    handlers=8  admitted=3  spawns=24
matcher ^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$         handlers=5  admitted=6  spawns=30
matcher ^Bash$                                                        handlers=5  admitted=1  spawns=5
TOTAL registrations=18  distinct handlers=17  matrix spawns=59
```

All 59 exit 0 with empty stdout and empty stderr. A companion guard case asserts the derivation is non-empty and spans at least three matchers, so an empty parse cannot make the matrix vacuously green.

Supporting artifacts: `evidence/regression-testing/pass-after.2026-07-25T20-46.md`; `evidence/other/phase7-poshqc-loop.2026-07-25T20-54.md`; `evidence/qa-gates/final-poshqc-test.2026-07-25T21-02.md`.

---

## AC2 — Forbidden payload yields exit 0 and exactly the native deny envelope, no legacy `decision` key

**Verdict: PASS**

Fifteen process-level deny cases in `codex-pretooluse-transport.Tests.ps1` cover each (handler, tool name) pair whose preserved policy can deny deterministically: the two purity hooks and `enforce-evidence-locations` across `Edit`/`Write`/`apply_patch` (9 cases), and the two checkpoint hooks across `Write`/`apply_patch`/`Edit` (6 cases). Each asserts exit 0, that stdout parses, `hookEventName == 'PreToolUse'`, `permissionDecision == 'deny'`, the reason matches the policy marker, and that the top-level `decision` key is **absent** (`Should -Not -Contain 'decision'`).

Batch-budget forbidden cases remain unit-level via injected state per `spec.md:263`. Preimplementation-gate deny cases are unit-level with an injected `-CheckpointRaw '{}'`, asserting `PREIMPLEMENTATION_GATE_BLOCKED` for `Edit`-, `Write`-, and `apply_patch`-mapped implementation paths.

Supporting artifacts: `evidence/regression-testing/pass-after.2026-07-25T20-46.md` (deny table); `evidence/qa-gates/final-poshqc-test.2026-07-25T21-02.md`.

---

## AC3 — Unmapped `apply_patch` yields exit 0 with empty stdout for all eight group handlers

**Verdict: PASS**

Two parameterized cases cover both unmapped variants across all eight group handlers (16 spawns): `{command:''}` and `{command:'noop'}`. All exit 0 with empty stdout. These are rows 3, 4, 7, 8, 11, 12, 15, 16, 19, 20, 23, 24, 27, 28, 31, 32 of the fail-before table, 14 of which previously exited 2.

Supporting artifacts: `evidence/regression-testing/fail-before.2026-07-25T19-30.md`; `evidence/regression-testing/pass-after.2026-07-25T20-46.md`.

---

## AC4 — Malformed stdin yields exit 2, empty stdout, nonempty stderr (scoped per I5); completion-consistency names itself

**Verdict: PASS**

- **Empty stdin and invalid JSON, every registered handler:** the case `fails closed with exit 2 for <empty stdin|invalid JSON> on every registered handler` iterates the 17 handlers derived from `.codex/config.toml` (34 spawns). All exit 2 with empty stdout and nonempty stderr.
- **Missing and null `tool_input`, the eight group handlers only:** the case `fails closed with exit 2 for a <missing|null> tool_input on every group handler` (16 spawns). All exit 2 with empty stdout and nonempty stderr matching `tool_input`. Scoped per Interpretation I5, because the seven non-implicated handlers allow this input today and must not be behaviourally changed (`spec.md:79`, `spec.md:119`).
- **Self-naming:** the case `reports enforce-completion-consistency in its own stderr rather than its neighbour` asserts, for three malformed inputs, that stderr matches `enforce-completion-consistency` and does **not** match `enforce-checkpoint-monotonic`.

Direct measurement of the eight group handlers × four malformed inputs returned **32/32 conforming**. Compare fail-before rows 29-32, where `enforce-completion-consistency` reported its neighbour's name.

A latent defect was also fixed here: `enforce-evidence-locations` previously exited **0** on empty stdin (a silent allow on malformed input) because a parameter-binding failure skipped its `exit`. It now exits 2. Detail in `evidence/other/phase5-poshqc-loop.2026-07-25T20-16.md`.

Supporting artifacts: `evidence/other/phase5-poshqc-loop.2026-07-25T20-16.md`; `evidence/other/phase6-poshqc-loop.2026-07-25T20-28.md`; `evidence/regression-testing/pass-after.2026-07-25T20-46.md`.

---

## AC5 — Poisoned `CLAUDE_*` environment has no effect; static `$env:CLAUDE_` absence

**Verdict: PASS**

Every process-level invocation in both new suites and in `legacy-codex-hook-contracts.Tests.ps1` bakes `CLAUDE_TOOL_INPUT='{"command":"git reset --hard"}'` and `CLAUDE_SESSION_ID='poisoned-legacy-session'` into `ProcessStartInfo.Environment`. Roughly 130 spawns run under poisoned variables and every one produces the stdin-determined result; notably, the poisoned `git reset --hard` command value never influences any outcome.

Statically, the Pester case `contains no legacy Claude environment-variable dependency in hooks or shared modules` asserts `Should -Not -Match '\$env:CLAUDE_'` across `$script:StaticCheckNames`, which `[P2-T3]` extended to include the new shared module. The module's own documentation was deliberately worded to avoid the literal token so the assertion measures code rather than prose.

Supporting artifacts: `evidence/other/phase2-poshqc-loop.2026-07-25T19-52.md`; `evidence/regression-testing/pass-after.2026-07-25T20-46.md`.

---

## AC6 — Registration set and matchers unchanged

**Verdict: PASS**

- `git diff .codex/config.toml` → 0 lines.
- `git diff 00980851 -- .codex/config.toml` → 0 lines: byte-identical to the merge-base.
- Root and bundle `config.toml` SHA256 both `160C5A0601918775D4190EF5EB14BB9F5DCD3FB8D8CF7FC3F80A20DCC4F704BD`.
- `[[hooks.PreToolUse]]` matcher-group handler counts: **5 / 5 / 8**, unchanged.
- The config-driven integration case passes against these registrations.

Supporting artifacts: `evidence/other/scope-verification.2026-07-25T21-10.md`; `evidence/other/phase1-poshqc-loop.2026-07-25T19-38.md`.

---

## AC7 — Policy outcomes for previously reachable `apply_patch` payloads unchanged

**Verdict: PASS**

No policy function in any of the eight hooks was modified. Verified structurally per phase with `git diff -U0` hunk maps: every hunk falls in the docstring region, the dot-source insertion, the removed transport functions, or the entrypoint. Targeted greps of the diffs for policy-function declaration lines return 0 for every file.

The pre-existing Pester cases in `legacy-codex-hook-contracts.Tests.ps1` that exercise `apply_patch` policy pass **without any policy-assertion change**:

- `ignores poisoned Claude variables when safe Codex stdin payloads are supplied`
- `emits the current PreToolUse deny envelope for shell and patch violations`
- `fails closed when the canonical checkpoint is deleted or becomes invalid JSON`
- `denies preimplementation and batch-budget violations through their pure decisions`

The only edits to that file were the `[P2-T3]` list additions and the `[P5-T4]`/`[P6-T4]` mapping-unit updates, which retarget two assertions at the shared module while keeping the expected values identical. No deny-path or fail-closed assertion was touched.

For the preimplementation gate specifically, `Bash` and `apply_patch` payloads traverse the unmodified `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ($payload.tool_input | ConvertTo-Json ...)` path, so its existing outcomes for those two tool names are preserved exactly.

Supporting artifacts: `evidence/other/phase3-poshqc-loop.2026-07-25T19-58.md`; `phase4-poshqc-loop.2026-07-25T20-06.md`; `phase5-poshqc-loop.2026-07-25T20-16.md`; `phase6-poshqc-loop.2026-07-25T20-28.md`; `evidence/qa-gates/final-poshqc-test.2026-07-25T21-02.md`.

---

## AC8 — Root/bundle byte-identity; bundle orphan deleted with #335 note

**Verdict: PASS**

Whole-directory check: `rootHooks=26 mismatches=0`. Every root `.ps1` has a bundle counterpart with an equal SHA256, and no bundle-only orphan remains.

All four independent parity gates named in the criterion pass:

| Gate | Result |
|---|---|
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 12 tests, 0 failures |
| `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` | 10 tests, 0 failures |
| `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` | 4 tests, 0 failures |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | passes within 8/8 |

The bundle-only `enforce-pr-author-skill.ps1` is deleted (`git diff --diff-filter=D` returns exactly that one path), with the issue #335 cross-reference note recorded at `evidence/regression-testing/issue-335-bundle-orphan-removal.2026-07-25T19-33.md`, which states that #335's fix must reintroduce the hook on both root and bundle with stdin transport plus a `[[hooks.PreToolUse]]` registration.

Supporting artifacts: `evidence/other/scope-verification.2026-07-25T21-10.md`; `evidence/qa-gates/final-poshqc-format.2026-07-25T20-58.md`; `evidence/qa-gates/final-pytest-parity.2026-07-25T21-04.md`.

---

## AC9 — Shared module exists, entrypoint-free, ≤ 500 lines, mirrored, listed in parity lists and `core.json`

**Verdict: PASS**

| Requirement | Result |
|---|---|
| exists under `.codex/hooks/` | `.codex/hooks/codex-pretooluse-file-mapping.ps1` |
| entrypoint-free | only script-scoped constants and function definitions; no stdin read; `enforce-completion-helpers.ps1` precedent |
| ≤ 500 lines | **474** |
| all changed hook files ≤ 500 lines | max is `enforce-completion-consistency.ps1` at 438; full table in `scope-verification` |
| mirrored byte-for-byte | SHA256 `4951858193773BCB4A36548B6F01CAE40BD81412A723AFACC4E9D12CB3899E7D` on both copies |
| in Pester parity/static lists | added via `$script:SharedModuleNames` / `$script:StaticCheckNames`; inside the parse + 500-line and hash-parity assertions and the legacy-environment-absence assertion; deliberately outside the stdin-presence assertion and all process-level loops |
| in `pack-manifests/core.json` | added, and asserted by the new case `lists every shared hook module in the core pack manifest` |

Extraction also brought the two largest hooks further under the cap: `enforce-checkpoint-monotonic.ps1` fell from 420 to 339 lines.

Supporting artifacts: `evidence/other/phase2-poshqc-loop.2026-07-25T19-52.md`; `evidence/other/scope-verification.2026-07-25T21-10.md`.

---

## AC10 — No `.claude/` paths in the change set

**Verdict: PASS**

`git diff --stat 00980851 -- .claude/` → 0 lines. `git status --porcelain | grep -c "\.claude/"` → 0. No tracked change, no working-tree change, no untracked file under `.claude/`, including any bundled `.claude` copy.

Supporting artifact: `evidence/other/scope-verification.2026-07-25T21-10.md`.

---

## AC11 — PoshQC loop clean in one pass with qa-gates evidence

**Verdict: PASS**

Final loop, in order, all against `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`:

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 | `mcp__drm-copilot__run_poshqc_format` | 0 | zero files changed |
| 2 | `mcp__drm-copilot__run_poshqc_analyze` | 0 | 0 errors, 0 warnings, 0 information |
| 3 | `mcp__drm-copilot__run_poshqc_test` | 0 | 1391 tests, 0 failures, 0 errors |

All three clean in a single uninterrupted pass, with results captured under `evidence/qa-gates/`. The one analyzer finding encountered earlier (Phase 7, `PSUseShouldProcessForStateChangingFunctions` on a test helper) was fixed at its cause and the loop restarted from format; no suppression was added.

Supporting artifacts: `evidence/qa-gates/final-poshqc-format.2026-07-25T20-58.md`; `final-poshqc-analyze.2026-07-25T20-59.md`; `final-poshqc-test.2026-07-25T21-02.md`.

---

## AC12 — Line coverage >= 85% (branch coverage where the toolchain measures it)

**Verdict: PASS**

- Baseline line coverage: **90.22%** (2150 / 2383)
- Post-change line coverage: **90.15%** (2151 / 2386)
- Threshold: >= 85%. **PASS**, 5.15 pp of headroom.
- No regression on changed lines: the −0.07 pp movement is denominator growth from three newly-added entrypoint lines in `enforce-completion-consistency.ps1` that sit behind the dot-source guard and were equally uncovered at baseline. No previously-covered line became uncovered.
- Branch coverage: **not measurable in this toolchain.** Pester 5 / JaCoCo through PoshQC emits `mb`/`cb` attributes that are uniformly `0` and no aggregate `BRANCH` counter. The criterion's own qualifier "where the toolchain measures it" applies; this is the documented limitation at `spec.md:248`. No threshold was waived and no value was fabricated.
- pytest parity run: 8 passed, exit 0.

Supporting artifacts: `evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md`; `final-poshqc-test.2026-07-25T21-02.md`; `final-pytest-parity.2026-07-25T21-04.md`; `evidence/baseline/phase0-poshqc-test.2026-07-25T19-16.md`.

---

## Summary

| AC | Verdict | Primary artifact |
|---|---|---|
| AC1 | PASS | `regression-testing/pass-after.2026-07-25T20-46.md` |
| AC2 | PASS | `regression-testing/pass-after.2026-07-25T20-46.md` |
| AC3 | PASS | `regression-testing/fail-before.2026-07-25T19-30.md` + `pass-after.2026-07-25T20-46.md` |
| AC4 | PASS | `other/phase6-poshqc-loop.2026-07-25T20-28.md` |
| AC5 | PASS | `other/phase2-poshqc-loop.2026-07-25T19-52.md` |
| AC6 | PASS | `other/scope-verification.2026-07-25T21-10.md` |
| AC7 | PASS | `other/phase3..phase6-poshqc-loop` artifacts |
| AC8 | PASS | `other/scope-verification.2026-07-25T21-10.md` |
| AC9 | PASS | `other/phase2-poshqc-loop.2026-07-25T19-52.md` |
| AC10 | PASS | `other/scope-verification.2026-07-25T21-10.md` |
| AC11 | PASS | `qa-gates/final-poshqc-*.md` |
| AC12 | PASS | `qa-gates/coverage-comparison.2026-07-25T21-06.md` |

**All 12 acceptance criteria are PASS with a named supporting artifact. No criterion is PARTIAL, FAIL, or UNVERIFIED.**

Per `[P8-T10]`, the spec checkboxes are **not** edited here; checking them off is a review-time action.
