<script>
    import { getContext } from 'svelte';
    import CDDoctor from '$lib/contracts/CDDoctor.json';
    import { ContractFactory } from 'ethers';

    let manager = getContext('dm');
    let provider = getContext('provider');
    let address;
    let profileAddress;

    const handleSubmit = (e) => {
        e.preventDefault();
        console.log(address);
        const doctorFactory = new ContractFactory(
            CDDoctor.abi,
            CDDoctor.bytecode,
            provider.getSigner()
        );
        doctorFactory.deploy(address).then(
            (value) => {
                profileAddress = value.address;
                manager.addDoctor(address, value.address).then(
                    (res) => {
                        alert(`Added ${address}`);
                    },
                    (err) => {
                        console.log(err);
                        alert(`Failed to add ${address}, profile address: ${profileAddress}`);
                    }
                );
            },
            (reason) => {
                console.log(reason);
            }
        );
    };
</script>

<div>
    <h1>Add Doctor</h1>
    <form on:submit={(e) => handleSubmit(e)}>
        <label for="address">Address</label>
        <input type="text" bind:value={address} />
        <button type="submit">Submit</button>
    </form>
</div>
