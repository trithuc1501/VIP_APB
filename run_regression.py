#!/usr/bin/env python3
import os
import subprocess
import glob
import re

def main():
    # Automatically determine the project root and run directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    run_dir = os.path.join(script_dir, "run")
    test_dir = os.path.join(script_dir, "test")

    if not os.path.exists(run_dir):
        print(f"Error: Run directory not found at {run_dir}")
        return

    os.chdir(run_dir)
    print("Starting UVM Regression Run...")
    print("-" * 65)
    print(f"{'TESTNAME':<30} | {'STATUS':<30}")
    print("-" * 65)

    test_files = glob.glob(os.path.join(test_dir, "APB_TC_*.sv"))
    tests = sorted([os.path.basename(t).replace(".sv", "") for t in test_files])

    # List of negative tests that expect UVM_ERRORs
    negative_tests = {
        "APB_TC_AST_001_test",
        "APB_TC_AST_002_test",
        "APB_TC_AST_003_test",
        "APB_TC_AST_004_test",
        "APB_TC_AST_005_test",
        "APB_TC_AST_006_test",
        "APB_TC_AST_007_test",
        "APB_TC_TIM_002_test",
        "APB_TC_FEAT_005_test",
        "APB_TC_FEAT_006_test"
    }

    passed_count = 0
    total_count = len(tests)

    for test in tests:
        out_file = f"{test}_run.out"
        with open(out_file, "w") as f:
            subprocess.run(["make", "all", f"TEST={test}"], stdout=f, stderr=subprocess.STDOUT)

        with open(out_file, "r") as f:
            log_content = f.read()

        # Check for compile errors
        if re.search(r'\*\* Error:|\*\* Fatal:|Error loading design', log_content):
            print(f"{test:<30} | \033[91m{'COMPILE ERR':<30}\033[0m")
            continue

        # Extract UVM_ERROR count
        match = re.search(r'^# UVM_ERROR\s*:\s*(\d+)', log_content, re.MULTILINE)
        if not match:
            print(f"{test:<30} | \033[93m{'CRASH/UNKNOWN':<30}\033[0m")
            continue

        err_count = int(match.group(1))

        if test in negative_tests:
            if err_count > 0:
                print(f"{test:<30} | \033[92m{'PASS':<10}\033[0m (Expected {err_count} errors)")
                passed_count += 1
            else:
                print(f"{test:<30} | \033[91m{'FAIL':<10}\033[0m (Expected errors but got 0)")
        else:
            if err_count == 0:
                print(f"{test:<30} | \033[92m{'PASS':<30}\033[0m")
                passed_count += 1
            else:
                print(f"{test:<30} | \033[91m{'FAIL':<10}\033[0m ({err_count} errors)")

    print("-" * 65)
    print(f"Regression Summary: \033[1m{passed_count}/{total_count} tests passed.\033[0m")

if __name__ == "__main__":
    main()
