// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

struct Dosage {
    uint32 strength;
    byte32 unit;
}

enum Frequency {
    Interval,
    DaysOfWeek,
    AsNeeded
}

struct Schedule {
    Frenquency frequency;
    uint8 interval;
    bytes16[7] daysOfWeek;
    unit8[] timesOfDay;
}

contract CDTreatment is ERC721, ERC721Enumerable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    string private medicine;
    string private form;
    Dosage private dosage;
    Schedule private schedule;

    constructor() ERC721("CDTreatment", "CDT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function safeMint(address to, uint256 tokenId)
        public
        onlyRole(MINTER_ROLE)
    {
        _safeMint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getTreatment() view public returns (string, string, Dosage, Schedule) {
        return (medicine, form, dosage, schedule);
    }
}
