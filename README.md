The cache has a total capacity of 16MB, uses 64-byte lines, and is 16-way set associative. It
employs a write allocate policy and uses the MESI protocol to ensure cache coherence. The
replacement policy is implemented with a pseudo-LRU scheme.

## Project File Structure

```
+---Files
|       default.din
|       emty.din
|       rwims.din
|       
+---Test Plan
|   |   Test_plan.docx
|   |   Test_plan.pdf
|   |   
LLC_Cache.sv
LLC_defs.sv
tb_LLC_cache.sv
```
# Simulation and Debugging Commands

## DEBUG mode: With `DEBUG` Defined
```bash
vlog +define+DEBUG tb_LLC_cache.sv
```
## SILENT mode 
```bash
vlog tb_LLC_cache.sv
```
## To Run
```bash
vsim -c tb_LLC_cache -do "run -all" +trace_file=rwims.din
```
## Key Features
### L1 Cache Specifications
- **Byte Line**: 64 bytes
- **Associativity**: 4-way set
- **Write Policy**: Write-once (initial write-through, subsequent write-back)

## Functional Highlights
- Implements **MESI protocol** for cache coherence.
- Supports **silent** and **debug** simulation modes.
- Provides detailed statistics, including cache hit/miss ratios and MESI state transitions.

## Testing Strategies
- Validates **read** and **write operations**.
- Tests **Pseudo-LRU functionality** for efficient replacement.
- Evaluates **MESI FSM transitions** for different cache scenarios.


---

This project was undertaken as part of the **ECE585 course** at **Portland State University** under the guidance of **Prof. Mark G. Faust**.
