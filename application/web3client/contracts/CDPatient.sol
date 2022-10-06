// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./CDTreatment.sol";

struct TreatmentStruct {
    string medicine;
    bytes32 form;
    Dosage dosage;
    Schedule schedule;
}

contract CDPatient is AccessControl {
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");

    bytes32 private name;
    bytes32 private gender;
    uint256 private dob;
    uint16 private height;
    uint16 private weight;
    string[] private allergy;
    bool private alcohol;
    bool private smoke;
    bool private cannabis;
    CDTreatment[] treatments;

    constructor(
        address owner_,
        bytes32 name_,
        bytes32 gender_,
        uint256 dob_,
        uint16 height_,
        uint16 weight_,
        string[] memory allergy_,
        bool alcohol_,
        bool smoke_,
        bool cannabis_
    ) {
        _setRoleAdmin(PATIENT_ROLE, DEFAULT_ADMIN_ROLE);
        _grantRole(PATIENT_ROLE, owner_);

        name = name_;
        gender = gender_;
        dob = dob_;
        height = height_;
        weight = weight_;
        allergy = allergy_;
        alcohol = alcohol_;
        smoke = smoke_;
        cannabis = cannabis_;
    }

    modifier canWrite() {
        require(
            hasRole(DOCTOR_ROLE, msg.sender) ||
                hasRole(PATIENT_ROLE, msg.sender)
        );
        _;
    }

    modifier canRead() {
        require(
            hasRole(DOCTOR_ROLE, msg.sender) ||
                hasRole(PATIENT_ROLE, msg.sender)
        );
        _;
    }

    function getInfo()
        public
        view
        returns (
            bytes32,
            bytes32,
            uint256,
            uint16,
            uint16,
            string[] memory,
            bool,
            bool,
            bool,
            CDTreatment[] memory
        )
    {
        string[] memory allergy_ = allergy;
        CDTreatment[] memory treatments_ = treatments;

        return (
            name,
            gender,
            dob,
            height,
            weight,
            allergy_,
            alcohol,
            smoke,
            cannabis,
            treatments_
        );
    }

    function addTreatment(CDTreatment newTreatment) public {
        treatments.push(newTreatment);
    }

    function removeTreatment(CDTreatment oldTreatment) public {
        uint256 index = findTreatment(oldTreatment);

        if (index != treatments.length) {
            treatments[index] = treatments[treatments.length - 1];
            treatments.pop();
        }
    }

    function findTreatment(CDTreatment treatment)
        private
        view
        returns (uint256 index)
    {
        for (uint256 i = 0; i < treatments.length; i++) {
            if (treatments[i] == treatment) {
                return i;
            }
        }
        return treatments.length;
    }

    function getTreatments() public view returns (TreatmentStruct[] memory) {
        TreatmentStruct[] memory temp = new TreatmentStruct[](
            treatments.length
        );

        for (uint256 i = 0; i < treatments.length; i) {
            (
                string memory medicine_,
                bytes32 form_,
                Dosage memory dosage_,
                Schedule memory schedule_
            ) = treatments[i].getTreatment();
            temp[i] = TreatmentStruct(medicine_, form_, dosage_, schedule_);
        }
        return temp;
    }
}
