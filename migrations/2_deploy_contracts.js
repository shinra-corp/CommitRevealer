const Committer = artifacts.require("Committer");

module.exports = function(deployer) {
    deployer.deploy(Committer);
}
