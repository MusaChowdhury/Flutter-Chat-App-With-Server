import socket
import threading
import json
import traceback


class Server(threading.Thread):
    class accepting_thread(threading.Thread):

        def __init__(self, client_object, address):
            super(Server.accepting_thread, self).__init__()
            self.client_object = client_object
            self.address = address

        def run(self):
            address = self.address
            client_object = self.client_object
            try:
                print(f"{address} connected")
                data = client_object.recv(100)
                try:
                    registered = False
                    print(data)
                    parsed = json.loads(data)
                    for i in Client_Connection_Handler.active_client:
                        if i.id == parsed["id"]:
                            registered = True
                    if not registered:
                        (Client_Connection_Handler(client_object, address, parsed["id"])).start()
                        client_object.send(Client_Connection_Handler.response("success"))
                    else:
                        client_object.send(Client_Connection_Handler.response("registered_already"))
                        client_object.shutdown(socket.SHUT_RDWR)
                        client_object.close()
                        traceback.print_exc()

                except:
                    client_object.send(Client_Connection_Handler.response("failed"))
                    client_object.shutdown(socket.SHUT_RDWR)
                    client_object.close()
                    traceback.print_exc()
            except:
                print("Error in Working Thread of Accepting Client's Primary Connection")

    def __init__(self):

        self.passed_init = False
        host = "0.0.0.0"
        port = 40000
        server = socket.socket()
        # Binding Here
        try:
            server.bind((host, port))
            server.listen()
            while True:
                try:
                    client_object, address = server.accept()
                    Server.accepting_thread(client_object, address).start()
                except:
                    print("main handler")
                    traceback.print_exc()
                    pass
        except:
            print("Error in Binding Port")
            traceback.print_exc()


class Client_Connection_Handler(threading.Thread):
    active_client = []

    @staticmethod
    def response(data):
        return json.dumps({"response": data}).encode()

    def __init__(self, connection, address, id):
        super(Client_Connection_Handler, self).__init__()
        self.connection = connection
        self.id = id
        self.address = address
        Client_Connection_Handler.active_client.append(self)

    def run(self):
        print(f"Inside Separate Thread For Handling Only {self.id} with ip = {self.address}")
        while True:
            try:
                data = self.connection.recv(1024)
                try:
                    if data:
                        found = False
                        parsed = json.loads(data.decode())
                        print(f"({self.id}) Client Handler Thread :", parsed)
                        if parsed["type"] == "message":
                            for i in Client_Connection_Handler.active_client:
                                if i.id == parsed["to"]:
                                    packet = {
                                        "response": "message",
                                        "from": parsed["id"],
                                        "data": parsed["data"]
                                    }
                                    i.connection.send((json.dumps(packet)).encode())
                                    found = True
                            if not found:
                                self.connection.send(Client_Connection_Handler.response("not_found"))
                        elif parsed["type"] == "find":
                            exist = False
                            for i in Client_Connection_Handler.active_client:

                                if i.id == parsed["id"]:
                                    exist = True

                            if exist:
                                self.connection.send(Client_Connection_Handler.response("found"))
                            else:
                                self.connection.send(Client_Connection_Handler.response("not_found"))

                    else:
                        self.connection.close()
                        Client_Connection_Handler.active_client.remove(self)
                        print(f"{self.address} closed")
                        break
                except:
                    pass



            except:
                print("Error in Client Handler  Thread For Client:", self.id)
                Client_Connection_Handler.active_client.remove(self)
                traceback.print_exc()


print(f"Server IP: 0.0.0.0, Port: 40000")
print("If the app is running in the same network use this computer's IP")
print("If the app is running inside Emulator (Android Studio) and server is on same computer use 10.0.2.2 to access "
      "localhost of host computer.")
print("\nPress any key to continue")
input()
print("Listening . . . . . ")
Server()

