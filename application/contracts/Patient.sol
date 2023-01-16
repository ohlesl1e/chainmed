// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Treatment.sol";
import "./Helper.sol";

contract Patient is AccessControl {
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant APPLICATION_ROLE = keccak256("APPLICATION_ROLE");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");

    bytes32 private name;
    bytes32 private gender;
    uint256 private dob;
    uint16 private height;
    uint16 private weight;
    bool private alcohol;
    bool private smoke;
    bool private cannabis;
    bool private init;
    string[] private allergy;
    address[] private treatments;
    address[] private requests;
    mapping(address => bool) private doctorQueue;
    mapping(address => bool) private appQueue;

    constructor() {
        _setRoleAdmin(PATIENT_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MANAGER_ROLE, PATIENT_ROLE);
        _setRoleAdmin(DOCTOR_ROLE, PATIENT_ROLE);
        _setRoleAdmin(APPLICATION_ROLE, PATIENT_ROLE);
    }

    modifier canWrite() {
        hasWriteAccess();
        _;
    }

    modifier canRead() {
        hasReadAccess();
        _;
    }

    modifier onlyPatient() {
        isPatient();
        _;
    }

    function hasReadAccess() public view {
        require(
            hasRole(DOCTOR_ROLE, msg.sender) ||
                hasRole(PATIENT_ROLE, msg.sender),
            "Need read access"
        );
    }

    function hasWriteAccess() public view {
        require(
            hasRole(DOCTOR_ROLE, msg.sender) ||
                hasRole(PATIENT_ROLE, msg.sender) ||
                hasRole(MANAGER_ROLE, msg.sender) ||
                hasRole(APPLICATION_ROLE, msg.sender),
            "Need write access"
        );
    }

    function isPatient() private view {
        require(hasRole(PATIENT_ROLE, msg.sender), "Not patient");
    }

    function checkDoctor(address user_) external view canWrite returns (bool) {
        return hasRole(DOCTOR_ROLE, user_);
    }

    function initialize(
        address manager_,
        address owner_,
        address app_,
        Bytes32Pair memory nameGender_,
        uint256 dob_,
        SmallUintPair memory physique_,
        string[] memory allergy_,
        BoolTriple memory alcoholSmokeCannabis_
    ) external {
        require(init == false, "Already initialized");
        _setRoleAdmin(PATIENT_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MANAGER_ROLE, PATIENT_ROLE);
        _setRoleAdmin(DOCTOR_ROLE, PATIENT_ROLE);
        _setRoleAdmin(APPLICATION_ROLE, PATIENT_ROLE);
        _setupRole(DEFAULT_ADMIN_ROLE, owner_);
        _setupRole(PATIENT_ROLE, owner_);
        _setupRole(MANAGER_ROLE, manager_);
        if (app_ != address(0)) _setupRole(APPLICATION_ROLE, app_);
        name = nameGender_.value1;
        gender = nameGender_.value2;
        dob = dob_;
        height = physique_.value1;
        weight = physique_.value2;
        allergy = allergy_;
        alcohol = alcoholSmokeCannabis_.value1;
        smoke = alcoholSmokeCannabis_.value2;
        cannabis = alcoholSmokeCannabis_.value3;
        init = true;
    }

    function getInfo()
        external
        view
        canRead
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
            address[] memory,
            address[] memory
        )
    {
        string[] memory allergy_ = allergy;

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
            treatments,
            requests
        );
    }

    function setName(bytes32 name_) external onlyPatient {
        name = name_;
    }

    function setGender(bytes32 gender_) external onlyPatient {
        gender = gender_;
    }

    function setDob(uint256 dob_) external onlyPatient {
        dob = dob_;
    }

    function setPhysique(SmallUintPair memory physique_) external canWrite {
        height = physique_.value1;
        weight = physique_.value2;
    }

    function setHabits(BoolTriple memory habits_) external canWrite {
        alcohol = habits_.value1;
        smoke = habits_.value2;
        cannabis = habits_.value3;
    }

    function addTreatment(address treatment_) external canWrite {
        treatments.push(treatment_);
    }

    function removeTreatment(address oldTreatment) external canWrite {
        uint256 index = findTreatment(oldTreatment);

        if (index != treatments.length) {
            treatments[index] = treatments[treatments.length - 1];
            treatments.pop();
        }
    }

    function findTreatment(address treatment)
        private
        view
        returns (uint256 index)
    {
        uint256 length = treatments.length;
        for (uint256 i = 0; i < length; ) {
            if (treatments[i] == treatment) {
                return i;
            }
            unchecked {
                i++;
            }
        }
        return treatments.length;
    }

    function doctorRequestAccess(address doctor_) external {
        require(!doctorQueue[doctor_], "You already requested access");
        requests.push(doctor_);
        doctorQueue[doctor_] = true;
    }

    function appRequestAccess(address app_) external {
        require(!appQueue[app_], "You already requested access");
        requests.push(app_);
        appQueue[app_] = true;
    }

    function getRequestQueue()
        external
        view
        onlyPatient
        returns (address[] memory queue)
    {
        queue = requests;
    }

    function acceptRequest(address doctor_) external onlyPatient {
        bool requested = false;
        uint256 index = 0;
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i] == doctor_) {
                requested = true;
                index = i;
                break;
            }
        }
        require(requested == true, "No requests record");
        grantRole(DOCTOR_ROLE, doctor_);
        requests[index] = requests[requests.length - 1];
        requests.pop();
    }

    function revokeAccess(address doctor_) external onlyPatient {
        require(doctorQueue[doctor_], "Access not exist");
        revokeRole(DOCTOR_ROLE, doctor_);
        doctorQueue[doctor_] = false;
    }
}