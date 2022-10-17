import logging

from utils.logger import init_logger


logger = init_logger()


def handler1(event, context):
    logger = logging.getLogger("rich")
    logger.info("`handle1` triggerd")
    return {"status": "`handler1-v4` triggered"}


def handler2(event, context):
    logger = logging.getLogger("rich")
    logger.info("`handle2` triggerd")
    return {"status": "`handler2-v4` triggered"}


def f3():
    print(1 / 0)


def f2():
    f3()


def f1():
    f2()


def handler3(event, context):
    logger = logging.getLogger("rich")
    logger.info("`handle3` triggerd")
    try:
        f1()
        return {"status": "`handler3-v4` triggered"}
    except Exception as e:
        logger.critical(e, exc_info=True)
        return {"status": "internal error", "message": repr(e)}
