// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CDPatient.sol";
import "./CDDoctor.sol";
import "./CDTreatment.sol";

contract CDManager {
    mapping(address => CDPatient) private patients;
    mapping(address => CDDoctor) private doctors;

    function register(
        bytes32 name_,
        bytes32 gender_,
        uint256 dob_,
        uint16 height_,
        uint16 weight_,
        string[] memory allergy_,
        bool alcohol_,
        bool smoke_,
        bool cannabis_
    ) public {
        patients[msg.sender] = new CDPatient(
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
    }

    function addDoctor(address id) public {
        doctors[id] = new CDDoctor(id);
    }

    function getPatient(address id) public view returns (CDPatient) {
        return patients[id];
    }

    function getDoctor(address id) public view returns (CDDoctor) {
        return doctors[id];
    }

    function prescribe(
        address patient_,
        string memory medicine_,
        bytes32 form_,
        Dosage memory dosage_,
        Schedule memory schedule_
    ) public {
        CDDoctor doctor = doctors[msg.sender];

        (CDTreatment treatment, address oldPatient) = doctor.prescribe(
            patient_,
            medicine_,
            form_,
            dosage_,
            schedule_
        );
        patients[patient_].addTreatment(treatment);
        if (oldPatient != address(0)) {
            patients[oldPatient].removeTreatment(treatment);
        }
    }
}
