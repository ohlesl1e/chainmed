// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DoctorFactory.sol";
import "./PatientFactory.sol";

contract Manager {
    mapping(address => address) private doctors;
    mapping(address => address) private patients;
    DoctorFactory private doctorFactory = new DoctorFactory();
    PatientFactory private patientFactory = new PatientFactory();

    function getPatient(address owner_) public view returns (address patient) {
        patient = patients[owner_];
    }

    function getDoctor(address owner_) public view returns (address doctor) {
        doctor = doctors[owner_];
    }

    function addDoctor(
        address owner_,
        bytes32 name_,
        bytes32 affiliate_,
        bool fromApp_
    ) public {
        require(doctors[owner_] == address(0), "Profile existed");
        doctors[owner_] = doctorFactory.createDoctor(
            owner_,
            name_,
            affiliate_,
            FromAppOption(fromApp_, msg.sender)
        );
    }

    function addPatient(
        Bytes32Pair memory nameGender_,
        uint256 dob_,
        SmallUintPair memory physique_,
        string[] memory allergy_,
        BoolTriple memory habits_,
        FromAppOption memory option_
    ) external {
        require(patients[option_.addr] == address(0), "Profile existed");
        patients[option_.addr] = patientFactory.createPatient(
            option_.addr,
            nameGender_,
            dob_,
            physique_,
            allergy_,
            habits_,
            FromAppOption(option_.fromApp, msg.sender)
        );
    }

    function doctorRequest(address patient_) external {
        require(
            doctors[msg.sender] != address(0) &&
                patients[patient_] != address(0),
            "Doctor or patient is not a user"
        );
        Patient patient = Patient(patients[patient_]);
        patient.doctorRequestAccess(msg.sender);
    }

    function getDoctorInfo(address[] memory doctors_)
        external
        view
        returns (DoctorStruct[] memory docInfo)
    {
        docInfo = new DoctorStruct[](doctors_.length);
        for (uint256 i = 0; i < doctors_.length; i++) {
            if (doctors[doctors_[i]] == address(0)) {
                docInfo[i] = DoctorStruct(bytes32(0), bytes32(0));
            } else {
                (bytes32 name, bytes32 affiliate) = Doctor(doctors[doctors_[i]])
                    .getInfo();
                docInfo[i] = DoctorStruct(name, affiliate);
            }
        }
    }

    function applicationRequest(address patient_) external {
        require(patients[patient_] != address(0), "Patient is not a user");
        Patient patient = Patient(patients[patient_]);
        patient.appRequestAccess(msg.sender);
    }
}