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

contract CDTreatment is AccessControl {
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    address private patient;
    string private medicine;
    bytes32 private form;
    Dosage private dosage;
    Schedule private schedule;

    constructor(
        address patient_,
        string memory medicine_,
        bytes32 form_,
        Dosage memory dosage_,
        Schedule memory schedule_
    ) {
        _setRoleAdmin(PATIENT_ROLE, DEFAULT_ADMIN_ROLE);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PATIENT_ROLE, patient_);

        patient = patient_;
        medicine = medicine_;
        form = form_;
        dosage = dosage_;
        schedule = schedule_;
    }

    modifier canRead() {
        _canRead();
        _;
    }

    modifier onlyCompleted() {
        require(isComplete());
        _;
    }

    function _canRead( ) private view {
        require(
            hasRole(PATIENT_ROLE, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)
        );
    }

    function getPatient() public view returns (address) {
        return patient;
    }

    function getTreatment()
        public
        view
        returns (
            string memory,
            bytes32,
            Dosage memory,
            Schedule memory
        )
    {
        string memory medicine_ = medicine;
        Dosage memory dosage_ = dosage;
        Schedule memory schedule_ = schedule;
        return (medicine_, form, dosage_, schedule_);
    }

    function isComplete() public view returns (bool) {
        return schedule.endDate < block.timestamp * 1000;
    }

    function edit(string memory medicine_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        medicine = medicine_;
    }

    function edit(bytes32 form_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        form = form_;
    }

    function edit(Dosage memory dosage_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        dosage = dosage_;
    }

    function edit(Schedule memory schedule_)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        schedule = schedule_;
    }

    function reset(
        address patient_,
        string memory medicine_,
        bytes32 form_,
        Dosage memory dosage_,
        Schedule memory schedule_
    ) public onlyCompleted onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(PATIENT_ROLE, patient);
        _grantRole(PATIENT_ROLE, patient_);

        patient = patient_;
        medicine = medicine_;
        form = form_;
        dosage = dosage_;
        schedule = schedule_;
    }
}
