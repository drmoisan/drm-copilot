# Research: pr-context helper duplication and vacuous tests (Issue #740)

- Timestamp: 2026-09-29T22-25
- Issue: #740
- Branch: bug/pr-context-helper-duplication-and-vacuous-tests-740
- Work mode: minor-audit
- Requirements source: `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/issue.md`
- Scope of this document: research only. No production code or tests were modified.

All paths below are repository-relative. The TypeScript extension root is `extensions/drm-copilot/` (abbreviated `ext/` in tables). Line numbers were read from the worktree at the time of writing.

## 1. Current State Analysis

### 1.1 `compareCodePoint` (question A)

Definition, `extensions/drm-copilot/src/lib/pr-context/models.ts:339-348`:

```ts
/** Compare two strings by Unicode code point (Python `sorted` semantics). */
export function compareCodePoint(left: string, right: string): number {
  if (left < right) { return -1; }
  if (left > right) { return 1; }
  return 0;
}
```

- The JSDoc claims Unicode code-point order. The body uses the JavaScript relational operators, which compare UTF-16 code units. MDN (`Operators/Less_than`) states: "If both values are strings, they are compared as strings, based on the values of the UTF-16 code units (not Unicode code points) they contain", with the example `"𥙑" < "Ｚ"; // true`.
- Python's language reference (Expressions, Value comparisons) states: "Strings (instances of `str`) compare lexicographically using the numerical Unicode code points (the result of the built-in function `ord()`) of their characters."
- The two orders disagree only when, at the first differing position, one string has a supplementary character (U+10000..U+10FFFF, encoded as a surrogate pair starting 0xD800..0xDBFF) and the other has a BMP character in U+E000..U+FFFF. UTF-16 order places the supplementary character first; code-point order places it last. Example: `"￿"` vs `"\u{1F600}"` — UTF-16: `0xD83D < 0xFFFF`, so the emoji sorts first; code point: `0xFFFF < 0x1F600`, so `"￿"` sorts first.
- The models.ts header (`models.ts:11-20`) lists the pure helpers `section`, `truncate`, `truncateLines`, `normalizeReference`, `findUserStoryLink`, `formatList`; it lists neither `compareCodePoint` nor `splitLines` (nit 5 is confirmed and slightly wider than stated).

Call sites (every production reference; verified by grep of `compareCodePoint` under `ext/src`):

| File | Line(s) | Use |
|---|---|---|
| `pr-context/autoclose.ts` | 26 (import), 210, 214 | author auto-close list; referenced-only list |
| `pr-context/collector-core.ts` | 22 (import), 200, 201, 202, 385 | referenced issues/PRs/invalid refs; local `sortedSet` |
| `pr-context/feature-docs.ts` | 23 (import), 103, 310 | feature iteration order; context-files set |
| `pr-context/feature-docs-parsers.ts` | 20 (import), 181, 277 | `latestGlobPath`; `resolveReadinessSignal` |
| `pr-context/gh-client-details.ts` | 18 (import), 124 | local `sortedSet` |
| `pr-context/verification-evidence.ts` | 22 (import), 104 | evidence file discovery order |
| `pr-context/render-feature-excerpts.ts` | 20 (import), 363 | feature iteration order |
| `pr-context/render.ts` | 19 (import), 378 | local `sortedSet` |
| `pr-context/render-pr-helpers.ts` | 20 (import), 152, 203 | extension summary; merge PR numbers |

No module outside `src/lib/pr-context/` imports `compareCodePoint`.

### 1.2 Tests of `compareCodePoint` (question B)

File: `extensions/drm-copilot/test/lib/pr-context/models.test.ts` (237 lines).

- `describe("compareCodePoint", ...)` at lines 150-174: six fixed-expectation example tests, all ASCII. They pass under both orderings.
- `describe("compareCodePoint - enumerative properties over a fixed domain", ...)` at lines 176-237, domain `["", "a", "A", "aa", "ab", "b", "ba", "é", "😀"]` (line 177). The domain contains no character in U+E000..U+FFFF, so no pair in it distinguishes UTF-16 order from code-point order.

Vacuous tests (cannot detect a regression to or from UTF-16 order):

1. Line 215, `"agrees with the native < and > operators for every ordered pair in the domain"` — the expectation is computed with the same `<`/`>` operators the implementation uses, so it is a tautology for the current body.
2. Line 230, `"produces the same order as native comparison via Array.prototype.sort, including an astral surrogate-pair string"` — the expected array is produced by a native `<`/`>` comparator (lines 232-234); the sample `["b", "😀", "a", "é", "", "A", "ab"]` has no U+E000..U+FFFF character, so it would pass under either ordering.

Antisymmetry test without diagnostics:

3. Line 185, `"is antisymmetric for every ordered pair in the domain"` — asserts `expect(forward === -backward).toBe(true)` (line 190). A failure reports `expected true, received false` with no indication of the pair.

