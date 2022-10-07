// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CDDoctorManager.sol";
import "./CDPatientManager.sol";

contract CDApplicationManager {
    CDDoctorManager private doctorManager;
    CDPatientManager private patientManager;
}
