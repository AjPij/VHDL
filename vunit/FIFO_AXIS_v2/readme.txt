in this version .vhd files remain the same except LUT_MEM, data output from memory is registered once more to emulate 
read latency for 2 clock cycles. This results in efectively testing and upgrading the interface and logic to work with other types of memory that have more read latency.

