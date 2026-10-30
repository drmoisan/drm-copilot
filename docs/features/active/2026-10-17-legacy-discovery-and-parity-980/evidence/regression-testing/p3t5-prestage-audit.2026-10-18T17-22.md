# p3t5-prestage-audit

Timestamp: 2026-10-18T17-22
Command: python SCRATCH/issue-980-p3t5-final-audit.py
EXIT_CODE: 0
Output Summary:   },;   "minimum_callable": 100.0,;   "findings": []; }

Working directory: .
Started: 2026-10-18T17:22:30.959310+00:00
Duration seconds: 1.300
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
{
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-prestage-audit.2026-10-18T17-22.json",
  "paths": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py",
      "sha256": "98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18",
      "git_blob": "ff34edd78af35c96c248afbe1bef2eeba87fa428",
      "physical_lines": 343
    },
    {
      "path": "tests/discovery_runtime/test_evidence_linking.py",
      "sha256": "8bb7317277b9c76236821e4adf6399f3acbcf9d2bdd77ba9f62b2ef42998a392",
      "git_blob": "41ec2ff1ade98dbd310a6ab2b2192e238d34965b",
      "physical_lines": 480
    },
    {
      "path": "tests/discovery_runtime/test_evidence_payloads.py",
      "sha256": "c53705640d294f496f7d6b1ca663d761b55baf5b9bcba7fee43e7f5fe6c85e14",
      "git_blob": "5cb36ba8ede51e5352a1a83d3124ca2173ed8576",
      "physical_lines": 354
    },
    {
      "path": "tests/discovery_runtime/evidence_test_support.py",
      "sha256": "bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3",
      "git_blob": "c27690845012691a680cdadb5f4646ae8ecee1e4",
      "physical_lines": 117
    }
  ],
  "tests": {
    "pass1": {
      "tests": "61",
      "failures": "0",
      "errors": "0",
      "skipped": "0",
      "time": "130.162",
      "timestamp": "2026-10-18T13:17:42.780862-04:00"
    },
    "reverse1": {
      "tests": "61",
      "failures": "0",
      "errors": "0",
      "skipped": "0",
      "time": "51.960",
      "timestamp": "2026-10-18T13:19:55.618797-04:00"
    },
    "pass1-contracts": {
      "tests": "543",
      "failures": "0",
      "errors": "0",
      "skipped": "0",
      "time": "26.337",
      "timestamp": "2026-10-18T13:20:48.941475-04:00"
    }
  },
  "coverage": {
    "packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": {
      "covered_lines": 108,
      "lines": 108,
      "line_percent": 100.0,
      "covered_branches": 38,
      "branches": 38,
      "branch_percent": 100.0
    }
  },
  "minimum_callable": 100.0,
  "findings": []
}
```
