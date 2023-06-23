// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Application.sol";

contract Chaindoser is Application {
    TreatmentFactory private treatmentFactory = new TreatmentFactory();

    constructor(address manager_, bytes32 name_) Application(manager_, name_) {}

    function prescribe(
        address patient_,
        string memory medicine_,
        bytes32 form_,
        Dosage memory dosage_,
        Schedule memory schedule_
    ) external {
        Patient patient = Patient(manager.getPatient(patient_));
        Doctor doctor = Doctor(manager.getDoctor(msg.sender));
        require(
            address(patient) != address(0) && address(doctor) != address(0),
            "Patient or doctor in not a user"
        );
        require(patient.checkDoctor(msg.sender), "User does not have DOCTOR_ROLE to prescribe");

        address newTreatment = treatmentFactory.createTreatment(
            msg.sender,
            patient_,
            medicine_,
            form_,
            dosage_,
            schedule_
        );
        doctor.addTreatment(newTreatment);
        patient.addTreatment(newTreatment);
    }
}
