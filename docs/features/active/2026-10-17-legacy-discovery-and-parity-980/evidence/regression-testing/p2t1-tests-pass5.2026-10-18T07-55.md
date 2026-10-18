# p2t1-tests-pass5

Timestamp: 2026-10-18T07-55
Command: poetry run pytest -q -o addopts= tests/discovery_runtime/test_snapshot.py tests/discovery_runtime/test_snapshot_io.py tests/discovery_runtime/test_repository_reader.py tests/discovery_runtime/test_snapshot_loading.py tests/discovery_runtime/test_snapshot_imports.py --cov=drm_copilot_discovery.snapshot --cov=drm_copilot_discovery.snapshot_io --cov=drm_copilot_discovery.snapshot_loading --cov=drm_copilot_discovery.repository_reader --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t1-coverage.json
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_snapshot_loading.py::test_structured_report_artifacts_use_their_fixed_schemas[migration-report]; FAILED tests/discovery_runtime/test_snapshot_loading.py::test_structured_report_artifacts_use_their_fixed_schemas[required-output-manifest]; 2 failed, 110 passed in 83.82s (0:01:23)

Working directory: .
Started: 2026-10-18T07:53:42.746709+00:00
Duration seconds: 85.029
Phase: P2-T1 immutable snapshots and injected read boundaries; focused task verification.

## Captured output

```text
........................................................................ [ 64%]
...................FF...................                                 [100%]
================================== FAILURES ===================================
_ test_structured_report_artifacts_use_their_fixed_schemas[migration-report] __

kind = 'migration-report'
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize("kind", ["migration-report", "required-output-manifest"])
    def test_structured_report_artifacts_use_their_fixed_schemas(
        kind: str, snapshot_catalog: SchemaCatalog
    ) -> None:
        """Reports with installed schema contracts validate through the same catalog."""
        store, document = memory_workspace()
        path = f"{as_object(document['artifacts'])['reports']}/{kind}.json"
>       put_document(store, path, load_fixture(kind))
                                  ^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_snapshot_loading.py:280:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\schemas\discovery\v2_schema_test_support.py:166: in load_fixture
    yaml.safe_load((ROOT / folder / f"{kind}.{suffix}.yaml").read_text("utf-8"))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\pathlib\_local.py:546: in read_text
    return PathBase.read_text(self, encoding, errors, newline)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\pathlib\_abc.py:632: in read_text
    with self.open(mode='r', encoding=encoding, errors=errors, newline=newline) as f:
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = WindowsPath('./examples/discovery/v2/migration-report.example.yaml')
mode = 'r', buffering = -1, encoding = 'utf-8', errors = None, newline = None

    def open(self, mode='r', buffering=-1, encoding=None,
             errors=None, newline=None):
        """
        Open the file pointed to by this path and return a file object, as
        the built-in open() function does.
        """
        if "b" not in mode:
            encoding = io.text_encoding(encoding)
>       return io.open(self, mode, buffering, encoding, errors, newline)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       FileNotFoundError: [Errno 2] No such file or directory: 'EXTERNAL_PATH'

..\..\..\AppData\Local\Programs\Python\Python313\Lib\pathlib\_local.py:537: FileNotFoundError
_ test_structured_report_artifacts_use_their_fixed_schemas[required-output-manifest] _

kind = 'required-output-manifest'
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize("kind", ["migration-report", "required-output-manifest"])
    def test_structured_report_artifacts_use_their_fixed_schemas(
        kind: str, snapshot_catalog: SchemaCatalog
    ) -> None:
        """Reports with installed schema contracts validate through the same catalog."""
        store, document = memory_workspace()
        path = f"{as_object(document['artifacts'])['reports']}/{kind}.json"
>       put_document(store, path, load_fixture(kind))
                                  ^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_snapshot_loading.py:280:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\schemas\discovery\v2_schema_test_support.py:166: in load_fixture
    yaml.safe_load((ROOT / folder / f"{kind}.{suffix}.yaml").read_text("utf-8"))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\pathlib\_local.py:546: in read_text
    return PathBase.read_text(self, encoding, errors, newline)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\pathlib\_abc.py:632: in read_text
    with self.open(mode='r', encoding=encoding, errors=errors, newline=newline) as f:
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = WindowsPath('./examples/discovery/v2/required-output-manifest.example.yaml')
mode = 'r', buffering = -1, encoding = 'utf-8', errors = None, newline = None

    def open(self, mode='r', buffering=-1, encoding=None,
             errors=None, newline=None):
        """
        Open the file pointed to by this path and return a file object, as
        the built-in open() function does.
        """
        if "b" not in mode:
            encoding = io.text_encoding(encoding)
>       return io.open(self, mode, buffering, encoding, errors, newline)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       FileNotFoundError: [Errno 2] No such file or directory: 'EXTERNAL_PATH'

..\..\..\AppData\Local\Programs\Python\Python313\Lib\pathlib\_local.py:537: FileNotFoundError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\repository_reader.py      83      0     24      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py              116      0     28      1    99%   60->62
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_io.py           186      0     88      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py      202      1    118      7    98%   121->127, 168, 294->306, 297->306, 304->306, 363->360, 444->448
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         587      1    258      8    99%
Coverage JSON written to file SCRATCH/issue-980-p2t1-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_snapshot_loading.py::test_structured_report_artifacts_use_their_fixed_schemas[migration-report]
FAILED tests/discovery_runtime/test_snapshot_loading.py::test_structured_report_artifacts_use_their_fixed_schemas[required-output-manifest]
2 failed, 110 passed in 83.82s (0:01:23)
```
