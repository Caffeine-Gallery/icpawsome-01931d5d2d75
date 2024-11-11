import { backend } from "declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { Principal } from "@dfinity/principal";

let principal = null;
let authClient;

async function init() {
    authClient = await AuthClient.create();
    if (await authClient.isAuthenticated()) {
        principal = authClient.getIdentity().getPrincipal();
        handleAuthenticated();
    }
}

async function handleAuthenticated() {
    document.getElementById('loader').classList.add('active');
    try {
        const [name, symbol, balance] = await Promise.all([
            backend.getName(),
            backend.getSymbol(),
            backend.balanceOf(principal)
        ]);

        document.getElementById('tokenInfo').innerHTML = `
            <p>Token Name: ${name}</p>
            <p>Symbol: ${symbol}</p>
        `;
        document.getElementById('balance').textContent = `${balance} ${symbol}`;
    } catch (error) {
        console.error("Error fetching token info:", error);
    } finally {
        document.getElementById('loader').classList.remove('active');
    }
}

document.getElementById('mintBtn').addEventListener('click', async () => {
    document.getElementById('loader').classList.add('active');
    try {
        await backend.mint();
        await handleAuthenticated();
    } catch (error) {
        console.error("Error minting tokens:", error);
        alert("Failed to mint tokens");
    } finally {
        document.getElementById('loader').classList.remove('active');
    }
});

document.getElementById('transferBtn').addEventListener('click', async () => {
    const recipientId = document.getElementById('recipientId').value;
    const amount = parseInt(document.getElementById('amount').value);

    if (!recipientId || !amount) {
        alert("Please fill in all fields");
        return;
    }

    document.getElementById('loader').classList.add('active');
    try {
        const recipient = Principal.fromText(recipientId);
        const result = await backend.transfer(recipient, amount);
        if (result) {
            alert("Transfer successful!");
            await handleAuthenticated();
        } else {
            alert("Transfer failed. Please check your balance and try again.");
        }
    } catch (error) {
        console.error("Error transferring tokens:", error);
        alert("Failed to transfer tokens. Please check the recipient ID and try again.");
    } finally {
        document.getElementById('loader').classList.remove('active');
    }
});

init();
