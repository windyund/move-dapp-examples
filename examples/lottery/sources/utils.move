module lottery::utils {

    use std::vector;

    #[test_only]
    public fun add(x: u64, y: u64): u64 {
        x + y
    }

    public fun u32_to_ascii(mut num: u32): vector<u8> {
        if (num == 0) {
            return b"0"
        };
        let mut bytes = vector::empty<u8>();
        while (num > 0) {
            let remainder = num % 10; // get the last digit
            num = num / 10; // remove the last digit
            vector::push_back(&mut bytes, (remainder as u8) + 48); // ASCII value of 0 is 48
        };
        vector::reverse(&mut bytes);
        return bytes
    }


    // 数字转字符串
    public fun u64_to_ascii(mut num: u64): vector<u8> {
        if (num == 0) {
            return b"0"
        };
        let mut bytes = vector::empty<u8>();
        while (num > 0) {
            let remainder = num % 10; // get the last digit
            num = num / 10; // remove the last digit
            vector::push_back(&mut bytes, (remainder as u8) + 48); // ASCII value of 0 is 48
        };
        vector::reverse(&mut bytes);
        return bytes
    }
}

