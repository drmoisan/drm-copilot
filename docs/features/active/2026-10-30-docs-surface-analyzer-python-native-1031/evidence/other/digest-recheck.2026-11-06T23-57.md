# Digest recheck against the 1022 whole-file architecture-component digest (final QA loop)

Timestamp: 2026-11-06T23-57
Command: `sh SCRATCH/issue-1031-pwsh.sh issue-1031-x-digest.ps1`, run in the final QA loop on the branch head that carries the last Python edit
EXIT_CODE: 0
Output Summary: 24 native architecture-component elements. 22 have a 1022 scanner element and all 22 digests are equal, with line_range null on both sides. The scanner emits no element for the other 2 inputs (it rejects them with PYTHON_LEXER_UNCLASSIFIED and PYTHON_ENCODING_UNSUPPORTED); each equals the whole-file Get-DocsDeclarationSha256 recomputation. 0 mismatches. The values equal the post-Phase-2 run.

## Method

The same direct comparison as the post-Phase-2 record: one request over the inputs of `python-surface-corpus.json` and `python-native-corpus.json`, the real helper run once with -I -B -X utf8, the response validated and converted, the native row and the 1022 scanner row of python-architecture run through `Invoke-DocsAnalyzer`, and `source_sha256` compared per `element_id`. Every row is also recomputed with `Get-DocsDeclarationSha256 -LineRange $null`, the function `New-DocsSurfaceElement` calls.

## Compared values