Property-test tooling: `fast-check` is not installed. `extensions/drm-copilot/package.json:228-241` devDependencies contain no `fast-check`; the only `fast-check` string in `package-lock.json` (line 6272) is the funding URL of `pure-rand` (a Jest transitive dependency). No test file imports `fast-check`. The existing "properties" are enumerative over a fixed domain. Adding `fast-check` would be a new dependency, which `.claude/rules/general-code-change.md` (Dependencies) restricts; it is not needed for this fix.

### 1.3 Duplicated helpers (question C)

Every definition in `src/lib/pr-context/` (see Numeric Derivation Evidence for the enumeration method):

| Helper | Location | Signature | Body |
|---|---|---|---|
| `sortedSet` | `collector-core.ts:383-386` | `(values: Iterable<string>): string[]` | `[...new Set(values)].sort(compareCodePoint)` |
| `sortedSet` | `render.ts:376-379` | `(values: Iterable<string>): string[]` | identical |
| `sortedSet` | `gh-client-details.ts:115-125` | `(values: string[]): string[]` | identical |
| `relativeToPosix` | `feature-docs-parsers.ts:290-306` (exported) | `(root, path)` | normalizes `root` (`toPosixPath` + strip trailing `/`), then prefix-strip or strip leading `/` |
| `relativeToPosix` | `verification-evidence.ts:259-272` | `(root, absolute)` | same, but does not normalize `root` |
| `relativeToPosix` | `render-feature-excerpts.ts:430-437` | `(root, path)` | same, but does not normalize `root` |
| `escapeRegExp` | `feature-docs-parsers.ts:308-316` | `(value)` | `value.replace(/[.*+?^${}()\|[\]\\]/gu, "\\$&")` |
| `escapeRegExp` | `render-feature-excerpts.ts:439-442` | `(value)` | identical |
| `splitLines` | `models.ts:211-236` (exported) | `(value)` | `""` -> `[]`; split `/\r\n\|\r\|\n/u`; pop one trailing empty element when the text ends with a terminator |
| `splitLines` | `verification-evidence.ts:274-293` | `(value)` | identical |
| `splitLines` | `render.ts:381-400` | `(value)` | identical |
| `splitLines` | `render-pr-helpers.ts:388-407` | `(value)` | identical |

Behavioral equivalence findings:

- `sortedSet`: bodies are identical. The `string[]` parameter in `gh-client-details.ts` is assignable to `Iterable<string>`; its two call sites (`gh-client-details.ts:332`, `:384`) pass arrays. The `Iterable<string>` signature serves all callers. Two further inline equivalents exist: `autoclose.ts:210` (`[...new Set(authorAsserted)].sort(compareCodePoint)`) and `feature-docs.ts:309-311` (`[...new Set([...contextFiles, ...evidenceContextFiles])].sort(compareCodePoint)`). `autoclose.ts:212-214` filters between dedupe and sort and is not a `sortedSet` equivalent.
- `relativeToPosix`: argument order is `(root, path)` in all three. The two private copies skip root normalization, but both callers already pass a normalized root (`verification-evidence.ts:89` and `:100`; `render-feature-excerpts.ts:357` and `:411`). The canonical copy's normalization is idempotent on a normalized root, so replacing the private copies with the exported one produces identical output at every current call site. The seven `relativeToPosix` functions in `src/lib/push-down/` have the opposite argument order `(path, root)` and return `string | null | undefined`; they are different functions that share a name and are out of scope.
- `escapeRegExp`: identical. It escapes fewer characters than Python `re.escape` (which also escapes `-`, `#`, `&`, `~`, and whitespace), but the unescaped characters are literal outside a character class, and escaping `-` would be a syntax error under the `u` flag. Match behavior is equivalent for the heading/feature patterns in use.
- `splitLines`: all four bodies are identical, including CRLF handling. All four JSDoc blocks claim Python `str.splitlines()` semantics, which is inaccurate: Python also splits on `\v`, `\f`, `\x1c`, `\x1d`, `\x1e`, `\x85`, ` `, ` ` (Python docs, `str.splitlines` line-boundary table). This is the same class of defect as the `compareCodePoint` JSDoc. `render.ts` and `render-pr-helpers.ts` already import from `./models` yet define a private `splitLines`.

Other in-module duplications observed but not listed in the issue (out of scope; they mirror the Python module structure): `parseSection` (`feature-docs-parsers.ts:34`, `render-feature-excerpts.ts:50`, `summary-helpers.ts:370`), `extractIssueReferences` (`feature-docs-parsers.ts:83`, `render-feature-excerpts.ts:73`, `render-pr-helpers.ts:167`), `resolveFeatureDir` (`feature-docs-parsers.ts:113`, `render-feature-excerpts.ts:136`, `render.ts:98`), `completedPlanTasks` (2), `formatDiffPath` (2), `errorMessage` (2), `isDigits` (2). Copies of `escapeRegExp`/`splitLines` also exist outside pr-context (`file-system.ts:147`, `validate/policy-audit-artifact.ts:254`, `codex-native-converter/rewrites-rules.ts:28`, `potential-to-issue/content.ts:76`, `new-active-feature-folder/markdown.ts:26,39`, `markdown-label-formatter.ts:43`, `validate/plan-gate-commands.ts:262`, `codex-native-converter/parser.ts:70`).

