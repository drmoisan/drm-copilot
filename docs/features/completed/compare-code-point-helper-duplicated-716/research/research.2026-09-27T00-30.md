# Research: compare-code-point-helper-duplicated (#716)

- Issue: #716
- Branch: bug/compare-code-point-helper-duplicated-716
- Scope: `extensions/drm-copilot/src/lib/pr-context/`

## 1. Current State Analysis

### 1.1 Numeric Derivation Evidence — count of `compareCodePoint` definitions

- **Complete Family:** every function declaration named `compareCodePoint` (private or exported) under `extensions/drm-copilot/src/lib/pr-context/`.
- **Exhaustive Search Scope:** all `.ts` files under `extensions/drm-copilot/src/lib/pr-context/` (18 files; no subdirectories).
- **Inclusion Rules:** a `function compareCodePoint(` or `export function compareCodePoint(` declaration.
- **Exclusion Rules:** call sites (`.sort(compareCodePoint)`), import/re-export statements, and comments that merely mention the name.
- **Primary Search Strategy or Query Expression:** `Grep` for the regex `^(export )?function compareCodePoint\(` over `extensions/drm-copilot/src/lib/pr-context/` (anchored to the declaration keyword, distinguishing it from call sites and imports).
- **Primary Member Set:** `feature-docs-parsers.ts:305` (exported), `gh-client-details.ts:128` (exported), `collector-core.ts:388`, `autoclose.ts:296`, `render-feature-excerpts.ts:439`, `render.ts:381`, `render-pr-helpers.ts:388`, `verification-evidence.ts:274`.
- **Primary Count:** 8.
- **Cross-check Search Strategy or Query Expression:** `Grep` for the literal JSDoc comment `Compare two strings by Unicode code point` (a distinct textual marker that immediately precedes every definition, independent of the function-signature regex used above) over the same directory.
- **Cross-check Member Set:** `collector-core.ts:387`, `autoclose.ts:295`, `feature-docs-parsers.ts:304`, `gh-client-details.ts:127`, `render-pr-helpers.ts:387`, `render.ts:380`, `render-feature-excerpts.ts:438`, `verification-evidence.ts:273`.
- **Cross-check Count:** 8.
- **Member-set Comparison:** both sets name the identical 8 files (`collector-core.ts`, `autoclose.ts`, `feature-docs-parsers.ts`, `gh-client-details.ts`, `render-pr-helpers.ts`, `render.ts`, `render-feature-excerpts.ts`, `verification-evidence.ts`); each comment line is one line above its corresponding declaration line. The sets agree exactly (normalized by filename, ignoring the 1-line comment/declaration offset).

**Conclusion:** the issue's intake observation (8 definitions, not the 7 the original issue body reports) is confirmed by two independent, exhaustive, non-overlapping search strategies. No `compareCodePoint` definition exists anywhere else in the repository (`Grep` for the bare identifier `compareCodePoint` across the full worktree returns matches only inside `extensions/drm-copilot/src/lib/pr-context/`, plus historical mentions in `docs/features/**` prose and one prior research file — no other `src/` or `mcp-server`/`resources` hit; `mcp-server` does not exist in this repository).

### 1.2 Body identity

All 8 definitions were read in full and are byte-identical in signature, JSDoc, and body:

```ts
/** Compare two strings by Unicode code point (Python `sorted` semantics). */
function compareCodePoint(left: string, right: string): number {
  if (left < right) {
    return -1;
  }
  if (left > right) {
    return 1;
  }
  return 0;
}
```

Two of the eight (`feature-docs-parsers.ts:305`, `gh-client-details.ts:128`) additionally carry `export`.

### 1.3 Call sites and import/export edges (exhaustive)

| File | Defines | Exported? | Call sites (same file) | Imports `compareCodePoint` from elsewhere |
|---|---|---|---|---|
| `collector-core.ts` | yes (388) | no | 199, 200, 201, 384 | — |
| `autoclose.ts` | yes (296) | no | 209, 213 | — |
| `feature-docs-parsers.ts` | yes (305) | **yes** | 177 | — |
| `gh-client-details.ts` | yes (128) | **yes** | 124 | — |
| `render.ts` | yes (381) | no | 377 | — |
| `render-pr-helpers.ts` | yes (388) | no | 151, 202 | — |
| `render-feature-excerpts.ts` | yes (439) | no | 362 | — |
| `verification-evidence.ts` | yes (274) | no | 103 | — |
| `feature-docs.ts` | no | — | 99 | `feature-docs-parsers.ts` (import at line 23, re-exported at line 306 in its own named-export list) |

