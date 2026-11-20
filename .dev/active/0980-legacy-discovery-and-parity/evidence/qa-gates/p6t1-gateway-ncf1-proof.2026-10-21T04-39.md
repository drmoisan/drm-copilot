# NCF1 focused proof

Timestamp: 2026-10-21T04-39

Command: `SCRATCH/issue-980-p6t1-gateway-ncf1-proof.py`

EXIT_CODE: 0

Output Summary: 26 controls passed; 22 new node IDs and four retained IDs are recorded exactly.

Both fresh executable bodies have 100% line and branch coverage. The low-level store guard is unchanged. The only retained test change is its approved nested resolver stub.

```json
{
  "named_bodies": {
    "_canonical_state_location": {
      "declaration_line": 359,
      "body_first_line": 368,
      "body_last_line": 375,
      "executable_ast_sha256": "430948c1436e8e65267cd0905758be49724b9f83bd6b9e6b51894c2a36942a5e",
      "covered_lines": 6,
      "statements": 6,
      "line_percent": 100.0,
      "covered_branches": 2,
      "branches": 2,
      "branch_percent": 100.0,
      "missing_lines": [],
      "missing_branches": [],
      "executed_body_lines": [
        368,
        371,
        372,
        373,
        374,
        375
      ],
      "executed_body_branches": [
        [
          373,
          374
        ],
        [
          373,
          375
        ]
      ]
    },
    "installed_local_io": {
      "declaration_line": 378,
      "body_first_line": 395,
      "body_last_line": 423,
      "executable_ast_sha256": "2b06807bec7f03997d783264e2f00342ef4733d1b21aa6037b73a785e0f8ea46",
      "covered_lines": 9,
      "statements": 9,
      "line_percent": 100.0,
      "covered_branches": 4,
      "branches": 4,
      "branch_percent": 100.0,
      "missing_lines": [],
      "missing_branches": [],
      "executed_body_lines": [
        395,
        396,
        397,
        398,
        399,
        400,
        405,
        412,
        418
      ],
      "executed_body_branches": [
        [
          396,
          397
        ],
        [
          396,
          398
        ],
        [
          398,
          399
        ],
        [
          398,
          400
        ]
      ]
    }
  },
  "file_coverage": {
    "fresh_26_controls": {
      "covered_lines": 60,
      "statements": 138,
      "line_percent": 43.47826086956522,
      "covered_branches": 8,
      "branches": 40,
      "branch_percent": 20.0,
      "missing_lines": [
        65,
        97,
        105,
        106,
        109,
        110,
        140,
        142,
        143,
        144,
        145,
        146,
        151,
        153,
        154,
        155,
        160,
        161,
        178,
        184,
        185,
        199,
        200,
        208,
        212,
        213,
        214,
        215,
        219,
        220,
        221,
        222,
        223,
        238,
        239,
        240,
        241,
        243,
        244,
        252,
        253,
        254,
        269,
        270,
        278,
        280,
        285,
        293,
        301,
        303,
        311,
        312,
        313,
        314,
        315,
        316,
        318,
        319,
        321,
        322,
        323,
        324,
        325,
        326,
        327,
        328,
        329,
        330,
        332,
        333,
        334,
        335,
        336,
        337,
        338,
        339,
        340,
        341
      ],
      "missing_branches": [
        [
          64,
          65
        ],
        [
          128,
          140
        ],
        [
          142,
          143
        ],
        [
          142,
          161
        ],
        [
          144,
          145
        ],
        [
          144,
          146
        ],
        [
          153,
          154
        ],
        [
          153,
          160
        ],
        [
          178,
          184
        ],
        [
          178,
          185
        ],
        [
          212,
          213
        ],
        [
          212,
          221
        ],
        [
          213,
          214
        ],
        [
          213,
          215
        ],
        [
          221,
          222
        ],
        [
          221,
          223
        ],
        [
          243,
          244
        ],
        [
          243,
          254
        ],
        [
          270,
          278
        ],
        [
          270,
          280
        ],
        [
          313,
          -303
        ],
        [
          313,
          314
        ],
        [
          323,
          324
        ],
        [
          323,
          325
        ],
        [
          326,
          327
        ],
        [
          326,
          328
        ],
        [
          334,
          335
        ],
        [
          334,
          337
        ],
        [
          337,
          338
        ],
        [
          337,
          339
        ],
        [
          339,
          340
        ],
        [
          339,
          341
        ]
      ]
    },
    "retained_baseline": {
      "covered_lines": 130,
      "statements": 131,
      "line_percent": 99.23664122137404,
      "covered_branches": 37,
      "branches": 38,
      "branch_percent": 97.36842105263158,
      "missing_lines": [
        145
      ],
      "missing_branches": [
        [
          144,
          145
        ]
      ]
    },
    "qualified_fresh_plus_unchanged_history": {
      "covered_lines": 137,
      "statements": 138,
      "line_percent": 99.27536231884058,
      "covered_branches": 39,
      "branches": 40,
      "branch_percent": 97.5,
      "missing_lines": [
        145
      ],
      "missing_branches": [
        [
          144,
          145
        ]
      ]
    },
    "retained_only_lines": [
      65,
      97,
      105,
      106,
      109,
      110,
      140,
      142,
      143,
      144,
      146,
      151,
      153,
      154,
      155,
      160,
      161,
      178,
      184,
      185,
      199,
      200,
      208,
      212,
      213,
      214,
      215,
      219,
      220,
      221,
      222,
      223,
      238,
      239,
      240,
      241,
      243,
      244,
      252,
      253,
      254,
      269,
      270,
      278,
      280,
      285,
      293,
      301,
      303,
      311,
      312,
      313,
      314,
      315,
      316,
      318,
      319,
      321,
      322,
      323,
      324,
      325,
      326,
      327,
      328,
      329,
      330,
      332,
      333,
      334,
      335,
      336,
      337,
      338,
      339,
      340,
      341
    ],
    "retained_only_branches": [
      [
        64,
        65
      ],
      [
        128,
        140
      ],
      [
        142,
        143
      ],
      [
        142,
        161
      ],
      [
        144,
        146
      ],
      [
        153,
        154
      ],
      [
        153,
        160
      ],
      [
        178,
        184
      ],
      [
        178,
        185
      ],
      [
        212,
        213
      ],
      [
        212,
        221
      ],
      [
        213,
        214
      ],
      [
        213,
        215
      ],
      [
        221,
        222
      ],
      [
        221,
        223
      ],
      [
        243,
        244
      ],
      [
        243,
        254
      ],
      [
        270,
        278
      ],
      [
        270,
        280
      ],
      [
        313,
        -303
      ],
      [
        313,
        314
      ],
      [
        323,
        324
      ],
      [
        323,
        325
      ],
      [
        326,
        327
      ],
      [
        326,
        328
      ],
      [
        334,
        335
      ],
      [
        334,
        337
      ],
      [
        337,
        338
      ],
      [
        337,
        339
      ],
      [
        339,
        340
      ],
      [
        339,
        341
      ]
    ]
  }
}
```

Only the two named changed/new bodies claim fresh coverage. Qualified whole-file coverage composes exact AST-identical unchanged ranges with retained proof; it is not a new whole-file test run.
