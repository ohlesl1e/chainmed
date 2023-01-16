export const ssr = false
import { derived, get, writable } from 'svelte/store'
import { Contract, constants, providers } from 'ethers'
import { browser } from '$app/environment'
import { NETWORKS } from '$lib/config'
import { applicationContract, token } from '$lib/store'
import { PUBLIC_APP_CONTRACT_ADDRESS } from "$env/static/public";
import Application from "$lib/contracts/Application.json";

export const networkProviders = [new providers.JsonRpcProvider(NETWORKS[0].rpcUrl)]
export const selectedNetworkIndex = writable(0)

export const accountProvider = writable(undefined)
export const accountChainId = writable({ chainId: 1, supportedNetwork: true })
export const connected = derived(accountProvider, $accountProvider => $accountProvider ? true : false)
export const walletAddress = writable(constants.AddressZero);

let disconnectListener

export const connectMetamask = () => new Promise((resolve, reject) => {
    if (!window.ethereum) reject('No injected provider found')
    else {
        try {
            window.ethereum.request({ method: 'eth_accounts' }).then(res => {
                if (res.length > 0) {
                    accountProvider.set(new providers.Web3Provider(window.ethereum))
                    window.sessionStorage.setItem('connectType', 'metamask');
                    setApplication()
                }
                else {
                    window.ethereum.request({ method: 'eth_requestAccounts' }).then((accounts) => {
                        if (accounts.length > 0) {
                            accountProvider.update(provider => {
                                if (provider) {
                                    get(accountProvider).removeListener('disconnect', disconnectListener);
                                }
                                return new providers.Web3Provider(window.ethereum);
                            })
                            window.sessionStorage.setItem('connectType', 'metamask');
                            disconnectListener = () => {
                                get(accountProvider).removeListener('disconnect', disconnectListener);
                                accountProvider.set(undefined);
                                walletAddress.set(constants.AddressZero);
                            }
                            get(accountProvider).on('disconnect', disconnectListener);
                            setApplication()
                            // const chainId = BigNumber.from(get(accountProvider).getNetwork().chainId).toNumber();
                            // const supportedNetwork = NETWORKS.filter(network => network.chainId === chainId).length > 0;
                            // if (supportedNetwork) selectedNetworkIndex.set(NETWORKS.findIndex(network => network.chainId === chainId));
                            // accountChainId.set({ chainId, supportedNetwork });
                            walletAddress.set(accounts[0]);
                        }
                    });
                }
            })

            resolve(true);
        } catch (error) {
            reject(error);
        }
    }
})

if (browser && JSON.parse(window.sessionStorage.getItem('connected'))) {
    if (window.sessionStorage.getItem('connectType') === 'metamask') {
        if (window.ethereum.selectedAddress) connectMetamask();
    }
    if (window.sessionStorage.getItem('connectType') === 'walletconnect') {
        const providerInstance = new WalletConnectProvider({ rpc: NETWORKS.reduce((networks, network) => ({ ...networks, [network.chainId]: network.rpcUrl }), {}) });
        if (providerInstance.connected) connectWalletConnect();
    }
}

connected.subscribe((value) => {
    if (browser) window.sessionStorage.setItem('connected', JSON.stringify(value));
})

export const disconnect = () => {
    if (get(accountProvider)) {
        get(accountProvider).removeListener('disconnect', disconnectListener);
        accountProvider.set(undefined);
        walletAddress.set(constants.AddressZero);
        token.set(undefined)
    }
}

export const setApplication = () => {
    applicationContract.set(
        new Contract(
            PUBLIC_APP_CONTRACT_ADDRESS,
            Application.abi,
            get(accountProvider).getSigner()
        )
    )
    console.log(get(applicationContract));
}