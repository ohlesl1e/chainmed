// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Doctor.sol";
import "./Patient.sol";
import "./Treatment.sol";
import "./TreatmentFactory.sol";
import "./Manager.sol";
import "./Helper.sol";

abstract contract Application {
    bytes32 private name;
    Manager internal manager;

    constructor(address manager_, bytes32 name_) {
        manager = Manager(manager_);
        name = name_;
    }

    function getName() public view returns (bytes32 name_) {
        name_ = name;
    }
}
