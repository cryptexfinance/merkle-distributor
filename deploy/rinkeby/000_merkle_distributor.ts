import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { deployments, hardhatArguments } from "hardhat";
import "hardhat-deploy/dist/src/type-extensions";

const merkleDistributor: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	if (hardhatArguments.network === "rinkeby") {
		console.log("=====Rinkeby Deploy=====");
		const merkleDistributor = await deployments.getOrNull("MerkleDistributor");
		const { log } = deployments;
		if (!merkleDistributor) {
			const namedAccounts = await hre.getNamedAccounts();

			const rewardToken = "	0xAa715DbD2ED909B7B7727dC864F3B78276D14A19"; // CTX
			const merkleRoot = "0xf3e2ea4c235de14ee793f105dbb1f54a4be38543c2996f3ea8a163363961d109";
			const treasury = "0xa54074b2cc0e96a43048d4a68472F7F046aC0DA8"; // Timelock

			const merkleDistributorDeployment = await deployments.deploy("MerkleDistributor", {
				contract: "MerkleDistributor",
				from: namedAccounts.deployer,
				args: [rewardToken, merkleRoot, treasury],
				skipIfAlreadyDeployed: true,
				log: true,
			});
			log(
				`MerkleDistributor deployed at ${merkleDistributorDeployment.address} for ${merkleDistributorDeployment.receipt?.gasUsed}`
			);
		} else {
			log("MerkleDistributor already deployed");
		}
	}
};

export default merkleDistributor;
