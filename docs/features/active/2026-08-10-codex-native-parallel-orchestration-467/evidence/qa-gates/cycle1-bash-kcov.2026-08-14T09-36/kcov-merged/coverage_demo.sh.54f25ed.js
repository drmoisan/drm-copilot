var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"set -euo pipefail","class":"lineCov","hits":"1","order":"4",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"SCRIPT_DIR=\"$(cd \"$(dirname \"${BASH_SOURCE[0]}\")\" && pwd)\"","class":"lineCov","hits":"1","order":"3",},
{"lineNum":"    5","line":"# shellcheck disable=SC1091"},
{"lineNum":"    6","line":"source \"${SCRIPT_DIR}/coverage_lib.sh\"","class":"lineCov","hits":"1","order":"2",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"greet_user \"${1:-Demo}\"","class":"lineCov","hits":"1","order":"1",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-08-15 00:25:28", "instrumented" : 4, "covered" : 4,};
var merged_data = [];
