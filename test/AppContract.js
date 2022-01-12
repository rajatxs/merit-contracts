// @ts-nocheck
const AppContract = artifacts.require('App');

require('chai').use(require('chai-as-promised')).should();

let appContract, account, options;

contract('AppContract', (accounts) => {
   describe('Contract deployment', function () {
      this.beforeAll(async function () {
         appContract = await AppContract.deployed();
         [account] = accounts;
   
         options = { from: account };
      });

      it("Should able to publish new article", async () => {
         const articleNumber = await appContract.publishArticle.call('Abc', 1, options);

         assert.isAtLeast(Number(articleNumber), 1);
      });
   });
});
