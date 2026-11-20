# p3t4-final-index-audit

Timestamp: 2026-10-18T16-42
Command: python SCRATCH/issue-980-p3t4-final-audit.py --pass=pass2 --final
EXIT_CODE: 0
Output Summary:   },;   "minimum_callable": 94.11764705882354,;   "findings": []; }

Working directory: .
Started: 2026-10-18T16:42:12.467326+00:00
Duration seconds: 1.603
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
{
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-final-audit.2026-10-18T16-42.json",
  "paths": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py",
      "sha256": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d",
      "git_blob": "9914ebe3fe91eb286c3a9db3626dd866bfcb8b43",
      "physical_lines": 396,
      "index_git_blob": "9914ebe3fe91eb286c3a9db3626dd866bfcb8b43",
      "index_sha256": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d",
      "index_equals_worktree": true,
      "only_checkout_line_endings_differ": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py",
      "sha256": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1",
      "git_blob": "2655c4d999cc79933cf9e72af2e2f0ebe5e114b1",
      "physical_lines": 231,
      "index_git_blob": "2655c4d999cc79933cf9e72af2e2f0ebe5e114b1",
      "index_sha256": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1",
      "index_equals_worktree": true,
      "only_checkout_line_endings_differ": false
    },
    {
      "path": "tests/discovery_runtime/test_draft_contracts.py",
      "sha256": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296",
      "git_blob": "30c14e3859692f9169dcb606ec7167939bc5dfb0",
      "physical_lines": 431,
      "index_git_blob": "30c14e3859692f9169dcb606ec7167939bc5dfb0",
      "index_sha256": "76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296",
      "index_equals_worktree": true,
      "only_checkout_line_endings_differ": false
    },
    {
      "path": "tests/discovery_runtime/test_draft_scenarios.py",
      "sha256": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108",
      "git_blob": "d84dc26a53d2bb3bf4add5a528ed7149c42d92a3",
      "physical_lines": 378,
      "index_git_blob": "d84dc26a53d2bb3bf4add5a528ed7149c42d92a3",
      "index_sha256": "3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108",
      "index_equals_worktree": true,
      "only_checkout_line_endings_differ": false
    },
    {
      "path": "tests/discovery_runtime/draft_test_support.py",
      "sha256": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236",
      "git_blob": "ffba64c7b5752ee733012d7f2ce5847342d5c0b7",
      "physical_lines": 126,
      "index_git_blob": "ffba64c7b5752ee733012d7f2ce5847342d5c0b7",
      "index_sha256": "90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236",
      "index_equals_worktree": true,
      "only_checkout_line_endings_differ": false
    }
  ],
  "tests": {
    "pass2": {
      "name": "pytest",
      "errors": "0",
      "failures": "0",
      "skipped": "0",
      "tests": "78",
      "time": "710.437",
      "timestamp": "2026-10-18T12:23:32.013007-04:00",
      "hostname": "Megalodon4"
    },
    "reverse2": {
      "name": "pytest",
      "errors": "0",
      "failures": "0",
      "skipped": "0",
      "tests": "78",
      "time": "304.116",
      "timestamp": "2026-10-18T12:35:25.355801-04:00",
      "hostname": "Megalodon4"
    },
    "pass2-contracts": {
      "name": "pytest",
      "errors": "0",
      "failures": "0",
      "skipped": "0",
      "tests": "551",
      "time": "6.317",
      "timestamp": "2026-10-18T12:40:30.656116-04:00",
      "hostname": "Megalodon4"
    }
  },
  "coverage": {
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": {
      "covered_lines": 119,
      "lines": 120,
      "line_percent": 99.16666666666667,
      "covered_branches": 37,
      "branches": 38,
      "branch_percent": 97.36842105263158
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": {
      "covered_lines": 50,
      "lines": 50,
      "line_percent": 100.0,
      "covered_branches": 14,
      "branches": 14,
      "branch_percent": 100.0
    }
  },
  "minimum_callable": 94.11764705882354,
  "findings": []
}
```
