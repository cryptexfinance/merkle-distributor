import airdrop from "./example.json";
import BalanceTree from "./balance-tree";
import { ethers } from "ethers";

console.log(airdrop);
const airdropAccounts = airdrop.map((drop: any) => ({
	account: drop.address,
	amount: ethers.utils.parseEther(drop.earnings.toString()),
}));

const tree = new BalanceTree(airdropAccounts);
const root = tree.getHexRoot();
console.log(root);

const proof0 = tree.getProof(
	0,
	"0x097a3a6ce1d77a11bda1ac40c08fdf9f6202103f",
	ethers.utils.parseEther("50")
);
const proof1 = tree.getProof(
	1,
	"0xfa6863a6507c94ed52e9276f8a72479924e77a36",
	ethers.utils.parseEther("100")
);

console.log("proof0: ", proof0);
console.log("proof1: ", proof1);
