import os
import typing
import logging
import traceback

from utils.logger import init_logger


class Handler():

    def __init__(self) -> None:
        self.logger = init_logger()

    def run(self, name: str, func: typing.Callable, *func_args) -> typing.Dict:
        self.logger = logging.getLogger("rich")

        if name:
            self.logger.info("{} triggerd".format(name))

        try:
            func(*func_args)
            return {"status": "ok", "message": "{} triggerd".format(name)}
        except Exception as e:
            if "LAMBDA_TASK_ROOT" in os.environ:
                self.logger.critical(traceback.format_exc().replace("\n", "\r"))
            else:
                self.logger.critical(repr(e), exc_info=True)
            return {"status": "internal error", "message": repr(e)}
