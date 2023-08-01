// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Treatment.sol";
import "./TreatmentFactory.sol";

struct DoctorStruct {
    bytes32 name;
    bytes32 affiliate;
}

contract Doctor is AccessControl {
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    bytes32 private name;
    bytes32 private affiliate;
    address[] private treatments;
    bool private init;

    constructor() {
        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    modifier canWrite() {
        hasWriteAccess();
        _;
    }

    function hasWriteAccess() private view {
        require(
            hasRole(MANAGER_ROLE, msg.sender) ||
                hasRole(DOCTOR_ROLE, msg.sender),
            "Need write access"
        );
    }

    function initialize(
        address owner_,
        address manager_,
        bytes32 name_,
        bytes32 affiliate_
    ) external {
        require(init == false, "Already initialized");
        _setupRole(DOCTOR_ROLE, owner_);
        _setupRole(MANAGER_ROLE, manager_);
        _setRoleAdmin(MANAGER_ROLE, DOCTOR_ROLE);

        name = name_;
        affiliate = affiliate_;
        init = true;
    }

    function getInfo()
        external
        view
        returns (bytes32 name_, bytes32 affiliate_)
    {
        name_ = name;
        affiliate_ = affiliate;
    }

    function addTreatment(address treatment_) external onlyRole(MANAGER_ROLE) {
        treatments.push(treatment_);
    }

    function getTreatments()
        external
        view
        onlyRole(DOCTOR_ROLE)
        returns (address[] memory)
    {
        return treatments;
    }
}
