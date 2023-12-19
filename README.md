# MultiBank Memory Design in SystemVerilog

## Overview

![multibank](https://github.com/Vor-Art/DCD_MultiBankMemory/blob/master/images/preview.png?raw=true)

The project explores the concept of multibank memory systems as a particular solution of multiport memory problem. The aims of the project is to find the optimal number of banks to minimize conflicts and maximize throughput, as described in the article _"Multibank memory bandwidth analysis in on-chip system."_ [(link)](https://www.researchgate.net/publication/355220832_Multibank_memory_bandwidth_analysis_in_on-chip_system?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6ImhvbWUiLCJwYWdlIjoicHJvZmlsZSIsInByZXZpb3VzUGFnZSI6ImhvbWUiLCJwb3NpdGlvbiI6InBhZ2VDb250ZW50In19)

- __Scalebility__: you can adjast the number of ports and memory banks;  
- __Ready/Valid interface__: module interaction use ready/valid interface.  
*Currently there is a problem with implementing an **efficient ready/valid interface** for the read port. It means that the read port has an additional 1 clock delay*;
- __Ports arbitration__: When multiple ports are handled simultaneously, the processing order is arbitrary, but the number of stall clock cycles cannot be greater than the number of ports;
- __Read constant memory delay__: After the read transaction is validated, the response comes after several clock cycles. The number of clock cycles is fixed and equal to the delay of memory block reading. The data is accompanied by an ready signal;
- __Write constant memory delay__: After the write transaction is validated, the data will be written to memory within a few clock cycles. The number of clock cycles is fixed and equal to the delay of memory block writing.

## Contents

- `src/design/`: Source code for the multibank memory module.
- `src/testbench/`: Files for verification and throughput examination.
- `docs/`: Documentation and additional resources.

## Project Details

- **Course:** Digital Circuit Design
- **University:** Innopolis University
- **Authors:** [Artem Voronov](https://github.com/Vor-Art) and [Roman Voronov](https://github.com/V-Roman-V)

## Getting Started

### Prerequisites

- Modelsim or QuestaSim

### Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/Vor-Art/DCD_MultiBankMemory.git
    cd DCD_MultiBankMemory/src
    ```

2. Launch test and display results:

    ```bash
    modelsim -do ./run.do
    cat test_results.txt
    ```

> Note: you can specify the test by setting the parameter `test_id` in `run.do`:  
test_id=0: __Direct test__ - static set of simple tests to check correctness;  
test_id=1: __Random test__ - each port access to random addresses each time;  
test_id=2: todo... 

## Documentation

### Related Article

Our paper is published on 2021 MES Conference. The article "Multibank memory bandwidth analysis in on-chip system" is available in the `doc/article/` directory. This publication provides in-depth analysis and insights into the design and performance of the multibank memory module.

For citation use: 
___
*A. V. Voronov, R. V. Voronov, and R. F. Iliasov, “Multibank memory bandwidth analysis in on-chip system,” Problems of advanced micro- and nanoelectronic systems development. FSFIS Institute for Design Problems in Microelectronics RAS, pp. 99–105, 2021. doi: 10.31114/2078-7707-2021-4-99-105*
___

### Presentation

The slides of the project presentation are available in the `doc/presentation/` directory. These slides provide explained details and key findings.

### Usefull links

- [Understanding Multiport-Memories](https://tomverbeure.github.io/2019/08/03/Multiport-Memories.html): Considers various implementation of multiport memory (Flip-Flop, Live Value Table, XOR-Based, etc...)  
- [Collection of Multi-Ported Memories](http://fpgacpu.ca/multiport/): Collects various articles related to multiport memory for FPGAs (and ASICs too)
- [Arbiters: Design Ideas and Coding Styles](https://abdullahyildiz.github.io/files/Arbiters-Design_Ideas_and_Coding_Styles.pdf): Describes the implementation of various arbitration methods.
## Acknowledgments

Thanks to [Yuri Panchul](https://github.com/yuri-panchul) for advising us on the concept of multiport memory. We are thankful to [Dmitry Smekhov](https://github.com/dsmv) for preparing the testbench for memory design and Innopolis University for inspiration in writing an article on this topic.
