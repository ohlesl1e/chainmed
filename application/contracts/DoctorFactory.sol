// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Doctor.sol";
import "./Helper.sol";

contract DoctorFactory is Ownable {
    address immutable doctorImplementation;

    constructor() {
        doctorImplementation = address(new Doctor());
    }

    function createDoctor(
        address doctor_,
        bytes32 name_,
        bytes32 affiliate_
    ) external onlyOwner returns (address clone) {
        clone = Clones.clone(doctorImplementation);
        Doctor(clone).initialize(doctor_, msg.sender, name_, affiliate_);
    }
}
