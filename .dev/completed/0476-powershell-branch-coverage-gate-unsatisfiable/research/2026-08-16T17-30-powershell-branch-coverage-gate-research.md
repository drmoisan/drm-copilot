# Research: PowerShell Branch-Coverage Gate Unsatisfiable (Issue #476)

- Date: 2026-08-16
- Issue: #476 (`docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/issue.md`)
- Branch: `bug/powershell-branch-coverage-gate-unsatisfiable-476` (base `main` at `687380a6`)
- Selected route (fixed by orchestrator): policy alignment to tooling capability, mirroring the bash precedent. This research found no evidence that the route is wrong; see "Route Validity Check".

## Verification of Established Findings

Each orchestrator-supplied finding was independently re-verified. Method is stated per item.

1. **Pester 5.6.1 has no branch-coverage capability — CONFIRMED, with one precision correction.**
   - Method: grep of the installed module at `C:\Users\DanMoisan\OneDrive\Documents\PowerShell\Modules\Pester\5.6.1`.
   - Grep for `branch` (case-insensitive) restricted to `*.ps1`/`*.psm1`: **0 occurrences across 0 files.** The orchestrator's claim, scoped to `.ps1`/`.psm1`, is exactly correct.
   - Precision correction: an unrestricted grep finds 3 occurrences of `branch`, all in `schemas/JaCoCo/report.dtd` — the JaCoCo report format DTD, which declares `BRANCH` as a legal counter type of the *format*. This is evidence that the output format supports branch counters and Pester's implementation never emits them, which strengthens rather than weakens the finding.
   - Emitter verification: Pester's report builder (`Pester.psm1` ~9613–9683) aggregates exactly four counter families — `Instruction`, `Line`, `Method` (functions), `Class` (files). No branch aggregation exists.
   - Configuration verification: the documented `CodeCoverage` option block (`Pester.psm1:3920–3936`) lists `CoveragePercentTarget`, `RecursePaths`, `UseBreakpoints`, `SingleHitBreakpoints`, output options, and paths. No branch-related option exists. (The configuration class itself is compiled into `Pester.dll`; the in-module documentation block is the authoritative option list available from source.)
   - `artifacts/pester/powershell-coverage.xml` does not exist in this worktree (build artifact, not tracked), so the counter-type claim could not be re-parsed here. It is corroborated by the issue's captured log and by at least four independent prior audit artifacts that each verified zero `BRANCH` counters: `docs/features/active/planner-hook-em-dash-mismatch-357/policy-audit.2026-07-17T17-15.md:43`, `docs/features/completed/separate-version-bump-from-publish-214/evidence/baseline/poshqc-test.baseline.2026-06-19T21-18.md:12`, `docs/features/completed/portable-orchestrator-state-preflight/policy-audit.2026-07-06T10-56.md:94`, `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/policy-audit.2026-07-09T12-23.md:420`.

2. **Bash precedent exists at `.claude/rules/shell.md:68-70` — CONFIRMED.** Method: read of the file; verbatim quotation in R3 below. No equivalent carve-out exists for PowerShell anywhere in `.claude/`, `.github/`, `.agents/`, or `.codex/` (grep, R1 table).

3. **GitHub Actions is not the failing gate — CONFIRMED.** Method: read of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`CoveragePercentTarget = 0` at line 148; `OutputFormat = 'CoverageGutters'` at line 21). Additionally verified that the *mechanical* local hook is also not the failing gate: `.claude/hooks/validate-feature-review-coverage.ps1` computes PowerShell branch coverage via `Get-JacocoBranchCoverage` (lines 186–206), which returns `$null` when zero `BRANCH` counters exist (line 195), and the threshold check at lines 323–329 runs only when `$null -ne $BranchPct`. The mechanical hook therefore silently skips branch validation for PowerShell today. The blocking gate is the prose policy applied by the feature-review agent when auditing against `.claude/rules/powershell.md`, `general-unit-test.md`, `quality-tiers.md`, `feature-review-workflow/SKILL.md`, and `agents/feature-review.md`.

