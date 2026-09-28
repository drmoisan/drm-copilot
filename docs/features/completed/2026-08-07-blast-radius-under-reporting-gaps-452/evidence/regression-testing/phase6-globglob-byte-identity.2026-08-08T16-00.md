# [P6-T6] Glob-by-glob branch byte identity

Timestamp: 2026-08-08T16-00
Task: [P6-T6]

The glob-by-glob branch of `_entries_overlap` must be untouched by the Gap 2 correction. `spec.md`
line 371 records the pair class `any glob×glob pair` as `unchanged | unchanged`, and `spec.md`
line 644 states the branch must be byte-identical to its pre-change form.

The pre-change form is the branch as it stood in `scripts/dev_tools/_blast_radius_conflicts.py`
at the baseline commit, before [P1-T3] moved `_entries_overlap` into
`scripts/dev_tools/_blast_radius_glob.py`.

Command:

```
git show HEAD:scripts/dev_tools/_blast_radius_conflicts.py | sed -n '226,228p' | md5sum
sed -n '314,316p' scripts/dev_tools/_blast_radius_glob.py | md5sum
```

EXIT_CODE: 0

## Output Summary

Pre-change, `scripts/dev_tools/_blast_radius_conflicts.py:226-228` at `HEAD`:

```python
    prefix_a = _literal_prefix(entry_a)
    prefix_b = _literal_prefix(entry_b)
    return prefix_a.startswith(prefix_b) or prefix_b.startswith(prefix_a)
```

Post-change, `scripts/dev_tools/_blast_radius_glob.py:314-316`:

```python
    prefix_a = _literal_prefix(entry_a)
    prefix_b = _literal_prefix(entry_b)
    return prefix_a.startswith(prefix_b) or prefix_b.startswith(prefix_a)
```

MD5 of the three-line block, both sides: `953d83e16cd625f8993a70b602f2e6cc`.

The two blocks are byte-identical, including leading whitespace and line endings. The Gap 2
correction added disjuncts only to the concrete-by-concrete branch ([P6-T4]) and to the two mixed
concrete-by-glob branches ([P6-T5]); the glob-by-glob fallback and its conservative prefix proof
are unmodified. `_literal_prefix`, which the branch calls, is likewise unmodified apart from its
[P1-T3] relocation.

Output Summary: the pre-change and post-change glob-by-glob return statements are identical, with
matching MD5 `953d83e16cd625f8993a70b602f2e6cc` over the three-line block. The branch is unchanged
by this plan.
