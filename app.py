from utils.handler import Handler


func_handler = Handler()


def handler1(event, context):
    return func_handler.run("handler1", print, 1)


def handler2(event, context):
    return func_handler.run("handler2", print, 2)


def f3():
    print(1 / 0)


def f2():
    f3()


def f1():
    f2()


def handler3(event, context):
    return func_handler.run("handler3", f1)


if __name__ == "__main__":
    print(handler1(1, 2))
    print(handler2(1, 2))
    print(handler3(1, 2))
