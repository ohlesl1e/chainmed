export const ssr = false
import { derived, get, writable } from 'svelte/store'
import { Contract, constants, providers, BigNumber } from 'ethers'
import { browser } from '$app/environment'
import { NETWORKS } from '$lib/config'
import { provider, applicationContract, managerContract, token } from '$lib/store'
import { PUBLIC_APPLICATION_ADDRESS, PUBLIC_MANAGER_ADDRESS } from "$env/static/public";
import Chaindoser from "$lib/contracts/Chaindoser.json";
import Manager from '$lib/contracts/Manager.json'

export const networkProviders = [new providers.JsonRpcProvider(NETWORKS[0].rpcUrl)]
export const selectedNetworkIndex = writable(0)

export const accountProvider = writable(undefined)
export const accountChainId = writable({ chainId: 1, supportedNetwork: true })
export const connected = derived(accountProvider, $accountProvider => $accountProvider ? true : false)
export const walletAddress = writable(constants.AddressZero);

let disconnectListener, chainChangedListener, accountsChangedListener

export const connectMetamask = () => new Promise((resolve, reject) => {
    if (!window['ethereum']) reject('No injected provider found');
    else {
        try {
            window['ethereum'].request({ method: 'eth_requestAccounts' }).then((accounts) => {
                if (accounts.length > 0) {
                    accountProvider.update(provider => {
                        if (provider) {
                            get(accountProvider).removeListener('accountsChanged', accountsChangedListener);
                            get(accountProvider).removeListener('chainChanged', chainChangedListener);
                            get(accountProvider).removeListener('disconnect', disconnectListener);
                        }
                        return window['ethereum'];
                    })
                    localStorage.setItem('connectType', 'metamask');
                    disconnectListener = () => {
                        get(accountProvider).removeListener('accountsChanged', accountsChangedListener);
                        get(accountProvider).removeListener('chainChanged', chainChangedListener);
                        get(accountProvider).removeListener('disconnect', disconnectListener);
                        accountProvider.set(undefined);
                        walletAddress.set(constants.AddressZero);
                    }
                    get(accountProvider).on('disconnect', disconnectListener);
                    const chainId = BigNumber.from(get(accountProvider).chainId).toNumber();
                    const supportedNetwork = NETWORKS.filter(network => network.chainId === chainId).length > 0;
                    if (supportedNetwork) selectedNetworkIndex.set(NETWORKS.findIndex(network => network.chainId === chainId));
                    accountChainId.set({ chainId, supportedNetwork });
                    walletAddress.set(accounts[0]);
                    accountsChangedListener = (accounts) => {
                        if (accounts.length > 0) walletAddress.set(accounts[0]);
                        else {
                            walletAddress.set(constants.AddressZero);
                            accountProvider.set(undefined);
                        }
                    }
                    get(accountProvider).on('accountsChanged', accountsChangedListener);
                    chainChangedListener = (chainIdHex) => {
                        console.log(chainIdHex);
                        const chainId = BigNumber.from(chainIdHex).toNumber();
                        const supportedNetwork = NETWORKS.filter(network => network.chainId === chainId).length > 0;
                        if (supportedNetwork) selectedNetworkIndex.set(NETWORKS.findIndex(network => network.chainId === chainId));
                        accountChainId.set({ chainId, supportedNetwork });
                    }
                    get(accountProvider).on('chainChanged', chainChangedListener);
                    provider.set(new providers.Web3Provider(get(accountProvider)))
                }
            });
            resolve(true);
        } catch (error) {
            reject(error);
        }
    }
})

if (browser && JSON.parse(window.localStorage.getItem('connected'))) {
    if (window.localStorage.getItem('connectType') === 'metamask') {
        if (window.ethereum.selectedAddress) connectMetamask();
    }
    if (window.localStorage.getItem('connectType') === 'walletconnect') {
        const providerInstance = new WalletConnectProvider({ rpc: NETWORKS.reduce((networks, network) => ({ ...networks, [network.chainId]: network.rpcUrl }), {}) });
        if (providerInstance.connected) connectWalletConnect();
    }
}

connected.subscribe((value) => {
    if (browser) window.localStorage.setItem('connected', JSON.stringify(value));
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
            PUBLIC_APPLICATION_ADDRESS,
            Chaindoser.abi,
            get(provider).getSigner()
        )
    )
    managerContract.set(
        new Contract(
            PUBLIC_MANAGER_ADDRESS,
            Manager.abi,
            get(provider).getSigner()
        )
    )
    console.log(get(applicationContract));
    console.log(get(managerContract));
}