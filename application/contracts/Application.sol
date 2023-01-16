// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Doctor.sol";
import "./Patient.sol";
import "./Treatment.sol";
import "./TreatmentFactory.sol";
import "./Manager.sol";
import "./Helper.sol";

contract Application {
    Manager private manager;
    TreatmentFactory private treatmentFactory = new TreatmentFactory();

    constructor(address manager_) {
        manager = Manager(manager_);
    }

    function addDoctor(
        address owner_,
        bytes32 name_,
        bytes32 affiliate_
    ) external {
        require(manager.getDoctor(msg.sender) == address(0), "Profile existed");
        manager.addDoctor(owner_, name_, affiliate_, true);
    }

    function addPatient(
        Bytes32Pair memory nameGender_,
        uint256 dob_,
        SmallUintPair memory physique_,
        string[] memory allergy_,
        BoolTriple memory habits_
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
            FromAppOption(true, msg.sender)
        );
    }

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
        require(patient.checkDoctor(msg.sender), "User does not have access");

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