4. **Payload propagation — CONFIRMED and extended.** Method: grep of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json`. `.claude/rules/powershell.md` and `.claude/skills/powershell-qa-gate/SKILL.md` ship in the `powershell` pack (`powershell.json:5,12`). `.claude/agents/feature-review.md` (`core.json:12`), `.claude/hooks/validate-feature-review-coverage.ps1` (`core.json:49`), `.claude/rules/general-unit-test.md` (`core.json:58`), `.claude/rules/quality-tiers.md` (`core.json:60`), and `.claude/skills/feature-review-workflow/SKILL.md` (`core.json:80`) ship in the `core` pack. Extension-bundle mirrors exist for each and are byte-identical by test (R5). Extension: `.claude/rules/shell.md` (the bash precedent) also ships in `core` (`core.json:116`), so the precedent wording already propagates downstream.

## R1 — Complete Inventory of the Unsatisfiable Requirement

Search method: `grep -i "branch coverage|branch-coverage"` over the repository root, then targeted greps over `.claude/`, `.github/`, `.agents/`, `.codex/`, and both extension bundle mirrors.

### Primary edit surface — statements that bind branch >= 75% to PowerShell (root + bundle mirror)

Every root path below has a byte-identical mirror at `extensions/drm-copilot/resources/claude-customizations/<same .claude-relative path>` at the same line numbers (verified by grep; parity enforced by test, see R5). Both copies must be edited together.

| # | File:line | Statement | Pack |
|---|---|---|---|
| 1 | `.claude/rules/powershell.md:64` | "Branch coverage must remain >= 75% across all tiers (T1–T4)." (Testing Standards list; line 63 carries the line-coverage sibling, line 65 the changed-lines regression rule) | powershell |
| 2 | `.claude/rules/general-unit-test.md:24` | "**Branch coverage must remain >= 75% across all tiers (T1–T4).**" (Coverage Requirements) | core |
| 3 | `.claude/rules/quality-tiers.md:25` | "line and branch coverage thresholds are uniform across all tiers" | core |
| 4 | `.claude/rules/quality-tiers.md:34` | "Branch coverage: >= 75%." (uniform gate matrix) | core |
| 5 | `.claude/rules/quality-tiers.md:51` | rationale paragraph restating ">= 75% ... uniformly across T1–T4" | core |
| 6 | `.claude/skills/feature-review-workflow/SKILL.md:112-114` | branch >= 75% for new files, modified files, repo-wide per language; "Flag as FAIL otherwise." PowerShell is explicitly enumerated as a coverage language at line 109 | core |
| 7 | `.claude/agents/feature-review.md:112-114` | same three thresholds; PowerShell enumerated in the coverage-artifact table at line 105 | core |
| 8 | `.claude/skills/powershell-qa-gate/SKILL.md:45` | "line coverage >= 85% and branch coverage >= 75%" for new modules/classes/methods | powershell |

### Enforcement code (no edit required by the selected route)

| File:line | Behavior |
|---|---|
| `.claude/hooks/validate-feature-review-coverage.ps1:186-206, 208-219, 323-329` | Parses `//counter[@type="BRANCH"]` from `artifacts/pester/powershell-coverage.xml`; returns `$null` when absent; the 75% floor check is skipped when the metric is `$null`. Already consistent with the selected route. Comment block lines 20–28 describes the coverage rules; ships in `core` (`core.json:49`). Pester suite: `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` (only relevant if the hook is edited). |

### Codex-native surface (same requirement, restated; scope decision for the planner)

Root and bundle mirror are byte-identical (parity test, R5). These files ship via the codex/agents push-down (full-tree default publish).