No other file in the repository imports `compareCodePoint`. Specifically:
- `extensions/drm-copilot/src/lib/pr-context/index.ts` (the public barrel) does **not** re-export `compareCodePoint` at all — the two `export function compareCodePoint` declarations in `feature-docs-parsers.ts` and `gh-client-details.ts` are file-local public exports that never reach the package's public surface.
- `gh-client-core.ts` imports `closingIssuesImpl, currentPrImpl, issueDetailsImpl, prDetailsImpl` from `./gh-client-details` but does **not** import `compareCodePoint` (`extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts:30-35`).
- `collector-core.ts` imports `extractIssueReferences` from `./feature-docs-parsers` (line 38) but does **not** import `compareCodePoint`.
- No test file imports `compareCodePoint` from any module. `Grep` for `compareCodePoint` under `extensions/drm-copilot/test/` returns zero matches (test files exercise the behavior only indirectly, through `.sort()` output assertions in modules such as `feature-docs.test.ts`, `render.test.ts`, `render-pr-helpers.test.ts`, `render-feature-excerpts.test.ts`, `verification-evidence.test.ts`, `autoclose.test.ts`, `collector-core.test.ts`, `gh-client-details.test.ts`). `feature-docs.test.ts` imports `completedPlanTasks, extractIssueReferences, parseSection, resolveFeatureDir` from `feature-docs-parsers.ts` — not `compareCodePoint`.
- `mcp-server` and `resources/` do not contain a copy: no directory named `mcp-server` exists in this repository (confirmed by a failed path-glob); `Grep` for `compareCodePoint` under `extensions/drm-copilot/resources/` returns zero matches.

**Consequence for compatibility (item 5):** removing the `export` keyword from `feature-docs-parsers.ts` and `gh-client-details.ts` (or removing the two functions entirely and importing from a shared module) breaks no importer, in-repo or in tests, because nothing consumes either export today.

## 2. Candidate Host Modules

### 2.1 `models.ts` — exists; contains data records and pure helpers, not types-only

`extensions/drm-copilot/src/lib/pr-context/models.ts` (338 total lines / ~308 non-blank) is a port of `dev_tools/pr_context/models.py`. Its own header docstring (lines 1-21) states it holds "the structured records and pure string helpers shared across the pr-context port," and it already exports seven executable pure functions (`section`, `truncate`, `splitLines`, `truncateLines`, `normalizeReference`, `findUserStoryLink`, `formatList`) alongside its interfaces and constants. It is **not** a types-only module, so adding one more pure function does not violate any types-only convention, and it is already inside the per-file `coverageThreshold` map in `jest.config.cjs` (lines 51-54: `lines: 85, branches: 75`), so a coverage-exclusion concern does not apply.

Import graph: `models.ts` imports only `{ type CommandResult }` from `../subprocess-runner` — nothing under `pr-context/`. It is a leaf/base module for the directory: 13 of the other 17 files in `pr-context/` already import from it directly (`autoclose.ts`, `collector-core.ts`, `collector-output.ts`, `feature-docs.ts`, `feature-docs-parsers.ts`, `gh-client-core.ts`, `gh-client-details.ts`, `render.ts`, `render-feature-excerpts.ts`, `render-pr-helpers.ts`, `summary-digests.ts`, `summary-helpers.ts`, `index.ts`). Of the 8 files that currently define `compareCodePoint`, only `verification-evidence.ts` does **not** already import from `models.ts` — every other one of the 8 already has the import edge open and would only need to add a name to an existing import list.

No cycle risk: nothing that `models.ts` imports (transitively, just `../subprocess-runner`) is itself one of the 8 files, so adding `verification-evidence.ts -> models.ts` and widening the other 7 existing edges creates no cycle.

### 2.2 A new dedicated module (e.g. `pr-context/compare.ts`)

Would isolate the helper but requires all 8 consumers (9 counting `feature-docs.ts`, which imports transitively today) to add a **new** import edge to a file that did not previously exist, rather than widening an edge 7 of them already have open. It also duplicates `models.ts`'s stated purpose ("pure string helpers shared across the pr-context port") in a second file, which is not a simplification per `.claude/rules/general-code-change.md` Design Principle 1 (simplicity first) — introducing a second home for the same category of helper without a reason to separate them adds indirection without benefit.

### 2.3 Keep it in one of the two currently-exporting files (`feature-docs-parsers.ts` or `gh-client-details.ts`)

