# Research — Remove Remaining Python Invocations from the `.claude/**` Payload (Issue #599)

- **Issue:** #599
- **Epic:** `docs/features/epics/claude-runtime-portability/epic.md` (Feature D, wave 2, complexity C3)
- **Branch under study:** `drm-copilot-wt-2026-08-29T15-07`, worktree
  `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3f62591bf10aebf3`
- **Date:** 2026-08-29
- **Scope of verification:** every file:line citation below was re-derived against this worktree in
  this research pass. Citations carried in the delegation prompt, the epic manifest, and
  `issue.md` that disagree with the tree are corrected in the "Citation Corrections" section.

---

## Citation Corrections

| Source of the citation | Claim | Verified state |
| --- | --- | --- |
| Epic manifest line 178 | lane-assertion invocation at `parallel-plan/SKILL.md:317` | **Wrong.** The invocation literal is at line **315**. Lines 313-315 carry the mandatory-step sentence; 316 opens the following prose. |
| Delegation prompt | `parallel-plan/SKILL.md:315` | **Correct.** |
| Epic manifest line 155 / Feature C scope | `Import-Module` at `parallel-plan/SKILL.md:185` | **Wrong.** The literal is at line **183** (fence at 182/184). |
| Epic manifest line 154 / Feature C scope | `Import-Module` at `parallel-add/SKILL.md:64` | **Wrong.** The `Import-Module` literal is inline in prose at `parallel-add/SKILL.md:62`. |
| Epic manifest line 155 / Feature C scope | `Import-Module` at `parallel-planner.md:151` | **Correct.** |
| Epic manifest line 182 | advisory prose at `parallel-plan/SKILL.md:324-331` | **Wrong.** The advisory-only paragraph is at lines **322-329**. |
| Issue / prompt | advisory prose at `parallel-plan/SKILL.md:322-329` | **Correct.** |
| Issue / prompt | required completion-report line item at `parallel-plan/SKILL.md:571` | **Imprecise.** The line item spans **569-573**; line 569 opens it ("The lane-assertion diagnostic's result: …"). Line 571 is the middle of the sentence. |
| Issue / prompt | `validate-discovery-artifact-gate.ps1:50-52` | **Imprecise.** The rationale sentence spans **50-53**. |
| Prompt | `enforce-discovery-artifact-gate.ps1:49-52` | **Correct.** |
| Prompt | `.claude/agents/parallel-orchestrator.md:92-96` retains the grants | **Correct.** |
| Prompt / issue | `.claude/hooks/enforce-parallel-abandon-gate.ps1:29` matches the abandon invocation's tokens | **Imprecise.** Line 29 is a `.NOTES` comment naming the producer-side module. The token declarations the gate actually matches on begin at line **38** ("These are the ONLY places either token literal appears in this file"). The substance of the non-goal is unchanged. |
| Epic manifest line 169 | "exactly four executable Python invocation sites under `.claude/**`" | **Wrong.** There are **five**; `issue.md` already corrects this. See `## Numeric Derivation Evidence`. |

---

## 1. Complete Behavioral Contract of `scripts/dev_tools/parallel_lane_assertion.py`

File length verified at **499** lines (`Grep` line count over the file). The module is the port's
byte-for-byte reference.

### 1.1 Module posture (lines 1-39, 34-38)

The module docstring states the contract the port must inherit: it is a DIAGNOSTIC; it never
overrides a derived edge, never feeds `compute_cohorts`, never influences scheduling, is imported by
no cohort-computation/validation/mutation module, and writes no artifact. Every function except
`main` is pure. `main` is the single I/O boundary.

### 1.2 Report-class tokens (lines 57-64)

```
EXPECTED_TOGETHER_DERIVED_APART = "expected_together_derived_apart"   # line 57
EXPECTED_APART_DERIVED_TOGETHER = "expected_apart_derived_together"   # line 58
MEMBER_NAMES_NO_ITEM            = "member_names_no_item"              # line 59
ITEM_COVERED_BY_NO_COMPONENT    = "item_covered_by_no_component"      # line 60
INFORMATIONAL_KINDS = frozenset({ITEM_COVERED_BY_NO_COMPONENT})       # line 64
EDGE_SEPARATOR = ":"                                                   # line 68
```

`INFORMATIONAL_KINDS` holds exactly one member, so `disagreement_count` (line 140) counts findings
of the first three classes only.

### 1.3 CLI surface (`build_parser`, lines 436-457)

- `prog="parallel_lane_assertion"` (line 440).
- Description text (lines 441-445): "Compare a parallel manifest's expected_conflict_components
  assertion against the derived conflict components. Advisory only: always exits 0 and never
  influences scheduling."
- `--manifest` — **required**, help "Path to docs/features/parallel/<slug>/parallel.md" (lines
  447-451).
- `--edges` — optional, `default=""`, help `Derived conflict edges as "<a>:<b> <c>:<d>"; empty means
  no edges.` (lines 452-456).
- There is **no `--keys` argument**. The delegation prompt's question 1 asks how `--keys` is parsed;
  the answer is that the module has no such flag. Item keys are read from the manifest's
  `items[].issue_num`, not supplied on the command line. This is the single largest surface
  difference from `compute-cohorts.sh`, which does take `--keys`.
- `argparse` supplies `-h/--help` and exits **2** on a malformed command line (documented at lines
  471-474).

### 1.4 `--edges` parsing (`parse_edges`, lines 410-433)

`edge_text.split()` on arbitrary whitespace; for each token, `token.partition(":")` takes the
**first** colon. A token with no colon is dropped (lines 427-428). `int(first)`/`int(second)` inside
a `try`; `ValueError` drops the token (lines 429-432). Edges are returned in input order.

**Parity hazard.** Python `int()` accepts forms the strict lexis in `compute-cohorts.sh:59`
(`^-?(0|[1-9][0-9]*)$`) rejects: leading zeros (`007` → 7), a leading `+` (`+5` → 5), underscore
separators (`1_0` → 10), surrounding whitespace, and non-ASCII decimal digits. A three-part token
`1:2:3` partitions to `("1", "2:3")` and is dropped by the `ValueError` path. The port must either
reproduce these acceptances or declare them as an excluded corpus class, exactly as
`tests/shell/parallel_cohorts_parity.bats:25-29` already does for leading-zero tokens.

### 1.5 Reading the manifest (`read_manifest_inputs`, lines 355-407)

Input is an already-parsed frontmatter mapping. Reads are defensive; a malformed entry is **skipped,
never raised** (lines 361-365).

`expected_conflict_components` (lines 376-395):
1. `mapping.get("expected_conflict_components")`; proceed only if it `isinstance(..., list)`. An
   absent key or a non-list value yields an empty component list with no error.
2. Per entry: skip if not a `dict` (lines 379-380).
3. `fields.get("members")`; skip the whole entry if not a `list` (lines 382-384).
4. `name = fields.get("name")`; kept only if `isinstance(name, str)`, otherwise `None` (lines
   385, 388). An empty string `""` is a `str` and is therefore kept as the name — the label then
   renders as `''`.
5. `members` = the members that satisfy `_is_positive_int` (lines 71-78: `isinstance(int)` **and not**
   `isinstance(bool)` **and** `> 0`), in manifest order, **not de-duplicated**.
6. An entry whose members all fail the filter is still appended, with an empty `members` tuple.

`items[].issue_num` (lines 397-406): `mapping.get("items")` must be a `list`; each entry must be a
`dict`; `issue_num` is added to a `set` when `_is_positive_int`. Returned **sorted ascending** and
de-duplicated by the set.

Return: `(components_in_manifest_order, sorted_unique_item_keys)`.

### 1.6 Component derivation (`derive_components`, lines 143-195)

- Adjacency seeded from every declared key so an isolated vertex survives (line 169).
- An edge is skipped when `first == second`, or either endpoint is not a declared key (line 171).
  No error is raised.
- Symmetric set-valued adjacency collapses direction and duplicates (lines 173-174).
- BFS from each unvisited root in `sorted(adjacency)` ascending (line 180); the visited set is
  marked at enqueue time.
- Each component is `tuple(sorted(member_set))` (line 193); components are returned
  `sorted(..., key=lambda members: members[0])` (line 195).
- Empty input returns an empty tuple. The result partitions the declared keys exactly.

### 1.7 Comparison (`compare`, lines 268-326)

Two flat index maps are built:
- `derived_index`: `key -> derived component index` (lines 289-293).
- `expected_index`: `key -> expected component position` (lines 294-298). Built by dict
  comprehension in manifest order, so if a key appears in two asserted components the **last**
  occurrence wins. The port must reproduce that, not report an error.

Findings are appended in this fixed order:
1. `_find_split_lanes` (lines 198-230) — per expected component, in manifest order.
2. `_find_merged_lanes` (lines 233-265) — per derived component, in derived order.
3. `MEMBER_NAMES_NO_ITEM` (lines 305-312) — `sorted(k for k in expected_index if k not in
   derived_index)`.
4. `ITEM_COVERED_BY_NO_COMPONENT` (lines 315-322) — `sorted(k for k in derived_index if k not in
   expected_index)`.

`_find_split_lanes` detail (lines 215-229): `resolved = [key for key in component.members if key in
derived_index]` (preserves manifest order and duplicates); `landed = {derived_index[key] for key in
resolved}`; emit only when `len(landed) > 1`; `members=tuple(sorted(resolved))`.

