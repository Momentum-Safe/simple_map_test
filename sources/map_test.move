/// Utils library support for momentum safe.
/// Includes cryptographic and dependency functions.
module msafe::simple_map_test {
    use aptos_std::simple_map::{Self, SimpleMap};
    use std::vector;
    use std::bcs;
    use std::signer;

    const MAX_TRANSACTION_SIZE: u64 = 64 * 1024;

    struct TestStore has key {
        value: vector<u8>,
        datas: SimpleMap<vector<u8>, vector<u8>>
    }

    fun init_module(s: &signer) {
        if (!exists<TestStore>(signer::address_of(s))) {
            move_to(s, TestStore {
                value: build_bytes(MAX_TRANSACTION_SIZE),
                datas: simple_map::create()
            })
        }
    }

    fun build_bytes(size: u64): vector<u8> {
        let data = vector::empty<u8>();
        let i = 0;
        while (i < size) {
            vector::push_back(&mut data, ((i & 0xff) as u8));
            i = i + 1;
        };
        data
    }

    fun to_bytes32(n: u64): vector<u8> {
        let bytes = b"0123456789abcdef01234567";
        vector::append(&mut bytes, bcs::to_bytes(&n));
        assert!(vector::length(&bytes) == 32, 0);
        bytes
    }

    public entry fun add(num: u64) acquires TestStore {
        let store = borrow_global_mut<TestStore>(@msafe);
        let i = 0;
        let startSeq = simple_map::length(&store.datas);
        while (i < num) {
            let key = to_bytes32(startSeq + i);
            i = i + 1;
            simple_map::add(&mut store.datas, key, store.value);
        }
    }

    public entry fun borrow(seq: u64) acquires TestStore {
        let store = borrow_global<TestStore>(@msafe);
        let key = to_bytes32(seq);
        let value = simple_map::borrow(&store.datas, &key);
        vector::length(value);
    }

    #[test(s = @msafe)]
    fun test_fill_128(s: &signer) acquires TestStore {
        let fill_size = 128;
        init_module(s);
        add(fill_size);
        borrow(fill_size - 1);
    }
}
