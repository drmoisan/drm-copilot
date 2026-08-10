# Research: Parallel-Surface Destination Portability via Bash (Issue #462)

- Timestamp: 2026-08-10T09-45
- Feature: `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/`
- Canonical issue: #462
- Author: task-researcher agent
- Status: research complete; no production code written

## Verified Problem Restatement

All four reported blockers were re-verified against this repository during this research pass:

1. `compute_cohorts` exists only at `scripts/dev_tools/parallel_cohort_computation.py` (468 lines, read in full). No `.claude/lib/` port and no TypeScript port exists (`Glob .claude/lib/**` returns only `blast-radius/*.psm1`, `model-routing/ModelRouting.psm1`, `orchestrator-state/*.psm1`).
2. `scripts/dev_tools/parallel_manifest_contract.py` (312 lines, read in full) is a library call only; `.claude/rules/parallel-orchestration.md` states manifest validation "is deliberately not a third MCP `artifact_type`" and `.claude/skills/parallel-plan/SKILL.md:279-282` forbids validating it through the MCP tool.
3. The Claude push-down publishes only the `.claude` root: `ROOT_FOLDERS = [".claude"]` at `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:37`, passed to the shared engine at `claude-customizations.ts:239`. No `config/` file can reach a destination.
4. The bundled copy of `parallel-orchestration.md` exists at `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`, but the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:54-62` lists only nine rules files and omits it. Pack-scoped publishes therefore drop the file (`ExcludingFileSystem.isPackIncluded`, `claude-filesystem-adapter.ts:179-189`).

An additional verified fact that reframes part of the work: **the production push-down does not publish from the repository root.** `pushDownClaudeCustomizationsServiceCall` resolves `sourceRoot = <extensionRoot>/resources/claude-customizations` and passes it as both `sourceRoot` and `bundleRoot` (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:169-193`). Every new destination-runtime file must therefore exist in two places: the repo-root `.claude/` tree (this repository's own runtime) and the bundled tree under `extensions/drm-copilot/resources/claude-customizations/` (the push-down source). The existing PowerShell library precedent already enforces this dual-home model via `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1:62-75` ("Bundled payload parity").

---

## Q1 — Bash Cohort Computation

### Source contract (read in full: `scripts/dev_tools/parallel_cohort_computation.py`)

Two public functions, both pure:

- `compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]` (lines 350-416).
- `compute_concurrency_batches(cohort_item_keys: Sequence[int], max_concurrency: int) -> list[list[int]]` (lines 419-468).

Algorithm, in the exact order the Python executes it:

1. **Duplicate-key validation** (`_validate_item_keys`, lines 129-167): walk keys in supplied order; the first repeated key raises `ParallelCohortInputError` with the literal message `Duplicate item key {k} in item_keys; item keys must be unique because cohort ordering relies on key uniqueness.`
2. **Adjacency build** (`_build_adjacency`, lines 216-263): seed every declared key with an empty neighbor set (isolated vertices survive, line 252); for each edge validate then add both directions. Edge validation (`_validate_edge`, lines 170-213) checks self-loop first (message `Self-loop edge on item key {k}; the conflict relation is defined over distinct items, so an item cannot conflict with itself.`), then unknown endpoint (message `Conflict edge {edge} names item key {endpoint}, which is not a member of item_keys; every edge endpoint must be a declared item key.` — note `{edge}` renders as a Python tuple repr, e.g. `(101, 999)` with a space after the comma). Set-based neighbor storage collapses direction and duplicates (lines 220-227).
3. **Welsh-Powell order** (`_welsh_powell_order`, lines 266-296): sort the vertex set by the composite key `(-degree, item_key)` ascending, where degree is distinct-neighbor count. The docstring at lines 269-274 states this is the single load-bearing determinism guard: the composite key is a total order (keys unique), so neither Python sort stability nor input order can leak into the result.
4. **Greedy assignment** (`_assign_cohort_indices`, lines 299-347): in visit order, each vertex takes the smallest index not held by an already-assigned neighbor (upward scan from 0, lines 341-345).
5. **Output shaping** (lines 402-416): empty assignment returns `[]`; otherwise `cohort_count = max(indices) + 1`, and membership is filled by walking `sorted(cohort_index_by_key)` — numerically ascending keys — so every inner list is ascending regardless of input order.

`compute_concurrency_batches` (lines 419-468): rejects `max_concurrency < 1` with `max_concurrency must be >= 1; received {n}.`, sorts the cohort keys ascending, and chunks into consecutive slices of at most `max_concurrency`.

### Input/output contract for the bash port

Recommended CLI shape (the Python has no CLI; the bash port must define one):

- `compute-cohorts.sh --keys "<k1> <k2> ..." --edges "<a>:<b> <a>:<b> ..."` (or stdin lines: first line keys, following lines `a b` pairs). Output: one compact JSON array of arrays on stdout, e.g. `[[101,103],[102]]`, produced by `printf` — trivially deterministic and directly comparable to the Python's `json.dumps(compute_cohorts(...), separators=(",", ":"))`. Errors: the exact Python message on stderr, exit code 1.
- `compute-concurrency-batches.sh --keys "<...>" --max-concurrency <n>` with the same output convention.

The parity contract (planner invariant P5, `.claude/rules/parallel-orchestration.md` planner section; discharged procedurally at `.claude/skills/parallel-plan/SKILL.md:244-258`) requires the bash partition, index assignment, and per-cohort ascending ordering to be identical to Python. JSON-array output makes fixture equality a plain string comparison.

### Graph representation in bash

- Adjacency as a bash associative array of membership flags: `adj["$a,$b"]=1` and `adj["$b,$a"]=1` (collapses direction/duplicates exactly as Python's sets do), plus a per-vertex degree counter incremented only when the pair was not already present.
- Vertex list as an indexed array in supplied order (needed for duplicate-error reporting order).

### Python-specific behaviors bash does not reproduce for free

| Python behavior | Bash hazard | Required countermeasure |
| --- | --- | --- |
| `sorted()` over ints is numeric | `sort` defaults to lexicographic (`10 < 9` fails) | `sort -n` everywhere; composite key via `sort -k1,1nr -k2,2n` over `"degree key"` lines |
| Negative keys are valid ints (planner intake uses `-1, -2` placeholders) | naive `[0-9]+` validation rejects them; lexicographic sort misorders them | accept `-?[0-9]+`; `sort -n` handles negatives correctly |
| Leading-zero tokens: Python `int("010")` = 10; JSON never emits them | bash `$(( 010 ))` is octal 8 | validate tokens with a strict regex and strip/reject leading zeros; document the accepted lexical form |
| `dict` insertion order is deterministic and *never used* for output (lines 291-296, 410-414 sort explicitly) | bash associative-array iteration order (`${!arr[@]}`) is unspecified | never iterate an associative array into output; always derive order from an explicit `sort` |
| Set membership for `candidate_index in neighbor_indices` | none — associative-array membership is equivalent | use `[[ -v ]]` membership checks |
| Tuple repr in the unknown-endpoint message: `(101, 999)` | must be formatted manually | `printf '(%s, %s)' "$a" "$b"` |
| Sort locale: Python compares ints | `sort` honors locale collation | export `LC_ALL=C` at entry-point top (matches the discovery contract in `.claude/rules/shell.md:55`) |
| Python raises before any coloring work (line 390: "All validation runs before any coloring work") | error ordering must match: duplicate-key errors precede edge errors; self-loop check precedes unknown-endpoint for the same edge (lines 191-213) | preserve the validation sequence exactly |

Recommendation: port **both** public functions. `compute_concurrency_batches` is ~30 lines of bash, and `.claude/skills/parallel-orchestrate/SKILL.md:127` names it as the execution-phase slot-filling mechanism; porting only `compute_cohorts` would leave `/parallel-run` with the same class of destination gap this feature closes for `/parallel-plan`.

---

## Q2 — Bash Manifest-Contract Validation

### Source contract (read in full: `scripts/dev_tools/parallel_manifest_contract.py` plus its shared helper `scripts/dev_tools/_parallel_state_common.py`, read in full)

Pipeline (`validate_parallel_manifest_text`, lines 274-312):

1. **M1** — line split tolerant of LF/CRLF/CR via `re.compile(r"\r\n|\n|\r")` (line 80, ordering load-bearing per the comment citing commit b845c505); fence extraction (`extract_frontmatter_body`, lines 105-140) with two distinct errors: `Parallel manifest must open with a '---' frontmatter fence.` and `Parallel manifest frontmatter block is not terminated by '---'.`; `yaml.safe_load` with failure message `Parallel manifest frontmatter is not valid YAML: {exc}.` (line 175, embeds the PyYAML exception text); non-mapping message `Parallel manifest frontmatter must be a mapping.` (line 178).
2. **M2-M5** — `_validate_identity` (lines 232-271) in schema field order: `parallel` non-empty string; presence-gated `mode` enum via the shared `enum_error` builder (`_parallel_state_common.py:205-227`: `"{context} {field} must be one of {', '.join(members)}; found: {value!r}."`); presence-gated `max_concurrency` bounded 1-8 excluding booleans, message `Parallel manifest max_concurrency must be an integer from 1 through 8; found: {value!r}.`; `created_at` non-empty string.
3. **M7** — `scan_prohibited_keys` (`_parallel_state_common.py:462-495`): deep scan for `depends_on` (depth-first, mapping keys in document/insertion order, lists indexed as `path[i]`), then top-level-only `integration_branch`; message `Parallel manifest carries prohibited key '{key}' at {path}.` with `<root>` for the document root.
4. **M6** — `validate_items(..., require_kind=True)` (`_parallel_state_common.py:380-425`): per-entry positional errors via `item_context` (`Parallel manifest items[{i}]`), then duplicate `issue_num` errors in ascending key order (`{context} has duplicate items[].issue_num: {n}.`). `validate_item_record` (lines 336-377) checks `issue_num` positive int (`found: {value!r}`), `feature_folder` non-empty string, `state` enum, `kind` enum, presence-gated `merge_status` enum plus the state-consistency rule (`_validate_merge_status`, lines 293-333, messages at 323-333), and the blast-radius block (`validate_blast_radius_block`, lines 249-290: four list-of-non-empty-string fields in order, `source` enum, `computed_at` non-empty).

Also two default-resolving accessors: `manifest_mode` (lines 182-203, default `closed`) and `manifest_max_concurrency` (lines 206-229, default `4`), which the bash port must also expose (e.g. `--print-mode` / `--print-max-concurrency` subcommands), since `.claude/skills/parallel-plan/SKILL.md:279-282` names them as the required consumption path.

### The YAML parsing decision

Three approaches evaluated:

**(a) Hand-written bash parser restricted to the manifest subset — RECOMMENDED.**
The manifest frontmatter is machine-authored (by the parallel-planner itself, per `.claude/skills/parallel-plan/SKILL.md:260-277`) and its schema is closed: four top-level scalars plus an `items` list of objects whose only nesting is one `blast_radius` object holding four string lists and two scalars. A parser restricted to block-style mappings, block-style lists, plain/single-quoted/double-quoted scalars, and lexical type classification (`-?[0-9]+` → int, float pattern → float, `true|false|True|False` → bool, `null|~` → null, else string) covers every document the planner emits. Any construct outside the subset (flow style `[a, b]`, anchors, multi-line scalars, tabs-as-indentation) is rejected **fail-closed** with a bash-specific parse error. This mirrors the accepted precedent of the TypeScript port: `.claude/rules/parallel-orchestration.md` (Enforcement section) records a *verified scope* ("96 of 96 error strings matched across 43 constructed documents, for JSON-representable values that round-trip") with three named divergence classes outside it. The bash port should declare its supported subset the same way.
- Advantage: zero new destination dependency; the whole point of the feature.
- Limitation: byte parity holds only within the declared subset; a hand-authored manifest using exotic YAML gets a divergent (but still failing-closed) error.

**(b) Require `yq` — REJECTED.**
`yq` is not part of any base toolset this repository assumes (`.claude/rules/shell.md:36-44` names only shfmt, shellcheck, bats, kcov, none preinstalled at destinations either), it is not apt-packaged in the same form everywhere (mikefarah `yq` vs. python-wrapper `kislyuk/yq` have incompatible CLIs and YAML-to-JSON semantics), and pinning it reintroduces exactly the provisioning burden (Python/Poetry) this feature exists to remove. Its type coercions (e.g. integral floats, quoting) would create a fourth divergence surface rather than remove one.

**(c) Reuse an existing destination runtime (Node via the MCP server) — REJECTED.**
Destinations running the MCP surface do have Node, but Node has no built-in YAML parser and the MCP server deliberately excludes a manifest artifact type (`.claude/rules/parallel-orchestration.md`, "Manifest validation is a library call ... deliberately not a third MCP `artifact_type`"). Adding one would violate the "no schema/validator surface change" constraint (issue.md AC: "No parallel-surface schema field, enum member, or validator invariant is added, removed, or altered") and the F3 ownership boundary.

### Reproducing the error strings exactly

- Every message begins `Parallel manifest ` and ends with a period (`parallel_manifest_contract.py` module docstring, lines 24-26). All enum messages flow through one template; the bash port should likewise centralize `enum_error` in the shared library so wording cannot drift between checks.
- **pythonRepr** must be implemented for the value domain that reaches `{value!r}`: `None` (absent key → `found: None.`), `True`/`False`, integers, floats, and strings. String repr must implement Python's quote-selection rule: single quotes by default; double quotes when the string contains `'` and no `"`; backslash-escape for `\`, the active quote, `\n`, `\r`, `\t`. This is precisely where the TS port diverges (divergence class 1, `parallel-state-shared.ts:112-132` always single-quotes, recorded in `.claude/rules/parallel-orchestration.md` and `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`); bash can and should implement the real rule for the printable-string subset, and record non-printable escapes (`\x..`) as out of verified scope.

### How the three known TS divergence classes map to bash

1. **pythonRepr quote selection** — applies identically; bash mitigation as above (implement the rule rather than always-single-quote).
2. **Integral floats** — does *not* apply the same way. The TS port loses `int` vs `float` because `JSON.parse` erases it. The bash parser reads the YAML text directly and classifies lexically, exactly as PyYAML does for the subset (`4` → int, `4.0` → float), so bash can *avoid* this divergence class entirely within the subset. The float repr (`4.0` → `4.0`) is preserved by keeping the raw scalar text for error rendering.
3. **Boolean/integer equality** — Python's `is_integer`/`in_bounded_range` explicitly exclude booleans (`_parallel_state_common.py:122-134, 187-202`). Bash must tag `true/false` as type `bool` at parse time and reject them in integer slots, rendering `found: True.`/`found: False.`. Lexical tagging makes this exact; there is no `===`-style trap in bash provided the type tag travels with the value.
4. **A fourth, bash-specific divergence class:** the M1 YAML-error message embeds `{exc}` — PyYAML's exception text with line/column details (line 175). This is unreproducible byte-for-byte. Record it as a divergence class: the bash validator emits its own single-element parse-failure message (still prefixed `Parallel manifest frontmatter is not valid YAML: ` plus a bash-side diagnostic), and the parity corpus asserts only prefix + single-element-list shape for this case, not full byte equality.

### Internal representation

Recommend the parser emit a flattened, ordered, type-tagged event stream (one line per node: `path<TAB>type<TAB>raw-value`, e.g. `items.0.blast_radius.paths.1	str	docs/...`), consumed by the validator stage. This gives the prohibited-key scan its required document order for free and keeps the parser and the M2-M7 logic in separate files under the 500-line cap.

---

## Q3 — Parity Testing

### Existing patterns examined

- `tests/scripts/dev_tools/test_blast_radius_parity.py` (lines 1-56 read): parametrizes over the committed corpus `tests/fixtures/blast_radius/*.json` (26 fixtures on disk, verified by Glob), asserts the Python reference reproduces each fixture's `expected` block, and enforces a `MINIMUM_FIXTURE_COUNT = 26` floor so a broken glob cannot pass vacuously (lines 53-56). The same corpus is asserted by `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (named at line 7). Neither suite executes the other runtime.
- `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts` (lines 1-100 read): same shared-corpus model over `tests/fixtures/parallel_cohort_barrier/*.json`, with the rationale stated at lines 19-27: "Per-side coverage is structurally blind to divergence"; corpus floor `MINIMUM_CORPUS_COUNT = 30` (line 78); corpus deliberately restricted to values that round-trip both runtimes (lines 44-51).

### Transfer assessment

The shared-committed-corpus pattern transfers directly and is the recommendation. Neither existing suite performs cross-process execution, which is exactly what the ubuntu-latest/bash vs. elsewhere/Python split requires: each runtime asserts the same committed files in its own CI lane.

Concrete design:

- New corpus `tests/fixtures/parallel_cohorts/*.json`: `{ "name", "notes", "input": { "item_keys": [...], "conflict_edges": [[a,b],...] }, "expected_cohorts": [[...],...] }`, plus error cases carrying `"expected_error"` (the exact message). New corpus `tests/fixtures/parallel_manifest_bash/*.json`: `{ "name", "notes", "manifest_text", "expected_errors": [...] }` with `manifest_text` JSON-encoding CRLF/CR variants where needed. (The Python manifest module may already have per-side pytest cases; the corpus binds them to bash.)
- Python side: `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` and `test_parallel_manifest_bash_parity.py`, parametrized over the corpora, asserting the Python reference reproduces every `expected_*` block, with a fixture-count floor. Runs wherever pytest runs.
- Bash side: `tests/shell/parallel_cohorts_parity.bats` and `tests/shell/parallel_manifest_parity.bats`, iterating the same files (a small `jq`-free JSON reader is not needed — bats can compare the entry point's stdout against the fixture's expected block extracted at fixture-authoring time into sibling `.expected` text files, or the entry points can accept the fixture JSON directly if a minimal reader is included; decide at planning, but note `.claude/rules/shell.md:85-88` forbids temp files and requires checked-in fixtures — both corpus designs comply). Runs on ubuntu-latest via `_shell-coverage.yml`.
- Scope statement in each suite header naming the verified subset and the divergence classes (M1 YAML-error text; non-printable string repr), following the parity-claim-scope precedent at `parallel-cohort-barrier-parity.test.ts:44-51`.

Both lanes run on every push/PR: `ci.yml:26-27` calls `_shell-coverage.yml` unconditionally (no path filter), and the pytest lane runs under `_quality-checks.yml`. Silent drift requires both lanes to miss a corpus change, which the shared files prevent by construction.

---

## Q4 — Push-Down Config Carriage

### Pipeline as read

- Engine (`copilot-customizations-engine.ts`, read in full): enumerates `rootFolders` in order (`enumerateSourceFiles`, lines 156-175), validates destination (lines 185-205), and for each file: classify created/overwritten by `fs.isFile(destinationPath)` (lines 387-391), read source, apply `rewrite(sourceText)` (lines 398-399), `ensureDir` + `writeTextFile` (lines 416-417). Defaults: `rootFolders ?? COPILOT_ROOT_FOLDERS` (line 360, the four `.github` roots at lines 37-42).
- Claude entry (`claude-customizations.ts`, read in full): passes `rootFolders: ROOT_FOLDERS` (line 239) and `rewriteReferences: passthroughRewrite` (line 241); composes `ExcludingFileSystem` (lines 219-231).
- Copilot entry uses the engine default roots; Codex has its own entry (`codex-agents-customizations.ts`) and bundled source root `resources/codex-and-agents-customizations` (`push-down-service-call.ts:123-126`). **Neither reads the Claude `ROOT_FOLDERS` constant**, so extending the Claude constant cannot alter the Copilot or Codex published sets. That is the precise non-interference statement: no edit to `copilot-customizations-engine.ts` semantics, no edit to `COPILOT_ROOT_FOLDERS` (engine lines 37-42), no edit to the Codex entry.

### Publishing `config/`

1. Add the bundled subtree `extensions/drm-copilot/resources/claude-customizations/config/` containing `orchestration-routing.json` (canonical routes, including `parallel` and `preparation`) and the **generic** `blast-radius.json` (Q5). Note this is distinct from the existing `extensions/drm-copilot/resources/config/orchestration-routing.json`, which is the extension-runtime mirror, not a push-down source (verified: the push-down bundle root is `resources/claude-customizations`, `push-down-service-call.ts:169-172`).
2. Change `ROOT_FOLDERS` at `claude-customizations.ts:37` to `[".claude", "config"]`. Enumeration order is the summary-artifact contract (engine lines 33-36), so append `config` after `.claude`.
3. Pack manifests: `ExcludingFileSystem.isPackIncluded` compares source-root-relative paths (`claude-filesystem-adapter.ts:179-189`), and manifest paths are unioned without a `.claude/` prefix check (`claude-pack-selection.ts`, verified by grep — only the C# canonical list is `.claude/`-specific). `config/orchestration-routing.json` and `config/blast-radius.json` entries in `core.json` therefore flow through the existing mechanism. Verify this with a targeted Jest case during implementation.
4. This repository's own `config/` files are unaffected: the push-down source is the bundle, and this repo is never a push-down destination of itself.

### The routing merge

**Where it belongs.** Not in the engine and not in `rewriteReferences`: the rewrite seam receives *source text only* (`RewriteFunction`, applied at engine lines 398-399) and has no access to destination content, so a merge is structurally impossible there. The correct seam is a Claude-side filesystem decorator — the same position `ExcludingFileSystem` already occupies, which already performs destination-aware behavior for the `merge` memory mode (`claude-filesystem-adapter.ts:219-241` reads `inner.isFile(destinationPath)`). Add a narrowly-scoped wrapper (either a new option on `ExcludingFileSystem` or a second decorator composed over it in `claude-customizations.ts`) whose `writeTextFile` special-cases the single destination-relative path `config/orchestration-routing.json`:

- Destination file absent → write the source text unchanged (plain copy; first publish).
- Destination file present → parse both as JSON, produce the merged object, write it with deterministic 2-space serialization (the engine already has `stringifySorted` as a precedent for deterministic JSON, engine lines 283-303, though the merge should preserve destination key order for untouched keys — decide the exact serialization rule at planning and pin it with a Jest idempotency test: pushing twice must be byte-stable).

**Merge rule (recommended):**

1. Start from the destination document.
2. `routes.parallel`: source-authoritative — overwrite or insert the source's `parallel` route definition. Rationale: every other pushed file is overwritten by push-down; the `parallel` route is source-owned content, and preserving a stale destination copy would silently pin destinations to an outdated route contract.
3. Any other source route absent at the destination is added; any route present at the destination (local or shared) is preserved verbatim. This matters because `/parallel-plan` also requires the `preparation` route (the kickoff line at `.claude/skills/parallel-plan/SKILL.md:72` carries `route_id: preparation`); a destination with a routing file that predates `preparation` would otherwise still be broken.
4. Top-level non-`routes` blocks (`model_policy`, `model_budget`, `codex_topology_policy`, `codex_model_policy`, `version`, `$schema`): added when absent, preserved when present.
5. Unparseable destination JSON → fail the file with an explicit error in the run summary rather than clobbering it (fail fast per `.claude/rules/general-code-change.md`).

`config/blast-radius.json` needs no merge: destinations either lack it (copy) or received it from a prior push-down (overwrite is correct for source-owned generic content). If a destination has locally enriched it, that is the one case where overwrite loses data; record this as an accepted limitation or extend the wrapper with a "destination file exists and differs → skip and report" rule. Recommendation: plain overwrite, documented, matching every other pushed file; a destination that customizes should copy to a differently-named local file only if the consuming code supports it (it does not today), so the practical loss risk is low.

---

## Q5 — Genericized Blast-Radius Config

### Consumption as read

`config/blast-radius.json` (read in full) carries five keys: `version`, `shared_surfaces` (exact paths), `shared_surface_globs` (glob patterns), `modules` (name → glob list), `over_breadth_fraction` (0.25). Consumers: `scripts/dev_tools/_blast_radius_thresholds.py` reads `over_breadth_fraction` via `config_over_breadth_fraction` (line 47-50); extraction/conflict modules (`_blast_radius_extraction.py`, `_blast_radius_conflicts.py`) consume `shared_surfaces`, `shared_surface_globs`, and `modules` as the truth table for radius derivation and the contention relation (`.claude/skills/parallel-plan/SKILL.md:157-171`). The PowerShell port `.claude/lib/blast-radius/BlastRadiusConfig.psm1` parses the same shape at destinations.

### Repo-specific entries to remove from the published default

From `config/blast-radius.json:3-19`: `poetry.lock`, `package-lock.json`, `extensions/drm-copilot/package-lock.json`, `packages/mcp-server/package-lock.json`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, the `scripts/dev_tools/*` glob triplet in `shared_surface_globs`, and the repo-specific `modules` entries (`python-dev-tools`, `powershell-dev-tools`, `poshqc`, `benchmarks`, `codex-runtime`, `mcp-server`, `vscode-extension`, `schemas`).

### Recommended generic default (bundled at `resources/claude-customizations/config/blast-radius.json`)

- `version: 1`.
- `shared_surfaces`: only paths the push-down itself guarantees exist at any destination: `.claude/settings.json`, `config/orchestration-routing.json`, `config/blast-radius.json`.
- `shared_surface_globs`: `[]` (nothing repo-agnostic can be assumed).
- `modules`: the structure-guaranteed trees only: `claude-runtime: [".claude/**"]`, `config: ["config/**"]`, `docs: ["docs/**"]`, `tests: ["tests/**"]`.
- `over_breadth_fraction: 0.25` (unchanged; it is a ratio, not a path).

The contention relation fails closed (`.claude/skills/parallel-plan/SKILL.md:170-172`), so a sparse config under-partitions into *more* conflict edges only when radii genuinely overlap on paths; it never hides contention — the generic default is safe in the fail-closed direction for path overlap, while module/shared-surface reasons simply fire less often until the destination enriches its config.

### How this repository keeps its richer config

No mechanism change needed: this repository's `config/blast-radius.json` at the repo root is read by its own tooling; the bundled generic default lives only under `resources/claude-customizations/config/` and is what push-down publishes. The two files are intentionally different documents, unlike the `.claude` tree where repo-root and bundle are kept in parity. This asymmetry must be documented (in the spec and in the bundle README if present) so a future "bundle parity" test does not incorrectly assert byte-equality for `config/`.

---

## Q6 — Pack Manifest

### `core.json` additions

To `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths`:

- `.claude/rules/parallel-orchestration.md` (blocker 4).
- Every new `.claude/lib/bash/*.sh` file (final names per Q9).
- `config/orchestration-routing.json` and `config/blast-radius.json` (required once `config` is a published root, because a pack-scoped publish filters *all* enumerated files against the manifest union — `claude-filesystem-adapter.ts:179-189` — so unlisted config files would be dropped under `--packs`).

Consider also `.claude/rules/shell.md`: not required to run `/parallel-plan`, but a destination whose agents modify the pushed bash library without the shell rule in context would violate the standards silently. Recommended as an inclusion, flagged `[recommendation, not upstream-constrained]`.

### Existing test: present but structurally incomplete

`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (read in full) already implements exactly the intended completeness check (issue #279 regression), against the real bundled tree and real manifests. Its enumeration function `enumerateBundledClaudeRelativePaths` (lines 62-91) walks only three directories: `agents/*.md`, `hooks/*.ps1`, and `skills/*/SKILL.md`. It never enumerates `.claude/rules/` or `.claude/lib/`, which is precisely why blocker 4 (a rules file) and the unlisted-lib class escaped it. The fix is an extension, not a new test:

- Add `rules/*.md` enumeration.
- Add a recursive walk of `lib/**` (all files, not extension-filtered, so a future non-`.psm1`/non-`.sh` lib file is caught).
- Add `settings.json` and any other top-level published files if desired (settings.json is already listed; low risk).
- Once `config` is a published root, add a second assertion that every file under the bundled `config/` tree has a manifest entry.

The per-library Pester tests (`tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`, plus the ModelRouting and OrchestratorState analogues) additionally pin each library's full membership and its bundled-counterpart existence (lines 34-75). A matching bats or Pester manifest-membership test for `.claude/lib/bash/` should follow that precedent (discover `*.sh` on disk, assert each is in `core.json`, assert a bundled counterpart exists), so the bash library gets both the generic Jest net and the library-specific check.

---

## Q7 — Destination-Runtime Wiring

Inventory of every reference to a Python parallel entry point (grep over `.claude/`, all hits reviewed):

| Location | Reference | Classification | Action |
| --- | --- | --- | --- |
| `.claude/skills/parallel-plan/SKILL.md:143-201` | radius derivation/validation/contention via `poetry run python -c ... compute_blast_radius` | destination-runtime | Repoint at the existing PowerShell port `.claude/lib/blast-radius/` (out-of-scope to re-port; in-scope to re-point). Python cited as authority/parity reference only. |
| `.claude/skills/parallel-plan/SKILL.md:202-258` | cohort seeding + P5 recomputation parity via `poetry run python -c ... parallel_cohort_computation` | destination-runtime | Repoint at the bash entry point. |
| `.claude/skills/parallel-plan/SKILL.md:279-282` | manifest validation library call to `parallel_manifest_contract.py` | destination-runtime | Repoint at the bash validator (and its accessor subcommands). |
| `.claude/agents/parallel-planner.md:16` | tools: `"Bash(poetry run *)"` | destination-runtime allowlist | Add a bash allowlist entry (see below); the poetry entry becomes unnecessary for the parallel calls once the skill repoints — retain or narrow per planning decision. |
| `.claude/agents/parallel-planner.md:134-149` | `## Upstream Library Invocation` justifying the poetry grant | destination-runtime | Rewrite to name the bash entry points; keep the Python modules named as the repository authority. |
| `.claude/agents/parallel-orchestrator.md:16-17, 71-76` | `"Bash(poetry run python -c *)"` / `"-m *"` for manifest re-validation and checkpoint-validator CLI fallback | destination-runtime | Manifest re-validation → bash. Checkpoint validation already has the MCP path as primary; the `-m` CLI fallback is a separate concern (see note). Add the bash allowlist entry. |
| `.claude/skills/parallel-orchestrate/SKILL.md:76-79` | manifest validation poetry one-liner | destination-runtime | Repoint at bash. |
| `.claude/skills/parallel-orchestrate/SKILL.md:87, 127, 488` | cohort/batch computation references (`compute_concurrency_batches` at 127) | destination-runtime | Repoint at bash (supports porting both functions, Q1). |
| `.claude/skills/parallel-orchestrate/SKILL.md:407` | `poetry run python -m ...validate_orchestration_artifacts` CLI fallback | destination-runtime fallback | Out of scope (validators are MCP-reachable); leave, or annotate MCP-primary. Note: prior project memory records the documented `python -m ...validate_orchestrator_state` CLI form as a no-op; if the same defect pattern applies to this fallback, it is a pre-existing adjacent defect to file separately, not to fix here. |
| `.claude/skills/parallel-orchestrate/SKILL.md:722` | `poetry run python -m scripts.dev_tools.parallel_drift_detection_cli` | destination-runtime, **residual gap** | Out of scope for #462 (execution-phase F8, not `/parallel-plan`). Record as a known residual destination gap in the spec so it is not mistaken for covered. |
| `.claude/skills/parallel-remove/SKILL.md:108` | `poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py` | destination-runtime, **residual gap** | Same disposition (F6 mutation CLI). |
| `.claude/skills/parallel-add/SKILL.md:60` | `conflicts(a, b, config)` from `compute_blast_radius.py` | destination-runtime | Repoint at the PowerShell port's contention function. |
| `.claude/rules/python.md`, `.claude/skills/python-qa-gate/SKILL.md`, `.claude/agents/atomic-executor.md:11-14`, `.claude/skills/feature-review-workflow/SKILL.md:108` | poetry toolchain commands | repository-local | Leave alone. |
| `.claude/hooks/*` | `python -m` appears only in `validate-orchestrator-output.ps1:160,196` and the discovery-gate hooks — none are parallel entry points | repository-local / out of scope | Leave alone. |

**Allowlist assessment.** Yes, a bash allowlist entry is needed. `parallel-planner` currently reaches the libraries only through `"Bash(poetry run *)"` (`parallel-planner.md:16`); with the skill repointed, the invocation form becomes `bash .claude/lib/bash/<entry>.sh ...`, which no current tools entry permits. Add `"Bash(bash .claude/lib/bash/*)"` to `parallel-planner.md` and the two scoped forms' equivalent to `parallel-orchestrator.md`, and mirror in `.claude/settings.json` permissions (which currently allows `Bash(poetry run *)` at `settings.json:6`). Recommendation: make the bash entry points the runtime invocation in *both* environments (they are committed to this repo's `.claude/lib/bash/` too), eliminating a dual-instruction drift surface; the Python modules remain the parity reference exercised by pytest, not by agent runtime instructions.

One consistency note: destinations already require `pwsh` (all pushed hooks are `.ps1`, `core.json:25-53`), so the parallel surface at a destination runs on bash + pwsh + Node(MCP), with Python/Poetry fully removed from the runtime path once this feature lands.

---

## Q8 — Verification Path

Confirmed by reading `.claude/rules/shell.md` and the workflows:

- The toolchain is native bash (shfmt, shellcheck, bats, kcov) with no Python/Poetry (`shell.md:36-39`); on Windows it runs under WSL (`shell.md:39`); in CI it runs on `ubuntu-latest` via `.github/workflows/_shell-coverage.yml` (`shell.md:40-42`). No delegate in this win32 environment can execute it locally; prior project memory (native-shell-toolchain-verification, issues #393/#394) records CI dispatch as the established verification path.
- `_shell-coverage.yml` (read in full): triggers `workflow_call` and `workflow_dispatch` (lines 3-5); job `shell-coverage` on `ubuntu-latest` (lines 8-10); installs shellcheck/bats via apt and pins shfmt 3.8.0 (lines 16-24); builds/caches kcov v43 (lines 26-49); runs `bash scripts/bash/shell-qc.sh test --coverage` (line 52); uploads `artifacts/pester/kcov/**` as artifact `shell-coverage` with `if-no-files-found: error` (lines 54-59).
- `ci.yml` (lines 3-8, 26-27): triggers on push/PR to main/development and `workflow_dispatch`; calls `_shell-coverage.yml` unconditionally on every run — no path filter, so any push to a PR branch exercises the shell lane.

**Concrete verification procedure for this feature's shell changes:**

1. Push the feature branch to origin.
2. Dispatch directly: `gh workflow run _shell-coverage.yml --ref <branch>` (valid because the workflow file already exists on the default branch and declares `workflow_dispatch`), or rely on the PR-triggered `ci.yml` run.
3. Poll with `gh run watch` / `gh run view --json conclusion`; on completion download the `shell-coverage` artifact (`cov.xml` merged Cobertura) and capture the log line `Bash coverage (lines): NN.N%` (`shell.md:60-63`).
4. Record the run URL, exit status, and coverage line as evidence under `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/qa-gates/` (canonical scheme per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`).

**Coverage position:** kcov reports line coverage only; the uniform >= 85% line threshold applies and there is no bash branch-coverage gate (`shell.md:60-65`, `.claude/rules/quality-tiers.md`).

**A discovered constraint that must be resolved at planning time:** the shell-QC discovery contract covers only `tools/` and `scripts/` (`scripts/bash/shell_qc_lib.sh:76-84`), and the kcov include pattern is `$repo_root/tools,$repo_root/scripts` (`shell_qc_lib.sh:323`; also `shell.md:47-48`). Files under `.claude/lib/bash/` are therefore invisible to shfmt/shellcheck discovery *and excluded from coverage measurement* as shipped. Two options:

- **(i) Extend the discovery contract — RECOMMENDED.** Add `.claude/lib/bash` to the search roots and the kcov include pattern in `shell_qc_lib.sh`, update `shell.md` (Discovery Contract and Coverage sections), and extend the existing shell-qc bats tests. Keeps `.claude/lib/bash/` as the single canonical home, matching the `.claude/lib/*.psm1` precedent where library files live only under `.claude/lib/`.
- (ii) Canonical sources under `scripts/bash/parallel/` with `.claude/lib/bash/` as a byte-identical mirror asserted by a parity test. Rejected: introduces a third copy (repo scripts + repo `.claude` + bundle) and contradicts the established `.claude/lib` precedent.

Note that `.claude/rules/shell.md` itself carries a `paths:` frontmatter scoping (`**/*.sh`, `**/*.bats`, `scripts/bash/**`, `tests/shell/**`, lines 1-8); `**/*.sh` already activates it for `.claude/lib/bash/*.sh`, so only the prose discovery/coverage sections need updating, not the activation globs.

---

## Q9 — File-Size Budget and Decomposition

The 500-line cap (`.claude/rules/general-code-change.md`, restated for shell at `shell.md:84`) applies to every new file. The Python sources total 468 + 312 lines, but the bash ports add a pythonRepr implementation, a YAML-subset parser (which Python gets free from PyYAML), and CLI entry points, while bash's comment discipline is lighter than the Python docstring policy. Proposed decomposition under `.claude/lib/bash/` (eight files), each mirrored in the bundle and listed in `core.json`:

| File | Content | Estimated lines |
| --- | --- | --- |
| `parallel-common.sh` | pythonRepr (string quote-selection, None/True/False/int/float rendering), type predicates (non-empty string, non-boolean integer, positive/non-negative, bounded range), `enum_error` and `item_context` builders, error-list accumulation helpers, `LC_ALL=C` guard | ~200 |
| `parallel-yaml-subset.sh` | Three-terminator line splitting, fence extraction (M1), restricted block-YAML parser emitting the ordered path/type/value stream, fail-closed out-of-subset errors | ~400 (highest cap risk; split scanner vs. emitter if it approaches 500) |
| `parallel-manifest-validate.sh` | Orchestration of M1-M7: identity checks (M2-M5), prohibited-key scan (M7) over the ordered stream, delegation to the item validator (M6), the `manifest_mode` / `manifest_max_concurrency` accessors | ~300 |
| `parallel-items-validate.sh` | `validate_items` / `validate_item_record` / merge-status consistency / `validate_blast_radius_block` ports | ~300 |
| `parallel-cohorts.sh` | Key/edge validation, adjacency + degree accounting, Welsh-Powell ordering (`sort -k1,1nr -k2,2n`), greedy assignment, output shaping, `compute_concurrency_batches` | ~350 |
| `compute-cohorts.sh` | Thin CLI entry: argument parsing, sources `parallel-cohorts.sh`, JSON emission | ~80 |
| `compute-concurrency-batches.sh` | Thin CLI entry for batching (or fold into `compute-cohorts.sh` as a subcommand to save a file) | ~60 |
| `validate-parallel-manifest.sh` | Thin CLI entry: reads the manifest file, sources the validator chain, prints errors one per line, exits 0/1; `--print-mode` / `--print-max-concurrency` subcommands | ~90 |

Tests under `tests/shell/` (per `shell.md:85-88`, mirroring `scripts/bash/` layout conventions): `parallel_common.bats`, `parallel_yaml_subset.bats`, `parallel_manifest_validate.bats`, `parallel_items_validate.bats`, `parallel_cohorts.bats`, plus the two parity suites from Q3. Fixtures under `tests/fixtures/` (checked in; no temp files).

---

## Recommended Implementation Approach (summary)

1. **F-A: bash library.** Implement the eight files above under `.claude/lib/bash/`, extend the shell-QC discovery roots and kcov include pattern (`shell_qc_lib.sh:84, 323`) plus `shell.md` prose, and mirror the files into `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/`.
2. **F-B: parity corpora.** Commit `tests/fixtures/parallel_cohorts/` and `tests/fixtures/parallel_manifest_bash/`; add the pytest and bats suites with fixture-count floors and explicit verified-scope headers recording the two bash divergence classes (M1 PyYAML text; non-printable repr escapes).
3. **F-C: push-down config carriage.** Bundle `resources/claude-customizations/config/{orchestration-routing.json, blast-radius.json (generic)}`; extend `ROOT_FOLDERS` to `[".claude", "config"]` in the Claude entry only; add the destination-aware merge decorator for `config/orchestration-routing.json` with the merge rule in Q4; Jest coverage for copy, merge, existing-`parallel`-route overwrite, local-route preservation, idempotency, and unchanged Copilot/Codex published sets.
4. **F-D: manifests and completeness test.** `core.json` additions (Q6); extend `claude-pack-manifest-completeness.test.ts` enumeration to `rules/*.md`, `lib/**`, and the `config/` tree; add the bash-library manifest-membership test following the `BlastRadius.Manifest.Tests.ps1` pattern.
5. **F-E: wiring.** Repoint the destination-runtime references per the Q7 table; add the bash allowlist entries to `parallel-planner.md`, `parallel-orchestrator.md`, and `.claude/settings.json`; record the two residual destination gaps (drift-detection CLI, mutation-abandon CLI) in the spec as out of scope.
6. **Verification:** local Jest/pytest lanes as normal; shell lane exclusively via CI dispatch per Q8 with evidence under `evidence/qa-gates/`.

## Rejected Alternatives (brief)

- `yq` (or any external YAML tool) for manifest parsing — reintroduces destination provisioning; version-fragmented semantics (Q2b).
- Node-based manifest validation / new MCP `artifact_type` — violates the F3 boundary and the no-schema-change constraint (Q2c).
- Implementing the merge inside the shared engine or `rewriteReferences` — the rewrite seam has no destination access; engine changes would put Copilot/Codex behavior at risk (Q4).
- Canonical bash sources under `scripts/bash/` with `.claude/lib/bash/` as a mirror — third copy, contradicts the `.claude/lib` precedent (Q8ii).
- Porting the cohort computation to PowerShell instead of bash — explicitly settled by the user; not re-litigated.

## Risk Register

| # | Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- | --- |
| R1 | Byte-parity failure on `pythonRepr` edge cases (quote selection, escapes) | Medium | Parity suite red | Implement the real quote-selection rule; restrict corpus to printable strings; record the escape subset as a divergence class in the suite headers and (if amended) the rules file |
| R2 | M1 PyYAML exception text unreproducible | Certain | Full byte parity impossible for that one case | Scoped parity (prefix + single-element shape) for the parse-failure case, following the TS verified-scope precedent |
| R3 | `parallel-yaml-subset.sh` exceeds 500 lines | Medium | Policy violation | Pre-planned split into scanner and emitter files |
| R4 | Editing `shell_qc_lib.sh` discovery roots regresses existing discovery/coverage | Low | Shell lane red repo-wide | Additive root only; extend the existing shell-qc bats tests; CI dispatch validates before merge |
| R5 | `ROOT_FOLDERS` change leaks into Copilot/Codex publishes | Low | Wrong published sets in other surfaces | The constant is Claude-entry-local (verified); add explicit Jest non-regression cases for both other entry points |
| R6 | Merge decorator clobbers destination-local routing content | Low-Medium | Destination breakage | Merge rule preserves all non-source-owned keys; unparseable destination fails fast; idempotency test |
| R7 | Generic blast-radius default under-detects module/shared-surface contention at destinations | Medium | Fewer conflict edges from those two reasons | Path-overlap remains fully derived from plans (fail-closed); document destination enrichment of `config/blast-radius.json` |
| R8 | CI-only shell verification lengthens iteration | High | Schedule, not correctness | Batch shell changes per dispatch; keep bats runnable in one lane; draft-PR trigger as fallback dispatch path |
| R9 | Bash associative-array iteration order leaks into output | Medium | Nondeterminism, parity flake | Coding rule: no associative-array iteration into output; explicit `sort -n`; `LC_ALL=C`; parity fixtures with permuted-equivalent inputs |
| R10 | Bundle/repo `.claude/lib/bash` drift | Medium | Destination receives stale library | Manifest-membership test with bundled-counterpart assertion (Q6), per the `.psm1` precedent |
| R11 | Pack manifests reject non-`.claude` paths in some untested code path | Low | `config/` dropped under `--packs` | Verified no prefix check exists in `claude-pack-selection.ts`; add a targeted Jest case as proof |

## Automation Feasibility

Assessed per the autonomous-execution mandate in `.claude/skills/orchestrate/SKILL.md`.

- **Shell toolchain execution (Q8).** No delegate in this environment can run shfmt/shellcheck/bats/kcov locally (win32 host; `.claude/rules/shell.md:39-42`; prior verified project memory for issues #393/#394). This does **not** require human interaction: the full verification loop — push branch, `gh workflow run _shell-coverage.yml --ref <branch>` (the workflow declares `workflow_dispatch`, `_shell-coverage.yml:5`), `gh run watch`, artifact download, evidence capture — is executable end-to-end by an agent with the existing `Bash(git *)` / `Bash(gh *)` grants. Fallback dispatch (draft PR triggering `ci.yml`) is likewise automatable. **Recommended response: none required (fully automatable).** If a downstream gate demands *local* seven-stage toolchain evidence for the shell files specifically, that demand is structurally unsatisfiable in this environment; the permitted response would be `exception` with a runbook documenting CI dispatch as the equivalent verification, citing the #393/#394 precedent — not `halt`, because an equivalent automated verification exists, and not `scope_change`, because the bash requirement is a fixed user decision.
- **Destination end-to-end check** (issue.md test condition: "a payload-only workspace clears all four reported blockers"). Automatable: run the push-down into a scratch workspace via the existing service-call path under Jest (in-memory FS) for the payload-content assertions, and a bats case on ubuntu-latest invoking the published bash entry points from a directory containing only the payload for the no-Python assertion. No human interaction required.
- **CI evidence for workflow-adjacent edits.** If `_shell-coverage.yml` or `shell_qc_lib.sh` are modified, the `modified-workflow-needs-green-run` policy (`.claude/rules/benchmark-baselines.md` Enforcement section; feature-review-workflow skill) requires a green run against the branch head — obtainable by the same automated dispatch. Automatable.
- **No step of this feature requires operator judgment, credentials not already held, or physical action.** No `human_interaction` requirement needs to be recorded in the orchestrator-state checkpoint for this feature as scoped.

## Cited Files (all read during this research)

- `scripts/dev_tools/parallel_cohort_computation.py` (full, 468 lines)
- `scripts/dev_tools/parallel_manifest_contract.py` (full, 312 lines)
- `scripts/dev_tools/_parallel_state_common.py` (full, 495 lines)
- `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (full)
- `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` (full)
- `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` (full)
- `extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts` (full)
- `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` (full)
- `extensions/drm-copilot/src/repo-automation-service-push-down.ts` (full)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (full)
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (full)
- `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts` (lines 1-100)
- `tests/scripts/dev_tools/test_blast_radius_parity.py` (lines 1-120)
- `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` (full)
- `config/blast-radius.json`, `config/orchestration-routing.json` (full)
- `.claude/skills/parallel-plan/SKILL.md` (full), `.claude/agents/parallel-planner.md` (full), `.claude/agents/parallel-orchestrator.md` (grep-targeted lines)
- `.claude/rules/shell.md` (full), `scripts/bash/shell_qc_lib.sh` (grep-targeted lines 75-84, 160-204, 322-323)
- `.github/workflows/_shell-coverage.yml` (full), `.github/workflows/ci.yml` (lines 1-33)
- `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/issue.md` (full)
