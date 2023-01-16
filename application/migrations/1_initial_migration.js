const Application = artifacts.require("Application");
const Manager = artifacts.require("Manager");

module.exports = function (deployer) {
  deployer.deploy(Manager).then(() => {
    return deployer.deploy(Application, Manager.address)
  })
};
