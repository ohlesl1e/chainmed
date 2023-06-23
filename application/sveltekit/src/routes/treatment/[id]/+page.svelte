<script>
    import { accountProvider as provider } from "$lib/provider";
    import Treatment from "$lib/contracts/Treatment.json";
    import { onMount } from "svelte";
    import { ethers, utils, BigNumber } from "ethers";
    import { Bar } from "svelte-chartjs";
    import {
        Chart,
        Title,
        Tooltip,
        Legend,
        BarElement,
        CategoryScale,
        LinearScale,
    } from "chart.js";

    Chart.register(
        Title,
        Tooltip,
        Legend,
        BarElement,
        CategoryScale,
        LinearScale
    );

    /** @type {import('./$types').PageData} */
    export let data;
    console.log(data.id);
    let treatment;
    let reportData;
    let treatmentContract;
    onMount(async () => {
        treatmentContract = new ethers.Contract(
            data.id,
            Treatment.abi,
            $provider.getSigner()
        );
        let res = await treatmentContract.getTreatment();
        treatment = {
            id: data.id,
            medicine: res[0],
            form: utils.parseBytes32String(res[1]),
            dosage: {
                strength: res[2].strength,
                unit: utils.parseBytes32String(res[2].unit),
            },
            schedule: {
                startDate: new Date(
                    BigNumber.from(res[3].startDate).toNumber()
                ).toLocaleDateString(),
                endDate: new Date(
                    BigNumber.from(res[3].endDate).toNumber()
                ).toLocaleDateString(),
                frequency: res[3].frequency,
                interval: res[3].interval,
                daysOfWeek: res[3].daysOfWeek.map((value) =>
                    utils.parseBytes32String(value)
                ),
                timesOfDay: res[3].timesOfDay.map((value) => {
                    return `${String(Math.floor(value / 100)).padStart(
                        2,
                        "0"
                    )}:${String(value % 100).padStart(2, "0")}`;
                }),
            },
            complete: res[4],
        };
        let rep = await fetch("/api/check", {
            method: "POST",
            body: JSON.stringify({
                address: treatment.id,
                schedule: { frequency: 0, interval: 7 },
            }),
        });
        let report = await rep.json();
        let today = new Date(Date.now());
        let labels = [];
        let dataMap = {};
        for (let i = 0; i < 8; i++) {
            labels.push(today.toLocaleDateString());
            dataMap[today.toLocaleDateString()] = 0;
            today.setDate(today.getDate() - 1);
        }
        report.forEach((element) => {
            let reportDate = new Date(element.report_time);
            dataMap[reportDate.toLocaleDateString()]++;
        });
        reportData = {
            labels: labels.reverse(),
            datasets: [
                {
                    label: "Number of reports",
                    data: Object.values(dataMap).reverse(),
                    backgroundColor: Array(7).fill("rgba(255, 218, 128, 0.4)"),
                    borderWidth: 2,
                    borderColor: Array(7).fill("rgba(255, 218, 128, 1)"),
                },
            ],
        };
        console.log({ res, treatment, reportData });
    });

    const sendReminder = async () => {
        let patient = await treatmentContract.getPatient();
        let res = await fetch("/api/push", {
            method: "POST",
            body: JSON.stringify({ address: patient, treatment: treatment.id }),
        });
        console.log(await res.json());
    };
</script>

<div class="flex flex-col">
    {#if treatment}
        <div class="w-20/22">
            <h2>Treatment Summary</h2>
            <p class="block text-md text-gray-200">
                <strong>Treatment ID:</strong>
                {treatment.id}<br />
                <strong>Medicine:</strong>
                {treatment.medicine}<br />
                <strong>Duration:</strong>
                {treatment.schedule.startDate} - {treatment.schedule.endDate}<br
                />
                {#if treatment.schedule.frequency === 0}
                    {#if treatment.schedule.interval === 1}
                        Every day
                    {:else if treatment.schedule.interval === 2}
                        Every other days
                    {:else}
                        Every {treatment.schedule.interval} days
                    {/if}
                    <ul class="mt-1">
                        {#each treatment.schedule.timesOfDay as time}
                            <li>{time}</li>
                        {/each}
                    </ul>
                {:else if treatment.schedule.frequency === 1}
                    <p>
                        {treatment.schedule.daysOfWeek.join(", ")}
                    </p>
                    <ul>
                        {#each treatment.schedule.timesOfDay as time}
                            <li>{time}</li>
                        {/each}
                    </ul>
                {:else}
                    <p>As needed</p>
                {/if}
            </p>
        </div>
    {/if}
    {#if reportData}
        <div>
            <h3>Number of reports in the past 7 days</h3>
            <Bar
                data={reportData}
                options={{
                    responsive: true,
                    scales: {
                        y: {
                            ticks: {
                                precision: 0,
                            },
                            grid: {
                                color: "rgba(255,255,255,0.2)",
                                borderColor: "rgba(255,255,255,0.2)",
                                tickColor: "rgba(255,255,255,0.2)",
                            },
                            beginAtZero: true,
                        },
                        x: {
                            grid: {
                                color: "rgba(255,255,255,0.2)",
                                borderColor: "rgba(255,255,255,0.2)",
                                tickColor: "rgba(255,255,255,0.2)",
                            },
                        },
                    },
                }}
            />
        </div>
    {/if}
    <button on:click|preventDefault={sendReminder}>Send reminder</button>
</div>
