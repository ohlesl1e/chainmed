{

    // bytes32[]
    function abi_decode_available_length_t_array$_t_bytes32_$dyn_memory_ptr(offset, length, end) -> array {
        array := allocate_memory(array_allocation_size_t_array$_t_bytes32_$dyn_memory_ptr(length))
        let dst := array

        mstore(array, length)
        dst := add(array, 0x20)

        let src := offset
        if gt(add(src, mul(length, 0x20)), end) {
            revert_error_81385d8c0b31fffe14be1da910c8bd3a80be4cfa248e04f42ec0faea3132a8ef()
        }
        for { let i := 0 } lt(i, length) { i := add(i, 1) }
        {

            let elementPos := src

            mstore(dst, abi_decode_t_bytes32(elementPos, end))
            dst := add(dst, 0x20)
            src := add(src, 0x20)
        }
    }

    // uint16[]
    function abi_decode_available_length_t_array$_t_uint16_$dyn_memory_ptr(offset, length, end) -> array {
        array := allocate_memory(array_allocation_size_t_array$_t_uint16_$dyn_memory_ptr(length))
        let dst := array

        mstore(array, length)
        dst := add(array, 0x20)

        let src := offset
        if gt(add(src, mul(length, 0x20)), end) {
            revert_error_81385d8c0b31fffe14be1da910c8bd3a80be4cfa248e04f42ec0faea3132a8ef()
        }
        for { let i := 0 } lt(i, length) { i := add(i, 1) }
        {

            let elementPos := src

            mstore(dst, abi_decode_t_uint16(elementPos, end))
            dst := add(dst, 0x20)
            src := add(src, 0x20)
        }
    }

    function abi_decode_available_length_t_string_memory_ptr(src, length, end) -> array {
        array := allocate_memory(array_allocation_size_t_string_memory_ptr(length))
        mstore(array, length)
        let dst := add(array, 0x20)
        if gt(add(src, length), end) { revert_error_987264b3b1d58a9c7f8255e93e81c77d86d6299019c33110a076957a3e06e2ae() }
        copy_calldata_to_memory(src, dst, length)
    }

    function abi_decode_t_address(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_address(value)
    }

    function abi_decode_t_address_fromMemory(offset, end) -> value {
        value := mload(offset)
        validator_revert_t_address(value)
    }

    // bytes32[]
    function abi_decode_t_array$_t_bytes32_$dyn_memory_ptr(offset, end) -> array {
        if iszero(slt(add(offset, 0x1f), end)) { revert_error_1b9f4a0a5773e33b91aa01db23bf8c55fce1411167c872835e7fa00a4f17d46d() }
        let length := calldataload(offset)
        array := abi_decode_available_length_t_array$_t_bytes32_$dyn_memory_ptr(add(offset, 0x20), length, end)
    }

    // uint16[]
    function abi_decode_t_array$_t_uint16_$dyn_memory_ptr(offset, end) -> array {
        if iszero(slt(add(offset, 0x1f), end)) { revert_error_1b9f4a0a5773e33b91aa01db23bf8c55fce1411167c872835e7fa00a4f17d46d() }
        let length := calldataload(offset)
        array := abi_decode_available_length_t_array$_t_uint16_$dyn_memory_ptr(add(offset, 0x20), length, end)
    }

    function abi_decode_t_bytes32(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_bytes32(value)
    }

    function abi_decode_t_contract$_CDPatientManager_$1320(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_contract$_CDPatientManager_$1320(value)
    }

    function abi_decode_t_contract$_CDPatient_$1252_fromMemory(offset, end) -> value {
        value := mload(offset)
        validator_revert_t_contract$_CDPatient_$1252(value)
    }

    function abi_decode_t_contract$_CDTreatment_$1615_fromMemory(offset, end) -> value {
        value := mload(offset)
        validator_revert_t_contract$_CDTreatment_$1615(value)
    }

    function abi_decode_t_enum$_Frequency_$1332(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_enum$_Frequency_$1332(value)
    }

    // string
    function abi_decode_t_string_memory_ptr(offset, end) -> array {
        if iszero(slt(add(offset, 0x1f), end)) { revert_error_1b9f4a0a5773e33b91aa01db23bf8c55fce1411167c872835e7fa00a4f17d46d() }
        let length := calldataload(offset)
        array := abi_decode_available_length_t_string_memory_ptr(add(offset, 0x20), length, end)
    }

    // struct Dosage
    function abi_decode_t_struct$_Dosage_$1328_memory_ptr(headStart, end) -> value {
        if slt(sub(end, headStart), 0x40) { revert_error_3538a459e4a0eb828f1aed5ebe5dc96fe59620a31d9b33e41259bb820cae769f() }
        value := allocate_memory(0x40)

        {
            // strength

            let offset := 0

            mstore(add(value, 0x00), abi_decode_t_uint16(add(headStart, offset), end))

        }

        {
            // unit

            let offset := 32

            mstore(add(value, 0x20), abi_decode_t_bytes32(add(headStart, offset), end))

        }

    }

    // struct Schedule
    function abi_decode_t_struct$_Schedule_$1348_memory_ptr(headStart, end) -> value {
        if slt(sub(end, headStart), 0xc0) { revert_error_3538a459e4a0eb828f1aed5ebe5dc96fe59620a31d9b33e41259bb820cae769f() }
        value := allocate_memory(0xc0)

        {
            // startDate

            let offset := 0

            mstore(add(value, 0x00), abi_decode_t_uint256(add(headStart, offset), end))

        }

        {
            // endDate

            let offset := 32

            mstore(add(value, 0x20), abi_decode_t_uint256(add(headStart, offset), end))

        }

        {
            // frequency

            let offset := 64

            mstore(add(value, 0x40), abi_decode_t_enum$_Frequency_$1332(add(headStart, offset), end))

        }

        {
            // interval

            let offset := 96

            mstore(add(value, 0x60), abi_decode_t_uint8(add(headStart, offset), end))

        }

        {
            // daysOfWeek

            let offset := calldataload(add(headStart, 128))
            if gt(offset, 0xffffffffffffffff) { revert_error_5e8f644817bc4960744f35c15999b6eff64ae702f94b1c46297cfd4e1aec2421() }

            mstore(add(value, 0x80), abi_decode_t_array$_t_bytes32_$dyn_memory_ptr(add(headStart, offset), end))

        }

        {
            // timesOfDay

            let offset := calldataload(add(headStart, 160))
            if gt(offset, 0xffffffffffffffff) { revert_error_5e8f644817bc4960744f35c15999b6eff64ae702f94b1c46297cfd4e1aec2421() }

            mstore(add(value, 0xa0), abi_decode_t_array$_t_uint16_$dyn_memory_ptr(add(headStart, offset), end))

        }

    }

    function abi_decode_t_uint16(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_uint16(value)
    }

    function abi_decode_t_uint256(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_uint256(value)
    }

    function abi_decode_t_uint8(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_uint8(value)
    }

    function abi_decode_tuple_t_address(headStart, dataEnd) -> value0 {
        if slt(sub(dataEnd, headStart), 32) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_address(add(headStart, offset), dataEnd)
        }

    }

    function abi_decode_tuple_t_contract$_CDPatientManager_$1320t_addresst_string_memory_ptrt_bytes32t_struct$_Dosage_$1328_memory_ptrt_struct$_Schedule_$1348_memory_ptr(headStart, dataEnd) -> value0, value1, value2, value3, value4, value5 {
        if slt(sub(dataEnd, headStart), 224) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_contract$_CDPatientManager_$1320(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_address(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

        {

            let offset := 96

            value3 := abi_decode_t_bytes32(add(headStart, offset), dataEnd)
        }

        {

            let offset := 128

            value4 := abi_decode_t_struct$_Dosage_$1328_memory_ptr(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 192))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value5 := abi_decode_t_struct$_Schedule_$1348_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function abi_decode_tuple_t_contract$_CDPatient_$1252_fromMemory(headStart, dataEnd) -> value0 {
        if slt(sub(dataEnd, headStart), 32) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_contract$_CDPatient_$1252_fromMemory(add(headStart, offset), dataEnd)
        }

    }

    function abi_decode_tuple_t_contract$_CDTreatment_$1615t_address_fromMemory(headStart, dataEnd) -> value0, value1 {
        if slt(sub(dataEnd, headStart), 64) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_contract$_CDTreatment_$1615_fromMemory(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_address_fromMemory(add(headStart, offset), dataEnd)
        }

    }

    function abi_encodeUpdatedPos_t_bytes32_to_t_bytes32(value0, pos) -> updatedPos {
        abi_encode_t_bytes32_to_t_bytes32(value0, pos)
        updatedPos := add(pos, 0x20)
    }

    function abi_encodeUpdatedPos_t_uint16_to_t_uint16(value0, pos) -> updatedPos {
        abi_encode_t_uint16_to_t_uint16(value0, pos)
        updatedPos := add(pos, 0x20)
    }

    function abi_encode_t_address_to_t_address_fromStack(value, pos) {
        mstore(pos, cleanup_t_address(value))
    }

    // bytes32[] -> bytes32[]
    function abi_encode_t_array$_t_bytes32_$dyn_memory_ptr_to_t_array$_t_bytes32_$dyn_memory_ptr(value, pos)  -> end  {
        let length := array_length_t_array$_t_bytes32_$dyn_memory_ptr(value)
        pos := array_storeLengthForEncoding_t_array$_t_bytes32_$dyn_memory_ptr(pos, length)
        let baseRef := array_dataslot_t_array$_t_bytes32_$dyn_memory_ptr(value)
        let srcPtr := baseRef
        for { let i := 0 } lt(i, length) { i := add(i, 1) }
        {
            let elementValue0 := mload(srcPtr)
            pos := abi_encodeUpdatedPos_t_bytes32_to_t_bytes32(elementValue0, pos)
            srcPtr := array_nextElement_t_array$_t_bytes32_$dyn_memory_ptr(srcPtr)
        }
        end := pos
    }

    // uint16[] -> uint16[]
    function abi_encode_t_array$_t_uint16_$dyn_memory_ptr_to_t_array$_t_uint16_$dyn_memory_ptr(value, pos)  -> end  {
        let length := array_length_t_array$_t_uint16_$dyn_memory_ptr(value)
        pos := array_storeLengthForEncoding_t_array$_t_uint16_$dyn_memory_ptr(pos, length)
        let baseRef := array_dataslot_t_array$_t_uint16_$dyn_memory_ptr(value)
        let srcPtr := baseRef
        for { let i := 0 } lt(i, length) { i := add(i, 1) }
        {
            let elementValue0 := mload(srcPtr)
            pos := abi_encodeUpdatedPos_t_uint16_to_t_uint16(elementValue0, pos)
            srcPtr := array_nextElement_t_array$_t_uint16_$dyn_memory_ptr(srcPtr)
        }
        end := pos
    }

    function abi_encode_t_bytes32_to_t_bytes32(value, pos) {
        mstore(pos, cleanup_t_bytes32(value))
    }

    function abi_encode_t_bytes32_to_t_bytes32_fromStack(value, pos) {
        mstore(pos, cleanup_t_bytes32(value))
    }

    function abi_encode_t_contract$_CDDoctor_$839_to_t_address_fromStack(value, pos) {
        mstore(pos, convert_t_contract$_CDDoctor_$839_to_t_address(value))
    }

    function abi_encode_t_contract$_CDTreatment_$1615_to_t_address_fromStack(value, pos) {
        mstore(pos, convert_t_contract$_CDTreatment_$1615_to_t_address(value))
    }

    function abi_encode_t_enum$_Frequency_$1332_to_t_uint8(value, pos) {
        mstore(pos, convert_t_enum$_Frequency_$1332_to_t_uint8(value))
    }

    function abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value, pos) -> end {
        let length := array_length_t_string_memory_ptr(value)
        pos := array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, length)
        copy_memory_to_memory(add(value, 0x20), pos, length)
        end := add(pos, round_up_to_mul_of_32(length))
    }

    // struct Dosage -> struct Dosage
    function abi_encode_t_struct$_Dosage_$1328_memory_ptr_to_t_struct$_Dosage_$1328_memory_ptr_fromStack(value, pos)  {
        let tail := add(pos, 0x40)

        {
            // strength

            let memberValue0 := mload(add(value, 0x00))
            abi_encode_t_uint16_to_t_uint16(memberValue0, add(pos, 0x00))
        }

        {
            // unit

            let memberValue0 := mload(add(value, 0x20))
            abi_encode_t_bytes32_to_t_bytes32(memberValue0, add(pos, 0x20))
        }

    }

    // struct Schedule -> struct Schedule
    function abi_encode_t_struct$_Schedule_$1348_memory_ptr_to_t_struct$_Schedule_$1348_memory_ptr_fromStack(value, pos)  -> end  {
        let tail := add(pos, 0xc0)

        {
            // startDate

            let memberValue0 := mload(add(value, 0x00))
            abi_encode_t_uint256_to_t_uint256(memberValue0, add(pos, 0x00))
        }

        {
            // endDate

            let memberValue0 := mload(add(value, 0x20))
            abi_encode_t_uint256_to_t_uint256(memberValue0, add(pos, 0x20))
        }

        {
            // frequency

            let memberValue0 := mload(add(value, 0x40))
            abi_encode_t_enum$_Frequency_$1332_to_t_uint8(memberValue0, add(pos, 0x40))
        }

        {
            // interval

            let memberValue0 := mload(add(value, 0x60))
            abi_encode_t_uint8_to_t_uint8(memberValue0, add(pos, 0x60))
        }

        {
            // daysOfWeek

            let memberValue0 := mload(add(value, 0x80))

            mstore(add(pos, 0x80), sub(tail, pos))
            tail := abi_encode_t_array$_t_bytes32_$dyn_memory_ptr_to_t_array$_t_bytes32_$dyn_memory_ptr(memberValue0, tail)

        }

        {
            // timesOfDay

            let memberValue0 := mload(add(value, 0xa0))

            mstore(add(pos, 0xa0), sub(tail, pos))
            tail := abi_encode_t_array$_t_uint16_$dyn_memory_ptr_to_t_array$_t_uint16_$dyn_memory_ptr(memberValue0, tail)

        }

        end := tail
    }

    function abi_encode_t_uint16_to_t_uint16(value, pos) {
        mstore(pos, cleanup_t_uint16(value))
    }

    function abi_encode_t_uint256_to_t_uint256(value, pos) {
        mstore(pos, cleanup_t_uint256(value))
    }

    function abi_encode_t_uint8_to_t_uint8(value, pos) {
        mstore(pos, cleanup_t_uint8(value))
    }

    function abi_encode_tuple_t_address__to_t_address__fromStack_reversed(headStart , value0) -> tail {
        tail := add(headStart, 32)

        abi_encode_t_address_to_t_address_fromStack(value0,  add(headStart, 0))

    }

    function abi_encode_tuple_t_address_t_string_memory_ptr_t_bytes32_t_struct$_Dosage_$1328_memory_ptr_t_struct$_Schedule_$1348_memory_ptr__to_t_address_t_string_memory_ptr_t_bytes32_t_struct$_Dosage_$1328_memory_ptr_t_struct$_Schedule_$1348_memory_ptr__fromStack_reversed(headStart , value4, value3, value2, value1, value0) -> tail {
        tail := add(headStart, 192)

        abi_encode_t_address_to_t_address_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        abi_encode_t_bytes32_to_t_bytes32_fromStack(value2,  add(headStart, 64))

        abi_encode_t_struct$_Dosage_$1328_memory_ptr_to_t_struct$_Dosage_$1328_memory_ptr_fromStack(value3,  add(headStart, 96))

        mstore(add(headStart, 160), sub(tail, headStart))
        tail := abi_encode_t_struct$_Schedule_$1348_memory_ptr_to_t_struct$_Schedule_$1348_memory_ptr_fromStack(value4,  tail)

    }

    function abi_encode_tuple_t_contract$_CDDoctor_$839__to_t_address__fromStack_reversed(headStart , value0) -> tail {
        tail := add(headStart, 32)

        abi_encode_t_contract$_CDDoctor_$839_to_t_address_fromStack(value0,  add(headStart, 0))

    }

    function abi_encode_tuple_t_contract$_CDTreatment_$1615__to_t_address__fromStack_reversed(headStart , value0) -> tail {
        tail := add(headStart, 32)

        abi_encode_t_contract$_CDTreatment_$1615_to_t_address_fromStack(value0,  add(headStart, 0))

    }

    function allocate_memory(size) -> memPtr {
        memPtr := allocate_unbounded()
        finalize_allocation(memPtr, size)
    }

    function allocate_unbounded() -> memPtr {
        memPtr := mload(64)
    }

    function array_allocation_size_t_array$_t_bytes32_$dyn_memory_ptr(length) -> size {
        // Make sure we can allocate memory without overflow
        if gt(length, 0xffffffffffffffff) { panic_error_0x41() }

        size := mul(length, 0x20)

        // add length slot
        size := add(size, 0x20)

    }

    function array_allocation_size_t_array$_t_uint16_$dyn_memory_ptr(length) -> size {
        // Make sure we can allocate memory without overflow
        if gt(length, 0xffffffffffffffff) { panic_error_0x41() }

        size := mul(length, 0x20)

        // add length slot
        size := add(size, 0x20)

    }

    function array_allocation_size_t_string_memory_ptr(length) -> size {
        // Make sure we can allocate memory without overflow
        if gt(length, 0xffffffffffffffff) { panic_error_0x41() }

        size := round_up_to_mul_of_32(length)

        // add length slot
        size := add(size, 0x20)

    }

    function array_dataslot_t_array$_t_bytes32_$dyn_memory_ptr(ptr) -> data {
        data := ptr

        data := add(ptr, 0x20)

    }

    function array_dataslot_t_array$_t_uint16_$dyn_memory_ptr(ptr) -> data {
        data := ptr

        data := add(ptr, 0x20)

    }

    function array_length_t_array$_t_bytes32_$dyn_memory_ptr(value) -> length {

        length := mload(value)

    }

    function array_length_t_array$_t_uint16_$dyn_memory_ptr(value) -> length {

        length := mload(value)

    }

    function array_length_t_string_memory_ptr(value) -> length {

        length := mload(value)

    }

    function array_nextElement_t_array$_t_bytes32_$dyn_memory_ptr(ptr) -> next {
        next := add(ptr, 0x20)
    }

    function array_nextElement_t_array$_t_uint16_$dyn_memory_ptr(ptr) -> next {
        next := add(ptr, 0x20)
    }

    function array_storeLengthForEncoding_t_array$_t_bytes32_$dyn_memory_ptr(pos, length) -> updated_pos {
        mstore(pos, length)
        updated_pos := add(pos, 0x20)
    }

    function array_storeLengthForEncoding_t_array$_t_uint16_$dyn_memory_ptr(pos, length) -> updated_pos {
        mstore(pos, length)
        updated_pos := add(pos, 0x20)
    }

    function array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, length) -> updated_pos {
        mstore(pos, length)
        updated_pos := add(pos, 0x20)
    }

    function cleanup_t_address(value) -> cleaned {
        cleaned := cleanup_t_uint160(value)
    }

    function cleanup_t_bytes32(value) -> cleaned {
        cleaned := value
    }

    function cleanup_t_contract$_CDPatientManager_$1320(value) -> cleaned {
        cleaned := cleanup_t_address(value)
    }

    function cleanup_t_contract$_CDPatient_$1252(value) -> cleaned {
        cleaned := cleanup_t_address(value)
    }

    function cleanup_t_contract$_CDTreatment_$1615(value) -> cleaned {
        cleaned := cleanup_t_address(value)
    }

    function cleanup_t_enum$_Frequency_$1332(value) -> cleaned {
        cleaned := value validator_assert_t_enum$_Frequency_$1332(value)
    }

    function cleanup_t_uint16(value) -> cleaned {
        cleaned := and(value, 0xffff)
    }

    function cleanup_t_uint160(value) -> cleaned {
        cleaned := and(value, 0xffffffffffffffffffffffffffffffffffffffff)
    }

    function cleanup_t_uint256(value) -> cleaned {
        cleaned := value
    }

    function cleanup_t_uint8(value) -> cleaned {
        cleaned := and(value, 0xff)
    }

    function convert_t_contract$_CDDoctor_$839_to_t_address(value) -> converted {
        converted := convert_t_contract$_CDDoctor_$839_to_t_uint160(value)
    }

    function convert_t_contract$_CDDoctor_$839_to_t_uint160(value) -> converted {
        converted := cleanup_t_uint160(value)
    }

    function convert_t_contract$_CDTreatment_$1615_to_t_address(value) -> converted {
        converted := convert_t_contract$_CDTreatment_$1615_to_t_uint160(value)
    }

    function convert_t_contract$_CDTreatment_$1615_to_t_uint160(value) -> converted {
        converted := cleanup_t_uint160(value)
    }

    function convert_t_enum$_Frequency_$1332_to_t_uint8(value) -> converted {
        converted := cleanup_t_enum$_Frequency_$1332(value)
    }

    function copy_calldata_to_memory(src, dst, length) {
        calldatacopy(dst, src, length)
        // clear end
        mstore(add(dst, length), 0)
    }

    function copy_memory_to_memory(src, dst, length) {
        let i := 0
        for { } lt(i, length) { i := add(i, 32) }
        {
            mstore(add(dst, i), mload(add(src, i)))
        }
        if gt(i, length)
        {
            // clear end
            mstore(add(dst, length), 0)
        }
    }

    function finalize_allocation(memPtr, size) {
        let newFreePtr := add(memPtr, round_up_to_mul_of_32(size))
        // protect against overflow
        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
        mstore(64, newFreePtr)
    }

    function panic_error_0x21() {
        mstore(0, 35408467139433450592217433187231851964531694900788300625387963629091585785856)
        mstore(4, 0x21)
        revert(0, 0x24)
    }

    function panic_error_0x41() {
        mstore(0, 35408467139433450592217433187231851964531694900788300625387963629091585785856)
        mstore(4, 0x41)
        revert(0, 0x24)
    }

    function revert_error_1b9f4a0a5773e33b91aa01db23bf8c55fce1411167c872835e7fa00a4f17d46d() {
        revert(0, 0)
    }

    function revert_error_3538a459e4a0eb828f1aed5ebe5dc96fe59620a31d9b33e41259bb820cae769f() {
        revert(0, 0)
    }

    function revert_error_5e8f644817bc4960744f35c15999b6eff64ae702f94b1c46297cfd4e1aec2421() {
        revert(0, 0)
    }

    function revert_error_81385d8c0b31fffe14be1da910c8bd3a80be4cfa248e04f42ec0faea3132a8ef() {
        revert(0, 0)
    }

    function revert_error_987264b3b1d58a9c7f8255e93e81c77d86d6299019c33110a076957a3e06e2ae() {
        revert(0, 0)
    }

    function revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() {
        revert(0, 0)
    }

    function revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() {
        revert(0, 0)
    }

    function round_up_to_mul_of_32(value) -> result {
        result := and(add(value, 31), not(31))
    }

    function validator_assert_t_enum$_Frequency_$1332(value) {
        if iszero(lt(value, 3)) { panic_error_0x21() }
    }

    function validator_revert_t_address(value) {
        if iszero(eq(value, cleanup_t_address(value))) { revert(0, 0) }
    }

    function validator_revert_t_bytes32(value) {
        if iszero(eq(value, cleanup_t_bytes32(value))) { revert(0, 0) }
    }

    function validator_revert_t_contract$_CDPatientManager_$1320(value) {
        if iszero(eq(value, cleanup_t_contract$_CDPatientManager_$1320(value))) { revert(0, 0) }
    }

    function validator_revert_t_contract$_CDPatient_$1252(value) {
        if iszero(eq(value, cleanup_t_contract$_CDPatient_$1252(value))) { revert(0, 0) }
    }

    function validator_revert_t_contract$_CDTreatment_$1615(value) {
        if iszero(eq(value, cleanup_t_contract$_CDTreatment_$1615(value))) { revert(0, 0) }
    }

    function validator_revert_t_enum$_Frequency_$1332(value) {
        if iszero(lt(value, 3)) { revert(0, 0) }
    }

    function validator_revert_t_uint16(value) {
        if iszero(eq(value, cleanup_t_uint16(value))) { revert(0, 0) }
    }

    function validator_revert_t_uint256(value) {
        if iszero(eq(value, cleanup_t_uint256(value))) { revert(0, 0) }
    }

    function validator_revert_t_uint8(value) {
        if iszero(eq(value, cleanup_t_uint8(value))) { revert(0, 0) }
    }

}