### 1.4 pr-context import graph (value and type imports, from each file's import block)

| Module | Imports from pr-context |
|---|---|
| `models.ts` | none (only `type CommandResult` from `../subprocess-runner`) |
| `feature-docs-parsers.ts` | `models` (+ `../file-system`) |
| `verification-evidence.ts` | `models` (+ `../file-system`) |
| `render-feature-excerpts.ts` | `models` (+ `../file-system`) |
| `render-pr-helpers.ts` | `models`, `git-client` (type), re-export from `autoclose` |
| `render.ts` | `models`, `git-client` (type), `render-pr-helpers`, `render-feature-excerpts` |
| `feature-docs.ts` | `models`, `feature-docs-parsers`, `verification-evidence` |
| `autoclose.ts` | `models`, `gh-client-core` (type) |
| `gh-client-details.ts` | `models` (two statements, lines 18-19), `gh-client-core` |
| `gh-client-core.ts` | `models` (type), `gh-client-details` |
| `collector-core.ts` | `models`, `git-client`, `gh-client-core`, `render`, `autoclose`, `render-pr-helpers`, `feature-docs`, `feature-docs-parsers`, `summary-helpers` |

Cycle analysis for the proposed edges:

- `models.ts` imports nothing from pr-context, so any pr-context module can import `sortedSet`, `escapeRegExp`, `splitLines` from `./models` without creating a cycle.
- `feature-docs-parsers.ts` imports only `./models` and `../file-system`. New edges `verification-evidence -> feature-docs-parsers` and `render-feature-excerpts -> feature-docs-parsers` cannot close a cycle.
- One cycle already exists and is unaffected: `gh-client-core.ts:30-35` imports `gh-client-details`, and `gh-client-details.ts:20-25` imports values from `gh-client-core`.

### 1.5 Comparators in `codex-native-converter/` and `push-down/` (question D)

Named comparators cited by the issue:

| Location | Name | Body |
|---|---|---|
| `codex-native-converter/engine-pipeline.ts:46-48` | `compareStrings` (private) | `left < right ? -1 : left > right ? 1 : 0` |
| `codex-native-converter/reporting-render.ts:36-38` | `compareStrings` (private) | identical |
| `codex-native-converter/reporting.ts:148-149` | local `compare` arrow | identical |
| `codex-native-converter/validation.ts:359-360` | local `compare` arrow | identical |
| `push-down/claude-blast-radius-derive-manifests.ts:121-123` | `compareOrdinal` (exported; also used in `claude-blast-radius-derive-core.ts`, `claude-blast-radius-overlay.ts`) | identical |

All five implement UTF-16 code-unit order, the same ordering the current `compareCodePoint` implements. A broader grep for the inline pattern `< x ? -1 :` under `ext/src` found 24 matching lines across `codex-native-converter/` (intermediate-state, inventory x3, models, pipeline x3, pipeline-traces x3, reporting x3, validation x2, engine-pipeline, reporting-render), `push-down/` (claude-blast-radius-derive, claude-blast-radius-derive-manifests, copilot-customizations-engine x2, filesystem-adapter), and `subagent-tree/quick-pick-labels.ts:132`. Some (`pipeline.ts:148,151`, `pipeline-traces.ts:112-118`) are two-way and not full comparators.

No module under `src/lib/pr-context/`, `src/lib/push-down/`, or `src/lib/codex-native-converter/` imports from either of the other two (grep for `from "../(pr-context|push-down|codex-native-converter)/"` under `src/lib` returned no matches). `src/lib/` root holds subsystem-neutral modules (`file-system.ts`, `subprocess-runner.ts`, `markdown-label-formatter.ts`), which is the natural home for a future shared comparator.

### 1.6 Python parity port (questions A and E)

Location: `scripts/dev_tools/pr_context/` (13 modules); tests in `tests/scripts/dev_tools/pr_context/` (6 test modules; no `test_models.py`).

- Ordering: every string sort uses built-in `sorted()` on `str`, which is code-point order — for example `collector.py:171,174,206-208,232,250,350`, `github.py:183,493`, `render.py:182,218-221,332-333`, `render_pr_helpers.py:99,130,219-220`, `feature_docs.py:215,350`. There is no custom comparator, so there is no mis-documented comparator.
- Several sorts operate on `Path` objects rather than strings: `feature_docs.py:63,101,186`, `render.py:92`, `render_feature_excerpts.py:74`, `verification_evidence.py:100`. `PurePath` ordering compares path parts (case-folded on Windows), not the joined string, so these Python sorts can differ from the TypeScript string sorts for names such as `a-b/x` vs `a/x`. This is a pre-existing parity divergence independent of the UTF-16 question. The final `context_files` list is re-sorted as strings (`feature_docs.py:350`), which limits the visible effect.
- Helpers: Python uses the standard library (`re.escape`, `Path.relative_to(...).as_posix()`, `str.splitlines()`, `sorted(set(...))`), so the four duplicated TypeScript helpers have no hand-rolled Python counterparts. Python does duplicate `parse_section` (`feature_docs.py:14`, `summary_helpers.py:364`, `render_feature_excerpts.py:15`) and the feature-dir resolver (`feature_docs.py:54`, `render.py:79`, `render_feature_excerpts.py:61`); the TypeScript duplicates listed in 1.3 mirror these.
- Tests: no Python test exercises sort ordering as a property; the only `sorted(` in the Python tests (`test_autoclose_collector.py:419`) normalizes call order for an assertion. No `hypothesis` usage. No vacuous comparator tests exist.
- A coverage-annotation artifact `scripts/dev_tools/pr_context/render.py,cover` is present in the worktree; `.gitignore` contains no `,cover` pattern. Whether it is tracked was not verified (git was not run).

