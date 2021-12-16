const { expect } = require('chai');


describe("Reentrancy Hack", () => {

    let addr1, addr2, attacker; 

    beforeEach(async () => {
        [addr1, addr2, attacker, _] = await ethers.getSigners();
    });



    describe("Attack on Vulnerable Contract", () => {

        let Vulnerable, vulnerable, AttackVulnerable, attackVulnerable;

        beforeEach(async () => {
            Vulnerable = await ethers.getContractFactory("VulnerableToReentrancy");
            vulnerable = await Vulnerable.deploy();
            // deposit 1 eth from 1st account
            await vulnerable.connect(addr1).deposit({value: ethers.utils.parseEther("1.0")}); 
            // deposit 1 eth from 2nd account
            await vulnerable.connect(addr2).deposit({value: ethers.utils.parseEther("1.0")}); 
        });

        it("Vulnerable contract should have a balance of 2 eth", async () => {
            expect(await vulnerable.getBalance()).to.equal(ethers.utils.parseEther("2.0"));
        });



        describe("Running Attack", () => {

            beforeEach(async () => {
                //deploying attack contract
                AttackVulnerable = await ethers.getContractFactory("AttackVulnerableToReentrancy");
                attackVulnerable = await AttackVulnerable.deploy(vulnerable.address);
                // attacker calls attack function, sending 1 eth with call
                await attackVulnerable.connect(attacker).attack({value: ethers.utils.parseEther("1.0")})
                });

            it("Attack contract should have balance of 3 eth after attack (includes the 1 ether they deposited to start the attack)", async () => {
                expect(await attackVulnerable.getBalance()).to.equal(ethers.utils.parseEther("3.0"));
            });

            it("Vulnerable contract should have balance of 0 eth after attack", async () => {
                expect(await vulnerable.getBalance()).to.equal(0);
            });
        });
    });





    describe("Attack on Secured Contract", () => {

        let Secured, secured, AttackSecured, attackSecured;

        beforeEach(async () => {
            Secured = await ethers.getContractFactory("PreventReentrancy");
            secured = await Secured.deploy();
            // deposit 1 eth from 1st account
            await secured.connect(addr1).deposit({value: ethers.utils.parseEther("1.0")}); 
            // deposit 1 eth from 2nd account
            await secured.connect(addr2).deposit({value: ethers.utils.parseEther("1.0")}); 
        });

        it("Secured contract should have a balance of 2 eth", async () => {
            expect(await secured.getBalance()).to.equal(ethers.utils.parseEther("2.0"));
        });
        


        describe("Running Attack", () => {

            beforeEach(async () => {
                //deploying attack contract
                AttackSecured = await ethers.getContractFactory("AttackPreventReentrancy");
                attackSecured = await AttackSecured.deploy(secured.address);
                });

            it("Attack should be reverted with \"Failure to send Eth\"", async () => {
                // attacker calls attack function, sending 1 eth with call
                await expect(attackSecured.connect(attacker).attack({value: ethers.utils.parseEther("1.0")})).to.be.revertedWith("Failure to send Eth");
            });

            it("Attack contract should have balance of 0 eth after attack (the entire transaction gets reverted)", async () => {
                expect(await attackSecured.getBalance()).to.equal(ethers.utils.parseEther("0.0"));
            });

            it("Secured contract should have balance of 2 eth after attack", async () => {
                expect(await secured.getBalance()).to.equal(ethers.utils.parseEther("2.0"));
            });
        });
    });
});