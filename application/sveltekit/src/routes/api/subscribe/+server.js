import webpush from 'web-push'
import { connection } from '$lib/server/db'
import { PRIVATE_PUSH_KEY, PUSH_SUB } from '$env/static/private'
import { PUBLIC_PUSH_KEY } from '$env/static/public'

webpush.setVapidDetails(PUSH_SUB, PUBLIC_PUSH_KEY, PRIVATE_PUSH_KEY)

export const POST = async ({ request }) => {
    let db = await connection()
    let { subscription, address } = await request.json()
    try {
        let result = await db.execute('INSERT INTO subscription (address, endpoint, sub_keys) VALUES(?,?,?)', [address, subscription.endpoint, JSON.stringify(subscription.keys)])
        console.log({ subscription, address, result })
    } catch (error) {
        console.log(error)
        if (error.code === 'ER_DUP_ENTRY') {
            let result = await db.execute('UPDATE subscription SET address=?, sub_keys=? WHERE endpoint=?', [address, JSON.stringify(subscription.keys), subscription.endpoint])
            console.log(result);
        }
    }

    // const payload = JSON.stringify({ title: 'Push Test', body: 'address' })

    // webpush.sendNotification(subscription, payload)

    return new Response(JSON.stringify('Success'))
}

export const DELETE = async ({ request }) => {
    let db = await connection()
    let { endpoint } = await request.json()

    try {
        let [result] = await db.execute('DELETE FROM subscription WHERE endpoint=?', [endpoint])
        return new Response(JSON.stringify({ message: 'success' }))
    } catch (error) {
        console.log(error)
        return new Response(JSON.stringify({ message: 'failed' }), { status: 500 })
    }
}