### 1.7 Golden, snapshot, and parity fixtures (question A)

- No test under `ext/test/lib/pr-context/` uses `toMatchSnapshot`, and no golden or parity fixture exists for PR-context output. `ext/test/fixtures/` holds only two `collect_commit_context.*.fixture.txt` files.
- Grep for supplementary-plane characters or `\u{1...}` / `\uD8..` escapes under `ext/test` found only `models.test.ts:177` and `:231`. Grep for U+E000..U+FFFF characters under `ext/test` found only `test/lib/subprocess-runner.test.ts:105` (U+FFFD in an unrelated module).
- Conclusion: switching to code-point order changes no existing test expectation. Both vacuous tests (lines 215 and 230) would still pass after the switch because their data contains no distinguishing pair; they are replaced regardless.

## 2. Candidate Approaches

### 2.1 Ordering contract

Selected: implement true code-point order and document it.

- Matches the Python port, which the TypeScript module header (`models.ts:5-9`) says it mirrors exactly.
- Matches UTF-8 byte order, so results agree with other runtimes and tools that sort by bytes or code points.
- The issue's proposed fix direction names code point as the safer choice.
- Observable change is limited to strings that differ first at a supplementary character versus a U+E000..U+FFFF character (for example fullwidth forms U+FF01..U+FF5E, U+FFFD, private-use characters versus emoji in branch names, paths, or labels). No current fixture contains such a pair.

Recommended implementation (no allocation; examines only the first differing code unit):

```ts
/**
 * Compare two strings by Unicode code point, matching Python `str` ordering.
 *
 * JavaScript `<` compares UTF-16 code units, which misorders a supplementary
 * character (surrogate pair) against a BMP character in U+E000..U+FFFF. This
 * comparator finds the first differing code unit and compares the code points
 * at that index instead.
 */
export function compareCodePoint(left: string, right: string): number {
  const sharedLength = Math.min(left.length, right.length);
  for (let index = 0; index < sharedLength; index += 1) {
    if (left.charCodeAt(index) !== right.charCodeAt(index)) {
      return left.codePointAt(index)! < right.codePointAt(index)! ? -1 : 1;
    }
  }
  if (left.length === right.length) {
    return 0;
  }
  return left.length < right.length ? -1 : 1;
}
```

Correctness argument for well-formed UTF-16: at the first differing index the preceding units are equal, so either both units are lead positions (codePointAt returns full code points, including `>= 0x10000` for a surrogate pair versus `<= 0xFFFF` for a BMP unit) or both are trail surrogates after an identical lead (their raw values order the same as the full code points). The two codePointAt values are therefore always different inside the branch, so it never needs to return 0. The non-null assertion matches existing usage in `models.ts:293,311`.

Performance: O(min(len)) per comparison, same complexity as the native comparison, with a constant-factor cost for the JavaScript loop. The sorted inputs are small (issue references, feature names, a handful of file paths), so the cost is not material. An `Array.from(str)` implementation was rejected because it allocates two arrays per comparison, O(k log k) times per sort.

Rejected alternative: keep UTF-16 order and correct the JSDoc. It is simpler but leaves a documented divergence from the Python port the module claims to mirror, and the issue recommends code point.

### 2.2 Helper consolidation

Selected: reuse the two existing exported homes; do not add a new module.

- `models.ts` (already "Shared models and pure helpers", no pr-context dependencies): canonical home for `compareCodePoint`, `splitLines` (already exported), and newly exported `sortedSet` and `escapeRegExp` (pure string helpers with no dependencies other than `compareCodePoint`).
- `feature-docs-parsers.ts`: canonical home for `relativeToPosix` (already exported and already consumed by `feature-docs.ts:34`). Keeping it here avoids adding a runtime import of `../file-system` (which loads `node:fs`, `node:path`) to `models.ts`, which today has only a type import.
- The new edge `render-feature-excerpts -> feature-docs-parsers` joins the render-variant and collector-variant modules. It is acyclic (section 1.4) and `collector-core.ts` already crosses the variants in the other direction (`collector-core.ts:31,37`).

