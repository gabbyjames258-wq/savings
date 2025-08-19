import { Clarinet, Tx, Chain, Account, types } from "clarinet";

Clarinet.test({
  name: "Users can deposit and withdraw STX",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let alice = accounts.get("wallet_1")!;
    let bob = accounts.get("wallet_2")!;

    // Alice deposits 100 STX
    let block = chain.mineBlock([
      Tx.contractCall("savings", "deposit", [types.uint(100_000_000)], alice.address),
    ]);
    block.receipts[0].result.expectOk().expectBool(true);

    // Bob deposits 50 STX
    block = chain.mineBlock([
      Tx.contractCall("savings", "deposit", [types.uint(50_000_000)], bob.address),
    ]);
    block.receipts[0].result.expectOk().expectBool(true);

    // Alice withdraws 40 STX
    block = chain.mineBlock([
      Tx.contractCall("savings", "withdraw", [types.uint(40_000_000)], alice.address),
    ]);
    block.receipts[0].result.expectOk().expectBool(true);

    // Check balances
    let aliceBal = chain.callReadOnlyFn("savings", "get-balance", [types.principal(alice.address)], deployer.address);
    aliceBal.result.expectUint(60_000_000);

    let total = chain.callReadOnlyFn("savings", "get-total", [], deployer.address);
    total.result.expectUint(110_000_000);
  },
});
