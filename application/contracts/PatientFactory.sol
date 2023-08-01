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
        string memory info_
    ) external onlyOwner returns (address clone) {
        clone = Clones.clone(patientImplementation);
        Patient(clone).initialize(msg.sender, owner_, info_);
    }
}