Rejected alternative: a new `pr-context/shared-helpers.ts` for all four helpers. It adds a file and a second "shared helpers" location next to `models.ts` without resolving any cycle; `relativeToPosix` would still need `../file-system`.

Optional, low-risk inclusion: replace the two inline equivalents (`autoclose.ts:210`, `feature-docs.ts:309-311`) with `sortedSet`. Behavior is identical.

## 3. Behavior Semantics

- `compareCodePoint(a, b)` returns exactly `-1`, `0`, or `1`; `0` if and only if `a === b`; ordering equals Python `sorted()` on `str` for well-formed strings; a proper prefix sorts first.
- `sortedSet(values)` returns the distinct values sorted by `compareCodePoint`; accepts any `Iterable<string>`; does not mutate the input.
- `escapeRegExp(value)` escapes `. * + ? ^ $ { } ( ) | [ ] \`, and the result is valid in `new RegExp(..., "u")`.
- `splitLines(value)` splits on `\r\n`, `\r`, `\n` only; returns `[]` for `""`; drops one trailing empty element when the text ends with a terminator. JSDoc must state this terminator set and that it is a subset of Python `str.splitlines()` boundaries. Extending it to the full Python set is a behavior change and is deferred.
- `relativeToPosix(root, path)` returns the POSIX path relative to the normalized root, or the POSIX path with leading slashes stripped when `path` is not under `root` (Python `relative_to` would raise instead; the JSDoc "Mirrors Python" line should note this fallback).
- Rendered PR-context output is unchanged for all inputs without a supplementary-versus-U+E000..U+FFFF first difference.

## 4. Requirements Mapping and File Changes

| File | Current lines | Change | Expected direction |
|---|---|---|---|
| `ext/src/lib/pr-context/models.ts` | 348 | reimplement and re-document `compareCodePoint`; export `sortedSet`, `escapeRegExp`; correct `splitLines` JSDoc; list `splitLines`, `compareCodePoint`, `sortedSet`, `escapeRegExp` in header | about +35 (about 383; under 500) |
| `ext/src/lib/pr-context/collector-core.ts` | 386 | delete private `sortedSet`; import from `./models` | about -4 |
| `ext/src/lib/pr-context/render.ts` | 400 | delete private `sortedSet`, `splitLines`; import from `./models` | about -25 |
| `ext/src/lib/pr-context/gh-client-details.ts` | 387 | delete private `sortedSet`; merge the two `./models` imports (lines 18-19) into one statement | about -12 |
| `ext/src/lib/pr-context/render-pr-helpers.ts` | 407 | delete private `splitLines`; import from `./models` | about -20 |
| `ext/src/lib/pr-context/verification-evidence.ts` | 293 | delete private `relativeToPosix`, `splitLines`; import from `./feature-docs-parsers` and `./models` | about -34 |
| `ext/src/lib/pr-context/render-feature-excerpts.ts` | 442 | delete private `relativeToPosix`, `escapeRegExp`; import from `./feature-docs-parsers` and `./models` | about -13 |
| `ext/src/lib/pr-context/feature-docs-parsers.ts` | 316 | delete private `escapeRegExp`; import from `./models`; correct `relativeToPosix` JSDoc | about -8 |
| `ext/src/lib/pr-context/feature-docs.ts` (optional) | 312 | use `sortedSet` at 309-311 | about -2 |
| `ext/src/lib/pr-context/autoclose.ts` (optional) | 294 | use `sortedSet` at 210 | 0 |
| `ext/test/lib/pr-context/models.test.ts` | 237 | replace tests at 215 and 230; add diagnostics to 185; add non-BMP cases; add `sortedSet`, `escapeRegExp`, `splitLines` tests | about +90 (under 500) |
| `ext/test/lib/pr-context/feature-docs.test.ts` | 311 | add direct `relativeToPosix` tests | about +30 |
| `ext/jest.config.cjs` | 356 | add per-file entries for changed files without one (see section 6) | small |

`index.ts` re-exports `splitLines` from `./models` (`index.ts:29,32`); that export is unaffected. No public API is removed; the private copies were not exported.

## 5. Testing Implications

Fixed-expected-order replacements in `models.test.ts` (enumerative; no `fast-check`):

- Disagreement pairs with literal expected results (each fails under the current UTF-16 implementation):
  - `compareCodePoint("￿", "\u{1F600}")` is `-1`, and the reverse is `1`.
  - `compareCodePoint("", "\u{10000}")` is `-1`.
  - `compareCodePoint("～", "\u{1F600}")` is `-1` (fullwidth tilde versus emoji).
  - `compareCodePoint("a�", "a\u{1F600}")` is `-1` (difference after a shared prefix).
- Agreement pairs (guard against over-correction): `"é"` vs `"\u{1F600}"` is `-1`; `"\u{1F600}"` vs `"\u{1F601}"` is `-1` (trail-surrogate difference); `"\u{1F600}"` vs `"\u{20000}"` is `-1` (lead-surrogate difference); `"a"` vs `"a\u{1F600}"` is `-1` (prefix).
- Fixed sort: input `["b", "\u{1F600}", "a", "￿", "é", "", "A", "ab", ""]` sorted with `compareCodePoint` equals the literal `["", "A", "a", "ab", "b", "é", "", "￿", "\u{1F600}"]`. Under the current implementation the emoji sorts before `""`, so this test fails before the fix and passes after it.
- Extend the enumerative domain with `""` and `"￿"` so reflexivity, antisymmetry, transitivity, and range checks cover the disagreement region.
- Antisymmetry diagnostics: collect violations instead of asserting per pair, for example `const violations = pairs.filter(([l, r]) => compareCodePoint(l, r) !== -compareCodePoint(r, l)).map(([l, r]) => \`${describeCodePoints(l)} vs ${describeCodePoints(r)}\`); expect(violations).toEqual([]);` where `describeCodePoints` renders `U+XXXX` sequences. Jest prints the offending pairs in the diff. Apply the same pattern to transitivity. `it.each` with the pair in the title is an acceptable alternative.
- Delete the tests at lines 215 and 230 outright; no test may derive its expectation from `<`/`>`.

Helper tests: `sortedSet` (dedupe; code-point order including a non-BMP pair; accepts a `Set` and a generator; does not mutate input), `escapeRegExp` (every metacharacter round-trips through `new RegExp(escapeRegExp(s), "u").test(s)`; `-` is left unescaped), `splitLines` (`""`, `"a\r\nb"`, `"a\rb"`, `"a\n"`, `"a\n\n"`, `"\n"`; documents that ` ` is not a boundary), `relativeToPosix` (Windows backslash root and path, trailing-slash root, path outside root, root equal to a path prefix without separator such as `/repo` vs `/repository/x`).

Regression: the existing suites for every changed module must pass unchanged (section 6 table), which demonstrates that consolidation did not change rendered output.

## 6. Toolchain (question F)

Run from `extensions/drm-copilot/` (scripts at `package.json:202-213`):

1. Format: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (the `format` script is the `--write` form).
2. Lint: `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`; config `eslint.config.mjs`, `@eslint/js` + `typescript-eslint` recommended).
3. Type check: `npm run typecheck` (`tsc -p ./ --noEmit`).
4. Architecture boundaries: no `.dependency-cruiser.*` exists in the repository and no architecture test exists under `ext/test`; the stage has no tool for this extension. Record it as not applicable and rely on the import map in section 1.4 plus `tsc` for cycle safety. `quality-tiers.yml` is not present at the repository root of this worktree.
5. Unit tests with coverage: `npm run test:coverage` (`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`). Targeted run: `node run-jest.cjs test/lib/pr-context`. `run-jest.cjs` rejects `--passWithNoTests`, `--onlyChanged`, `--lastCommit`.
6. Contract/schema: not applicable (no host-service boundary changes).
7. Integration: `test/lib/pr-context/collector-integration.test.ts` and `test/extension.collect-pr-context.test.ts` run inside the Jest suite.

