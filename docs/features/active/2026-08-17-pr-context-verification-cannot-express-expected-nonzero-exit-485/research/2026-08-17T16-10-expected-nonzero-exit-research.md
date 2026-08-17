# Research — PR-context Verification cannot express an expected non-zero exit (Issue #485)

- Timestamp: 2026-08-17T16-10
- Issue: #485
- Feature folder: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485`
- Scope: research and documentation only. No production or test file was modified.
- Source of the defect statement: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/issue.md`

Every claim below is grounded in a file read during this session. Line numbers refer to the state of the branch `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485` at the time of reading.

---

## 1. Current State — Python parser

File: `scripts/dev_tools/pr_context/verification_evidence.py`

- **Line count:** the module's last content line is line 171 (`    )` closing `parse_verification_evidence_markdown`'s call in `parse_verification_evidence_file`). Well under the 500-line limit in `.claude/rules/general-code-change.md` ("File Size Limit"). There is ample headroom for an additive change.
- **Module docstring:** lines 1-12, declaring the three-step flow "discover → parse required schema fields → normalize pass/fail/unparseable status from EXIT_CODE".

### 1.1 Constants

- `verification_evidence.py:22`
  ```python
  REQUIRED_FIELDS: tuple[str, str, str] = ("Timestamp", "Command", "EXIT_CODE")
  ```
  The type annotation is arity-bearing (`tuple[str, str, str]`). Adding a fourth member would force a type-annotation change and would mislabel an optional field as required.
- `verification_evidence.py:23-27` — `CANONICAL_GLOBS: tuple[str, str, str]` = `evidence/qa-gates/**/*.md`, `evidence/regression-testing/**/*.md`, `evidence/other/**/*.md`. Note this is a strict subset of the canonical evidence roots listed in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:14-20`: `baseline/`, `issue-updates/`, and `remediation-baseline/` are **not** discovered by the PR-context parser. That is pre-existing and out of scope here, but it bounds the corpus (see §6).
- `verification_evidence.py:29` — `NormalizedResult = Literal["pass", "fail", "unparseable"]`.

### 1.2 Record type

`verification_evidence.py:32-54` — `@dataclass(frozen=True) class VerificationEvidenceRecord` with exactly six members:

| Member | Type | Line |
| --- | --- | --- |
| `feature` | `str` | 49 |
| `source_file` | `str` | 50 |
| `timestamp` | `str \| None` | 51 |
| `command` | `str \| None` | 52 |
| `exit_code` | `int \| None` | 53 |
| `normalized_result` | `NormalizedResult` | 54 |

### 1.3 Public functions

| Function | Lines | Signature |
| --- | --- | --- |
| `discover_canonical_evidence_files` | 57-80 | `(root: Path, feature: str) -> list[Path]` |
| `parse_verification_evidence_markdown` | 83-144 | `(*, feature: str, source_file: str, markdown: str) -> VerificationEvidenceRecord` |
| `parse_verification_evidence_file` | 147-171 | `(*, root: Path, feature: str, relative_path: Path) -> VerificationEvidenceRecord` |

There is no `__all__` in this module. There is no private helper.

### 1.4 The parse loop (the accept-list filter)

`verification_evidence.py:99-108`:

```python
parsed: dict[str, str] = {}

# Parse `Key: value` rows once and keep only required schema fields.
for raw_line in markdown.splitlines():
    if ":" not in raw_line:
        continue
    key, value = raw_line.split(":", 1)
    key = key.strip()
    if key in REQUIRED_FIELDS:
        parsed[key] = value.strip()
