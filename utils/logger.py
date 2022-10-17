import datetime
import logging
import os
import tempfile

from rich.logging import RichHandler


def init_logger(env: str = "dev") -> logging.Logger:
    """Initialize logger
    Args:
        env (`str`, optional): _description_. Defaults to `dev`.
    Returns:
        logging.Logger: The logger for further usages.
    >>> from utils.logger import init_logger
    >>> logger = init_logger()
    >>> logger.info("hello world")
    """

    assert env in [
        "dev",
        "stage",
        "prod",
    ], "`env` should only be one of `dev`, `stage`, or `prod`"

    logger = logging.getLogger("rich")

    FORMAT = (
        "%(name)s[%(process)d] "
        + "%(processName)s(%(threadName)s) "
        + "%(module)s:%(lineno)d  %(message)s"
    )

    logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter(FORMAT, datefmt="%Y%m%d %H:%M:%S")
    logging.basicConfig(level="NOTSET", format=FORMAT, handlers=[RichHandler()])

    # ch = logging.StreamHandler()
    # ch.setLevel(logging.DEBUG)
    # ch.setFormatter(formatter)

    if "LAMBDA_TASK_ROOT" not in os.environ: # Do not write to .log/ in AWS Lambda
        if env == "dev":
            log_dir = ".logs"
        else:
            log_dir = tempfile.gettempdir()

        os.makedirs(log_dir, exist_ok=True)

        log_filename = os.path.join(
            log_dir, datetime.datetime.now().strftime("%Y-%m-%d_%H_%M_%S.log")
        )
        fh = logging.FileHandler(log_filename, "w", encoding="utf-8")
        fh.setLevel(logging.DEBUG)
        fh.setFormatter(formatter)
        logger.addHandler(fh)

    logger.info("Logger initialized.")

    return 