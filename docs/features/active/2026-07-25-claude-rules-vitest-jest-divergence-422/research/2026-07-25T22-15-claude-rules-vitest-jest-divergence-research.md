# Research: Vitest/Jest divergence in Claude and Codex instruction mirrors (Issue #422)

- Date: 2026-07-25
- Issue: #422
- Researcher: task-researcher
- Scope: read-only analysis; no source files modified.

## 1. Current state (verified)

- Root `package.json` scripts (`package.json:26-39`): `"test:unit": "node run-jest.cjs"`, `"test:unit:coverage": "node run-jest.cjs --coverage"`, `"test": "vscode-test"`, `"test:integration": "vscode-test"`. Also verified: `format` (line 32), `format:check` (33), `lint` (35), `typecheck` (30). There is **no** `test:coverage` script and **no** Vitest dependency; Jest is a root devDependency (`jest ^30.4.2`, line 49; `ts-jest ^29.4.11`, line 51; `@jest/globals`, line 42).
- `jest.config.cjs` exists at repo root and is the active unit-test config (testMatch covers `tests/unit/**/*.test.ts` and `extensions/drm-copilot/test/**/*.test.ts`; ts-jest transform; v8 coverage provider).
- `run-jest.cjs` invokes `jest/bin/jest --config jest.config.cjs` through `run-node-tool.cjs` and rewrites the legacy `--testPathPattern` flag to `--testPathPatterns` (Jest 30 flag name).
- `run-node-tool.cjs` resolves tool binaries from two `node_modules` roots (repo root and `extensions/drm-copilot`) and augments `NODE_PATH` accordingly (`run-node-tool.cjs:5-13, 91-104`).
- Canonical policy `.github/instructions/typescript-unit-test.instructions.md` mandates Jest (line 24), `jest.spyOn`/`jest.mock` (lines 82-83), `jest.resetAllMocks` (line 89), `jest.useFakeTimers()` (line 94), and the approved command `npm run test:unit` (line 110).
- Canonical policy `.github/instructions/typescript-code-change.instructions.md` names "Testing — Jest" with approved command `npm run test:unit` (lines 45-48).
- `CLAUDE.md` establishes that `.github/instructions/` is canonical and must not be modified; `.claude/` files mirror or reference its content.

## 2. Q1 — Parity contract, file by file

### Parity assertions (verified by reading the assertions, not inferred)

**All four `.claude/**` files are covered by a byte-for-byte text parity assertion.**

- Test file: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- Test function: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 100-125)
- Assertion (lines 118-125): for every file enumerated under the repo-root `.claude/` tree (excluding `.claude/settings.local.json` and `.claude/agent-memory/**`), the test asserts the file exists in the bundle and `read_text(BUNDLED_ROOT, relative_path) == read_text(REPO_ROOT, relative_path)`, where `BUNDLED_ROOT = extensions/drm-copilot/resources/claude-customizations` (lines 16-18). The enumeration is `SCOPED_ROOTS = (Path(".claude"),)` (line 19) via `rglob("*")` (lines 33-42), so it is exhaustive, not a hand-maintained list.
- Consequence: editing `.claude/rules/typescript.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/general-code-change.md`, or `.claude/agents/atomic-executor.md` at the repo root **without** the matching edit to the bundled copy fails this test (assertion message: `"Bundle content differs from repo for: {relative_path}"`, line 125).

**Both `.agents/**` files are covered by an equivalent parity assertion.**

- Test file: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- Test function: `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (lines 206-219)
- Assertion (lines 213-219): for every repo-root file under `SCOPED_ROOTS = (Path(".codex"), Path(".agents"))` (line 34), the test asserts presence in `extensions/drm-copilot/resources/codex-and-agents-customizations` and `read_text(BUNDLED_ROOT, relative_path) == read_text(REPO_ROOT, relative_path)`.
- Consequence: editing `.agents/skills/general-unit-test/SKILL.md` or `.agents/skills/general-code-change/SKILL.md` without the bundled copy fails this test.

Reference example confirmed: `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources` (lines 63-81) uses the same exact-text-equality pattern for the PoshQC module pairs.

Per-file summary:

| Repo-root file | Parity enforced? | Test function / lines |
|---|---|---|
| `.claude/rules/typescript.md` | Yes, byte-for-byte text | `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_push_down_claude_resource_contracts.py:100-125` |
| `.claude/rules/general-unit-test.md` | Yes | same |
| `.claude/rules/general-code-change.md` | Yes | same |
| `.claude/agents/atomic-executor.md` | Yes | same |
| `.agents/skills/general-unit-test/SKILL.md` | Yes | `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, `test_push_down_codex_and_agents_resource_contracts.py:206-219` |
| `.agents/skills/general-code-change/SKILL.md` | Yes | same |