| Path | Native digest | 1022 scanner digest | Whole-file recomputation | Equal |
|---|---|---|---|---|
| native/deep_brackets.py | f1b20e4ab052db0fc9651124ddeab0b8a2197dbeca0093be8acf67cd5888fa06 | no-scanner-element | f1b20e4ab052db0fc9651124ddeab0b8a2197dbeca0093be8acf67cd5888fa06 | True |
| native/escaped_cli.py | f5668ad220fe48cb5d7fedfe7710e6ac9f6f996529869a50a5007d9bd811deb4 | f5668ad220fe48cb5d7fedfe7710e6ac9f6f996529869a50a5007d9bd811deb4 | f5668ad220fe48cb5d7fedfe7710e6ac9f6f996529869a50a5007d9bd811deb4 | True |
| native/escaped_http.py | 481445a41c59ba0c13a4b743132a9966c7fb7208b2a2fbe3aae3f2f41f437ef4 | 481445a41c59ba0c13a4b743132a9966c7fb7208b2a2fbe3aae3f2f41f437ef4 | 481445a41c59ba0c13a4b743132a9966c7fb7208b2a2fbe3aae3f2f41f437ef4 | True |
| src/pkg/__init__.py | 1b5af566d6a24b8b78f2df1e0bc5888161e4bbdccd57940693b4f581928493bd | 1b5af566d6a24b8b78f2df1e0bc5888161e4bbdccd57940693b4f581928493bd | 1b5af566d6a24b8b78f2df1e0bc5888161e4bbdccd57940693b4f581928493bd | True |
| src/pkg/_cli_argparse_diag.py | 934af86afc5cc6731aa35146b2afea02f75e32faa0cd6a189c50b05042f12360 | 934af86afc5cc6731aa35146b2afea02f75e32faa0cd6a189c50b05042f12360 | 934af86afc5cc6731aa35146b2afea02f75e32faa0cd6a189c50b05042f12360 | True |
| src/pkg/_cli_argparse.py | 6943f8bd5c3a432102a76113c40ce302131300b2d6b81aea221060e63835bed9 | 6943f8bd5c3a432102a76113c40ce302131300b2d6b81aea221060e63835bed9 | 6943f8bd5c3a432102a76113c40ce302131300b2d6b81aea221060e63835bed9 | True |
| src/pkg/_cli_click_diag.py | 9ffec0c17ef75448bfb61621fe72f5754f03d2682623e37c1fd248b1d756f0fa | 9ffec0c17ef75448bfb61621fe72f5754f03d2682623e37c1fd248b1d756f0fa | 9ffec0c17ef75448bfb61621fe72f5754f03d2682623e37c1fd248b1d756f0fa | True |
| src/pkg/_cli_click.py | 1fb16309f06a08f952ff3e29679a82f014f1f24fbe89228a110a9b8a4618388a | 1fb16309f06a08f952ff3e29679a82f014f1f24fbe89228a110a9b8a4618388a | 1fb16309f06a08f952ff3e29679a82f014f1f24fbe89228a110a9b8a4618388a | True |
| src/pkg/_cli_typer_diag.py | d36852e7da169eb15d347bbb9354cd65064269bd4734d3d3d17fcd6df1f5e08c | d36852e7da169eb15d347bbb9354cd65064269bd4734d3d3d17fcd6df1f5e08c | d36852e7da169eb15d347bbb9354cd65064269bd4734d3d3d17fcd6df1f5e08c | True |
| src/pkg/_cli_typer.py | c89ee730f35116683b4629e9ba3984637cd11f939f94970d4e21c4a7f2d1879c | c89ee730f35116683b4629e9ba3984637cd11f939f94970d4e21c4a7f2d1879c | c89ee730f35116683b4629e9ba3984637cd11f939f94970d4e21c4a7f2d1879c | True |
| src/pkg/_http_diag.py | 830e96f843aa462f991a990fc3448fd20256e850b0633096d1d7d6bf5ddf20aa | 830e96f843aa462f991a990fc3448fd20256e850b0633096d1d7d6bf5ddf20aa | 830e96f843aa462f991a990fc3448fd20256e850b0633096d1d7d6bf5ddf20aa | True |
| src/pkg/_http_fastapi.py | 4fc647921b78c3b1b113bc1e5152f7781f23b8e2f65ab9b395b2d6c149bbfcf1 | 4fc647921b78c3b1b113bc1e5152f7781f23b8e2f65ab9b395b2d6c149bbfcf1 | 4fc647921b78c3b1b113bc1e5152f7781f23b8e2f65ab9b395b2d6c149bbfcf1 | True |
| src/pkg/_http_flask.py | c1ee12c88bc0f2c2e452a49413eb5e33d1474b717fe8220e804158f3b1f11934 | c1ee12c88bc0f2c2e452a49413eb5e33d1474b717fe8220e804158f3b1f11934 | c1ee12c88bc0f2c2e452a49413eb5e33d1474b717fe8220e804158f3b1f11934 | True |
| src/pkg/_http_routers.py | e3ba16a81a4961687e2b935f5835421f39a9b37d58274d94f69da4731d6e1ba3 | e3ba16a81a4961687e2b935f5835421f39a9b37d58274d94f69da4731d6e1ba3 | e3ba16a81a4961687e2b935f5835421f39a9b37d58274d94f69da4731d6e1ba3 | True |
| src/pkg/api_all_tuple.py | 912787e4f646534102bab50e70e81f688360a16d966a1b25c5b176b9e888d4ac | 912787e4f646534102bab50e70e81f688360a16d966a1b25c5b176b9e888d4ac | 912787e4f646534102bab50e70e81f688360a16d966a1b25c5b176b9e888d4ac | True |
| src/pkg/api_all.py | d1ed534c69745c9714dc41ff9b8f13db911ee2613cb788969127cfc06d621efc | d1ed534c69745c9714dc41ff9b8f13db911ee2613cb788969127cfc06d621efc | d1ed534c69745c9714dc41ff9b8f13db911ee2613cb788969127cfc06d621efc | True |
| src/pkg/api_dynamic.py | 685fef2a2921abf8fe24522962a7add234713580191fbb6f0c203c531e1c6411 | 685fef2a2921abf8fe24522962a7add234713580191fbb6f0c203c531e1c6411 | 685fef2a2921abf8fe24522962a7add234713580191fbb6f0c203c531e1c6411 | True |
| src/pkg/api_naming.py | 18ab94b222daabaad5f22ca178794bf1c6c3c7adb974eea9e8ee2ed342f09989 | 18ab94b222daabaad5f22ca178794bf1c6c3c7adb974eea9e8ee2ed342f09989 | 18ab94b222daabaad5f22ca178794bf1c6c3c7adb974eea9e8ee2ed342f09989 | True |
| src/pkg/arch.py | 196f6d97112daf3e10a8376ef0ccaf724078d5498f3698b08a335f2dd280f842 | 196f6d97112daf3e10a8376ef0ccaf724078d5498f3698b08a335f2dd280f842 | 196f6d97112daf3e10a8376ef0ccaf724078d5498f3698b08a335f2dd280f842 | True |
| src/pkg/config.py | 412a717e7118cf04347e8555728e6875f973499ed423779c9d0c8a99bed296f4 | 412a717e7118cf04347e8555728e6875f973499ed423779c9d0c8a99bed296f4 | 412a717e7118cf04347e8555728e6875f973499ed423779c9d0c8a99bed296f4 | True |
| src/pkg/lex_encoding.py | a11b269db78f88f1e6c70129e3a8efb53adff1e08435d1c03895a23e41e45e85 | no-scanner-element | a11b269db78f88f1e6c70129e3a8efb53adff1e08435d1c03895a23e41e45e85 | True |
| src/pkg/lex_imports.py | e9ab88d7abf3325244a7553dbe77d044b2687e30d987b06e8c1eb2903a8ad2b6 | e9ab88d7abf3325244a7553dbe77d044b2687e30d987b06e8c1eb2903a8ad2b6 | e9ab88d7abf3325244a7553dbe77d044b2687e30d987b06e8c1eb2903a8ad2b6 | True |
| src/pkg/util.py | a14e932f6ec4ec229ecf4f71a46574c284de5dac2ff39350b8e214d6593b0041 | a14e932f6ec4ec229ecf4f71a46574c284de5dac2ff39350b8e214d6593b0041 | a14e932f6ec4ec229ecf4f71a46574c284de5dac2ff39350b8e214d6593b0041 | True |
| src/toplevel.py | 6a6c0f7536bd0c69eb49c29eb74d388e8eb3fe49817a6e6465255fa904c7d2f4 | 6a6c0f7536bd0c69eb49c29eb74d388e8eb3fe49817a6e6465255fa904c7d2f4 | 6a6c0f7536bd0c69eb49c29eb74d388e8eb3fe49817a6e6465255fa904c7d2f4 | True |
