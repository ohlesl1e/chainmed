import { networkProviders } from '$lib/provider'
import { SiweMessage } from 'siwe'
import Manager from '$lib/contracts/Manager.json'
import { ethers } from 'ethers'
import { JWT_SECRET } from '$env/static/private'
import { PUBLIC_MANAGER_ADDRESS } from '$env/static/public'
import jwt from "jsonwebtoken";

const managerContract = new ethers.Contract(PUBLIC_MANAGER_ADDRESS, Manager.abi, networkProviders[0])

export const POST = async ({ request }) => {
    const { address } = await request.json()
    console.log(address);
    let result = await managerContract.getPatient(address)
    if (result !== ethers.constants.AddressZero) {
        return new Response(JSON.stringify({
            message: "Registration success",
            token: jwt.sign(
                { type: 'patient', address: result },
                JWT_SECRET
            )
        }))
    }
    return new Response(JSON.stringify({ message: "Profile not found" }), { status: 404, headers: { location: '/new-user/patient' } })
}