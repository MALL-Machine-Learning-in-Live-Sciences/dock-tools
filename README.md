# Dock-tools

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15064460.svg)](https://doi.org/10.5281/zenodo.15064460)
![GitHub release](https://img.shields.io/github/v/release/MALL-Machine-Learning-in-Live-Sciences/dock-tools?label=release)
![Maintenance](https://img.shields.io/badge/Maintenance-Actively%20Maintained-brightgreen)
![GitHub contributors](https://img.shields.io/github/contributors/MALL-Machine-Learning-in-Live-Sciences/dock-tools)
![GitHub last commit](https://img.shields.io/github/last-commit/MALL-Machine-Learning-in-Live-Sciences/dock-tools)

# Building the Dock-Tools Image Locally

Follow these steps to generate the "dock-tools" Docker image on your local machine.

## Prerequisites

- Ensure Docker is installed on your machine.
- Verify Docker is running and accessible.

## Steps

1. **Clone the Repository**

   Clone the repository containing the Dockerfile and necessary resources:

   ```bash
   git clone git@github.com:MALL-Machine-Learning-in-Live-Sciences/dock-tools.git
   cd dock-tools
   ```

2. **Navigate to the Dockerfile Directory**

   Ensure you are in the same directory as the Dockerfile:

   ```bash
   cd path/to/dockerfile
   ```

3. **Build the Docker Image**

   Use Docker to build the image:

   ```bash
   docker build -t dock-tools:latest .
   ```

   - `-t dock-tools:latest` tags the image with the name "dock-tools" and the "latest" tag.
   - The `.` specifies the current directory as the context.

4. **Verify the Image Build**

   Confirm the image was created successfully:

   ```bash
   docker images
   ```

   Look for the "dock-tools" image in the list.

5. **Run the Docker Image**

   Test your new image by running a container:

   ```bash
   docker run -it --rm dock-tools:latest
   ```

   - `-it` runs the container interactively.
   - `--rm` removes the container once stopped.

   The _usage_ info for version v1.0 will be displayed with information on how to use dock-tools.

```sh
Usage: docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output reposudoe/dock-tools:v1.0 [experimentType] [OPTIONS]

INFO:
  -v $PWD/input:/input   Mounts the local input directory to the container /input directory.
  -v $PWD/output:/output Mounts the local output directory to the container /output directory.

The paths enable data to be shared between your host machine and the Docker container, allowing you
to provide input files and retrieve output files easily.

Experiment Type:
   vina (executes Vina version 1.2.6)
      Input Parameters:
        receptor.pdb (receptor file)
        ligand.sdf (ligand file)
        You must choose either --box_enveloping or both --box_size and --box_center

        --box_enveloping (requires padding; cannot be used with --box_size and --box_center)
        --padding (default: 2.0)
        --box_size (followed by three positive numbers)
        --box_center (followed by three numbers)
        --no-preprocessing (receptor processing with pdb4amber, maintaining --model 1)
        --vre (to be executed on the VRE of d4science)
        --cpu (default: 2)
        --exhaustiveness (default: 10)
        --verbosity (default: 2)
        --seed (default: 1367858384)
        --scoring (default: vina). Options: vina, ad4

Example Vina:
   Automatically generate box with --box_enveloping:
   docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output reposudoe/dock-tools:v1.0 vina 2mm3.pdb Abemaciclib.sdf --box_enveloping

   Manually define box with --box_size and --box_center:
   docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output reposudoe/dock-tools:v1.0 vina 2mm3.pdb Abemaciclib.sdf --box_size 10 10 10.1 --box_center 11 -12 13

   Manually defined options:
   docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output reposudoe/dock-tools:v1.0 vina 2mm3.pdb Abemaciclib.sdf --box_size 10 10 10.1 --box_center 11 -12 13 --cpu 20 --exhaustiveness 30 --verbosity 4 --seed 1234 --scoring ad4

Maintainers:
   - Carlos Fernandez-Lozano <carlos.fernandez@udc.es>
   - Francisco Cedrón Santaeufemia <francisco.cedron@udc.es>
   - Diego Fernández-Edreira <diego.fedreira@udc.es>

RePo-SUDOE Project. URL: https://interreg-sudoe.eu/proyecto-interreg/repo-sudoe/

Beneficiaries:
   Instituto Politécnico da Guarda (Portugal)
   Universidade da Coruña (Spain)
   Universidade de Santiago de Compostela (Spain)
   Centre National de la Recherche Scientifique (France)
   MD.USE Innovations S.L. (Spain)
   Sociedade Portuguesa de Saúde Pública (Portugal)
   Asociación Cluster Saúde de Galicia (Spain)

Associated partners:
   Servizo Galego de Saúde. Dirección Xeral de Asistencia Sanitaria (Spain)
   Centro Académico Clínico das Beiras (Portugal)
   Cancéropôle (France)
```

# Basic Usage Example for Dock-Tools

This section describes how to execute a basic docking operation using the `dock-tools` Docker image. We'll assume you have example files in your `input` directory.

## Prerequisites

- Docker installed and running on your machine.
- Example input files located in the `input` directory:
  - `2mm3.pdb` (receptor file)
  - `Abemaciclib.sdf` (ligand file)

## Command

Run the following command to execute the docking operation:

```bash
docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output reposudoe/dock-tools:v1.0 vina 2mm3.pdb Abemaciclib.sdf --box_enveloping
```

### Explanation:

- **`docker run -it --rm`:** Runs the Docker container interactively and removes it after execution.
- **`-v $PWD/input:/input`:** Mounts your local `input` directory to the container's `/input` directory.
- **`-v $PWD/output:/output`:** Mounts your local `output` directory to the container's `/output` directory.
- **`reposudoe/dock-tools:v1.0`:** Specifies the Docker image and version.
- **`vina 2mm3.pdb Abemaciclib.sdf --box_enveloping`:** Runs the `vina` command with specified receptor and ligand files, using automatic box enveloping.

## Output

The results of the docking operation will be saved in the `output` directory with the following files:

- `2mm3_Abemaciclib_out.pdbqt`: The docking output file in PDBQT format.
- `2mm3_Abemaciclib_out.pdbqt.sdf`: The docking output file converted to SDF format.
- `2mm3.pdbqt`: The receptor file in PDBQT format.
- `2mm3_Abemaciclib_vina.log`: The log file containing details of the docking process.

The output folder will contain the docking results and logs for the receptor (`2mm3`) and ligand (`Abemaciclib`), naming the files accordingly.

## Notes

- Ensure your `input` directory contains the necessary example files (`2mm3.pdb` and `Abemaciclib.sdf`).
- The results of the docking operation will be saved in the `output` directory.

This command provides a simple demonstration of how to perform a docking operation using the `dock-tools` image.

# About the RePo-SUDOE Project

The pharmaceutical development process often faces high failure rates, costs, and delays. This highlights the importance of drug repurposing, which finds new therapeutic uses for existing market drugs, benefiting the pharmaceutical industry, society, and patients alike. The RePo-SUDOE project aims to develop and disseminate drug repurposing technologies to enhance the competitiveness of the SUDOE region in this R&D area, boosting the biopharmaceutical industry and attracting skilled human resources.

The project will achieve this through three specific objectives:

1. Advance scientific knowledge and disseminate drug repurposing technologies among public and private agents, elevating SUDOE's R&D groups to European excellence.
2. Foster multidisciplinary collaboration and identify innovative opportunities in SUDOE through a transnational network, developing a database of therapeutic targets and drugs, with a primary focus on cancer treatment.
3. Create a prototype 3D visualization room for biological systems, utilizing VR and AR, aimed at young students and researchers in STEAM fields.

RePo-SUDOE unites partners from different SUDOE regions and sectors within the pharmaceutical development value chain. It provides easily accessible scientific information and visualization technologies to strengthen drug repurposing within the SUDOE space. Additionally, it addresses the demographic challenges of aging and depopulation, enhancing regional R&D competitiveness and bridging territorial disparities. By aligning with regional RIS3 strategies, RePo-SUDOE fosters innovation and sustainable employment growth, particularly in regions with traditionally low R&D intensity, thus ensuring an integrated approach to reducing inequalities and advancing regional capabilities.

**URL:** [https://interreg-sudoe.eu/proyecto-interreg/repo-sudoe/](https://interreg-sudoe.eu/proyecto-interreg/repo-sudoe/)

## Beneficiaries:
- Instituto Politécnico da Guarda (Portugal)
- Universidade da Coruña (Spain)
- Universidade de Santiago de Compostela (Spain)
- Centre National de la Recherche Scientifique (France)
- MD.USE Innovations S.L. (Spain)
- Sociedade Portuguesa de Saúde Pública (Portugal)
- Asociación Cluster Saúde de Galicia (Spain)

## Associated Partners:
- Servizo Galego de Saúde. Dirección Xeral de Asistencia Sanitaria (Spain)
- Centro Académico Clínico das Beiras (Portugal)
- Cancéropôle (France)