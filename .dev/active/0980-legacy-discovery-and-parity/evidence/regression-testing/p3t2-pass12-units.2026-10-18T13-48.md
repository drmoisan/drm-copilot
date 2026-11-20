# p3t2-pass12-units

Timestamp: 2026-10-18T13-48
Command: poetry run python SCRATCH/issue-980-p3t2-units.py forward12 -o addopts=-ra tests/scripts/dev_tools/discovery/test_init_flow.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_domain_neutrality.py tests/discovery_runtime/test_initialization_conflicts.py tests/discovery_runtime/test_initialization.py -x -q --durations=10 --cov=drm_copilot_discovery.init_flow --cov=drm_copilot_discovery.init_io --cov=drm_copilot_discovery.init_projection --cov=scripts.dev_tools.discovery.init_flow --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t2-pass12-coverage.json --cov-fail-under=0
EXIT_CODE: 4294967295
Output Summary: PYTEST_ARGUMENTS: ["-o", "addopts=-ra", "tests/scripts/dev_tools/discovery/test_init_flow.py", "tests/scripts/dev_tools/discovery/test_init_cli.py", "tests/scripts/dev_tools/discovery/test_init_models.py", "tests/scripts/dev_tools/discovery/test_domain_neutrality.py", "tests/discovery_runtime/test_initialization_conflicts.py", "tests/discovery_runtime/test_initialization.py", "-x", "-q", "--durations=10", "--cov=drm_copilot_discovery.init_flow", "--cov=drm_copilot_discovery.init_io", "--cov=drm_copilot_discovery.init_projection", "--cov=scripts.dev_tools.discovery.init_flow", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:SCRATCH/issue-980-p3t2-pass12-coverage.json", "--cov-fail-under=0"]; COVERAGE_REQUEST: ['drm_copilot_discovery.init_flow', 'drm_copilot_discovery.init_io', 'drm_copilot_discovery.init_projection', 'scripts.dev_tools.discovery.init_flow']; ORDER: cheap boundary and fixture cases first; all collected cases retained: 92; ..................................

Working directory: .
Started: 2026-10-18T13:47:27.113698+00:00
Duration seconds: 34.450
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
PYTEST_ARGUMENTS: ["-o", "addopts=-ra", "tests/scripts/dev_tools/discovery/test_init_flow.py", "tests/scripts/dev_tools/discovery/test_init_cli.py", "tests/scripts/dev_tools/discovery/test_init_models.py", "tests/scripts/dev_tools/discovery/test_domain_neutrality.py", "tests/discovery_runtime/test_initialization_conflicts.py", "tests/discovery_runtime/test_initialization.py", "-x", "-q", "--durations=10", "--cov=drm_copilot_discovery.init_flow", "--cov=drm_copilot_discovery.init_io", "--cov=drm_copilot_discovery.init_projection", "--cov=scripts.dev_tools.discovery.init_flow", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:SCRATCH/issue-980-p3t2-pass12-coverage.json", "--cov-fail-under=0"]
COVERAGE_REQUEST: ['drm_copilot_discovery.init_flow', 'drm_copilot_discovery.init_io', 'drm_copilot_discovery.init_projection', 'scripts.dev_tools.discovery.init_flow']
ORDER: cheap boundary and fixture cases first; all collected cases retained: 92
..................................
```