Rejected: neither file's stated purpose is generic string comparison. `feature-docs-parsers.ts` is "pure parsing helpers for the collector feature-docs variant," and `gh-client-details.ts` is "GitHub CLI issue/PR detail fetches." Routing `render.ts`, `render-feature-excerpts.ts`, `render-pr-helpers.ts`, `collector-core.ts`, `autoclose.ts`, and `verification-evidence.ts` through either of these unrelated, narrower modules for a single comparator function is a weaker conceptual fit than `models.ts` and would create an import edge from render/collector modules to a GitHub-CLI-specific or feature-doc-parsing-specific file for no domain reason.

### Recommendation

Move the single definition into `models.ts`, exported as `compareCodePoint`, placed among the other pure string helpers (for example, immediately after `formatList`). This matches the issue's own suggestion ("for example, in `models.ts`"), matches `models.ts`'s existing stated purpose, requires the fewest new import edges (7 of 8 consumers already import from `models.ts`; only `verification-evidence.ts` needs a new edge), and creates no import cycle. **Rejected alternatives:** a new dedicated module (more new edges, duplicate "shared helper" home); keeping it in `feature-docs-parsers.ts` or `gh-client-details.ts` (poor conceptual fit for unrelated consumers).

## 3. Reuse Check Outside `pr-context/`

No existing generic string-comparator utility module exists elsewhere under `extensions/drm-copilot/src/lib/` that `pr-context/` could import instead of defining its own. `pr-context/` has no reason to depend on a sibling feature directory for a two-line pure function, and no such shared `util`/`comparators` module exists in the repository today.

