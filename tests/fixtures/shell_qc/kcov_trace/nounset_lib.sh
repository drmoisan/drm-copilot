#!/usr/bin/env bash
# Fixture library for the shell-qc kcov-trace regression tests (issue #743). It enables
# strict mode, including nounset, at top level, as the repository's executable scripts do.
# Sourcing it at the top level of bash -c under kcov tracing reproduces the
# BASH_SOURCE unbound-variable failure. It defines nothing else.
set -euo pipefail
