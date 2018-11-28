import sys
import time
import traceback

from termcolor import colored


def test(test_function):
    def test_wrapper():
        test_function()

    test_wrapper.__basename__ = test_function.__name__
    return test_wrapper


def get_test_functions(local_values):
    test_functions = []
    local_function_names = [name for name in local_values if local_values[name].__class__.__name__ == "function"]
    for function_name in local_function_names:
        function = local_values[function_name]
        if function.__name__ == "test_wrapper":
            test_functions.append(function)

    return test_functions


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


def main(local_values, start_server=None, stop_server=None):
    usage = "USAGE: " + sys.argv[0] + " [a|r]\n" + \
            "a       => don't start the server because it's (a)lready running.\n" + \
            "r       => (r)un the server in the tests.\n" + \
            "           You will need to define the start and stop functions and\n" + \
            "           pass them to `main` in the test script.\n" + \
            "No args => There is no server to run or not run.\n" + \
            "           Run the test script of other programs."

    print("Running: " + str(sys.argv) + "\n")

    if len(sys.argv) == 2:
        if sys.argv[1] == "a":  # 'a' is for 'already running'
            using_server = False
        elif sys.argv[1] == "r":  # 'r' is for 'run it in the tests'
            using_server = True
        else:
            print(usage)
            exit(1)
    elif len(sys.argv) == 1:
        using_server = False
    else:
        print(usage)
        exit(1)

    if using_server:
        print("=== starting server ===")
        start_server()
        time.sleep(1)

    print("=== starting tests ===")
    results = run_tests(local_values)
    print_results(results)

    if using_server:
        print("=== killing server ===")
        stop_server()

    print("=== finished tests ===")
