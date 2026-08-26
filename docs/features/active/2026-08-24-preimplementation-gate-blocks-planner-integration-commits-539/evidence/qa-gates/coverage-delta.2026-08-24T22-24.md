# Coverage Delta and Threshold Verification [P7-T4]

Timestamp: 2026-08-24T22-24

Threshold: uniform line coverage >= 85% across all tiers, per `.claude/rules/quality-tiers.md`.
PowerShell is exempt from the branch-coverage threshold because Pester does not measure branch
coverage; the line threshold applies in full.

## (a) Baseline coverage — from [P0-T8] and [P0-T9]

| Source file | Covered | Total | Line coverage | Artifact |
| --- | ---: | ---: | ---: | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 99 | 110 | **90.0%** | `evidence/baseline/baseline-pester-claude-hooks.2026-08-24T17-23.md` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 121 | 122 | **99.2%** | `evidence/baseline/baseline-pester-codex-hooks.2026-08-24T17-31.md` |

The two helper files have no baseline because they did not exist before this change. Each
baseline was captured under the same per-side folder scan set the final run uses, so the
comparison below is like-for-like. The 0.0% cross-rows in each baseline artifact are scoping
artifacts of a single-side scan and are not a comparison basis, as those artifacts state.

## (b) Post-change coverage — from [P7-T3]

Extracted from `artifacts/pester/powershell-coverage.xml` (report `Pester (08/24/2026 22:16:46)`),
keyed on the enclosing `package` element.

| Package | Source file | Covered | Total | Line coverage |
| --- | --- | ---: | ---: | ---: |
| `.claude/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 102 | 113 | **90.3%** |
| `.claude/hooks` | `enforce-orchestration-preimplementation-gate-helpers.ps1` | 112 | 118 | **94.9%** |
| `.codex/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 124 | 125 | **99.2%** |
| `.codex/hooks` | `enforce-orchestration-preimplementation-gate-helpers.ps1` | 112 | 118 | **94.9%** |

## (c) Changed-code result — threshold and regression

| Source file | Baseline | Post-change | Delta | >= 85%? | Regression? |
| --- | ---: | ---: | ---: | :---: | :---: |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 90.0% | 90.3% | **+0.3 pp** | PASS | no |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | n/a (new file) | 94.9% | n/a | PASS | n/a |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 99.2% | 99.2% | **0.0 pp** | PASS | no |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | n/a (new file) | 94.9% | n/a | PASS | n/a |

All four numeric values are available and all four are at or above the 85% threshold. Neither
hook regressed against its baseline: the Claude hook improved by 0.3 percentage points and the
Codex hook is unchanged.

Both hooks grew in executable lines (Claude 110 to 113, Codex 122 to 125) while gaining covered
lines at least as fast (99 to 102, 121 to 124), so the added exemption call sites are themselves
exercised. The two new helper files enter the coverage denominator at 94.9%, so the change adds
236 executable lines to the measured surface without lowering any per-file figure below threshold.

Because every numeric value is present and every threshold is met, the outcome is **PASS**, not
remediation-required.

## (d) Mirror inheritance — the four bundle copies

No suite executes the four bundle copies directly. Each inherits its canonical measurement by
byte-identity, recomputed and cross-checked against git object storage in
`evidence/other/pair-hash-recomputed-final.2026-08-24T22-24.md`.

| Bundle copy | Inherits from | Shared SHA-256 | Inherited coverage |
| --- | --- | --- | ---: |
| `extensions/.../claude-customizations/.claude/hooks/…-gate.ps1` | `.claude/hooks/…-gate.ps1` | `BF3FE18D…` | 90.3% |
| `extensions/.../claude-customizations/.claude/hooks/…-gate-helpers.ps1` | `.claude/hooks/…-gate-helpers.ps1` | `45C339FD…` | 94.9% |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/…-gate.ps1` | `.codex/hooks/…-gate.ps1` | `DB69F084…` | 99.2% |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/…-gate-helpers.ps1` | `.codex/hooks/…-gate-helpers.ps1` | `45C339FD…` | 94.9% |

The inheritance argument is sound only while the pairs remain equal. That equality is not left to
this artifact: it is asserted programmatically by the `keeps the canonical hooks byte-identical to
their bundled copies` test in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
(passing in [P7-T3]) and by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
(passing in [P7-T6]). A future divergence breaks those tests before it can invalidate this table.

Note that the pair-hash values recorded in the earlier [P4-T7] and [P5-T7] artifacts were stale
for the two hook rows; the recomputed artifact cited above supersedes them. The equality relation
they asserted was correct — only the recorded numbers were not.

## Output Summary

PASS. Baseline: Claude hook 90.0%, Codex hook 99.2%, no baseline for the two new helpers.
Post-change: Claude hook 90.3%, Claude helper 94.9%, Codex hook 99.2%, Codex helper 94.9%. Every
one of the four canonical changed or added production files is at or above the 85% line-coverage
threshold, and neither pre-existing hook regressed (+0.3 pp and 0.0 pp). The four bundle copies
inherit their canonical measurements through recomputed, git-cross-checked SHA-256 byte-identity,
with that identity independently enforced by two passing contract suites. All four sections
required by this task are present and every threshold is met.
