# p3t3-wip-inventory-command

Timestamp: 2026-10-18T14-48
Command: python SCRATCH/issue-980-p3t3-wip-inventory.py
EXIT_CODE: 1
Output Summary:   File "SCRATCH\issue-980-p3t3-wip-inventory.py", line 33, in <module>;     actual = sha256((root / item["path"]).read_bytes()).hexdigest();                             ~~~~^^^^^^^^; TypeError: string indices must be integers, not 'str'

Working directory: .
Started: 2026-10-18T14:48:14.723366+00:00
Duration seconds: 0.069
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
Traceback (most recent call last):
  File "SCRATCH\issue-980-p3t3-wip-inventory.py", line 33, in <module>
    actual = sha256((root / item["path"]).read_bytes()).hexdigest()
                            ~~~~^^^^^^^^
TypeError: string indices must be integers, not 'str'
```
