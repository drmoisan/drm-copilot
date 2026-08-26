# Code Review — Issue #559 (epic-orchestrator always-on context footprint)

- Timestamp: 2026-08-26T01-11
- Reviewer: `feature-review`
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- HEAD: `aeac89a7`
- Merge base: `b36179b2`
- Review scope: the full branch diff, 55 files

## Change Inventory

| Group | Files | Nature |
|---|---|---|
| Runtime surface (`.claude/`) | 8 | Content edits: 1 agent, 2 skills, 5 rules |
| Standing instructions | 1 | `CLAUDE.md` tone-policy de-duplication |
| Bundled payload mirrors | 8 | Byte-identity copies of the 8 `.claude/` edits |
| Python tests | 3 | 2 added modules, 1 modified constants module |
| Feature documents | 5 | issue, spec, user story, plan, research |
| Evidence artifacts | 29 | baseline, regression-testing, qa-gates, other |
| Promoted lifecycle record | 1 | `docs/features/potential/promoted/` |

Zero production source files are changed. Zero PowerShell, TypeScript, or C# files are changed.

## Overall Assessment

The change is well-constructed. It is a context-reduction change that reduces the epic-orchestrator
surface from 2,158 always-on lines to 984 — a reduction of 1,174 lines (54.40%) — and the reduction
was independently recomputed by this review rather than accepted from the artifact:

```
wc -l CLAUDE.md .claude/agents/epic-orchestrator.md \
      .claude/skills/{policy-compliance-order,epic-orchestrate,acceptance-criteria-tracking}/SKILL.md \
      .claude/rules/{general-code-change,general-unit-test,quality-tiers,tonality}.md
-> 984 total
```

Pre-change components sum to 2,158 (59 + 162 + 936 + 316 + 685), matching the spec's measured
baseline exactly.

The dominant quality signal is that the change spends context to save context and keeps the ledger
honest: F6 is a net addition of 17 lines to `epic-orchestrate/SKILL.md` and 10 lines to
`orchestrate/SKILL.md`, and the child-side statement is deliberately capped at ten lines by an
assertion in the test rather than by convention alone. That is the right instinct for this kind of
change.

One Blocking defect was found, in a new test module. Details are in the Policy Audit under B1 and
restated below in the test-quality section.

## Design Principles (`general-code-change.md`)

### Simplicity first — PASS

Every one of the six sub-features is the smallest edit that achieves its stated effect. F1 and F2
are pure deletions with no replacement text, as the issue directs. F3 is a single frontmatter
insertion at the top of each of five files with no body change. The diff confirms this
mechanically: each of the five rules files has exactly one hunk, it begins at line 1 of the
original, and it removes no original line.

F4's three replacements resolve to concrete authorities rather than to another relative citation:
`spec.md §6` becomes `validate_epic_orchestrator_state_text` with its implementing module path, and
`spec.md §4 and §10` becomes two named headings in a file that exists. This is the correct direction
— a citation that names a validator function is checkable in a way a section number is not.

### Reusability — PASS with one observation

Both new test modules define their own `read_text` and `normalize_whitespace` helpers with identical
bodies (`test_claude_rules_frontmatter.py:98-132` and
`test_epic_bounded_child_return_contract.py:91-128`). The duplication is small and deliberate: the
repository's contract-test convention keeps each module self-contained, and the existing
`test_epic_run_kickoff_discovery_contract.py` follows the same pattern. Not a finding, but if a
third module joins them, a shared `tests/scripts/dev_tools/_claude_text_support.py` would be
warranted.

### Extensibility — PASS

`assert_rule_paths_reach(rule_file_name, targets)` in `test_claude_rules_frontmatter.py:276-304` is
the right factoring: the three scope-coverage tests differ only in the rule read and the surfaces it
must reach, and each supplies its own tuple constant. Adding a fourth scoped rule is one constant
plus one three-line test.

`section_body`, `heading_order`, and `blockquote_block` in the second module are general Markdown
primitives rather than assertions welded to one file, so the module extends to further sections
without new parsing code.

### Separation of concerns — PASS

Parsing (`parse_frontmatter`, `string_sequence`, `section_body`) is cleanly separated from I/O
(`read_text`) and from assertion. `parse_frontmatter` explicitly isolates the untyped
`yaml.safe_load` boundary so callers work against `dict[str, object]`, which is the reason the
module type-checks cleanly under `pyright` without a single `type: ignore`.

## Error Handling

`parse_frontmatter` (`test_claude_rules_frontmatter.py:135-167`) returns `None` rather than raising
for three distinct malformed conditions — no opening fence, no closing fence, and a non-mapping
block — and the docstring states why: "carries no usable frontmatter" is the condition callers test
for. This is the correct call for a contract test, because a raise would report a stack trace where
the intended output is a named defect. `read_text` deliberately does not catch `OSError`, so a
missing file fails loudly. Both choices are documented in the docstrings.

