export const connectWallet = (provider) => { 
    provider
			.send('eth_requestAccounts', [])
			.catch(() => console.log('user rejected request'));
 }