import mysql.connector

def get_connection():
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="shadow",
        database="urban_mobility"
    )
    return connection