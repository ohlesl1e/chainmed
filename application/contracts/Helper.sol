// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct Bytes32Pair {
    bytes32 value1;
    bytes32 value2;
}

struct BoolTriple {
    bool value1;
    bool value2;
    bool value3;
}

struct SmallUintPair {
    uint16 value1;
    uint16 value2;
}

struct FromAppOption {
    bool fromApp;
    address addr; //put app address here if fromApp is true, owner address otherwise
}