Coverage configuration (`jest.config.cjs`): `coverageProvider: "v8"`, `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`, per-file thresholds only (no `global`), each `lines: 85, branches: 75`. Changed files with an existing entry: `models.ts` (51), `collector-core.ts` (33), `feature-docs-parsers.ts` (55), `render-feature-excerpts.ts` (59), `render-pr-helpers.ts` (63), `autoclose.ts` (47). Changed files without an entry: `render.ts`, `gh-client-details.ts`, `verification-evidence.ts`, and optionally `feature-docs.ts`. Following the per-changed-file precedent recorded in the config comments, add entries for these after confirming from the baseline `coverage/lcov.info` that each meets 85/75; if one does not, record the baseline and raise a follow-up rather than expanding this bug's scope.

Test files per affected module:

| Module | Test files |
|---|---|
| `models.ts` | `models.test.ts` (direct); all pr-context suites indirectly |
| `collector-core.ts` | `collector-core.test.ts`, `collector-core-default-resolver.test.ts`, `collector-core-autoclose.test.ts`, `collector-output*.test.ts`, `collector-integration.test.ts` |
| `gh-client-details.ts` | `gh-client-details.test.ts`, `gh-client-core.test.ts` |
| `render.ts` | `render.test.ts` |
| `render-pr-helpers.ts` | `render-pr-helpers.test.ts`, `issue-reference-pattern.test.ts` |
| `render-feature-excerpts.ts` | `render-feature-excerpts.test.ts`, `issue-reference-pattern.test.ts` |
| `feature-docs-parsers.ts` | `feature-docs.test.ts`, `issue-reference-pattern.test.ts` |
| `verification-evidence.ts` | `verification-evidence.test.ts` |
| `feature-docs.ts`, `autoclose.ts` | `feature-docs.test.ts`, `autoclose.test.ts` |

No test currently calls `sortedSet`, `relativeToPosix`, `escapeRegExp`, or `splitLines` directly (grep under `ext/test` found only a comment at `render.test.ts:298`).

## 7. Scope Decisions

### 7.1 Comparators outside pr-context (question D)

Recommendation: defer to a follow-up issue. Do not consolidate them in #740.

