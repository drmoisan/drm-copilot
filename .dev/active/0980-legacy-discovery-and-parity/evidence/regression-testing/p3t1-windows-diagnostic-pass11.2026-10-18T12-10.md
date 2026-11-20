# p3t1-windows-diagnostic-pass11

Timestamp: 2026-10-18T12-10
Command: poetry run python SCRATCH/issue-980-p3t1-windows-smoke.py
EXIT_CODE: 0
Output Summary:   "failure": null,;   "passed": true,;   "guarantee": "Cooperating authorized writers; individual atomic publication, not a multi-file transaction or kernel digest CAS."; }

Working directory: .
Started: 2026-10-18T12:10:56.096912+00:00
Duration seconds: 0.920
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
PASS exclusive-create-and-retained-parent
PASS digest-checked-replacement
PASS stale-digest-rejection
PASS exclusive-collision-rejection
PASS authorized-concurrent-exclusion
PASS retained-handle-and-stage-cleanup
{
  "timestamp": "2026-10-18T12:10:56.968576+00:00",
  "platform": "nt",
  "provider_sha256": "db2aca8bf68f64333b509ca12cbe8445d1a0dadc0532064d93581acb1afb422c",
  "source": "packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py",
  "scratch_name": "issue-980-p3t1-windows-smoke-a3716f130fc3410d967b1702d11e278f",
  "checks": [
    {
      "name": "exclusive-create-and-retained-parent",
      "passed": true
    },
    {
      "name": "digest-checked-replacement",
      "passed": true
    },
    {
      "name": "stale-digest-rejection",
      "passed": true
    },
    {
      "name": "exclusive-collision-rejection",
      "passed": true
    },
    {
      "name": "authorized-concurrent-exclusion",
      "passed": true
    },
    {
      "name": "retained-handle-and-stage-cleanup",
      "passed": true
    }
  ],
  "failure": null,
  "passed": true,
  "guarantee": "Cooperating authorized writers; individual atomic publication, not a multi-file transaction or kernel digest CAS."
}
```
