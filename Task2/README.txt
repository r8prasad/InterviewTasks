Assumptions:

1) If data input to counterDetectRTL is unknown, the output flags (incr, decr, error) are also unknown.
2) On receiving first valid data in counterDetectRTL, the output flags (incr, decr, error) are all zeros. 

Run:
+UVM_TESTNAME=counterDetect_random_test
