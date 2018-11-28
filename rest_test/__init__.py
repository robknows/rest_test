import time
import traceback

from termcolor import colored


def test(test_function):
    def test_wrapper():
        test_function()

    test_wrapper.__basename__ = test_function.__name__
    return test_wrapper


def setup(setup_function):
    def setup_wrapper():
        setup_function()

    setup_wrapper.__basename__ = setup_function.__name__
    return setup_wrapper


def teardown(teardown_function):
    def teardown_wrapper():
        teardown_function()

    teardown_wrapper.__basename__ = teardown_function.__name__
    return teardown_wrapper


def get_test_functions(local_values):
    test_functions = []
    local_function_names = [name for name in local_values if local_values[name].__class__.__name__ == "function"]
    for function_name in local_function_names:
        function = local_values[function_name]
        if function.__name__ == "test_wrapper":
            test_functions.append(function)

    return test_functions


def get_test_maintenance_functions(local_values):
    setup_function = None
    teardown_function = None
    local_function_names = [name for name in local_values if local_values[name].__class__.__name__ == "function"]
    for function_name in local_function_names:
        function = local_values[function_name]
        if function.__name__ == "setup_wrapper":
            setup_function = function
        elif function.__name__ == "teardown_wrapper":
            teardown_function = function

    return setup_function, teardown_function


def run_test(test):
    print("=== === ===")
    print("Running: " + test.__basename__)
    try:
        test()
        print(colored("- " + test.__basename__ + " - pass", "green"))
        print("=== === ===")
        return 0
    except AssertionError as e:
        print(colored(str(e), "red"))
        print(colored("- " + test.__basename__ + " - fail", "red"))
        print("=== === ===")
        return 1
    except Exception as e:
        print(colored(traceback.format_exc(), "red"))
        print(colored("- " + test.__basename__ + " - error", "red"))
        print("=== === ===")
        return 2


def run_tests(local_values):
    results = {}
    for test_function in get_test_functions(local_values):
        result = run_test(test_function)
        results[test_function.__basename__] = result

    return results


def print_results(results):
    print("=== results ===\n")
    total_passed = 0
    total_failed = 0
    for test_function_name in results:
        if results[test_function_name] == 0:
            print(colored("- " + test_function_name + " - pass", "green"))
            total_passed += 1
        elif results[test_function_name] == 1:
            print(colored("- " + test_function_name + " - fail", "red"))
            total_failed += 1
        elif results[test_function_name] == 2:
            print(colored("- " + test_function_name + " - error", "red"))
            total_failed += 1

    print("")
    print(colored("=== " + str(total_passed) + " tests passed ===", "green"))
    if (total_failed > 0):
        print(colored("=== " + str(total_failed) + " tests failed ===", "red"))
    else:
        print(colored("=== No failures ===", "green"))

    print("")


def all_passed(results):
    for test_function_name in results:
        if not results[test_function_name] == 0:
            return False

    return True


def main(local_values):
    start_server, stop_server = get_test_maintenance_functions(local_values)
    using_server = start_server is not None and stop_server is not None

    if start_server is not None and stop_server is None:
        print(colored(f"Not running @setup ({start_server.__basename__}) because no @teardown is defined. " +
                      "They must be used together.\n", "yellow"))
    elif stop_server is not None and start_server is None:
        print(colored(f"Not running @teardown ({stop_server.__basename__}) because no @setup is defined. " +
                      "They must be used together.\n", "yellow"))

    if using_server:
        print(f"=== running \"{start_server.__basename__}\" ===")
        start_server()
        time.sleep(1)

    print("=== starting tests ===")
    results = run_tests(local_values)
    print_results(results)

    if using_server:
        print(f"=== running \"{stop_server.__basename__}\" ===")
        stop_server()

    print("=== finished tests ===")

    success = all_passed(results)
    if success:
        return 0
    else:
        return 1
