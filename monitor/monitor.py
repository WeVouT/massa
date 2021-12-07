#!/usr/bin/env python3
import os, requests
import configparser
import time 
import json

# constants
IDEP_DECIMALS = 100000000
TRANSACTION_WAIT_TIME = 10

class MassaMonitor():
    def __init__( self, config_file='config.ini' ):

        # read the config and setup the telegram
        self.read_config( config_file )
        self.setup_telegram()
        self.setup_info()
        self.init_cycle()

        # send the hello message
        self.send( f'Hello from Massa Monitoring Bot!' )
        
    def read_config( self, config_file ):
        '''
        Read the configuration file
        '''
        config = configparser.ConfigParser()
        if os.path.exists( config_file ):
            print( f"Using Configuration File: { config_file }")
            config.read( config_file )
        else:
            print( f"Configuration File Does Not Exist: { config_file }")

        # save the config
        self.config = config

    def setup_telegram( self ):
        '''
        Setup telegram
        '''
        if "TELEGRAM_TOKEN" in os.environ:
            self.telegram_token = os.environ['TELEGRAM_TOKEN']
        elif 'Telegram' in self.config and 'telegram_token' in self.config['Telegram']:
            self.telegram_token = self.config['Telegram']['telegram_token']
        else:
            self.telegram_token = None
        
        if "TELEGRAM_CHAT_ID" in os.environ:
            self.telegram_chat_id = os.environ['TELEGRAM_CHAT_ID']
        elif 'Telegram' in self.config and 'telegram_chat_id' in self.config['Telegram']:
            self.telegram_chat_id = self.config['Telegram']['telegram_chat_id']
        else:
            self.telegram_chat_id = None
    
    def setup_info( self ):
        # sleep time between delegation cycles
        if "SLEEP_TIME" in os.environ:
            self.sleep_time = int(os.environ['SLEEP_TIME'])
        elif 'sleep_time' in self.config['Massa']:
            self.sleep_time = int(self.config['Massa']['sleep_time'])
        else:
            self.sleep_time = 600

        if "NODE_IP" in os.environ:
            self.node_ip = os.environ['NODE_IP']
        elif 'node_ip' in self.config['Massa']:
            self.node_ip = self.config['Massa']['node_ip']
        else:
            self.node_ip = "127.0.0.1"

        if "NODE_ADDRESS" in os.environ:
            self.node_address = os.environ['NODE_ADDRESS']
        elif 'node_ip' in self.config['Massa']:
            self.node_address = self.config['Massa']['node_address']
        
    def send( self, msg ):
        '''
        Print the message and send telegram message, if available
        '''
        if self.telegram_token != None and self.telegram_chat_id != None:
            requests.post( f'https://api.telegram.org/bot{self.telegram_token}/sendMessage?chat_id={self.telegram_chat_id}&text={msg}' )
        print( msg )

    def parse_subprocess( self, response, keyword ):
        '''
        Parse and return the line
        '''
        for line in response.decode("utf-8").split('\n'):
            if keyword in line:
                return line

    def init_cycle(self):
        self.current_cycle = self.get_cycle()

    def get_cycle(self):
        headers = {'content-type': 'application/json'}
        payload = {
            "method": "get_status",
            "jsonrpc": "2.0",
            "id": 0,
        }
        response = requests.post(f"http://{self.node_ip}", json.dumps(payload), headers=headers).json()        
        return response["result"]["current_cycle"]

    def getCycleData(self):
        headers = {'content-type': 'application/json'}
        payload = {
            "method": "get_addresses",
            "params": [[self.node_address]],
            "jsonrpc": "2.0",
            "id": 0,
        }
        response = requests.post(f"http://{self.node_ip}", json.dumps(payload), headers=headers).json()
        return response["result"][0]["production_stats"]

    def monitoring_cycle( self ):
        '''
        start monitoring cycle
        '''
        if(self.current_cycle != self.get_cycle()):            
            message= ''
            cycleData = self.getCycleData()
            for dataItem in cycleData:
                if dataItem["nok_count"] > 0:                    
                    message += f"\nNOK items found in {dataItem['cycle']}. "
                    message += f"{dataItem['nok_count']+dataItem['ok_count']}/{dataItem['ok_count']}/{dataItem['nok_count']} (TOTAL/OK/NOK)"
            self.send(message)
            self.current_cycle = self.get_cycle

        time.sleep( self.sleep_time )

def parse_arguments( ):
    '''
    Parse the arguments passed in
    '''
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', '-c', type=str, required=False, default='config.ini', help='Configuration File')
    return parser.parse_args()

# Parse arguments
args = parse_arguments()

# Create the object
massa_bot = MassaMonitor( args.config )

# run periodic delegation cycle
while True:
    massa_bot.monitoring_cycle()