| File:line | Statement | Mirror |
|---|---|---|
| `.agents/skills/general-unit-test/SKILL.md:29` | "**Branch coverage must remain >= 75% across all tiers (T1–T4).**" | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md:29` |
| `.agents/skills/quality-tiers/SKILL.md:30,39,56` | uniform statement / matrix row / rationale, identical to `.claude/rules/quality-tiers.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` (byte-identical) |

Not affected on the Codex surface (verified by grep): `.agents/skills/powershell/SKILL.md` carries the legacy Copilot-era line thresholds (80%/90%, lines 64–66) and **no** branch requirement; `.agents/skills/powershell-qa-gate/SKILL.md` and `.agents/skills/feature-review-workflow/SKILL.md` contain no numeric branch threshold; `.codex/**` contains zero matches for "branch coverage".

### `.github/` Copilot surface — no branch threshold (orchestrator suspicion CONFIRMED)

Method: case-insensitive grep for `coverage` across `.github/instructions/**` and for `branch coverage|branch-coverage` across all of `.github/`. Result: zero branch-coverage statements. `.github/instructions/general-unit-test.instructions.md:39-40` states only line-coverage expectations (repo-wide >= 80%, new code >= 90%). The `.github` surface needs no edit.

### Non-shipped repository documentation (optional consistency edits)

| File:line | Statement |
|---|---|
| `README.md:298` | "line coverage >= 85% and branch coverage >= 75%" stated uniformly for all toolchains |
| `docs/features/**`, `docs/research/**` (numerous) | historical audit/plan artifacts recording the threshold or the tooling limitation; historical records, not edit targets |

Footnote: `.claude/rules/quality-tiers.md` line 4 names `docs/ci.research.md` as the tier-system source of truth; that file does not exist in the repository. Dangling reference, out of scope for #476.

## R2 — Per-Language Capability Matrix

| Language | Coverage tool | Branch-capable | Rule statement (file:line) | Evidence of capability |
|---|---|---|---|---|
| Python | pytest + coverage.py, `--cov --cov-branch` | Yes | `.claude/rules/python.md:89`; command with `--cov-branch` at `python.md` Toolchain item 4 | Real branch numbers in audits, e.g. 76.61% (2588/3378) in `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-pytest-coverage.2026-07-09T15-35.md:15` |
| TypeScript | Jest (Istanbul), LCOV with `BRF:`/`BRH:` records | Yes | `.claude/rules/typescript.md:50` | Real branch numbers, e.g. 88.61% in `.../coverage-delta.2026-07-09T15-57.md:11`; hook parses LCOV branch records (`validate-feature-review-coverage.ps1:161-184`) |
| C# | `dotnet test --collect:"XPlat Code Coverage"` (coverlet), JaCoCo/Cobertura with BRANCH counters | Yes | `.claude/rules/csharp.md:44` | Hook parses JaCoCo `BRANCH` counters at `artifacts/csharp/coverage.xml` (`validate-feature-review-coverage.ps1:216`) |
| PowerShell | Pester 5.6.1 (`CoverageGutters`/JaCoCo emitters) | **No** | `.claude/rules/powershell.md:63-64` demands it anyway | Zero `branch` occurrences in module `.ps1`/`.psm1`; emitter aggregates Instruction/Line/Method/Class only (`Pester.psm1:9613-9683`) |
| bash | kcov (merged Cobertura `cov.xml`) | **No** (line only) | `.claude/rules/shell.md:68-70` — carve-out present | Carve-out states it directly; kcov output is line-based |

PowerShell and bash are the only two gated languages whose tooling cannot measure branch coverage. Only bash has a carve-out.

## R3 — Exact Precedent Wording and Structural Analysis (decision-relevant)

Verbatim, `.claude/rules/shell.md:68-70` (inside the `## Coverage Expectations` section):

> - kcov reports **line coverage only**. The uniform line-coverage threshold (>= 85% per
>   `.claude/rules/quality-tiers.md`) applies. Branch coverage is not measurable by kcov for
>   bash; there is no bash branch-coverage gate.

Structure of the precedent, in order:

1. **Names the tool and its actual capability** ("kcov reports line coverage only").
2. **Preserves the uniform line threshold explicitly**, with a cross-reference to `quality-tiers.md` (>= 85%).
3. **States the incapability as a fact about the tool** ("not measurable by kcov for bash").
4. **Disclaims the gate's existence, not merely its threshold** ("there is no bash branch-coverage gate").

### Were the shared files left unqualified for bash? Yes.

Method: grep for `bash|kcov|shell` in each shared file.

- `.claude/rules/general-unit-test.md` — no bash/kcov qualification (only an unrelated PowerShell path example at line 78).
- `.claude/rules/quality-tiers.md` — zero matches; the uniform matrix is unqualified.
- `.claude/skills/feature-review-workflow/SKILL.md` — no bash qualification; bash is simply absent from the coverage-language enumeration.
- `.claude/agents/feature-review.md` — same absence.

### Has the unqualified state caused any observed bash review failure? No — and the structural reason is the decisive finding of this research.

Bash never binds to the branch-coverage requirement because bash is not enumerated anywhere in the review surface:

- The hook's changed-language detector maps only `.ts/.tsx → TypeScript`, `.py → Python`, `.ps1/.psm1 → PowerShell`, `.cs → CSharp` (`validate-feature-review-coverage.ps1:121-137`). `.sh` files never produce a coverage-audited language.
- `feature-review-workflow/SKILL.md:107-110` enumerates exactly four coverage languages with artifacts (TypeScript, Python, PowerShell, C#). Bash is not listed.
- `agents/feature-review.md:101-106` coverage-artifact table lists the same four languages.

**PowerShell is on the wrong side of this asymmetry.** It is explicitly enumerated in all three places, with its artifact path, and the threshold text at `SKILL.md:112-114` / `feature-review.md:112-114` instructs "Flag as FAIL otherwise" with no capability escape. Consequence for the fix:

- For **bash**, a language-rule-file-only carve-out was sufficient *because nothing else ever binds the requirement to bash*.
- For **PowerShell**, a carve-out in `.claude/rules/powershell.md` alone leaves four other shipped files (`general-unit-test.md`, `quality-tiers.md`, `feature-review-workflow/SKILL.md`, `agents/feature-review.md`) plus `powershell-qa-gate/SKILL.md` still instructing a reviewer to demand branch >= 75% for an enumerated PowerShell audit. A reviewer following the skill text literally would still raise the finding. The fix therefore needs to touch the shared files as well — this is a justified, documented deviation from the bash precedent, caused by the enumeration asymmetry, not a contradiction of it.

Supporting evidence that prose ambiguity produces inconsistent outcomes today: prior audits handled the missing metric three different ways — instruction-coverage proxy recorded as PASS (`separate-version-bump-from-publish-214/policy-audit.2026-06-19T22-30.md:285`; `portable-orchestrator-state-preflight/policy-audit.2026-07-06T10-56.md:94`), "accepted documented tooling limitation" (`planner-hook-em-dash-mismatch-357/policy-audit.2026-07-17T18-30.md:121,145`), and a downstream consumer's remediation cycle stalled on a permanent Blocking finding (issue #476 Impact section). A single explicit carve-out at every binding site removes the ambiguity.

## R4 — What Pester Can Measure, Precisely (background for amendment wording)

Mechanism (verified from module source): Pester performs static AST analysis of the files in `CodeCoverage.Path`, identifies every measurable *command* (PowerShell AST command element), and instruments each one — by default with breakpoints (`UseBreakpoints`, `Enter-CoverageAnalysis` at `Pester.psm1:8641`), optionally with an experimental profiler-based tracer (`Pester.psm1:3932`). A command either executed at least once or it did not. The emitters then aggregate:

- `INSTRUCTION` — one unit per measurable command; covered when the command executed.
- `LINE` — derived by grouping commands per source line (`Pester.psm1:9683`); a line with zero measurable commands is not in the denominator.
- `METHOD` — per function; `CLASS` — per file.

What command coverage **does** capture about control flow: a conditional branch whose body contains commands is visible when untaken — its commands count as missed in both `INSTRUCTION` and `LINE` denominators. Under-tested `if`/`else`/`switch` bodies therefore do reduce the reported percentages.

What it **does not** capture: condition *outcomes*. An `if` that was only ever evaluated true, with an implicit (absent or empty) else, contributes no missed unit — the untaken false path is invisible. Short-circuit sub-expressions (`-and`/`-or` operands) and the distinction between "line hit via one path" and "all paths through the line exercised" are likewise unrepresented. There is no branch denominator at all; the metric is not low, it is undefined (0/0).

Accurate amendment vocabulary, per the issue's manual-verification note: Pester measures **command (instruction) coverage and line coverage**; it does not measure branch outcomes in any output format (`CoverageGutters`, `JaCoCo`, `Cobertura` — all share the same counter aggregation). Per the fixed route, command coverage must be described as what the tool measures, not adopted as a substitute gated metric.

## R5 — Verification Surface

Tests that bind the edit:

1. **Root/bundle byte parity, Claude surface** — `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 101–126): every non-memory root `.claude/**` file must exist in `extensions/drm-copilot/resources/claude-customizations/.claude/**` with byte-identical content. Any edit to a root policy file **must** be applied to its bundle mirror in the same change, or this test fails.
2. **Pack-manifest completeness, Python side** — `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`: real-filesystem, presence-only (every bundled agent/skill/hook is listed in some manifest). Content edits to already-listed files cannot fail it; it matters only if the fix adds a new file.
3. **Pack-manifest completeness, TypeScript twin** — `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`: same presence-only contract.
4. **Root/bundle byte parity, Codex surface** (only if `.agents/**` files are edited) — `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (lines 207–220): byte parity between root `.agents`/`.codex` and `extensions/drm-copilot/resources/codex-and-agents-customizations/`.

**Content assertions on the affected files: none.** Verified by grep for `branch coverage|75%` across `tests/**` and `extensions/drm-copilot/test/**`: the only content-level assertions on rule/skill files anywhere in the parity suites target C# gate-command substrings (`test_push_down_claude_resource_contracts.py:290-433`, and the Codex twin at lines 263+). No test pins the branch-coverage wording of `powershell.md`, `general-unit-test.md`, `quality-tiers.md`, `feature-review-workflow/SKILL.md`, `feature-review.md`, or `powershell-qa-gate/SKILL.md`. The fix therefore requires no test-content updates — only that the parity suites pass.

Commands that must pass after the edit (the changed files are Markdown, so no language toolchain loop is triggered by production-code changes; the binding checks are):

- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (plus `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` if `.agents/**` is touched), and the full `poetry run pytest` per the repository loop.
- From `extensions/drm-copilot/`: the Jest suite (completeness twin), via the repo's standard test command.
- The hook Pester suite `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` is unaffected because the selected route does not modify the hook.

## R6 — Downstream Propagation Mechanics

- **Tool**: MCP tool `push_down_claude_customizations` (registered at `extensions/drm-copilot/src/mcp-tool-definitions.ts:133`, dispatched at `src/mcp-tools.ts:179`; TypeScript engine at `src/lib/push-down/claude-customizations.ts`). The engine's source root is the **bundled** payload inside the installed extension: `extensions/drm-copilot/resources/claude-customizations` (`src/lib/push-down/push-down-service-call.ts:171`). A Python CLI equivalent exists (`scripts/dev_tools/push_down_claude_customizations.py`), which reads the repository checkout when run from a drm-copilot clone.
- **Packs**: `.claude/rules/powershell.md` and `.claude/skills/powershell-qa-gate/SKILL.md` reach consumers that select the `powershell` pack; `general-unit-test.md`, `quality-tiers.md`, `feature-review-workflow/SKILL.md`, `agents/feature-review.md`, and the coverage hook reach every consumer via `core`. The corrected carve-out therefore reaches all consumers through `core`, plus the PowerShell-specific files through `powershell`. (`shell.md`, the precedent, already ships in `core` at `core.json:116`.)
- **Version bump requirement**: yes, for the extension-mediated path. The corrected bundle mirror ships inside the packaged extension, so consumers receive it only after an extension release (repository convention: paired extension + mcp-server version bump, e.g. commit `17b1b08d` "release: bump extension to 1.0.25 and mcp-server to 1.0.25", driven by the `Invoke-FullRelease` flow) and an extension update on the consumer side. Editing only the root `.claude/**` files publishes nothing; the byte-parity test forces the mirror edit, and the release publishes it.
- **Consumer action**: consumers must re-run `push_down_claude_customizations` after updating the extension; push-down overwrites the destination copies of the affected files. A consumer working from a drm-copilot checkout can alternatively run the Python CLI against the updated checkout without waiting for a release.
- **Codex surface**: analogous via `push_down_codex_and_agents_customizations` (Python CLI publishes root `.codex` + `.agents` trees; the extension twin publishes `resources/codex-and-agents-customizations`). With no `--packs` selection, the full `.agents` tree — including the two Codex files carrying the requirement — is published.

## Requirements Mapping (proposed edit design)

Single recommended approach: one structurally parallel carve-out plus capability qualifications at every site that binds the threshold to PowerShell, root and bundle mirror together.

1. `.claude/rules/powershell.md:63-65` — replace the branch line with a carve-out structurally parallel to `shell.md:68-70`: name Pester 5.6.1; state that it measures command (instruction) and line coverage only; preserve the >= 85% line threshold with the `quality-tiers.md` cross-reference; state that branch coverage is not measurable by Pester for PowerShell and that there is no PowerShell branch-coverage gate.
2. `.claude/rules/general-unit-test.md:24` — qualify the branch threshold to languages whose tooling measures branch coverage, naming PowerShell (Pester) and bash (kcov) as the two exceptions where only the line threshold applies.
3. `.claude/rules/quality-tiers.md:25,34,51` — same qualification on the uniform-matrix row and rationale.
4. `.claude/skills/feature-review-workflow/SKILL.md:111-114` — qualify the three threshold bullets so the branch clause applies only to branch-capable languages; the line clause and no-regression clause remain unconditional.
5. `.claude/agents/feature-review.md:112-114` — same qualification.
6. `.claude/skills/powershell-qa-gate/SKILL.md:45` — remove or qualify the branch clause for PowerShell.
7. Bundle mirrors of 1–6 under `extensions/drm-copilot/resources/claude-customizations/.claude/` (byte-identical).
8. Planner decision: `.agents/skills/general-unit-test/SKILL.md:29` and `.agents/skills/quality-tiers/SKILL.md:30,39,56` plus their `codex-and-agents-customizations` mirrors restate the same requirement on the Codex surface. Including them keeps the two surfaces consistent at the cost of two more file pairs; excluding them leaves the Codex surface carrying the unqualified rule. The issue's stated scope (Claude payload files) does not name them; recommend including them or filing an immediate follow-up.
9. Optional, non-shipped: `README.md:298` consistency edit.

No change to `.claude/hooks/validate-feature-review-coverage.ps1`: its `$null`-skip behavior already implements the selected policy mechanically, and prose alignment makes policy and mechanism agree.

Success conditions: a feature-review pass over a PowerShell-touching diff raises no branch-coverage finding; the line-coverage gate still fails a genuinely under-covered file; the amended text names Pester, states the measurable metrics, and preserves >= 85% line unchanged (issue's manual-verification notes). Failure condition to guard: any wording that lowers or removes the line threshold, or that reads as excluding PowerShell files from coverage measurement (prohibited by the Coverage Exclusion Policy).

### Rejected alternatives

- **Language-rule-file-only edit (strict bash parallel)** — rejected: PowerShell, unlike bash, is explicitly enumerated with "Flag as FAIL otherwise" thresholds in `feature-review-workflow/SKILL.md:109,112-114` and `agents/feature-review.md:105,112-114`; those files would keep regenerating the finding (R3).
- **AST-instrumentation branch collector; command coverage as a substitute gated metric** — out of scope by orchestrator constraint; both are recorded as separate follow-ups in the issue.
- **Editing shared files without `powershell.md`** — rejected: `powershell.md:64` is the most-cited conflicting line and is the only affected file scoped to the `powershell` pack.

## Testing Implications

- No new tests are required by the policy-text route. The binding regression suite is the existing parity/completeness set (R5).
- Integration re-test per the issue: run a feature-review pass over a PowerShell-touching diff; confirm no branch finding is raised and that an under-covered file still fails the line gate. This is a behavioral check of the review workflow, not a unit test.
- If the planner opts to pin the new carve-out wording against future drift, a content-substring assertion in `test_push_down_claude_resource_contracts.py` (pattern precedent: the C# gate-command substring tests at lines 290–433) is the established mechanism; optional.

## Automation Feasibility

No step of the eventual fix requires human interaction. Reasoning:

- All edits are Markdown policy files inside this repository (root plus bundle mirrors); no external system, credential, or manual approval is involved in making or verifying them.
- Verification is fully automated: pytest parity/completeness suites, the Jest twin, and the standard toolchain loops.
- The downstream *publication* of the corrected payload rides the repository's existing release flow (version bump + publish), which is standard post-merge process and outside the fix's scope; the fix itself is complete and verifiable entirely within repository files.
- No `human_interaction` checkpoint entry is warranted; no scope change, exception, or halt condition was identified.

## Route Validity Check

Nothing found contradicts the selected route. Three observations affirmatively support it: (1) the mechanical hook already skips the branch check when the metric is absent, so policy alignment closes a prose/mechanism gap rather than weakening an operating gate; (2) the repository resolved the identical conflict for bash with exactly this route; (3) the `.github/` Copilot surface never carried the branch requirement, so no cross-surface contradiction is created by removing it for PowerShell on the Claude surface.
