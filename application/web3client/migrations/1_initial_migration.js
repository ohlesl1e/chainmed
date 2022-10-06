var CDDoctorManager = artifacts.require('./CDDoctorManager.sol')
var CDPatientManager = artifacts.require('./CDPatientManager.sol')

module.exports = (deployer) => {
    deployer.deploy(CDDoctorManager)
    deployer.deploy(CDPatientManager)
}