use strict;
use warnings;

use Test::More;
use Test::Fatal;
require_ok("XSTest");

my (%kv,$expecting);

%kv = (alpha => 1, beta => "B", -charlie => "C", delta => 0, _echo => "E");
$expecting = 'TestStruct { alpha: true, beta: "B", charlie: "C", delta: Some(false), echo: Some("E") }';
is XSTest::Derive::test_from_kv(%kv), $expecting, "test_from_kv_debug - happy path";


delete $kv{'-charlie'};
$kv{'-charles'} = 'C'; # alias. same expected output
is XSTest::Derive::test_from_kv_debug(%kv), $expecting, "test_from_kv_debug - field alias";

is XSTest::Derive::test_from_kv_bool(%kv), 1, "test_from_kv_bool - happy path";

my ($auto,$manual) = XSTest::Derive::test_from_kv_dual_arg_unpack(%kv);

is $auto, $expecting, "test_from_kv_dual_arg_unpack - auto unpack happy path";
is $manual, $expecting, "test_from_kv_dual_arg_unpack - manual unpack happy path";

%kv = (); # nada
$expecting = 'ToStructErr { name: "TestStruct", errors: [OmittedKey(["alpha"]), OmittedKey(["beta"]), OmittedKey(["-charlie", "-charles", "-chuck"])] }';
is XSTest::Derive::Error::test_from_kv_error(%kv), $expecting, "test_from_kv_error - omitted fields";

$expecting = "Failed to instantiate TestStruct
\tMissing field: alpha
\tMissing field: beta
\tMissing one of the following fields: -charlie, -charles, -chuck
";
is XSTest::Derive::Error::test_from_kv_error_display(%kv), $expecting, "test_from_kv_error_display - omitted fields";

is exception { XSTest::Derive::test_from_kv(%kv) }, $expecting, "panic ok";

%kv = (alpha => 0, -chuck => "C");
$expecting = 'ToStructErr { name: "TestStruct", errors: [OmittedKey(["beta"])] }';
is XSTest::Derive::Error::test_from_kv_error(%kv), $expecting, "test_from_kv_error - omitted fields 2";

$expecting = "Failed to instantiate TestStruct
\tMissing field: beta
";
is XSTest::Derive::Error::test_from_kv_error_display(%kv), $expecting, "test_from_kv_error_display - omitted fields 2";


done_testing;

# struct TestStruct {
#     alpha:          bool,
#     beta:           String,
#     #[perlxs(key="-charlie", key="-charles", key="-chuck")]
#     charlie:        String,
#     delta:          Option<bool>,
#     #[perlxs(key = "_echo")]
#     echo:          Option<String>,
# }