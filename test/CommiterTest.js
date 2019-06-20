const Committer = artifacts.require("Committer");

contract('Test Committer Contract', async accounts => {
    let instance;

    beforeEach('Deploy new Instance of Committer', async() => {
        instance = await Committer.new();
    });

    it('should accept a new commitment', async () => {
        let hashMsg = await web3.utils.soliditySha3("My Commitment message");
        let hashSalt = await web3.utils.soliditySha3("User Random Salt # 123");

        await instance.commit(hashMsg, hashSalt, {from: accounts[0]});
   });

    it('should reveal commitment', async () => {
        let hashMsg = await web3.utils.soliditySha3("My Commitment message");
        let hashSalt = await web3.utils.soliditySha3("User Random Salt # 123");

        await instance.commit(hashMsg, hashSalt, {from: accounts[0]});
        await instance.nextState({from: accounts[0]});
        let result = await instance.reveal(await web3.utils.fromAscii("My Commitment message"),web3.utils.fromAscii("User Random Salt # 123"));
        assert(result, 'not reveal the message and salt');
    });
});
