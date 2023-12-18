# MultiBank Memory Design in SystemVerilog

## Overview

![multibank](https://github.com/Vor-Art/DCD_MultiBankMemory/blob/master/images/preview.png?raw=true)

The project explores the concept of multibank memory systems as a particular solution of multiport memory problem. The aims of the project is to find the optimal number of banks to minimize conflicts and maximize throughput, as described in the article _"Multibank memory bandwidth analysis in on-chip system."_ [(link)](https://www.researchgate.net/publication/355220832_Multibank_memory_bandwidth_analysis_in_on-chip_system?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6ImhvbWUiLCJwYWdlIjoicHJvZmlsZSIsInByZXZpb3VzUGFnZSI6ImhvbWUiLCJwb3NpdGlvbiI6InBhZ2VDb250ZW50In19)

- __Scalebility__: you can ajast the parameters of ports and banks  
- sadas

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
test_id=0: __Direct test__ - each port access to only one uniformly chosen bank;  
test_id=1: __Random test__ - Each port access to random addresses each time  
test_id=2: todo... 

## Documentation

### Related Article

Our paper is published on 2021 MES Conference. The article "Multibank memory bandwidth analysis in on-chip system" is available in the `doc/article/` directory. This publication provides in-depth analysis and insights into the design and performance of the multibank memory module.

For citation use:

```text
A. V. Voronov, R. V. Voronov, and R. F. Iliasov, “Multibank memory bandwidth analysis in on-chip system,” Problems of advanced micro- and nanoelectronic systems development. FSFIS Institute for Design Problems in Microelectronics RAS, pp. 99–105, 2021. doi: 10.31114/2078-7707-2021-4-99-105
```

### Presentation

The slides of the project presentation are available in the `doc/presentation/` directory. These slides provide explained details and key findings.

### Usefull links

- [Understanding Multiport-Memories](https://tomverbeure.github.io/2019/08/03/Multiport-Memories.html): Considers various implementation of multiport memory (Flip-Flop, Live Value Table, XOR-Based, etc...)  
- [Collection of Multi-Ported Memories](http://fpgacpu.ca/multiport/): Collects various articles related to multiport memory for FPGAs (and ASICs too)

## Acknowledgments

Thanks to [Yuri Panchul](https://github.com/yuri-panchul) for advising us on the concept of multiport memory. We are thankful to [Dmitry Smekhov](https://github.com/dsmv) for preparing the testbench for memory design and Innopolis University for inspiration in writing an article on this topic.
