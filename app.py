import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler1(event, context):
    return {"status": "`handler1-v2` triggered"}


def handler2(event, context):
    return {"status": "`handler2-v2` triggered"}