```

Verified properties:

1. The split is on the **first** colon (`split(":", 1)`), so a value containing colons is preserved intact.
2. The key is `.strip()`ped, so leading indentation is tolerated. The key match is **case-sensitive and exact**; `expected exit code` or `EXPECTEDEXITCODE` would not match a key named `ExpectedExitCode`.
3. `REQUIRED_FIELDS` doubles as the **accept-list**. Any other `Key: value` line — including `Output Summary:` (mandated by `.claude/skills/atomic-plan-contract/SKILL.md:34,45`), `SearchScope:`, `PostedAs:`, or a hypothetical `ExpectedExitCode:` — is discarded with no signal. This is the mechanism the issue describes at `issue.md:56-65`, and it is confirmed.
4. **Last occurrence wins.** `parsed[key] = value.strip()` executes unconditionally on every match, so a document with several `EXIT_CODE:` lines retains the last one. This is a divergence from the TypeScript port; see §3.

### 1.5 Unparseable branches and normalization

- `verification_evidence.py:110-112` reads the three keys back out.
- `verification_evidence.py:114-122` — missing/empty `Timestamp`, missing/empty `Command`, or absent `EXIT_CODE` yields `normalized_result="unparseable"` with `exit_code=None`. Note the truthiness test `not timestamp or not command`: an empty-string value (a bare `Timestamp:` line) is treated as missing, whereas an empty `EXIT_CODE:` falls through to the `int("")` `ValueError` path.
- `verification_evidence.py:124-134` — `int(exit_code_raw)` inside `try/except ValueError` yields `unparseable` on a non-integer. `int()` tolerates surrounding whitespace and a leading sign; it rejects anything else.
- `verification_evidence.py:136` — the defect:
  ```python
  normalized_result: NormalizedResult = "pass" if exit_code == 0 else "fail"
  ```
  A total binary partition over the integer domain. There is no seam for an expectation.

### 1.6 Callers of the Python module

Two, both inside `scripts/dev_tools/pr_context/`:

1. `scripts/dev_tools/pr_context/feature_docs.py:8` imports `discover_canonical_evidence_files`; used at `feature_docs.py:330-343` to add canonical evidence paths to `FeatureDocExcerpt.context_files`. This caller does **not** touch `normalized_result`.
2. `scripts/dev_tools/pr_context/collector.py:65-68` imports `VerificationEvidenceRecord` and `parse_verification_evidence_file`; used in `_render_verification_evidence_section` (`collector.py:115-166`).

No other in-repo Python module imports `verification_evidence`. Verified by a repository-wide search for `verification_evidence`.

The Python surface is reachable through the Poetry console script `dev.pr-context` (`pyproject.toml:79` → `scripts.dev_tools.pr_context.collector:main`).

---

## 2. Current State — TypeScript parser

File: `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`

- **Line count:** 248 lines (the file's last line, `}` closing `splitLines`, is line 248). Under the 500-line limit.
- Module header (lines 1-19) states it is a port of the Python module and that all filesystem access flows through the injected `FileSystem` from `../file-system`.

### 2.1 Constants and types

| Symbol | Line | Form |
| --- | --- | --- |
| `REQUIRED_FIELDS` | 24 | `export const REQUIRED_FIELDS = ["Timestamp", "Command", "EXIT_CODE"] as const;` |
| `CANONICAL_GLOBS` | 27-31 | `export const ... as const` — same three globs, same order |
| `NormalizedResult` | 34 | `export type NormalizedResult = "pass" \| "fail" \| "unparseable";` |
| `VerificationEvidenceRecord` | 37-44 | `export interface`, six `readonly` members: `feature`, `sourceFile`, `timestamp`, `command`, `exitCode`, `normalizedResult` |

`REQUIRED_FIELDS` is **exported** here (the Python constant is module-level but not re-exported through a package `__init__`), so mutating its member set is a public-surface change on the TypeScript side.

### 2.2 Exported functions

| Function | Lines | Signature |
| --- | --- | --- |
| `discoverCanonicalEvidenceFiles` | 59-80 | `(fs: FileSystem, root: string, feature: string) => string[]` |
| `parseVerificationEvidenceMarkdown` | 93-155 | `(params: { feature: string; sourceFile: string; markdown: string }) => VerificationEvidenceRecord` |
| `parseVerificationEvidenceFile` | 169-184 | `(params: { fs; root; feature; relativePath }) => VerificationEvidenceRecord` |

Module-private helpers: `parseIntegerStrict` (196-201), `relativeToPosix` (210-216), `compareCodePoint` (219-227), `splitLines` (235-248).

### 2.3 The parse loop

`verification-evidence.ts:103-116`:

```typescript
for (const rawLine of splitLines(markdown)) {
  const colonIndex = rawLine.indexOf(":");
  if (colonIndex === -1) { continue; }
  const key = rawLine.slice(0, colonIndex).trim();
  const value = rawLine.slice(colonIndex + 1).trim();
  if ((REQUIRED_FIELDS as readonly string[]).includes(key) && !parsed.has(key)) {
    parsed.set(key, value);
  }
}
```

The `!parsed.has(key)` guard makes this **first occurrence wins**. The comment on lines 101-102 asserts this "mirrors the Python dict-first-write semantics"; that statement is factually incorrect — Python overwrites (see §1.4 item 4).

### 2.4 Unparseable branches and normalization

- `verification-evidence.ts:118-132` — missing-field branch, using `?? null` and a `!timestamp || !command || exitCodeRaw === undefined` test that reproduces the Python truthiness behavior.
- `verification-evidence.ts:134-144` — `parseIntegerStrict` returns `null` on anything that is not `/^[+-]?\d+$/u`, yielding `unparseable`. Note `parseIntegerStrict` is stricter than Python's `int()` for exotic inputs (Python `int()` accepts underscores such as `1_0` and Unicode decimal digits; the regex does not). No corpus artifact observed exercises that difference.
- `verification-evidence.ts:146` — the mirrored defect:
  ```typescript
  const normalizedResult: NormalizedResult = exitCode === 0 ? "pass" : "fail";
  ```

### 2.5 Callers of the TypeScript module

1. `extensions/drm-copilot/src/lib/pr-context/collector-output.ts:40-42` imports `VerificationEvidenceRecord` and `parseVerificationEvidenceFile`; used in `renderVerificationEvidenceSection` (69-126).
2. `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` imports `discoverCanonicalEvidenceFiles` (the analogue of the Python `feature_docs.py` caller); it does not read `normalizedResult`.
3. `extensions/drm-copilot/src/lib/pr-context/index.ts:74-80` re-exports `NormalizedResult`, `VerificationEvidenceRecord`, `discoverCanonicalEvidenceFiles`, `parseVerificationEvidenceFile`, and `parseVerificationEvidenceMarkdown`. It does **not** re-export `REQUIRED_FIELDS` or `CANONICAL_GLOBS`.

### 2.6 Which runtime serves the MCP tool named in the issue

`mcp__drm-copilot__collect_pr_context` is served **in-process by the TypeScript implementation**, not by a Python subprocess:

- `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts:27` imports `collectAndWrite` from `./collector-output`; lines 71-81 invoke it directly. The header comment (lines 1-20) records that this replaced a prior "Python-spawn shape".

Consequence for the fix: the reporter's observed behavior came from the **first-occurrence** parser. The Python CLI (`dev.pr-context`) remains live and uses last-occurrence.

---

## 3. Parity Delta

### 3.1 Side-by-side structure

| Concern | Python (`verification_evidence.py`) | TypeScript (`verification-evidence.ts`) | Aligned? |
| --- | --- | --- | --- |
| Accept-list constant | `REQUIRED_FIELDS` (22), `tuple[str, str, str]`, module-private | `REQUIRED_FIELDS` (24), `as const` tuple, **exported** | Same members; different visibility/typing |
| Glob constant | `CANONICAL_GLOBS` (23-27) | `CANONICAL_GLOBS` (27-31) | Yes |
| Result union | `Literal["pass","fail","unparseable"]` (29) | `"pass" \| "fail" \| "unparseable"` (34) | Yes |
| Record | frozen dataclass, `snake_case` (32-54) | `readonly interface`, `camelCase` (37-44) | Same six fields, naming per language convention |
| Line splitting | `str.splitlines()` (102) | `splitLines` helper reimplementing `splitlines` (235-248) | Yes (deliberate port) |
| Colon split | `split(":", 1)` (105) | `indexOf(":")` + two slices (104-109) | Yes |
| Key trimming | `key.strip()` (106) | `.trim()` (108) | Yes (Python `strip` and JS `trim` differ on exotic Unicode whitespace; not observed in corpus) |
| Value trimming | `value.strip()` (108) | `.trim()` (109) | Same caveat |
| **Duplicate-key precedence** | **last wins** (108, unconditional assignment) | **first wins** (110-113, `!parsed.has(key)`) | **NO — divergent** |
| Missing-field branch | 114-122 | 123-132 | Yes |
| Integer parse | `int()` in `try/except ValueError` (124-134) | `/^[+-]?\d+$/u` + `parseInt` (196-201) | Near-identical for decimal strings; Python accepts `1_0` and Unicode digits, TS does not |
| Normalization | `"pass" if exit_code == 0 else "fail"` (136) | `exitCode === 0 ? "pass" : "fail"` (146) | Yes (both defective) |
| Discovery sort | `sorted()` on `Path` objects (80) | `compareCodePoint` on strings (79, 219-227) | Ported deliberately |
| Read failure | propagates `OSError` (161) | throws `Error` (167) | Yes; both callers catch |
| Error text | none (no error strings emitted) | none | N/A |

### 3.2 The pre-existing divergence, quantified

The duplicate-key divergence is not theoretical. Measured over the corpus the parser actually reads (`docs/features/active/**/evidence/{qa-gates,regression-testing,other}/**/*.md`):

- 968 artifacts contain at least one line-anchored `EXIT_CODE:`.
- **156 of those 968 (16.1%) contain two or more `EXIT_CODE:` lines**, and are therefore subject to the divergence.

Worked example — `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/evidence/other/d1-grep-gates.2026-08-17T00-47.md`:

- Line 9: `EXIT_CODE: 1` (the absence-assertion gate, `git grep` with zero matches)
- Line 18: `EXIT_CODE: 0` (a positive control confirming the search reached the surface)

Python takes line 18 and reports **`pass`**. TypeScript takes line 9 and reports **`fail`**. Neither answer describes the artifact, because the artifact records two gates.

Second worked example — `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/evidence/other/cross-cutting-gates.2026-08-17T02-25.md` carries six `EXIT_CODE:` lines, of which lines 40, 69, 116, 122 and 141 have values like `1 -> **zero matches**. Neither ...`. Those are not integers, so both runtimes classify the whole artifact `unparseable` and the collector drops the row entirely (see §4). The artifact's authors were already working around the absence of an expectation field by annotating the value inline.

### 3.3 What "parity" means for this fix

Because the runtimes already disagree on duplicate-key precedence, "add the same key to both parsers" does not by itself produce parity for 16% of the corpus. The spec must make an explicit decision:

- **Option P1 (recommended):** fix the divergence in the same change, converging on **first wins**, and record it as a separate, separately-evidenced sub-change. Rationale: the TypeScript behavior is what the MCP tool (the surface named in the issue) actually produces today, and it is the behavior an existing test already asserts (`extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts:151-159`). Converging Python to first-wins is a **behavior change for 156 existing artifacts**, so it is not covered by the additive-proof requirement and needs its own before/after evidence.
- **Option P2:** scope the divergence out, add the new key with each runtime's existing precedence, and file the divergence as its own issue. Cost: the new expectation key inherits the same 16% ambiguity, and the parity tests for this fix cannot use multi-gate fixtures.

Either way the divergence must be named in the spec. It is the single most consequential finding of this research beyond the reported defect itself.

---

## 4. Downstream Consumers of the Normalized Result

The `pass` / `fail` / `unparseable` value is read in exactly four places in the repository, two production and two test:

| File | Lines | Role |
| --- | --- | --- |
| `scripts/dev_tools/pr_context/collector.py` | 147-149 | Filters `records` to `normalized_result in {"pass", "fail"}`. **`unparseable` records are dropped entirely** — they never appear in the PR body. |
| `scripts/dev_tools/pr_context/collector.py` | 150-151 | Fallback text `"No canonical verification evidence parsed"` when nothing is parseable. |
| `scripts/dev_tools/pr_context/collector.py` | 155-165 | Row rendering, six lines per record, sorted by `source_file`: `- Feature:`, `  - Source:`, `  - Timestamp:`, `  - Command:`, `  - EXIT_CODE:`, `  - Normalized result:`. |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 98-104 | Same filter and same fallback string. |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 115-124 | Same six-line row rendering, sorted by `sourceFile` (108-114). |

Section placement: `collector.py:513-514` and `collector-output.ts:236-237` emit `section("Verification evidence (feature docs + canonical artifacts)")` followed by the rendered body. The section is inside the summary artifact `artifacts/pr_context.summary.txt` (`collector.py:103`, `pr-context-service-call.ts:30`).

**A repository-wide search for the strings `Normalized result` and `No canonical verification evidence parsed` returns 9 files: the 2 production files above, 2 test files, and 5 historical feature documents** (`docs/features/completed/2026-06-25-port-python-commands-to-typescript-240/plans/F9-pr-context.plan.md` and four documents under `docs/features/archive/2026-02-22-pr-context-verification-contract-gap-46/`). There is **no golden file, no snapshot fixture, and no schema file** keyed on the result vocabulary.

### 4.1 Blast radius by decision

- **If the result value set stays `pass | fail | unparseable`** (recommended): the two renderers need **no change at all**. Only the two parser modules change. This is the minimal-blast-radius design.
- **If a fourth result value is introduced** (for example `expected-fail`): both filters (`collector.py:147-149`, `collector-output.ts:98-101`) must be widened or the row silently disappears, and both row renderers change. Not recommended — it buys nothing that `pass` with a declared expectation does not already convey.
- **If the expectation is displayed in the row**: `collector.py:155-165` and `collector-output.ts:115-124` change, and the two collector-level tests that assert on section content change with them.
- **Not affected under any option:** `feature_docs.py` / `feature-docs.ts` (they use discovery only, not the result), `index.ts` (re-exports a type name, not members), `pr-context-service-call.ts`, `collector-core.ts`, and every MCP/tool-definition file — none reads `normalizedResult`.

---

## 5. Existing Tests

### 5.1 TypeScript

`extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` — 219 lines, **9 tests**:

- `parseVerificationEvidenceMarkdown` (104-160): pass on exit 0 (105), fail on non-zero (118), unparseable on missing field (129), unparseable on non-integer `EXIT_CODE` (140), **first-occurrence-wins for a duplicated key (151)**.
- `discoverCanonicalEvidenceFiles` (162-189): empty when feature root absent (163), three-root glob with sorted relative paths (168).
- `parseVerificationEvidenceFile` (191-219): reads through the filesystem (192), propagates a read failure (208).

Fixture construction: **in-memory only**. Markdown is inline string literals; the filesystem is a local `SeededFileSystem implements FileSystem` class (46-98) backed by two `Map`/`Set` fields, with a hand-written glob compiler (20-44). No disk access, no temporary files. This satisfies `.claude/rules/general-unit-test.md` ("Creation and use of temporary files in tests is strictly prohibited") and is directly extensible for new cases.

`extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` — `describe("renderVerificationEvidenceSection")` at line 268 holds **4 tests**: row rendering with `EXIT_CODE: 0` → `Normalized result: pass` (269, asserting the exact strings at 286-287), skip/tolerate behavior (290), sorting with a mixed 0/1 pair (≈313), and the fallback (343). Fixtures use `TreeFileSystem` from `extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts` (also in-memory).

### 5.2 Python

**There is no dedicated Python unit-test module for `verification_evidence.py`.** Verified: a search across `tests/` for `verification_evidence`, `parse_verification_evidence_markdown`, and `discover_canonical_evidence_files` returns a single hit — a test *function name* at `tests/scripts/dev_tools/test_collect_pr_context_part4.py:305`. `tests/scripts/dev_tools/` contains no `pr_context/` subpackage.

The module is exercised only indirectly, by three collector-level tests:

| Test | File:line | What it covers |
| --- | --- | --- |
| `test_collector_includes_canonical_evidence_paths_in_additional_context_files` | `tests/scripts/dev_tools/test_collect_pr_context.py:318` | discovery path only |
| `test_collector_verification_evidence_section_is_rendered_with_normalized_fields` | `tests/scripts/dev_tools/test_collect_pr_context_part4.py:305` | the `EXIT_CODE: 0` → rendered-section path (fixture at 462-476) |
| `test_collector_reports_unparseable_evidence_without_claiming_completion` | `tests/scripts/dev_tools/test_collect_pr_context_part4.py:500` | the fallback text path (fixture at 656-667) |

The non-zero (`fail`) normalization branch and the non-integer `EXIT_CODE` branch have **no Python test at all**. The defective line `verification_evidence.py:136` is exercised only on its `exit_code == 0` side.

Fixture construction: these tests write files through the `mem_fs_path` fixture defined at `tests/conftest.py:145-172`, which monkeypatches selected `pathlib.Path` methods so all reads and writes under a synthetic root `/__pytest_mem__/<n>` operate purely in memory. Its docstring (149-153) states its purpose explicitly: "Replace pytest's default filesystem-backed temporary directory fixture with an in-memory path store to enforce repository policy against temporary file usage in unit tests." New Python tests must use `mem_fs_path`, never `tmp_path`.

### 5.3 Coverage posture

Not measured in this session (research-only; no toolchain was run). What is verifiable from configuration:

- `pyproject.toml:119-127` — `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, so `verification_evidence.py` is in the coverage denominator. `omit` lists only test/`__pycache__`/site-packages paths, consistent with the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`.
- `pyproject.toml:114-117` — `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`. Note there is **no `fail_under`** in `[tool.coverage.report]` (129-140); the 85%/75% thresholds are policy-enforced, not `pyproject`-enforced. A run therefore must pass `--cov --cov-branch` explicitly to measure anything (this is the failure mode recorded in the operator memory "Verification gates that cannot fail": `--cov=<path>.py` measures nothing).
- The module is small (171 lines, three functions, no I/O beyond one `read_text`), so a dedicated test module can reach near-total line and branch coverage cheaply.

---

## 6. Additive-Change Proof Strategy

The requirement: an artifact carrying no expectation key must produce **byte-identical** Verification output. This can be proved, not merely asserted, at two levels.

### 6.1 Corpus inventory (measured)

Counting only what the parser actually reads — `docs/features/active/<feature>/evidence/{qa-gates,regression-testing,other}/**/*.md`, per `CANONICAL_GLOBS`:

| Root | Artifacts containing `^EXIT_CODE:` |
| --- | --- |
| `evidence/qa-gates/` | 628 |
| `evidence/regression-testing/` | 193 |
| `evidence/other/` | 147 |
| **Total** | **968** |

Of these, **103 carry at least one non-zero-looking `EXIT_CODE:` value** (matched as `^EXIT_CODE:\s*[1-9-]`), i.e. at least 103 artifacts currently render (or would render) as `fail` or are dropped as `unparseable`. **156 carry two or more `EXIT_CODE:` lines.**

For reference, the whole of `docs/features/` (active + completed + archive, all evidence roots including `baseline/` and `remediation-baseline/`, which the parser does not read) contains 3,549 files with a line-anchored `EXIT_CODE:`; 1,433 of those are under `docs/features/active/`.

**Assessment: the corpus is large, real, git-tracked, and usable.** Zero of the 968 artifacts can contain the new key (the repository-wide search in §7 confirms zero occurrences), so the corpus is by construction a pure "no expectation key present" set — exactly the population the additive claim is about.

### 6.2 Layer 1 — hermetic unit-level equivalence proof (required)

Extract the normalization into a named pure helper in each runtime, for example `normalize_result(exit_code: int, expected_exit_code: int) -> NormalizedResult`. Then assert, as a parametrized test over a bounded integer range (for example −8..8 plus a few large values):

```
normalize_result(observed, 0) == ("pass" if observed == 0 else "fail")
```

This is an exact, deterministic, hermetic restatement of the pre-change expression at `verification_evidence.py:136` / `verification-evidence.ts:146`, and it proves the default-expectation path is unchanged for the entire integer domain rather than for a sampled set. It requires no filesystem, no fixture files, and no temp files, and it satisfies the property-density guidance in `.claude/rules/general-unit-test.md` for a pure function.

Pair it with a parser-level table covering every shape observed in the corpus, expressed as in-memory markdown strings:

1. all three fields present, `EXIT_CODE: 0`
2. all three present, `EXIT_CODE: 1`
3. `EXIT_CODE` non-integer (`ok`, `SKIPPED`, `1 -> **zero matches**`)
4. a required field missing
5. a required field present but empty
6. duplicated `EXIT_CODE` lines (documents the chosen precedence explicitly)
7. an unrelated `Key: value` line (`Output Summary:`) present — must still be ignored
8. the new key absent (the additive case)
9. the new key present and equal to the observed code
10. the new key present and different from the observed code
11. the new key present with a non-integer value

Cases 1-8 must produce records identical to the pre-change parser.

### 6.3 Layer 2 — corpus differential run (required as evidence, not as a unit test)

Do **not** commit a unit test that walks `docs/features/active/**`: the corpus mutates every time a feature lands, which would make the test non-deterministic across time and would couple the test suite to documentation content. Instead:

1. During implementation, write a throwaway comparison script (permitted by the file-size-limit exception in `.claude/rules/general-code-change.md` for "temporary throwaway scripts created and deleted within an agent session") that, for each of the 968 artifacts, computes the pre-change record and the post-change record and diffs the rendered six-line row.
2. Run it once per runtime (Python and TypeScript) and record the result as canonical evidence at `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the artifact count and the diff count (expected: `968 artifacts compared, 0 rendered-row differences`).
3. Delete the script before the final QC loop.

The "pre-change" side can be obtained without git gymnastics by keeping the equivalence assertion of §6.2 as the definition of pre-change behavior: for an artifact with no expectation key, pre-change output is fully determined by `("pass" if exit_code == 0 else "fail")`, so the comparison script can compute the reference side inline.

An identical corpus run also produces the **cross-runtime** parity number that §3.3 needs: comparing the Python and TypeScript rendered rows over the same 968 artifacts will report the 156 duplicate-key artifacts as differing under Option P2, or zero differences under Option P1.

### 6.4 Section-level byte identity

For the strongest form of the claim, run `_render_verification_evidence_section` / `renderVerificationEvidenceSection` before and after over a fixed, committed set of `FeatureDocExcerpt` inputs (in-memory, `mem_fs_path` / `TreeFileSystem`) and assert string equality of the whole section body. This is cheap because the recommended design leaves both renderers untouched (§4.1), which makes the byte-identity claim a near-tautology — and that is itself the argument for the recommended design.

---

## 7. Naming and Schema Shape

### 7.1 Verified: the namespace is clean

A repository-wide search for `expected_exit`, `expectedExit`, `expected_nonzero`, `ExpectedExit`, and `EXPECTED_EXIT` returns **four matches, all inside this feature's own documents** (`issue.md:29,65` and `spec.md:32,66`). No production file, no test, no configuration, no rule file, and no evidence artifact uses any of these tokens. The issue's claim is confirmed and extended (the search here also covered the PascalCase and SCREAMING_SNAKE forms).

### 7.2 Existing key-naming conventions in the evidence schema

From `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`:

| Key | Line | Style |
| --- | --- | --- |
| `Timestamp:` | 109 | single word |
| `Command:` | 110 | single word |
| `EXIT_CODE:` | 111 | SCREAMING_SNAKE (the only one) |
| `Output Summary:` | 117 | Title Case with space |
| `WhyFailingRunImpossible:` | 121 | PascalCase, no space |
| `SearchScope:` / `SearchPatterns:` / `SearchResult:` | 135-137 | PascalCase, no space |
| `PostedAs:` / `IssueUpdatedAt:` | 156, 159 | PascalCase, no space |

PascalCase-without-space is the dominant convention for multi-word keys (6 of 8). `EXIT_CODE` is the sole SCREAMING_SNAKE key and is not a pattern to extend.

### 7.3 Options compared

**Option A — `ExpectedExitCode: <int>`, single value, default `0`. (Recommended.)**

- Matches the dominant PascalCase convention (§7.2).
- Is the exact name already written into `issue.md:29` and `spec.md:32`, so adopting it avoids re-litigating a name that has already been reviewed.
- Expresses precisely what the observed field expresses, in the same units, so the two are directly comparable: `normalized_result = "pass" if exit_code == expected_exit_code else "fail"`.
- Default `0` makes every one of the 968 existing artifacts unchanged by construction (§6.1).
- Additive by construction on the accept-list: an absent key never reaches the new branch.
- Limitation: a single flat key cannot express *per-gate* expectations in a multi-gate artifact (§7.5).

**Option B — `ExpectedExitCodes:` accepting a list.**

- Would cover a gate whose acceptance is "any non-zero" or "1 or 2".
- Costs: a separator convention (comma? space? YAML flow?) must be chosen and kept byte-identical across a Python `str.split` and a TypeScript `String.prototype.split`, including empty-element and whitespace handling; the `unparseable` rule becomes "any element non-integer" versus "all elements non-integer"; and duplicate-key precedence (§3) compounds with element ordering.
- No demonstrated need: every absence-assertion example found in the corpus is a `git grep` / `rg` gate whose acceptance is exactly `1` (`docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/domain-neutrality-grep.2026-07-18T10-20.md:3`, `.../479/evidence/other/d1-grep-gates.2026-08-17T00-47.md:9`).
- **Rejected** for this fix. It remains available later as a strictly additive superset: a future change can teach the same key to accept a comma list, since a bare integer is a valid one-element list.

**Option C — boolean or qualitative form (`ExpectedNonZeroExit: true`, `ExpectedResult: pass`).**

- Loses the value: cannot distinguish `1` from `2`, so it cannot detect a gate that failed for the wrong reason (a `git grep` that exits `2` on a bad pathspec would be reported `pass`). That is a false-positive direction, which is worse than the current false-negative.
- Introduces a second vocabulary alongside the numeric `EXIT_CODE`, and `ExpectedResult: pass` in particular makes the artifact self-asserting rather than self-describing.
- **Rejected.**

### 7.4 Behavior of the `unparseable` branch under Option A

This is the sharpest design decision, because `unparseable` is not a visible state — `collector.py:147-149` and `collector-output.ts:98-101` **drop** unparseable records from the PR body entirely.

| Sub-option | Behavior on `ExpectedExitCode: banana` | Consequence |
| --- | --- | --- |
| **A1 (recommended)** — non-integer expectation ⇒ `unparseable` | Row disappears from the Verification section | Consistent with the existing treatment of a non-integer `EXIT_CODE` (`verification_evidence.py:124-134`). Conservative: never produces a false `pass`. Matches the unit-coverage area the issue already lists at `issue.md:91`. Cost: a typo silently removes a row that renders today. |
| A2 — non-integer expectation ⇒ ignore, default to `0` | Row renders as `fail` (status quo ante) | Maximally additive; a typo degrades to today's behavior rather than to invisibility. Cost: inconsistent with `EXIT_CODE` handling, and a silent-ignore rule is what caused this defect in the first place. |

Recommendation: **A1**, on consistency grounds, with the trade-off recorded explicitly in the spec. Note that A1 does not violate the additive requirement: the additive requirement is scoped to artifacts carrying **no** expectation key, and all 968 existing artifacts satisfy that.

Related edge worth spec attention: `.claude/skills/atomic-plan-contract/SKILL.md:135` explicitly contemplates the literal value `EXIT_CODE: SKIPPED` and forbids treating it as passing. Today that value produces `unparseable` and the row is dropped. The fix must not change that.

### 7.5 The multi-gate limitation (must be stated, not solved here)

156 of 968 artifacts record more than one gate in one file (§3.2). A flat, first-or-last-wins key schema can carry exactly one expectation per file, so a multi-gate artifact still cannot express "gate 1 expects 1, gate 2 expects 0". Solving that requires a block/section-scoped schema, which is a materially larger change to both parsers and to the six copies of the conventions skill. Recommendation: **declare it out of scope** and record it as a known limitation, with the practical guidance that a gate needing a non-zero expectation should be recorded in its own artifact file (as `domain-neutrality-grep.2026-07-18T10-20.md` already does). Do not silently leave the limitation undocumented; a reader will otherwise assume per-gate expectations work.

### 7.6 Constant naming inside the parsers

Do **not** add the new key to `REQUIRED_FIELDS`. It is not required, the Python annotation is arity-bearing (`tuple[str, str, str]`, `verification_evidence.py:22`), and the TypeScript constant is exported (`verification-evidence.ts:24`) so its member set is public surface. Recommended shape in both runtimes:

- keep `REQUIRED_FIELDS` byte-identical,
- add `OPTIONAL_FIELDS` (or a single `EXPECTED_EXIT_CODE_FIELD` constant),
- introduce a private accept-list `PARSED_FIELDS = REQUIRED_FIELDS + OPTIONAL_FIELDS` used by the loop at `verification_evidence.py:107` / `verification-evidence.ts:110-113`,
- add `expected_exit_code: int` / `expectedExitCode: number` to the record, always populated (defaulting to `0`), so the value is traceable even when the renderer does not print it.

### 7.7 Rendering decision

Recommended: leave both renderers unchanged by default, and — if the spec wants reviewer legibility — add **one conditional line** emitted only when the parsed expectation is non-zero, for example `  - Expected EXIT_CODE: 1`, inserted between the `EXIT_CODE` and `Normalized result` lines. Because the line is emitted only when the key is present and non-default, output for all 968 existing artifacts remains byte-identical. Without it, a reviewer sees `EXIT_CODE: 1` next to `Normalized result: pass` with no explanation, which invites exactly the distrust the issue's Impact section describes. This is a spec decision; both variants are additive.

---

## 8. Explicit Non-Reuse of the Atomic-Executor `[expect-fail]` Machinery

Substantiated, not restated.

**What the executor module actually is.** `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` (185 lines) exposes five functions: `matches_expected_ref` (20), `jest_test_matches_expected` (28), `jest_file_matches_expected` (37), `run_pytest_with_expectations` (46), `run_jest_with_expectations` (108). The last two **execute `subprocess.run`** (57, 75, 118, 135) and decide whether to raise `subprocess.CalledProcessError`. Its input type is `ResolvedTestExpectations` (`scripts/dev_tools/atomic_executor/pytest_expectations.py:89-111`), a frozen dataclass of four `set[str]` fields plus `missing_test_refs`, produced by `resolve_checked_test_expectations(plan: PlanModel)` (`pytest_expectations.py:154`) — that is, derived from a parsed **atomic plan**, keyed by pytest node-id prefixes and Jest `file::pattern` refs.

**Import-graph check.** A repository-wide search for `qc_runner_expectations` and `pytest_expectations` returns 18 files: five under `scripts/dev_tools/atomic_executor/` (`qc_runner.py`, `qc_runner_process.py`, `cli_preflight.py`, `cli_task_runtime.py`, and the module itself), four test modules under `tests/scripts/dev_tools/`, and nine documentation/evidence files that merely list the filename in a coverage report. **No file under `scripts/dev_tools/pr_context/` appears.** The two subsystems have no import edge in either direction.

**Why reuse or duplication is the wrong move — four independent reasons:**

1. **Different input type.** The executor consumes a `PlanModel`; the PR-context parser consumes a markdown evidence artifact. There is no shared value type to lift.
2. **Different granularity.** The executor's unit is a test node (`expected_fail_refs` are node-id prefixes, matched by `str.startswith` at `qc_runner_expectations.py:22-25`). The evidence parser's unit is a whole command invocation with a single process exit code. A node-id set cannot express "this process is expected to exit 1", and an integer cannot express "these three tests may fail".
3. **Different side-effect class.** The executor **runs processes** and raises to abort a QC loop. The parser is pure: `parse_verification_evidence_markdown` has an explicit `Side Effects: None.` contract (`verification_evidence.py:96-97`). Importing an executor helper would drag a `subprocess` dependency into a pure module and violate the I/O-boundary rule in `.claude/rules/general-code-change.md`.
4. **Different lifecycle position.** The executor gate runs *during* implementation and decides whether work may continue. The evidence parser runs *after* the fact and decides how to describe a recorded outcome to a reviewer. Coupling them would make PR-body rendering depend on plan parsing.

Copying the shape (a set-of-refs tolerance model) into the parser would import all four mismatches at once. The correct fix is a single integer field on the evidence schema, which is what §7 recommends.

---

## 9. Policy Constraints Binding the Implementation

### 9.1 File size

`.claude/rules/general-code-change.md` — "No production code, test code, or reusable script file may exceed 500 lines."

| File | Last line read | Status |
| --- | --- | --- |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 171 | ample headroom |
| `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | 248 | headroom |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 449 | 51 lines of headroom — a renderer change must be small |
| `scripts/dev_tools/pr_context/collector.py` | 619 | **already over the 500-line limit (pre-existing)** |
| `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` | 219 | headroom |
| `tests/scripts/dev_tools/test_collect_pr_context_part4.py` | ≥ 684 | **already over the limit (pre-existing)** |

Implication: the recommended design (parsers only, renderers untouched) avoids adding a single line to either already-over-limit file. If the spec chooses the conditional-render variant (§7.7), the added lines in `collector.py` are still an increase to an over-limit file and a reviewer will raise it; the counter-argument (three added lines in a 619-line pre-existing violation, with extraction out of scope) should be pre-recorded in the spec.

### 9.2 Coverage

- `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`: line coverage ≥ 85% and branch coverage ≥ 75%, **uniform across T1–T4**, for languages whose tooling measures branch coverage (both Python and TypeScript do).
- No production file may be excluded from measurement (Coverage Exclusion Policy). Both parser modules contain executable behavior and stay in the denominator.
- "Coverage regression on changed lines is a blocking finding" (`.claude/rules/python.md:90`, `.claude/rules/typescript.md:52`). Because the Python module currently has **no dedicated tests** and its `fail` branch is untested (§5.2), adding the new branch without a new Python test module would measurably reduce coverage on changed lines.
- Note: `quality-tiers.yml` is expected at repo root by `.claude/rules/quality-tiers.md` ("Source of Truth"), but a repository glob for `quality-tiers*` returns only the two rule-file copies and two evidence documents — **no root `quality-tiers.yml` exists**. This is a pre-existing gap, recorded here as an observation; it does not change the uniform thresholds, which apply to every tier.

### 9.3 Test placement and hermeticity

- `.claude/rules/general-unit-test.md` — "Test files must live in a `tests/` directory tree that mirrors the production source structure." The strict mirror for `scripts/dev_tools/pr_context/verification_evidence.py` is `tests/scripts/dev_tools/pr_context/test_verification_evidence.py`. The existing pr-context tests sit flat at `tests/scripts/dev_tools/test_collect_pr_context*.py`, but the repository already has a precedent for a mirroring subpackage with `__init__.py` (`tests/scripts/dev_tools/atomic_executor/__init__.py`). Recommend the strict mirror; flag the divergence from the flat sibling files so the planner makes it deliberately.
- Temporary files are prohibited. Use `mem_fs_path` (`tests/conftest.py:145`) for Python and the existing `SeededFileSystem` / `TreeFileSystem` for TypeScript. Never `tmp_path`.
- Arrange–Act–Assert, one behavior per test, `pytest.mark.parametrize` for the boundary matrix of §6.2.

### 9.4 Exact toolchain commands (quoted from repository configuration, not guessed)

**Python** — run from the repository root, in this order, restarting at step 1 on any failure or file modification (`.claude/rules/python.md:13-18`):

```
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

Supporting configuration: `pyproject.toml:84-86` (Black, line-length 88, target py310), `pyproject.toml:88-93` (Ruff, `fix = true`), `pyproject.toml:142-145` (`[tool.pyright] typeCheckingMode = "strict"`, `pythonVersion = "3.12"`), `pyproject.toml:114-117` (`addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`, `testpaths = ["tests"]`). Because `addopts` does not include `--cov`, the coverage flags above are load-bearing.

**TypeScript** — the changed file lives in the extension workspace, so run the extension's own scripts from `extensions/drm-copilot/` (`extensions/drm-copilot/package.json:202-213`):

```
npm run format      # prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
npm run lint        # eslint --no-error-on-unmatched-pattern src test
npm run typecheck   # tsc -p ./ --noEmit
npm run test:unit   # node run-jest.cjs
npm run test:coverage   # node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary
```

The root workspace has its own distinct scripts (`package.json:31-36`): `format` / `format:check` scope Prettier to root `src` and `tests`, `lint` runs `eslint ... src tests`, `test:unit` is `node run-jest.cjs`, and `test:unit:coverage` is `node run-jest.cjs --coverage`. The root scripts do **not** cover `extensions/drm-copilot/src`; use the extension workspace scripts for this change. `.claude/rules/typescript.md:13-16` names the generic `npm run format` / `lint` / `typecheck` / `test:unit` forms, which resolve to the extension scripts when invoked from the extension directory.

### 9.5 Documentation surfaces that must move together

The evidence schema is documented in six copies. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:106-112` is the canonical statement:

```
When evidence artifacts are used for automated checking or plan reconciliation, include:
- `Timestamp: <ISO-8601>`
- `Command: <exact command>`
- `EXIT_CODE: <int>`
```

The identical block appears at `.github/skills/evidence-and-timestamp-conventions/SKILL.md:79-84`, and in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, plus three bundled mirrors:

- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md`

Mirror byte-identity is enforced by push-down contract tests (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and the copilot-side equivalents), and the mirrors are generated by `scripts/dev_tools/push_down_claude_customizations.py`, `push_down_copilot_customizations.py`, and `push_down_codex_and_agents_customizations.py`. Editing the canonical skill without regenerating the mirrors will fail those tests.

`.claude/skills/atomic-plan-contract/SKILL.md` also names the required field set at lines 34, 45, 87, 102 and constrains `EXIT_CODE` values at 135; it has the same six-copy fan-out. Whether the optional key needs to be named there is a spec decision — it is optional, so the "MUST include" lists need not change.

---

## 10. Recommended Design (single approach)

1. **Schema:** add one optional, flat, integer-valued key `ExpectedExitCode`, defaulting to `0` when absent. No list form, no boolean form. (§7.3 Option A.)
2. **Parsers:** in both runtimes, keep `REQUIRED_FIELDS` byte-identical; add a separate optional-field constant and a private combined accept-list used by the parse loop; add `expected_exit_code` / `expectedExitCode` to the record; replace the two normalization expressions with an equality test against the expectation. (§7.6.)
3. **Malformed expectation:** a present-but-non-integer `ExpectedExitCode` yields `unparseable`, consistent with `EXIT_CODE`. (§7.4 A1.)
4. **Result vocabulary:** unchanged — `pass | fail | unparseable`. Both renderers and both filters stay untouched. (§4.1.)
5. **Optional render line:** if reviewer legibility is wanted, add one conditional row line emitted only when the expectation is non-zero. Spec decision; both variants are additive. (§7.7.)
6. **Duplicate-key precedence:** name the pre-existing divergence in the spec and choose Option P1 (converge on first-wins, evidenced separately) or P2 (defer, file separately). Do not leave it unstated. (§3.3.)
7. **Multi-gate artifacts:** declare per-gate expectations out of scope and document the one-gate-per-artifact guidance. (§7.5.)
8. **Documentation:** add the optional key to the canonical `evidence-and-timestamp-conventions` skill and regenerate all mirrors via the push-down scripts. (§9.5.)

### Rejected alternatives (brief)

- **List-valued `ExpectedExitCodes`** — no demonstrated need in the corpus, and it multiplies the cross-runtime parity surface (separator, empty-element, and ordering semantics). Remains a strictly additive future extension of the same key.
- **Boolean / qualitative `ExpectedNonZeroExit` or `ExpectedResult`** — discards the value, so a gate failing for the wrong reason (e.g. `git grep` exit 2 on a bad pathspec) would be reported as passing. False-positive direction; strictly worse than the current defect.
- **A fourth `NormalizedResult` member (e.g. `expected-fail`)** — forces changes to both renderers and both filters for no informational gain over `pass` plus a declared expectation.
- **Reusing or copying `qc_runner_expectations.py`** — four independent mismatches in input type, granularity, side-effect class, and lifecycle position. (§8.)

---

## 11. Requirements Mapping

| Issue acceptance point (`issue.md`) | Design element | Files |
| --- | --- | --- |
| Artifact can declare an expected exit code (32-34) | `ExpectedExitCode` on the accept-list | both parsers |
| Observed == declared ⇒ `pass` (34) | equality normalization replacing lines 136 / 146 | both parsers |
| Default expectation `0`; existing artifacts unchanged (34) | default when key absent; proved by §6.2 + §6.3 | both parsers, new tests, evidence artifact |
| Non-integer expectation ⇒ `unparseable` (91) | A1 branch alongside the existing `EXIT_CODE` int branch | both parsers |
| Row still shows the observed exit code (92) | renderers unchanged; `EXIT_CODE` row already prints the observed value | `collector.py:162`, `collector-output.ts:121` |
| Byte-identical output without the key (93) | §6.2 equivalence assertion + §6.3 corpus run | new tests + evidence |
| Python/TypeScript parity across the same artifact set (93) | §6.3 cross-runtime corpus diff; §3.3 decision on duplicate-key precedence | both parsers, evidence |

### Proposed state model

Parsing is a four-way decision, unchanged in shape, extended in one branch:

```
missing/empty required field        -> unparseable
EXIT_CODE not an integer            -> unparseable
ExpectedExitCode present, not int   -> unparseable            (new)
observed == expected (default 0)    -> pass                   (was: observed == 0)
otherwise                           -> fail
```

For every artifact with no `ExpectedExitCode` line, `expected == 0` and the last two rows collapse to the pre-change expression exactly.

### Required file changes

**Production (both runtimes, required):**
- `scripts/dev_tools/pr_context/verification_evidence.py`
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`

**Production (conditional on the render decision, §7.7):**
- `scripts/dev_tools/pr_context/collector.py:155-165`
- `extensions/drm-copilot/src/lib/pr-context/collector-output.ts:115-124`

**Tests (required):**
- New: `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` (plus `__init__.py`), or the flat `tests/scripts/dev_tools/test_verification_evidence.py` if the planner prefers the existing sibling convention
- Extend: `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts`

**Tests (conditional on the render decision):**
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py` (section-content assertions at 490-497)
- `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` (`describe` at 268)

**Documentation (required):** the six `evidence-and-timestamp-conventions/SKILL.md` copies listed in §9.5, produced by editing the three canonical copies and regenerating the three mirrors.

**Evidence (required):** `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md` per §6.3, plus the standard baseline and final-QC artifacts.

---

## 12. Testing Implications

Strategy only; no test code is authored here.

- **Unit, Python (new module).** Parametrized coverage of the eleven shapes in §6.2 plus the pure-normalization equivalence assertion. Fixtures are inline markdown strings; the file-reading function is exercised through `mem_fs_path`. Targets both the previously-untested `fail` branch and the new expectation branches, which is what keeps changed-line coverage from regressing (§9.2).
- **Unit, TypeScript (extend existing).** The same eleven shapes added to the existing `describe("parseVerificationEvidenceMarkdown")` block, reusing `SeededFileSystem`. Add one test that pins the chosen duplicate-key precedence for the **new** key explicitly, mirroring the existing test at line 151.
- **Parity.** A shared, human-readable fixture table (the eleven shapes) transcribed into both suites so a reviewer can diff them by eye. If Option P1 is chosen, add the Python test that pins first-wins for `EXIT_CODE` and record the before/after for the 156 affected artifacts as regression evidence.
- **Collector-level.** Only if the render decision changes a renderer: one added case per runtime asserting the conditional expectation line appears when the key is non-zero and does not appear when it is absent.
- **Determinism.** No clock, no randomness, no network, no subprocess in any of the above. `.claude/rules/general-unit-test.md` "Determinism Infrastructure" imposes no additional obligation on this change.
- **Property-based tests.** The normalization is a pure function; the bounded-integer parametrization in §6.2 is the practical equivalent and is preferred over introducing `hypothesis` / `fast-check` for a two-argument integer comparison. If the module's tier classification demands a formal property test, one property (`normalize(c, c) == "pass"` for all integers `c`) is sufficient and cheap. Tier classification cannot be confirmed because no root `quality-tiers.yml` exists (§9.2).
- **Not required:** golden/snapshot tests (no golden fixture exists for this section, §4), mutation testing (per-commit loop excludes it), contract/schema tests (no schema file governs this artifact — the schema is prose in the conventions skill).

---

## Automation Feasibility

**Assessment: the fix and its verification are fully automatable. No human interaction is required at any step.**

Evidence:

1. **The change is pure local code.** The required production edits are confined to two files (`verification_evidence.py`, `verification-evidence.ts`), both pure functions with no network, credential, or host dependency. `parse_verification_evidence_markdown` declares `Side Effects: None.` (`verification_evidence.py:96-97`); the TypeScript port routes all filesystem access through an injected `FileSystem` (`verification-evidence.ts:15-19`).
2. **Verification is local toolchain execution.** Every gate is a command in §9.4 that runs offline against the working tree: `poetry run black/ruff/pyright/pytest` and the extension's `npm run format/lint/typecheck/test:unit/test:coverage`. None requires GitHub, a runner, an interactive prompt, or a credential.
3. **The additive proof is machine-checkable.** The §6.2 equivalence assertion is a deterministic unit test. The §6.3 corpus run reads 968 git-tracked files already present in the working tree and emits a count and a diff count; it requires no external service.
4. **No workflow, no branch-protection, and no runner-class dependency.** The change touches no file under `.github/workflows/**` and no benchmark baseline, so neither `.claude/rules/ci-workflows.md` nor `.claude/rules/benchmark-baselines.md` imposes a green-run requirement on the diff. (Regenerating the six documentation mirrors is a local script run, not a workflow.)
5. **The judgment calls are spec decisions, not human interactions.** Three choices must be fixed before execution — the duplicate-key precedence scope (§3.3), the malformed-expectation policy (§7.4), and whether to render the expectation (§7.7). Each is resolved by writing it into `spec.md` during planning; none requires a human to run a command, approve an external action, or inspect a runtime the agent cannot reach.

No `human_interaction` requirement should be recorded in the orchestrator-state checkpoint for this feature.

---

## Open Decisions and Unknowns

**No blocking unknown was found.** The following are decisions the spec author must record; each is resolvable from the evidence in this document without further investigation:

1. **Duplicate-key precedence** (§3.3) — Option P1 (converge on first-wins now, with separate before/after evidence for 156 artifacts) or P2 (defer and file separately). Recommendation: P1.
2. **Malformed expectation policy** (§7.4) — A1 (`unparseable`, consistent with `EXIT_CODE`) or A2 (ignore, default to 0). Recommendation: A1.
3. **Whether to render the expectation** (§7.7) — affects two additional production files and two additional test files, both already over or near the 500-line limit. Recommendation: render conditionally.
4. **Python test-module path** (§9.3) — strict mirror `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` versus the existing flat sibling convention. Recommendation: strict mirror, precedent `tests/scripts/dev_tools/atomic_executor/`.

Two pre-existing conditions are recorded as observations, not as work in scope: `scripts/dev_tools/pr_context/collector.py` is 619 lines (over the 500-line limit), and no root `quality-tiers.yml` exists despite `.claude/rules/quality-tiers.md` naming it as the source of truth.
