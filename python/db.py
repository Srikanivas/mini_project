import psycopg2
import config


def open_connection():
    if config.DB_URL:
        return psycopg2.connect(config.DB_URL)
    return psycopg2.connect(
        host=config.DB_HOST,
        port=config.DB_PORT,
        dbname=config.DB_NAME,
        user=config.DB_USER,
        password=config.DB_PASS,
    )
