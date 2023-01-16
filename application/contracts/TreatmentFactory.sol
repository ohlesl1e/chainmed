// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Treatment.sol";

contract TreatmentFactory is Ownable {
    address immutable treatmentImplementation;

    constructor() {
        treatmentImplementation = address(new Treatment());
    }

    function createTreatment(
        address doctor_,
        address patient_,
        string memory medicine_,
        bytes32 form_,
        Dosage memory dosage_,
        Schedule memory schedule_
    ) external onlyOwner returns (address clone) {
        clone = Clones.clone(treatmentImplementation);
        Treatment(clone).initialize(
            doctor_,
            patient_,
            medicine_,
            form_,
            dosage_,
            schedule_
        );
    }
}