`is_unconditional` (lines 225-248) makes a subtle and correct judgment: a file with no parseable
frontmatter and a file whose `paths:` carries `**` are treated as the same condition, because
neither constrains when the runtime injects the rule. The module docstring (lines 10-14) records the
reasoning explicitly — "Counting only explicit `**` entries would let an unscoped file hide inside a
four-file expectation and would make this module pass before the fix landed." That is precisely the
fail-before reasoning a structural regression test needs, and it is stated rather than assumed.

## Naming

All names are descriptive and follow `snake_case` for functions and locals,
`SCREAMING_SNAKE_CASE` for module constants. `CHECKPOINT_WRITER_SURFACES`,
`PLAN_GATE_DISPATCHERS`, `BLAST_RADIUS_CONFIG_SURFACES`, and `DELIBERATE_UNCONDITIONAL_RULES` each
name what the constant is for rather than what it contains, and each carries a comment stating why
its members belong to it. No abbreviation outside the standard set is used.

## Commenting (`self-explanatory-code-commenting.md`)

Strong. Comments explain *why*, not *what*. Representative examples:

- `test_claude_rules_frontmatter.py:251-258` — `globs_cover` documents that `fnmatch` is chosen
  because its `*` crosses path separators, states that this is "slightly permissive at a segment
  boundary", and names the rejected alternative ("reimplementing the runtime's own glob engine,
  which the repository does not expose"). Recording the known imprecision and its cost is better
  practice than silently choosing the permissive matcher.
- `test_epic_bounded_child_return_contract.py:15-19` — the module docstring states that whitespace
  normalization is "mandatory here, not stylistic" and gives the failure mode it prevents: a
  line-oriented phrase search "silently returns zero matches once the target file reflows... which
  converts the assertion into a no-op that can no longer fail." This is the exact class of defect
  `.claude/rules/plan-acceptance-gates.md` G6 exists to catch, addressed at the source.
