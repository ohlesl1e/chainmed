export const ssr = false
import { writable } from 'svelte/store'

export const provider = writable(undefined)
export const applicationContract = writable(undefined)
export const managerContract = writable(undefined)
export const patientContract = writable(undefined)
export const doctorContract = writable(undefined)
export const token = writable(undefined)