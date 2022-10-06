// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CDPatient.sol";
import "./CDDoctor.sol";
import "./CDTreatment.sol";
import "./CDPatientManager.sol";

contract CDDoctorManager {
    mapping(address => CDDoctor) public doctors;

    function addDoctor(address id, CDDoctor doctor_) public {
        doctors[id] = doctor_;
    }

    function getDoctor(address id) public view returns (CDDoctor) {
        return doctors[id];
    }

    function prescribe(
        CDPatientManager patients,
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
        patients.getPatient(patient_).addTreatment(treatment);
        if (oldPatient != address(0)) {
            patients.getPatient(oldPatient).removeTreatment(treatment);
        }
    }
}
