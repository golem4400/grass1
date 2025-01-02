import asyncio
import random
import ssl
import json
import time
import uuid
from loguru import logger
import websockets

def read_config(file_path='config.json'):
    with open(file_path, 'r') as config_file:
        config = json.load(config_file)
    return config

async def connect_to_wss(ip_address, user_id):
    device_id = str(uuid.uuid3(uuid.NAMESPACE_DNS, ip_address))
    logger.info(f"Device ID: {device_id}")
    while True:
        try:
            await asyncio.sleep(random.randint(1, 10) / 10)
            custom_headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
            }
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE

            uri = "wss://proxy2.wynd.network:4650/"

            async with websockets.connect(uri, ssl=ssl_context, extra_headers=custom_headers) as websocket:
                async def send_ping():
                    while True:
                        send_message = json.dumps(
                            {"id": str(uuid.uuid4()), "version": "4.30.0", "action": "PING", "data": {}})
                        logger.debug(f"Sending PING: {send_message}")
                        await websocket.send(send_message)
                        await asyncio.sleep(20)

                await asyncio.sleep(1)
                asyncio.create_task(send_ping())

                while True:
                    response = await websocket.recv()
                    message = json.loads(response)
                    logger.info(f"Received Message: {message}")
                    if message.get("action") == "AUTH":
                        auth_response = {
                            "id": message["id"],
                            "origin_action": "AUTH",
                            "result": {
                                "browser_id": device_id,
                                "user_id": user_id,
                                "user_agent": custom_headers['User-Agent'],
                                "timestamp": int(time.time()),
                                "device_type": "desktop",
                                "version": "4.30.0",  # Cập nhật phiên bản thành 4.30.0
                                "product": "Grass",
                                "copyright": "© Grass Foundation, 2024. All rights reserved."
                            }
                        }
                        logger.debug(f"Sending AUTH Response: {auth_response}")
                        await websocket.send(json.dumps(auth_response))

                    elif message.get("action") == "PONG":
                        pong_response = {"id": message["id"], "origin_action": "PONG"}
                        logger.debug(f"Sending PONG Response: {pong_response}")
                        await websocket.send(json.dumps(pong_response))
        except Exception as e:
            logger.error(f"Error for IP {ip_address}: {e}")

async def main():
    config = read_config()
    file_path = config.get('file_path', 'ip.txt')
    user_id = config.get('user_id', '')

    # Đọc danh sách IP từ file
    with open(file_path, 'r') as file:
        ip_list = [line.strip() for line in file.readlines()]

    tasks = []
    for ip_address in ip_list:
        task = asyncio.ensure_future(connect_to_wss(ip_address, user_id))
        tasks.append(task)

    await asyncio.gather(*tasks)

if __name__ == '__main__':
    asyncio.run(main())
