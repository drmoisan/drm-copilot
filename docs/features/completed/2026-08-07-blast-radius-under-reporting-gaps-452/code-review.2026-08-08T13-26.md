# Code Review — Blast-radius under-reporting gaps (Issue #452)

- Timestamp: 2026-08-08T13-26
- Branch: `bug/blast-radius-under-reporting-452`
- Base branch: `epic/parallel-orchestration-integration` (merge base `05c48ced`)
- Commit: `7a835c38` — 108 files, +7494 / -358
- Work mode: `full-bug`
- **Total Blocking findings: 0**
- **Total Non-blocking findings: 6** (shared numbering with `policy-audit.2026-08-08T13-26.md`)

## Change Inventory

| Category | Files | Notes |
|---|---|---|
| Python production | 6 | 4 modified, 2 added (`_blast_radius_glob.py`, `_blast_radius_thresholds.py`) |
| PowerShell production | 10 | 5 modified under `.claude/lib/blast-radius/`, 5 byte-identical bundled mirrors |
| Python tests | 6 | all modified, add-only except one import relocation |
| PowerShell tests | 5 | all modified, add-only except the two authorized inversions |
| Test fixtures | 5 | all added |
| Documentation | 1 | F1 spec (`...-447/spec.md`) amended |
| Feature documents | 4 | `issue.md`, `spec.md`, `plan.*`, `research/*` |
| Evidence artifacts | ~60 | canonical `evidence/{baseline,regression-testing,qa-gates,other}/` |
| Promotion | 1 | `docs/features/potential/...` -> `.../potential/promoted/...` (R100, pure rename) |

## Design Assessment

### Gap 1 — separator-free root surfaces (positive)

The chosen resolution is the strongest of the three candidates recorded in `issue.md`. The set of
admissible separator-free tokens is **derived** from `config["shared_surfaces"]` at call time
rather than duplicated as a second literal list, which structurally prevents the desynchronization
failure the issue identified as the dominant risk. The reader is one function per language:

- `config_root_surfaces` (`scripts/dev_tools/_blast_radius_validation.py:194-228`)
- `Get-ConfigRootSurface` (`.claude/lib/blast-radius/BlastRadiusConfig.psm1:230-278`)

Both filter for entries containing no `/`, with an explicit comment explaining why a
separator-bearing surface is deliberately excluded (already reachable via the ordinary path-shape
rules) and why `shared_surface_globs` is deliberately not a source (a glob can never be an exact
token match). This is the right boundary and it is documented at the point of decision.

The critical correctness property is that `derive_blast_radius` and `validate_blast_radius` obtain
the set from **the same `config` mapping through the same reader**. Both call sites carry a comment
naming the invariant they protect (a derived radius must pass V1 and V2 against its own plan).
The pre-existing guard tests exercise this without modification, and the `PLANS` table in
`test_blast_radius_invariants.py:121-124` was extended with a plan citing `poetry.lock` so the
guard actually traverses the new path rather than passing vacuously. That is a well-judged
addition: it strengthens an existing invariant test instead of adding a parallel one.

### API extension shape (positive)

Both languages extend the surface additively with a defaulted optional parameter:

```python
def classify_path_token(token: str, *, root_surfaces: Sequence[str] = ()) -> PathTokenKind | None:
```

```powershell
[Parameter(Mandatory = $false)]
[AllowEmptyCollection()]
[string[]] $RootSurface = @()
```