**Out-of-scope duplicates noted, not remediated:** the identical `left < right ? -1 : left > right ? 1 : 0` (or equivalent if/if/return-0) pattern recurs as private, differently-named helpers in other directories, each already local to its own file and not sharing a name with `compareCodePoint`:
- `extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts:36` (`compareStrings`)
- `extensions/drm-copilot/src/lib/codex-native-converter/reporting.ts:148-149` (inline `compare`)
- `extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts:46-47` (`compareStrings`)
- `extensions/drm-copilot/src/lib/codex-native-converter/validation.ts:359-360` (inline `compare`)
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts:121-122` (`compareOrdinal`)
- `extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts:141-142` (inline sort comparator)
- `extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts:132` (inline comparator)
- `extensions/drm-copilot/src/lib/codex-native-converter/pipeline.ts:93`, `inventory.ts:168-169,238-239,293-294` (inline comparators)

These are a distinct, larger, cross-cutting duplication pattern spanning at least two other feature directories (`codex-native-converter`, `push-down`) with different function names and no existing shared home. Issue #716's scope, spec header, and acceptance criteria are explicitly limited to `extensions/drm-copilot/src/lib/pr-context/`; consolidating these additional copies is out of scope for this fix and is flagged only as an observation for a possible separate follow-up issue.

## 4. Testing Landscape

- **Test root:** this npm package uses `extensions/drm-copilot/test/` (singular), not `tests/` — an established, pre-existing per-package convention (`jest.config.cjs:4`: `testMatch: ["**/test/**/*.test.ts"]`). This diverges textually from the general `tests/` wording in `.claude/rules/general-unit-test.md`, but it is the existing convention for this whole package (all 21 files under `extensions/drm-copilot/test/lib/pr-context/` follow it) and is not something this bug fix should change.
- **Existing pr-context tests:** `extensions/drm-copilot/test/lib/pr-context/` contains `autoclose.test.ts`, `collector-core-autoclose.test.ts`, `collector-core.test.ts`, `collector-integration.test.ts`, `collector-output*.test.ts`, `diff-emptiness.test.ts`, `feature-docs.test.ts`, `gh-client-core.test.ts`, `gh-client-details.test.ts`, `git-client.test.ts`, `issue-reference-pattern.test.ts`, `models.test.ts`, `pr-context-service-call*.test.ts`, `render-feature-excerpts.test.ts`, `render-pr-helpers.test.ts`, `render.test.ts`, `summary-helpers.test.ts`, `verification-evidence.test.ts`, plus the shared `tree-file-system.ts` fixture helper.
- **No test targets `compareCodePoint` directly today** — confirmed by an exhaustive `Grep` of the entire `test/` tree for the literal `compareCodePoint` (zero matches). Every existing exercise of the function is indirect, through the sorted output of the module under test.
- **`models.test.ts` pattern:** `describe`/`it` blocks per pure function, Arrange-Act-Assert, plain Jest (`@jest/globals`), no property-based framework used yet in this file (`section`, `truncate`, `truncateLines` are each covered by hand-picked boundary cases). This is the natural place to add `describe("compareCodePoint", ...)` following the same style, once the function moves to `models.ts`.
- **`fast-check` is not installed.** `Grep` for the literal `"fast-check"` across the entire worktree (root `package.json`, `extensions/drm-copilot/package.json`, and every other file) returns zero matches. `extensions/drm-copilot/package.json` `devDependencies` (lines 228-241) list only `@eslint/js`, `@jest/globals`, `@types/jest`, `@types/node`, `@types/vscode`, `esbuild`, `eslint`, `jest`, `prettier`, `ts-jest`, `typescript`, `typescript-eslint` — no `fast-check`.
- **Quality tier / `quality-tiers.yml`:** no `quality-tiers.yml` file exists anywhere in this repository (two independent globs — one for the literal root path, one recursive — both return no results). `.claude/rules/quality-tiers.md` and `.claude/rules/general-code-change.md` both reference `quality-tiers.yml` as the source of truth for per-project tiering, but the file itself is absent from this checkout, so `extensions/drm-copilot`'s tier cannot be confirmed from that source. This is a pre-existing repository-wide gap, not something introduced by or in scope for this issue.
- **Dependency-cruiser / architecture-boundary tooling:** no `.dependency-cruiser.cjs` exists anywhere in the repository (confirmed by glob and corroborated by a prior baseline artifact, `docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-depcruise-config-absence.2026-08-20T18-54.md`, and by the #622 code-review NB-9 observation dated 2026-09-26). Stage 4 of the seven-stage toolchain therefore has no tool to run against this change; this is a pre-existing, previously documented gap, not introduced by this fix.
- **Coverage thresholds:** `jest.config.cjs` uses per-file `coverageThreshold` entries only (no `global` key). `models.ts` already carries an entry (`lines: 85, branches: 75`). The 7 files losing their private `compareCodePoint` definition each already carry (or in `verification-evidence.ts`'s case, does **not** yet carry) a per-file entry — checked: `verification-evidence.ts` has no entry in the current `coverageThreshold` map, so its coverage is measured (via `collectCoverageFrom`) but not gated by a per-file threshold today; this fix does not need to add one, but should not regress its measured coverage.

**Requirements-mapping implication:** issue AC3 requires the moved helper to be "covered by a unit test, including a property-based test." Since `fast-check` is not present in this npm workspace, the plan must either (a) add `fast-check` as a new `devDependency` of `extensions/drm-copilot` — justified because `.claude/rules/typescript.md` and `.claude/rules/general-unit-test.md` already name `fast-check` as the repository's designated TypeScript property-testing library, so this is formalizing an already-sanctioned tool rather than introducing an unapproved one — or (b) flag the AC as unsatisfiable without that addition and get explicit sign-off to test `compareCodePoint` with hand-picked cases only. Given the general-code-change.md dependency policy ("choose a well-maintained, widely used package and document why it is required"), option (a) is the straightforward path: `fast-check` is well-maintained, widely used, and is the exact tool the repo's own rules already name for this purpose.

## 5. File-Size Check (500-line cap)

Approximate non-blank line counts today: `collector-core.ts` 369, `render.ts` 382, `render-pr-helpers.ts` 391, `render-feature-excerpts.ts` 424, `verification-evidence.ts` 282, `autoclose.ts` 290, `gh-client-details.ts` 368, `feature-docs-parsers.ts` 306, `models.ts` 308. Removing a private ~9-line function (or an ~9-line exported one, in the two exporting files) and adding one identifier to an existing import statement is a net decrease for all 8 source files. `models.ts` gains roughly 9-10 lines (the function plus its JSDoc), landing at roughly 317-318 — well under the 500-line cap. No file approaches the limit as a result of this change.

## 6. Mirror / Bundled-Copy Check

No mirrored copy of these TypeScript sources exists. `Grep` for `pr-context` under `extensions/drm-copilot/resources/` matches only unrelated Codex agent `.toml` prompt files (which reference the pr-context *tool* by name in prose, not a copy of its source) — there is no `resources/` tree that re-bundles `src/lib/pr-context/*.ts` verbatim, and no parity test comparing a bundled copy to `src/` was found for this directory. No Python analog of this duplication exists either: `dev_tools/pr_context/*.py` uses the built-in `sorted()`, not a custom comparator, so there is no cross-language copy to keep in sync for this specific function.

## 7. Merge-Order Risk — Frequent Edit Targets

`extensions/drm-copilot/src/lib/pr-context/` files are touched by several other in-flight active features referenced under `docs/features/active/`:
- `collect-pr-context-fabricates-auto-close-issues-622` — heavily edits `autoclose.ts`, `render-pr-helpers.ts`, `render.ts`, `collector-core.ts`, `models.ts` (this is the feature whose code review, NB-4, is the direct source of issue #716).
- `2026-08-28-pr-context-gh-detection-false-negative-588` — edits pr-context gh-detection paths (`gh-client-core.ts`/`gh-client-details.ts` family).
- `2026-09-06-collect-pr-context-omits-claude-tree-633` — edits collector/output paths.
- `2026-09-13-collect-pr-context-explicit-target-675` — edits collector/render paths (this is the feature that added `diff-emptiness.ts`, per the existing `coverageThreshold` comment at `jest.config.cjs:312-318`).

Given this, `autoclose.ts`, `render.ts`, `render-pr-helpers.ts`, `collector-core.ts`, and `gh-client-details.ts`/`gh-client-core.ts` are the highest-risk files for concurrent edits landing in parallel with this fix.

**Recommended edit strategy:** anchor every edit to unique, stable text rather than line numbers, since a parallel branch touching the same file shifts line numbers:
- For each of the 8 files, anchor the removal on the full function body text (the byte-identical block reproduced in section 1.2), which is unique per file and will not silently mismatch even if surrounding lines move.
- For the import-list edits, anchor on the existing `} from "./models";` closing line (present in 7 of the 8 files already) or the full existing import statement text, not a line number, when adding `compareCodePoint` to the imported-name list.
- For `verification-evidence.ts` (the one file with no existing `models.ts` import), anchor the new `import { compareCodePoint } from "./models";` insertion on the existing `import { type FileSystem, toPosixPath } from "../file-system";` line (its current only import), rather than a line number.
- For the two `export` removals (`feature-docs-parsers.ts`, `gh-client-details.ts`), anchor on the full `export function compareCodePoint(...) { ... }` block text for deletion, and separately anchor the import-list edit on each file's existing `from "./models"` import block.
- Because a parallel PR may add or remove other functions in the same file, prefer a plan structured as many small, per-file, text-anchored edits (one edit per file) over a single multi-file patch, so a merge conflict in one file does not block the rest.

## 8. Requirements Mapping Summary

| Issue AC | Design mapping |
|---|---|
| "Exactly one definition ... exported from a single shared module." | Define `compareCodePoint` once, exported, in `models.ts`. Delete the other 7 (including removing `export` from the 2 that had it) along with their preceding JSDoc comment. |
| "Every module ... imports it from that shared module; no private copy remains." | Update the import list in the 7 files that already import from `./models` to add `compareCodePoint`; add a new `./models` import in `verification-evidence.ts`. `feature-docs.ts` already imports `compareCodePoint` from `feature-docs-parsers.ts` (line 23) and re-exports it (line 306) — update that import to `./models` and, since `feature-docs.ts`'s own re-export at line 306 has no external consumer (see section 1.3), either keep it pointed at the same name sourced from `models.ts` or drop the re-export; no importer breaks either way. |
| "Ordering behavior is unchanged ... covered by a unit test, including a property-based test." | Keep the exact body (section 1.2). Add `describe("compareCodePoint", ...)` to `models.test.ts` following its existing Arrange-Act-Assert style; add a `fast-check` property test (see section 4's dependency note) asserting antisymmetry/totality/consistency-with-`<`/`>` over arbitrary string pairs. |
| "PR-context output ordering is unchanged: the existing pr-context test suite passes without changes to expected output." | No behavior change (identical function body moved, not rewritten); run the full existing `extensions/drm-copilot/test/lib/pr-context/` suite unmodified as regression evidence. |
| "Full TypeScript toolchain ... passes, with no coverage regression on changed lines." | Run Prettier, ESLint, `tsc`, Jest with coverage in order per `.claude/rules/typescript.md`; dependency-cruiser has no config in this repo (section 4) so stage 4 has no tool to execute — record that as a pre-existing gap, not a new failure, consistent with the #622 code review's own NB-9 finding. |

## File Paths Referenced

- `extensions/drm-copilot/src/lib/pr-context/models.ts`
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts`
- `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`
- `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts`
- `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts`
- `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts`
- `extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts`
- `extensions/drm-copilot/src/lib/pr-context/render.ts`
- `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts`
- `extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts`
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`
- `extensions/drm-copilot/src/lib/pr-context/index.ts`
- `extensions/drm-copilot/test/lib/pr-context/models.test.ts`
- `extensions/drm-copilot/jest.config.cjs`
- `extensions/drm-copilot/package.json`