`_find_merged_lanes` detail (lines 251-264): `covered = [key for key in members if key in
expected_index]`; `lanes = {expected_index[key] for key in covered}`; emit only when `len(lanes) > 1`;
`members=tuple(sorted(covered))`.

### 1.8 Exact output text (`format_report`, lines 329-352)

Header (lines 341-344), a single line after f-string concatenation:

```
Lane assertion: {N} derived conflict component(s); {D} disagreement(s).
```

where `N = len(report.derived_components)` and `D = report.disagreement_count`.

One line per finding, in the order produced by `compare` (lines 345-347):

```
ADVISORY [{kind}] {detail}.
```

Note the trailing period is added by the formatter; the `detail` strings themselves carry none.

Closing line (lines 348-351), one line after concatenation:

```
Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.
```

Lines are joined with `"\n"` (line 352) and emitted through `print` (line 494), which appends one
trailing newline.

The four `detail` templates, verbatim:

| Class | Template (source lines) |
| --- | --- |
| `expected_together_derived_apart` | `expected component {label} was derived apart: its members occupy {len(landed)} distinct conflict components` (222-226) |
| `expected_apart_derived_together` | `derived conflict component {list(members)} spans {len(lanes)} expected components that were asserted apart` (258-261) |
| `member_names_no_item` | `expected member {key} names no manifest item` (308) |
| `item_covered_by_no_component` | `manifest item {key} is covered by no expected component` (318) |

`label` is `ExpectedComponent.label(position)` (lines 100-103): `f"'{self.name}'"` when `name is not
None`, otherwise `f"component[{position}]"`, with `position` the zero-based manifest index.

`{list(members)}` renders the Python list repr of a tuple of ints: `[101, 102]` — square brackets,
comma **and space** separator, no trailing comma; `[101]` for a single member. A derived component
is never empty, so `[]` cannot occur here.

### 1.9 Behavior when `expected_conflict_components` is absent

`read_manifest_inputs` returns an empty component list. `expected_index` is empty. No split, merged,
or unknown-member finding is possible. Every declared key falls into
`ITEM_COVERED_BY_NO_COMPONENT`, one finding each, ascending. `disagreement_count` is 0. The header
therefore reads `Lane assertion: {N} derived conflict component(s); 0 disagreement(s).` followed by
N informational lines and the closing line. This matches
`.claude/skills/parallel-plan/SKILL.md:326-327` and the operator note in the only real manifest that
mentions the key at all (`docs/features/parallel/verification-integrity/parallel.md:473-475`).

### 1.10 Every exit path

| Path | Source | Exit code | Output |
| --- | --- | --- | --- |
| Malformed command line (unknown flag, missing `--manifest`) | `argparse` (lines 471-474) | **2** | argparse usage text on stderr |
| `--help` | `argparse` | 0 | usage text on stdout |
| Manifest unreadable (`OSError`) | lines 481-485 | **0** | `Lane assertion: manifest unreadable ({exc}); no comparison made.` |
| Frontmatter does not parse to a mapping | lines 487-490 | **0** | `Lane assertion: manifest unparseable ({parse_errors[0]}).` |
| Normal path, no findings | lines 492-495 | **0** | header + closing line |
| Normal path, with findings | lines 492-495 | **0** | header + N `ADVISORY` lines + closing line |

`parse_errors[0]` comes from `parse_manifest_frontmatter`
(`scripts/dev_tools/parallel_manifest_contract.py:143-179`) and is exactly one of four M1 strings:
the missing-opening-fence message, the unterminated-block message, `Parallel manifest frontmatter is
not valid YAML: {exc}.` (line 175), or `Parallel manifest frontmatter must be a mapping.` (line 178).

The module's only import from the repository is
`from scripts.dev_tools.parallel_manifest_contract import parse_manifest_frontmatter` (line 50).

---

## 2. Target Runtime — Recommendation: **bash only**

### 2.1 What the surrounding procedure steps actually use

`.claude/skills/parallel-plan/SKILL.md`, `### Seeding procedure`:

- Step 1 (lines 304-312) uses PowerShell `Test-BlastRadiusConflict` to derive the edge set.
- Step 2 (lines 313-329) is the lane-assertion diagnostic — the site under repair.
- Step 6 (lines 333-338) uses `bash .claude/lib/bash/compute-concurrency-batches.sh`.
- The step that consumes the edges, step 1's own invocation of `compute-cohorts.sh`, is bash
  (`SKILL.md:275`).

So the diagnostic sits between a PowerShell producer and a bash consumer. Both runtimes are already
in the procedure; neither is "the" runtime by position.

### 2.2 What already exists under `.claude/lib/`

Verified inventory (36 files, `Glob .claude/lib/**/*`):

- **bash** — 9 files, 2,185 lines total: `compute-cohorts.sh` (143), `compute-concurrency-batches.sh`
  (122), `parallel-cohorts.sh` (330), `parallel-common.sh` (238), `parallel-items-validate.sh` (244),
  `parallel-manifest-validate.sh` (299), `parallel-yaml-emit.sh` (340), `parallel-yaml-scan.sh` (335),
  `validate-parallel-manifest.sh` (134). Three are CLI entry points; six are sourceable libraries.
- **PowerShell** — 27 `.psm1` files across eight subdirectories (`blast-radius`, `codex-routing`,
  `discovery-validation`, `hook-payload`, `mermaid`, `model-routing`, `orchestrator-state`).

Every artifact the diagnostic needs already exists on the bash side and nowhere on the PowerShell
side: a manifest YAML reader (`parallel-yaml-scan.sh` + `parallel-yaml-emit.sh`), the four M1
messages (`parallel-manifest-validate.sh:72-95`), a declared-`issue_num` reader
(`parallel-manifest-validate.sh:pm_declared_issue_nums`, lines ~143-157), and the exact
`expected_conflict_components` node-path accessors (`parallel-manifest-validate.sh:203-237`,
`pm_validate_component_members` at 159-201). No `.claude/lib/**` PowerShell module parses YAML at
all.

### 2.3 What the agent tool allowlists permit

`.claude/agents/parallel-planner.md:5-20` — `tools:` list, verified:

```
Agent(orchestrator), Read, Grep, Glob,
Write/Edit(docs/features/parallel/**), Write/Edit(artifacts/orchestration/**),
Bash(git *), Bash(gh *), Bash(poetry run *),
Bash(bash .claude/lib/bash/compute-cohorts.sh*),
Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*),
Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*),
mcp__drm-copilot__validate_orchestration_artifacts
```

Two consequences:

