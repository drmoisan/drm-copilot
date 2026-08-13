var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"set -euo pipefail","class":"lineCov","hits":"1","order":"1097",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"greet_user() {"},
{"lineNum":"    5","line":"\tlocal name=\"${1:-Demo}\"","class":"lineCov","hits":"1","order":"1096",},
{"lineNum":"    6","line":"\techo \"Hello, ${name}!\"","class":"lineCov","hits":"1","order":"1095",},
{"lineNum":"    7","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "", "date" : "2026-08-12 05:30:03", "instrumented" : 3, "covered" : 3,};
var merged_data = [];
