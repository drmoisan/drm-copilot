# p3t4-pass2-integration

Timestamp: 2026-10-18T16-41
Command: poetry run python SCRATCH\issue-980-p3t4-composed-integration.py
EXIT_CODE: 0
Output Summary:   },;   "passed": 10,;   "failed": 0; }

Working directory: .
Started: 2026-10-18T16:40:37.209411+00:00
Duration seconds: 58.542
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
{
  "evidence": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-composed-integration.2026-10-18T16-41.json",
  "written_at_utc": "2026-10-18T16:41:35.689102+00:00",
  "kind": "composed runtime integration; injected memory OS seams, not new native-platform proof",
  "source_hashes_before": {
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d",
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1",
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py": "f0b02a3f2d685fbf69681e37e89786ec8e1a1991ee10a8447bd25a60ca6efc1c",
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py": "7a0cc867f3ff62760bab97c290207e11744f50f37e9ae9c41bfd5115bb3b9015",
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py": "790613abf92e1355d14332d52cae3d125a5d139e093cfea0d25cae04eb36b164"
  },
  "source_hashes_after": {
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d",
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1",
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py": "f0b02a3f2d685fbf69681e37e89786ec8e1a1991ee10a8447bd25a60ca6efc1c",
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py": "7a0cc867f3ff62760bab97c290207e11744f50f37e9ae9c41bfd5115bb3b9015",
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py": "790613abf92e1355d14332d52cae3d125a5d139e093cfea0d25cae04eb36b164"
  },
  "checks": [
    {
      "name": "dry-run-no-effects",
      "passed": true
    },
    {
      "name": "contract-exclusive-create-exact-bytes",
      "passed": true
    },
    {
      "name": "contract-invalidates-once",
      "passed": true
    },
    {
      "name": "scenario-create-and-collection-cas-exact-bytes",
      "passed": true
    },
    {
      "name": "scenario-has-no-execution-or-evidence",
      "passed": true
    },
    {
      "name": "original-artifacts-preserved",
      "passed": true
    },
    {
      "name": "guard-and-parent-handles-released",
      "passed": true
    },
    {
      "name": "truthful-draft-is-not-complete",
      "passed": true
    },
    {
      "name": "existing-id-collision-preserves-bytes-and-revocation",
      "passed": true
    },
    {
      "name": "source-stable",
      "passed": true
    }
  ],
  "timings": {
    "contract_preview_seconds": 4.516668900003424,
    "contract_commit_seconds": 19.527445300002,
    "scenario_commit_seconds": 28.404962800006615
  },
  "passed": 10,
  "failed": 0
}
```
