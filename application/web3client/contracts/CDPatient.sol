// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CDPatient is ERC20, AccessControl {
    

    constructor() ERC20("CDPatient", "CDP") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}