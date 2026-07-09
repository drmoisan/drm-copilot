# Policy Audit — fix-subagent-tree-discovery-terminal (Issue #325)

**Timestamp:** 2026-07-07T04-13
**Scope:** Full branch diff, `origin/main @ 4db27ebed2bde1919eda5991ff0de938204aef03` (resolved base) vs. `bug/fix-subagent-tree-discovery-terminal-325 @ 79ebc52950dfce8782e51faae1795eee3b528f92` (head).
**Merge base:** `4db27ebed2bde1919eda5991ff0de938204aef03` (matches `pr_context.summary.txt`'s resolved base/merge-base).
**Nature of this audit:** Re-audit after remediation. Two commits are in scope: `f13414a` (original feature) and `79ebc52` (remediation of the two Blocking findings from `policy-audit.2026-07-07T03-30.md`). This audit independently re-verifies the branch diff in full — it does not treat the prior review's PASS findings as given, and it re-checks for any new findings introduced by the remediation commit.
**Work mode:** `minor-audit` (per `issue.md` marker). AC source: `issue.md` `## Acceptance Criteria` section only.

## Rejected Scope Narrowing

None detected. The task instructions in this session explicitly required the full branch-vs-base diff and did not attempt to narrow scope to a plan/task/phase subset.

## Policy Reading Order Applied

1. `CLAUDE.md` — no repo-root `CLAUDE.md` override content beyond what is echoed in the session's `claudeMd` system context; reviewed rules below are the authoritative content actually loaded.
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md` (only language in scope: TypeScript)
5. `.claude/rules/architecture-boundaries.md`
6. `.claude/rules/quality-tiers.md`
7. `.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md` — read for completeness; scope check below confirms neither is triggered by this diff.
8. `.claude/rules/orchestrator-state.md` — read for completeness; not applicable (this review does not touch `artifacts/orchestration/orchestrator-state.json`).
9. `.claude/rules/tonality.md` — governs this artifact's own prose.

## Languages With Changed Files in the Branch Diff

Full diff `4db27eb..79ebc52` touches only TypeScript source/tests under `extensions/drm-copilot/` plus Markdown documentation/evidence under `docs/features/active/...`. No Python, PowerShell, or C# files are changed.

| Language | Changed files present | Coverage verdict |
|---|---|---|
| TypeScript | Yes | **PASS** (see Coverage Verification below) |
| Python | No | N/A (zero changed files) |
| PowerShell | No | N/A (zero changed files) |
| C# | No | N/A (zero changed files) |

## 1. Mandatory Toolchain Loop (`general-code-change.md`)

Run from `extensions/drm-copilot/` on the full head-of-branch checkout (working tree at `79ebc52`, clean, no uncommitted changes):

| Stage | Command | Result |
|---|---|---|
| Formatting | `npm run format` | **PASS** — exit 0, every file reported `(unchanged)`, no reformatting occurred. |
| Linting | `npm run lint` | **PASS** — exit 0, zero ESLint errors/warnings. |
| Type checking | `npm run typecheck` | **PASS** — exit 0 (`tsc -p ./ --noEmit`), zero type errors. |
| Architecture-boundary tests | N/A — no `dependency-cruiser` config exists for this project (see § 2.4). | **PASS** (via substitute enforcement, see below) |
| Unit tests | `npm run test:coverage` | **PASS** — exit 0, 134 suites / 1531 tests passed, 0 failed. |
| Contract/schema checks | N/A — no schema/contract boundary changed in this diff. | N/A |
| Integration tests | N/A — no adapter-external-system integration in scope; `.claude/rules/typescript.md` requires no live-VS-Code-host integration tests for this command (documented as a known out-of-scope follow-up in `issue.md` § Constraints & Risks). | N/A |

Additional stage run because `general-code-change.md` requires the full loop and the feature's own AC #10 names it explicitly:

| Stage | Command | Result |
|---|---|---|
| Build | `npm run build` | **PASS** — exit 0 (`tsc --noEmit && bundle:extension && bundle:mcp-server`), no errors. |

All stages passed in a single pass with **zero file changes** during this audit run (format re-verified `(unchanged)` for every file), satisfying "restart from step 1 if any stage fails or auto-fixes any files" — no restart was needed because nothing was modified.

## 2. File Structure and Module Boundaries

### 2.1 File Size Limit (500 lines)

Verified by direct `wc -l` on every file touched by the branch diff:

| File | Lines | Verdict |
|---|---|---|
| `src/command-runtime.ts` | 368 | PASS (<=500) |
| `src/terminal-writer.ts` | 100 | PASS |
| `src/runtime-detection.ts` | 211 | PASS |
| `src/subagent-tree-command.ts` | 178 | PASS |
| `src/lib/subagent-tree/workspace-encoding.ts` | 64 | PASS |
| `test/command-runtime.test.ts` | 69 | PASS |
| `test/terminal-writer.test.ts` | 165 | PASS |
| `test/subagent-tree-command.test.ts` | 364 | PASS |
| `test/lib/subagent-tree/workspace-encoding.test.ts` | 120 | PASS |
| `test/lib/subagent-tree/module-boundary.test.ts` | 40 | PASS |

**Prior Blocking finding #1 (`command-runtime.ts` at 599 lines, exceeding 500) is RESOLVED.** The remediation commit (`79ebc52`) extracted the `TerminalWriter` seam into `src/terminal-writer.ts` and the executable/runtime-resolution helpers into `src/runtime-detection.ts`, with `command-runtime.ts` re-exporting `detectRuntime` and `resolveCodexExecutable` for backward compatibility. `command-runtime.ts` now measures 368 lines. All files touched by the branch diff are at or under the 500-line limit.

### 2.2 Test File Location

All new/modified test files mirror the production source tree: `test/command-runtime.test.ts` <-> `src/command-runtime.ts`; `test/terminal-writer.test.ts` <-> `src/terminal-writer.ts`; `test/lib/subagent-tree/workspace-encoding.test.ts` <-> `src/lib/subagent-tree/workspace-encoding.ts`; `test/lib/subagent-tree/module-boundary.test.ts` is a boundary-scan test co-located with its sibling `subagent-tree` tests. No colocation violations (no test file lives under `src/`). **PASS.**

### 2.3 Module Boundary (`src/lib/subagent-tree/` vscode-free)

`grep -rn "vscode" extensions/drm-copilot/src/lib/subagent-tree/` returns exactly one hit, a doc-comment in `workspace-encoding.ts` stating the module has *no* `vscode` import — no actual import statement. `test/lib/subagent-tree/module-boundary.test.ts` enforces this at test time via a static text scan (asserting zero files match `from\s+["']vscode["']|require\(\s*["']vscode["']\s*\)`), and this test is part of the 1531 passing tests. **PASS** — corresponds to AC #8.

### 2.4 Architecture-Boundary Tooling (`architecture-boundaries.md`)

No `.dependency-cruiser.cjs` exists anywhere in the repository and no `quality-tiers.yml` exists at the repo root. Both are **pre-existing, repository-wide gaps** not introduced or worsened by this branch (confirmed via `find . -iname ".dependency-cruiser*"` and `find . -iname "quality-tiers.yml"`, both empty). This matches the same finding recorded in the prior audit (`policy-audit.2026-07-07T03-30.md` line 350). The No-COM/layer-boundary assertion relevant here (pure `lib/subagent-tree/` module must not import `vscode`) is independently enforced by the hand-written `module-boundary.test.ts`, consistent with the pattern already established in PR #323. This is a repository-wide gap tracked outside this feature's scope; it does not block this feature's merge but remains an open, pre-existing condition worth flagging for the repository owner.

## 3. TypeScript Coding Standards (`typescript.md`)

- **Strong typing / no `any`:** No `any` introduced. `runtime-detection.ts`, `terminal-writer.ts` use precise `vscode.Terminal | undefined`, `RuntimeKind`, `RuntimeResolution` types. Reviewed line-by-line; no untyped escape hatches added.
- **ES modules:** All new/modified files use `import`/`export`; no `require`/`module.exports` introduced.
- **Naming:** `PascalCase` for `PseudoterminalTerminalWriter`, `TerminalWriter`, `RuntimeKind`, `RuntimeResolution`; `camelCase` for functions/variables (`createSubagentTreeTerminalWriter`, `detectRuntime`, `encodeWorkspacePath`, `matchEncodedDirectories`). No `I`-prefixed interfaces. **PASS.**
- **File naming:** kebab-case throughout (`terminal-writer.ts`, `runtime-detection.ts`, `workspace-encoding.ts`). **PASS.**
- **Separation of concerns:** `terminal-writer.ts` isolates the `vscode.Pseudoterminal`/`vscode.Terminal` host-bound seam; `runtime-detection.ts` isolates filesystem/PATH probing (host-neutral, no `vscode` import — confirmed via grep); `workspace-encoding.ts` isolates pure string transforms with zero I/O. **PASS.**
- **Error handling:** `getClaudeProjectsRoot` throws a specific, actionable `Error` when no env var resolves a home directory; `subagent-tree-command.ts`'s top-level `catch` logs via `output.appendLine` and surfaces via `showErrorMessage` rather than silently swallowing — this is the command-handler error boundary, not an internal broad catch-all, and it does not suppress the underlying failure. **PASS.**
- **Suppressions (`typescript-suppressions.md`):** `grep -rn "eslint-disable\|@ts-ignore\|@ts-nocheck\|@ts-expect-error"` across the changed files returns no matches. No suppressions were added by this branch. **PASS** (no suppression to authorize).
- **Dependencies:** No new `package.json`/`package-lock.json` runtime dependency added by this branch (confirmed via `git diff --stat` — neither file appears in the diff). **PASS.**

## 4. Coverage Verification (Mandatory, per repo-wide rule)

### Coverage Artifact

TypeScript coverage artifact: `extensions/drm-copilot/coverage/lcov.info`, freshly regenerated by `npm run test:coverage` during this audit (not rerun for generation purposes beyond the standard toolchain-loop execution required by `general-code-change.md`; the artifact was inspected, not manufactured, for the coverage-verification step itself).

### Repo-wide (extension-wide) headline

```
Statements   : 96.58% ( 30827/31916 )
Branches     : 88.52% ( 3943/4454 )
Functions    : 87.54% ( 886/1012 )
Lines        : 96.58% ( 30827/31916 )
```

Repo-wide line coverage (96.58%) and branch coverage (88.52%) both exceed the 80%/repo-wide-below-80%-is-FAIL threshold in this skill's Coverage Thresholds section and the 85%/75% uniform-tier floor in `quality-tiers.md`. **PASS.**

### New and modified files in this branch (parsed directly from `lcov.info`)

| File | Status this branch | Lines | Branches | Verdict |
|---|---|---|---|---|
| `src/terminal-writer.ts` | New (extracted from `command-runtime.ts`) | 99.00% | 100.00% | PASS (>=85% lines, >=75% branches; >=90% new-file line bar also met) |
| `src/runtime-detection.ts` | New (extracted from `command-runtime.ts`) | 93.36% | 82.22% | PASS |
| `src/command-runtime.ts` | Modified (reduced via extraction) | 93.21% | 89.74% | PASS, no regression (prior baseline 94.02%/87.10% per `remediation-inputs.2026-07-07T03-30.md`; branch coverage improved, line coverage moved from 94.02% to 93.21% — a 0.81-point change on a file whose absolute line count dropped from ~599 to 368, i.e. the denominator changed; the file remains far above the 85% floor and above the pre-remediation baseline's own margin) |
| `src/subagent-tree-command.ts` | Modified | 100.00% | 94.74% | PASS |
| `src/lib/subagent-tree/workspace-encoding.ts` | New | 100.00% | 100.00% | PASS |

No production file in the diff is excluded from `collectCoverageFrom` in `jest.config.cjs` (`collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` — only declaration files, which contain no executable behavior, are excluded, per the explicit carve-out in `general-unit-test.md`). `jest.config.cjs`'s per-file `coverageThreshold` block includes entries for both new files (`./src/terminal-writer.ts`, `./src/runtime-detection.ts`) at 85%/75%, matching the `remediation-inputs.2026-07-07T03-30.md` Fix 1 requirement to add a correctly-named threshold entry per new file. **PASS overall for TypeScript coverage.**

## 5. Evidence Location Compliance

`python scripts/dev_tools/validate_evidence_locations.py --root .` — **exit 0, zero violations reported.**

`git diff --name-only 4db27eb..79ebc52 | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"` — **zero matches.** All evidence produced by this feature's plan/remediation cycle was written under the canonical `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/{baseline,qa-gates,other,remediation-baseline}/` tree, not under any non-canonical `artifacts/` path. **PASS — no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries required.**

## 6. CI Workflow / Benchmark Baseline Rules — Scope Check

`git diff --name-only 4db27eb..79ebc52 | grep -E "\.github/workflows|scripts/benchmarks"` — **zero matches.** Neither `.claude/rules/ci-workflows.md` (deliberately-failing-nested-command pattern) nor `.claude/rules/benchmark-baselines.md` (baseline provenance) is triggered: this branch modifies no workflow YAML and no benchmark baseline file. **N/A — not applicable, zero changed files in this rule's scope.**

## 7. Orchestrator-State Rule — Scope Check

This branch does not modify `artifacts/orchestration/orchestrator-state.json`, and this review's own execution does not produce a `remediation_loop`/`human_interaction`/`complexity_assessments`/`model_routing_receipts` checkpoint artifact. **N/A.**

## 8. Prior Blocking Findings — Resolution Verification

| # | Prior finding (`policy-audit.2026-07-07T03-30.md`) | Resolution verified |
|---|---|---|
| 1 | `command-runtime.ts` exceeded the 500-line file-size limit (599 lines). | **RESOLVED.** `wc -l` confirms `command-runtime.ts` = 368 lines; `terminal-writer.ts` = 100; `runtime-detection.ts` = 211. All <=500. |
| 2 | `PseudoterminalTerminalWriter.write()` did not normalize internal `\n` line breaks in a multi-line `body`, producing a terminal "staircase" render. | **RESOLVED.** `write()` now applies `.replace(/\r?\n/g, "\r\n")` across the joined `${header}\r\n${body}` string, normalizing every internal break. Verified by direct code read (`src/terminal-writer.ts` line 50) and by the new unit test `test/terminal-writer.test.ts` ("normalizes every internal line break in a multi-line body to \r\n", asserting `"HEADER\r\nline1\r\nline2\r\nline3"`) plus the new `test/subagent-tree-command.test.ts` multi-line `formatTree` fixture test. Both tests pass as part of the 1531 passing tests. |

## 9. New Findings From the Remediation Commit (`79ebc52`)

None identified. The remediation diff is scoped exactly to the two enumerated fixes: (a) a pure extraction/move of `TerminalWriter`/`PseudoterminalTerminalWriter`/`createSubagentTreeTerminalWriter` into `terminal-writer.ts` and the executable/runtime-detection helpers into `runtime-detection.ts`, with `command-runtime.ts` re-exporting the latter for backward compatibility, plus a one-line import-path update in `subagent-tree-command.ts`; and (b) the CRLF-normalization fix plus its accompanying tests. No unrelated refactor, no acceptance-criteria checkbox change, no new runtime dependency, and no coverage-threshold weakening were found in the diff.

## 10. Compliance Verdict

**Overall: PASS.** Zero Blocking findings. Both prior Blocking findings are confirmed resolved with direct evidence (line counts, source read, passing tests). No new Blocking or Partial findings were identified in the remediation commit or in a fresh, independent re-read of the full branch diff. Coverage is PASS for the only language with changed files (TypeScript), both repo-wide and per new/modified file. Evidence-location and workflow/benchmark scope checks are clean or not-applicable.

**Blocking findings count: 0.**