- `parallel_orchestrator_surface_expectations.py:105-119` — the rewritten block comment records what
  was re-baselined, why the change was legitimate, and why the pin was re-baselined rather than
  deleted ("it remains live as a guard: an unintended future edit to either file still fails
  loudly... keeps this control owned by its original feature rather than silently dropped by an
  unrelated one"). This is the right record for a cross-feature contention point.

No commented-out code, no redundant restatement of the following line, no TODO or FIXME added.

## Test Quality

### What is done well

**Wrap tolerance is applied consistently and for a stated reason.** Both modules normalize
whitespace across adjacent lines before searching, and every prose assertion goes through
`contains_phrase` or a pre-normalized haystack. `blockquote_block`
(`test_epic_bounded_child_return_contract.py:199-234`) goes further and collects the whole
contiguous blockquote run rather than a single line, so the kickoff-line assertion survives the
directive being re-wrapped across several quoted lines. This directly addresses the "gate that
cannot fail" class.

**Assertions are specific rather than existential.** Field presence is checked as an inline-code
token (`` f"`{field}`" ``) rather than as a bare word, so "a prose word that happens to match a
field name cannot satisfy the assertion" (line 338). Heading position is asserted as an ordering
over the document's heading sequence (`kickoff_index < bounded_index < model_index`) rather than as
a line-number comparison, so it survives edits elsewhere in the file.

**Failure messages name the whole gap.** Six separate tests accumulate every defect into a list and
assert on the list rather than returning at the first offender, with the reasoning stated in the
docstring or a comment each time ("so one run reports the whole gap rather than only its first
entry"). This materially reduces remediation round-trips.

**Determinism infrastructure is respected.** No `sleep`, no `Date.now()` analogue, no wall-clock
read, no unseeded randomness, no temporary file, no external service. `rule_files()` sorts its glob
output explicitly "so failure messages are stable between runs and between machines".

**Ordering independence.** Verified by running the selection under `-p no:randomly`, and again in
the default randomized order during the executor's full run; both produce the same result set.

### Blocking defect — B1

`claude_markdown_files()` (`test_claude_rules_frontmatter.py:307-327`) enumerates the filesystem
with `CLAUDE_ROOT.rglob("*.md")` and excludes only `agent-memory`
(`EXCLUDED_CLAUDE_SUBDIRS`, line 37). It does not exclude `.claude/worktrees/`, which is this
repository's standard agent-worktree location and currently holds sixteen full repository copies.
`test_no_unqualified_spec_section_citation_under_claude` (lines 479-499) therefore reports every
nested worktree's `docs/features/**` `spec.md §` occurrences as offenders and fails on the primary
development checkout, while passing from inside a worktree.

This was reproduced empirically against a synthetic tree using the module's own helpers. Full
evidence is in the Policy Audit.

Two aggravating factors make this worth blocking on rather than deferring:

1. The exclusion list already demonstrates awareness of the problem class — it excludes
   `agent-memory` precisely because that subtree "is gitignored and machine-local, so its content
   varies per workstation" (line 35-36). `.claude/worktrees` and `.claude/state` are gitignored on
   the two adjacent lines of the same `.gitignore` (lines 21, 67-68) and were not excluded.
2. This change's own evidence correctly diagnoses the tolerated failing test as an instance of
   exactly this defect — "`list_scoped_files` enumerates the filesystem rather than consulting git,
   so a gitignored, untracked, machine-local state file enters the repo-side set". Deferring that
   instance while introducing a new one is inconsistent.

Recommended fix, in order of preference:

```python
# Preferred: enumerate from git, so untracked and gitignored trees cannot enter the set.
#   git ls-files -- .claude
# Minimal: extend the existing exclusion set.
EXCLUDED_CLAUDE_SUBDIRS = frozenset({"agent-memory", "worktrees", "state"})
```

The minimal fix restores determinism for the observed cases. The git-backed fix removes the class.

### Non-blocking test observations

- **N8 — file size.** `test_claude_rules_frontmatter.py` is 499 lines against the 500-line ceiling in
  `.claude/rules/general-code-change.md`. It passes, but with one line of headroom. Splitting the
  agent-preload tests (lines 330-348, 437-476) into a sibling module would give both files room and
  would separate two genuinely different subjects — rule scoping and agent preloads.
- **N10 — defaulted test parameter.**
  `test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions(agent_path: Path = EPIC_ORCHESTRATOR_AGENT)`
  (lines 237-254) exists only so Black's exploded form keeps the `def` line under 88 characters after
  the E501 suppression was removed. The mechanism is sound — pytest's `getfuncargnames` excludes
  parameters carrying defaults, so no fixture is requested, and the docstring says so — but the
  signature's motivation is line length rather than a dependency seam, and no caller ever supplies
  the argument. A shorter function name with a plain no-arg signature would read more directly.
  This is a style preference, not a defect; the executor's rejection of the two worse alternatives
  (keeping an unauthorized suppression, or dropping the return annotation) was correct.
- **Weak assertion.** `assert "discard" in normalized.lower()` (line 360) and the matching assertion
  at line 428 are substring checks on a single common word. They would be satisfied by prose that
  mentions discarding in an unrelated sense. The surrounding assertions in the same test (the three
  re-derivation command literals and the cache-doctrine path) carry the real weight, so this is a
  minor point, but a phrase such as `"is discarded"` would be tighter.

## Runtime Surface Content Review

### F1, F2, F4 — PASS

The Startup Protocol is now three contiguous steps that begin with the checkpoint read, which is
the only step that was ever doing work. Renumbering is correct and no continuation line was
disturbed. The `## Prerequisites` block deletion leaves exactly one blank line before
`## Epic Dependency Manifest` (verified with `cat -A`).

The `skills:` reduction to three is correct and safe. The claim that no prose in either epic file
references a removed skill was verified independently (`git grep -n -F` over the three names across
both files returns exit 1). The concern that removing a preload might break the `epic` route's
`required_skills` receipt obligation was also checked and is unfounded: that gate lives in
`scripts/dev_tools/_orchestrator_state_routing.py:583-585`, is keyed on the checkpoint's own
`route_id`, and the `epic` route already lists `orchestrate`, `pr-context-artifacts`, and
`pr-base-branch-merge-base` — three skills that were never preloaded on this agent. Preload and
receipt obligation are independent, exactly as the spec argues at line 123.

### F3 — PASS, with the scoping caveat correctly disclosed

The five frontmatter blocks are well-formed, and the glob sets are defensible against each rule's
own scope statement. The `orchestrator-state.md` list names all ten checkpoint-writer surfaces
literally rather than relying on activation via the runtime-written checkpoint artifact, which is
the mitigation the spec's own risk table prescribes.

Two observations, neither a defect:

- Whether path-scoped activation actually reaches an agent that *is* one of those files, rather than
  one that *edits* it, is not verifiable in-repository. The spec discloses this
  ("no repository code reads `paths:` frontmatter from `.claude/rules/`") and correctly restricts
  every acceptance criterion to a structural assertion. The ten literal entries are belt-and-braces
  over the first glob, which already matches the checkpoint artifact itself.
- `benchmark-baselines.md`'s glob set matches zero current files, because `scripts/benchmarks/` does
  not exist and no tracked `baseline*.json` exists. This is recorded in the plan prose as the
  criterion requires and is the correct outcome under that rule's own scope statement — the rule
  governs a subsystem the repository does not currently have.

Recorded as N9: the newly scoped `parallel-orchestration.md` is no longer auto-injected for the epic
surface, and `epic-orchestrate/SKILL.md:143-149` now cites it for the cache doctrine. Citing rather
than restating is the whole point of the change, and the agent can read it on demand, so this is
consistent rather than contradictory. It is recorded so a later reader does not mistake it for an
oversight.

### F5 mechanical half — PASS, with N2

The de-duplication is correct and the reservation held: no threshold literal and no stage count
appears anywhere in the `CLAUDE.md` diff, `AGENTS.md` is untouched, and `.github/instructions/` is
untouched.

N2: `CLAUDE.md:11` now says the tone rules are "stated once in `.claude/rules/tonality.md`, which
the runtime loads as the authoritative source", while `CLAUDE.md:13` retains "The full tone policy
is defined in `.github/copilot-instructions.md` and
`.github/instructions/tonality.instructions.md`. Those files are authoritative." Two adjacent
paragraphs now each nominate an authoritative source. Line 13 is pre-existing and outside F5's
scope, so this is not a regression the change introduced alone, but the new sentence makes the
tension visible where it previously was not. A one-line precedence statement would resolve it.

### F6 — PASS

The bounded return contract is the strongest part of the change. Three details are worth noting:

1. The shape is eight fields, not the six the issue required at minimum. The two extra fields,
   `branch_name` and `worktree_path`, are justified in place: they "spare the parent a re-parse of
   porcelain output per child before `git worktree remove`". Critically, the same sentence states
   they "are not authoritative and are re-derived like every other field", which prevents the
   convenience fields from quietly becoming a second source of truth. That is the right guard.
2. The section cites the cache doctrine rather than restating it, which is the behavior a
   context-reduction change should exhibit.
3. The child-facing half reaches the child through two independent paths — the kickoff blockquote in
   `epic-orchestrate/SKILL.md:118` and the `## Epic Mode Bounded Return` section in
   `orchestrate/SKILL.md:99-108` — and both are asserted by tests. Relying on the kickoff line alone
   would have left the constraint invisible to a child reading only its own skill.

The child-side section is 10 total lines and 6 non-blank body lines, within the asserted cap.

## Cross-Feature Contention — `parallel_orchestrator_surface_expectations.py`

The file is owned by concurrently-active feature 441. Decision 1 of the plan re-baselines the two
digest constants in place, keeps the consuming test live, and rewrites the block comment.

Verified: the diff touches exactly the two constants and the comment above them. No other line in
the 339-line module changes. The pins match the committed bytes exactly:

```
git cat-file -p aeac89a7:.claude/agents/epic-orchestrator.md | sha256sum
5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec   (pin: identical)

git cat-file -p aeac89a7:.claude/skills/epic-orchestrate/SKILL.md | sha256sum
d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b   (pin: identical)
```

Worktree bytes match the committed bytes for both files, so no line-ending rewrite invalidated the
pin — the risk the spec's own risk table flagged. `test_frozen_epic_surface_matches_pinned_baseline_digest`
passes.

The choice to re-baseline rather than delete is the right one. Deleting would have removed a live
guard and silently dropped a control owned by another feature; re-baselining keeps the guard armed
and leaves the control with its owner.

N3: the consuming test itself was correctly not modified, but its assertion message still reads
"must be byte-identical to its **pre-feature** state"
(`test_parallel_orchestrator_surface_contracts.py:482-485`). After the re-baseline that message
misdescribes what the pin now asserts. A future maintainer who trips this test reads a message that
does not point at the rationale recorded in the expectations module. Worth a one-line message update
when feature 441 next touches that file.

## Bundled Payload Mirrors

All eight pairs verified byte-identical by direct comparison, independent of the test suite:

```
diff -q .claude/<path> extensions/drm-copilot/resources/claude-customizations/.claude/<path>
-> no output for all 8 pairs
```

`CLAUDE.md` correctly has no mirror: `SCOPED_ROOTS` in the push-down contract test is
`(Path(".claude"),)` only, so a root-level `CLAUDE.md` is out of the bundle's scope. There is no
missing ninth mirror.

The rollout note is accurate and worth preserving: a repository-side `resources/` edit does not
change what an installed extension pushes down until the extension is rebuilt and reinstalled.

## Dependencies

No dependency added. `yaml` is imported by the new frontmatter module and `PyYAML = ">=6.0"` is
already declared at `pyproject.toml:19`.

## I/O Boundaries

Both new modules confine I/O to a single two-line `read_text` helper plus directory globbing. Every
parsing and matching function is pure and separately testable. No temporary file is created. No
network or database access occurs.

## Summary of Findings

| Severity | Count |
|---|---|
| **Blocking** | **1** |
| Non-blocking | 10 |

Blocking: **B1** — `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:37,307-327,479-499`.
Non-blocking: **N1**–**N10**, enumerated in `policy-audit.2026-08-26T01-11.md`.
