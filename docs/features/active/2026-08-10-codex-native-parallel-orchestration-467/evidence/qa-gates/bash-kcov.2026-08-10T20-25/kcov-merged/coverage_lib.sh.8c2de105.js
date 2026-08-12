var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"set -euo pipefail","class":"lineCov","hits":"1","order":"765",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"greet_user() {"},
{"lineNum":"    5","line":"\tlocal name=\"${1:-Demo}\"","class":"lineCov","hits":"1","order":"764",},
{"lineNum":"    6","line":"\techo \"Hello, ${name}!\"","class":"lineCov","hits":"1","order":"763",},
{"lineNum":"    7","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-08-11 23:03:35", "instrumented" : 3, "covered" : 3,};
var merged_data = [];
