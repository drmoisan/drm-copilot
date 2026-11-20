# p3t1-reverse-pass11

Timestamp: 2026-10-18T12-12
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_mutation_filesystem.py tests/discovery_runtime/test_mutation_commit.py tests/discovery_runtime/test_mutation_plan.py --no-cov -x -q
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_mutation_filesystem.py::test_native_directory_uses_actual_handle_identity_and_closes[posix]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 18 passed in 0.20s

Working directory: .
Started: 2026-10-18T12:12:19.834872+00:00
Duration seconds: 1.301
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
..................F
================================== FAILURES ===================================
_____ test_native_directory_uses_actual_handle_identity_and_closes[posix] _____

platform = 'posix'
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x0000014AE53C6B10>

    @pytest.mark.parametrize("platform", ["nt", "posix", "unsupported"])
    def test_native_directory_uses_actual_handle_identity_and_closes(
        platform: str, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """
        Both supported directory mechanisms bind identity; other platforms fail closed.
        """
        closed: list[int] = []

        @contextmanager
        def pin(path: Path, *, directory: bool) -> Generator[os.stat_result, None, None]:
            """Model an already pinned Windows handle without calling a native library."""
            yield stat_value(directory=directory)

        monkeypatch.setattr(filesystem, "pin_windows_path", pin)
        monkeypatch.setattr(os, "open", constant(23))
        monkeypatch.setattr(os, "fstat", constant(stat_value(directory=True)))
        monkeypatch.setattr(os, "close", closed.append)
        monkeypatch.setattr(os, "O_DIRECTORY", 0x10000, raising=False)
        monkeypatch.setattr(os, "O_NOFOLLOW", 0x20000, raising=False)
        # Only supported handle providers may produce a directory capability.
        if platform == "unsupported":
            with pytest.raises(OSError, match="requires"):
                with filesystem.open_local_directory(Path("anchor"), platform=platform):
                    pytest.fail("unsupported platform admitted")
        else:
>           with filesystem.open_local_directory(
                Path("anchor"), platform=platform
            ) as directory:

tests\discovery_runtime\test_mutation_filesystem.py:230:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\contextlib.py:141: in __enter__
    return next(self.gen)
           ^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:251: in open_local_directory
    _ordinary(info, directory=True)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

info = os.stat_result(st_mode=16384, st_ino=11, st_dev=7, st_nlink=1, st_uid=0, st_gid=0, st_size=0, st_atime=0, st_mtime=0, st_ctime=0)

    def _ordinary(info: os.stat_result, *, directory: bool) -> None:
        """Reject links, reparse points and nonordinary entries before any byte access."""
        expected = stat.S_ISDIR if directory else stat.S_ISREG
>       if not expected(info.st_mode) or getattr(info, "st_file_attributes", 0) & 0x400:
                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       TypeError: unsupported operand type(s) for &: 'NoneType' and 'int'

packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:72: TypeError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_mutation_filesystem.py::test_native_directory_uses_actual_handle_identity_and_closes[posix]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 18 passed in 0.20s
```
