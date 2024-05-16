#[test_only]
module lottery::utils_tests {
    use lottery::utils;

    #[test]
    fun test_math() {
        assert!(utils::add(1, 2) == 3, 0);
    }
}