1. **There is no `Bash(pwsh *)` grant on the planner persona.** Project settings allow
   `Bash(pwsh *)` at `.claude/settings.json:7`, but the persona's `tools:` list is the narrower
   allowlist. A PowerShell port would need a new grant added to `parallel-planner.md`; a bash port
   needs one new entry-point-scoped grant of the same shape as the three that already exist. Both
   are one line, but the bash form matches the pattern the persona documents at lines 158-163
   ("three entry-point-specific allowlist entries … one per command-line entry point. The six
   sourceable libraries carry no grant because they are never invoked directly").
2. **A live inconsistency exists today.** `parallel-plan/SKILL.md:316` says the lane-assertion call
   is "covered by the planner's existing `Bash(poetry run *)` grant", while
   `parallel-planner.md:185-186` says that grant "is not required by any step above". Both statements
   are in the payload; they contradict. Removing the invocation resolves the contradiction in the
   correct direction.

### 2.4 Cost of each option

| Option | Cost | Assessment |
| --- | --- | --- |
| **bash only (recommended)** | 2 new `.sh` files + 2 bundle mirrors + 1 `core.json` entry pair + 1 planner grant + bats parity suite + Python-lane parity suite + shared JSON corpus. Reuses the YAML parser, the four M1 messages, the declared-key reader, and the `LC_ALL=C` determinism discipline. Held to `.claude/rules/shell.md` format/lint/test/coverage, which already measures `.claude/lib/bash/` (see §7). | Lowest net-new surface. Every dependency already exists. Directly mirrors the `compute-cohorts.sh` / `validate-parallel-manifest.sh` precedent the issue's Proposed Behavior names. |
| **PowerShell only** | A net-new YAML subset parser in PowerShell (there is none under `.claude/lib/**`), or an unbounded dependency on `ConvertFrom-Yaml`, which is not available on a bare destination. Plus a new `Bash(pwsh *)` grant on the planner, a new `CodeCoverage.Path` entry in **two** runsettings copies, and exposure to the MCP-PoshQC coverage gotcha in §7.3. Also creates a second edit region in `.claude/agents/parallel-planner.md`, which is a Feature C file (line 151). | Highest cost, and it would duplicate a parser the bash lane already owns. Reject. |
| **Both runtimes** | The union of the two above, plus a third parity axis (bash↔PowerShell) with no consumer. | No caller needs a PowerShell entry point. Reject. |

**Recommendation: bash only.** Ship two files under `.claude/lib/bash/`:

- `.claude/lib/bash/parallel-lane-assertion.sh` — sourceable library, function prefix `pla_`
  (matching the `pc_`/`pcoh_`/`pm_`/`pi_`/`yp_` convention), holding component derivation,
  comparison, and report formatting.
- `.claude/lib/bash/report-lane-assertion.sh` — CLI entry point, function prefix `rla_` (matching
  `cc_` and `vm_`), holding argument parsing, the manifest read, and the print. The name uses
  "report" rather than "assert" deliberately: "assert" would imply a blocking verdict, which the
  advisory-only contract forbids.

The library sources `parallel-manifest-validate.sh` and calls `pm_parse_manifest`, reading
`PC_ERRORS[0]` for the unparseable-manifest message. That reuses all four M1 strings byte-for-byte
rather than restating them, and the dependency direction (diagnostic → manifest contract) is exactly
the Python reference's direction at `parallel_lane_assertion.py:50`. Nothing in the cohort,
validation, or mutation path gains a dependency on the diagnostic, which preserves the AC30 property
recorded in §9.

**External-utility budget.** `tests/shell/parallel_payload_only.bats:14-18, 41-42` runs the payload
under `PATH` set to a single shim directory containing exactly four binaries —
`tests/fixtures/parallel_payload_path/{cat,cut,dirname,sort}` (verified by `Glob`). The port may use
only those four plus bash builtins, or the checked-in shim set must be extended. Sorting integers via
`sort -n` and reading the manifest via `cat` stay inside the budget; nothing in the diagnostic needs
more.

---

## 3. The YAML-Subset Constraint — Already Satisfied

### 3.1 What `.claude/lib/bash/parallel-yaml-scan.sh` accepts and rejects

Accepted subset, per the module header at lines 15-24 and enforced by `yp_classify_scalar`
(lines 170-267):

- Block mappings `key: value` and `key:` followed by an indented block.
- Block sequences `- scalar`, `- key: value` (compact mapping), and `-` followed by an indented block.
- Two-space indentation steps, spaces only.
- **Empty** flow collections `[]` and `{}` (line 215).
- Scalars: null (`~`, `null`, `Null`, `NULL`, empty) (lines 225-229); YAML 1.1 booleans
  `true/True/TRUE/yes/Yes/YES/on/On/ON` and their negatives (lines 230-239); decimal integers
  matching `^[-+]?(0|[1-9][0-9]*)$` (line 246, `+` stripped at 248); single- and double-quoted
  strings without escape sequences (lines 183-207); plain strings (lines 264-266).
- Full-line `#` comments and blank lines.

Rejected fail-closed as `out_of_subset` (header lines 26-31): **non-empty flow collections**
(lines 216-219), anchors/aliases/tags/block scalars and the other leading indicators (lines 210-214),
special floats (lines 240-243), numeric-looking tokens that are not clean decimal integers —
underscore-separated, `0x`/`0o`/`0b`, floats, exponent notation, and `YYYY-MM-DD` timestamps
(lines 255-262), escape sequences inside double-quoted scalars (lines 190-193), trailing comments,
and multi-document streams.

Reported as `yaml_error` (header lines 33-37): unterminated quotes (lines 184-187, 199-202), tab
indentation, misaligned indentation, and lines that are neither a mapping nor a sequence entry.

### 3.2 Can `expected_conflict_components` be read by it? **Yes, already.**

The constraint stated in `issue.md:126-127` and the delegation prompt is **already discharged**. The
bash lane does not merely tolerate the key — it fully validates it today:

- `.claude/lib/bash/parallel-manifest-validate.sh:203-237` (`pm_validate_expected_components`) reads
  `expected_conflict_components`, its per-entry `.name`, and its `.members` list through the node
  table, using paths of the form `expected_conflict_components[0].members[1]`.
- `.claude/lib/bash/parallel-manifest-validate.sh:159-201` (`pm_validate_component_members`) walks
  the members with `yp_type_of`/`yp_value_of` and enforces the M8 rules.
- The header at line 13 names "the key-gated M8 `expected_conflict_components` assertion" as a first-
  class validation section.

The only shape that is out of subset is the **flow-style** form, and it is already prohibited by
prose in two places, both of which cite the parser by name:

- `.claude/rules/parallel-orchestration.md:132` — "The value must be authored as a YAML BLOCK
  sequence. The destination-runtime bash YAML subset parser
  (`.claude/lib/bash/parallel-yaml-scan.sh`) rejects a non-empty flow collection, so a flow-style
  value such as `members: [101, 102]` is outside the supported subset and is not accepted on the bash
  path."
- `.claude/skills/parallel-plan/SKILL.md:374-375` — "A flow-style value (`members: [101, 102]`) is
  outside the bash YAML subset and must not be authored."

The canonical block-sequence example is at `.claude/rules/parallel-orchestration.md:138-144`:

```yaml
expected_conflict_components:
  - name: hooks-lane          # optional, diagnostic label only
    members:                  # required, non-empty, positive ints
      - 101
      - 102
```

### 3.3 Real instances in `docs/features/parallel/**`

There is exactly **one** manifest under `docs/features/parallel/`
(`docs/features/parallel/verification-integrity/parallel.md`) and it carries **no**
`expected_conflict_components` block. Its only mention is the operator note at lines 473-475:

> `expected_conflict_components` is deliberately absent. The operator authored no lane assertion for
> this run, so the advisory lane diagnostic reports every item as uncovered, which is its expected
> output in that case.

The authored instances that do exist are the thirteen M8 corpus fixtures under
`tests/fixtures/parallel_manifest_bash/manifest_m8_*.json`. The positive one,
`manifest_m8_valid_named_component.json:4`, embeds the block form verbatim:

```
expected_conflict_components:\n  - name: hooks-lane\n    members:\n      - 101\n      - 102\n
```

**Conclusion:** nothing has to change inside or outside this feature's scope to make
`expected_conflict_components` readable on the destination runtime. The port consumes the existing
node table. The `issue.md` constraint bullet should be restated in `spec.md` as "already satisfied —
the block form is inside the subset and is already parsed and validated by the bash lane" rather than
as an open risk.

---

## 4. The Parity Precedent

### 4.1 Shared-corpus location and format

Two corpora, each a directory of checked-in JSON records read by **both** a bats suite and a pytest
suite:

| Corpus | Bash lane | Python lane | Floor |
| --- | --- | --- | --- |
| `tests/fixtures/parallel_cohorts/*.json` | `tests/shell/parallel_cohorts_parity.bats` | `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` | 20 (`parallel_cohorts_parity.bats:46`) |
| `tests/fixtures/parallel_manifest_bash/*.json` | `tests/shell/parallel_manifest_parity.bats` | `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` | 24 (`parallel_manifest_parity.bats:44`; `test_parallel_manifest_bash_parity.py:67`) |

Manifest-fixture record shape (documented at `test_parallel_manifest_bash_parity.py:13-19`): `name`,
`notes`, `manifest_text` (raw document, LF/CRLF/CR), `expected_errors` (full list in emission order),
plus optional `expected_mode` / `expected_max_concurrency`. A declared-divergence fixture carries
`divergence: "M1_YAML_PARSE"` and `expected_error_prefix` instead of `expected_errors`.

Cohort-fixture record shape (from `parallel_cohorts_parity.bats:72-84`): an `input` object holding
either `item_keys` + `conflict_edges` or `cohort_item_keys` + `max_concurrency`, plus one of
`expected_cohorts`, `expected_batches`, or `expected_error`.

### 4.2 How each suite invokes the two implementations

- **bats, cohorts** (`parallel_cohorts_parity.bats:68-101`): runs the entry point as a subprocess
  (`run bash "$COHORTS" --keys "$keys" --edges "$edges"`) and compares `$status` and `$output`
  against the fixture's expected block.
- **bats, manifest** (`parallel_manifest_parity.bats:40, 65-113`): **sources**
  `parallel-manifest-validate.sh` and calls `pm_validate_text` in-process, then compares
  `pc_errors_print` output. It refuses (`rc == 2`) as a failure, so no corpus fixture may be out of
  subset.
- **pytest, both** (`test_parallel_manifest_bash_parity.py:37-39, 184-213`): imports the reference
  module and asserts against the same fixture files. It starts **no** external process and invokes
  no bash — "parity is asserted against a shared artifact rather than by cross-process execution."

Both bats suites read fixture JSON through a `fixture_field()` helper that shells out to `python3`
with a one-line expression (`parallel_cohorts_parity.bats:52-56`,
`parallel_manifest_parity.bats:49-53`), and each has a dedicated case asserting `python3` is
available so the suite can never pass vacuously (`:63-66` and `:60-63` respectively).

### 4.3 The CI-versus-destination distinction — confirmed

The parity suites **do** require a Python interpreter, and that is explicitly declared, not
accidental. Both headers state it in identical words
(`parallel_cohorts_parity.bats:31-36`, `parallel_manifest_parity.bats:28-33`):

> "python3 is used only to read a checked-in JSON fixture; it is a harness dependency of this suite,
> not of the code under test. The destination-portability property — that the entry points need no
> Python — is asserted separately by `tests/shell/parallel_payload_only.bats`, which removes python
> from PATH."

`tests/shell/parallel_payload_only.bats` is the suite that proves destination portability: it invokes
the entry points from the **bundle root** with `env -i PATH=<four-shim directory>` and asserts
`command -v python`, `python3`, and `poetry` all fail (lines 58-65). Per `.claude/rules/shell.md:40`,
the whole shell toolchain runs on `ubuntu-latest` in CI, not on a destination runtime. The
distinction is therefore: **parity suites run in CI with Python present; the payload-only suite
proves the shipped code needs no Python.** Feature D must add to both.

### 4.4 What a Feature D parity suite must look like

To match the precedent exactly, five artifacts:

1. **`tests/fixtures/parallel_lane_assertion/*.json`** — new shared corpus. Record shape:
   `name`, `notes`, `manifest_text`, `edges` (the raw `--edges` string), `expected_stdout` (the full
   report as a single string with `\n` separators, no trailing newline), `expected_status` (always
   0), and an optional `divergence` marker. Declare a floor constant in both lanes.
2. **`tests/shell/parallel_lane_assertion_parity.bats`** — bash lane. Given the port has a CLI entry
   point *and* a sourceable library, either invocation style in §4.2 is precedented; the subprocess
   style (`run bash "$REPORT" --manifest ... --edges ...`) is preferable because it also pins the
   exit code, which is an acceptance criterion here.
3. **`tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`** — Python lane over the
   same corpus, calling `main()`/`format_report(compare(...))` and asserting against the same
   `expected_stdout`. No bash invoked.
4. **`tests/shell/parallel_lane_assertion.bats`** — bash-only unit coverage of the library functions
   (the analogue of `tests/shell/parallel_cohorts.bats` and `parallel_manifest_validate.bats`), which
   is where the coverage percentage is actually earned.
5. **New cases in `tests/shell/parallel_payload_only.bats`** — the port invoked from the bundle root
   with no interpreter on `PATH`, asserting exit 0 and the expected report.

**Declared divergence classes to record in all lane headers**, following the existing two-class
precedent:

- **Class 1 (inherited).** The M1 YAML-parse-failure message. The bash `YP_DETAIL` text is not
  PyYAML's exception text. Any corpus fixture exercising `Lane assertion: manifest unparseable (...)`
  through the YAML-error branch must pin the prefix only.
- **Class 2 (inherited).** Non-printable string-repr escapes — no corpus fixture may contain a
  control character other than `\n`, `\r`, `\t`.
- **Class 3 (new).** The `--edges` integer lexis. Python `int()` accepts `007`, `+5`, `1_0`, and
  non-ASCII digits (§1.4). Either the port reproduces those acceptances or the corpus excludes them
  and a bash-only suite asserts the refusal directly, as
  `parallel_cohorts_parity.bats:25-29` already does for the cohort entry points.
- **Class 4 (new).** The manifest-unreadable message. Python emits the `OSError` string, e.g.
  `[Errno 2] No such file or directory: 'x'`, which bash cannot reproduce. Pin the prefix
  `Lane assertion: manifest unreadable (` only, or exclude the class from the shared corpus and cover
  it bash-side.
- **Class 5 (new).** Out-of-subset manifests. `pm_parse_manifest` returns status 2 for constructs the
  Python authority parses successfully. There is no Python counterpart. Recommended behavior: print a
  distinct refusal line and **exit 0**, preserving the never-blocks contract, and assert it bash-side
  only.

---

## 5. The Push-Down Bundle Mirror

### 5.1 The exclusion set and comparison mechanism — confirmed

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
spans lines **101-126** (the delegation prompt's citation is correct).

- Enumeration scope: `SCOPED_ROOTS = (Path(".claude"),)` (line 20); `list_scoped_files` (lines 34-43)
  does `rglob("*")` and keeps files, sorted by relative path.
- Exclusions (lines 113-117): exactly two — `Path(".claude/settings.local.json")` and any path under
  `.claude/agent-memory/` via `_is_agent_memory_path` (lines 68-98, using `relative_to` with a
  `ValueError` guard).
- Comparison (lines 119-126): for each repo file, first `relative_path in bundled_files`, then
  `read_text(BUNDLED_ROOT, rel) == read_text(REPO_ROOT, rel)` where `read_text` is
  `.read_text(encoding="utf-8")` (line 49). The comparison is **UTF-8 text equality**, not a byte or
  hash comparison — a BOM or line-ending difference still fails, but the check is text-decoded.
- Direction: **one-way**. A bundle-only file with no repo counterpart does not fail this test.

A second, independent mirror check exists for the bash library specifically:
`tests/shell/parallel_bash_manifest_membership.bats:56-71` uses `cmp -s` (a true byte comparison)
between `.claude/lib/bash/<name>` and the bundle copy, and lines 73-82 additionally assert **no
bundled-only** bash file exists. That suite also enforces `core.json` membership (lines 43-54) and
carries a discovery floor `MINIMUM_LIB_FILE_COUNT=9` (line 21), which two added files keep satisfied.

### 5.2 Is the mirroring automated? **No.**

No script or task in this repository copies repo `.claude/**` into the bundle.
`scripts/dev_tools/push_down_claude_customizations.py` runs the other direction: its
`BUNDLE_ROOT_RELATIVE_DIR` (lines 67-69) is the **source**, and the destination is a consumer
workspace. `extensions/drm-copilot/src/lib/push-down/*` likewise reads from the pre-built bundle.
`Grep` for `mirror|sync.*bundle|Sync-` in `.vscode/tasks.json` returns no matches. The repo→bundle
copy is **manual**, and the two tests above are the only guards.

### 5.3 Exact bundle paths this feature will need

Every path below is under
`extensions/drm-copilot/resources/claude-customizations/`.

**Files that must be created (new):**

1. `.claude/lib/bash/parallel-lane-assertion.sh`
2. `.claude/lib/bash/report-lane-assertion.sh`

**Files that must be updated (edited in the repo, then re-copied):**

3. `.claude/skills/parallel-plan/SKILL.md` — replace the site-4 invocation and its grant note.
4. `.claude/skills/epic-orchestrate/SKILL.md` — delete the site-1 CLI spelling.
5. `.claude/skills/parallel-orchestrate/SKILL.md` — delete the site-2 CLI spelling.
6. `.claude/agents/parallel-planner.md` — add the entry-point grant to `tools:` and document the new
   entry point in `## Upstream Library Invocation`; reconcile the stale `Bash(poetry run *)` sentence
   at lines 185-186.
7. `.claude/agents/parallel-orchestrator.md` — see §5.4; **required**, not optional.
8. `.claude/rules/parallel-orchestration.md` — recommended: M8 line 134 names
   `scripts/dev_tools/parallel_lane_assertion.py` as the consumer; add the destination-runtime entry
   point alongside it, in the same "authority versus runtime path" form the rule already uses for
   cohorts and manifest validation.

**Bundle-only file (no repo counterpart, still required):**

9. `pack-manifests/core.json` — add `".claude/lib/bash/parallel-lane-assertion.sh"` and
   `".claude/lib/bash/report-lane-assertion.sh"` to the `paths` array beside lines 137-145. Without
   this, `parallel_bash_manifest_membership.bats:43-54` fails and a manifest-scoped push-down silently
   drops both files. Note that `core.json` is **outside** the `.claude/**` parity scope
   (`test_pack_manifests_are_outside_the_parity_scope`, lines 129-146), so it exists only in the
   bundle.

**Optional test extensions (inclusion-only assertions; they will not fail without the change, but
should be extended for consistency):**
`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:242-244` and
`extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:451-453`, both of which
enumerate the three current bash entry points.

### 5.4 A coupling the epic manifest did not record

`.claude/agents/parallel-orchestrator.md:92-94` justifies its two retained `poetry run` grants with
exactly two named consumers:

> "The two `poetry run` grants remain for the repository-local paths that still need an interpreter:
> the checkpoint-validator CLI fallback the skill names in its `## Parallel-Level Checkpoint` section
> is invoked as `poetry run python -m`, and the drift-detection CLI likewise."

The first of those two named consumers **is site 2** — the CLI form at
`parallel-orchestrate/SKILL.md:482`, which sits in the `## Parallel-Level Checkpoint` section
(the section's checkpoint prose runs from line 470). Deleting site 2 leaves this rationale citing a
consumer that no longer exists. The persona file must be updated in the same change. This is a real
scope item that neither the epic manifest nor `issue.md` records.

---

## 6. The 500-Line Cap

`.claude/rules/general-code-change.md` caps production, test, and reusable script files at 500 lines;
`.claude/rules/shell.md:89` restates it for shell.

The Python reference is 499 lines, but that is not a proxy for the port's size: the module is
docstring-dominant. Executable statements are concentrated in `derive_components` (lines 169-195,
~20 statements), `_find_split_lanes` (212-230), `_find_merged_lanes` (248-265), `compare` (286-326),
`format_report` (341-352), `read_manifest_inputs` (375-407), and `parse_edges` (424-433).

Two comparable bash ports set the scale: `parallel-cohorts.sh` is 330 lines for a graph-coloring
algorithm with four exact error strings, and `parallel-manifest-validate.sh` is 299 lines for eight
manifest invariants. Reading the M8 node table is already written and is being reused, not reported.
A faithful port therefore lands at roughly 250-320 lines of library plus 110-140 lines of entry
point — comfortably inside the cap in **two** files.

**Recommended split, along a real seam in the reference's structure.** The reference already draws
the seam itself at lines 34-38: "Every function and method below EXCEPT `main` is pure … only `main`,
the module's single I/O boundary". Split on that boundary, which is also the seam every existing
sibling uses (`parallel-cohorts.sh` pure / `compute-cohorts.sh` I/O;
`parallel-manifest-validate.sh` pure / `validate-parallel-manifest.sh` I/O):

- **`.claude/lib/bash/parallel-lane-assertion.sh`** — pure. `pla_derive_components`,
  `pla_find_split_lanes`, `pla_find_merged_lanes`, `pla_compare`, `pla_format_report`,
  `pla_read_manifest_inputs`, `pla_parse_edges`, plus the four class-token constants and the
  `PLA_FINDING_*` / `PLA_REPORT` accumulators. Sources `parallel-manifest-validate.sh`.
- **`.claude/lib/bash/report-lane-assertion.sh`** — I/O. Usage text, flag parsing, `cat` of the
  manifest, dispatch to the library, `printf` of the report, and the exit-code contract, with the
  `[[ ${BASH_SOURCE[0]} == "${0}" ]]` guard the other two entry points use
  (`compute-cohorts.sh:139-143`, `validate-parallel-manifest.sh:130-134`).

If the library nonetheless overruns, the second seam is the one `parallel-yaml-scan.sh` /
`parallel-yaml-emit.sh` already demonstrates (header note at `parallel-yaml-scan.sh:12-13`): split
derivation from comparison-and-formatting. That is a fallback, not the plan.

---

## 7. Toolchain and Coverage for the Port

### 7.1 bash (the recommended runtime) — `.claude/rules/shell.md`

Verified against both the rule file and the implementation:

- **Discovery root.** `.claude/rules/shell.md:48-51` names `tools/`, `scripts/`, and
  `.claude/lib/bash/` as the three search roots, and states the Claude bash library "is held to the
  same format, lint, test, and coverage standards". Confirmed in code at
  `scripts/bash/shell_qc_lib.sh:85` (`for root in tools scripts .claude/lib/bash; do`).
- **kcov measures it.** `.claude/rules/shell.md:65-67` states the kcov include pattern covers all
  three roots. Confirmed at `scripts/bash/shell_qc_lib.sh:335`:
  `include_pattern="$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash"`. Unlike the
  PowerShell runsettings, this is a **directory pattern**, not a per-file allow-list, so a new
  `.claude/lib/bash/*.sh` file is measured automatically with no registration step.
- **Thresholds.** Line coverage >= 85% (`.claude/rules/shell.md:68-70`). kcov reports line coverage
  only; **there is no bash branch-coverage gate**. Confirmed identically in
  `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`.
- **Toolchain order** (`.claude/rules/shell.md:17-32`): `bash scripts/bash/shell-qc.sh format` →
  `bash scripts/bash/shell-qc.sh check` (shfmt diff + shellcheck) → no type-check stage →
  `bash scripts/bash/shell-qc.sh test [--coverage]`. Restart from step 1 on any failure or rewrite.
  On Windows, run under WSL (line 39).
- **Coding standards** the port must follow (lines 81-93): `set -euo pipefail` in the entry point;
  capture intentionally non-zero tools with `|| rc=$?`; shellcheck-clean with inline justified
  suppressions only; shfmt default tab indentation; quote all expansions; 500-line cap; **no
  temporary files** in tests — use checked-in fixtures under `tests/fixtures/`.
- **CI.** `.github/workflows/_shell-coverage.yml` builds kcov v43 from source on `ubuntu-latest` and
  uploads `artifacts/pester/kcov/**`.

### 7.2 Test locations

- bats tests: `tests/shell/*.bats` (`.claude/rules/shell.md:58, 90`; the directory list is
  `tests/shell` then `tests/bash`, whichever exist). The nine existing parallel-surface suites are
  named `parallel_*.bats`, so the port's suites belong at
  `tests/shell/parallel_lane_assertion.bats` and `tests/shell/parallel_lane_assertion_parity.bats`.
- Python-lane parity suite: `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`,
  mirroring the two existing `*_bash_parity.py` modules.
- Shared corpus: `tests/fixtures/parallel_lane_assertion/*.json`.

### 7.3 PowerShell — only if the recommendation in §2 is overridden

- **Toolchain** (`.claude/rules/powershell.md:13-20`): `mcp__drm-copilot__run_poshqc_format` →
  `mcp__drm-copilot__run_poshqc_analyze` → no type-check → `mcp__drm-copilot__run_poshqc_test`,
  using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Restart from step 1 on any
  failure or file change.
- **Test location** (`.claude/rules/powershell.md:57-58`): mirror the source structure under
  `tests/`, `*.Tests.ps1`. The `.claude/lib/**` convention in this repo is
  `tests/scripts/claude-lib/<module-dir>/<Module>.Tests.ps1`.
- **Coverage configuration** (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-248`):
  `CodeCoverage.Path` is an **explicit per-file allow-list**, restated in the file's own comments at
  lines 158-162 and 228-235. A new module must be registered there, and in the bundled parity copy
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, which
  `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16` pins.
- **Known gotcha (verified as still applicable).** `mcp__drm-copilot__run_poshqc_test` resolves its
  runsettings from the **installed VS Code extension**, not from either in-repo copy, so a newly added
  `CodeCoverage.Path` entry produces zero coverage rows under the MCP runner and reads as a coverage
  failure rather than a tooling-path problem. The workaround is to invoke the self-hosted module
  directly (`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root
  (Get-Location).Path -ScanFolders @(...)`), because `PoshQC.psm1` sets `$script:PesterSettings` from
  its own module root. Coverage XML must be keyed on the enclosing `package` element, never the bare
  `sourcefile` name. This is a further argument for the bash recommendation: the bash coverage path
  is a directory pattern with no registration step and no installed-extension dependency.
- **Change budget** (`.claude/rules/powershell.md:39-41`): at most 3 production and 3 test PowerShell
  files per batch.

### 7.4 Coverage exclusion policy

`.claude/rules/general-unit-test.md`, "Coverage Exclusion Policy": no production file may be excluded
from coverage measurement, and a feature-review agent must treat an `exclude` entry matching a
production source path as **Blocking**. Both new bash files are production files under a measured
root; neither may be excluded.

---

## 8. Feature A and Feature C Dependencies

### 8.1 Both feature folders are ABSENT on this branch

Verified explicitly:

- `Glob docs/features/active/*/spec.md` returns 25 folders. Neither
  `blast-radius-powershell-calling-convention` (Feature A / issue 901) nor
  `caller-site-invocation-correctness` (Feature C / issue 903) is among them. The only
  epic-associated folder present is this feature's own,
  `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/`.
- `Glob docs/features/**/*calling-convention*` → no files found.
- `Glob docs/features/**/*caller-site*` → no files found.

There is therefore **no** Feature A or Feature C `spec.md` or plan to read on this branch, and no
convention text to inherit from them directly. The epic manifest's placeholder issue numbers 901-904
are also still unresolved at manifest lines 22-33, confirming the siblings have not completed
preparation.

### 8.2 What the port should assume in their absence

**Feature A — fail-fast import convention.** The epic states (manifest lines 87-89, verified against
the tree) that no file under `.claude/lib/**` sets `$ErrorActionPreference`, and that Feature A adds
a fail-fast import guard. That convention is **PowerShell-specific**: `$ErrorActionPreference` and
`Import-Module -ErrorAction Stop` have no bash analogue. Under the recommended bash-only design,
Feature A's import convention **does not apply** to the port.

The bash equivalent already exists and the port should follow it unchanged, since it is the same
intent expressed in the destination runtime:
- `set -euo pipefail` in the entry point (`compute-cohorts.sh:26`,
  `validate-parallel-manifest.sh:24`).
- Self-directory resolution before sourcing, so a library loads regardless of cwd
  (`compute-cohorts.sh:29-32`, `parallel-cohorts.sh:28-31`, `parallel-manifest-validate.sh:31-34`,
  `parallel-yaml-emit.sh:30-33`).
- `pc_enforce_c_locale` called by every entry point before doing any work
  (`compute-cohorts.sh:34`, `validate-parallel-manifest.sh:32`; rationale at
  `parallel-common.sh:13-16`, determinism countermeasure R9).

**Feature A — date coercion.** The epic retargets this to the three `ConvertFrom-Json` sites under
`.claude/lib/**` (`OrchestratorState.psm1:175`, `HookPayload.psm1:262`,
`DiscoveryValidation.psm1:338`). The lane-assertion port parses **no JSON** and reads **no
timestamp**: it consumes `expected_conflict_components` and `items[].issue_num` only. The
date-coercion convention has **no application surface** in this port. State that explicitly in
`spec.md` so its absence is not read as an omission.

**Feature C — file-region contention.** Feature C's three sites are, corrected:
`.claude/skills/parallel-plan/SKILL.md:183`, `.claude/skills/parallel-add/SKILL.md:62`, and
`.claude/agents/parallel-planner.md:151`.

| File | Feature C region | Feature D region | Overlap |
| --- | --- | --- | --- |
| `.claude/skills/parallel-plan/SKILL.md` | 182-184 (`Import-Module` fence), plus surrounding prose in `## Radius Computation and Validation` (176-195) | 313-329 (seeding step 2) and 569-573 (completion report) | **None line-wise.** Same file, ~130 lines apart. Wave serialization removes the merge risk; there is no semantic coupling. |
| `.claude/agents/parallel-planner.md` | 151 (`Import-Module` fence, inside `## Upstream Library Invocation` at 140-186) | `tools:` list at 5-20, and the same `## Upstream Library Invocation` section at 158-186 | **Yes, section-level.** Both features edit `## Upstream Library Invocation`. Feature C rewrites the PowerShell paragraph (147-156); Feature D adds a fourth bash entry point (158-168) and must reconcile the stale `Bash(poetry run *)` sentence (185-186). Adjacent, not identical, but a rebase conflict is plausible if the paragraph boundaries shift. |
| `.claude/skills/parallel-add/SKILL.md` | 62 | none | None. |
| `.claude/agents/parallel-orchestrator.md` | none | 92-97 (§5.4) | None. |

Feature D should assume Feature C has already rewritten the `Import-Module` call sites to use `pwsh`,
a root-anchored module path, `-ErrorAction Stop`, and the `$result['conflict']` read pattern, and must
not restate or re-edit those. If Feature D lands first for any reason, it must confine its
`parallel-planner.md` edits to the `tools:` list and the bash paragraph, leaving 147-156 untouched.

---

## 9. The Original Deferral Record

`docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/spec.md`:

- **Line 51**, under "Out of scope / non-goals": *"A bash or destination-runtime port of the D3
  lane-assertion diagnostic (explicitly deferred; the diagnostic is advisory-only and degrades
  gracefully on the no-Python path)."*
- **Line 266**, under "Rollout & Follow-up": *"Post-fix follow-ups (explicitly deferred, not in
  scope): `max_preparation_concurrency` manifest key; bash/destination-runtime port of the
  lane-assertion diagnostic."*

Both citations are correct as given.

### 9.1 Design intent the port must honor

Four constraints from the same spec, each with a live enforcement artifact:

1. **Assertion, never declaration** (spec line 62, D3 root cause): "the fix must add an ASSERTION
   seam, never a DECLARATION seam: the field must never override a derived edge, never feed
   `compute_cohorts`, and never influence scheduling". Restated in `.claude/rules/parallel-orchestration.md:134`
   and `.claude/skills/parallel-plan/SKILL.md:322-325`.
2. **No production consumer** (spec line 260, AC30). The completion evidence
   `.../evidence/other/d3-scope-gates.2026-08-17T01-55.md` records the gate: `git grep -n
   "parallel_lane_assertion" -- scripts/dev_tools` returns exactly one line — the module's own
   `argparse` `prog` value at line 440 — and no cohort-computation, validator, helper, or mutation
   module names it. Re-verified in this pass: `Grep parallel_lane_assertion --glob *.py` returns
   exactly two files, the module and its test module.
   **Consequence for the port:** no file under `.claude/lib/bash/` may source
   `parallel-lane-assertion.sh` or `report-lane-assertion.sh`. The dependency arrow points only
   outward (diagnostic → manifest contract), mirroring `parallel_lane_assertion.py:50`.
3. **Advisory rendering, not an exit code** (module docstring lines 14-18, and `main`'s `Returns`
   at 466-469): "a disagreement must not be expressible as a non-zero exit status". The port always
   exits 0 except for an argparse-equivalent usage error.
4. **Graceful degradation on partial input** (module docstring 155-158, 361-365): malformed edges and
   malformed manifest entries are skipped, never raised — "malformed-edge reporting belongs to the
   checkpoint validators, and a diagnostic must degrade gracefully on partial input".

Note the deferral's stated rationale — "degrades gracefully on the no-Python path" — is precisely
what Feature D corrects. Degrading gracefully means the step silently does nothing at the
destination, while `SKILL.md:313` calls it mandatory and `SKILL.md:569-570` calls its report line item
REQUIRED. That gap is the defect; it is not a rule contradiction (see §11).

---

## 10. Prose Citations That Must NOT Change

### 10.1 The two discovery-gate hook comments

Both re-read in this pass. `.claude/hooks/enforce-discovery-artifact-gate.ps1:49-52`:

```
        This no longer invokes a Python interpreter (issue #475). The `.claude/**`
        payload ships to destinations with no guaranteed Python, Poetry, or
        `scripts/dev_tools`, where the previous `python -m ...` call failed
        obscurely or blocked every operation.
```

`.claude/hooks/validate-discovery-artifact-gate.ps1:50-53` carries the identical four-line paragraph
(the prompt's `50-52` is one line short).

**Recommendation: no change.** Rationale:

- The text is accurate today and remains accurate after Feature D. It is a rationale record, not a
  procedure step, and it names no path this feature alters.
- Both files are covered by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`,
  which parses PowerShell ASTs and explicitly asserts at lines 319-331 that interpreter names inside
  **comments** produce no finding. The comments are therefore already proven inert to the guard.
- That suite ships an **empty allowlist** (lines 102-109: "issue #475 removes every site, so none
  needs an exemption. An entry may only be added by an owner decision, never to pass a failure") and
  scans exactly `.claude/hooks` and `.claude/lib`, deliberately excluding `.claude/lib/bash/**` as
  shell and the bundled mirror as a byte-identical copy (lines 36-42, 65-68, 452-471). Feature D adds
  no PowerShell to either scan root, so the suite is unaffected.
- Editing them would produce two more mirror files to re-sync for zero behavioral benefit.

If a reviewer nonetheless wants a wording refresh, the smallest defensible change is to append
"(extended by issue #599 to the orchestration skills)" to the first sentence. That is an optional
nicety, not a requirement.

### 10.2 Legitimate `scripts/dev_tools` prose citations elsewhere under `.claude/**`

`Grep 'scripts[/.]dev_tools'` over `.claude/**` returns **158 occurrences across 46 files**. All but
the five executable invocation sites in §11 are prose citations that identify the Python modules as
authoritative reference implementations, per `.claude/rules/parallel-orchestration.md`. The
implementation must not touch them. Per-file occurrence counts:

| File | Count | | File | Count |
| --- | --- | --- | --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 20 | | `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | 3 |
| `.claude/rules/parallel-orchestration.md` | 16 | | `.claude/lib/codex-routing/CodexDeployment.psm1` | 3 |
| `.claude/rules/orchestrator-state.md` | 13 | | `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 3 |
| `.claude/skills/parallel-plan/SKILL.md` | 9 | | `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | 3 |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 6 | | `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | 3 |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 6 | | `.claude/agents/epic-orchestrator.md` | 2 |
| `.claude/rules/plan-acceptance-gates.md` | 6 | | `.claude/agents/parallel-planner.md` | 2 |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | 6 | | `.claude/agents/parallel-orchestrator.md` | 2 |
| `.claude/skills/parallel-add/SKILL.md` | 5 | | `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 2 |
| `.claude/skills/orchestrate/SKILL.md` | 5 | | `.claude/lib/blast-radius/BlastRadius.psm1` | 2 |
| `.claude/skills/parallel-remove/SKILL.md` | 5 | | `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | 2 |
| `.claude/lib/model-routing/ModelRouting.psm1` | 5 | | `.claude/lib/codex-routing/CodexTopology.psm1` | 2 |
| `.claude/skills/epic-orchestrate/SKILL.md` | 3 | | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 2 |
| | | | `.claude/hooks/enforce-parallel-drift-gate.ps1` | 2 |

The remaining 18 files carry exactly one occurrence each:
`.claude/skills/parallel-close/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`,
`.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/hooks/enforce-discovery-artifact-gate.ps1`,
`.claude/hooks/validate-discovery-artifact-gate.ps1`,
`.claude/hooks/enforce-prd-feature-before-planner.ps1`,
`.claude/hooks/validate-orchestrator-output.ps1`, `.claude/lib/blast-radius/BlastRadiusConfig.psm1`,
`.claude/lib/blast-radius/BlastRadiusNormalization.psm1`, `.claude/lib/bash/parallel-cohorts.sh`,
`.claude/lib/bash/parallel-common.sh`, `.claude/lib/bash/parallel-items-validate.sh`,
`.claude/lib/bash/parallel-manifest-validate.sh`,
`.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1`,
`.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1`,
`.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`,
`.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`,
`.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`,
`.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1`.

Three files in the tables above **do** need an edit, but for their executable content or their
now-stale grant rationale, never for their citation content:
`.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`,
`.claude/skills/parallel-orchestrate/SKILL.md`, plus `.claude/agents/parallel-planner.md` and
`.claude/agents/parallel-orchestrator.md`. Of the 158 citations, the count that becomes stale is
**one**: the M8 consumer sentence at `.claude/rules/parallel-orchestration.md:134`, which should gain
the destination-runtime entry point alongside the Python authority rather than replace it.

---

## 11. Numeric Derivation Evidence

### Claim 1 — There are exactly **five** executable Python or Poetry invocation sites under `.claude/**`

- **Complete Family:** every occurrence, in any tracked file under `.claude/**` in this worktree, of a
  command-position invocation of a Python interpreter or of Poetry, across every spelling the
  repository's own detection helper recognizes: `python`, `python3`, `py`, and `poetry`, in the forms
  `python -m`, `python <path>.py`, `python -c`, `poetry run python -m`, `poetry run python <path>.py`,
  `poetry run python -c`, and `poetry run <subcommand>`.
- **Exhaustive Search Scope:** the entire `.claude/` subtree of the worktree
  (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3f62591bf10aebf3\.claude`), all
  file types, no path filter.
- **Inclusion Rules:** the token appears in a command position that a reader of the payload is
  instructed to execute — inside a fenced code block that is presented as a procedure step, or as an
  inline command literal introduced as an invocation.
- **Exclusion Rules:** (a) permission allowlist entries in `tools:` frontmatter or
  `settings.json` `permissions.allow`; (b) prose describing a grant, a past state, or a module
  identity; (c) comments; (d) regular-expression literals inside hook source; (e) the
  language-scoped Python QA toolchain, which is by definition inapplicable on a destination with no
  Python and is not an orchestration procedure step.
- **Primary Search Strategy:** case-insensitive `Grep` for the literal `poetry` over `.claude/**`,
  content mode, then manual classification of every returned line against the inclusion and exclusion
  rules. This is exhaustive over the entire Poetry half of the family and, because every Poetry
  invocation in the payload is `poetry run python`, over most of the interpreter half.
- **Primary Member Set** (executable, after classification):
  1. `.claude/skills/epic-orchestrate/SKILL.md:296`
  2. `.claude/skills/parallel-plan/SKILL.md:315`
  3. `.claude/skills/parallel-orchestrate/SKILL.md:482`
  4. `.claude/skills/parallel-orchestrate/SKILL.md:817`
  5. `.claude/skills/parallel-remove/SKILL.md:112`
- **Primary Count:** 5. (Site 1 carries no `poetry` prefix and is therefore *not* returned by the
  primary query; it is recovered by the cross-check. The primary query returns 39 lines total; the 4
  executable Poetry sites are 112/315/482/817. The nine `poetry run black|ruff|pyright|pytest` lines
  in `python-qa-gate/SKILL.md:30-33`, `rules/python.md:13-16`, and
  `feature-review-workflow/SKILL.md:108` are excluded by rule (e); the eight allowlist entries at
  `settings.json:6`, `atomic-executor.md:11-14`, `orchestrator.md:13`,
  `parallel-orchestrator.md:16-17`, `parallel-planner.md:16` by rule (a); the remainder by rules
  (b), (c), and (d).)
- **Cross-check Search Strategy:** a structurally different regular expression targeting the
  interpreter name in command position rather than the Poetry wrapper —
  `(^|[`&$( ])(python|python3|py)\s+(-m|-c|-3|scripts)` over `.claude/**`, content mode. This query
  matches on the interpreter token and its immediately following mode flag or path, so it recovers
  bare `python -m` forms the primary query cannot see, and it covers the `py -3` and
  `python <path>.py` spellings independently.
- **Cross-check Member Set** (executable, after applying the same classification rules):
  1. `.claude/skills/epic-orchestrate/SKILL.md:296`
  2. `.claude/skills/parallel-plan/SKILL.md:315`
  3. `.claude/skills/parallel-orchestrate/SKILL.md:482`
  4. `.claude/skills/parallel-orchestrate/SKILL.md:817`
  5. `.claude/skills/parallel-remove/SKILL.md:112`
- **Cross-check Count:** 5. (The query returns 11 lines; the six non-executable ones are
  `parallel-orchestrator.md:16`, `:17` (allowlist), `:94` (prose), `DiscoveryValidation.psm1:7`
  (prose), `enforce-discovery-artifact-gate.ps1:51` and `validate-discovery-artifact-gate.ps1:52`
  (comments).)
- **Member-set Comparison:** Normalizing both sets to `<path>:<line>` strings and sorting:
  primary = {`epic-orchestrate/SKILL.md:296`, `parallel-orchestrate/SKILL.md:482`,
  `parallel-orchestrate/SKILL.md:817`, `parallel-plan/SKILL.md:315`,
  `parallel-remove/SKILL.md:112`}; cross-check = the identical five strings. The sets are **equal**;
  neither contains a member the other lacks. A third, independent superset query
  (`Grep '\.py\b'` over `.claude/**`, 175 occurrences across 56 files) introduces no additional
  executable site: the only executable `.py`-suffixed invocation it adds beyond the two sets is
  `parallel-remove/SKILL.md:112`, already a member of both.
- **Assertion:** Exactly five executable Python or Poetry invocation sites exist under `.claude/**`.
  Three are in scope (sites 1, 2, 4 in `issue.md`'s numbering: `epic-orchestrate:296`,
  `parallel-orchestrate:482`, `parallel-plan:315`); two are explicit non-goals
  (`parallel-orchestrate:817`, `parallel-remove:112`). The epic manifest's "exactly four" at line 169
  is superseded.

### Claim 2 — The diagnostic emits exactly **four** ADVISORY finding classes, of which exactly **one** is informational

- **Complete Family:** every distinct `kind` value a `LaneAssertionFinding` can carry, over every
  construction site in `scripts/dev_tools/parallel_lane_assertion.py`, plus the membership of
  `INFORMATIONAL_KINDS`.
- **Exhaustive Search Scope:** the whole of `scripts/dev_tools/parallel_lane_assertion.py` (499
  lines), plus its two independent documentation consumers.
- **Inclusion Rules:** a value that reaches `LaneAssertionFinding.kind` and is therefore rendered
  into an `ADVISORY [{kind}]` line.
- **Exclusion Rules:** module-level constants that are not finding kinds (`EDGE_SEPARATOR`,
  `INFORMATIONAL_KINDS` itself).
- **Primary Search Strategy or Query Expression:** `Grep '^[A-Z_]+ = "|^[A-Z_]+:'` over the module —
  enumerate every module-level constant declaration and classify.
- **Primary Member Set:** lines 57-60 declare `EXPECTED_TOGETHER_DERIVED_APART`,
  `EXPECTED_APART_DERIVED_TOGETHER`, `MEMBER_NAMES_NO_ITEM`, `ITEM_COVERED_BY_NO_COMPONENT`. Line 64
  declares `INFORMATIONAL_KINDS = frozenset({ITEM_COVERED_BY_NO_COMPONENT})` (one member). Line 68
  declares `EDGE_SEPARATOR`, excluded by rule.
- **Primary Count:** 4 finding classes; 1 informational.
- **Cross-check Search Strategy or Query Expression:** `Grep 'kind='` over the module — enumerate
  every *construction* site rather than every declaration, which is a different program element and
  would diverge if a constant were declared but never used, or a literal were passed inline.
- **Cross-check Member Set:** line 221 `kind=EXPECTED_TOGETHER_DERIVED_APART`; line 257
  `kind=EXPECTED_APART_DERIVED_TOGETHER`; line 307 `kind=MEMBER_NAMES_NO_ITEM`; line 317
  `kind=ITEM_COVERED_BY_NO_COMPONENT`.
- **Cross-check Count:** 4.
- **Member-set Comparison:** Normalized to the constant names and sorted, primary =
  {`EXPECTED_APART_DERIVED_TOGETHER`, `EXPECTED_TOGETHER_DERIVED_APART`,
  `ITEM_COVERED_BY_NO_COMPONENT`, `MEMBER_NAMES_NO_ITEM`}; cross-check = the identical four names.
  The sets are **equal**, and no constant is declared without a construction site or constructed
  without a declaration. Two independent documentation sources corroborate: the payload prose at
  `.claude/skills/parallel-plan/SKILL.md:318-321` names the same four in the same order, and the
  test module's import list at `tests/scripts/dev_tools/test_parallel_lane_assertion.py:25-28` imports
  exactly those four tokens and no fifth.
- **Assertion:** The diagnostic emits four ADVISORY finding classes —
  expected-together-but-derived-apart, expected-apart-but-derived-together, member-names-no-item, and
  the informational item-covered-by-no-component — and exactly one of them (the last) is excluded
  from `disagreement_count`.

---

## 12. Behavior Semantics for the Port

### 12.1 Success and failure conditions

- **Success** is defined as "the report was printed". A report containing disagreements is a success.
- **The only non-zero exit** is the usage error (exit 2), matching `argparse`. Every other path —
  unreadable manifest, unparseable manifest, out-of-subset manifest, findings present, findings
  absent — exits **0**.
- The port must never write a file, never mutate a checkpoint, and never be sourced by a scheduling
  module (§9.1 item 2).

### 12.2 Ordering rules (all load-bearing for parity)

1. Findings are grouped by class in the fixed order split → merged → unknown-member → uncovered-item.
2. Within the split class, expected components are visited in **manifest** order.
3. Within the merged class, derived components are visited in **derived** order (lowest member
   ascending).
4. Within the last two classes, keys are visited **ascending**.
5. Derived component members are ascending; components are ordered by lowest member.
6. Every finding's own `members` tuple is ascending.
7. All sorting must run under `LC_ALL=C` via `pc_enforce_c_locale`, and every numeric sort must use
   `sort -n`, per the determinism discipline at `parallel-common.sh:13-16` and
   `parallel-cohorts.sh:6-13`.

### 12.3 Edge cases the corpus must cover

- Manifest with no `expected_conflict_components` key → every item uncovered, 0 disagreements.
- Manifest with an empty `items` list and no assertion → `Lane assertion: 0 derived conflict
  component(s); 0 disagreement(s).` plus the closing line only.
- Component with `name` absent → label renders `component[0]`.
- Component with `name: ''` → label renders `''` (empty string is a `str`).
- Component whose `members` contains a non-positive or boolean value → that member is dropped, the
  component survives.
- Component whose `members` are **all** dropped → an empty component that can produce no finding.
- The same `issue_num` in two components → the later position wins in `expected_index`; M8 would
  report this as a validation error, but the diagnostic must **not**.
- A duplicate member inside one component → duplicated in the `resolved` list and in the finding's
  `members` tuple.
- Self-loop edge, and an edge naming an undeclared key → both silently skipped.
- Reversed and duplicated edges → collapse to one adjacency entry.
- A `--edges` token with no colon, with two colons, or with a non-integer endpoint → dropped.
- Empty and whitespace-only `--edges` → no edges.
- 13 lanes over 69 items (the motivating scale, `test_parallel_lane_assertion.py:46-49`) → exactly 13
  components, 0 disagreements.

---

## 13. Requirements Mapping

| `issue.md` acceptance criterion | Concrete design |
| --- | --- |
| Destination-portable port exists under `.claude/lib/` with output identical to the Python reference | `.claude/lib/bash/parallel-lane-assertion.sh` + `.claude/lib/bash/report-lane-assertion.sh` (§2.4, §6), asserted by the corpus in §4.4 with the five declared divergence classes |
| Port always exits 0, never blocks, never feeds `compute_cohorts`, never influences scheduling | Exit-code contract in §12.1; no `.claude/lib/bash/*` file sources the port (§9.1 item 2); the port sources `parallel-manifest-validate.sh` only |
| `parallel-plan/SKILL.md` invokes the port instead of `poetry run python -m ...` | Replace line **315**; update the grant note at line **316**; leave 322-329 and 569-573 semantically unchanged |
| CLI spellings at `epic-orchestrate:296` and `parallel-orchestrate:482` removed, MCP form retained | Both MCP forms already sit alongside (`epic-orchestrate:297-299`, `parallel-orchestrate:480-481`), and `require_complete` is a supported MCP argument (`extensions/drm-copilot/src/mcp-tool-definitions.ts:423`, `mcp-repo-automation-tool-definitions.ts:356`), so no capability is lost |
| Parity suite asserts port-vs-reference identity | §4.4, five artifacts |
| Every added/edited `.claude/**` file has a byte-identical bundle copy | §5.3, nine paths, of which `pack-manifests/core.json` is bundle-only |
| The two non-goals recorded in `spec.md` with rationale | §14 |
| *(new, not in `issue.md`)* `parallel-orchestrator.md:92-94` rationale reconciled after site 2 deletion | §5.4 |
| *(new, not in `issue.md`)* `parallel-planner.md:185-186` reconciled with `parallel-plan/SKILL.md:316` | §2.3 |
| *(correction)* `expected_conflict_components` YAML-subset readability | Already satisfied; restate as verified, not as a risk (§3.2) |

### 13.1 No state model change

The port introduces no state. It writes no checkpoint field. `.claude/skills/parallel-plan/SKILL.md:328-329`
already states that recording the diagnostic's result in the planner checkpoint is "a tolerated extra
field, not a validated one; no validator changes for it". Feature D must not add a validator field.

---

## 14. The Two Explicit Non-Goals

Recorded here so the scope boundary is unambiguous. **Neither is planned in this research, and
neither must be addressed for the epic's stated goal to hold** — see §14.3.

### 14.1 `parallel_drift_detection_cli` (`.claude/skills/parallel-orchestrate/SKILL.md:817`)

The invocation sits under a heading literally named `#### CLI Invocation` (line 809) and is the sole
I/O wrapper over two pure modules (lines 811-814). `.claude/agents/parallel-orchestrator.md:92-96`
deliberately retains `Bash(poetry run python -m *)` for it, scoping the grant "to those two
invocation forms only — not to `poetry run` as a whole". The dependency is a recorded decision, not
drift. Porting it is a second net-new implementation outside this epic's locked scope.

### 14.2 `parallel_mutation_abandon_cli.py` (`.claude/skills/parallel-remove/SKILL.md:112`)

Mandatory in the strongest available terms (lines 105-118): the abandon disposition runs "through the
single deterministic CLI invocation below and through nothing else", and ad hoc `gh pr close` /
`git worktree remove` is PROHIBITED because "the abandon gate matches on the tokens of the invocation
above". `.claude/hooks/enforce-parallel-abandon-gate.ps1` declares the matched token literals in
exactly one place (lines 38-45), and `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`
parses both sides at run time so a one-sided rename fails
(`enforce-parallel-abandon-gate.ps1:27-31`). Changing the invocation without co-designing the gate
would break the confirmation contract the gate exists to enforce.

### 14.3 Do either MUST be addressed for the epic's stated goal?

**No, with one honest qualification.** The epic's leading indicator (manifest line 14) reads: "No
file under `.claude/**` contains an executable python or poetry invocation **that a mandatory
procedure step depends on**." Under that wording, site 4 (drift detection) is inside an
orchestrator-side detection procedure and site 5 (abandon) is mandatory in the strongest terms, so a
strict reading of the indicator is not fully satisfied after Feature D lands. The narrower indicator
at manifest line 15 — "The lane-assertion diagnostic runs to completion on a destination runtime with
no Python interpreter present" — **is** fully satisfied.

The correct disposition is to record the residual in `spec.md` as a known, deliberate remainder with
the two rationales above, and to reword the epic's line-14 indicator to scope it to the sites this
epic actually closes. That is a manifest-wording action for the epic owner, not additional
implementation work for Feature D. Do not expand Feature D's scope.

---

## 15. Testing Implications

Consistent with `.claude/rules/general-unit-test.md`, `.claude/rules/shell.md`, and the parity
precedent. No test code is written here.

1. **bats unit suite** (`tests/shell/parallel_lane_assertion.bats`) — sources the library and
   exercises each function directly, in the style of `tests/shell/parallel_manifest_validate.bats`.
   This is where the >= 85% line coverage is earned. Cover every edge case in §12.3, plus the entry
   point's usage/`--help`/missing-`--manifest` paths and the exit-code contract.
2. **bats parity suite** (`tests/shell/parallel_lane_assertion_parity.bats`) — iterates the shared
   corpus as a subprocess, pinning stdout and exit status. Declare a `MINIMUM_FIXTURE_COUNT` floor
   and a dedicated case asserting the floor, plus the `python3 is available` case, so the suite can
   never pass vacuously.
3. **pytest parity suite** (`tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`) —
   same corpus, reference implementation, no subprocess, `MINIMUM_FIXTURE_COUNT` floor asserted in
   its own test, parametrized with `ids=lambda path: path.stem`.
4. **Payload-only cases** appended to `tests/shell/parallel_payload_only.bats` — invoke the new entry
   point from the bundle root under the four-shim `PATH`, asserting exit 0 and the expected report.
   This is the acceptance evidence for the epic's line-15 leading indicator.
5. **Mirror and manifest membership** — `tests/shell/parallel_bash_manifest_membership.bats` and
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` both pass unchanged once the
   two new files are copied to the bundle and registered in `core.json`. Neither needs editing;
   `MINIMUM_LIB_FILE_COUNT=9` stays satisfied at 11 files. Optionally raise it to 11 to preserve the
   floor's discriminating power.
6. **Determinism** — no temporary files anywhere (`.claude/rules/shell.md:90-93`); the corpus and the
   fixture manifests are checked in; every sort under `LC_ALL=C`; the diagnostic reads no clock and no
   environment beyond `LC_ALL`.
7. **Coverage evidence** — `bash scripts/bash/shell-qc.sh test --coverage` prints
   `Bash coverage (lines): NN.N%` and writes `artifacts/pester/kcov/cov.xml`. Because the include
   pattern is directory-scoped, both new files appear automatically. Record the per-file rows in
   `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/qa-gates/`.

---

## Automation Feasibility

**Every step of this feature is automatable. No manual or third-party-UI step is required.**

Reasoning, step by step:

- **Source edits.** All eight repository files in §5.3 are text files edited with `Edit`/`Write`.
- **New files.** Both new bash modules are created with `Write`.
- **Bundle mirroring.** No automation exists (§5.2), but the operation is a file copy of known source
  and destination paths, fully expressible as `Write` of identical content or a `Copy-Item`. The
  absence of a sync script makes the step manual-to-author, not manual-to-perform-in-a-UI.
- **`pack-manifests/core.json`.** A JSON array edit, two string entries.
- **Toolchain.** `bash scripts/bash/shell-qc.sh format|check|test [--coverage]` are non-interactive
  CLI commands (`.claude/rules/shell.md:19-29`), runnable under WSL on Windows.
- **Python-lane verification.** `poetry run black|ruff|pyright|pytest` are non-interactive
  (`.claude/rules/python.md:13-16`); the pytest parity suite and the push-down contract test run under
  `poetry run pytest`.
- **PowerShell.** Under the recommended bash-only design, no PowerShell production file is added, so
  the PoshQC MCP toolchain and the runsettings registration step in §7.3 — the only place where the
  installed-extension gotcha could bite — do not arise at all.
- **Verification of every claim in this document.** Each is a `Grep`, `Read`, or `Glob` over the
  worktree, or a non-interactive CLI run.

There is no marketplace publish, no VS Code extension install, no GitHub web UI action, and no
third-party service interaction anywhere in this feature's surface. The expected finding — that
automation is complete — is confirmed.

---

## Open Questions for the Planner

1. **Entry-point name.** `report-lane-assertion.sh` is recommended over `assert-parallel-lanes.sh`
   because "assert" implies a blocking verdict. Confirm the name before the pack-manifest entry and
   the persona grant are authored, since renaming later touches five files.
2. **`--keys` flag.** The reference has none; item keys come from the manifest. Confirm the port does
   not gratuitously add one, which would create a surface the Python lane cannot mirror.
3. **Out-of-subset manifests.** The Python lane has no counterpart for `pm_parse_manifest` status 2.
   Confirm the recommendation in §4.4 class 5: print a distinct refusal line and exit 0.
4. **`--edges` integer lexis.** Confirm whether the port reproduces Python `int()`'s permissiveness
   or declares it excluded (§1.4, §4.4 class 3). Reproducing it is more faithful; excluding it matches
   the precedent already set by `compute-cohorts.sh`.
5. **`MINIMUM_LIB_FILE_COUNT`.** Raise `tests/shell/parallel_bash_manifest_membership.bats:21` from 9
   to 11 so the floor keeps discriminating, or leave it as a lower bound.
6. **Epic leading-indicator wording.** §14.3 — the epic owner should narrow manifest line 14 so the
   two non-goals do not read as a Feature D shortfall.
