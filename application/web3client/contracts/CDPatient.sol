// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./CDTreatment.sol";

contract CDPatient is AccessControl {
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");

    bytes32 private name;
    bytes32 private gender;
    uint private dob;
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
        uint dob_,
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
            uint,
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
}
