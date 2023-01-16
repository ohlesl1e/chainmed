// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Patient.sol";
import "./Helper.sol";

contract PatientFactory is Ownable {
    address immutable patientImplementation;

    constructor() {
        patientImplementation = address(new Patient());
    }

    function createPatient(
        address owner_,
        Bytes32Pair memory nameGender_,
        uint256 dob_,
        SmallUintPair memory physique_,
        string[] memory allergy_,
        BoolTriple memory habits_,
        FromAppOption memory option_
    ) external onlyOwner returns (address clone) {
        clone = Clones.clone(patientImplementation);
        if (option_.fromApp) {
            Patient(clone).initialize(
                msg.sender,
                owner_,
                option_.addr,
                nameGender_,
                dob_,
                physique_,
                allergy_,
                habits_
            );
        } else {
            Patient(clone).initialize(
                msg.sender,
                owner_,
                address(0),
                nameGender_,
                dob_,
                physique_,
                allergy_,
                habits_
            );
        }
    }
}
