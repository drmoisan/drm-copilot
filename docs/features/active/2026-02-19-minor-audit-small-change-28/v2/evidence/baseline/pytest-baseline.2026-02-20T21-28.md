Timestamp: 2026-02-20T21-28
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary: ============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.12.1, cov-7.0.0
collected 787 items

tests\scripts\dev_tools\atomic_executor\test_cli.py .................... [  2%]
................................                                         [  6%]
tests\scripts\dev_tools\atomic_executor\test_copilot_backoff.py ...      [  6%]
tests\scripts\dev_tools\atomic_executor\test_copilot_rate_limiter.py ..  [  7%]
tests\scripts\dev_tools\atomic_executor\test_copilot_throttling_classifier.py . [  7%]
...........                                                              [  8%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_bounded_retries.py . [  8%]
                                                                         [  8%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_ordering.py . [  9%]
                                                                         [  9%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_retry_regression.py . [  9%]
                                                                         [  9%]
