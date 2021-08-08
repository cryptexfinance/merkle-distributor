import airdrop from "./example.json";
import BalanceTree from "./balance-tree";
import { ethers } from "ethers";

const airdropAccounts = airdrop.map((drop: any) => ({
	account: drop.address,
	amount: ethers.utils.parseEther(drop.earnings.toString()),
}));

const tree = new BalanceTree(airdropAccounts);
const root = tree.getHexRoot();
console.log(root);

const proof0 = tree.getProof(
	0,
	"0x1FdD5814d3d23fBF93849B530c825eAd5f83D63f",
	ethers.utils.parseEther("50")
);
const proof1 = tree.getProof(
	1,
	"0x76927E2CCAb0084BD19cEe74F78B63134b9d181E",
	ethers.utils.parseEther("50")
);

console.log("proof0: ", proof0);
console.log("proof1: ", proof1);
