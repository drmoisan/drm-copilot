# Cross-Runtime `RESUME_RE` Parity After B1

Timestamp: 2026-08-08T15-25

Task: [P1-T4]
Working directory: repository root

Command: `grep -n -A5 "^RESUME_RE = re.compile" scripts/dev_tools/parallel_kickoff_contract.py` and `grep -n -A2 "^const RESUME_RE" extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts`

EXIT_CODE: 0

Output Summary: The two runtime patterns carry the identical three-member leading alternation `(?:Every item|Each item|items)` and identical case-insensitivity. The Python pattern sets `flags=re.IGNORECASE`; the TypeScript regex literal carries the `i` flag. Concatenating the three Python raw-string source lines yields a pattern body byte-identical to the TypeScript regex literal body. Parity holds after the [P1-T1] and [P1-T2] widening.

## Side-by-Side Comparison

Python — `scripts/dev_tools/parallel_kickoff_contract.py:78-83`:

```python
RESUME_RE = re.compile(
    r"(?:Every item|Each item|items)\s+resumes?\s+at atomic execution\s+"
    r"from\s+(?:its|their)\s+committed plan-path\s+"
    r"on\s+(?:its|their)\s+own\s+(?:pushed\s+)?feature branch",
    flags=re.IGNORECASE,
)
```

TypeScript — `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:19-20`:

```typescript
const RESUME_RE =
  /(?:Every item|Each item|items)\s+resumes?\s+at atomic execution\s+from\s+(?:its|their)\s+committed plan-path\s+on\s+(?:its|their)\s+own\s+(?:pushed\s+)?feature branch/i;
```

## Explicit Parity Statement

| Property | Python | TypeScript | Identical |
|---|---|---|---|
| Leading alternation | `(?:Every item\|Each item\|items)` | `(?:Every item\|Each item\|items)` | yes |
| Alternation member count | 3 | 3 | yes |
| Verb form | `resumes?` | `resumes?` | yes |
| Possessive alternation | `(?:its\|their)` (twice) | `(?:its\|their)` (twice) | yes |
| Optional `pushed` group | `(?:pushed\s+)?` | `(?:pushed\s+)?` | yes |
| Case-insensitivity | `flags=re.IGNORECASE` | `/i` flag | yes |
| Anchoring | none (applied with `search`) | none (applied with `.test`/`.exec`) | yes |

Concatenated Python pattern body:

```
(?:Every item|Each item|items)\s+resumes?\s+at atomic execution\s+from\s+(?:its|their)\s+committed plan-path\s+on\s+(?:its|their)\s+own\s+(?:pushed\s+)?feature branch
```

TypeScript pattern body:

```
(?:Every item|Each item|items)\s+resumes?\s+at atomic execution\s+from\s+(?:its|their)\s+committed plan-path\s+on\s+(?:its|their)\s+own\s+(?:pushed\s+)?feature branch
```

The two bodies are byte-identical.

## Note on Absence of a Word Boundary

Neither pattern carries a word boundary before the alternation, and both are applied with a substring search (`RESUME_RE.search(invocation)` at `scripts/dev_tools/parallel_kickoff_contract.py:323`). A subject phrase that merely CONTAINS one of the three alternants as a substring therefore matches. This is why the negative test cases in [P3-T7] and [P4-T8] use `Each entry`, which contains none of `Every item`, `Each item`, or `items`.