- They implement the same UTF-16 ordering as the current `compareCodePoint`, so they are not inconsistent with each other; they would become inconsistent with pr-context only after this fix. Their Python counterparts would presumably also use code-point `sorted()`, but that was not verified for those subsystems.
- Consolidation is wider than the five named comparators: 24 inline comparator lines across three subsystems (section 1.5). Switching them to code point changes converter and push-down ordering, which needs its own evidence of unchanged output.
- Dependency direction: `push-down/` and `codex-native-converter/` must not import from `pr-context/` (no such edges exist today, and pr-context is a peer feature module, not a shared library). The correct home for a cross-subsystem comparator is a neutral module under `src/lib/` (for example `src/lib/string-order.ts`), to which `compareCodePoint` would then move with a re-export from `models.ts`. That relocation is a separate design step.
- Minor-audit work mode favors the narrow change stated in the issue's Expected Behavior ("each helper exists once" within pr-context).

Follow-up scope to file: introduce `src/lib/string-order.ts` with `compareCodePoint`; migrate `codex-native-converter/`, `push-down/`, and `subagent-tree/` comparators; verify converter/push-down outputs; optionally consolidate the out-of-pr-context `escapeRegExp`/`splitLines` copies.

### 7.2 Python parity port (question E)

Recommendation: no Python changes in scope. The Python port has no mis-documented comparator, no hand-rolled copies of the four helpers, and no vacuous ordering tests. Record two observations for possible follow-ups: the `Path`-object sorts (part-wise, case-folded on Windows) that diverge from the TypeScript string sorts, and the untracked-or-tracked status of `render.py,cover`.

### 7.3 Other observations deferred

- `splitLines` terminator-set parity with Python (behavior change).
- Larger pr-context duplications (`parseSection`, `extractIssueReferences`, `resolveFeatureDir`, and others in section 1.3), which mirror Python module structure.
- The existing `gh-client-core` / `gh-client-details` import cycle.

## 8. Proposed Acceptance Criteria (question G)

- [ ] `compareCodePoint` in `ext/src/lib/pr-context/models.ts` orders strings by Unicode code point; its JSDoc states code-point order and that it matches Python `str` comparison. Verified by the new fixed-order tests in `models.test.ts`, which fail against the pre-fix implementation.
- [ ] `models.test.ts` asserts literal expected results for the non-BMP disagreement pairs `"￿"` vs `"\u{1F600}"`, `""` vs `"\u{10000}"`, and a shared-prefix pair, plus agreement pairs for lead- and trail-surrogate differences.
- [ ] `models.test.ts` contains a fixed-order sort test whose expected array is a literal (`["", "A", "a", "ab", "b", "é", "", "￿", "\u{1F600}"]`), not derived from `<`/`>`.
- [ ] The tests formerly at `models.test.ts:215` ("agrees with the native < and > operators...") and `:230` ("produces the same order as native comparison via Array.prototype.sort...") are removed; `rg -n "left < right|left > right" extensions/drm-copilot/test/lib/pr-context/models.test.ts` returns no matches.
- [ ] The antisymmetry test (and transitivity test) report the offending pair(s) on failure, via a violations array or `it.each` titles; the enumerative domain includes `""` and `"￿"`.
- [ ] `rg -n "function (sortedSet|relativeToPosix|escapeRegExp|splitLines)\b" extensions/drm-copilot/src/lib/pr-context` returns exactly 4 lines: `sortedSet`, `escapeRegExp`, `splitLines` in `models.ts` and `relativeToPosix` in `feature-docs-parsers.ts`, each exported.
- [ ] `models.test.ts` has direct tests for `sortedSet`, `escapeRegExp`, and `splitLines`; `feature-docs.test.ts` has direct tests for `relativeToPosix` (including a Windows-style root and a path outside the root).
- [ ] The `splitLines` JSDoc states the supported terminators (`\r\n`, `\r`, `\n`) and that this is a subset of Python `str.splitlines()` boundaries.
- [ ] The `models.ts` header comment lists `splitLines`, `compareCodePoint`, `sortedSet`, and `escapeRegExp`.
- [ ] `gh-client-details.ts` imports from `./models` in a single statement.
- [ ] All pre-existing tests in `extensions/drm-copilot/test/lib/pr-context/` pass without modification to their expected outputs (`node run-jest.cjs test/lib/pr-context`), demonstrating unchanged PR-context output for existing inputs.
- [ ] `npx prettier --check`, `npm run lint`, and `npm run typecheck` exit 0 from `extensions/drm-copilot/`.
- [ ] `npm run test:coverage` exits 0; every changed production file meets 85% line and 75% branch coverage, and `jest.config.cjs` carries a per-file threshold entry for each changed file (or a recorded baseline and follow-up where a pre-existing file is below threshold).
- [ ] No changed file exceeds 500 lines.
- [ ] A follow-up issue is recorded for consolidating the `codex-native-converter/`, `push-down/`, and `subagent-tree/` comparators into a neutral `src/lib/` module; no change is made to those modules in #740.

