<script>
    import { Bar } from "svelte-chartjs";
    import "chartjs-adapter-moment";
    import {
        Chart,
        Title,
        Tooltip,
        Legend,
        BarElement,
        CategoryScale,
        LinearScale,
        registerables,
    } from "chart.js";
    import { onMount } from "svelte";
    import { Contract } from "ethers";
    import Treatment from "$lib/contracts/Treatment.json";
    import { provider } from "$lib/store";

    export let ids = [];

    let reportData = {};
    let labels = [];
    let counter = 0;
    let chart;
    let legend;

    Chart.register(
        // Title,
        // Tooltip,
        // Legend,
        // BarElement,
        // CategoryScale,
        // LinearScale
        ...registerables
    );

    onMount(async () => {
        let today = new Date(Date.now());
        // let dataMap = {};

        for (let i = 0; i < 7; i++) {
            labels.push(today.toLocaleDateString());
            // dataMap[today.toLocaleDateString()] = 0;
            today.setDate(today.getDate() - 1);
        }
        // console.log(labels);
        reportData = {
            // labels: labels.reverse(),
            datasets: [],
        };

        // console.log({ labels });
    });

    const updateChart = async () => {
        reportData.datasets = [];
        // console.log({ ids });
        for (const treatment of ids) {
            // console.log(treatment[0]);
            let res = await fetch("/api/check", {
                method: "POST",
                body: JSON.stringify({
                    address: treatment[0],
                    schedule: { frequency: 0, interval: 7 },
                }),
            });
            let reportDataMap = {};
            let reports = await res.json();
            let dataLabels = [];
            let dataToday = new Date(new Date(Date.now()).toLocaleDateString());
            // if (treatment[0] === "0x4a9a4852E8666dA6e33396cE704790a22a0CA6b9") {
            //     console.log(reportDataMap);
            // }
            for (let i = 0; i < 7; i++) {
                dataLabels.push(dataToday.toISOString());
                reportDataMap[dataToday.toLocaleDateString()] = 0;
                dataToday.setDate(dataToday.getDate() - 1);
            }
            for (const report of reports) {
                // console.log(report);
                let reportDate = new Date(report.report_time);
                // if (reportDataMap[reportDate.toLocaleDateString()]) {
                reportDataMap[reportDate.toLocaleDateString()]++;
                // } else {
                // reportDataMap[reportDate.toLocaleDateString()] = 1;
                // }
            }
            //
            let treatmentLog = Object.values(reportDataMap).reverse();
            if (treatmentLog.length > 7) {
                treatmentLog = treatmentLog.slice(treatmentLog.length - 7);
            }
            // if (treatment[0] === "0x4a9a4852E8666dA6e33396cE704790a22a0CA6b9") {
            // console.log(treatmentLog);
            // console.log({
            //     label: treatment[0].substr(-4, 4),
            //     data: treatmentLog.map((value, index) => {
            //         return { x: dataLabels[index], y: value };
            //     }),
            //     // backgroundColor: Array(7).fill(`#${treatment[0].substr(2, 6)}40`),
            //     backgroundColor: `#${treatment[0].substr(2, 6)}`,
            //     // borderWidth: 2,
            //     // borderColor: Array(7).fill(`#${treatment[0].substr(2, 6)}`),
            //     borderColor: `#${treatment[0].substr(2, 6)}`,
            // });
            // }
            const treatmentContract = new Contract(
                treatment[0],
                Treatment.abi,
                $provider.getSigner()
            );
            const info = await treatmentContract.getMedicine();
            // console.log(info);
            reportData.datasets = [
                ...reportData.datasets,
                {
                    label: `${treatment[0]}${treatment[1]}|${info[0]}`,
                    data: treatmentLog.map((value, index) => {
                        return { x: dataLabels[6 - index], y: value };
                    }),
                    // backgroundColor: Array(7).fill(`#${treatment[0].substr(2, 6)}40`),
                    backgroundColor: `#${treatment[0].substr(2, 6)}`,
                    // borderWidth: 2,
                    // borderColor: Array(7).fill(`#${treatment[0].substr(2, 6)}`),
                    borderColor: `#${treatment[0].substr(2, 6)}`,
                },
            ];
        }

        const getOrCreateLegendList = (chart, id) => {
            const legendContainer = document.getElementById(id);
            let listContainer = legendContainer.querySelector("ul");

            if (!listContainer) {
                listContainer = document.createElement("ul");
                // listContainer.style.display = "flex";
                // listContainer.style.flexDirection = "col";
                listContainer.style.margin = 0;
                listContainer.style.padding = 0;
                listContainer.style.height = "28rem";
                listContainer.style.overflowY = "auto";

                legendContainer.appendChild(listContainer);
            }

            return listContainer;
        };

        const treatmentLegendPlugin = {
            id: "treatmentLegend",
            afterUpdate(chart, args, options) {
                const ul = getOrCreateLegendList(chart, options.containerID);

                // Remove old legend items
                while (ul.firstChild) {
                    ul.firstChild.remove();
                }

                // Reuse the built-in legendItems generator
                const items =
                    chart.options.plugins.legend.labels.generateLabels(chart);

                items.forEach(async (item) => {
                    // console.log(item);
                    const li = document.createElement("li");
                    li.style.alignItems = "center";
                    li.style.cursor = "pointer";
                    li.style.display = "flex";
                    li.style.flexDirection = "row";
                    li.style.marginLeft = "10px";

                    li.onclick = () => {
                        const { type } = chart.config;
                        if (type === "pie" || type === "doughnut") {
                            // Pie and doughnut charts only have a single dataset and visibility is per item
                            chart.toggleDataVisibility(item.index);
                        } else {
                            chart.setDatasetVisibility(
                                item.datasetIndex,
                                !chart.isDatasetVisible(item.datasetIndex)
                            );
                        }
                        chart.update();
                    };

                    // Color box
                    const boxSpan = document.createElement("span");
                    boxSpan.style.background = item.fillStyle;
                    boxSpan.style.borderColor = item.strokeStyle;
                    boxSpan.style.borderWidth = item.lineWidth + "px";
                    boxSpan.style.display = "inline-block";
                    boxSpan.style.height = "10px";
                    boxSpan.style.marginRight = "5px";
                    boxSpan.style.width = "10px";

                    // Text
                    const textContainer = document.createElement("p");
                    textContainer.style.color = item.fontColor;
                    textContainer.style.margin = 0;
                    textContainer.style.padding = 0;
                    textContainer.style.textDecoration = item.hidden
                        ? "line-through"
                        : "";

                    // console.log({ treatment: item.text.substr(0, 42) });
                    // const treatmentContract = new Contract(
                    //     item.text.substr(0, 42),
                    //     Treatment.abi,
                    //     $provider.getSigner()
                    // );
                    // const info = await treatmentContract.getMedicine();
                    // console.log({ info: item.text.indexOf("|") });
                    const text = document.createTextNode(
                        item.text.substr(item.text.indexOf("|") + 1)
                    );
                    textContainer.appendChild(text);

                    li.appendChild(boxSpan);
                    li.appendChild(textContainer);
                    ul.appendChild(li);
                });
            },
        };

        const patientLegendPlugin = {
            id: "patientLegend",
            afterUpdate(chart, args, options) {
                const ul = getOrCreateLegendList(chart, options.containerID);

                // Remove old legend items
                while (ul.firstChild) {
                    ul.firstChild.remove();
                }

                // Reuse the built-in legendItems generator
                const items =
                    chart.options.plugins.legend.labels.generateLabels(chart);

                let patients = [];

                items.forEach((item) => {
                    // console.log(
                    //     item.text.substring(42, item.text.indexOf("|"))
                    // );
                    if (
                        !patients.includes(
                            item.text.substring(42, item.text.indexOf("|"))
                        )
                    ) {
                        const li = document.createElement("li");
                        li.style.alignItems = "center";
                        li.style.cursor = "pointer";
                        li.style.display = "flex";
                        li.style.flexDirection = "row";
                        li.style.marginLeft = "10px";

                        li.onclick = () => {
                            const { type } = chart.config;
                            if (type === "pie" || type === "doughnut") {
                                // Pie and doughnut charts only have a single dataset and visibility is per item
                                chart.toggleDataVisibility(item.index);
                            } else {
                                chart.data.datasets.forEach((value, index) => {
                                    if (
                                        value.label.substring(
                                            42,
                                            item.text.indexOf("|")
                                        ) ===
                                        item.text.substring(
                                            42,
                                            item.text.indexOf("|")
                                        )
                                    ) {
                                        // console.log(index);
                                        chart.setDatasetVisibility(
                                            index,
                                            !chart.isDatasetVisible(index)
                                        );
                                    }
                                });
                            }
                            chart.update();
                        };

                        // Color box
                        // console.log(item);
                        const boxSpan = document.createElement("span");
                        boxSpan.style.background = `#${item.text.substr(3, 6)}`;
                        boxSpan.style.borderColor = `#${item.text.substr(
                            3,
                            6
                        )}`;
                        boxSpan.style.borderWidth = item.lineWidth + "px";
                        boxSpan.style.display = "inline-block";
                        boxSpan.style.height = "10px";
                        boxSpan.style.marginRight = "5px";
                        boxSpan.style.width = "10px";

                        // Text
                        const textContainer = document.createElement("p");
                        textContainer.style.color = item.fontColor;
                        textContainer.style.margin = 0;
                        textContainer.style.padding = 0;
                        // textContainer.style.textDecoration = item.hidden
                        //     ? "line-through"
                        //     : "";

                        const text = document.createTextNode(
                            item.text.substring(42, item.text.indexOf("|"))
                        );
                        textContainer.appendChild(text);

                        li.appendChild(boxSpan);
                        li.appendChild(textContainer);
                        ul.appendChild(li);
                        patients.push(
                            item.text.substring(42, item.text.indexOf("|"))
                        );
                    }
                });
            },
        };

        // console.log(reportData);

        let newChart = new Chart(chart.getContext("2d"), {
            type: "line",
            data: reportData,
            options: {
                responsive: true,
                aspectRatio: 1.5,
                interaction: {
                    intersect: false,
                    mode: "nearest",
                    axis: "x",
                },
                scales: {
                    y: {
                        // stacked: true,
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
                        // stacked: true,
                        type: "time",
                        display: true,
                        time: {
                            unit: "day",
                            tooltipFormat: "MM/DD/YYYY",
                        },
                        // title: {
                        //     display: true,
                        //     text: "Date",
                        // },
                        grid: {
                            color: "rgba(255,255,255,0.2)",
                            borderColor: "rgba(255,255,255,0.2)",
                            tickColor: "rgba(255,255,255,0.2)",
                        },
                    },
                },
                plugins: {
                    tooltip: {
                        callbacks: {
                            // beforeLabel: (tooltipItem) => {
                            //     // console.log(tooltipItem);
                            //     return tooltipItem.dataset.label.substring(
                            //         0,
                            //         4
                            //     );
                            // },
                            label: (tooltipItem) => {
                                const index =
                                    tooltipItem.dataset.label.indexOf("|");
                                return `${tooltipItem.dataset.label.substring(
                                    38,
                                    42
                                )}${tooltipItem.dataset.label.substring(
                                    index
                                )}: ${
                                    tooltipItem.dataset.data[
                                        tooltipItem.dataIndex
                                    ].y
                                }`;
                            },
                        },
                    },
                    treatmentLegend: {
                        containerID: "treatment-legend-container",
                    },
                    patientLegend: {
                        containerID: "patient-legend-container",
                    },
                    legend: { display: false },
                },
            },
            plugins: [treatmentLegendPlugin, patientLegendPlugin],
        });
        // console.log(newChart);
        // legend.innerHTML = newChart.generateLegend();
    };

    $: {
        // console.log(ids[23]);
        if (ids.length && !ids.includes(undefined)) {
            // if (ids.length === counter) {
            setTimeout(() => {
                updateChart();
            }, 500);

            // }
            // counter++;
        }
    }
</script>

<div class="grid dash-chart w-10/11">
    {#if ids.length}
        <div class="chart-div min-w-[50vw]">
            <canvas bind:this={chart} />
            <!-- <Bar
            bind:this={chart}
            data={reportData}
            options={{
                responsive: true,
                aspectRatio: 1.5,
                scales: {
                    y: {
                        stacked: true,
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
                        stacked: true,
                        grid: {
                            color: "rgba(255,255,255,0.2)",
                            borderColor: "rgba(255,255,255,0.2)",
                            tickColor: "rgba(255,255,255,0.2)",
                        },
                    },
                },
                plugins: {
                    legend: { display: false },
                },
            }}
        /> -->
        </div>
        <div class="min-w-max">
            <h3 class="m-0">Treatment filter</h3>
            <div id="treatment-legend-container" class="legend-div" />
        </div>
        <div class="min-w-max">
            <h3 class="m-0">Patient filter</h3>
            <div id="patient-legend-container" class="legend-div" />
        </div>
    {/if}
</div>

<style>
    .dash-chart {
        grid-template-columns: 5fr 1fr 1fr;
        gap: 1rem;
    }
</style>
