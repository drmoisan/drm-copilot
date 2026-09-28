# Fail-before: Over-reporting Defect (P0-T30, expect-fail)

Timestamp: 2026-09-27T15-14
Command: poetry run python SCRATCH/failbefore-demo.py extraction
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The script exited 1 as expected. The current derive_blast_radius over the plan block B4 text (with the TASKLINE markers replaced by the canonical unchecked task prefix) returns all three over-reported tokens as radius paths: the glob token src/**/*.py, the command-span token src/other.py, and the read-task token src/policy.py.

## Printed output (verbatim; the phase heading's dash rendered as a replacement character on the console)

```text
B4 PLAN TEXT
### Phase 1 ? Demonstration

- [ ] [P1-T1] Update `src/app.py` and the files matched by `src/**/*.py`; run `git add src/other.py`.
- [ ] [P1-T2] Read `src/policy.py` in full.

DERIVED paths=['docs/features/active/failbefore-demo-722/**', 'src/**/*.py', 'src/app.py', 'src/other.py', 'src/policy.py']
OVER-REPORTED present=['src/**/*.py', 'src/other.py', 'src/policy.py'] of ['src/**/*.py', 'src/other.py', 'src/policy.py']
DEFECT the current derivation returns the glob token, the command-span token, and the read-task token as radius paths
```

## Script

The same script SCRATCH/failbefore-demo.py (contract C5) run in extraction mode. Its full text is
recorded in FEATURE/evidence/regression-testing/failbefore-zero-tolerance.2026-09-27T15-14.md; the
extraction branch is reproduced here:

```python
if mode == "extraction":
    # Block B4, with each TASKLINE marker replaced by the canonical unchecked task prefix.
    task_prefix = "- [ ] "
    plan_text = "\n".join(
        [
            "### Phase 1 — Demonstration",
            "",
            task_prefix + "[P1-T1] Update `src/app.py` and the files matched by `src/**/*.py`; run `git add src/other.py`.",
            task_prefix + "[P1-T2] Read `src/policy.py` in full.",
            "",
        ]
    )
    radius = derive_blast_radius(plan_text, "", "failbefore-demo-722", config, computed_at="2026-09-27T00-00")
    over_reported = ["src/**/*.py", "src/other.py", "src/policy.py"]
    present = [token for token in over_reported if token in radius.paths]
    print("B4 PLAN TEXT")
    print(plan_text)
    print(f"DERIVED paths={list(radius.paths)}")
    print(f"OVER-REPORTED present={present} of {over_reported}")
    if present:
        print(
            "DEFECT the current derivation returns the glob token, the command-span token, and the "
            "read-task token as radius paths" if len(present) == len(over_reported) else
            "DEFECT the current derivation returns some of the over-reported tokens as radius paths"
        )
        raise SystemExit(1)
    print("NO-DEFECT none of the over-reported tokens is a radius path")
    raise SystemExit(0)
```

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.
