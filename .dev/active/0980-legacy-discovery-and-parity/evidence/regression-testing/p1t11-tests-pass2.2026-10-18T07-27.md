# p1t11-tests-pass2

Timestamp: 2026-10-18T07-27
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_path_policy.py tests/discovery_runtime/test_path_resolution.py tests/discovery_runtime/test_path_collisions.py tests/discovery_runtime/test_profile_v2.py tests/discovery_runtime/test_profile_dimensions.py tests/discovery_runtime/test_package_contract.py tests/scripts/dev_tools/discovery/test_domain_profile.py --cov=drm_copilot_discovery.path_models --cov=drm_copilot_discovery.path_policy --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t11-coverage.json -q
EXIT_CODE: 1
Output Summary: Coverage JSON written to file SCRATCH/issue-980-p1t11-coverage.json; =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_path_collisions.py::test_conflicting_input_file_and_directory_declarations_fail[project_entry_points-value0]; 1 failed, 537 passed in 175.67s (0:02:55)

Working directory: .
Started: 2026-10-18T07:24:41.792898+00:00
Duration seconds: 176.901
Phase: P1-T11 portable path policy and injected metadata; focused task verification.

## Captured output

```text
........................................................................ [ 13%]
........................................................................ [ 26%]
........................................................................ [ 40%]
......................F................................................. [ 53%]
........................................................................ [ 66%]
........................................................................ [ 80%]
........................................................................ [ 93%]
..................................                                       [100%]
================================== FAILURES ===================================
_ test_conflicting_input_file_and_directory_declarations_fail[project_entry_points-value0] _

field = 'project_entry_points', value = ['docs']

    @pytest.mark.parametrize(
        "field,value",
        [
            ("project_entry_points", ["docs"]),
            ("documentation_roots", ["docs/migration/discovery/scope.yaml"]),
        ],
    )
    def test_conflicting_input_file_and_directory_declarations_fail(
        field: str, value: list[str]
    ) -> None:
        """Schema-valid paths must still describe one coherent filesystem layout."""
        document = profile_document()
        document[field] = value
        profile = parse_profile_v2(json.dumps(document), format="json")
>       policy = PathPolicy(profile, workspace_root="/workspace", metadata=MemoryPaths())
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_path_collisions.py:301:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:179: in __init__
    self._validate_layout()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002BD16357A50>

    def _validate_layout(self) -> None:
        """Reject aliased roots, protected overlaps and sibling output nesting."""
        outputs = tuple(self._locations.items())
        check_path_collisions(self._locations.values())
        # Repeated identical input roots are harmless; alternate spellings are not.
        check_path_collisions(
            sorted(
                set(
                    self._input_directories
                    + self._input_files
                    + tuple(self._locations.values())
                    + self._protected
                )
            )
        )
        forbidden = (
            self._protected
            + self._profile.production_roots
            + self._profile.test_roots
            + self._profile.project_entry_points
        )
        # Protect declared extension schemas even inside a readable documentation root.
        extension_paths = tuple(
            cast("str", cast("dict[str, object]", entry)["path"])
            for entry in self._profile.extension_schemas.values()
        )
        # Each output must be independently separated from implementation/authority.
        for key, path in outputs:
            if _reserved_output(path) or any(
                _overlaps(path, root) for root in forbidden
            ):
>               raise PathPolicyError(
                    "PATH_OUTPUT_OVERLAP",
                    path,
                    "Move artifacts outside protected or production/test paths.",
                )
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_OUTPUT_OVERLAP: 'docs/migration/discovery/acceptance': Move artifacts outside protected or production/test paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:212: PathPolicyError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                  Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py      98      0     34      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py     153      1     82      1    99%   375
-----------------------------------------------------------------------------------------------------------------
TOTAL                                                                   251      1    116      1    99%
Coverage JSON written to file SCRATCH/issue-980-p1t11-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_path_collisions.py::test_conflicting_input_file_and_directory_declarations_fail[project_entry_points-value0]
1 failed, 537 passed in 175.67s (0:02:55)
```