## Numeric Derivation Evidence

### Claim N1: pr-context helper definitions (current 12; target 4, one per helper)

- Complete Family: every definition (function declaration, function expression, or arrow assigned to a binding) of `sortedSet`, `relativeToPosix`, `escapeRegExp`, `splitLines` in production TypeScript under `extensions/drm-copilot/src/lib/pr-context/`.
- Exhaustive Search Scope: all 18 `.ts` files in `extensions/drm-copilot/src/lib/pr-context/` (enumerated by Glob `extensions/drm-copilot/src/lib/pr-context/*.ts`; no subdirectories).
- Inclusion Rules: a declaration of one of the four names that introduces a callable binding, exported or private.
- Exclusion Rules: import specifiers, re-exports (`index.ts:29`), call sites, comments; same-named functions outside `pr-context/` (for example the seven `push-down` `relativeToPosix` functions).
- Primary Search Strategy or Query Expression: Grep regex `function (sortedSet|relativeToPosix|escapeRegExp|splitLines)\b` (combined with other names in the original query) over `extensions/drm-copilot`, filtered to `src/lib/pr-context/`.
- Primary Member Set: `collector-core.ts:384 sortedSet`; `gh-client-details.ts:123 sortedSet`; `render.ts:377 sortedSet`; `feature-docs-parsers.ts:299 relativeToPosix`; `verification-evidence.ts:266 relativeToPosix`; `render-feature-excerpts.ts:431 relativeToPosix`; `feature-docs-parsers.ts:314 escapeRegExp`; `render-feature-excerpts.ts:440 escapeRegExp`; `models.ts:221 splitLines`; `verification-evidence.ts:280 splitLines`; `render.ts:387 splitLines`; `render-pr-helpers.ts:394 splitLines`.
- Primary Count: 12 (sortedSet 3, relativeToPosix 3, escapeRegExp 2, splitLines 4).
- Cross-check Search Strategy or Query Expression: (a) Grep regex `sortedSet\(|relativeToPosix\(|escapeRegExp\(|splitLines\(` over `src/lib/pr-context` (every call or declaration with an opening parenthesis), with each result line classified by hand as declaration or call; plus (b) Grep regex `(const|let|var)\s+(sortedSet|relativeToPosix|escapeRegExp|splitLines|compareCodePoint)\b|(sortedSet|relativeToPosix|escapeRegExp|splitLines|compareCodePoint)\s*[:=]\s*(\(|function)` over the same directory to capture binding-form definitions the primary query cannot see; plus (c) the per-file listing from Grep `^(export )?function \w+` over the same directory.
- Cross-check Member Set: (a) declaration lines in the call-site listing: the same 12 file:line entries as the primary set (all other lines are calls: collector-core 163,166,234,249,359; gh-client-details 332,384; render 202,203,215,238,239,241,358,359; feature-docs 298,302; feature-docs-parsers 35,61,124,225; render-feature-excerpts 51,101,151,276,411; verification-evidence 100,128; models 250; summary-digests 80; render-pr-helpers 110,227,333; summary-helpers 71,102,196,215); (b) zero binding-form definitions; (c) the function listing shows the same 12 declarations among all top-level functions.
- Cross-check Count: 12 (12 from (a) and (c), 0 additional from (b)).
- Member-set Comparison: normalized sets (file, line, name) from primary and cross-check are identical; no member appears in only one set; no duplicates. The target assertion "exactly 4 lines, one per helper" is therefore grounded, and the post-fix grep is capable of failing (it returns more than 4 lines today).

### Claim N2: vacuous comparator tests (2) and antisymmetry test (1)

- Complete Family: every `it(...)` in `extensions/drm-copilot/test/lib/pr-context/models.test.ts` whose expected value is derived from the JavaScript `<`/`>` operators rather than a literal.
- Exhaustive Search Scope: the full file (237 lines), read end to end.
- Inclusion Rules: the expectation (not the subject) uses `<` or `>` on strings.
- Exclusion Rules: tests whose `<`/`>` usage is on numeric comparator results (for example transitivity at line 199 uses `<= 0` on numbers).
- Primary Search Strategy or Query Expression: full read of the file and manual classification of every `it` block (lines 151-236).
- Primary Member Set: line 215 test; line 230 test.
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: Grep regex `left < right|left > right` within the file.
- Cross-check Member Set: matches at lines 219, 221 (inside the line-215 test) and 233 (inside the line-230 test).
- Cross-check Count: 2 distinct tests.
- Member-set Comparison: identical sets (tests at 215 and 230). The antisymmetry test at 185 is identified separately by name and is not counted in this family.

## Automation Feasibility

No step requires human interaction. All changes are source and test edits within `extensions/drm-copilot/`, and every verification step is a non-interactive command (`npx prettier --check`, `npm run lint`, `npm run typecheck`, `node run-jest.cjs`, `npm run test:coverage`, `rg`). Filing the deferred follow-up issue uses the repository's MCP promotion path, which is automated. No credentials, UI, or manual review gates are needed for the verification itself.
