import base64, yaml, secrets, string

def rs(n):
   return ''.join(secrets.choice(string.ascii_letters + string.digits + '_-') for _ in range(n))

c = {
   'max_message_size': 20971520,
   'room': rs(43), 'rendezvous': rs(43), 'mdns': rs(43),
   'otp': {
       'dht': {'key': rs(43), 'interval': 30, 'length': 43},
       'crypto': {'key': rs(43), 'interval': 9000, 'length': 43},
   }
}
print(base64.b64encode(yaml.dump(c, default_flow_style=False).encode()).decode())
