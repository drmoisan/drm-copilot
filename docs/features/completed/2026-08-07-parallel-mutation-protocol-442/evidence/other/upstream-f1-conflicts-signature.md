# Upstream Contract Re-Verification — F1 `conflicts` Signature ([P1-T4])

Timestamp: 2026-08-08T21-48

Command: `Grep '^def conflicts|^class ConflictResult|^CONFLICT_KINDS' scripts/dev_tools/_blast_radius_conflicts.py`
EXIT_CODE: 0

Command: `Grep 'conflicts|ConflictResult|CONFLICT_KINDS|__all__' scripts/dev_tools/compute_blast_radius.py`
EXIT_CODE: 0

Command: `Read scripts/dev_tools/_blast_radius_conflicts.py` (lines 126-180)
EXIT_CODE: 0

## Defining Module Path

`conflicts` is DEFINED in `scripts/dev_tools/_blast_radius_conflicts.py` at
**line 137**. Verdict: no divergence.

## Re-Export Confirmation

`scripts/dev_tools/compute_blast_radius.py` re-exports it:

- line 35: `from scripts.dev_tools._blast_radius_conflicts import (`
- line 37: `    ConflictResult,`
- line 38: `    conflicts,`
- line 60: `__all__ = [`
- line 63: `    "ConflictResult",`
- line 65: `    "conflicts",`

Both the import list and `__all__` carry `conflicts` and `ConflictResult`.
Verdict: no divergence.

## Exact Signature (three-arity)

```python
def conflicts(
    a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
) -> ConflictResult:
```

(`_blast_radius_conflicts.py:137-139`.)

- Arity: three. Verdict: no divergence.
- Operands `a` and `b` are `BlastRadius` VALUE OBJECTS, not strings.
  Verdict: no divergence.
- `config: Mapping[str, object]` is POSITIONAL AND REQUIRED — it carries no default.
  Its docstring (lines 145-147) states it is the parsed `config/blast-radius.json`,
  that "the relation reads no key from it today", and that "it is validated and kept
  in the signature because the contract is frozen for downstream consumers".
  Verdict: no divergence.
- Non-mapping `config` raises `TypeError`: docstring `Raises:` at lines 154-155
  declares it, and line 157 enforces it via `require_mapping(config, "config")`.
  Verdict: no divergence.

## `ConflictResult` Shape

`@dataclass(frozen=True) class ConflictResult` (`_blast_radius_conflicts.py:94-95`)
carries two fields:

- line 111: `conflict: bool` — the verdict.
- line 112: `reasons: tuple[ConflictReason, ...]` — one entry per triggered level.

`__post_init__` (lines 114-134) enforces two invariants: `conflict` is True exactly
when `reasons` is non-empty (line 124), and `reasons` follow `CONFLICT_KINDS` order
without repeats (lines 129-134). `ConflictReason` is itself
`@dataclass(frozen=True)` (line 61) carrying `kind` and `detail`.

`CONFLICT_KINDS` (`_blast_radius_conflicts.py:48-52`) is the four-member ordered
vocabulary `path_overlap`, `module_overlap`, `shared_surface_overlap`,
`contract_dependency` — matching the F3-owned `conflict_edges[].reason` enum
member set. Verdict: no divergence.

Construction at line 177 is `ConflictResult(conflict=bool(reasons),
reasons=tuple(reasons))`, so one reason is constructed per triggered level in
`CONFLICT_KINDS` order. Verdict: no divergence.

## Empty-Radius Behavior

The `Returns:` docstring at lines 150-152 states: "Two empty radii, and an empty
radius against a non-empty one, do not conflict." Confirmed structurally: every
level is an overlap/intersection test (`_smallest_path_overlap` at line 160 and the
three set intersections at lines 172-175), each of which yields `None` when either
side is empty, so `reasons` stays empty and `conflict` is False.
Verdict: no divergence.

## Chosen F6 Import Path

**F6 imports `conflicts` and `ConflictResult` from the RE-EXPORTING module
`scripts.dev_tools.compute_blast_radius`, not from the private defining module
`scripts.dev_tools._blast_radius_conflicts`.**

Rationale: `_blast_radius_conflicts.py`'s own module docstring designates it a
private implementation detail split out only to respect the 500-line cap, and
`compute_blast_radius.py` declares the public surface via `__all__`. Importing an
underscore-prefixed module across a feature boundary would cross a private seam.
This choice affects only Phase 4 documentation ([P4-T1]) — no Phase 2 engine
function calls `conflicts` itself, because [P2-T2]'s edge-production contract places
the call in the CALLER and the engine consumes the resulting `(int, int)` edge
sequence.

## Output Summary

Overall verdict: **NO DIVERGENCE.** `conflicts` is defined at
`scripts/dev_tools/_blast_radius_conflicts.py:137` with the exact landed three-arity
signature `conflicts(a: BlastRadius, b: BlastRadius, config: Mapping[str, object]) ->
ConflictResult`, is re-exported by `scripts/dev_tools/compute_blast_radius.py` in both
its import list and its `__all__`, takes `BlastRadius` value objects rather than
strings, requires the `config` mapping, and raises `TypeError` on a non-mapping
`config`. `ConflictResult` carries `conflict: bool` plus one `ConflictReason` per
triggered level in `CONFLICT_KINDS` order. Empty radii do not conflict. F6's chosen
import path is the re-exporting public module. The Phase 1 stop rule is NOT triggered.
