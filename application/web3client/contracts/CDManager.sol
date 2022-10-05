// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CDPatient.sol";

contract CDManager {
    mapping(address => CDPatient) private patients;

    function register(
        bytes32 name_,
        bytes32 gender_,
        uint dob_,
        uint16 height_,
        uint16 weight_,
        string[] memory allergy_,
        bool alcohol_,
        bool smoke_,
        bool cannabis_
    ) public {
        CDPatient patient_ = new CDPatient(
            msg.sender,
            name_,
            gender_,
            dob_,
            height_,
            weight_,
            allergy_,
            alcohol_,
            smoke_,
            cannabis_
        );
        patients[msg.sender] = patient_;
    }

    function getPatient(address id) public view returns (CDPatient) {
        return patients[id];
    }
}
