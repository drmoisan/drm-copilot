# Implementation AC-to-Task Map (Issue #256)

Timestamp: 2026-06-27T14-16

| AC | Description | Implementing task(s) | Evidence |
|----|-------------|----------------------|----------|
| AC1 | C# + modern variant forwards `csharp-modern` (not literal `csharp`) | P1-T1, P1-T3 (pure helper translation + command wiring) | `claude-pack-name-translation.ts` `translateSelectedPackNames`; unit test "AC1" in `test/lib/push-down/claude-pack-name-translation.test.ts` |
| AC2 | C# + legacy variant forwards `csharp-legacy` | P1-T1, P1-T3 | unit test "AC2" in `test/lib/push-down/claude-pack-name-translation.test.ts` |
| AC3 | Non-C# packs unchanged and in order; no variant prompt when C# absent | P1-T1, P1-T3 (helper returns unchanged list; existing `packs.includes("csharp")` gating retained) | unit tests "AC3" and "AC1/AC3" in `test/lib/push-down/claude-pack-name-translation.test.ts` |
| AC4 | No `Pack manifest is missing for pack 'csharp'`; variant-qualified manifest resolved | P1-T2, P1-T3 (translation produces `csharp-modern`/`csharp-legacy`; fail-fast guard on unresolved variant) | helper translation + fail-fast guard; unit tests "AC4" and order-preservation in translation test |
| AC5 | Service failure written to output channel before surfacing | P1-T4, P1-T6 (try/catch around service call with `[commandId] push-down failure: ...` log + re-throw) | command edit in `repo-automation-command-registration-admin.ts`; unit test "AC5" in `test/repo-automation-command-registration-admin.test.ts` |
| AC6 | Unit tests cover AC1–AC5 and toolchain passes with no changed-line coverage regression | P1-T5, P1-T6, Phase 2 (P2-T1..T5) | new unit test files; Phase 2 final-QC and coverage-comparison artifacts |

## Files changed / created

- Created: `extensions/drm-copilot/src/lib/push-down/claude-pack-name-translation.ts` (pure helper, no `vscode` import, no I/O).
- Edited: `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` (call helper; forward translated packs; try/catch output logging + re-throw).
- Created: `extensions/drm-copilot/test/lib/push-down/claude-pack-name-translation.test.ts` (AC1–AC4 + non-mutation).
- Created: `extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts` (AC5 output-channel logging seam).
