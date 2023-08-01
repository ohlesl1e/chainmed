// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./Treatment.sol";
import "./Helper.sol";

contract Patient is AccessControlEnumerable {
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant APPLICATION_ROLE = keccak256("APPLICATION_ROLE");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");

    string private info;
    bool private init;
    address[] private treatments;
    address[] private requests;
    mapping(address => bool) private doctorQueue;
    string[] private updates;

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

    event updateRemoved(address indexed sender, bytes result);

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
        string memory info_
    ) external {
        require(init == false, "Already initialized");
        _setRoleAdmin(PATIENT_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MANAGER_ROLE, PATIENT_ROLE);
        _setRoleAdmin(DOCTOR_ROLE, PATIENT_ROLE);
        _setRoleAdmin(APPLICATION_ROLE, PATIENT_ROLE);
        _setupRole(DEFAULT_ADMIN_ROLE, owner_);
        _setupRole(PATIENT_ROLE, owner_);
        _setupRole(MANAGER_ROLE, manager_);
        info = info_;
        init = true;
    }

    function getInfo() external view canRead returns (string memory) {
        return info;
    }

    function getRequests()
        external
        view
        onlyPatient
        returns (address[] memory)
    {
        return requests;
    }

    function getTreatments() external view canRead returns (address[] memory) {
        return treatments;
    }

    function getUpdates() external view canRead returns (string[] memory) {
        return updates;
    }

    function addUpdate(string memory newInfo) external canWrite {
        updates.push(newInfo);
    }

    function approveUpdate(uint256 index) external onlyPatient {
        require(index < updates.length, "index out of bound");

        info = updates[index]; //update the current value

        //remove the updates
        (bool success, bytes memory result) = address(this).delegatecall(
            abi.encodeWithSignature("removeUpdate(uint256)", index)
        );
        require(success, "Delegate call failed");

        emit updateRemoved(msg.sender, result);
    }

    function removeUpdate(uint256 index) public onlyPatient {
        for (uint i = index; i < updates.length - 1; i++) {
            updates[i] = updates[i + 1];
        }
        updates.pop();
    }

    function updateInfo(string memory info_) external onlyPatient {
        info = info_;
    }

    function addTreatment(
        address treatment_
    ) external onlyRole(APPLICATION_ROLE) {
        treatments.push(treatment_);
    }

    function removeTreatment(
        address oldTreatment
    ) external onlyRole(APPLICATION_ROLE) {
        uint256 index = findTreatment(oldTreatment);

        if (index != treatments.length) {
            treatments[index] = treatments[treatments.length - 1];
            treatments.pop();
        }
    }

    function findTreatment(
        address treatment
    ) private view returns (uint256 index) {
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
