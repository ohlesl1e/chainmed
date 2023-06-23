<script>
    import { applicationContract } from "$lib/store";
    import { utils } from "ethers";
    let address;
    let name;
    let affiliate;

    const handleSubmit = () => {
        console.log({ address, name, affiliate });
        $applicationContract
            .addDoctor(
                address,
                utils.formatBytes32String(name),
                utils.formatBytes32String(affiliate)
            )
            .then(
                (res) => {
                    console.log(res);
                },
                (reason) => {
                    console.log(reason);
                }
            );
    };
</script>

<div>
    <h1>Add Doctor</h1>
    <form on:submit|preventDefault={handleSubmit}>
        <label for="address">Address</label>
        <input type="text" bind:value={address} /><br />
        <label for="address">Name</label>
        <input type="text" bind:value={name} /><br />
        <label for="address">Affiliate</label>
        <input type="text" bind:value={affiliate} /><br />
        <button type="submit">Submit</button>
    </form>
</div>
