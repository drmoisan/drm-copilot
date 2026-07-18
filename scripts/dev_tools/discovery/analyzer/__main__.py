"""Module entry point delegating ``python -m ...`` to the CLI ``main``.

Side Effects:
    Delegates process exit to ``cli.main`` under the standard module guard.
"""

from __future__ import annotations

from scripts.dev_tools.discovery.analyzer.cli import main

if __name__ == "__main__":
    raise SystemExit(main())
