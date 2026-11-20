# Gate — the required-field constant is unchanged in both runtimes (Invariant D, AC12)

Timestamp: 2026-08-20T09-53

Task: [P7-T8]

Command: git diff 71aebdb9a1e4752b191b3c9d4e677b807ea6fdec -- scripts/dev_tools/pr_context/verification_evidence.py extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts | (count changed lines naming the constant) ; git grep -n "REQUIRED_FIELDS" -- scripts/dev_tools/pr_context extensions/drm-copilot/src
EXIT_CODE: 0

## No changed line names the constant

Filtering the diff of both parser files to changed lines only (`+` or `-`, excluding the file headers)
and counting those that name the constant yields **0**. A comment line that named the constant was
present in an intermediate revision of the TypeScript parse loop and was reworded before this gate ran,
precisely so the gate would remain discriminating rather than being weakened to accommodate it.

## Both declarations and both membership tests are byte-identical to baseline

```
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:24:export const REQUIRED_FIELDS = ["Timestamp", "Command", "EXIT_CODE"] as const;
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:135:      (REQUIRED_FIELDS as readonly string[]).includes(key) &&
scripts/dev_tools/pr_context/verification_evidence.py:22:REQUIRED_FIELDS: tuple[str, str, str] = ("Timestamp", "Command", "EXIT_CODE")
scripts/dev_tools/pr_context/verification_evidence.py:127:        if key in REQUIRED_FIELDS: 
```

- Member set, Python: `("Timestamp", "Command", "EXIT_CODE")` — three members.
- Member set, TypeScript: `["Timestamp", "Command", "EXIT_CODE"] as const` — the same three members in
  the same order.
- The Python arity-bearing annotation `tuple[str, str, str]` is intact at line 22, so no optional field
  was mislabeled as required.
- The TypeScript constant remains `export`ed with its member set unchanged, so no public surface
  changed.
- Both membership tests are unchanged. The Python line number moved from 107 to 127 and the TypeScript
  line from 111 to 135 because of the additions above them; the LINES THEMSELVES are context lines in
  the diff, not changed lines.

The optional field is carried by a separate constant in each runtime
(`EXPECTED_EXIT_CODE_FIELD`), consulted by a separate branch appended after the required-field block.
No combined accept-list derived from the required-field constant was introduced, exactly so that this
gate stays satisfiable.

Output Summary: Zero changed lines in either parser file name `REQUIRED_FIELDS`. Both declarations
carry the same three members (`Timestamp`, `Command`, `EXIT_CODE`) in the same order, the Python
arity-bearing annotation is intact, the exported TypeScript constant is unchanged, and both membership
tests appear only as diff context. Invariant D holds.
