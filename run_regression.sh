#!/bin/bash
cd /home/trithuc/Documents/FPT/VIP_APB/run

echo "Starting Regression Run..."
echo "------------------------------------------------"
printf "%-30s | %-10s\n" "TESTNAME" "STATUS"
echo "------------------------------------------------"

tests=$(ls ../test/APB_TC_*.sv | xargs -n 1 basename | sed 's/\.sv//')

for test in $tests; do
    make all TEST=$test > ${test}_run.out 2>&1
    
    if grep -q "Error loading design\|Error:\|Fatal:" ${test}_run.out; then
        printf "%-30s | %-10s\n" "$test" "COMPILE ERR"
        continue
    fi
    
    err_count=$(grep -E "^# UVM_ERROR[ \t]*:" ${test}_run.out | grep -o '[0-9]\+' | tail -n 1)
    
    if [ -z "$err_count" ]; then
        printf "%-30s | %-10s\n" "$test" "CRASH/UNKNOWN"
    else
        # AST_002, AST_003, AST_005, AST_006, AST_007, AST_008 inject errors and expect SVA to fire
        # TIM_002 injects a timeout and expects APB Bus Hung
        if [[ "$test" =~ APB_TC_AST_00[1-7]_test ]] || [[ "$test" == "APB_TC_TIM_002_test" ]] || [[ "$test" == "APB_TC_FEAT_005_test" ]]; then
            if [ "$err_count" -gt 0 ]; then
                printf "%-30s | %-10s (Expected %s errors)\n" "$test" "PASS" "$err_count"
            else
                printf "%-30s | %-10s (Expected errors but got 0)\n" "$test" "FAIL"
            fi
        else
            if [ "$err_count" -eq 0 ]; then
                printf "%-30s | %-10s\n" "$test" "PASS"
            else
                printf "%-30s | %-10s (%s errors)\n" "$test" "FAIL" "$err_count"
            fi
        fi
    fi
done
echo "------------------------------------------------"