### Non-parity tests in the candidate list (for completeness)

- `tests/scripts/dev_tools/test_push_down_claude_customizations.py` and `test_push_down_codex_and_agents_customizations.py` are unit tests of the push-down engine against in-memory fakes (test names verified, e.g. `test_push_down_customizations_copies_claude_tree_files`); they do not assert live root-versus-bundle parity.
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` asserts pack-manifest completeness for the bundled `.claude` tree; it is not a content-parity lock.

### Is there a repo-root → bundle regeneration script?

**No.** Verified by inspection:

- `scripts/dev_tools/push_down_claude_customizations.py` and `push_down_codex_and_agents_customizations.py` publish **from the bundle to an external destination workspace** (`BUNDLE_ROOT_RELATIVE_DIR = "extensions/drm-copilot/resources/claude-customizations"`, `push_down_claude_customizations.py:66-68`; the CLI requires `--destination`, lines 313-317). They never write into the bundle from repo-root sources.
- `scripts/dev_tools/agentic_sync.py` synchronizes `.github/` folders between two repository workspaces (`ROOT_FOLDERS`, lines 24-29); it does not touch `.claude/`, `.agents/`, or the bundles.
- No other script under `scripts/dev_tools/` copies repo-root `.claude`/`.agents` into `extensions/drm-copilot/resources/`.

Conclusion: the correct update procedure is to **edit each repo-root file and its bundled copy identically by hand** (12 files total for this fix: 6 repo-root + 4 bundled `.claude` copies + 2 bundled `.agents` copies), with the two parity tests acting as the drift lock. This matches how the parity contract is designed to be satisfied.

Note: no test binds the `.agents/skills/*` converted skills to their `.claude/rules/*` sources. The `.agents` files carry a one-time conversion header ("Source: legacy Claude rule ...", `.agents/skills/general-unit-test/SKILL.md:10`); the codex-native-converter tests (`tests/scripts/dev_tools/codex_native_converter/*`) exercise the converter against fakes, not the live trees. The `.claude` and `.agents` texts must therefore be corrected independently and kept consistent by review, not by an existing test.

## 3. Q2 — Canon adjudication, file by file

Preliminary finding **confirmed**: `.github/instructions/general-unit-test.instructions.md` (read in full, 107 lines) contains exactly five sections — `## 1. Core Principles`, `## 2. Coverage and Scenarios`, `## 3. Test Structure and Diagnostics`, `## 4. External Dependencies and Environment`, `## 5. Policy Audit`. It contains no "Determinism Infrastructure" section, no "Coverage Exclusion Policy" section, and no Vitest reference. The `vi.useFakeTimers()`/`vitest.config.ts` text in the mirrors is repo-specific additive content with no canon counterpart; the mirror is the authority for those lines.

| # | File and lines | Canon counterpart | Verdict | Basis |
|---|---|---|---|---|
| 1 | `.claude/rules/typescript.md:16, 42, 47, 51, 73` | `.github/instructions/typescript-code-change.instructions.md:45-48` (Jest, `npm run test:unit`); `.github/instructions/typescript-unit-test.instructions.md:24, 82-94, 110` (Jest APIs, `npm run test:unit`) | **CORRECT-IN-MIRROR** | Canon says Jest throughout; mirror says Vitest and Vitest-only APIs (`vi.spyOn`, `vi.mock`, `vi.resetAllMocks`, `vi.useFakeTimers`). Line 51 additionally carries stale bootstrap text ("wired in Prompt B1 alongside the Vitest dependency") describing a setup that was never adopted. Fix on this branch. |
| 2 | `.claude/rules/general-unit-test.md:40, 105` | None — canon has no Coverage Exclusion Policy or Determinism Infrastructure section (confirmed above) | **CORRECT-IN-MIRROR** (mirror-authored additive content; the mirror is the authority and it names the wrong framework for this repository) | Line 40 lists `vitest.config.ts` as a permitted coverage exclude; the repo's actual non-production test config is `jest.config.cjs` (root, verified present; no `vitest.config.ts` exists). Line 105 instructs `vi.useFakeTimers()` for Vitest; the repo framework facility is `jest.useFakeTimers()` (canon `typescript-unit-test.instructions.md:94`). Fix on this branch. |
| 3 | `.claude/rules/general-code-change.md:39` | `.github/instructions/general-code-change.instructions.md:246` — "Run the tests (e.g. Pytest)." Canon names no TypeScript runner. | **CORRECT-IN-MIRROR** | The mirror's example list `(e.g., Pytest, Vitest, MSTest, Pester)` enumerates this repository's per-language runners, exactly as the sibling lines do for formatters (`Black, Prettier, CSharpier, Invoke-Formatter`, line 35) and linters. It is not a generic cross-ecosystem list: Pytest, MSTest, and Pester are this repo's actual Python, legacy-C#, and PowerShell runners (README.md:302-306). The TypeScript slot should read Jest. One-word substitution; not NOT-A-DEFECT. |
| 4 | `.claude/agents/atomic-executor.md:18, 79` | `.github/agents/atomic_executor.agent.md` — contains **no** occurrence of `vitest`, `jest`, `test:unit`, or `TypeScript` (case-insensitive grep, zero matches). The toolchain section is mirror-authored. | **CORRECT-IN-MIRROR** | The allowlist entry `Bash(npx vitest *)` and the toolchain line `npx vitest` name a tool that is not installed in this repository (no `vitest` in any `package.json` dependency block). This file drives actual Bash permission scoping, so the defect has runtime consequences. Fix on this branch; recommended replacement in section 4. |
| 5 | `.agents/skills/general-unit-test/SKILL.md:45, 110` | Same as #2 (the file is a conversion of `.claude/rules/general-unit-test.md`; header at line 10) | **CORRECT-IN-MIRROR** | Identical text to #2 at the corresponding lines (verified). Fix in lockstep with #2 so the two runtime surfaces stay consistent. |
| 6 | `.agents/skills/general-code-change/SKILL.md:44` | Same as #3 | **CORRECT-IN-MIRROR** | Identical toolchain list text (verified). Fix in lockstep with #3. |

No **UPSTREAM-DIVERGENCE** verdicts: the canon is either correct (Jest) or silent for every occurrence in the owned file set.

### Out-of-scope occurrences (leave alone)

- `.github/instructions/github-actions-ci-cd-best-practices.instructions.md:322` and its vendored copy `extensions/drm-copilot/resources/customizations/.github/instructions/github-actions-ci-cd-best-practices.instructions.md:322` — "Use appropriate language-specific test runners and frameworks (Jest, Vitest, Pytest, Go testing, JUnit, NUnit, XUnit, RSpec)." **NOT-A-DEFECT**: a genuinely generic cross-ecosystem enumeration in imported Copilot best-practices content that already includes Jest; it is guidance for arbitrary projects, not a statement of this repository's toolchain. It also lives under `.github/` (canonical surface, no-edit) and its vendored bundle copy mirrors it.
- `.github/agents/expert-react-frontend-engineer.agent.md:23` and its vendored copy under `extensions/drm-copilot/resources/customizations/.github/agents/` — "Comprehensive testing with Jest, React Testing Library, Vitest, and Playwright/Cypress." **NOT-A-DEFECT**: a third-party-style React specialist persona describing the React ecosystem broadly (the file also names Vite, Zustand, Redux Toolkit, etc.); Vitest is a correct example in that context. Under `.github/`, no-edit. Neither file is in the owned six-file set.

### Adjacent occurrences the planner should adjudicate (documentation, not instruction mirrors)

- `README.md:303` — toolchain table row "Vitest (Jest in the bundled extension)" — and `README.md:318` — heading "TypeScript (Prettier → ESLint → tsc → Vitest)". Both describe the repository's own TypeScript toolchain and are inaccurate for the same reason as the mirrors (root runner is Jest via `run-jest.cjs`). Not named in issue #422's file list, not bound by any parity test, and not under `.github/`; correcting them is low-risk and keeps the README consistent with the fixed mirrors. Recommended: include in scope as a documentation touch-up, or record as a follow-up if the planner keeps scope minimal.
- Historical artifacts under `docs/features/completed/**` and `docs/features/active/**` (policy audits, plans, specs) mention the Vitest divergence extensively (e.g., accepted divergence "D1" in `docs/features/completed/2026-06-25-port-python-commands-to-typescript-240/`). These are frozen records; do not edit.

## 4. Q3 — Command correctness

Every command named in `.claude/rules/typescript.md`, checked against root `package.json` scripts (lines 26-39):

| Rule line | Command as written | Resolves? | Correct command |
|---|---|---|---|
| 13 | `npm run format` | Yes (`package.json:32`) | No change |
| 14 | `npm run lint` | Yes (`package.json:35`) | No change |
| 15 | `npm run typecheck` | Yes (`package.json:30`) | No change |
| 16 | `npm run test` | Resolves, but to `vscode-test` — the **integration** runner, not unit tests | `npm run test:unit` (canon: `typescript-unit-test.instructions.md:110`; `typescript-code-change.instructions.md:48`) |
| 51 | `npm run test:coverage` | **No such script** | `npm run test:unit:coverage` (`package.json:37`; precedent: `.claude/skills/feature-review-workflow/SKILL.md:107` already names `npm run test:unit:coverage`) |

Important nuance for the regression test (section 5): `npm run test` **does** resolve to a real script, so a pure "named script exists" assertion would not catch line 16. The unit-test command must be asserted semantically (the unit-test line must name `test:unit`), not just existentially.

Adjacent finding (out of #422 fix scope; report only): `.claude/rules/typescript.md:57` names the dependency-cruiser configuration file `.dependency-cruiser.cjs`; no file with that name exists anywhere in the repository (glob `**/.dependency-cruiser.cjs` returns nothing). This is a separate accuracy defect in the same rule file and should be filed or folded in per planner judgment; it is unrelated to the Vitest/Jest divergence.

### `.claude/agents/atomic-executor.md` (lines 18 and 79)

- `Bash(npx vitest *)` allowlists a tool with no local installation; `npx vitest` at the repo root would attempt a registry fetch or fail. Unrunnable as documented.
- Verified precedents for the correct form:
  - The PreToolUse hook `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:66-67` recognizes exactly two TypeScript test-command families as implementation commands: `npm ... (prettier|lint|typecheck|test:unit)` and `npx (prettier|eslint|tsc|jest)`. `jest` — not `vitest` — is the recognized `npx` test tool in the Claude runtime's own enforcement surface.
  - `.claude/skills/feature-review-workflow/SKILL.md:107` names `npm run test:unit:coverage`.
  - Canonical `.github/agents/typescript-engineer.agent.md` names Jest and `npm run test:unit` (lines 8, 32, 111, 126, 133-135). `.claude/agents/typescript-engineer.md` itself names no test command (its allowlist is the broad `Bash(npx *)`), so the canonical typescript-engineer agent and the hook regex are the precedents to follow.
- Recommended correction:
  - Line 18: `"Bash(npx vitest *)"` → `"Bash(npx jest *)"`. This is symmetric with the sibling entries (`npx prettier`, `npx eslint`, `npx tsc`), matches the hook's recognized command family (`enforce-orchestration-preimplementation-gate.ps1:67`), and resolves: `jest ^30.4.2` is a root devDependency and Jest auto-discovers `jest.config.cjs` from the working directory. Caveat stated explicitly: bare `npx jest` bypasses `run-jest.cjs`'s `--testPathPattern`→`--testPathPatterns` alias rewrite and `run-node-tool.cjs`'s `NODE_PATH` augmentation; the executor should pass Jest 30 flag names. I could not execute commands in this research session, so `npx jest` end-to-end behavior is verified by dependency/config inspection, not by a run — the executing agent should confirm with one invocation during implementation.
  - Line 79: `npx vitest` → `npx jest`, keeping the list parallel with line 18. If the planner prefers the wrapper semantics instead, the alternative is adding `"Bash(node run-jest.cjs *)"` and naming `node run-jest.cjs`; this is the exact code path `npm run test:unit` executes (`package.json:36`) and requires no assumptions about Jest config discovery. Primary recommendation remains `npx jest` for allowlist symmetry and hook alignment; rejected alternative recorded here for the planner.

## 5. Q4 — Regression-test surface

### Recommendation

Add one Python test module: `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` (pytest, mirroring the established home for live-tree instruction-contract tests in this repo). It should assert **both** properties:

1. **Framework-token absence.** For each of the six repo-root mirror files, assert the text contains no `vitest` token (case-insensitive) and no `vi.` API token (`vi.spyOn`, `vi.mock`, `vi.resetAllMocks`, `vi.useFakeTimers` — a regex such as `\bvi\.[a-zA-Z]` is sufficient and does not collide with any legitimate content in these files, verified by reading them). The bundled copies do not need separate assertions: the existing parity tests (section 2) transitively extend any repo-root guarantee to the bundles.
2. **Command resolution plus semantic anchors.** Parse root `package.json` `scripts`; extract every `` `npm run <name>` `` token from `.claude/rules/typescript.md`; assert each named script exists. Additionally assert two semantic anchors that pure existence cannot catch: the Testing line of the toolchain section names `npm run test:unit`, and the coverage line names `npm run test:unit:coverage` (rationale in section 4: `npm run test` resolves but is the integration runner).

### Structural precedents (existing tests to model on)

- `tests/scripts/dev_tools/test_codex_orchestration_contracts.py` — pytest module that reads live `.codex`/`.agents` markdown with `read_text(encoding="utf-8")` and asserts required/forbidden substrings (functions at lines 33-95). This is the closest structural twin for the new test's shape.
- `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1:8-14` — Pester precedent for **negative** textual assertions on live `.claude/**` files (`Should -Not -Match 'context:\s*fork'`). If the planner prefers Pester for the `.claude/**` files, this is the file and pattern to follow; however, a single pytest module covering all six files is simpler and matches the parity tests' language.
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` — the parity-lock pattern already covering the bundle halves; the new test intentionally does not duplicate it.

Location conforms to the repository test-location rule (tests live under `tests/` mirroring production structure; the live-tree contract tests for runtime instruction files are established at `tests/scripts/dev_tools/` and `tests/scripts/claude-runtime/`).

## 6. Q5 — Fail-before feasibility

**Achievable, and it is the expected path.** Both recommended assertion families fail deterministically against the current text:

- Token-absence assertions fail today at exactly the known lines: `.claude/rules/typescript.md:16, 42, 47, 51, 73`; `.claude/rules/general-unit-test.md:40, 105`; `.claude/rules/general-code-change.md:39`; `.claude/agents/atomic-executor.md:18, 79`; `.agents/skills/general-unit-test/SKILL.md:45, 110`; `.agents/skills/general-code-change/SKILL.md:44`.
- Command assertions fail today: `npm run test:coverage` (`.claude/rules/typescript.md:51`) resolves to no script, and the Testing toolchain line (`:16`) names `npm run test` rather than `npm run test:unit`.

Sequence: write the test, run it against the current tree and record the failure output as evidence, fix the six repo-root files plus their six bundled copies, re-run the new test plus the two parity tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`) and observe all pass. The parity tests also serve as the built-in check that no bundle edit was missed.

## 7. Requirements mapping (proposed change set)

| File | Change |
|---|---|
| `.claude/rules/typescript.md` | Line 16: "Testing — Jest", command `npm run test:unit`. Line 42: "Use **Jest**". Line 47: `jest.spyOn`/`jest.mock`/`jest.resetAllMocks`. Line 51: `npm run test:unit:coverage`; delete the stale "Prompt B1 / Vitest dependency" parenthetical. Line 73: "Jest fake timers (`jest.useFakeTimers()`)". |
| `.claude/rules/general-unit-test.md` | Line 40: `vitest.config.ts` → `jest.config.cjs`. Line 105: `vi.useFakeTimers()` for Vitest → `jest.useFakeTimers()` for Jest. |
| `.claude/rules/general-code-change.md` | Line 39: Vitest → Jest in the runner list. |
| `.claude/agents/atomic-executor.md` | Line 18: `Bash(npx vitest *)` → `Bash(npx jest *)`. Line 79: `npx vitest` → `npx jest`. |
| `.agents/skills/general-unit-test/SKILL.md` | Lines 45, 110: same as the `.claude/rules/general-unit-test.md` edits. |
| `.agents/skills/general-code-change/SKILL.md` | Line 44: same as the `.claude/rules/general-code-change.md` edit. |
| 6 bundled copies under `extensions/drm-copilot/resources/claude-customizations/.claude/...` (4 files) and `.../codex-and-agents-customizations/.agents/...` (2 files) | Identical edits, byte-for-byte, to satisfy the parity tests. |
| New: `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` | Regression test per section 5, with a fail-before evidence run per section 6. |
| Optional (planner decision): `README.md:303, 318` | Align the repository-facing toolchain table and heading with Jest. |

Non-goal restated: no Vitest migration; the instructions are corrected to describe the Jest toolchain the repository actually runs.

## 8. Rejected alternatives

- **Pester-based regression test** (`tests/scripts/claude-runtime/*.Tests.ps1`): viable and precedented for `.claude/**` negative-match assertions, but would split the six-file assertion across two languages or leave the `.agents/**` files to a second module; a single pytest module matches the parity tests' language and covers all six files in one place.
- **Allowlisting `node run-jest.cjs` in atomic-executor**: exact-wrapper fidelity, but breaks the symmetry of the existing `npx`-form allowlist entries and is not the command family the pre-implementation hook recognizes; retained only as a fallback if `npx jest` proves problematic during implementation.
- **Editing only repo-root files and regenerating bundles by tooling**: no such tooling exists (section 2); manual paired edits are the sanctioned mechanism, enforced by the parity tests.
