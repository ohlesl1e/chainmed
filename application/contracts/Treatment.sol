// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
struct Dosage {
    uint16 strength;
    bytes32 unit;
}

enum Frequency {
    Interval,
    DaysOfWeek,
    AsNeeded
}

struct Schedule {
    uint256 startDate;
    uint256 endDate;
    Frequency frequency;
    uint8 interval;
    bytes32[] daysOfWeek;
    uint16[] timesOfDay;
}

contract Treatment is AccessControl {
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");

    address private patient;
    bytes32 private form;
    Dosage private dosage;
    Schedule private schedule;
    string private medicine;
    bool private init;

    constructor() {}

    modifier canRead() {
        hasReadAccess();
        _;
    }

    function hasReadAccess() private view {
        require(
            hasRole(PATIENT_ROLE, msg.sender) ||
                hasRole(DOCTOR_ROLE, msg.sender)
        );
    }

    function initialize(
        address doctor_,
        address patient_,
        string memory medicine_,
        bytes32 form_,
        Dosage memory dosage_,
        Schedule memory schedule_
    ) external {
        require(init == false, "Already initialized");
        _setRoleAdmin(DOCTOR_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PATIENT_ROLE, DOCTOR_ROLE);
        _setupRole(PATIENT_ROLE, patient_);
        _setupRole(DOCTOR_ROLE, doctor_);

        patient = patient_;
        medicine = medicine_;
        form = form_;
        dosage = dosage_;
        schedule = schedule_;
        init = true;
    }

    function getPatient() external view canRead returns (address) {
        return patient;
    }

    function getMedicine()
        external
        view
        returns (string memory medicine_, bool isComplete_)
    {
        return (medicine, isComplete());
    }

    function getTreatment()
        external
        view
        canRead
        returns (
            string memory,
            bytes32,
            Dosage memory,
            Schedule memory,
            bool
        )
    {
        string memory medicine_ = medicine;
        Dosage memory dosage_ = dosage;
        Schedule memory schedule_ = schedule;
        return (medicine_, form, dosage_, schedule_, isComplete());
    }

    function isComplete() private view returns (bool) {
        return schedule.endDate < block.timestamp * 1000;
    }

    function edit(string memory medicine_) external onlyRole(DOCTOR_ROLE) {
        medicine = medicine_;
    }

    function edit(bytes32 form_) external onlyRole(DOCTOR_ROLE) {
        form = form_;
    }

    function edit(Dosage memory dosage_) external onlyRole(DOCTOR_ROLE) {
        dosage = dosage_;
    }

    function edit(Schedule memory schedule_) external onlyRole(DOCTOR_ROLE) {
        schedule = schedule_;
    }
}
