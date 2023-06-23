const Chaindoser = artifacts.require("Chaindoser");
const Manager = artifacts.require("Manager");

module.exports = function (deployer) {
  deployer.deploy(Manager).then((manager) => {
    return deployer.deploy(Chaindoser, Manager.address, web3.utils.padRight(web3.utils.asciiToHex("Chaindoser"), 64)).then(async (application) => {
      let appRole = await manager.APPLICATION_ROLE()
      await manager.grantRole(appRole, application.address)
    })
  })
};
