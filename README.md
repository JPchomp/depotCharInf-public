# depotCharInf-public

This repository contains the public version of the code accompanying the paper:

**Battery Electric Truck Infrastructure Co-design via Joint Optimization and Agent-based Simulation**

## Overview

The code provided here supports the research presented in the aforementioned paper, focusing on the co-design of infrastructure for battery electric trucks through joint optimization and agent-based simulation methodologies.

## Repository Structure

- **funs/**: Directory containing function files utilized in the simulation and optimization processes.
- **a_data_load.m**: Script for loading and preprocessing input data required for simulations.
- **a_main.m**: Main script to execute the simulation and optimization routines.
- **b_definitions.asv**: File containing variable and parameter definitions.
- **c_grid_setup.m**: Script for setting up the grid infrastructure parameters.
- **d_OutputTablesSetup.m**: Script to initialize and configure output tables for storing results.
- **d_parameters.m**: Script defining various parameters used throughout the simulations.
- **d_vehicle_setup.m**: Script for configuring vehicle-specific parameters and initial conditions.
- **datetimeVectorToString.m**, **doubleVectorToString.m**, **intVectorToString.m**: Utility functions for data type conversions.
- **efficient_implementation_for_experiments.m**: Script containing optimized implementations for experimental runs.
- **efficient_initialization_implementation.m**: Script for efficient initialization procedures.
- **efficient_solution_writing_AL.m**: Script to efficiently write solution data.
- **g_constraints_DC.asv**: File detailing direct current (DC) constraints.
- **itinTest.m**: Script for itinerary testing and validation.
- **plot_charger_usage.m**, **plot_truck_soc.m**, **truck_activities_plot.m**: Visualization scripts for analyzing charger usage, state of charge (SOC) of trucks, and truck activities, respectively.

## Getting Started

To utilize this code:

1. **Prerequisites**: Ensure that you have MATLAB installed on your system.

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/JPchomp/depotCharInf-public.git
   ```

3. **Navigate to the Repository Directory**:
   ```bash
   cd depotCharInf-public
   ```

4. **Run the Main Script**: Open MATLAB and execute `a_main.m` to start the simulation and optimization process.

## Citation

If you find this code useful in your research, please consider citing the paper:

*Battery Electric Truck Infrastructure Co-design via Joint Optimization and Agent-based Simulation*

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

For any questions or further information, please contact the repository owner through the GitHub repository's issue tracker.
