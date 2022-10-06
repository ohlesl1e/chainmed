// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CDTreatment.sol";

contract CDDoctor is Ownable {
    CDTreatment[] private treatments;

    function findCompleted()
        public
        view
        returns (CDTreatment[] memory treatment)
    {
        CDTreatment[] memory temp = new CDTreatment[](1);
        for (uint256 i = 0; i < treatments.length; i) {
            if (treatments[i].isComplete()) {
                temp[0] = treatments[1];
                return temp;
            }
        }
        return new CDTreatment[](0);
    }

    function prescribe(
        address patient_,
        string memory medicine_,
        bytes32 form_,
        Dosage memory dosage_,
        Schedule memory schedule_
    ) public onlyOwner returns (CDTreatment treatment, address oldPatient) {
        CDTreatment[] memory completedTreatment = findCompleted();
        address patient;

        if (completedTreatment.length == 0) {
            // no completed treatment, create new treatment
            CDTreatment newTreatment = new CDTreatment(
                patient_,
                medicine_,
                form_,
                dosage_,
                schedule_
            );
            treatments.push(newTreatment);
            return (newTreatment, address(0));
        } else {
            // reuse completed treatment
            patient = completedTreatment[0].getPatient();
            completedTreatment[0].reset(
                patient_,
                medicine_,
                form_,
                dosage_,
                schedule_
            );
            return (treatment = completedTreatment[0], patient);
        }
    }
}
