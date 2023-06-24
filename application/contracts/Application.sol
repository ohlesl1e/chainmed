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

    function addDoctor(
        address owner_,
        bytes32 name_,
        bytes32 affiliate_
    ) external {
        require(
            manager.hasRole(manager.ADMINISTRATOR_ROLE(), msg.sender),
            "Administrator only"
        );
        require(manager.getDoctor(msg.sender) == address(0), "Profile existed");
        manager.addDoctor(owner_, name_, affiliate_, true);
    }

    function addPatient(
        Bytes32Pair memory nameGender_,
        uint256 dob_,
        SmallUintPair memory physique_,
        string[] memory allergy_,
        BoolTriple memory habits_,
        string memory info_
    ) external {
        require(
            manager.getPatient(msg.sender) == address(0),
            "Profile existed"
        );
        manager.addPatient(
            nameGender_,
            dob_,
            physique_,
            allergy_,
            habits_,
            FromAppOption(true, msg.sender),
            info_
        );
    }
}
