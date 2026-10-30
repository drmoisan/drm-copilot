# p3t1-windows-smoke-pass9

Timestamp: 2026-10-18T11-39
Command: poetry run python SCRATCH/issue-980-p3t1-windows-smoke.py
EXIT_CODE: 1
Output Summary:   "failure": "AssertionError: Windows parent handle did not deny relocation",;   "passed": false,;   "guarantee": "Cooperating authorized writers; individual atomic publication, not a multi-file transaction or kernel digest CAS."; }

Working directory: .
Started: 2026-10-18T11:39:54.052518+00:00
Duration seconds: 0.996
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
{
  "timestamp": "2026-10-18T11:39:54.991451+00:00",
  "platform": "nt",
  "provider_sha256": "3d4ebf82948d07f6d7404c1b17e6a0caa6c8c0bcce7360b4e46a35486a2ab2ba",
  "source": "packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py",
  "scratch_name": "issue-980-p3t1-windows-smoke-ae4a214846c74011becb7edfcae9d243",
  "checks": [],
  "failure": "AssertionError: Windows parent handle did not deny relocation",
  "passed": false,
  "guarantee": "Cooperating authorized writers; individual atomic publication, not a multi-file transaction or kernel digest CAS."
}
```
