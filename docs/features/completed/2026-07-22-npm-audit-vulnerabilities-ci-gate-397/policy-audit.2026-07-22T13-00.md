# Policy Compliance Audit — issue #397 (npm-audit-vulnerabilities-ci-gate)

- **Branch:** `bug/npm-audit-vulnerabilities-ci-gate-397` @ `33a33806`
- **Base:** `main` @ merge-base `b2351cbc3fb3916f516d77567a1c9e40457c8981`
- **Work mode:** `full-bug` (per `plan.2026-07-22T07-54.md` header; no `issue.md` exists in this feature folder — AC source is `spec.md` `## Acceptance Criteria` per explicit task instruction, consistent with `full-bug` mode rules)
- **Timestamp:** 2026-07-22T13-00
- **Reviewer:** feature-review agent (Claude Code)

## Scope Resolution

Full branch diff `b2351cbc3fb3916f516d77567a1c9e40457c8981..33a3380623de8e0aa3e158cad695b488a62c4cd9`: 43 files changed, 1133 insertions(+), 71 deletions(-).

File-type breakdown (from `pr_context.appendix.txt` and direct `git diff --name-status`):
- 6 `.json` files: `package.json` + `package-lock.json` in `.`, `extensions/drm-copilot/`, `packages/mcp-server/` (all `M`).
- 37 `.md` files: all `A` (new), entirely under `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/` (spec, plan, research, evidence/*) plus one promoted potential-bug doc.
- 0 `.ts`, `.py`, `.ps1`, `.cs` files changed.

No narrowing of this scope was attempted by the calling prompt; the caller's instructions matched the full branch diff and the resolved base/merge-base. No entry is required under "Rejected Scope Narrowing."

## Rejected Scope Narrowing

None detected. The delegation prompt's stated scope (branch `bug/npm-audit-vulnerabilities-ci-gate-397`, base `main`, merge-base `b2351cbc3fb3916f516d77567a1c9e40457c8981`) is identical to the full branch-vs-base diff independently computed via `git diff --stat`/`git diff --name-status`. No plan/task/phase subset was substituted for full-branch scope.

## Evidence Location Compliance

- `git diff --name-only <merge-base>..<head> | grep -E "^artifacts/(baselines|qa|coverage|evidence)/"` — **no matches**. No file in the branch diff was written to a non-canonical `artifacts/` evidence path.
- All evidence produced by this feature's execution lives under the canonical `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/{baseline,qa-gates,other,issue-updates}/` tree, matching the Evidence Location Invariant.
- `scripts/dev_tools/validate_evidence_locations.py --root .` was run (exit 0, one warning): it flags a **pre-existing** violation at `artifacts/research/2026-07-07T19-00-epic-folder-structure-research.md`. This file is **not part of this branch's diff** (unmodified by commit `33a33806`) and predates this feature; it is not attributable to this PR and is not a new finding. No new evidence-location violations were introduced by this branch.

## Coverage Verification

Per the Coverage Verification procedure, this is mandatory only for languages with changed files in the branch diff. The four tracked languages (TypeScript, Python, PowerShell, C#) each have **zero changed files** in this diff (only `.json` manifests and `.md` documents changed) — `N/A` is the acceptable verdict for each per the Scope Invariant's "zero changed files" carve-out.

| Language | Changed files in diff | Verdict |
|---|---|---|
| TypeScript | 0 | N/A (zero changed files) |
| Python | 0 | N/A (zero changed files) |
| PowerShell | 0 | N/A (zero changed files) |
| C# | 0 | N/A (zero changed files) |

Although not mandated by the coverage-artifact rule (no `.ts` files changed), the plan independently captured before/after Jest coverage baselines as defense-in-depth evidence for the "no regression" requirement in `general-unit-test.md`. Verified directly by this reviewer (re-running the commands, not merely reading the artifact):

- Root: `npm run test:unit:coverage` — 96.97% statements/lines, 89.09% branches, 89.25% functions, both before (`test-coverage-baseline-root.2026-07-22T12-15.md`) and after (`test-coverage-final-root.2026-07-22T12-15.md`) the fix. Zero delta.
- `extensions/drm-copilot/`: `npm run test:coverage` — 96.3% statements/lines, 89.22% branches, 89.48% functions, both before (`test-coverage-baseline-extensions.2026-07-22T12-15.md`) and after (`test-coverage-final-extensions.2026-07-22T12-15.md`). Zero delta.
- `packages/mcp-server/`: no `test`/`test:unit` script exists in this manifest (confirmed via `grep -n '"build"\|"test"' packages/mcp-server/package.json`); the manual stdio smoke check is the documented functional-verification substitute, per plan P0-T13/T14 and P6-T8/T9.

**Verdict: PASS** (coverage is N/A per the language-changed-files gate; the repo's own coverage regression check, run as supplementary evidence, shows zero regression, independently re-verified by this reviewer at commit `33a33806`).

## Policy Compliance by Rule File

### `CLAUDE.md` / Tone Policy
- **PASS.** All authored artifacts (spec, plan, evidence, issue-comment mirror) use neutral, factual, non-hyperbolic phrasing consistent with `.claude/rules/tonality.md`.

### `.claude/rules/general-code-change.md`
- **PASS (N/A for most sub-rules).** No production/source code was touched (confirmed: diff contains only `package.json`/`package-lock.json` and docs). Design-principles, class/function, naming, and I/O-boundary rules do not apply to a dependency-manifest-only change. Dependency-policy sub-rule ("use only approved libraries... document why new dependency is required") is satisfied: no new *runtime* dependency was added — `@hono/node-server` was already a transitive dependency; the change only constrains its resolved version via `overrides`, and the spec's Root Cause Analysis documents why (`@modelcontextprotocol/sdk` declares it, unused, vulnerable pre-2.0.5).
- **File Size Limit** — N/A; no production/test/script file changed exceeds or approaches 500 lines (only manifest JSON and generated lock-file diffs).

### `.claude/rules/general-unit-test.md`
- **PASS.** No test files were added or modified (none required — no source lines changed). "No regression on changed lines" is trivially and verifiably satisfied: this reviewer independently re-ran `npm run test:unit` at root and in `extensions/drm-copilot/` and obtained identical pass counts (166 suites/2007 tests; 165 suites/2006 tests) to both the plan's baseline and final evidence artifacts.
- Coverage Exclusion Policy — N/A; no `exclude` config changed.

### `.claude/rules/typescript.md`
- **PASS with a noted pre-existing tooling divergence.** The rule file specifies Vitest as the test framework ("Testing — Vitest... Command: `npm run test`"), but this repository's actual `test:unit`/`test:coverage` scripts wrap **Jest** (`node run-jest.cjs`), as `spec.md`'s Test Strategy section explicitly and correctly notes ("Jest — the repo's actual test runner, not vitest"). This is a **pre-existing repo/policy-doc mismatch**, not introduced or worsened by this branch; the branch's evidence artifacts correctly follow the repo's actual (Jest-based) toolchain rather than the rule file's stated (Vitest) toolchain, which is the pragmatically correct choice. Recorded here for policy-doc maintenance awareness, not as a finding against this PR.
- Formatting/Lint/typecheck stages: the plan's `toolchain-stage-applicability.md` rationale (Prettier/ESLint/tsc are not standalone-applicable because no `.ts`/`.js` source changed; `tsc` is exercised indirectly via `npm run compile`) was independently verified by this reviewer: `npm run compile` (root) and `npx tsc -p ./ --noEmit` (extensions) both re-run clean (exit 0) at commit `33a33806`.

### `.claude/rules/ci-workflows.md` and `.claude/rules/benchmark-baselines.md`
- **N/A.** No workflow files and no benchmark baseline files are in this diff. `.github/workflows/_npm-audit-gate.yml` is confirmed byte-identical between base and head (`git diff <merge-base> <head> -- .github/workflows/_npm-audit-gate.yml` produced no output).

### `modified-workflow-needs-green-run` (feature-review-workflow rule, per agent memory)
- **N/A.** No `workflow/**` (`.github/workflows/**`) diff exists on this branch; the green-run-evidence requirement is not triggered.

### `.claude/rules/quality-tiers.md`
- **Observation, not a new finding.** `quality-tiers.yml` does not exist at the repository root (`find . -maxdepth 1 -iname "quality-tiers*"` returns nothing repo-wide). This is a pre-existing repository-wide gap unrelated to and not introduced by this branch (this branch adds no new project/module requiring classification — it only edits `overrides` in three existing manifests). Not counted as a blocking finding for this PR; flagged for awareness only.

### `.claude/rules/orchestrator-state.md`
- **N/A.** No `artifacts/orchestration/orchestrator-state.json` changes are in this diff.

## Direct Verification Performed by This Reviewer (not merely reading claimed evidence)

- `npm audit --audit-level=moderate` re-run at commit `33a33806` in `.`, `extensions/drm-copilot/`, and `packages/mcp-server/`: **0 vulnerabilities in all three**, confirming AC items 1–3.
- `git diff <merge-base> <head> -- package.json extensions/drm-copilot/package.json packages/mcp-server/package.json`: confirms exactly the `overrides` edits described in `spec.md`/plan (added `@hono/node-server: ^2.0.5`; raised `fast-uri` to `^3.1.4`, `hono` to `^4.12.27`; raised `c8`-scoped `brace-expansion` to `^5.0.7` in root and extensions only, absent in mcp-server as documented) — no other keys changed, `dependencies["@modelcontextprotocol/sdk"]` untouched in all three files.
- `npm run compile` (root), `npx tsc -p ./ --noEmit` (extensions): both exit 0.
- `npm run test:unit` (root: 166/166 suites, 2007/2007 tests; extensions: 165/165 suites, 2006/2006 tests) and `npm run build` (mcp-server: exit 0) all reproduced independently.
- `gh auth status`, `git ls-remote --heads origin bug/npm-audit-vulnerabilities-ci-gate-397`, `gh pr list --head ...`, `gh run list --branch ...`: confirmed the branch has not been pushed, no PR exists, and no CI run exists for this branch — consistent with the plan's Phase 8 tasks being unchecked and AC item 7 remaining unchecked.

## Overall Policy Verdict

**PASS** for all in-scope policy areas given the current diff. The single remaining acceptance criterion (`NPM Audit Gate` required check green on the PR head SHA) is **not a policy violation** — it is a procedural dependency on PR creation and CI execution that has not yet occurred (branch not pushed, no PR opened). No remediation-inputs artifact is produced because no FAIL-level or Blocking finding exists against the delivered code/config change; the outstanding item is tracked in `feature-audit` as an unmet, non-code-defect AC.
