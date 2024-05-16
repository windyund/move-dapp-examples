#[test_only]
module lottery::utils_tests {
    use std::debug;
    use std::string;
    use lottery::utils;
    #[test]
    fun test_math() {
        assert!(utils::add(1, 2) == 3, 0);
    }

    #[test]
    fun test_to_str() {
        let mut aa :u32 =  32;
        let c = utils::u32_to_ascii(aa);
        debug::print( &string::utf8(c));
    }
}