This matches `.claude/rules/general-code-change.md` ("Prefer keyword-style parameters with
defaults"; "Avoid breaking public APIs"). Every pre-existing caller compiles unchanged and
reproduces pre-change behaviour, which the executor pinned with explicit backward-compatibility
tests rather than leaving implicit
(`test_classify_path_token_without_root_surfaces_still_rejects_a_root_surface`, and the
`Get-PathTokenKind -Token 'poetry.lock'` -> `$null` case). Verified by execution.

### Guard ordering (correct, and correctly explained)

The root-surface membership test is placed **before** the separator guard in both languages. This
is necessary — a configured root surface has no separator by construction, so it would be rejected
by the guard — and both implementations carry a comment stating exactly that. The Python comment
additionally explains why explicit equality is used rather than `in`:

> The explicit equality comparison is deliberate: a plain `in` test would fall back to substring
> semantics if a caller ever passed a bare string.

That is a defensive choice worth keeping. The equivalent PowerShell code uses
`[string]::Equals($Token, $surface, [System.StringComparison]::Ordinal)`, giving the same exact,
case-sensitive semantics. Case sensitivity is pinned by test in both languages (`Poetry.Lock`
rejected).

One consequence deserves noting: because the membership test returns before every other guard, a
configured root surface bypasses the leading-separator and extension checks entirely. This is safe
given that `config_root_surfaces` admits only separator-free entries, and it errs toward
over-inclusion, which is the fail-closed direction for this design. No action required.

### Gap 2 — listed-directory semantics in `conflicts` (positive, with an accepted trade-off)

The correction is expressed as three added disjuncts on the existing branch structure
(`scripts/dev_tools/_blast_radius_glob.py:598-641`). The branch selection is untouched and the
glob×glob branch is byte-identical, so the change is a superset by construction — the property the
design most needs. Two small named helpers carry the new logic:

- `_directory_prefix(entry)` -> `entry.rstrip("/") + "/"`, with a docstring explaining that the
  trailing-separator anchor is what prevents `scripts/dev_tools` from appearing to contain
  `scripts/dev_toolsX/a.py`.
- `_prefixes_nest(left, right)`, with a docstring explaining why the test must be two-way (a glob's
  literal prefix may sit above or below the concrete entry's directory).

Extracting these rather than inlining the arithmetic three times is the right call: the anchoring
rule is subtle, it appears in three branches, and each helper's docstring is where the rationale
lives. This satisfies "Simplicity first" and "Reusability" without over-abstracting.

The accepted trade-off is recorded honestly. Because the relation cannot know whether a
wildcard-free entry names a file or a directory, `("config/blast-radius.json", "config/*.yml")`
now reports overlap. The reviewer confirmed this by execution. The F1 spec amendment records it
explicitly as the fail-closed direction rather than leaving a future reader to rediscover it as a
defect. That is the correct disposition for a design whose stated dominant failure mode is
under-reporting.

### Structural splits (positive)

Two modules were extracted to stay within the 500-line limit. Both are genuine relocations:
nine of the ten relocated symbols are byte-identical to their base-revision source, and the tenth
(`_entries_overlap`) differs only by the authorized Gap 2 disjuncts. `_blast_radius_glob.py` groups
exactly the primitives that the PowerShell mirror `BlastRadiusGlob.psm1` already grouped, so the
split makes the two language trees structurally parallel rather than divergent — a real
maintainability gain beyond the line-count relief.

Both new modules are leaves of the import graph and declare that invariant in their module
docstrings. `_blast_radius_glob.py` also declares an explicit `__all__` with a comment explaining
why `_literal_prefix` and `_entries_overlap` keep underscore names while being consumed by a
sibling — the spec and parity corpus name them. That is the right way to make package-internal
export intentional rather than accidental private access.

### Documentation quality (positive)

Module docstrings follow the repository's Purpose / Responsibilities / Usage / Invariants /
Side Effects structure and state scope boundaries negatively as well as positively ("Tokenizing
document text belongs to ...; emitting findings belongs to ..."). Branch and loop comments explain
decision criteria rather than narrating lines, per
`.claude/rules/self-explanatory-code-commenting.md`. The Gap 2 branch comment states not just what
the rules do but why they were added and what breaks without them.

## Test Quality Assessment

### Assertion integrity (the highest-risk dimension) — clean

Enumerating every removed line across the whole `tests/` diff yields exactly two removed
assertions, both of which are the authorized defect-test inversions. No other existing assertion
was weakened, deleted, loosened, or skipped. Full evidence is in
`policy-audit.2026-08-08T13-26.md` section 5.

Both inversions are handled well. Each is renamed to describe the corrected behaviour, each keeps
its Arrange/Act structure, and each carries a rationale comment that cites issue #452 and
explicitly identifies itself as one of the two authorized inversions — so a future reader who finds
a changed assertion in `git blame` can immediately tell it was sanctioned. The Gap 1 inversion
also **strengthens** the test, going from a single count assertion to a count assertion plus a
value assertion (`Should -Be 'poetry.lock'`).

### Anti-vacuity floors raised, not lowered — correct

`MINIMUM_FIXTURE_COUNT` and `$minimumFixtureCount` both move 12 -> 26, matching the on-disk corpus
of 26. Lowering either would have been the natural way to make a shrinking corpus pass; raising
both is the correct direction and keeps the parity suites from passing vacuously.

### Cross-language test symmetry — good practice

The added PowerShell `Context 'Directory containment, added by issue #452'` block carries a comment
stating that each case mirrors a Python case one for one, and the monotonicity block states that
its pair set matches `PREVIOUSLY_OVERLAPPING_ENTRY_PAIRS` in the Python suite. This makes a
divergence between the two implementations fail a test in both languages rather than silently in
one. The reviewer's independent 164,025-pair cross-language comparison found 0 mismatches,
confirming the symmetry the tests are designed to protect.

### Both-argument-order assertions — good practice

Every new overlap case asserts both `(A, B)` and `(B, A)`. Symmetry is a real property of the
relation and asserting it directly is cheaper and clearer than a separate symmetry test. The
reviewer confirmed symmetry independently over the full 164,025-pair sweep (0 violations).

### Fixture design — good

The five added fixtures are add-only and each carries a `description` explaining what it pins and
why. Two design choices stand out:

- `conflict-sibling-prefix-disjoint.json` sets `modules: []` on both radii, with the description
  stating "Both radii declare empty modules so the coarse module map cannot mask the path level."
  This is the correct construction: the issue identified module-map masking as the reason Gap 2 was
  invisible in most realistic cases, so a fixture that did not defeat the mask would not test the
  path level at all.
- `derivation-root-surface-not-configured.json` pairs with the positive case to pin that acceptance
  is driven by configuration, not by a filename pattern.

### Scenario completeness — good

Gap 1 covers positive (three configured surfaces), negative (`README.md`, `pyproject.toml`, bare
identifier), case-sensitivity, and parameter-omitted backward compatibility. Gap 2 covers positive
containment (6 cases), regression guards (4 cases), and monotonicity (4 cases). The negative cases
are the valuable ones here — `pyproject.toml` in particular pins that a recognized extension alone
must not admit a token, which is exactly the loosening a careless implementation would introduce.

### Determinism — clean

No clock read, no RNG, no sleep, no temporary file in any added test. All inputs are literals or
committed fixtures.

## Findings

**Total Blocking: 0. Total Non-blocking: 6.**

| ID | Severity | Summary | Location |
|---|---|---|---|
| NB-1 | Non-blocking | AC line 668 ("PowerShell toolchain passes in a single pass") does not hold literally; Pester exits 2. Unchecked by this review. | `spec.md:668` |
| NB-2 | Non-blocking | Pre-existing test-isolation defect: two hook suites read the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam. Out of scope for #452. | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` |
| NB-3 | Non-blocking | Per-file PowerShell coverage unmeasured for the five changed `.psm1` modules (no `sourcefile` element emitted). Pre-existing, inherited from F1 (#447). | `.claude/lib/blast-radius/*.psm1` |
| NB-4 | Non-blocking | `_blast_radius_thresholds.py` is named by no acceptance criterion; AC 662's stated import graph omits the `validation -> thresholds` edge. | `spec.md:662`, `scripts/dev_tools/_blast_radius_thresholds.py` |
| NB-5 | Non-blocking | Delivery summary reports "100% new-code coverage" (measured 98.28%/96.43%) and a branch figure that is the baseline value (83.58% vs measured 83.60%). | `scripts/dev_tools/_blast_radius_glob.py:222` |
| NB-6 | Non-blocking | Informational: `_literal_prefix` passes a single character to `is_glob_entry`, a conceptual type mismatch. Pre-existing; relocated verbatim. | `scripts/dev_tools/_blast_radius_glob.py:218-220` |

Full detail, verification commands, and adjudication reasoning for each finding are recorded in
`policy-audit.2026-08-08T13-26.md`.

## Best-Practice Observations Worth Preserving

These are not findings. They are patterns in this change set that improved reviewability and are
worth repeating.

1. **Superset-by-construction refactoring.** Expressing each corrected branch as
   `<old predicate> or <new disjunct>` and leaving the branch selection untouched makes the
   fail-closed monotonicity property provable by reading, not only testable by sampling. A reviewer
   can establish the guarantee in one pass over 40 lines.
2. **Encoding the authorization in the code.** Both inverted tests name themselves as one of the
   two authorized inversions in their rationale comments. This survives into `git blame` and
   answers the "was this assertion weakened?" question at the point of the change.
3. **Extending an existing invariant table instead of adding a parallel test.** Adding a
   `poetry.lock`-citing plan to `PLANS` makes the pre-existing V1/V2 self-consistency suite
   exercise the new path, so the guard cannot pass vacuously and no duplicate test is introduced.
4. **Defeating the masking mechanism in the fixture.** Setting `modules: []` so the coarse module
   map cannot hide the path-level result is what makes the non-regression fixture meaningful.
5. **Deriving a set from configuration rather than restating it.** Sourcing the separator-free
   surfaces from `shared_surfaces` removes an entire class of drift defect rather than fixing one
   instance of it.
6. **Disclosing the qualification rather than burying it.** The executor recorded the Pester exit-2
   condition explicitly in its own evidence artifact. That disclosure is what allowed this review to
   adjudicate it quickly instead of treating it as a concealed regression.

## Verdict

**Approve. 0 Blocking findings, 6 Non-blocking findings.**

The implementation is well-factored, symmetric across both language trees, and conservative in the
correct direction. Test changes are add-only apart from the two sanctioned inversions, and the
fixture corpus was strengthened rather than relaxed. The Non-blocking findings are two pre-existing
conditions inherited from earlier deliveries, one acceptance criterion that does not hold literally
as a downstream consequence of one of them, and three documentation-accuracy items. None requires
a code change before merge.
